import 'trial_access_prefs.dart';



/// Miroir local du statut Pro **après** confirmation serveur / Firestore.

abstract final class PaychekEntitlementLocalSync {

  PaychekEntitlementLocalSync._();



  static Future<void> markPurchaseVerified() async {

    await TrialAccessPrefs.setSubscriberActive(true);

  }



  /// Abonnement Play expiré ou révoqué côté serveur.

  static Future<void> markSubscriptionInactive() async {

    TrialAccessPrefs.invalidateSignedInAccessCache();

    await TrialAccessPrefs.setSubscriberActive(false);

  }



  /// Recharge le statut depuis Firestore (évite le cache après IAP / sync Stripe).

  ///

  /// N’active Pro localement **que** si Firestore confirme `isPro` — jamais

  /// avant (évite un faux Pro au simple lancement du checkout Stripe).

  static Future<void> refreshEntitlementFromServer({

    required bool purchaseActive,

  }) async {

    TrialAccessPrefs.invalidateSignedInAccessCache();

    if (!purchaseActive) {

      await markSubscriptionInactive();

      return;

    }



    for (var attempt = 0; attempt < 6; attempt++) {

      if (attempt > 0) {

        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));

      }

      final snap = await TrialAccessPrefs.loadGateStateAndAccountEntitlement(

        forceServer: true,

      );

      if (snap.entitlement.isPro) {

        await markPurchaseVerified();

        return;

      }

    }

  }



  /// Recharge le statut Pro depuis Firestore (après IAP validé côté serveur).

  static Future<void> refreshProFromServer() async {

    await refreshEntitlementFromServer(purchaseActive: true);

  }

}


