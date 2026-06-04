import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';

import 'paychek_apple_iap_product_ids.dart';
import 'paychek_billing_plan.dart';
import 'paychek_google_play_iap_service.dart';
import 'paychek_google_play_product_ids.dart';
import 'paychek_plan_price_quote.dart';
import 'paychek_stripe_paywall_pricing.dart';
import 'paychek_subscription_platform.dart';

/// Charge les tarifs paywall depuis App Store / Play (tous pays, TTC)
/// ou Cloud Function web (pays → devise, Stripe / Firestore).
abstract final class PaychekStorePlanPricing {
  PaychekStorePlanPricing._();

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
        snapshot = await _loadFromInAppPurchase(
          productIdForCycle: PaychekAppleIapProductIds.forCycle,
          allProductIds: PaychekAppleIapProductIds.all,
          source: PaychekPlanPricingSource.appStore,
          locale: loc,
        );
      } else if (paychekUsesNativeGooglePlayIap) {
        snapshot = await _loadFromGooglePlay(locale: loc);
      } else {
        snapshot = await _loadWebByCountry(loc);
      }
    } catch (e, st) {
      debugPrint('[Paychek] store plan pricing $e\n$st');
      snapshot = _catalogFallback(loc);
    }

    if (snapshot.byCycle.isEmpty) {
      snapshot = _catalogFallback(loc);
    }

    _cache = snapshot;
    _cacheKey = key;
    _cachedAt = now;
    return snapshot;
  }

  static String _cacheKeyFor(Locale locale) {
    final platform = paychekUsesNativeAppleIap
        ? 'apple'
        : (paychekUsesNativeGooglePlayIap ? 'google' : 'web');
    final country = locale.countryCode ?? 'US';
    return '$platform-$country-${locale.languageCode}';
  }

  static void invalidateCache() {
    _cache = null;
    _cacheKey = null;
    _cachedAt = null;
  }

  static Future<PaychekPlanPricingSnapshot> _loadWebByCountry(
    Locale locale,
  ) async {
    final country = locale.countryCode ?? 'US';
    final fromServer = await PaychekStripePaywallPricing.fetch(
      countryCode: country,
      numberFormatLocale: _numberFormatLocale(locale, 'EUR'),
    );
    if (fromServer != null && fromServer.byCycle.isNotEmpty) {
      return fromServer;
    }
    return _catalogFallback(locale);
  }

  static Future<PaychekPlanPricingSnapshot> _loadFromGooglePlay({
    required Locale locale,
  }) async {
    await PaychekGooglePlayIapService.ensureInitialized();
    return _loadFromInAppPurchase(
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
      return _catalogFallback(locale);
    }

    final response = await iap.queryProductDetails(allProductIds);
    if (response.error != null) {
      debugPrint('[Paychek] plan pricing query ${response.error}');
    }
    if (response.productDetails.isEmpty) {
      return _catalogFallback(locale);
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
      source: byCycle.isEmpty ? PaychekPlanPricingSource.catalogFallback : source,
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
    final formatter = NumberFormat.simpleCurrency(
      name: currency,
      locale: _numberFormatLocale(locale, currency),
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

  static String _numberFormatLocale(Locale locale, String currencyCode) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return locale.toString();
    }
    final cc = currencyCode.toUpperCase();
    if (cc == 'EUR') return 'fr_FR';
    if (cc == 'USD') return 'en_US';
    if (cc == 'GBP') return 'en_GB';
    return 'en_US';
  }

  static PaychekPlanPricingSnapshot _catalogFallback(Locale locale) {
    final currency = 'USD';
    final formatter = NumberFormat.simpleCurrency(
      name: currency,
      locale: _numberFormatLocale(locale, currency),
    );
    PaychekPlanPriceQuote quote(PaychekBillingCycle cycle) {
      final totalStr = PaychekBillingPlanCatalog.totalPrice(cycle)
          .replaceAll(',', '.');
      final total = double.tryParse(totalStr) ?? 0;
      final months = switch (cycle) {
        PaychekBillingCycle.monthly => 1,
        PaychekBillingCycle.quarterly => 3,
        PaychekBillingCycle.annual => 12,
      };
      final perMonthStr = PaychekBillingPlanCatalog.pricePerMonth(cycle)
          .replaceAll(',', '.');
      final perMonth = double.tryParse(perMonthStr) ?? total / months;
      return PaychekPlanPriceQuote(
        cycle: cycle,
        totalDisplay: formatter.format(total),
        perMonthDisplay: formatter.format(perMonth),
        rawTotal: total,
        currencyCode: currency,
      );
    }
    return PaychekPlanPricingSnapshot(
      source: PaychekPlanPricingSource.catalogFallback,
      byCycle: {
        for (final c in PaychekBillingCycle.values) c: quote(c),
      },
    );
  }
}
