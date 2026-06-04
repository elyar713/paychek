import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'paychek_apple_iap_product_ids.dart';
import 'paychek_apple_transaction_jws.dart';
import 'paychek_entitlement_local_sync.dart';
import 'stripe_entitlement_sync.dart';

/// Validation serveur d’un achat / restore App Store → Firestore Pro.
abstract final class PaychekAppleEntitlementSync {
  PaychekAppleEntitlementSync._();

  static String? lastFailureMessage;

  static Future<bool> verifySignedTransaction({
    required String productId,
    required String signedTransaction,
    String appleStoreKit2Json = '',
    bool isRestore = false,
  }) async {
    lastFailureMessage = null;
    if (FirebaseAuth.instance.currentUser == null) {
      lastFailureMessage = 'Connexion requise.';
      return false;
    }
    final jws = signedTransaction.trim();
    final jsonPayload = appleStoreKit2Json.trim();
    if (!paychekHasAppleVerificationPayload(
      jws: jws,
      storeKit2Json: jsonPayload,
    )) {
      lastFailureMessage =
          'Reçu Apple incomplet. Réessaie ou utilise « Restaurer les achats ».';
      return false;
    }
    final fn =
        FirebaseFunctions.instanceFor(region: kPaychekFunctionsRegion);
    final callableName = isRestore ?
        'restorePaychekAppleEntitlement' :
        'verifyPaychekApplePurchase';
    final callable = fn.httpsCallable(callableName);
    for (var attempt = 0; attempt < 4; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(seconds: 2 * attempt));
      }
      try {
        final payload = <String, dynamic>{
          'productId': productId,
          'allowedProductIds': PaychekAppleIapProductIds.all.toList(),
        };
        if (jws.isNotEmpty) payload['signedTransaction'] = jws;
        if (jsonPayload.isNotEmpty) {
          payload['appleStoreKit2Json'] = jsonPayload;
        }
        if (isRestore) payload['allowTransfer'] = true;
        final result = await callable.call<Object?>(payload);
        final data = result.data;
        if (data is Map && data['active'] == true) {
          lastFailureMessage = null;
          await PaychekEntitlementLocalSync.refreshEntitlementFromServer(
            purchaseActive: true,
          );
          return true;
        }
        if (data is Map && data['active'] == false) {
          lastFailureMessage = _reasonFromResponse(data) ??
              'Abonnement Apple inactif ou expiré.';
          await PaychekEntitlementLocalSync.markSubscriptionInactive();
          return false;
        }
        if (data is Map) {
          lastFailureMessage =
              _reasonFromResponse(data) ?? 'Validation Apple incomplète.';
        }
      } on FirebaseFunctionsException catch (e, st) {
        debugPrint(
          '[Paychek] verifyPaychekApplePurchase ${e.code}: ${e.message}\n$st',
        );
        lastFailureMessage = _messageFromFunctionsException(e);
        if (e.code == 'unavailable' ||
            e.code == 'deadline-exceeded' ||
            e.code == 'internal') {
          continue;
        }
        if (e.code == 'failed-precondition') {
          return false;
        }
        return false;
      } catch (e, st) {
        debugPrint('[Paychek] verifyPaychekApplePurchase $e\n$st');
        lastFailureMessage = '$e';
        return false;
      }
    }
    lastFailureMessage ??=
        'Validation serveur indisponible. Réessaie dans quelques secondes.';
    return false;
  }

  static String? _reasonFromResponse(Map<dynamic, dynamic> data) {
    final reason = data['reason']?.toString().trim();
    if (reason != null && reason.isNotEmpty) return reason;
    final message = data['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    return null;
  }

  static String _messageFromFunctionsException(FirebaseFunctionsException e) {
    final msg = e.message?.trim() ?? '';
    if (e.code == 'not-found' || e.code == 'unavailable') {
      return 'Fonction verifyPaychekApplePurchase absente ou indisponible. '
          'Déploie les Cloud Functions Firebase (région europe-west1).';
    }
    if (msg.contains('JWS') ||
        msg.contains('jws') ||
        msg.contains('Transaction Apple invalide') ||
        msg.contains('signedTransaction') ||
        msg.contains('déjà lié')) {
      return msg.isNotEmpty ?
          msg :
          'Reçu Apple refusé par le serveur. Réessaie ou « Restaurer les achats ».';
    }
    if (msg.isNotEmpty) return msg;
    return 'Validation Apple impossible (${e.code}).';
  }
}
