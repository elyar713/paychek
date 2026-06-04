const fs = require('fs');
const path = require('path');
const {
  COUNTRY_TO_CURRENCY,
  DEFAULT_PRICES_BY_CURRENCY,
} = require('../functions/paywall_pricing');

const countries = Object.entries(COUNTRY_TO_CURRENCY).sort((a, b) =>
  a[0].localeCompare(b[0]),
);
const currencies = Object.entries(DEFAULT_PRICES_BY_CURRENCY).sort((a, b) =>
  a[0].localeCompare(b[0]),
);

const countryMap = countries
  .map(([k, v]) => `  '${k}': '${v}',`)
  .join('\n');
const priceMap = currencies
  .map(
    ([k, v]) =>
      `  '${k}': _Amounts(${v.monthly}, ${v.quarterly}, ${v.annual}),`,
  )
  .join('\n');

const dart = `import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:intl/intl.dart';

import 'paychek_billing_plan.dart';
import 'paychek_plan_price_quote.dart';

/// Pays / devise / montants TTC (alignés sur \`functions/paywall_pricing.js\`).
abstract final class PaychekRegionalPriceDefaults {
  PaychekRegionalPriceDefaults._();

  static String countryFromLocale(Locale locale) {
    final cc = locale.countryCode?.trim().toUpperCase();
    if (cc != null && cc.length == 2) return cc;
    return _countryFromLanguage(locale.languageCode);
  }

  static String currencyForCountry(String countryCode) {
    final cc = countryCode.trim().toUpperCase();
    return _countryToCurrency[cc] ?? 'USD';
  }

  static PaychekPlanPricingSnapshot snapshotForCountry(String countryCode) {
    final country = countryCode.trim().toUpperCase();
    final currency = currencyForCountry(country);
    final amounts = _pricesByCurrency[currency] ?? _pricesByCurrency['USD']!;
    final formatLocale = formatLocaleForCountry(country, currency);
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

  static String formatLocaleForCountry(String countryCode, String currency) {
    final country = countryCode.trim().toUpperCase();
    const byCountry = {
      'FR': 'fr_FR',
      'DE': 'de_DE',
      'ES': 'es_ES',
      'IT': 'it_IT',
      'PT': 'pt_PT',
      'NL': 'nl_NL',
      'BE': 'fr_BE',
      'GB': 'en_GB',
      'US': 'en_US',
      'CA': 'en_CA',
      'AU': 'en_AU',
      'NZ': 'en_NZ',
      'NO': 'nb_NO',
      'SE': 'sv_SE',
      'DK': 'da_DK',
      'FI': 'fi_FI',
      'JP': 'ja_JP',
      'KR': 'ko_KR',
      'BR': 'pt_BR',
      'MX': 'es_MX',
      'IN': 'en_IN',
      'PL': 'pl_PL',
      'CH': 'de_CH',
      'SG': 'en_SG',
      'HK': 'zh_HK',
      'TW': 'zh_TW',
      'AE': 'ar_AE',
      'SA': 'ar_SA',
      'TR': 'tr_TR',
      'RU': 'ru_RU',
      'UA': 'uk_UA',
      'TH': 'th_TH',
      'ID': 'id_ID',
      'MY': 'ms_MY',
      'PH': 'en_PH',
      'ZA': 'en_ZA',
      'NG': 'en_NG',
      'EG': 'ar_EG',
      'IL': 'he_IL',
      'CN': 'zh_CN',
      'AR': 'es_AR',
      'CL': 'es_CL',
      'CO': 'es_CO',
    };
    if (byCountry.containsKey(country)) return byCountry[country]!;
    if (currency == 'EUR') return 'fr_FR';
    if (currency == 'GBP') return 'en_GB';
    if (currency == 'USD') return 'en_US';
    return 'en_US';
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
      case 'it':
        return 'IT';
      case 'nl':
        return 'NL';
      case 'ja':
        return 'JP';
      case 'ko':
        return 'KR';
      case 'zh':
        return 'CN';
      case 'ar':
        return 'AE';
      case 'tr':
        return 'TR';
      case 'pl':
        return 'PL';
      case 'sv':
        return 'SE';
      case 'nb':
      case 'no':
        return 'NO';
      case 'da':
        return 'DK';
      case 'fi':
        return 'FI';
      default:
        return 'US';
    }
  }
}

class _Amounts {
  const _Amounts(this.monthly, this.quarterly, this.annual);
  final double monthly;
  final double quarterly;
  final double annual;
}

// ${countries.length} pays ISO 3166-1 → devise ISO 4217
const Map<String, String> _countryToCurrency = {
${countryMap}
};

// ${currencies.length} devises avec montants TTC indicatifs
const Map<String, _Amounts> _pricesByCurrency = {
${priceMap}
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
`;

const out = path.join(
  __dirname,
  '..',
  'lib',
  'reglage',
  'paychek_regional_price_defaults.dart',
);
fs.writeFileSync(out, dart, 'utf8');
console.log('Wrote', out);
