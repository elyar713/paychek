import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart' show debugPrint;

import 'paychek_native_store_plan_pricing.dart';
import 'paychek_plan_price_quote.dart';
import 'paychek_regional_price_defaults.dart';
import 'paychek_stripe_paywall_pricing.dart';
import 'paychek_subscription_platform.dart';

/// Tarifs paywall : web = catalogue régional (standard) ; iOS/Android = store natif.
///
/// Web : Cloud Function puis catalogue local (249 pays).
/// Mobile : App Store / Play (`queryProductDetails`), repli catalogue si indisponible.
abstract final class PaychekStorePlanPricing {
  PaychekStorePlanPricing._();

  static Locale resolvePricingLocale({Locale? appLocale}) =>
      paychekResolvePricingLocale(appLocale: appLocale);

  static PaychekPlanPricingSnapshot? _cache;
  static String? _cacheKey;
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(minutes: 10);

  /// Web : pays → devise → montants catalogue. Mobile : prix store natifs en priorité.
  static Future<PaychekPlanPricingSnapshot> load({Locale? locale}) async {
    final loc = locale ?? PlatformDispatcher.instance.locale;
    final key = _cacheKeyFor(loc);
    final now = DateTime.now();
    if (_cache != null &&
        _cacheKey == key &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheTtl) {
      return _cache!;
    }

    PaychekPlanPricingSnapshot snapshot;
    try {
      if (paychekUsesNativeStoreIap) {
        final fromStore =
            await PaychekNativeStorePlanPricing.load(locale: loc);
        snapshot = fromStore ?? await loadRegionalByCountry(loc);
      } else {
        snapshot = await loadRegionalByCountry(loc);
      }
    } catch (e, st) {
      debugPrint('[Paychek] store plan pricing $e\n$st');
      snapshot = _offlineRegional(loc);
    }

    if (snapshot.byCycle.isEmpty) {
      snapshot = _offlineRegional(loc);
    }

    _cache = snapshot;
    _cacheKey = key;
    _cachedAt = now;
    return snapshot;
  }

  /// Alias explicite pour l’aperçu paywall (identique à [load]).
  static Future<PaychekPlanPricingSnapshot> loadRegionalPreview({
    Locale? locale,
  }) async {
    return load(locale: locale);
  }

  /// Résout pays → devise → montants via Cloud Function, puis catalogue local.
  static Future<PaychekPlanPricingSnapshot> loadRegionalByCountry(
    Locale locale,
  ) async {
    final country = PaychekRegionalPriceDefaults.countryFromLocale(locale);
    final currency = PaychekRegionalPriceDefaults.currencyForCountry(country);
    final formatLocale = PaychekRegionalPriceDefaults.formatLocaleForCountry(
      country,
      currency,
    );
    final fromServer = await PaychekStripePaywallPricing.fetch(
      countryCode: country,
      numberFormatLocale: formatLocale,
    );
    if (fromServer != null && fromServer.byCycle.isNotEmpty) {
      debugPrint(
        '[Paychek] paywall prices $country → $currency (${fromServer.source.name})',
      );
      return fromServer;
    }
    debugPrint('[Paychek] paywall prices offline $country → $currency');
    return _offlineRegional(locale);
  }

  static String _cacheKeyFor(Locale locale) {
    final platform = paychekUsesNativeAppleIap
        ? 'apple'
        : (paychekUsesNativeGooglePlayIap ? 'google' : 'web');
    final country = PaychekRegionalPriceDefaults.countryFromLocale(locale);
    return '$platform-$country-${locale.languageCode}';
  }

  static void invalidateCache() {
    _cache = null;
    _cacheKey = null;
    _cachedAt = null;
  }

  static PaychekPlanPricingSnapshot _offlineRegional(Locale locale) {
    return PaychekRegionalPriceDefaults.snapshotForLocale(locale);
  }
}
