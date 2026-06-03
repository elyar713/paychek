import 'trade_models.dart';

/// Capital de trading effectif : capital de base + P&L cumulé du journal actif.
///
/// Aligné sur [CapitalBalanceCard] (accueil). [excludeTradeId] évite de compter
/// un trade en cours d’édition sur « Ajouter un trade ».
double? computeEffectiveTradingCapital({
  required double? baseCapital,
  required Iterable<TradeListItem> journalTrades,
  String? excludeTradeId,
}) {
  if (baseCapital == null) return null;
  var net = 0.0;
  for (final t in journalTrades) {
    if (excludeTradeId != null && t.id == excludeTradeId) continue;
    net += t.gainAmount;
  }
  return baseCapital + net;
}
