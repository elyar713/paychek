import 'ajouter_trade_asset_class.dart';

/// Distance de stop par défaut pour l’estimation (pips, points, $ selon le marché).
double defaultStopDistanceForSizing(AjouterTradeAssetClass c) {
  switch (c) {
    case AjouterTradeAssetClass.forex:
      return 25;
    case AjouterTradeAssetClass.indice:
    case AjouterTradeAssetClass.future:
      return 15;
    case AjouterTradeAssetClass.crypto:
      return 500;
    case AjouterTradeAssetClass.stock:
      return 5;
    case AjouterTradeAssetClass.matieresPremieres:
      return 2;
  }
}

/// Libellé court pour le champ stop dans l’UI.
String stopFieldHintLabel(AjouterTradeAssetClass c) {
  switch (c) {
    case AjouterTradeAssetClass.forex:
      return 'pips';
    case AjouterTradeAssetClass.indice:
    case AjouterTradeAssetClass.future:
      return 'points';
    case AjouterTradeAssetClass.stock:
      return r'$ / action';
    case AjouterTradeAssetClass.crypto:
      return r'$ / unité';
    case AjouterTradeAssetClass.matieresPremieres:
      return r'$ sous-jacent';
  }
}

/// Unité de la taille suggérée (lot, contrat, action…).
String suggestedSizeUnitLabel(AjouterTradeAssetClass c) {
  switch (c) {
    case AjouterTradeAssetClass.forex:
      return 'lot std';
    case AjouterTradeAssetClass.indice:
    case AjouterTradeAssetClass.future:
      return 'contrats';
    case AjouterTradeAssetClass.stock:
      return 'actions';
    case AjouterTradeAssetClass.crypto:
      return 'unités';
    case AjouterTradeAssetClass.matieresPremieres:
      return 'contrats (estim.)';
  }
}

double _forexPipValuePerStdLot(String pair) {
  final p = pair.toUpperCase();
  if (p.contains('JPY')) return 9;
  if (p.contains('XAU') || p.contains('GOLD')) return 10;
  if (p.contains('XAG') || p.contains('SILVER')) return 50;
  return 10;
}

/// $ (ou équivalent compte) par **1 point** d’indice CFD — approximation retail.
double? _indiceUsdPerPoint(String sym) {
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
  return m[sym.toUpperCase().trim()];
}

/// $ P&L par unité de mouvement du contrat (point, tick dollar…) — approximation.
double? _futureUsdPerMovementUnit(String sym) {
  const m = <String, double>{
    'ES': 50,
    'NQ': 20,
    'YM': 5,
    'RTY': 50,
    'MES': 5,
    'MNQ': 2,
    'MYM': 0.5,
    'M2K': 5,
    'CL': 1000,
    'MCL': 500,
    'GC': 100,
    'MGC': 10,
    'SI': 50,
    'SIL': 25,
    'ZB': 50,
    'ZN': 16,
    'NG': 100,
    'HG': 250,
  };
  return m[sym.toUpperCase().trim()];
}

double _commodityUsdPerMove(String label) {
  final n = label.toLowerCase();
  if (n.contains('pétrole') ||
      n.contains('crude') ||
      n.contains('wti') ||
      n.contains('brent')) {
    return 1000;
  }
  if (n.contains('xau')) return 100;
  if (n.contains('xag')) return 50;
  if (n.contains('cuivre')) return 125;
  if (n.contains('blé') || n.contains('wheat')) return 50;
  return 100;
}

/// Taille de position suggérée, ou `null` si paramètres insuffisants ou symbole inconnu.
double? computeSuggestedPositionSize({
  required AjouterTradeAssetClass assetClass,
  required String symbol,
  double? capitalAmount,
  required double riskPercent,
  required double stopDistance,
}) {
  final cap = capitalAmount;
  if (cap == null || cap <= 0 || riskPercent <= 0) return null;
  final risk = cap * (riskPercent / 100.0);
  final d = stopDistance;
  if (d <= 0 || !d.isFinite || !risk.isFinite) return null;

  switch (assetClass) {
    case AjouterTradeAssetClass.forex:
      final pipVal = _forexPipValuePerStdLot(symbol);
      final denom = d * pipVal;
      if (denom <= 0) return null;
      final lots = risk / denom;
      if (!lots.isFinite || lots <= 0) return null;
      return lots;

    case AjouterTradeAssetClass.indice:
      final root = symbol.toUpperCase().split('/').first.trim();
      final mult = _indiceUsdPerPoint(root);
      if (mult == null) return null;
      final denom = d * mult;
      if (denom <= 0) return null;
      final c = risk / denom;
      if (!c.isFinite || c <= 0) return null;
      return c;

    case AjouterTradeAssetClass.future:
      final root = symbol.toUpperCase().split('/').first.trim();
      final mult = _futureUsdPerMovementUnit(root);
      if (mult == null) return null;
      final denom = d * mult;
      if (denom <= 0) return null;
      final c = risk / denom;
      if (!c.isFinite || c <= 0) return null;
      return c;

    case AjouterTradeAssetClass.stock:
      final denom = d;
      if (denom <= 0) return null;
      final sh = risk / denom;
      if (!sh.isFinite || sh <= 0) return null;
      return sh;

    case AjouterTradeAssetClass.crypto:
      final denom = d;
      if (denom <= 0) return null;
      final u = risk / denom;
      if (!u.isFinite || u <= 0) return null;
      return u;

    case AjouterTradeAssetClass.matieresPremieres:
      final mult = _commodityUsdPerMove(symbol);
      final denom = d * mult;
      if (denom <= 0) return null;
      final c = risk / denom;
      if (!c.isFinite || c <= 0) return null;
      return c;
  }
}
