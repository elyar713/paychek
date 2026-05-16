import 'ajouter_trade_gain_estimate.dart';
import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_side.dart';

double? parseAjouterTradeAmount(String raw) {
  final t = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

/// Gain monétaire estimé : uniquement si la sortie est saisie (+ entrée, qty valides).
double? estimateAjouterTradeMonetaryGain({
  required bool breakeven,
  required bool positionEnCours,
  required String sortieText,
  required String quantiteText,
  required String entreeText,
  required AjouterTradeAssetClass assetClass,
  required String actif,
  required AjouterTradeSide side,
}) {
  if (breakeven) return 0;
  if (positionEnCours) return null;
  if (sortieText.trim().isEmpty) return null;
  final qty = parseAjouterTradeAmount(quantiteText);
  final entree = parseAjouterTradeAmount(entreeText);
  final sortie = parseAjouterTradeAmount(sortieText);
  if (qty == null || entree == null || sortie == null) return null;
  if (qty <= 0) return null;
  return estimateMonetaryGain(
    assetClass: assetClass,
    actif: actif,
    side: side,
    quantity: qty,
    entry: entree,
    exit: sortie,
  );
}
