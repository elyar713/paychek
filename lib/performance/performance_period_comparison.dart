import 'performance_trade_model.dart';

class PeriodStats {
  const PeriodStats({
    required this.tradeCount,
    required this.profitSum,
    required this.commissionSum,
  });

  final int tradeCount;
  final double profitSum;
  final double commissionSum;

  double get grossProfit => profitSum + commissionSum;
}

class PeriodComparisonResult {
  const PeriodComparisonResult({
    required this.anchor,
    required this.currentLabel,
    required this.previousLabel,
    required this.current,
    required this.previous,
  });

  final DateTime anchor;
  final String currentLabel;
  final String previousLabel;
  final PeriodStats current;
  final PeriodStats previous;
}

PeriodStats aggregateTradesInRange(
  List<Trade> trades,
  DateTime start,
  DateTime end,
) {
  var count = 0;
  var p = 0.0;
  var c = 0.0;
  for (final t in trades) {
    final d = t.date;
    if (!d.isBefore(start) && d.isBefore(end)) {
      count++;
      p += t.profit;
      c += t.commission;
    }
  }
  return PeriodStats(tradeCount: count, profitSum: p, commissionSum: c);
}

String _fmtFrDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

PeriodComparisonResult compareCurrentVsPreviousPeriod(
  List<Trade> trades,
  String period,
) {
  const empty = PeriodStats(tradeCount: 0, profitSum: 0, commissionSum: 0);
  if (trades.isEmpty) {
    return PeriodComparisonResult(
      anchor: DateTime.now(),
      currentLabel: '',
      previousLabel: '',
      current: empty,
      previous: empty,
    );
  }
  final maxD = trades.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b);
  final anchor = DateTime(maxD.year, maxD.month, maxD.day);

  switch (period) {
    case 'day':
      final curStart = anchor;
      final curEnd = curStart.add(const Duration(days: 1));
      final prevStart = curStart.subtract(const Duration(days: 1));
      final prevEnd = curStart;
      return PeriodComparisonResult(
        anchor: anchor,
        currentLabel: _fmtFrDate(curStart),
        previousLabel: _fmtFrDate(prevStart),
        current: aggregateTradesInRange(trades, curStart, curEnd),
        previous: aggregateTradesInRange(trades, prevStart, prevEnd),
      );
    case 'week':
      final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
      final curStart = DateTime(monday.year, monday.month, monday.day);
      final curEnd = curStart.add(const Duration(days: 7));
      final prevStart = curStart.subtract(const Duration(days: 7));
      final prevEnd = curStart;
      return PeriodComparisonResult(
        anchor: anchor,
        currentLabel: 'Semaine du ${_fmtFrDate(curStart)}',
        previousLabel: 'Semaine précédente',
        current: aggregateTradesInRange(trades, curStart, curEnd),
        previous: aggregateTradesInRange(trades, prevStart, prevEnd),
      );
    case 'month':
      final curStart = DateTime(anchor.year, anchor.month, 1);
      final curEnd = DateTime(anchor.year, anchor.month + 1, 1);
      final prevStart = DateTime(anchor.year, anchor.month - 1, 1);
      final prevEnd = curStart;
      return PeriodComparisonResult(
        anchor: anchor,
        currentLabel:
            '${anchor.month.toString().padLeft(2, '0')}/${anchor.year}',
        previousLabel: 'Mois précédent',
        current: aggregateTradesInRange(trades, curStart, curEnd),
        previous: aggregateTradesInRange(trades, prevStart, prevEnd),
      );
    default:
      return PeriodComparisonResult(
        anchor: anchor,
        currentLabel: '',
        previousLabel: '',
        current: empty,
        previous: empty,
      );
  }
}

String? normalizeStatsPeriod(String? raw) {
  if (raw == 'day' || raw == 'week' || raw == 'month') return raw;
  return null;
}
