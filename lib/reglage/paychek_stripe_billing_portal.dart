import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

import 'paychek_checkout_launch.dart';
import 'stripe_entitlement_sync.dart';

/// Ouvre le portail client Stripe (factures, annulation, carte).
abstract final class PaychekStripeBillingPortal {
  PaychekStripeBillingPortal._();

  static Future<bool> open({String returnUrl = 'https://paychek.pro/'}) async {
    if (!kIsWeb || FirebaseAuth.instance.currentUser == null) return false;
    final fn =
        FirebaseFunctions.instanceFor(region: kPaychekFunctionsRegion);
    final callable = fn.httpsCallable('createPaychekStripeBillingPortal');
    try {
      final result = await callable.call<Object?>({'returnUrl': returnUrl});
      final data = result.data;
      if (data is! Map) return false;
      final url = '${data['url'] ?? ''}'.trim();
      if (url.isEmpty) return false;
      return launchPaychekCheckoutUri(Uri.parse(url));
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[Paychek] createPaychekStripeBillingPortal ${e.code}: ${e.message}\n$st',
      );
    } catch (e, st) {
      debugPrint('[Paychek] createPaychekStripeBillingPortal $e\n$st');
    }
    return false;
  }
}
