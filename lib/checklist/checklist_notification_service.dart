import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'checklist_item_schedule.dart';
import 'checklist_models.dart';
import 'checklist_notification_prefs.dart';
import '../reglage/reglage_language_prefs.dart';

/// Rappels locaux pour les lignes checklist avec [ChecklistItemData.schedule] défini.
abstract final class ChecklistNotificationService {
  ChecklistNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool get _supported {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  static bool _initialized = false;
  static bool _tzReady = false;
  static final Set<int> _scheduledIds = {};

  static Future<({String title, String bodyTemplate})> _copyForLocale() async {
    final code = await ReglageLanguagePrefs.loadCode();
    if (code.startsWith('en')) {
      return (
        title: 'Paychek checklist',
        bodyTemplate: 'Time to check: {item}',
      );
    }
    return (
      title: 'Checklist Paychek',
      bodyTemplate: 'Pense à cocher : {item}',
    );
  }

  static Future<void> ensureInitialized() async {
    if (!_supported || _initialized) return;
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      _tzReady = true;
    } catch (e, st) {
      debugPrint('[Paychek] checklist TZ init: $e\n$st');
      tz.setLocalLocation(tz.UTC);
      _tzReady = true;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static Future<bool> requestPermissionsIfNeeded() async {
    if (!_supported) return false;
    await ensureInitialized();
    var granted = true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      granted = await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          true;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      granted = await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          true;
    }
    return granted;
  }

  static int _idForItem(String itemId) => itemId.hashCode & 0x7FFFFFFF;

  static NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      'paychek_checklist_reminders',
      'Checklist reminders',
      channelDescription: 'Rappels horaires des éléments de checklist',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  static bool _shouldScheduleItem(
    ChecklistSectionData section,
    ChecklistItemData item,
  ) {
    if (!checklistSectionIsActive(section)) return false;
    if (item.schedule == null) return false;
    if (item.isCompletedForCurrentPeriod()) return false;
    final sched = item.schedule!.normalized();
    if (sched.displayMode == ChecklistScheduleMode.specificDate) {
      final d = sched.specificDate;
      if (d == null) return false;
      final day = DateTime(d.year, d.month, d.day);
      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);
      if (day.isBefore(todayDay)) return false;
    }
    return true;
  }

  static tz.TZDateTime _nextTzDateTime(ChecklistItemSchedule sched) {
    final next = ChecklistItemSchedule.nextOccurrenceDateTime(sched);
    return tz.TZDateTime.from(next, tz.local);
  }

  static DateTimeComponents? _matchComponents(ChecklistScheduleMode mode) {
    switch (mode) {
      case ChecklistScheduleMode.daily:
        return DateTimeComponents.time;
      case ChecklistScheduleMode.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case ChecklistScheduleMode.specificDate:
        return null;
    }
  }

  static Future<void> syncSections(List<ChecklistSectionData> sections) async {
    if (!_supported) return;
    await ensureInitialized();
    if (!_tzReady) return;

    final enabled = await ChecklistNotificationPrefs.isEnabled();
    final nextIds = <int>{};

    if (!enabled) {
      await _cancelAllTracked();
      return;
    }

    final hasAny = sections.any(
      (s) => s.items.any((i) => _shouldScheduleItem(s, i)),
    );
    if (hasAny) {
      final ok = await requestPermissionsIfNeeded();
      if (!ok) {
        await _cancelAllTracked();
        return;
      }
    }

    final copy = await _copyForLocale();

    for (final section in sections) {
      for (final item in section.items) {
        final id = _idForItem(item.id);
        if (!_shouldScheduleItem(section, item)) {
          if (_scheduledIds.contains(id)) {
            await _plugin.cancel(id: id);
            _scheduledIds.remove(id);
          }
          continue;
        }

        final sched = item.schedule!.normalized();
        final when = _nextTzDateTime(sched);
        if (when.isBefore(tz.TZDateTime.now(tz.local))) {
          if (sched.displayMode == ChecklistScheduleMode.specificDate) {
            continue;
          }
        }

        final title = copy.title;
        final body = copy.bodyTemplate.replaceAll('{item}', item.label);

        try {
          await _plugin.zonedSchedule(
            id: id,
            title: title,
            body: body,
            scheduledDate: when,
            notificationDetails: _details(),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: _matchComponents(sched.displayMode),
          );
          nextIds.add(id);
        } catch (e, st) {
          debugPrint(
            '[Paychek] checklist notify schedule ${item.id}: $e\n$st',
          );
        }
      }
    }

    for (final old in _scheduledIds.toList()) {
      if (!nextIds.contains(old)) {
        await _plugin.cancel(id: old);
      }
    }
    _scheduledIds
      ..clear()
      ..addAll(nextIds);
  }

  static Future<void> cancelAll() async {
    if (!_supported || !_initialized) return;
    await _cancelAllTracked();
  }

  static Future<void> _cancelAllTracked() async {
    for (final id in _scheduledIds.toList()) {
      await _plugin.cancel(id: id);
    }
    _scheduledIds.clear();
  }

  /// Après changement du toggle Réglages.
  static Future<void> onEnabledChanged(
    bool enabled,
    List<ChecklistSectionData> sections,
  ) async {
    await ChecklistNotificationPrefs.setEnabled(enabled);
    if (!enabled) {
      await cancelAll();
      return;
    }
    unawaited(syncSections(sections));
  }
}
