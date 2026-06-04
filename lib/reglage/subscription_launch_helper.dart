import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'paychek_apple_iap_checkout.dart';
import 'paychek_gold_upgrade_sheet.dart';
import 'paychek_apple_iap_service.dart';
import 'paychek_google_play_iap_checkout.dart';
import 'paychek_google_play_iap_service.dart';
import 'paychek_billing_plan.dart';
import 'paychek_billing_remote.dart';
import 'paychek_checkout_launch.dart';
import 'paychek_subscription_flow_result.dart';
import 'paychek_subscription_platform.dart';
import 'trial_paywall_config.dart';

Future<PaychekSubscriptionFlowResult> openPaychekSubscriptionFlow({
  PaychekBillingCycle cycle = PaychekBillingCycle.annual,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  final email = user?.email;
  final uid = user?.uid;

  // iOS natif : App Store uniquement (jamais Stripe).
  if (paychekUsesNativeAppleIap) {
    if (user == null) {
      return const PaychekSubscriptionFlowResult(
        PaychekSubscriptionFlowKind.signInRequired,
      );
    }
    await PaychekAppleIapService.ensureInitialized();
    final outcome = await purchaseProOnMobileStore(cycle: cycle);
    if (outcome == null) {
      debugPrint(
        '[Paychek] IAP iOS: purchaseProOnMobileStore null '
        '(kIsWeb=$kIsWeb, platform=$defaultTargetPlatform)',
      );
      return const PaychekSubscriptionFlowResult(
        PaychekSubscriptionFlowKind.appleStoreUnavailable,
      );
    }
    final result = PaychekSubscriptionFlowResult.fromAppleOutcome(outcome);
    if (!result.ok) {
      debugPrint('[Paychek] IAP iOS outcome: $outcome');
    }
    return result;
  }

  // Android natif : Google Play uniquement (jamais Stripe).
  if (paychekUsesNativeGooglePlayIap) {
    if (user == null) {
      return const PaychekSubscriptionFlowResult(
        PaychekSubscriptionFlowKind.signInRequired,
      );
    }
    await PaychekGooglePlayIapService.ensureInitialized();
    final outcome = await purchaseProOnAndroidStore(cycle: cycle);
    if (outcome == null) {
      debugPrint(
        '[Paychek] IAP Android: purchaseProOnAndroidStore null '
        '(kIsWeb=$kIsWeb, platform=$defaultTargetPlatform)',
      );
      return const PaychekSubscriptionFlowResult(
        PaychekSubscriptionFlowKind.googlePlayStoreUnavailable,
      );
    }
    final result = PaychekSubscriptionFlowResult.fromGoogleOutcome(outcome);
    if (!result.ok) {
      debugPrint('[Paychek] IAP Android outcome: $outcome');
    }
    return result;
  }

  // Safari / web sur iPhone : pas de Stripe in-app.
  if (paychekIsIosWeb) {
    return const PaychekSubscriptionFlowResult(
      PaychekSubscriptionFlowKind.iosWebRequiresNativeApp,
    );
  }

  if (kIsWeb) {
    PaychekBillingRemote.invalidateCache();
    final uri = await buildPaywallSubscribeUriAsync(
      cycle: cycle,
      firebaseEmail: email,
      firebaseUid: uid,
    );
    if (uri == null) {
      return const PaychekSubscriptionFlowResult(
        PaychekSubscriptionFlowKind.stripeUrlMissing,
      );
    }
    debugLogPaychekCheckoutUri(uri);
    final launched = await launchPaychekCheckoutUri(uri);
    return PaychekSubscriptionFlowResult(
      launched
          ? PaychekSubscriptionFlowKind.success
          : PaychekSubscriptionFlowKind.launchFailed,
    );
  }

  switch (defaultTargetPlatform) {
    default:
      PaychekBillingRemote.invalidateCache();
      final uri = await buildPaywallSubscribeUriAsync(
        cycle: cycle,
        firebaseEmail: email,
        firebaseUid: uid,
      );
      if (uri == null) {
        return const PaychekSubscriptionFlowResult(
          PaychekSubscriptionFlowKind.stripeUrlMissing,
        );
      }
      debugLogPaychekCheckoutUri(uri);
      final launched = await launchPaychekCheckoutUri(uri);
      return PaychekSubscriptionFlowResult(
        launched
            ? PaychekSubscriptionFlowKind.success
            : PaychekSubscriptionFlowKind.launchFailed,
      );
  }
}

/// Gestion d’abonnement : paywall (web), App Store / Play (mobile).
Future<bool> openPaychekSubscriptionManagement({BuildContext? context}) async {
  if (kIsWeb) {
    if (context == null) return false;
    await showPaychekGoldUpgradeSheet(context: context);
    return true;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return launchPaychekCheckoutUri(
        Uri.parse('https://apps.apple.com/account/subscriptions'),
      );
    case TargetPlatform.android:
      return launchPaychekCheckoutUri(
        Uri.parse('https://play.google.com/store/account/subscriptions'),
      );
    default:
      return false;
  }
}
