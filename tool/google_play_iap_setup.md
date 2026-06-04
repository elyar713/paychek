# Google Play Billing (Android)



Architecture Paychek :



| Plateforme | Paiement |

|------------|----------|

| iPhone (app native) | App Store |

| Android (app native) | Google Play |

| Web | Stripe |



## 1. Play Console — abonnements



1. **Monétiser → Abonnements** (pas le menu « Achats intégrés » vide).

2. Créer un **groupe d’abonnements** puis 3 produits avec ces IDs (alignés sur le code) :

   - `paychek_monthly`

   - `paychek_quarterly2` (trimestriel actif ; `paychek_quarterly` = ancien, ignoré à l’achat)

   - `paychek_annual`

3. Activer chaque abo pour **test interne** / production selon l’étape.

4. Lier l’APK/AAB publié (test interne suffit pour tester).



## 2. Compte de service (validation serveur) — **obligatoire**



Sans cette étape : message *« validation serveur échouée »* après paiement Play.



Les logs Firebase montrent souvent :



`401 … insufficient permissions … permissionDenied`



→ le JSON du secret est bon, mais **Play Console n’autorise pas encore** ce compte sur l’app `pro.paychek.app`.



### A. Google Cloud (projet `paychek-trading`)



1. [Bibliothèque d’API](https://console.cloud.google.com/apis/library/androidpublisher.googleapis.com?project=paychek-trading) → activer **Google Play Android Developer API**.

2. Compte de service : `firebase-adminsdk-fbsvc@paychek-trading.iam.gserviceaccount.com` → clé JSON (fichier local, **ne pas commit**).



### B. Play Console



1. **Paramètres** (engrenage) → lier le projet Google Cloud **paychek-trading** (si proposé ; parfois regroupé avec l’invitation utilisateur).

2. **Utilisateurs et autorisations** → **Inviter** exactement :

   `firebase-adminsdk-fbsvc@paychek-trading.iam.gserviceaccount.com`

   - Statut **Actif** (pas « invitation envoyée »).

   - Droits : **Gérer les commandes et abonnements** (ou voir données financières + commandes).

   - **Accès à l’application** : cocher **Paychek** / `pro.paychek.app` (pas « toutes les apps » vide).

3. Attendre **15–30 min** après activation, puis retester **J’ai déjà souscrit** dans l’app.



### C. Secret Firebase Functions



```powershell

cd functions

firebase functions:secrets:set PAYCHEK_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON --data-file "C:\chemin\vers\paychek-trading-firebase-adminsdk-fbsvc-….json"

```



Répondre **Yes** au redéploiement des fonctions quand Firebase le propose.



Ne pas utiliser `firebase functions:secrets:set` sans `--data-file` (erreur *Secret Payload cannot be empty*).



## 3. Déploiement fonctions



```bash

cd functions && npm install

firebase deploy --only functions:verifyPaychekGooglePurchase,functions:restorePaychekGoogleEntitlement

```



## 4. Testeurs



- **Test interne** : liste de testeurs + lien d’opt-in.

- **Paramètres → Licence de test** : comptes Gmail testeurs (achats factices).



## 5. App Flutter



- Package : `pro.paychek.app`

- Plugin : `in_app_purchase`

- Après correction Play : rebuild AAB, upload test interne, puis **J’ai déjà souscrit** (pas besoin de repayer).



## 6. Vérifier que ça marche



1. Firebase → Functions → Logs → `verifyPaychekGooglePurchase` : plus de `401 permissionDenied`.

2. Firestore : `subscriber_entitlements/{uid}` → `active: true`, `provider: google_play`.

3. Admin : utilisateur **Pro**, paiement **Google Play**.

## 7. Annulation par l’utilisateur (Google Play)

### Règles (Play + UE)

- L’utilisateur **doit** pouvoir annuler depuis **Google Play** (Paramètres → Paiements → Abonnements). Paychek ne bloque pas ça.
- **Annulation ≠ fin immédiate** : l’accès Pro reste jusqu’à la **fin de la période déjà payée** (`expiryTime` Play = `currentPeriodEnd` Firestore).
- Le paywall affiche déjà : *« Paiement via Google Play • Annulable à tout moment »*.

### Comportement Paychek (implémenté)

| Étape | Action |
|--------|--------|
| Annulation dans Play | État `SUBSCRIPTION_STATE_CANCELED` mais échéance future → **reste Pro** |
| Fin de période (`EXPIRED`) | `verifyPaychekGooglePurchase` → `active: false` → **revoke** Firestore (Lite) |
| Ouverture app (Android) | Sync Play au démarrage (Pro ou Lite) → re-vérifie le token |

### Notifications temps réel (recommandé, pas encore fait)

Pour révoquer **sans** ouvrir l’app : **RTDN** (Real-Time Developer Notifications) Play → Pub/Sub → Cloud Function. À configurer dans Play Console → Monétisation → Notifications. Voir [doc Google](https://developer.android.com/google/play/billing/rtdn-reference).

### Déploiement après changement revoke

```powershell
firebase deploy --only functions:verifyPaychekGooglePurchase,functions:restorePaychekGoogleEntitlement,functions:syncPaychekGooglePlayEntitlement
```

Puis nouvel AAB (sync + date expirée côté app) : build **+15** ou suivant.

### Test annulation : pourquoi je reste Pro ?

| Situation | Normal ? |
|-----------|----------|
| Annulé **aujourd’hui**, fin Pro dans 3 semaines | **Oui** — accès jusqu’à la date payée |
| Date **Fin Pro** passée, toujours Pro | **Non** — ouvre l’app (sync) ou admin **Sync Google Play** |
| Annulé, date fin = dans 7 j (essai Play) | Échéance courte Play → resync pour recalculer la vraie fin mensuelle |

