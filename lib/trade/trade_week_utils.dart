import 'trade_models.dart';

/// Clé jour stable `YYYY-MM-DD` (minuit local) — cartes Trade 1J / sparkline dashboard.
String tradeDayKeyLocal(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Lundi (local) de la semaine contenant [dt] (lundi = début).
DateTime tradeWeekMondayLocal(DateTime dt) {
  final l = dt.toLocal();
  final d = DateTime(l.year, l.month, l.day);
  return d.subtract(Duration(days: d.weekday - 1));
}

/// Jours de la semaine **actuelle** (lun→…) : **5** (lun–ven) ou **7** (lun–dim), date locale.
List<DateTime> tradeCurrentWeekDaysLocal({int tradingDaysPerWeek = 7}) {
  assert(tradingDaysPerWeek == 5 || tradingDaysPerWeek == 7);
  final now = DateTime.now().toLocal();
  final anchorDay = DateTime(now.year, now.month, now.day);
  final monday = tradeWeekMondayLocal(anchorDay);
  return List<DateTime>.generate(
    tradingDaysPerWeek,
    (i) => monday.add(Duration(days: i)),
  );
}

/// Index du jour courant dans [days] (minuit local), ou **-1** si aujourd’hui n’y figure pas.
int tradeTodayIndexInWeekDays(List<DateTime> days) {
  final n = DateTime.now().toLocal();
  final today = DateTime(n.year, n.month, n.day);
  for (var i = 0; i < days.length; i++) {
    final d = days[i];
    final key = DateTime(d.year, d.month, d.day);
    if (key == today) return i;
  }
  return -1;
}

/// Gain net par jour (aligné sur [days], minuit local).
List<double> tradeDailyNetForDays(
  List<TradeListItem> items,
  List<DateTime> days,
) {
  DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
  final dayKeys = days.map(dayStart).toList();
  final map = <DateTime, double>{for (final d in dayKeys) d: 0.0};
  for (final t in items) {
    final d = dayStart(t.entreeAt.toLocal());
    if (!map.containsKey(d)) continue;
    map[d] = (map[d] ?? 0) + t.gainAmount;
  }
  return [for (final d in dayKeys) map[d] ?? 0.0];
}

/// Nombre de trades par jour.
List<int> tradeDailyCountForDays(
  List<TradeListItem> items,
  List<DateTime> days,
) {
  DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
  final dayKeys = days.map(dayStart).toList();
  final map = <DateTime, int>{for (final d in dayKeys) d: 0};
  for (final t in items) {
    final d = dayStart(t.entreeAt.toLocal());
    if (!map.containsKey(d)) continue;
    map[d] = (map[d] ?? 0) + 1;
  }
  return [for (final d in dayKeys) map[d] ?? 0];
}

/// Trades dont la date d’entrée tombe sur l’un des jours (minuit local).
List<TradeListItem> tradesWithEntreeOnDays(
  Iterable<TradeListItem> items,
  List<DateTime> days,
) {
  final daySet = days.map((d) => DateTime(d.year, d.month, d.day)).toSet();
  return items.where((t) {
    final l = t.entreeAt.toLocal();
    final d = DateTime(l.year, l.month, l.day);
    return daySet.contains(d);
  }).toList();
}
