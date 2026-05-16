import 'dart:ui' show Locale;

import '../performance/performance_locale_copy.dart';
import 'strategie_horaires_sessions_storage.dart';

/// Plage horaire affichée selon la langue (pas le [StrategieSessionPersisted.timeDisplay] persisté souvent FR).
String formatStrategieSessionWindow(StrategieSessionPersisted s, Locale locale) {
  String hm(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  final start = hm(s.startHour, s.startMinute);
  if (s.endHour != null && s.endMinute != null) {
    return '$start–${hm(s.endHour!, s.endMinute!)}';
  }
  return performancePickLocale(
    locale,
    'Après $start',
    'After $start',
    'Después de $start',
    'Nach $start',
    'Após $start',
    '$start 이후',
  );
}

/// Titres des sessions **[StrategieHorairesSessionsStorage.defaultSessions]** localisés ; sinon titre utilisateur tel quel.
String strategieSessionTitleForLocale(StrategieSessionPersisted s, Locale locale) {
  switch (s.title) {
    case 'Session de Londres':
      return performancePickLocale(
        locale,
        'Session de Londres',
        'London session',
        'Sesión de Londres',
        'London-Session',
        'Sessão de Londres',
        '런던 세션',
      );
    case 'Session de New York':
      return performancePickLocale(
        locale,
        'Session de New York',
        'New York session',
        'Sesión de Nueva York',
        'New-York-Session',
        'Sessão de Nova York',
        '뉴욕 세션',
      );
    case 'Zone Rouge (No Trade)':
      return performancePickLocale(
        locale,
        'Zone Rouge (No Trade)',
        'Red zone (No trade)',
        'Zona roja (sin operar)',
        'Rote Zone (No Trade)',
        'Zona vermelha (sem trade)',
        '레드 존(노 트레이드)',
      );
    default:
      return s.title;
  }
}
