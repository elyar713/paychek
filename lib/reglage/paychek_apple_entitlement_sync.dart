import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'paychek_apple_iap_product_ids.dart';
import 'stripe_entitlement_sync.dart';

/// Validation serveur d’un achat / restore App Store → Firestore Pro.
abstract final class PaychekAppleEntitlementSync {
  PaychekAppleEntitlementSync._();

  static Future<bool> verifySignedTransaction({
    required String productId,
    required String signedTransaction,
  }) async {
    if (FirebaseAuth.instance.currentUser == null) return false;
    final fn =
        FirebaseFunctions.instanceFor(region: kPaychekFunctionsRegion);
    final callable = fn.httpsCallable('verifyPaychekApplePurchase');
    try {
      final result = await callable.call<Object?>({
        'productId': productId,
        'signedTransaction': signedTransaction,
        'allowedProductIds': PaychekAppleIapProductIds.all.toList(),
      });
      final data = result.data;
      if (data is Map && data['active'] == true) {
        return true;
      }
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        '[Paychek] verifyPaychekApplePurchase ${e.code}: ${e.message}\n$st',
      );
    } catch (e, st) {
      debugPrint('[Paychek] verifyPaychekApplePurchase $e\n$st');
    }
    return false;
  }
}
