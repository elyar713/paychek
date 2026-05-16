import 'package:flutter/material.dart';

import 'admin_models.dart';

/// Fin d’accès plein (freemium) : override admin sinon inscription + 7 j (UTC).
DateTime paychekAdminEffectiveTrialEndUtc(AdminUserRow u) {
  const trial = Duration(days: 7);
  return u.trialFreemiumOverrideUntil ?? u.joinedAt.toUtc().add(trial);
}

/// Libellé court « jours restants » avant fin essai (Lite). Pro → libellé dédié.
String paychekAdminTrialDaysRemainingShort(AdminUserRow u) {
  if (u.hasPaidPlan) return 'Pro';
  final end = paychekAdminEffectiveTrialEndUtc(u);
  final now = DateTime.now().toUtc();
  if (!end.isAfter(now)) return '0 j';
  final totalHours = end.difference(now).inHours;
  final days = (totalHours / 24).floor();
  if (days >= 1) return '$days j';
  return '<1 j';
}

/// Pastille d’engagement sur **7 jours civils UTC** glissants (aujourd’hui inclus).
///
/// - **Vert** : ouverture enregistrée chacun des 7 jours.
/// - **Orange** : au moins un jour dans la fenêtre, mais pas les 7.
/// - **Rouge** : aucune ouverture sur la fenêtre (y compr. sans historique).
enum AdminEngagementLed {
  green,
  orange,
  red,
}

String _ymdUtc(DateTime utc) {
  final d = utc.isUtc ? utc : utc.toUtc();
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

/// Fenêtre des 7 derniers jours civils UTC (clés `yyyy-MM-dd`).
Set<String> paychekAdminRolling7UtcDayKeys() {
  final today = DateTime.now().toUtc();
  final out = <String>{};
  for (var i = 0; i < 7; i++) {
    final d = today.subtract(Duration(days: i));
    out.add(_ymdUtc(d));
  }
  return out;
}

AdminEngagementLed paychekAdminEngagementLed(AdminUserRow u) {
  final window = paychekAdminRolling7UtcDayKeys();
  final opens = <String>{};
  for (final s in u.appOpenDatesUtc) {
    final t = s.trim();
    if (t.length >= 10) opens.add(t.substring(0, 10));
  }
  if (u.lastSeenAt != null) {
    opens.add(_ymdUtc(u.lastSeenAt!));
  }
  var distinct = 0;
  for (final k in opens) {
    if (window.contains(k)) distinct++;
  }
  if (distinct == 0) return AdminEngagementLed.red;
  if (distinct >= 7) return AdminEngagementLed.green;
  return AdminEngagementLed.orange;
}

Color paychekAdminEngagementLedColor(AdminEngagementLed led) {
  return switch (led) {
    AdminEngagementLed.green => const Color(0xFF22C55E),
    AdminEngagementLed.orange => const Color(0xFFF59E0B),
    AdminEngagementLed.red => const Color(0xFFEF4444),
  };
}

String paychekAdminEngagementLedTooltip(AdminEngagementLed led) {
  return switch (led) {
    AdminEngagementLed.green =>
      'Actif : ouvertures sur chacun des 7 derniers jours (UTC).',
    AdminEngagementLed.orange =>
      'Actif : ouvertures sur une partie des 7 derniers jours (ex. quelques jours dans la semaine).',
    AdminEngagementLed.red =>
      'Inactif : aucune ouverture enregistrée sur les 7 derniers jours.',
  };
}
