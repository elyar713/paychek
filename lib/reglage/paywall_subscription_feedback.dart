import '../l10n/app_localizations.dart';
import 'paychek_apple_entitlement_sync.dart';
import 'paychek_google_entitlement_sync.dart';
import 'paychek_subscription_flow_result.dart';

/// Message utilisateur selon la plateforme et la cause d’échec.
String paywallMessageForSubscriptionResult(
  AppLocalizations l,
  PaychekSubscriptionFlowResult result,
) {
  return switch (result.kind) {
    PaychekSubscriptionFlowKind.success => '',
    PaychekSubscriptionFlowKind.cancelled => '',
    PaychekSubscriptionFlowKind.signInRequired => l.paywallSignInRequired,
    PaychekSubscriptionFlowKind.stripeUrlMissing => l.paywallStoreNotConfigured,
    PaychekSubscriptionFlowKind.iosWebRequiresNativeApp =>
      l.paywallIosWebRequiresNativeApp,
    PaychekSubscriptionFlowKind.appleStoreUnavailable =>
      l.paywallAppleStoreUnavailable,
    PaychekSubscriptionFlowKind.appleProductsUnavailable =>
      l.paywallAppleProductsUnavailable,
    PaychekSubscriptionFlowKind.appleVerificationFailed =>
      PaychekAppleEntitlementSync.lastFailureMessage?.trim().isNotEmpty == true
          ? PaychekAppleEntitlementSync.lastFailureMessage!.trim()
          : l.paywallAppleVerificationFailed,
    PaychekSubscriptionFlowKind.applePurchaseError =>
      l.paywallApplePurchaseError,
    PaychekSubscriptionFlowKind.googlePlayStoreUnavailable =>
      l.paywallGooglePlayStoreUnavailable,
    PaychekSubscriptionFlowKind.googlePlayProductsUnavailable =>
      l.paywallGooglePlayProductsUnavailable,
    PaychekSubscriptionFlowKind.googlePlayVerificationFailed =>
      PaychekGoogleEntitlementSync.lastFailureMessage?.trim().isNotEmpty == true
          ? PaychekGoogleEntitlementSync.lastFailureMessage!.trim()
          : l.paywallGooglePlayVerificationFailed,
    PaychekSubscriptionFlowKind.googlePlayPurchaseError =>
      l.paywallGooglePlayPurchaseError,
    PaychekSubscriptionFlowKind.launchFailed => l.paywallStoreNotConfigured,
  };
}
