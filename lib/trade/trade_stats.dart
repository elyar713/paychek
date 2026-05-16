import 'trade_models.dart';

/// Statistiques communes du module Trade (source "mère" pour l'app).
class TradeStats {
  const TradeStats({
    required this.wins,
    required this.losses,
  });

  final int wins;
  final int losses;

  int get denom => wins + losses;

  double get winRatePctRaw => denom <= 0 ? 0.0 : (100.0 * wins / denom);

  /// Aligné avec le ring du dashboard: % entier non arrondi (66.6 -> 66).
  int get winRatePctDisplay => winRatePctRaw.floor().clamp(0, 100);
}

TradeStats computeTradeStats(Iterable<TradeListItem> items) {
  var w = 0;
  var l = 0;
  for (final t in items) {
    if (!t.isClosed) continue;
    if (t.countsAsClosedBreakevenOrFlat) continue;
    if (t.gainAmount > 0) {
      w++;
    } else if (t.gainAmount < 0) {
      l++;
    }
  }
  return TradeStats(wins: w, losses: l);
}

