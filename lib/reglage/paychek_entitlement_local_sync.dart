import 'trial_access_prefs.dart';

/// Marque l’abonnement actif sur l’appareil dès validation IAP (avant propagation Firestore).
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

  /// Recharge le statut depuis Firestore (évite le cache après IAP / sync).
  static Future<void> refreshEntitlementFromServer({
    required bool purchaseActive,
  }) async {
    TrialAccessPrefs.invalidateSignedInAccessCache();
    if (purchaseActive) {
      await markPurchaseVerified();
    } else {
      await markSubscriptionInactive();
      return;
    }

    AccountEntitlementSnapshot? last;
    for (var attempt = 0; attempt < 6; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
      final snap = await TrialAccessPrefs.loadGateStateAndAccountEntitlement(
        forceServer: true,
      );
      last = snap.entitlement;
      if (last.isPro) return;
    }

    if (last != null && !last.isPro) {
      // Firestore lent ou grant serveur manquant : garde le flag local Pro.
      await markPurchaseVerified();
    }
  }

  /// Recharge le statut Pro depuis Firestore (évite le cache après IAP).
  static Future<void> refreshProFromServer() async {
    await refreshEntitlementFromServer(purchaseActive: true);
  }
}
