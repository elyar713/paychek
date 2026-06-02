import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

import 'paychek_apple_iap_service.dart';
import 'paychek_billing_plan.dart';

/// Lance l’achat Pro : App Store sur iOS, Stripe ailleurs (via [openPaychekSubscriptionFlow]).
Future<PaychekAppleIapPurchaseOutcome?> purchaseProOnMobileStore({
  required PaychekBillingCycle cycle,
}) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
    return null;
  }
  await PaychekAppleIapService.ensureInitialized();
  return PaychekAppleIapService.purchase(cycle: cycle);
}

Future<PaychekAppleIapPurchaseOutcome?> restoreProOnMobileStore() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
    return null;
  }
  await PaychekAppleIapService.ensureInitialized();
  return PaychekAppleIapService.restorePurchases();
}
