import '../ajouter_trade/ajouter_trade_asset_class.dart';

class RatioResult {
  const RatioResult({
    required this.ratio,
    required this.riskMoney,
    required this.rewardMoney,
    required this.riskPctOfCapital,
  });

  final double ratio;
  final double riskMoney;
  final double rewardMoney;
  final double? riskPctOfCapital;
}

class AssetSpec {
  const AssetSpec({required this.multiplier});
  final double multiplier;
}

class TradeRow {
  const TradeRow({
    required this.index,
    required this.startBalance,
    required this.endBalance,
    required this.isWin,
    required this.pnl,
    required this.totalGain,
    required this.totalGainPct,
  });

  final int index;
  final double startBalance;
  final double endBalance;
  final bool isWin;
  final double pnl;
  final double totalGain;
  final double totalGainPct;
}

class TradeSimulationResult {
  const TradeSimulationResult({
    required this.rows,
    required this.equityCurve,
    required this.endBalance,
    required this.totalGain,
    required this.totalGainPct,
    required this.wins,
    required this.losses,
    required this.profitFactor,
    required this.maxDrawdownPct,
    required this.maxBalance,
    required this.minBalance,
  });

  final List<TradeRow> rows;
  final List<double> equityCurve;
  final double endBalance;
  final double totalGain;
  final double totalGainPct;
  final int wins;
  final int losses;
  final double profitFactor;
  final double maxDrawdownPct;
  final double maxBalance;
  final double minBalance;
}

AssetSpec assetSpecFor(AjouterTradeAssetClass market, String asset) {
  switch (market) {
    case AjouterTradeAssetClass.forex:
      return const AssetSpec(multiplier: 100000);
    case AjouterTradeAssetClass.crypto:
    case AjouterTradeAssetClass.stock:
    case AjouterTradeAssetClass.indice:
    case AjouterTradeAssetClass.matieresPremieres:
      return const AssetSpec(multiplier: 1);
    case AjouterTradeAssetClass.future:
      switch (asset) {
        case 'ES':
        case 'MES':
          return const AssetSpec(multiplier: 50);
        case 'NQ':
        case 'MNQ':
          return const AssetSpec(multiplier: 20);
        case 'YM':
        case 'MYM':
          return const AssetSpec(multiplier: 5);
        case 'RTY':
        case 'M2K':
          return const AssetSpec(multiplier: 50);
        case 'CL':
        case 'MCL':
          return const AssetSpec(multiplier: 1000);
        case 'GC':
        case 'MGC':
          return const AssetSpec(multiplier: 100);
        case 'SI':
        case 'SIL':
          return const AssetSpec(multiplier: 5000);
        default:
          return const AssetSpec(multiplier: 1);
      }
  }
}

