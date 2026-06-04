import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

import 'paychek_billing_plan.dart';
import 'paychek_google_play_iap_service.dart';

/// Lance l’achat Pro : Google Play sur Android.
Future<PaychekGooglePlayIapPurchaseOutcome?> purchaseProOnAndroidStore({
  required PaychekBillingCycle cycle,
}) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return null;
  }
  await PaychekGooglePlayIapService.ensureInitialized();
  return PaychekGooglePlayIapService.purchase(cycle: cycle);
}

Future<PaychekGooglePlayIapPurchaseOutcome?> restoreProOnAndroidStore() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return null;
  }
  await PaychekGooglePlayIapService.ensureInitialized();
  return PaychekGooglePlayIapService.restorePurchases();
}
