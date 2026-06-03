import 'paychek_billing_plan.dart';

/// Identifiants App Store Connect (abonnements auto-renouvelables).
///
/// Surcharge via `--dart-define` ou Firestore `paychek_app_config/billing`.
abstract final class PaychekAppleIapProductIds {
  PaychekAppleIapProductIds._();

  static const String monthly = String.fromEnvironment(
    'PAYCHEK_APPLE_PRODUCT_MONTHLY',
    defaultValue: 'Paychek.monthly',
  );

  /// IDs avec `_` : anciens `Paychek.quarterly` / `Paychek.annual` déjà pris
  /// dans des groupes supprimés (App Store Connect ne les libère pas).
  static const String quarterly = String.fromEnvironment(
    'PAYCHEK_APPLE_PRODUCT_QUARTERLY',
    defaultValue: 'Paychek_quarterly',
  );

  static const String annual = String.fromEnvironment(
    'PAYCHEK_APPLE_PRODUCT_ANNUAL',
    defaultValue: 'Paychek_annual',
  );

  static String forCycle(PaychekBillingCycle cycle) => switch (cycle) {
        PaychekBillingCycle.monthly => monthly,
        PaychekBillingCycle.quarterly => quarterly,
        PaychekBillingCycle.annual => annual,
      };

  static Set<String> get all => {monthly, quarterly, annual};

  static PaychekBillingCycle? cycleForProductId(String productId) {
    final id = productId.trim();
    if (id == monthly) return PaychekBillingCycle.monthly;
    if (id == quarterly) return PaychekBillingCycle.quarterly;
    if (id == annual) return PaychekBillingCycle.annual;
    return null;
  }
}
