import 'package:flutter/material.dart';

/// Fréquence par défaut d’un élément de checklist.
enum ChecklistScheduleMode {
  daily,
  weekly,
  specificDate,
}

/// Rappel date/heure par ligne de checklist.
@immutable
class ChecklistItemSchedule {
  const ChecklistItemSchedule({
    this.mode = ChecklistScheduleMode.daily,
    this.specificDate,
    this.weekday,
    this.warningTime = const TimeOfDay(hour: 9, minute: 0),
  });

  final ChecklistScheduleMode mode;
  final DateTime? specificDate;
  /// 1 = lundi … 7 = dimanche ([DateTime.weekday]).
  final int? weekday;
  final TimeOfDay? warningTime;

  /// Mode effectif pour l’UI (résumé, couleur) — tolère données partielles.
  ChecklistScheduleMode get displayMode {
    if (mode == ChecklistScheduleMode.specificDate) {
      return ChecklistScheduleMode.specificDate;
    }
    if (mode == ChecklistScheduleMode.weekly) {
      return ChecklistScheduleMode.weekly;
    }
    if (specificDate != null) return ChecklistScheduleMode.specificDate;
    return ChecklistScheduleMode.daily;
  }

  /// `true` si le rappel n’est pas « tous les jours » (hebdo ou date précise).
  bool get isNonDailyDisplay => displayMode != ChecklistScheduleMode.daily;

  /// Champs cohérents avec [mode] avant persistance.
  ChecklistItemSchedule normalized() {
    switch (mode) {
      case ChecklistScheduleMode.daily:
        return copyWith(clearWeekday: true, clearSpecificDate: true);
      case ChecklistScheduleMode.weekly:
        return copyWith(
          clearSpecificDate: true,
          weekday: weekday ?? DateTime.now().weekday,
        );
      case ChecklistScheduleMode.specificDate:
        return copyWith(
          clearWeekday: true,
          specificDate: specificDate ?? DateTime.now(),
        );
    }
  }

  ChecklistItemSchedule copyWith({
    ChecklistScheduleMode? mode,
    DateTime? specificDate,
    bool clearSpecificDate = false,
    int? weekday,
    bool clearWeekday = false,
    TimeOfDay? warningTime,
  }) {
    return ChecklistItemSchedule(
      mode: mode ?? this.mode,
      specificDate:
          clearSpecificDate ? null : (specificDate ?? this.specificDate),
      weekday: clearWeekday ? null : (weekday ?? this.weekday),
      warningTime: warningTime ?? this.warningTime,
    );
  }

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  /// `true` si ce rappel concerne le jour [on] (défaut : aujourd’hui).
  static bool isDueOnDay(ChecklistItemSchedule s, [DateTime? on]) {
    final day = _dateOnly(on ?? DateTime.now());
    switch (s.displayMode) {
      case ChecklistScheduleMode.daily:
        return true;
      case ChecklistScheduleMode.weekly:
        final w = s.weekday;
        if (w == null || w < 1 || w > 7) return false;
        return w == day.weekday;
      case ChecklistScheduleMode.specificDate:
        final d = s.specificDate;
        return d != null && _dateOnly(d) == day;
    }
  }

  static ChecklistItemSchedule effectiveSchedule(ChecklistItemSchedule? raw) =>
      raw ?? const ChecklistItemSchedule();

  /// Jour calendaire de la prochaine occurrence (sans l’heure).
  static DateTime? resolvedDate(ChecklistItemSchedule s, [DateTime? from]) {
    final now = _dateOnly(from ?? DateTime.now());
    switch (s.displayMode) {
      case ChecklistScheduleMode.daily:
        return now;
      case ChecklistScheduleMode.specificDate:
        final d = s.specificDate;
        return d == null ? null : _dateOnly(d);
      case ChecklistScheduleMode.weekly:
        final w = s.weekday;
        if (w == null || w < 1 || w > 7) return null;
        var diff = w - now.weekday;
        if (diff < 0) diff += 7;
        return now.add(Duration(days: diff));
    }
  }

  /// Prochaine occurrence date + [warningTime] (tri dashboard / sections).
  static DateTime nextOccurrenceDateTime(
    ChecklistItemSchedule s, [
    DateTime? from,
  ]) {
    final day = resolvedDate(s, from);
    if (day == null) return DateTime(9999, 12, 31, 23, 59);
    final t = s.warningTime ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(day.year, day.month, day.day, t.hour, t.minute);
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        if (mode == ChecklistScheduleMode.specificDate && specificDate != null)
          'specificDate': _isoDate(specificDate!),
        if (mode == ChecklistScheduleMode.weekly && weekday != null)
          'weekday': weekday,
        if (warningTime != null) ...{
          'warningHour': warningTime!.hour,
          'warningMinute': warningTime!.minute,
        },
      };

  static ChecklistItemSchedule? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final modeName = raw['mode']?.toString();
    ChecklistScheduleMode mode = ChecklistScheduleMode.daily;
    for (final m in ChecklistScheduleMode.values) {
      if (m.name == modeName) {
        mode = m;
        break;
      }
    }
    DateTime? specific;
    final sd = raw['specificDate']?.toString();
    if (sd != null && sd.isNotEmpty) {
      final parts = sd.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          specific = DateTime(y, m, d);
        }
      }
      specific ??= DateTime.tryParse(sd);
    }
    final wd = raw['weekday'];
    final int? weekday = wd is int ? wd : int.tryParse('$wd');
    TimeOfDay? warn;
    final wh = raw['warningHour'];
    final wm = raw['warningMinute'];
    if (wh is int && wm is int) {
      warn = TimeOfDay(hour: wh.clamp(0, 23), minute: wm.clamp(0, 59));
    }
    var resolvedMode = mode;
    if (specific != null &&
        resolvedMode != ChecklistScheduleMode.weekly &&
        resolvedMode != ChecklistScheduleMode.specificDate) {
      resolvedMode = ChecklistScheduleMode.specificDate;
    }
    return ChecklistItemSchedule(
      mode: resolvedMode,
      specificDate: specific,
      weekday: weekday,
      warningTime: warn ?? const TimeOfDay(hour: 9, minute: 0),
    );
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
