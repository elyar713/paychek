import 'dart:math' as math;

import 'performance_trade_model.dart';

/// Périodes alignées sur la maquette HTML (filtres KPI / graphiques / PDF).
enum PerformancePeriodFilter {
  /// Aucun filtre : tout l’historique importé.
  all,

  /// 1 jour (jour de référence).
  oneDay,

  /// Hier (jour précédent).
  yesterday,

  /// Fenêtre glissante : aujourd’hui − 3 jours → référence.
  threeDays,

  /// Fenêtre glissante : aujourd’hui − 7 jours → référence.
  oneWeek,

  /// Semaine civile précédente (lun–dim), même logique que le JS (getDay).
  lastWeek,

  /// ~1 mois glissant : même jour, mois précédent.
  lastMonth,

  /// Mois en cours (depuis le 1er du mois jusqu'à aujourd'hui).
  currentMonth,

  /// Date de début choisie → référence (fin).
  custom,
}

/// Plage inclusive sur les dates (sans heure).
class PerformanceDateRange {
  const PerformanceDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

/// Jour de la semaine style JavaScript `Date.getDay()` : 0 = dimanche … 6 = samedi.
int _jsGetDay(DateTime d) {
  switch (d.weekday) {
    case DateTime.sunday:
      return 0;
    case DateTime.monday:
      return 1;
    case DateTime.tuesday:
      return 2;
    case DateTime.wednesday:
      return 3;
    case DateTime.thursday:
      return 4;
    case DateTime.friday:
      return 5;
    case DateTime.saturday:
      return 6;
    default:
      return 0;
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Référence « fin de période » : le plus tard entre aujourd’hui et la date du dernier trade.
DateTime anchorDateForTrades(List<Trade> trades) {
  final today = _dateOnly(DateTime.now());
  if (trades.isEmpty) return today;
  final maxTrade = trades.map((t) => _dateOnly(t.date)).reduce((a, b) => a.isAfter(b) ? a : b);
  return maxTrade.isAfter(today) ? maxTrade : today;
}

/// Calcule [start, end] inclusif pour [period]. Pour [custom], [customStart] doit être non nul.
PerformanceDateRange? rangeForPeriod({
  required PerformancePeriodFilter period,
  required DateTime anchor,
  DateTime? customStart,
}) {
  final end = _dateOnly(anchor);

  switch (period) {
    case PerformancePeriodFilter.all:
      return null;
    case PerformancePeriodFilter.oneDay:
      return PerformanceDateRange(start: end, end: end);
    case PerformancePeriodFilter.yesterday:
      final yesterday = end.subtract(const Duration(days: 1));
      return PerformanceDateRange(start: yesterday, end: yesterday);
    case PerformancePeriodFilter.threeDays:
      return PerformanceDateRange(
        start: end.subtract(const Duration(days: 3)),
        end: end,
      );
    case PerformancePeriodFilter.oneWeek:
      return PerformanceDateRange(
        start: end.subtract(const Duration(days: 7)),
        end: end,
      );
    case PerformancePeriodFilter.lastWeek:
      final jsD = _jsGetDay(end);
      // Lundi de la semaine précédente : today - getDay() - 6
      var start = end.subtract(Duration(days: jsD + 6));
      // Dimanche de cette même semaine : today - getDay()
      final weekEnd = end.subtract(Duration(days: jsD));
      return PerformanceDateRange(start: start, end: weekEnd);
    case PerformancePeriodFilter.lastMonth:
      final lastDayPrev = DateTime(end.year, end.month, 0).day;
      final day = math.min(end.day, lastDayPrev);
      final start = DateTime(end.year, end.month - 1, day);
      return PerformanceDateRange(start: _dateOnly(start), end: end);
    case PerformancePeriodFilter.currentMonth:
      final firstDayOfMonth = DateTime(end.year, end.month, 1);
      return PerformanceDateRange(start: firstDayOfMonth, end: end);
    case PerformancePeriodFilter.custom:
      if (customStart == null) return PerformanceDateRange(start: end, end: end);
      final s = _dateOnly(customStart);
      if (s.isAfter(end)) {
        return PerformanceDateRange(start: end, end: s);
      }
      return PerformanceDateRange(start: s, end: end);
  }
}

/// Filtre les trades dont la [Trade.date] tombe dans la plage (inclusif).
List<Trade> filterTradesByRange(List<Trade> trades, PerformanceDateRange? range) {
  if (range == null) return List<Trade>.from(trades);
  final start = _dateOnly(range.start);
  final end = _dateOnly(range.end);
  return trades.where((t) {
    final d = _dateOnly(t.date);
    return !d.isBefore(start) && !d.isAfter(end);
  }).toList();
}
