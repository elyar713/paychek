import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'paychek_entitlement_local_sync.dart';
import 'paychek_google_play_product_ids.dart';
import 'stripe_entitlement_sync.dart';

/// Validation serveur d’un achat / restore Google Play → Firestore Pro.
abstract final class PaychekGoogleEntitlementSync {
  PaychekGoogleEntitlementSync._();

  /// Dernier échec (affiché dans le paywall).
  static String? lastFailureMessage;

  static Future<bool> verifyPurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    lastFailureMessage = null;
    if (FirebaseAuth.instance.currentUser == null) {
      lastFailureMessage = 'Connexion requise.';
      return false;
    }
    final fn =
        FirebaseFunctions.instanceFor(region: kPaychekFunctionsRegion);
    final callable = fn.httpsCallable('verifyPaychekGooglePurchase');
    for (var attempt = 0; attempt < 4; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(seconds: 2 * attempt));
      }
      try {
        final result = await callable.call<Object?>({
          'productId': productId,
          'purchaseToken': purchaseToken,
          'allowedProductIds': PaychekGooglePlayProductIds.all.toList(),
        });
        final data = result.data;
        if (data is Map && data['active'] == true) {
          lastFailureMessage = null;
          await PaychekEntitlementLocalSync.refreshEntitlementFromServer(
            purchaseActive: true,
          );
          return true;
        }
        if (data is Map && data['active'] == false) {
          await PaychekEntitlementLocalSync.markSubscriptionInactive();
          return false;
        }
        if (data is Map) {
          final reason = data['reason']?.toString() ?? '';
          final state = data['subscriptionState']?.toString() ?? '';
          lastFailureMessage = reason == 'expired_or_inactive'
              ? (state.isNotEmpty
                  ? 'Abonnement Play inactif ($state). Réessaie ou contacte le support.'
                  : 'Abonnement Play pas encore actif côté Google. Réessaie dans 1 minute.')
              : 'Validation serveur refusée ($reason).';
          debugPrint(
            '[Paychek] verifyPaychekGooglePurchase attempt ${attempt + 1} '
            'active=false $data',
          );
        }
      } on FirebaseFunctionsException catch (e, st) {
        lastFailureMessage = _messageFromFunctionsException(e);
        debugPrint(
          '[Paychek] verifyPaychekGooglePurchase ${e.code}: ${e.message} '
          '(attempt ${attempt + 1})\n$st',
        );
        if (e.code == 'unauthenticated' || e.code == 'invalid-argument') {
          break;
        }
      } catch (e, st) {
        lastFailureMessage = '$e';
        debugPrint(
          '[Paychek] verifyPaychekGooglePurchase $e (attempt ${attempt + 1})\n$st',
        );
      }
    }
    return false;
  }

  /// Resync serveur via token stocké dans `subscriber_entitlements` (sans achat sur l’appareil).
  static Future<bool> syncFromServer({String? targetUserId}) async {
    lastFailureMessage = null;
    if (FirebaseAuth.instance.currentUser == null) {
      lastFailureMessage = 'Connexion requise.';
      return false;
    }
    final fn =
        FirebaseFunctions.instanceFor(region: kPaychekFunctionsRegion);
    try {
      final payload = <String, dynamic>{};
      final target = targetUserId?.trim();
      if (target != null && target.isNotEmpty) {
        payload['targetUserId'] = target;
      }
      final result = await fn
          .httpsCallable('syncPaychekGooglePlayEntitlement')
          .call<Object?>(payload);
      final data = result.data;
      if (data is Map && data['active'] == true) {
        await PaychekEntitlementLocalSync.refreshEntitlementFromServer(
          purchaseActive: true,
        );
        return true;
      }
      if (data is Map && data['active'] == false) {
        await PaychekEntitlementLocalSync.refreshEntitlementFromServer(
          purchaseActive: false,
        );
        final msg = data['message']?.toString().trim() ?? '';
        final reason = data['reason']?.toString() ?? '';
        lastFailureMessage = msg.isNotEmpty
            ? msg
            : (reason == 'expired_or_inactive'
                ? 'Abonnement Google Play expiré. Réabonnez-vous depuis l’app.'
                : 'Abonnement Google Play inactif.');
        return false;
      }
    } on FirebaseFunctionsException catch (e, st) {
      lastFailureMessage = _messageFromFunctionsException(e);
      debugPrint(
        '[Paychek] syncPaychekGooglePlayEntitlement ${e.code}: ${e.message}\n$st',
      );
    } catch (e, st) {
      lastFailureMessage = '$e';
      debugPrint('[Paychek] syncPaychekGooglePlayEntitlement $e\n$st');
    }
    return false;
  }

  static String _messageFromFunctionsException(FirebaseFunctionsException e) {
    final msg = e.message?.trim() ?? '';
    if (msg.contains('Compte de service') ||
        msg.contains('API access') ||
        msg.contains('non lié') ||
        msg.contains('Play Console')) {
      return 'Le compte de service Firebase n’a pas accès à Paychek dans '
          'Play Console (Utilisateurs et autorisations → Actif, app Paychek, '
          'droits commandes/abonnements). Active aussi l’API '
          '« Google Play Android Developer » dans Google Cloud (projet paychek-trading).';
    }
    if (msg.contains('credentials') || msg.contains('JSON')) {
      return 'Secret Firebase Google Play invalide. '
          'Reconfigure PAYCHEK_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON.';
    }
    if (msg.isNotEmpty) return msg;
    return 'Validation Google Play impossible (${e.code}).';
  }
}
