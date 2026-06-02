import '../l10n/app_localizations.dart';
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
    PaychekSubscriptionFlowKind.appleStoreUnavailable =>
      l.paywallAppleStoreUnavailable,
    PaychekSubscriptionFlowKind.appleProductsUnavailable =>
      l.paywallAppleProductsUnavailable,
    PaychekSubscriptionFlowKind.appleVerificationFailed =>
      l.paywallAppleVerificationFailed,
    PaychekSubscriptionFlowKind.applePurchaseError =>
      l.paywallApplePurchaseError,
    PaychekSubscriptionFlowKind.launchFailed => l.paywallApplePurchaseError,
  };
}
