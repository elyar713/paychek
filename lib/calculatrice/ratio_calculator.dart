import '../ajouter_trade/ajouter_trade_asset_class.dart';
import 'calculatrice_models.dart';

RatioResult computeRatio({
  required AjouterTradeAssetClass market,
  required String asset,
  required double lot,
  required double entry,
  required double sl,
  required double tp,
  required double? capital,
}) {
  final spec = assetSpecFor(market, asset);
  final riskPerUnit = (entry - sl).abs();
  final rewardPerUnit = (tp - entry).abs();
  final ratio = rewardPerUnit / riskPerUnit;

  final multiplier = spec.multiplier;
  final riskMoney = riskPerUnit * lot * multiplier;
  final rewardMoney = rewardPerUnit * lot * multiplier;
  final riskPctOfCapital =
      (capital == null || capital <= 0) ? null : (riskMoney / capital) * 100.0;

  return RatioResult(
    ratio: ratio,
    riskMoney: riskMoney,
    rewardMoney: rewardMoney,
    riskPctOfCapital: riskPctOfCapital,
  );
}

