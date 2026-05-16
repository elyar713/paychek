import 'dart:ui' show Locale;

import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_custom_actifs_storage.dart';

/// Symboles / paires proposés selon le type de marché (menu Actif).
List<String> ajouterTradeActifsPour(
  AjouterTradeAssetClass marche, {
  Locale? locale,
}) {
  final fr = (locale?.languageCode ?? 'en') == 'fr';
  final custom = AjouterTradeCustomActifsStorage.notifier.value[marche] ??
      const <String>[];
  final base = switch (marche) {
    AjouterTradeAssetClass.forex => [
        'EUR/USD',
        'GBP/USD',
        'USD/JPY',
        'USD/CHF',
        'AUD/USD',
        'USD/CAD',
        'NZD/USD',
        'XAU/USD',
        'EUR/GBP',
        'EUR/JPY',
        'EUR/CHF',
        'EUR/AUD',
        'EUR/CAD',
        'EUR/NZD',
        'GBP/JPY',
        'GBP/CHF',
        'GBP/AUD',
        'GBP/CAD',
        'AUD/JPY',
        'AUD/CAD',
        'NZD/JPY',
        'CAD/JPY',
        'CHF/JPY',
        'USD/TRY',
        'USD/ZAR',
        'USD/MXN',
        'USD/SGD',
        'XAG/USD',
      ],
    AjouterTradeAssetClass.indice => [
        'NAS100',
        'US30',
        'US500',
        'US2000',
        'GER40',
        'UK100',
        'FRA40',
        'EU50',
        'JPN225',
        'AUS200',
        'HK50',
        'ESP35',
        'SWI20',
        'CHINA50',
        'VIX',
      ],
    AjouterTradeAssetClass.future => [
        'ES',
        'NQ',
        'YM',
        'RTY',
        'MES',
        'MNQ',
        'MYM',
        'M2K',
        'CL',
        'GC',
        'SI',
        'ZB',
        'MCL',
        'MGC',
        'SIL',
        'ZN',
        'NG',
        'HG',
      ],
    AjouterTradeAssetClass.crypto => [
        'BTC/USD',
        'ETH/USD',
        'SOL/USD',
        'XRP/USD',
        'BNB/USD',
        'ADA/USD',
        'DOGE/USD',
        'AVAX/USD',
        'DOT/USD',
        'LINK/USD',
        'LTC/USD',
        'TRX/USD',
        'ATOM/USD',
        'XLM/USD',
        'NEAR/USD',
      ],
    AjouterTradeAssetClass.stock => [
        'NVDA',
        'MSFT',
        'AAPL',
        'GOOGL',
        'AMZN',
        'META',
        'AVGO',
        'TSLA',
        'BRK.B',
        'LLY',
        'WMT',
        'JPM',
        'V',
        'UNH',
        'ORCL',
        'MA',
        'XOM',
        'JNJ',
        'COST',
        'HD',
      ],
    AjouterTradeAssetClass.matieresPremieres => fr
          ? [
              'Or (XAU)',
              'Argent (XAG)',
              'Pétrole WTI',
              'Pétrole Brent',
              'Cuivre',
              'Blé',
            ]
          : [
              'Gold (XAU)',
              'Silver (XAG)',
              'WTI crude',
              'Brent crude',
              'Copper',
              'Wheat',
            ],
  };

  if (custom.isEmpty) return base;
  final out = <String>[...custom, ...base];
  // De-dup (case-insensitive) while preserving order.
  final seen = <String>{};
  final uniq = <String>[];
  for (final s in out) {
    final k = s.trim().toUpperCase();
    if (k.isEmpty || seen.contains(k)) continue;
    seen.add(k);
    uniq.add(s.trim());
  }
  return uniq;
}
