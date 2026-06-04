import 'paychek_apple_iap_service.dart';
import 'paychek_google_play_iap_service.dart';

/// Résultat du flux d’abonnement (App Store, Play, Stripe web).
enum PaychekSubscriptionFlowKind {
  success,
  cancelled,
  signInRequired,
  stripeUrlMissing,
  iosWebRequiresNativeApp,
  appleStoreUnavailable,
  appleProductsUnavailable,
  appleVerificationFailed,
  applePurchaseError,
  googlePlayStoreUnavailable,
  googlePlayProductsUnavailable,
  googlePlayVerificationFailed,
  googlePlayPurchaseError,
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

  static PaychekSubscriptionFlowResult fromGoogleOutcome(
    PaychekGooglePlayIapPurchaseOutcome outcome,
  ) {
    return switch (outcome) {
      PaychekGooglePlayIapPurchaseOutcome.success =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.success,
        ),
      PaychekGooglePlayIapPurchaseOutcome.cancelled =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.cancelled,
        ),
      PaychekGooglePlayIapPurchaseOutcome.storeUnavailable =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.googlePlayStoreUnavailable,
        ),
      PaychekGooglePlayIapPurchaseOutcome.productUnavailable =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.googlePlayProductsUnavailable,
        ),
      PaychekGooglePlayIapPurchaseOutcome.verificationFailed =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.googlePlayVerificationFailed,
        ),
      PaychekGooglePlayIapPurchaseOutcome.notSignedIn =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.signInRequired,
        ),
      PaychekGooglePlayIapPurchaseOutcome.error =>
        const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.googlePlayPurchaseError,
        ),
    };
  }
}
