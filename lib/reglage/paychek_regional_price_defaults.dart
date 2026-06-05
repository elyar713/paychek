import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:intl/intl.dart';

import 'paychek_billing_plan.dart';
import 'paychek_plan_price_quote.dart';

/// Pays / devise / montants TTC (alignés sur `functions/paywall_pricing.js`).
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

  /// Tarif web global : toujours USD 8,99 / 20,97 / 59,99 (tous pays).
  static PaychekPlanPricingSnapshot usStandardSnapshot() {
    const amounts = _Amounts(8.99, 20.95, 59.99);
    const currency = 'USD';
    const formatLocale = 'en_US';
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
      source: PaychekPlanPricingSource.catalogFallback,
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
    if (country.length == 2) {
      final lang = switch (currency) {
        'EUR' => 'en',
        'GBP' => 'en',
        'USD' => 'en',
        'JPY' => 'ja',
        'KRW' => 'ko',
        'CNY' => 'zh',
        'BRL' => 'pt',
        'MXN' => 'es',
        'PLN' => 'pl',
        'SEK' => 'sv',
        'NOK' => 'nb',
        'DKK' => 'da',
        _ => 'en',
      };
      return '${lang}_$country';
    }
    if (currency == 'EUR') return 'en_IE';
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

// 249 pays ISO 3166-1 → devise ISO 4217
const Map<String, String> _countryToCurrency = {
  'AD': 'EUR',
  'AE': 'AED',
  'AF': 'AFN',
  'AG': 'XCD',
  'AI': 'XCD',
  'AL': 'ALL',
  'AM': 'AMD',
  'AO': 'AOA',
  'AR': 'ARS',
  'AS': 'USD',
  'AT': 'EUR',
  'AU': 'AUD',
  'AW': 'AWG',
  'AX': 'EUR',
  'AZ': 'AZN',
  'BA': 'BAM',
  'BB': 'BBD',
  'BD': 'BDT',
  'BE': 'EUR',
  'BF': 'XOF',
  'BG': 'BGN',
  'BH': 'BHD',
  'BI': 'BIF',
  'BJ': 'XOF',
  'BL': 'EUR',
  'BM': 'BMD',
  'BN': 'BND',
  'BO': 'BOB',
  'BQ': 'USD',
  'BR': 'BRL',
  'BS': 'BSD',
  'BT': 'BTN',
  'BV': 'NOK',
  'BW': 'BWP',
  'BY': 'BYN',
  'BZ': 'BZD',
  'CA': 'CAD',
  'CC': 'AUD',
  'CD': 'CDF',
  'CF': 'XAF',
  'CG': 'XAF',
  'CH': 'CHF',
  'CI': 'XOF',
  'CK': 'NZD',
  'CL': 'CLP',
  'CM': 'XAF',
  'CN': 'CNY',
  'CO': 'COP',
  'CR': 'CRC',
  'CU': 'CUP',
  'CV': 'CVE',
  'CW': 'ANG',
  'CX': 'AUD',
  'CY': 'EUR',
  'CZ': 'CZK',
  'DE': 'EUR',
  'DJ': 'DJF',
  'DK': 'DKK',
  'DM': 'XCD',
  'DO': 'DOP',
  'DZ': 'DZD',
  'EC': 'USD',
  'EE': 'EUR',
  'EG': 'EGP',
  'EH': 'MAD',
  'ER': 'ERN',
  'ES': 'EUR',
  'ET': 'ETB',
  'FI': 'EUR',
  'FJ': 'FJD',
  'FK': 'FKP',
  'FM': 'USD',
  'FO': 'DKK',
  'FR': 'EUR',
  'GA': 'XAF',
  'GB': 'GBP',
  'GD': 'XCD',
  'GE': 'GEL',
  'GF': 'EUR',
  'GG': 'GBP',
  'GH': 'GHS',
  'GI': 'GIP',
  'GL': 'DKK',
  'GM': 'GMD',
  'GN': 'GNF',
  'GP': 'EUR',
  'GQ': 'XAF',
  'GR': 'EUR',
  'GS': 'GBP',
  'GT': 'GTQ',
  'GU': 'USD',
  'GW': 'XOF',
  'GY': 'GYD',
  'HK': 'HKD',
  'HM': 'AUD',
  'HN': 'HNL',
  'HR': 'EUR',
  'HT': 'HTG',
  'HU': 'HUF',
  'ID': 'IDR',
  'IE': 'EUR',
  'IL': 'ILS',
  'IM': 'GBP',
  'IN': 'INR',
  'IO': 'USD',
  'IQ': 'IQD',
  'IR': 'IRR',
  'IS': 'ISK',
  'IT': 'EUR',
  'JE': 'GBP',
  'JM': 'JMD',
  'JO': 'JOD',
  'JP': 'JPY',
  'KE': 'KES',
  'KG': 'KGS',
  'KH': 'KHR',
  'KI': 'AUD',
  'KM': 'KMF',
  'KN': 'XCD',
  'KP': 'KPW',
  'KR': 'KRW',
  'KW': 'KWD',
  'KY': 'KYD',
  'KZ': 'KZT',
  'LA': 'LAK',
  'LB': 'LBP',
  'LC': 'XCD',
  'LI': 'CHF',
  'LK': 'LKR',
  'LR': 'LRD',
  'LS': 'LSL',
  'LT': 'EUR',
  'LU': 'EUR',
  'LV': 'EUR',
  'LY': 'LYD',
  'MA': 'MAD',
  'MC': 'EUR',
  'MD': 'MDL',
  'ME': 'EUR',
  'MF': 'EUR',
  'MG': 'MGA',
  'MH': 'USD',
  'MK': 'MKD',
  'ML': 'XOF',
  'MM': 'MMK',
  'MN': 'MNT',
  'MO': 'MOP',
  'MP': 'USD',
  'MQ': 'EUR',
  'MR': 'MRU',
  'MS': 'XCD',
  'MT': 'EUR',
  'MU': 'MUR',
  'MV': 'MVR',
  'MW': 'MWK',
  'MX': 'MXN',
  'MY': 'MYR',
  'MZ': 'MZN',
  'NA': 'NAD',
  'NC': 'XPF',
  'NE': 'XOF',
  'NF': 'AUD',
  'NG': 'NGN',
  'NI': 'NIO',
  'NL': 'EUR',
  'NO': 'NOK',
  'NP': 'NPR',
  'NR': 'AUD',
  'NU': 'NZD',
  'NZ': 'NZD',
  'OM': 'OMR',
  'PA': 'PAB',
  'PE': 'PEN',
  'PF': 'XPF',
  'PG': 'PGK',
  'PH': 'PHP',
  'PK': 'PKR',
  'PL': 'PLN',
  'PM': 'EUR',
  'PN': 'NZD',
  'PR': 'USD',
  'PS': 'ILS',
  'PT': 'EUR',
  'PW': 'USD',
  'PY': 'PYG',
  'QA': 'QAR',
  'RE': 'EUR',
  'RO': 'RON',
  'RS': 'RSD',
  'RU': 'RUB',
  'RW': 'RWF',
  'SA': 'SAR',
  'SB': 'SBD',
  'SC': 'SCR',
  'SD': 'SDG',
  'SE': 'SEK',
  'SG': 'SGD',
  'SH': 'SHP',
  'SI': 'EUR',
  'SJ': 'NOK',
  'SK': 'EUR',
  'SL': 'SLE',
  'SM': 'EUR',
  'SN': 'XOF',
  'SO': 'SOS',
  'SR': 'SRD',
  'SS': 'SSP',
  'ST': 'STN',
  'SV': 'USD',
  'SX': 'ANG',
  'SY': 'SYP',
  'SZ': 'SZL',
  'TC': 'USD',
  'TD': 'XAF',
  'TF': 'EUR',
  'TG': 'XOF',
  'TH': 'THB',
  'TJ': 'TJS',
  'TK': 'NZD',
  'TL': 'USD',
  'TM': 'TMT',
  'TN': 'TND',
  'TO': 'TOP',
  'TR': 'TRY',
  'TT': 'TTD',
  'TV': 'AUD',
  'TW': 'TWD',
  'TZ': 'TZS',
  'UA': 'UAH',
  'UG': 'UGX',
  'UM': 'USD',
  'US': 'USD',
  'UY': 'UYU',
  'UZ': 'UZS',
  'VA': 'EUR',
  'VC': 'XCD',
  'VE': 'VES',
  'VG': 'USD',
  'VI': 'USD',
  'VN': 'VND',
  'VU': 'VUV',
  'WF': 'XPF',
  'WS': 'WST',
  'XK': 'EUR',
  'YE': 'YER',
  'YT': 'EUR',
  'ZA': 'ZAR',
  'ZM': 'ZMW',
  'ZW': 'USD',
};

// 39 devises avec montants TTC indicatifs
const Map<String, _Amounts> _pricesByCurrency = {
  'AED': _Amounts(32.99, 76.99, 219.99),
  'ARS': _Amounts(8999, 20999, 59999),
  'AUD': _Amounts(14.99, 34.99, 99.99),
  'BRL': _Amounts(49.9, 119.9, 349.9),
  'CAD': _Amounts(11.99, 27.99, 79.99),
  'CHF': _Amounts(8, 20, 50),
  'CLP': _Amounts(8990, 20990, 59990),
  'CNY': _Amounts(58, 138, 398),
  'COP': _Amounts(39900, 92900, 269900),
  'CZK': _Amounts(229, 529, 1490),
  'DKK': _Amounts(69, 159, 449),
  'EGP': _Amounts(449.99, 999.99, 2999.99),
  'EUR': _Amounts(9.99, 22.95, 69.99),
  'GBP': _Amounts(8.99, 19.95, 59.99),
  'HKD': _Amounts(68, 158, 468),
  'HUF': _Amounts(3990, 9290, 25990),
  'IDR': _Amounts(149000, 349000, 990000),
  'ILS': _Amounts(34.9, 79.9, 229.9),
  'INR': _Amounts(899, 2099, 5900),
  'JPY': _Amounts(1300, 3000, 9000),
  'KRW': _Amounts(11000, 25000, 75000),
  'MXN': _Amounts(179, 419, 1199),
  'MYR': _Amounts(39.9, 94.9, 279.9),
  'NGN': _Amounts(12900, 29900, 84900),
  'NOK': _Amounts(99, 229, 649),
  'NZD': _Amounts(14.99, 34.99, 99.99),
  'PHP': _Amounts(499, 1190, 3490),
  'PLN': _Amounts(39.99, 94.99, 269.99),
  'RON': _Amounts(49.99, 114.99, 329.99),
  'RUB': _Amounts(799, 1890, 5290),
  'SAR': _Amounts(34.99, 79.99, 229.99),
  'SEK': _Amounts(99, 229, 649),
  'SGD': _Amounts(12.98, 29.98, 89.98),
  'THB': _Amounts(349, 799, 2290),
  'TRY': _Amounts(349.99, 799.99, 2299.99),
  'TWD': _Amounts(290, 670, 1990),
  'UAH': _Amounts(399, 929, 2699),
  'USD': _Amounts(8.99, 20.95, 59.99),
  'ZAR': _Amounts(169.99, 399.99, 1099.99),
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
