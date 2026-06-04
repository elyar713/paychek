import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';

import 'paychek_apple_iap_service.dart';
import 'paychek_apple_iap_product_ids.dart';
import 'paychek_billing_plan.dart';
import 'paychek_google_play_iap_service.dart';
import 'paychek_google_play_product_ids.dart';
import 'paychek_plan_price_quote.dart';
import 'paychek_regional_price_defaults.dart';
import 'paychek_stripe_paywall_pricing.dart';
import 'paychek_subscription_platform.dart';

/// Charge les tarifs paywall depuis App Store / Play (tous pays, TTC)
/// ou Cloud Function (pays → devise, Stripe / Firestore).
abstract final class PaychekStorePlanPricing {
  PaychekStorePlanPricing._();

  static Locale resolvePricingLocale({Locale? appLocale}) =>
      paychekResolvePricingLocale(appLocale: appLocale);

  static PaychekPlanPricingSnapshot? _cache;
  static String? _cacheKey;
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(minutes: 10);

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
      if (paychekUsesNativeAppleIap) {
        snapshot = await _loadApplePricing(loc);
      } else if (paychekUsesNativeGooglePlayIap) {
        snapshot = await _loadGooglePlayPricing(loc);
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

  /// Aperçu immédiat par pays (serveur puis catalogue local hors-ligne).
  static Future<PaychekPlanPricingSnapshot> loadRegionalPreview({
    Locale? locale,
  }) async {
    final loc = locale ?? resolvePricingLocale();
    return loadRegionalByCountry(loc);
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
        '[Paychek] paywall prices server $country → $currency',
      );
      return fromServer;
    }
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

  static String _expectedCurrencyForLocale(Locale locale) {
    final country = PaychekRegionalPriceDefaults.countryFromLocale(locale);
    return PaychekRegionalPriceDefaults.currencyForCountry(country);
  }

  static String? _snapshotCurrency(PaychekPlanPricingSnapshot snapshot) {
    if (snapshot.byCycle.isEmpty) return null;
    return snapshot.byCycle.values.first.currencyCode.trim().toUpperCase();
  }

  /// StoreKit / Play Billing utilisent le compte store (souvent USD en sandbox).
  /// On n’affiche ces prix que s’ils correspondent au pays de l’appareil.
  static bool _storeMatchesCountryCurrency(
    PaychekPlanPricingSnapshot store,
    Locale locale,
  ) {
    final storeCurrency = _snapshotCurrency(store);
    if (storeCurrency == null) return false;
    return storeCurrency == _expectedCurrencyForLocale(locale).toUpperCase();
  }

  static PaychekPlanPricingSnapshot _resolveNativeStorePricing({
    required PaychekPlanPricingSnapshot store,
    required PaychekPlanPricingSnapshot regional,
    required Locale locale,
    required PaychekPlanPricingSource storeSource,
    required String storeLabel,
  }) {
    final expected = _expectedCurrencyForLocale(locale);
    final storeCurrency = _snapshotCurrency(store);

    if (store.byCycle.length == PaychekBillingCycle.values.length &&
        store.source == storeSource &&
        _storeMatchesCountryCurrency(store, locale)) {
      debugPrint('[Paychek] $storeLabel prices OK $storeCurrency');
      return store;
    }

    if (store.byCycle.isNotEmpty && _storeMatchesCountryCurrency(store, locale)) {
      return _mergePricing(store, regional);
    }

    if (store.byCycle.isNotEmpty && storeCurrency != null) {
      debugPrint(
        '[Paychek] $storeLabel currency $storeCurrency '
        '≠ country $expected — regional prices kept',
      );
    }

    return regional;
  }

  static Future<PaychekPlanPricingSnapshot> _loadApplePricing(
    Locale locale,
  ) async {
    await PaychekAppleIapService.ensureInitialized();

    final regionalFuture = loadRegionalByCountry(locale);

    PaychekPlanPricingSnapshot store = PaychekPlanPricingSnapshot(
      byCycle: const {},
      source: PaychekPlanPricingSource.catalogFallback,
    );

    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
      store = await _loadFromInAppPurchase(
        productIdForCycle: PaychekAppleIapProductIds.forCycle,
        allProductIds: PaychekAppleIapProductIds.all,
        source: PaychekPlanPricingSource.appStore,
        locale: locale,
      );
      if (store.byCycle.length == PaychekBillingCycle.values.length &&
          store.source == PaychekPlanPricingSource.appStore) {
        break;
      }
    }

    if (store.notFoundProductIds.isNotEmpty) {
      debugPrint(
        '[Paychek] App Store products not found: ${store.notFoundProductIds}',
      );
    }

    final regional = await regionalFuture;
    return _resolveNativeStorePricing(
      store: store,
      regional: regional,
      locale: locale,
      storeSource: PaychekPlanPricingSource.appStore,
      storeLabel: 'App Store',
    );
  }

  static Future<PaychekPlanPricingSnapshot> _loadGooglePlayPricing(
    Locale locale,
  ) async {
    await PaychekGooglePlayIapService.ensureInitialized();

    final regionalFuture = loadRegionalByCountry(locale);

    PaychekPlanPricingSnapshot store = PaychekPlanPricingSnapshot(
      byCycle: const {},
      source: PaychekPlanPricingSource.catalogFallback,
    );

    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
      store = await _loadFromInAppPurchase(
        productIdForCycle: PaychekGooglePlayProductIds.forCycle,
        allProductIds: PaychekGooglePlayProductIds.all,
        source: PaychekPlanPricingSource.googlePlay,
        locale: locale,
        pickProduct: (details, productId) {
          for (final d in details) {
            if (d.id != productId) continue;
            if (d is GooglePlayProductDetails &&
                (d.offerToken ?? '').isNotEmpty) {
              return d;
            }
          }
          for (final d in details) {
            if (d.id == productId) return d;
          }
          return null;
        },
      );
      if (store.byCycle.length == PaychekBillingCycle.values.length &&
          store.source == PaychekPlanPricingSource.googlePlay) {
        break;
      }
    }

    if (store.notFoundProductIds.isNotEmpty) {
      debugPrint(
        '[Paychek] Play products not found: ${store.notFoundProductIds}',
      );
    }

    final regional = await regionalFuture;
    return _resolveNativeStorePricing(
      store: store,
      regional: regional,
      locale: locale,
      storeSource: PaychekPlanPricingSource.googlePlay,
      storeLabel: 'Play',
    );
  }

  static PaychekPlanPricingSnapshot _mergePricing(
    PaychekPlanPricingSnapshot primary,
    PaychekPlanPricingSnapshot fallback,
  ) {
    final byCycle = Map<PaychekBillingCycle, PaychekPlanPriceQuote>.from(
      fallback.byCycle,
    );
    byCycle.addAll(primary.byCycle);
    return PaychekPlanPricingSnapshot(
      byCycle: byCycle,
      source: primary.byCycle.isNotEmpty
          ? primary.source
          : fallback.source,
    );
  }

  static Future<PaychekPlanPricingSnapshot> _loadFromInAppPurchase({
    required String Function(PaychekBillingCycle cycle) productIdForCycle,
    required Set<String> allProductIds,
    required PaychekPlanPricingSource source,
    required Locale locale,
    ProductDetails? Function(List<ProductDetails> details, String productId)?
        pickProduct,
  }) async {
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) {
      return PaychekPlanPricingSnapshot(
        byCycle: const {},
        source: PaychekPlanPricingSource.catalogFallback,
      );
    }

    final response = await iap.queryProductDetails(allProductIds);
    if (response.error != null) {
      debugPrint('[Paychek] plan pricing query ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[Paychek] plan pricing notFoundIDs: ${response.notFoundIDs}');
    }
    if (response.productDetails.isEmpty) {
      return PaychekPlanPricingSnapshot(
        byCycle: const {},
        source: PaychekPlanPricingSource.catalogFallback,
        notFoundProductIds: response.notFoundIDs.toList(),
      );
    }

    final byCycle = <PaychekBillingCycle, PaychekPlanPriceQuote>{};
    for (final cycle in PaychekBillingCycle.values) {
      final productId = productIdForCycle(cycle);
      ProductDetails? product;
      if (pickProduct != null) {
        product = pickProduct(response.productDetails, productId);
      } else {
        for (final d in response.productDetails) {
          if (d.id == productId) {
            product = d;
            break;
          }
        }
      }
      if (product == null) continue;
      final quote = _quoteFromProductDetails(
        cycle: cycle,
        product: product,
        locale: locale,
      );
      if (quote != null) byCycle[cycle] = quote;
    }

    return PaychekPlanPricingSnapshot(
      byCycle: byCycle,
      source: byCycle.isEmpty
          ? PaychekPlanPricingSource.catalogFallback
          : source,
      notFoundProductIds: response.notFoundIDs.toList(),
    );
  }

  static PaychekPlanPriceQuote? _quoteFromProductDetails({
    required PaychekBillingCycle cycle,
    required ProductDetails product,
    required Locale locale,
  }) {
    final raw = product.rawPrice;
    if (raw.isNaN || raw <= 0) return null;
    final months = switch (cycle) {
      PaychekBillingCycle.monthly => 1,
      PaychekBillingCycle.quarterly => 3,
      PaychekBillingCycle.annual => 12,
    };
    final perMonthRaw = raw / months;
    final currency = product.currencyCode.trim().isNotEmpty
        ? product.currencyCode.trim()
        : 'USD';
    final country = PaychekRegionalPriceDefaults.countryFromLocale(locale);
    final formatter = NumberFormat.simpleCurrency(
      name: currency,
      locale: PaychekRegionalPriceDefaults.formatLocaleForCountry(
        country,
        currency,
      ),
    );
    return PaychekPlanPriceQuote(
      cycle: cycle,
      totalDisplay: product.price.trim().isNotEmpty
          ? product.price.trim()
          : formatter.format(raw),
      perMonthDisplay: formatter.format(perMonthRaw),
      rawTotal: raw,
      currencyCode: currency,
    );
  }
}
