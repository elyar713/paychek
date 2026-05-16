import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_side.dart';

/// Gain monétaire estimé (approx. **USD** pour les instruments multi-devises).
///
/// Interprétation des champs :
/// - **Forex** : [quantity] = lots standards (100k).
/// - **Indice / Future** : entrée & sortie = **cours / indice** ; [quantity] = contrats.
/// - **Crypto** : [quantity] = unités (coins) ; paire ***/USD**.
/// - **Action** : [quantity] = nombre d’actions ; prix en devise du titre (souvent USD).
/// - **Matières premières** : [quantity] = contrats ; delta = variation du sous-jacent ($).
double? estimateMonetaryGain({
  required AjouterTradeAssetClass assetClass,
  required String actif,
  required AjouterTradeSide side,
  required double quantity,
  required double entry,
  required double exit,
}) {
  if (quantity <= 0 || !entry.isFinite || !exit.isFinite) return null;
  final delta =
      side == AjouterTradeSide.long ? exit - entry : entry - exit;

  switch (assetClass) {
    case AjouterTradeAssetClass.forex:
      return _forexGainApproxUsd(actif, quantity, entry, delta);
    case AjouterTradeAssetClass.indice:
      return _indiceGainUsd(actif, quantity, delta);
    case AjouterTradeAssetClass.future:
      return _futureGainUsd(actif, quantity, delta);
    case AjouterTradeAssetClass.crypto:
    case AjouterTradeAssetClass.stock:
      return delta * quantity;
    case AjouterTradeAssetClass.matieresPremieres:
      return _matieresGainUsd(actif, quantity, delta);
  }
}

// --- Indices CFD : $ par **point d’indice** × contrats (aligné usage retail) ---
double _indiceGainUsd(String sym, double contracts, double deltaPoints) {
  const m = <String, double>{
    'NAS100': 20,
    'US30': 5,
    'US500': 50,
    'US2000': 5,
    'GER40': 25,
    'UK100': 10,
    'FRA40': 10,
    'EU50': 10,
    'JPN225': 10,
    'AUS200': 10,
    'HK50': 5,
    'ESP35': 10,
    'SWI20': 10,
    'CHINA50': 10,
    'VIX': 100,
  };
  final key = sym.toUpperCase().trim();
  final usdPerPoint = m[key] ?? 15.0;
  return deltaPoints * usdPerPoint * contracts;
}

// --- Futures CME-style : $ P&L par **1,00 unité de prix** du contrat × contrats ---
double _futureGainUsd(String sym, double contracts, double deltaPrice) {
  const m = <String, double>{
    // E-mini / micro indices ($ / point d’indice)
    'ES': 50,
    'NQ': 20,
    'YM': 5,
    'RTY': 50,
    'MES': 5,
    'MNQ': 2,
    'MYM': 0.5,
    'M2K': 5,
    // Énergies & métaux ($ / 1,00 $ au sous-jacent côté contrat standard)
    'CL': 1000,
    'MCL': 100,
    'GC': 100,
    'MGC': 10,
    'SI': 5000,
    'SIL': 2500,
    // Taux (ordre de grandeur : ~1000 $ / point entier de cotation obligataire)
    'ZB': 1000,
    'ZN': 800,
    'NG': 10000,
    'HG': 25000,
  };
  final key = sym.toUpperCase().trim();
  final mult = m[key];
  if (mult != null) {
    return deltaPrice * mult * contracts;
  }
  return deltaPrice * 50 * contracts;
}

// --- Matières premières (libellés FR) : $ / 1,00 $ de move sous-jacent × contrats ---
double _matieresGainUsd(String label, double contracts, double deltaUnderlying) {
  final n = label.toLowerCase();
  double usdPerDollarMove;
  if (n.contains('pétrole') ||
      n.contains('crude') ||
      n.contains('wti') ||
      n.contains('brent')) {
    usdPerDollarMove = 1000;
  } else if (n.contains('xau') || n.contains('or')) {
    usdPerDollarMove = 100;
  } else if (n.contains('xag') || n.contains('argent')) {
    usdPerDollarMove = 5000;
  } else if (n.contains('cuivre')) {
    usdPerDollarMove = 25000;
  } else if (n.contains('blé') || n.contains('wheat')) {
    usdPerDollarMove = 50;
  } else {
    usdPerDollarMove = 100;
  }
  return deltaUnderlying * usdPerDollarMove * contracts;
}

double _forexGainApproxUsd(
  String pair,
  double lots,
  double entry,
  double delta,
) {
  final p = pair.toUpperCase().replaceAll(' ', '');

  if (p.contains('XAU')) {
    return delta * 100 * lots;
  }
  if (p.contains('XAG')) {
    return delta * 50 * lots;
  }

  if (p.startsWith('USD/') && p.contains('JPY')) {
    final rate = entry.abs() < 1e-6 ? 150.0 : entry;
    final pips = delta / 0.01;
    final pipUsd = 1000.0 / rate.clamp(50.0, 250.0);
    return pips * pipUsd * lots;
  }

  if (p.contains('JPY')) {
    final pips = delta / 0.01;
    return pips * 9.0 * lots;
  }

  if (p.contains('/USD')) {
    final pips = delta / 0.0001;
    return pips * 10.0 * lots;
  }

  if (p.startsWith('USD/')) {
    final pips = delta / 0.0001;
    return pips * 9.0 * lots;
  }

  final pips = delta / 0.0001;
  return pips * 10.0 * lots;
}
