import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:intl/intl.dart';

import 'paychek_billing_plan.dart';
import 'paychek_plan_price_quote.dart';

/// Pays / devise / montants TTC (alignés sur `functions/paywall_pricing.js`).
abstract final class PaychekRegionalPriceDefaults {
  PaychekRegionalPriceDefaults._();

  static const Set<String> _euCountries = {
    'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR',
    'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK',
    'SI', 'ES', 'SE',
  };

  static String countryFromLocale(Locale locale) {
    final cc = locale.countryCode?.trim().toUpperCase();
    if (cc != null && cc.length == 2) return cc;
    return _countryFromLanguage(locale.languageCode);
  }

  static String currencyForCountry(String countryCode) {
    final cc = countryCode.trim().toUpperCase();
    return _countryToCurrency[cc] ??
        (_euCountries.contains(cc) ? 'EUR' : 'USD');
  }

  static PaychekPlanPricingSnapshot snapshotForCountry(String countryCode) {
    final country = countryCode.trim().toUpperCase();
    final currency = currencyForCountry(country);
    final amounts = _pricesByCurrency[currency] ?? _pricesByCurrency['USD']!;
    final formatLocale = _formatLocaleFor(country, currency);
    final formatter = NumberFormat.simpleCurrency(
      name: currency,
      locale: formatLocale,
    );

    PaychekPlanPriceQuote quote(PaychekBillingCycle cycle, double total) {
      final months = switch (cycle) {
        PaychekBillingCycle.monthly => 1,
        PaychekBillingCycle.quarterly => 3,
        PaychekBillingCycle.annual => 12,
      };
      return PaychekPlanPriceQuote(
        cycle: cycle,
        totalDisplay: formatter.format(total),
        perMonthDisplay: formatter.format(total / months),
        rawTotal: total,
        currencyCode: currency,
      );
    }

    return PaychekPlanPricingSnapshot(
      source: PaychekPlanPricingSource.regionalWeb,
      byCycle: {
        PaychekBillingCycle.monthly:
            quote(PaychekBillingCycle.monthly, amounts.monthly),
        PaychekBillingCycle.quarterly:
            quote(PaychekBillingCycle.quarterly, amounts.quarterly),
        PaychekBillingCycle.annual:
            quote(PaychekBillingCycle.annual, amounts.annual),
      },
    );
  }

  static PaychekPlanPricingSnapshot snapshotForLocale(Locale locale) {
    return snapshotForCountry(countryFromLocale(locale));
  }

  static String _countryFromLanguage(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'fr':
        return 'FR';
      case 'de':
        return 'DE';
      case 'es':
        return 'ES';
      case 'pt':
        return 'PT';
      case 'ko':
        return 'KR';
      default:
        return 'US';
    }
  }

  static String _formatLocaleFor(String country, String currency) {
    if (country == 'FR' || (currency == 'EUR' && country.isNotEmpty)) {
      return 'fr_FR';
    }
    if (country == 'DE') return 'de_DE';
    if (country == 'NO') return 'nb_NO';
    if (country == 'GB') return 'en_GB';
    if (currency == 'USD') return 'en_US';
    return 'en_US';
  }
}

class _Amounts {
  const _Amounts(this.monthly, this.quarterly, this.annual);
  final double monthly;
  final double quarterly;
  final double annual;
}

const Map<String, _Amounts> _pricesByCurrency = {
  'USD': _Amounts(8.99, 20.97, 59.99),
  'EUR': _Amounts(9.99, 23.49, 59.99),
  'GBP': _Amounts(8.99, 20.97, 59.99),
  'NOK': _Amounts(99, 229, 649),
  'CAD': _Amounts(11.99, 27.99, 79.99),
  'AUD': _Amounts(14.99, 34.99, 99.99),
  'CHF': _Amounts(10.00, 24.00, 60.00),
  'JPY': _Amounts(1300, 3000, 9000),
  'BRL': _Amounts(49.90, 119.90, 349.90),
  'MXN': _Amounts(179, 419, 1199),
  'INR': _Amounts(899, 2099, 5900),
  'PLN': _Amounts(39.99, 94.99, 269.99),
  'SEK': _Amounts(99, 229, 649),
  'DKK': _Amounts(69, 159, 449),
  'KRW': _Amounts(11000, 25000, 75000),
  'SGD': _Amounts(12.98, 29.98, 89.98),
};

const Map<String, String> _countryToCurrency = {
  'FR': 'EUR', 'DE': 'EUR', 'ES': 'EUR', 'IT': 'EUR', 'NL': 'EUR',
  'BE': 'EUR', 'AT': 'EUR', 'PT': 'EUR', 'IE': 'EUR', 'FI': 'EUR',
  'NO': 'NOK', 'SE': 'SEK', 'DK': 'DKK', 'GB': 'GBP', 'US': 'USD',
  'CA': 'CAD', 'AU': 'AUD', 'CH': 'CHF', 'JP': 'JPY', 'BR': 'BRL',
  'MX': 'MXN', 'IN': 'INR', 'PL': 'PLN', 'KR': 'KRW', 'SG': 'SGD',
};

/// Locale utilisée pour résoudre le pays du paywall (app + système iOS/Android).
Locale paychekResolvePricingLocale({Locale? appLocale}) {
  final device = PlatformDispatcher.instance.locale;
  if (device.countryCode != null && device.countryCode!.trim().isNotEmpty) {
    final lang = (appLocale ?? device).languageCode;
    return Locale(lang, device.countryCode);
  }
  final app = appLocale ?? device;
  if (app.countryCode != null && app.countryCode!.trim().isNotEmpty) {
    return app;
  }
  final country = PaychekRegionalPriceDefaults.countryFromLocale(app);
  return Locale(app.languageCode, country);
}
