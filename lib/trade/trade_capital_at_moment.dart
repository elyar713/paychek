import 'trade_models.dart';

DateTime _midnightLocal(DateTime d) {
  final l = d.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// P&L cumulé des trades dont l'entrée est strictement avant [beforeExclusive],
/// ou même instant avec un id lexicographiquement inférieur à [tieBreakTradeId].
double priorTradesNetBefore({
  required Iterable<TradeListItem> allTrades,
  required DateTime beforeExclusive,
  String? tieBreakTradeId,
}) {
  var net = 0.0;
  for (final t in allTrades) {
    final e = t.entreeAt;
    if (e.isBefore(beforeExclusive)) {
      net += t.gainAmount;
    } else if (tieBreakTradeId != null &&
        e == beforeExclusive &&
        t.id.compareTo(tieBreakTradeId) < 0) {
      net += t.gainAmount;
    }
  }
  return net;
}

/// Capital de référence juste avant l'entrée d'un trade (capital courant).
double? capitalAtTradeEntry({
  required double? baseCapital,
  required TradeListItem trade,
  required Iterable<TradeListItem> allTrades,
}) {
  if (baseCapital == null) return null;
  return baseCapital +
      priorTradesNetBefore(
        allTrades: allTrades,
        beforeExclusive: trade.entreeAt,
        tieBreakTradeId: trade.id,
      );
}

/// Capital au début d'un jour civil (minuit local).
double? capitalAtDayStart({
  required double? baseCapital,
  required DateTime day,
  required Iterable<TradeListItem> allTrades,
}) {
  if (baseCapital == null) return null;
  return baseCapital +
      priorTradesNetBefore(
        allTrades: allTrades,
        beforeExclusive: _midnightLocal(day),
      );
}

/// Capital au début d'une semaine (lundi 00:00 local).
double? capitalAtWeekStart({
  required double? baseCapital,
  required DateTime weekMonday,
  required Iterable<TradeListItem> allTrades,
}) {
  if (baseCapital == null) return null;
  return baseCapital +
      priorTradesNetBefore(
        allTrades: allTrades,
        beforeExclusive: _midnightLocal(weekMonday),
      );
}

/// Capital au début d'un mois (1er jour 00:00 local).
double? capitalAtMonthStart({
  required double? baseCapital,
  required DateTime monthStart,
  required Iterable<TradeListItem> allTrades,
}) {
  if (baseCapital == null) return null;
  final start = DateTime(monthStart.year, monthStart.month, 1);
  return baseCapital +
      priorTradesNetBefore(
        allTrades: allTrades,
        beforeExclusive: _midnightLocal(start),
      );
}

/// Capital immédiatement avant chaque trade (clé = trade id), tri entrée + id.
Map<String, double> capitalBeforeTradeById({
  required double baseCapital,
  required Iterable<TradeListItem> allTrades,
}) {
  final sorted = allTrades.toList()
    ..sort((a, b) {
      final c = a.entreeAt.compareTo(b.entreeAt);
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  var running = baseCapital;
  final out = <String, double>{};
  for (final t in sorted) {
    out[t.id] = running;
    running += t.gainAmount;
  }
  return out;
}

/// Pourcentage de gain/perte par rapport à un capital de référence (> 0).
double? gainPctOfReferenceCapital(double gain, double? referenceCapital) {
  if (referenceCapital == null || referenceCapital <= 0) return null;
  return (gain / referenceCapital) * 100.0;
}
