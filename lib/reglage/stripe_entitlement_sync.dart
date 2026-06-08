import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'paychek_entitlement_local_sync.dart';
import 'trial_access_prefs.dart';

/// Région des Cloud Functions Paychek (webhook, sync Stripe, support).
const String kPaychekFunctionsRegion = 'europe-west1';

/// Synchronise l’abonnement Stripe → Firestore (`subscriber_entitlements` + `paychek_users`).
///
/// Complète le webhook : utile au retour du navigateur après Payment Link.
class PaychekStripeEntitlementSync {
  PaychekStripeEntitlementSync._();

  static Future<bool> syncFromStripe({int maxAttempts = 1}) async {
    if (FirebaseAuth.instance.currentUser == null) return false;
    final fn =
        FirebaseFunctions.instanceFor(region: kPaychekFunctionsRegion);
    final callable = fn.httpsCallable('syncPaychekStripeEntitlement');

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(seconds: 2 * attempt));
      }
      try {
        final result = await callable.call<Object?>();
        final data = result.data;
        if (data is Map && data['active'] == true) {
          await PaychekEntitlementLocalSync.refreshEntitlementFromServer(
            purchaseActive: true,
          );
          return true;
        }
        await _clearStaleLocalProIfServerInactive();
        return false;
      } on FirebaseFunctionsException catch (e, st) {
        debugPrint(
          '[Paychek] syncPaychekStripeEntitlement ${e.code}: ${e.message}\n$st',
        );
      } catch (e, st) {
        debugPrint('[Paychek] syncPaychekStripeEntitlement $e\n$st');
      }
    }
    await _clearStaleLocalProIfServerInactive();
    return false;
  }

  /// Retire un flag Pro local posé par erreur (checkout Stripe non payé).

  static Future<void> _clearStaleLocalProIfServerInactive() async {

    TrialAccessPrefs.invalidateSignedInAccessCache();

    final snap = await TrialAccessPrefs.loadGateStateAndAccountEntitlement(

      forceServer: true,

    );

    if (!snap.entitlement.isPro) {

      await PaychekEntitlementLocalSync.markSubscriptionInactive();

    }

  }

}

