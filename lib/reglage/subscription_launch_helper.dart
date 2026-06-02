import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'paychek_apple_iap_checkout.dart';
import 'paychek_apple_iap_service.dart';
import 'paychek_billing_plan.dart';
import 'paychek_billing_remote.dart';
import 'paychek_checkout_launch.dart';
import 'trial_paywall_config.dart';

Future<bool> openPaychekSubscriptionFlow({
  PaychekBillingCycle cycle = PaychekBillingCycle.annual,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  final email = user?.email;
  final uid = user?.uid;

  if (kIsWeb) {
    PaychekBillingRemote.invalidateCache();
    final uri = await buildPaywallSubscribeUriAsync(
      cycle: cycle,
      firebaseEmail: email,
      firebaseUid: uid,
    );
    if (uri == null) return false;
    debugLogPaychekCheckoutUri(uri);
    return launchPaychekCheckoutUri(uri);
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      if (user == null) return false;
      final outcome = await purchaseProOnMobileStore(cycle: cycle);
      return outcome == PaychekAppleIapPurchaseOutcome.success;
    case TargetPlatform.android:
      return launchPaychekCheckoutUri(
        Uri.parse('https://play.google.com/store/account/subscriptions'),
      );
    default:
      PaychekBillingRemote.invalidateCache();
      final uri = await buildPaywallSubscribeUriAsync(
        cycle: cycle,
        firebaseEmail: email,
        firebaseUid: uid,
      );
      if (uri == null) return false;
      debugLogPaychekCheckoutUri(uri);
      return launchPaychekCheckoutUri(uri);
  }
}

/// Gestion d’abonnement (réglages système App Store / Play).
Future<bool> openPaychekSubscriptionManagement() async {
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
