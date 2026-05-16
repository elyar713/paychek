import 'package:flutter/foundation.dart';

/// Devise pour le capital initial (symbole affiché à gauche du montant).
@immutable
class TradingCurrency {
  const TradingCurrency({
    required this.code,
    required this.shortLabel,
    required this.symbol,
  });

  final String code;
  final String shortLabel;
  final String symbol;
}

/// Devise par défaut (première de la liste : USD).
const String kDefaultCurrencyCode = 'USD';

/// Devise saisie manuellement (nom + symbole).
const String kCustomCurrencyCode = 'CUSTOM';

/// Ordre : USD, EUR, GBP, CAD, AUD, NZD, JPY, BTC.
const List<TradingCurrency> kTradingCurrencies = [
  TradingCurrency(code: 'USD', shortLabel: 'USD', symbol: r'$'),
  TradingCurrency(code: 'EUR', shortLabel: 'EUR', symbol: '€'),
  TradingCurrency(code: 'GBP', shortLabel: 'GBP', symbol: '£'),
  TradingCurrency(code: 'CAD', shortLabel: 'CAD', symbol: r'C$'),
  TradingCurrency(code: 'AUD', shortLabel: 'AUD', symbol: r'A$'),
  TradingCurrency(code: 'NZD', shortLabel: 'NZD', symbol: r'NZ$'),
  TradingCurrency(code: 'JPY', shortLabel: 'JPY', symbol: '¥'),
  TradingCurrency(code: 'BTC', shortLabel: 'BTC', symbol: '₿'),
];

TradingCurrency? tradingCurrencyByCode(String? code) {
  if (code == null) return null;
  for (final c in kTradingCurrencies) {
    if (c.code == code) return c;
  }
  return null;
}
