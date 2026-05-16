import 'ajouter_trade_asset_class.dart';

const _majorsLower = <String>{
  'usd',
  'eur',
  'gbp',
  'jpy',
  'chf',
  'aud',
  'cad',
  'nzd',
  'hkd',
  'sgd',
  'sek',
  'nok',
  'zar',
  'try',
  'mxn',
  'pln',
  'rub',
};

const _indexTickersUpper = <String>{
  'NAS100',
  'US100',
  'US500',
  'US30',
  'US2000',
  'SP500',
  'GER40',
  'DE40',
  'UK100',
  'FRA40',
  'EU50',
  'ESP35',
  'JPN225',
  'HK50',
  'AUS200',
  'CHINA50',
  'SWI20',
  'VIX',
};

/// Roots normalisées type Quantower/TV pour contrats très liquides.
const _exchangeTradedFutureRootsUpper = <String>{
  'ES',
  'NQ',
  'YM',
  'RTY',
  'MES',
  'MNQ',
  'M2K',
  'MYM',
  'MCL',
  'MGC',
  'MBT',
  'MET',
  'GC',
  'SI',
  'CL',
  'NG',
  'HG',
  'SIL',
  'ZB',
  'ZN',
};

String _canonicalSymbolStem(String raw) {
  final s = raw.trim().toUpperCase();
  if (s.isEmpty) return '';
  final afterColon = s.contains(':') ? s.split(':').last.trim() : s;
  return afterColon.replaceAll(RegExp(r'\s+'), '');
}

bool _looksLikeForexConcat6(String compact) {
  if (compact.length != 6) return false;
  if (!RegExp(r'^[A-Z]+$').hasMatch(compact)) return false;
  final a = compact.substring(0, 3);
  final b = compact.substring(3, 6);
  return _majorsLower.contains(a.toLowerCase()) &&
      _majorsLower.contains(b.toLowerCase());
}

bool _looksLikeForexSlashed(String compact) {
  final slash = compact.indexOf('/');
  if (slash <= 0 || slash >= compact.length - 1) return false;
  final a = compact.substring(0, slash).toUpperCase();
  final b = compact.substring(slash + 1).toUpperCase();
  if (!RegExp(r'^[A-Z]{3}$').hasMatch(a)) return false;
  if (!RegExp(r'^[A-Z]{3,4}$').hasMatch(b)) return false;
  return _majorsLower.contains(a.toLowerCase()) &&
      _majorsLower.contains(b.toLowerCase());
}

bool _looksLikeForexDotted(String compact) {
  final dot = compact.indexOf('.');
  if (dot <= 0 || dot >= compact.length - 1) return false;
  final a = compact.substring(0, dot).toUpperCase();
  final b = compact.substring(dot + 1).toUpperCase();
  return _looksLikeForexConcat6('$a$b');
}

bool _looksLikeForexStem(String stem) =>
    _looksLikeForexConcat6(stem) ||
    _looksLikeForexSlashed(stem) ||
    _looksLikeForexDotted(stem);

bool _looksLikeCmeStyleContract(String stem) =>
    RegExp(r'[FGHJKMNQUVXZ]\d{2,4}', caseSensitive: false).hasMatch(stem);

bool _looksLikeIndexCfdStem(String stem) {
  final u = stem.toUpperCase();
  for (final t in _indexTickersUpper) {
    if (u == t) return true;
    if (!u.startsWith(t)) continue;
    final rest = u.substring(t.length);
    if (rest.isEmpty) return true;
    if (RegExp(r'^[\d._\-!]').hasMatch(rest)) return true;
    if (_looksLikeCmeStyleContract(rest)) return true;
  }
  return false;
}

bool _looksCommodityCf(String stem) {
  final u = stem.toUpperCase();
  return u.contains('XAU') ||
      u.contains('XAG') ||
      u.contains('WTI') ||
      u.contains('BRENT') ||
      u.contains('OIL') ||
      u.endsWith('GAS') ||
      u.contains('.GAS') ||
      u.contains('GAS.');
}

bool _looksCryptoStem(String stem) {
  final u = stem.toUpperCase();
  return u.contains('BTC') ||
      u.contains('ETH') ||
      u.contains('SOL.') ||
      u.contains('.SOL') ||
      u.startsWith('SOL/') ||
      u.contains('/BTC') ||
      u.contains('/ETH') ||
      u.contains('XRP') ||
      u.contains('ADA') ||
      u.contains('DOGE') ||
      u.contains('LINK') ||
      u.contains('LTC') ||
      u.contains('MATIC');
}

/// Déduit [AjouterTradeAssetClass] depuis le symbole importé (CSV brut préféré).
///
/// Sans CSV brut Quantower peut raccourcir `EURUSD` en `EU` : privilégier l’historique brut.
AjouterTradeAssetClass inferAjouterTradeAssetClassFromImportSymbol({
  required String normalizedRoot,
  String? csvSymbolOriginal,
}) {
  final rawStem = csvSymbolOriginal != null && csvSymbolOriginal.trim().isNotEmpty
      ? _canonicalSymbolStem(csvSymbolOriginal)
      : _canonicalSymbolStem(normalizedRoot);
  final nr = normalizedRoot.trim().toUpperCase();

  if (_looksCryptoStem(rawStem)) {
    return AjouterTradeAssetClass.crypto;
  }
  if (_looksCommodityCf(rawStem)) {
    return AjouterTradeAssetClass.matieresPremieres;
  }

  if (rawStem.contains('!')) {
    return AjouterTradeAssetClass.future;
  }
  if (_looksLikeCmeStyleContract(rawStem)) {
    return AjouterTradeAssetClass.future;
  }

  // Paires devise (avant la racine future abrégée type EU / GB)
  if (_looksLikeForexStem(rawStem)) {
    return AjouterTradeAssetClass.forex;
  }

  if (_looksLikeIndexCfdStem(rawStem)) {
    return AjouterTradeAssetClass.indice;
  }

  if (_exchangeTradedFutureRootsUpper.contains(nr)) {
    return AjouterTradeAssetClass.future;
  }

  return AjouterTradeAssetClass.forex;
}
