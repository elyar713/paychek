import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';

import 'paychek_billing_plan.dart';
import 'paychek_plan_price_quote.dart';
import 'stripe_entitlement_sync.dart';

/// Tarifs paywall web via Cloud Function (pays → devise → montants TTC).
abstract final class PaychekStripePaywallPricing {
  PaychekStripePaywallPricing._();

  static Future<PaychekPlanPricingSnapshot?> fetch({
    required String countryCode,
    required String numberFormatLocale,
  }) async {
    final country = countryCode.trim().toUpperCase();
    if (country.length != 2) return null;
    final fn =
        FirebaseFunctions.instanceFor(region: kPaychekFunctionsRegion);
    try {
      final result = await fn
          .httpsCallable('getPaychekPaywallPrices')
          .call<Object?>(<String, dynamic>{'countryCode': country});
      final data = result.data;
      if (data is! Map) return null;
      return _snapshotFromResponse(data, numberFormatLocale);
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[Paychek] getPaychekPaywallPrices ${e.code}: ${e.message}\n$st',
      );
      return null;
    } catch (e, st) {
      debugPrint('[Paychek] getPaychekPaywallPrices $e\n$st');
      return null;
    }
  }

  static PaychekPlanPricingSnapshot? _snapshotFromResponse(
    Map<dynamic, dynamic> data,
    String numberFormatLocale,
  ) {
    final currency = data['currencyCode']?.toString().trim() ?? 'USD';
    final amounts = <PaychekBillingCycle, double>{
      PaychekBillingCycle.monthly: _num(data['monthly']),
      PaychekBillingCycle.quarterly: _num(data['quarterly']),
      PaychekBillingCycle.annual: _num(data['annual']),
    };
    if (amounts.values.any((v) => v <= 0)) return null;

    final locale = numberFormatLocale.trim().isNotEmpty
        ? numberFormatLocale
        : 'en_US';
    final formatter = NumberFormat.simpleCurrency(
      name: currency,
      locale: locale,
    );

    final byCycle = <PaychekBillingCycle, PaychekPlanPriceQuote>{};
    for (final entry in amounts.entries) {
      final cycle = entry.key;
      final total = entry.value;
      final months = switch (cycle) {
        PaychekBillingCycle.monthly => 1,
        PaychekBillingCycle.quarterly => 3,
        PaychekBillingCycle.annual => 12,
      };
      byCycle[cycle] = PaychekPlanPriceQuote(
        cycle: cycle,
        totalDisplay: formatter.format(total),
        perMonthDisplay: formatter.format(total / months),
        rawTotal: total,
        currencyCode: currency,
      );
    }

    return PaychekPlanPricingSnapshot(
      byCycle: byCycle,
      source: PaychekPlanPricingSource.regionalWeb,
    );
  }

  static double _num(Object? raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse('${raw ?? ''}'.replaceAll(',', '.')) ?? 0;
  }
}
