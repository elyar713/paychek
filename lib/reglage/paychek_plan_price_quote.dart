import 'paychek_billing_plan.dart';

/// Prix affichés pour une formule (libellés localisés, TTC côté store).
class PaychekPlanPriceQuote {
  const PaychekPlanPriceQuote({
    required this.cycle,
    required this.totalDisplay,
    required this.perMonthDisplay,
    required this.rawTotal,
    required this.currencyCode,
  });

  final PaychekBillingCycle cycle;
  final String totalDisplay;
  final String perMonthDisplay;
  final double rawTotal;
  final String currencyCode;
}

/// Ensemble de tarifs pour le paywall (store ou région web).
class PaychekPlanPricingSnapshot {
  const PaychekPlanPricingSnapshot({
    required this.byCycle,
    required this.source,
  });

  final Map<PaychekBillingCycle, PaychekPlanPriceQuote> byCycle;
  final PaychekPlanPricingSource source;

  PaychekPlanPriceQuote? quoteFor(PaychekBillingCycle cycle) => byCycle[cycle];

  /// Pourcentage d’économie annuel vs mensuel (null si incomplet).
  int? annualSavingsPercent() {
    final monthly = byCycle[PaychekBillingCycle.monthly]?.rawTotal;
    final annual = byCycle[PaychekBillingCycle.annual]?.rawTotal;
    if (monthly == null || annual == null || monthly <= 0) return null;
    final monthlyEquiv = annual / 12;
    final pct = ((1 - monthlyEquiv / monthly) * 100).round();
    if (pct < 1 || pct > 90) return null;
    return pct;
  }
}

enum PaychekPlanPricingSource {
  appStore,
  googlePlay,
  regionalWeb,
  catalogFallback,
}
