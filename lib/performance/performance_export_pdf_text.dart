part of 'performance_export_pdf.dart';

String _periodLabel(PerformancePeriodFilter p, DateTime anchor, DateTime? customStart, Locale locale) {
  switch (p) {
    case PerformancePeriodFilter.all:
      return _p(locale, 'Tout l\'historique', 'All history', 'Todo el historial', 'Gesamte Historie', 'Todo o histórico', '전체 기록');
    case PerformancePeriodFilter.oneDay:
      return _p(locale, 'Aujourd\'hui', 'Today', 'Hoy', 'Heute', 'Hoje', '오늘');
    case PerformancePeriodFilter.yesterday:
      return _p(locale, 'Hier', 'Yesterday', 'Ayer', 'Gestern', 'Ontem', '어제');
    case PerformancePeriodFilter.threeDays:
      return _p(locale, '3 derniers jours', 'Last 3 days', 'Últimos 3 días', 'Letzte 3 Tage', 'Últimos 3 dias', '최근 3일');
    case PerformancePeriodFilter.oneWeek:
      return _p(locale, 'Cette semaine (7 jours)', 'Last 7 days', 'Últimos 7 días', 'Letzte 7 Tage', 'Últimos 7 dias', '최근 7일');
    case PerformancePeriodFilter.lastWeek:
      return _p(locale, 'Semaine civile précédente', 'Previous calendar week', 'Semana civil anterior', 'Vorherige Kalenderwoche', 'Semana civil anterior', '직전 주(월~일)');
    case PerformancePeriodFilter.lastMonth:
      return _p(locale, 'Mois glissant précédent', 'Prior rolling month', 'Mes móvil anterior', 'Rollierender Monat zuvor', 'Mês móvel anterior', '직전 같은 날짜 기준 한 달');
    case PerformancePeriodFilter.currentMonth:
      return _p(locale, 'Mois en cours', 'Current month', 'Mes actual', 'Aktueller Monat', 'Mês atual', '이번 달');
    case PerformancePeriodFilter.custom:
      if (customStart == null) {
        return _p(locale, 'Période personnalisée', 'Custom period', 'Periodo personalizado', 'Benutzerdefiniert', 'Personalizado', '사용자 기간');
      }
      final d = DateTime(customStart.year, customStart.month, customStart.day);
      final dd = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      return _p(locale, 'Du $dd', 'From $dd', 'Desde $dd', 'Ab $dd', 'De $dd', '$dd부터');
  }
}
