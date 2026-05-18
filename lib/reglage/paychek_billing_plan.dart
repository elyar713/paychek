/// Cycle de facturation Pro (Stripe Payment Links distincts).
enum PaychekBillingCycle {
  monthly,
  quarterly,
  annual,
}

/// Tarifs affichés (USD) — maquette mobile.
abstract final class PaychekBillingPlanCatalog {
  PaychekBillingPlanCatalog._();

  static const List<PaychekBillingCycle> mobileDisplayOrder = [
    PaychekBillingCycle.annual,
    PaychekBillingCycle.quarterly,
    PaychekBillingCycle.monthly,
  ];

  static String pricePerMonth(PaychekBillingCycle cycle) => switch (cycle) {
        PaychekBillingCycle.monthly => '8,99',
        PaychekBillingCycle.quarterly => '6,99',
        PaychekBillingCycle.annual => '4,99',
      };

  static String totalPrice(PaychekBillingCycle cycle) => switch (cycle) {
        PaychekBillingCycle.monthly => '8,99',
        PaychekBillingCycle.quarterly => '20,97',
        PaychekBillingCycle.annual => '59,99',
      };
}
