import 'paychek_apple_iap_service.dart';

/// Résultat du flux d’abonnement (App Store, Play, Stripe web).
enum PaychekSubscriptionFlowKind {
  success,
  cancelled,
  signInRequired,
  stripeUrlMissing,
  appleStoreUnavailable,
  appleProductsUnavailable,
  appleVerificationFailed,
  applePurchaseError,
  launchFailed,
}

class PaychekSubscriptionFlowResult {
  const PaychekSubscriptionFlowResult(this.kind);

  final PaychekSubscriptionFlowKind kind;

  bool get ok => kind == PaychekSubscriptionFlowKind.success;

  static PaychekSubscriptionFlowResult fromAppleOutcome(
    PaychekAppleIapPurchaseOutcome outcome,
  ) {
    return switch (outcome) {
      PaychekAppleIapPurchaseOutcome.success =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.success,
        ),
      PaychekAppleIapPurchaseOutcome.cancelled =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.cancelled,
        ),
      PaychekAppleIapPurchaseOutcome.storeUnavailable =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.appleStoreUnavailable,
        ),
      PaychekAppleIapPurchaseOutcome.productUnavailable =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.appleProductsUnavailable,
        ),
      PaychekAppleIapPurchaseOutcome.verificationFailed =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.appleVerificationFailed,
        ),
      PaychekAppleIapPurchaseOutcome.notSignedIn =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.signInRequired,
        ),
      PaychekAppleIapPurchaseOutcome.error =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.applePurchaseError,
        ),
    };
  }
}
