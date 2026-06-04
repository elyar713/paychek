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
  static Future<void> refreshEntitlementFromServer({required bool purchaseActive}) async {
    TrialAccessPrefs.invalidateSignedInAccessCache();
    if (purchaseActive) {
      await markPurchaseVerified();
    } else {
      await markSubscriptionInactive();
    }
    await TrialAccessPrefs.loadGateStateAndAccountEntitlement(
      forceServer: true,
    );
  }

  /// Recharge le statut Pro depuis Firestore (évite le cache après IAP).
  static Future<void> refreshProFromServer() async {
    await refreshEntitlementFromServer(purchaseActive: true);
  }
}
