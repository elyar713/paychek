import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

import 'paychek_apple_iap_product_ids.dart';
import 'paychek_apple_iap_service.dart';
import 'paychek_billing_plan.dart';
import 'paychek_google_play_iap_service.dart';
import 'paychek_google_play_product_ids.dart';
import 'paychek_plan_price_quote.dart';
import 'paychek_regional_price_defaults.dart';
import 'paychek_subscription_platform.dart';

/// Tarifs paywall iOS / Android lus depuis App Store Connect / Play Console.
abstract final class PaychekNativeStorePlanPricing {
  PaychekNativeStorePlanPricing._();

  static final InAppPurchase _iap = InAppPurchase.instance;

  static Future<PaychekPlanPricingSnapshot?> load({Locale? locale}) async {
    if (paychekUsesNativeAppleIap) {
      return _load(
        productIds: {
          PaychekBillingCycle.monthly: PaychekAppleIapProductIds.monthly,
          PaychekBillingCycle.quarterly: PaychekAppleIapProductIds.quarterly,
          PaychekBillingCycle.annual: PaychekAppleIapProductIds.annual,
        },
        resolveCycle: PaychekAppleIapProductIds.cycleForProductId,
        source: PaychekPlanPricingSource.appStore,
        init: PaychekAppleIapService.ensureInitialized,
        locale: locale,
      );
    }
    if (paychekUsesNativeGooglePlayIap) {
      return _load(
        productIds: {
          PaychekBillingCycle.monthly: PaychekGooglePlayProductIds.monthly,
          PaychekBillingCycle.quarterly: PaychekGooglePlayProductIds.quarterly,
          PaychekBillingCycle.annual: PaychekGooglePlayProductIds.annual,
        },
        resolveCycle: PaychekGooglePlayProductIds.cycleForProductId,
        source: PaychekPlanPricingSource.googlePlay,
        init: PaychekGooglePlayIapService.ensureInitialized,
        locale: locale,
      );
    }
    return null;
  }

  static Future<PaychekPlanPricingSnapshot?> _load({
    required Map<PaychekBillingCycle, String> productIds,
    required PaychekBillingCycle? Function(String productId) resolveCycle,
    required PaychekPlanPricingSource source,
    required Future<void> Function() init,
    Locale? locale,
  }) async {
    await init();
    final available = await _iap.isAvailable();
    if (!available) return null;

    final ids = productIds.values.toSet();
    final response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      debugPrint('[Paychek] native store pricing ${response.error}');
      return null;
    }

    final loc = locale ?? paychekResolvePricingLocale();
    final country = PaychekRegionalPriceDefaults.countryFromLocale(loc);
    final formatLocale = PaychekRegionalPriceDefaults.formatLocaleForCountry(
      country,
      PaychekRegionalPriceDefaults.currencyForCountry(country),
    );

    final byCycle = <PaychekBillingCycle, PaychekPlanPriceQuote>{};
    for (final product in response.productDetails) {
      final cycle = resolveCycle(product.id);
      if (cycle == null) continue;
      byCycle[cycle] = _quoteFromProduct(
        product,
        cycle: cycle,
        formatLocale: formatLocale,
      );
    }

    final notFound = productIds.entries
        .where((e) => !byCycle.containsKey(e.key))
        .map((e) => e.value)
        .toList(growable: false);

    if (byCycle.length < PaychekBillingCycle.values.length) {
      debugPrint(
        '[Paychek] native store pricing incomplete '
        '(found ${byCycle.length}/3, missing $notFound)',
      );
      return null;
    }

    debugPrint('[Paychek] native store pricing ok (${source.name})');
    return PaychekPlanPricingSnapshot(
      byCycle: byCycle,
      source: source,
      notFoundProductIds: notFound,
    );
  }

  static PaychekPlanPriceQuote _quoteFromProduct(
    ProductDetails product, {
    required PaychekBillingCycle cycle,
    required String formatLocale,
  }) {
    final months = switch (cycle) {
      PaychekBillingCycle.monthly => 1,
      PaychekBillingCycle.quarterly => 3,
      PaychekBillingCycle.annual => 12,
    };
    final formatter = NumberFormat.simpleCurrency(
      name: product.currencyCode,
      locale: formatLocale,
    );
    return PaychekPlanPriceQuote(
      cycle: cycle,
      totalDisplay: product.price,
      perMonthDisplay: formatter.format(product.rawPrice / months),
      rawTotal: product.rawPrice,
      currencyCode: product.currencyCode,
    );
  }
}
