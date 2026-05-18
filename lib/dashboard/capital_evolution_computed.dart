import 'evolution_spot.dart';
import 'evolution_spot_context.dart';
import '../trade/pnl_curve_scale.dart';
import '../trade/trade_models.dart';
import '../trade/trade_week_utils.dart';

/// Données pour la courbe d’évolution (PnL cumulé) + métadonnées période.
class CapitalEvolutionComputed {
  const CapitalEvolutionComputed({
    required this.spots,
    required this.spotContexts,
    required this.minY,
    required this.maxY,
    required this.periodNet,
    required this.tradeCount,
    required this.tradesInPeriod,
  });

  final List<EvolutionSpot> spots;

  /// Une entrée par sommet (tooltips / survol), même longueur que [spots].
  final List<EvolutionSpotContext> spotContexts;
  final double minY;
  final double maxY;
  final double periodNet;
  final int tradeCount;
  final List<TradeListItem> tradesInPeriod;

  static DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  static List<TradeListItem> _tradesEntreeOnDay(
    Iterable<TradeListItem> pool,
    DateTime dayMidnight,
  ) {
    final key = _midnight(dayMidnight);
    return pool
        .where((t) {
          final l = t.entreeAt.toLocal();
          return _midnight(l) == key;
        })
        .toList()
      ..sort((a, b) => a.entreeAt.compareTo(b.entreeAt));
  }

  static CapitalEvolutionComputed empty() {
    final d = DateTime.now().toLocal();
    final mid = _midnight(d);
    return CapitalEvolutionComputed(
      spots: const [EvolutionSpot(1, 0), EvolutionSpot(2, 0)],
      spotContexts: [
        EvolutionSpotContext(referenceDayLocalMidnight: mid),
        EvolutionSpotContext(referenceDayLocalMidnight: mid),
      ],
      minY: -PnlCurveScale.symmetricFlatExtent,
      maxY: PnlCurveScale.symmetricFlatExtent,
      periodNet: 0,
      tradeCount: 0,
      tradesInPeriod: [],
    );
  }

  static CapitalEvolutionComputed fromTrades(
    List<TradeListItem> allTrades,
    int timeframeIndex, {
    int tradingDaysPerWeek = 7,
  }) {
    if (allTrades.isEmpty) return empty();

    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);

    switch (timeframeIndex) {
      case 0:
        return _oneDay(allTrades, today);
      case 1:
        return _oneWeek(allTrades, today, tradingDaysPerWeek);
      case 2:
        return forFocusedCalendarMonth(allTrades, today);
      default:
        return _allRange(allTrades, today);
    }
  }

  static CapitalEvolutionComputed _oneDay(
    List<TradeListItem> allTrades,
    DateTime today,
  ) {
    final end = today.add(const Duration(days: 1));
    final dayTrades = allTrades.where((t) {
      final e = t.entreeAt.toLocal();
      return !e.isBefore(today) && e.isBefore(end);
    }).toList()..sort((a, b) => a.entreeAt.compareTo(b.entreeAt));

    final todayMid = _midnight(today);
    final spots = <EvolutionSpot>[const EvolutionSpot(1, 0)];
    final contexts = <EvolutionSpotContext>[
      EvolutionSpotContext(referenceDayLocalMidnight: todayMid),
    ];

    var cum = 0.0;
    for (var i = 0; i < dayTrades.length; i++) {
      cum += dayTrades[i].gainAmount;
      spots.add(EvolutionSpot((i + 2).toDouble(), cum));
      contexts.add(
        EvolutionSpotContext(
          referenceDayLocalMidnight: todayMid,
          tradesOnSlice: [dayTrades[i]],
        ),
      );
    }
    if (spots.length < 2) {
      spots.add(const EvolutionSpot(2, 0));
      contexts.add(EvolutionSpotContext(referenceDayLocalMidnight: todayMid));
    }

    final periodNet = dayTrades.fold<double>(0, (s, t) => s + t.gainAmount);
    return _finish(
      spots,
      contexts,
      periodNet,
      dayTrades.length,
      dayTrades,
    );
  }

  static CapitalEvolutionComputed _oneWeek(
    List<TradeListItem> allTrades,
    DateTime today,
    int tradingDaysPerWeek,
  ) {
    final days = tradeCurrentWeekDaysLocal(tradingDaysPerWeek: tradingDaysPerWeek);
    final daily = tradeDailyNetForDays(allTrades, days);
    var cum = 0.0;
    final spots = <EvolutionSpot>[];
    final contexts = <EvolutionSpotContext>[];
    for (var i = 0; i < daily.length; i++) {
      cum += daily[i];
      spots.add(EvolutionSpot((i + 1).toDouble(), cum));
      final dMid = _midnight(days[i]);
      contexts.add(
        EvolutionSpotContext(
          referenceDayLocalMidnight: dMid,
          tradesOnSlice: _tradesEntreeOnDay(allTrades, dMid),
        ),
      );
    }
    if (spots.length < 2) {
      return empty();
    }

    final tradesInPeriod = tradesWithEntreeOnDays(allTrades, days);
    final periodNet = daily.fold<double>(0, (a, b) => a + b);
    return _finish(
      spots,
      contexts,
      periodNet,
      tradesInPeriod.length,
      tradesInPeriod,
    );
  }

  /// Courbe cumulée + contextes trades par jour pour un mois précis (Calendrier, carte dashboard).
  static CapitalEvolutionComputed forFocusedCalendarMonth(
    List<TradeListItem> allTrades,
    DateTime focusedMonthAnyDay,
  ) {
    final first = DateTime(
      focusedMonthAnyDay.year,
      focusedMonthAnyDay.month,
      1,
    );
    final next = DateTime(focusedMonthAnyDay.year, focusedMonthAnyDay.month + 1, 1);
    final n = next.difference(first).inDays;
    if (n <= 0) return empty();

    final dayList = List<DateTime>.generate(
      n,
      (i) => first.add(Duration(days: i)),
    );
    final daily = tradeDailyNetForDays(allTrades, dayList);
    var cum = 0.0;
    final spots = <EvolutionSpot>[];
    final contexts = <EvolutionSpotContext>[];
    for (var i = 0; i < n; i++) {
      cum += daily[i];
      spots.add(EvolutionSpot((i + 1).toDouble(), cum));
      final dMid = _midnight(dayList[i]);
      contexts.add(
        EvolutionSpotContext(
          referenceDayLocalMidnight: dMid,
          tradesOnSlice: _tradesEntreeOnDay(allTrades, dMid),
        ),
      );
    }
    if (spots.length < 2) return empty();

    final tradesInPeriod = allTrades.where((t) {
      final e = t.entreeAt.toLocal();
      return !e.isBefore(first) && e.isBefore(next);
    }).toList();

    final periodNet = daily.fold<double>(0, (a, b) => a + b);
    return _finish(
      spots,
      contexts,
      periodNet,
      tradesInPeriod.length,
      tradesInPeriod,
    );
  }

  static CapitalEvolutionComputed _allRange(
    List<TradeListItem> allTrades,
    DateTime today,
  ) {
    final todayDay = DateTime(today.year, today.month, today.day);
    var earliest = todayDay;
    for (final t in allTrades) {
      final e = t.entreeAt.toLocal();
      final d = DateTime(e.year, e.month, e.day);
      if (d.isBefore(earliest)) earliest = d;
    }

    var start = todayDay.subtract(const Duration(days: 89));
    if (earliest.isAfter(start)) start = earliest;

    final dayList = <DateTime>[];
    for (
      var d = start;
      !d.isAfter(todayDay);
      d = d.add(const Duration(days: 1))
    ) {
      dayList.add(DateTime(d.year, d.month, d.day));
    }

    if (dayList.length > 120) {
      dayList.removeRange(0, dayList.length - 120);
    }

    if (dayList.length < 2) {
      final tradesInPeriod = List<TradeListItem>.from(allTrades);
      final net = tradesInPeriod.fold<double>(0, (s, t) => s + t.gainAmount);
      final d0 = dayList.isNotEmpty
          ? _midnight(dayList.first)
          : _midnight(todayDay);
      final d1 = dayList.isNotEmpty
          ? _midnight(dayList.last)
          : _midnight(todayDay);
      return _finish(
        [const EvolutionSpot(1, 0), EvolutionSpot(2, net.clamp(-1e9, 1e9))],
        [
          EvolutionSpotContext(referenceDayLocalMidnight: d0),
          EvolutionSpotContext(
            referenceDayLocalMidnight: d1,
            tradesOnSlice: [
              ...tradesInPeriod,
            ]..sort((a, b) => a.entreeAt.compareTo(b.entreeAt)),
          ),
        ],
        net,
        tradesInPeriod.length,
        tradesInPeriod,
      );
    }

    final daily = tradeDailyNetForDays(allTrades, dayList);
    var cum = 0.0;
    final spots = <EvolutionSpot>[];
    final contexts = <EvolutionSpotContext>[];
    for (var i = 0; i < daily.length; i++) {
      cum += daily[i];
      spots.add(EvolutionSpot((i + 1).toDouble(), cum));
      final dMid = _midnight(dayList[i]);
      contexts.add(
        EvolutionSpotContext(
          referenceDayLocalMidnight: dMid,
          tradesOnSlice: _tradesEntreeOnDay(allTrades, dMid),
        ),
      );
    }

    final startDay = dayList.first;
    final endDay = dayList.last.add(const Duration(days: 1));
    final tradesInPeriod = allTrades.where((t) {
      final e = t.entreeAt.toLocal();
      return !e.isBefore(startDay) && e.isBefore(endDay);
    }).toList();

    final periodNet = daily.fold<double>(0, (a, b) => a + b);
    return _finish(
      spots,
      contexts,
      periodNet,
      tradesInPeriod.length,
      tradesInPeriod,
    );
  }

  static CapitalEvolutionComputed _finish(
    List<EvolutionSpot> spots,
    List<EvolutionSpotContext> spotContexts,
    double periodNet,
    int tradeCount,
    List<TradeListItem> tradesInPeriod,
  ) {
    assert(
      spots.length == spotContexts.length,
      'spotContexts.length (${spotContexts.length}) != spots (${spots.length})',
    );

    final ys = spots.map((s) => s.y).toList();
    final extents = PnlCurveScale.extentsForCumulativeYs(ys);

    return CapitalEvolutionComputed(
      spots: spots,
      spotContexts: spotContexts,
      minY: extents.minY,
      maxY: extents.maxY,
      periodNet: periodNet,
      tradeCount: tradeCount,
      tradesInPeriod: tradesInPeriod,
    );
  }
}

/// Meilleur gain et plus grosse perte (gainAmount) sur une liste de trades.
/// [best] / [bestTrade] : uniquement trades en gain (gainAmount > 0).
/// [worst] / [worstTrade] : uniquement trades en perte (gainAmount < 0).
({
  double? best,
  double? worst,
  TradeListItem? bestTrade,
  TradeListItem? worstTrade,
})
tradeBestAndWorst(List<TradeListItem> trades) {
  TradeListItem? bestT;
  TradeListItem? worstT;
  double? best;
  double? worst;
  for (final t in trades) {
    final g = t.gainAmount;
    if (g > 0 && (best == null || g > best)) {
      best = g;
      bestT = t;
    }
    if (g < 0 && (worst == null || g < worst)) {
      worst = g;
      worstT = t;
    }
  }
  return (best: best, worst: worst, bestTrade: bestT, worstTrade: worstT);
}
