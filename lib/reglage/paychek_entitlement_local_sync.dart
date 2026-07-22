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
  /// Si [purchaseActive] est true (achat / restore store OK), active Pro local
  /// **tout de suite**, puis attend la confirmation Firestore (retries longs).
  /// N’enlève jamais Pro local si Firestore est encore vide / lent.
  static Future<void> refreshEntitlementFromServer({
    required bool purchaseActive,
  }) async {
    TrialAccessPrefs.invalidateSignedInAccessCache();
    if (!purchaseActive) {
      await markSubscriptionInactive();
      return;
    }

    // Pro immédiat côté UI tant que le serveur rattrape (Play / Apple OK).
    await markPurchaseVerified();

    for (var attempt = 0; attempt < 15; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
      }
      final snap = await TrialAccessPrefs.loadGateStateAndAccountEntitlement(
        forceServer: true,
      );
      if (snap.entitlement.isPro) {
        await markPurchaseVerified();
        return;
      }
    }
    // Firestore pas encore à jour : on garde le Pro local (markPurchaseVerified).
  }

  /// Recharge le statut Pro depuis Firestore (après IAP validé côté serveur).
  static Future<void> refreshProFromServer() async {
    await refreshEntitlementFromServer(purchaseActive: true);
  }
}
