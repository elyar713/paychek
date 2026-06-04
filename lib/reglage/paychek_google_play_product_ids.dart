import 'paychek_billing_plan.dart';

/// Identifiants Google Play Console (abonnements).
///
/// Surcharge via `--dart-define` ou Firestore `paychek_app_config/billing`.
abstract final class PaychekGooglePlayProductIds {
  PaychekGooglePlayProductIds._();

  /// Ancien ID trimestriel (forfait mensuel par erreur) — restore uniquement.
  static const String quarterlyLegacy = 'paychek_quarterly';

  static const String monthly = String.fromEnvironment(
    'PAYCHEK_GOOGLE_PRODUCT_MONTHLY',
    defaultValue: 'paychek_monthly',
  );

  static const String quarterly = String.fromEnvironment(
    'PAYCHEK_GOOGLE_PRODUCT_QUARTERLY',
    defaultValue: 'paychek_quarterly2',
  );

  static const String annual = String.fromEnvironment(
    'PAYCHEK_GOOGLE_PRODUCT_ANNUAL',
    defaultValue: 'paychek_annual',
  );

  static String forCycle(PaychekBillingCycle cycle) => switch (cycle) {
        PaychekBillingCycle.monthly => monthly,
        PaychekBillingCycle.quarterly => quarterly,
        PaychekBillingCycle.annual => annual,
      };

  static Set<String> get all => {monthly, quarterly, quarterlyLegacy, annual};

  static PaychekBillingCycle? cycleForProductId(String productId) {
    final id = productId.trim();
    if (id == monthly) return PaychekBillingCycle.monthly;
    if (id == quarterly || id == quarterlyLegacy) {
      return PaychekBillingCycle.quarterly;
    }
    if (id == annual) return PaychekBillingCycle.annual;
    return null;
  }

  static bool isKnownProductId(String productId) =>
      cycleForProductId(productId) != null;
}
