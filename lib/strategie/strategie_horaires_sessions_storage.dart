import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'strategie_tokens.dart';

/// Session « Horaires » (page Stratégie) — sérialisable pour persistance + règles Paychek Lens.
class StrategieSessionPersisted {
  const StrategieSessionPersisted({
    required this.title,
    required this.subtitle,
    required this.timeDisplay,
    required this.startHour,
    required this.startMinute,
    this.endHour,
    this.endMinute,
    required this.isNoTradeZone,
  });

  final String title;
  final String subtitle;
  final String timeDisplay;

  /// Début de fenêtre (local).
  final int startHour;
  final int startMinute;

  /// Fin inclusive ; `null` = ouvert (ex. « après 17:00 »).
  final int? endHour;
  final int? endMinute;

  final bool isNoTradeZone;

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'timeDisplay': timeDisplay,
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
        'isNoTradeZone': isNoTradeZone,
      };

  static StrategieSessionPersisted? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    final t = j['title'] as String?;
    if (t == null || t.isEmpty) return null;
    return StrategieSessionPersisted(
      title: t,
      subtitle: (j['subtitle'] as String?) ?? '',
      timeDisplay: (j['timeDisplay'] as String?) ?? '—',
      startHour: (j['startHour'] as num?)?.toInt() ?? 0,
      startMinute: (j['startMinute'] as num?)?.toInt() ?? 0,
      endHour: (j['endHour'] as num?)?.toInt(),
      endMinute: (j['endMinute'] as num?)?.toInt(),
      isNoTradeZone: j['isNoTradeZone'] as bool? ?? false,
    );
  }
}

/// Persistance des sessions (édition page Stratégie).
abstract final class StrategieHorairesSessionsStorage {
  StrategieHorairesSessionsStorage._();

  static const _kBase = 'strategie_horaires_sessions_v1';
  static String get _k => paychekScopedPrefsKey(_kBase);

  /// Valeurs par défaut alignées sur [StrategieHorairesSessionsSection].
  static List<StrategieSessionPersisted> defaultSessions() => [
        const StrategieSessionPersisted(
          title: 'Session de Londres',
          subtitle: 'Forte volatilité (Forex)',
          timeDisplay: '09:00 - 11:30',
          startHour: 9,
          startMinute: 0,
          endHour: 11,
          endMinute: 30,
          isNoTradeZone: false,
        ),
        const StrategieSessionPersisted(
          title: 'Session de New York',
          subtitle: 'Ouverture US (Indices)',
          timeDisplay: '14:30 - 16:30',
          startHour: 14,
          startMinute: 30,
          endHour: 16,
          endMinute: 30,
          isNoTradeZone: false,
        ),
        const StrategieSessionPersisted(
          title: 'Zone Rouge (No Trade)',
          subtitle: 'Fin de journée',
          timeDisplay: 'Après 17:00',
          startHour: 17,
          startMinute: 0,
          endHour: null,
          endMinute: null,
          isNoTradeZone: true,
        ),
      ];

  static Future<List<StrategieSessionPersisted>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw == null || raw.isEmpty) return defaultSessions();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final out = <StrategieSessionPersisted>[];
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          final s = StrategieSessionPersisted.fromJson(e);
          if (s != null) out.add(s);
        } else if (e is Map) {
          final s = StrategieSessionPersisted.fromJson(Map<String, dynamic>.from(e));
          if (s != null) out.add(s);
        }
      }
      return out.isEmpty ? defaultSessions() : out;
    } catch (_) {
      return defaultSessions();
    }
  }

  static Future<void> save(List<StrategieSessionPersisted> sessions) async {
    final p = await SharedPreferences.getInstance();
    final raw = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await p.setString(_k, raw);
  }
}

/// Reconstruit les champs UI d’une ligne session à partir du modèle persisté.
({
  IconData icon,
  Color iconBg,
  Color iconColor,
  Color titleColor,
  Color timeColor,
  TimeOfDay? startTime,
  TimeOfDay? endTime,
}) strategieSessionVisuals(StrategieSessionPersisted s) {
  final noTrade = s.isNoTradeZone;
  return (
    icon: noTrade ? LucideIcons.moon : LucideIcons.sunrise,
    iconBg: noTrade ? const Color(0xFF2A1515) : const Color(0xFF0D2A22),
    iconColor: noTrade ? const Color(0xFFE57373) : StrategieTokens.emerald,
    titleColor: noTrade ? StrategieTokens.riskRed : Colors.white,
    timeColor: noTrade ? StrategieTokens.riskRed : Colors.white,
    startTime: TimeOfDay(hour: s.startHour, minute: s.startMinute),
    endTime: (s.endHour != null && s.endMinute != null)
        ? TimeOfDay(hour: s.endHour!, minute: s.endMinute!)
        : null,
  );
}
