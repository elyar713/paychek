# Abonnement Pro via App Store (iOS)

## 1. App Store Connect

1. [App Store Connect](https://appstoreconnect.apple.com) → **Paychek** (`pro.paychek.app`)
2. **Monétisation** → **Abonnements** → créer un **groupe d’abonnements** (ex. `paychek_pro`)
3. Créer **3 abonnements auto-renouvelables** avec ces identifiants **exactement** (ou les mêmes que dans le projet) :

| Formule   | Product ID        | Prix indicatif (maquette) |
|-----------|-------------------|---------------------------|
| Mensuel   | `Paychek.monthly` | 8,99 $/mois               |
| Trimestriel | `Paychek.quarterly` | 20,97 $ / 3 mois        |
| Annuel    | `Paychek.annual`  | 59,99 $/an                |

> Les IDs sont **sensibles à la casse** — doivent correspondre exactement à App Store Connect.

4. Pour chaque produit : métadonnées, prix, **révision App Store** (souvent liée à une nouvelle version de l’app).
5. **Utilisateurs et accès** → **Sandbox** : créer un compte test Apple pour tester les achats.

## 2. Xcode

1. Ouvrir `ios/Runner.xcworkspace`
2. Cible **Runner** → **Signing & Capabilities** → **+ Capability** → **In-App Purchase**
3. Rebuild l’app sur un **appareil réel** (les achats sandbox ne fonctionnent pas toujours sur simulateur).

## 3. Firebase Functions

Installer les dépendances (obligatoire avant le premier déploiement) :

```bash
cd functions
npm install
cd ..
```

Si tu vois `Cannot find module '@apple/app-store-server-library'`, c’est que cette étape n’a pas été faite dans `functions/`.

Déployer les fonctions de validation (terminal **interactif**, avec tes secrets Firebase déjà configurés) :

```bash
firebase deploy --only functions:verifyPaychekApplePurchase,functions:restorePaychekAppleEntitlement
```

Le bundle iOS utilisé pour la validation est fixé dans le code : `pro.paychek.app`.

(Région : `europe-west1`, comme le reste du projet.)

## 4. Test

1. Se connecter à l’app iOS avec un compte Firebase
2. Ouvrir le paywall → choisir une formule → confirmer avec le compte **Sandbox**
3. L’app appelle `verifyPaychekApplePurchase` → Firestore `subscriptionTier: pro`, `paymentMethod: apple_iap`
4. **Restaurer les achats** : bouton du paywall (même flux de validation)

### TestFlight (Mac in Cloud)

> **Important :** une build TestFlight **antérieure au commit `7c30a33`** (avril 2026) appelait encore **Stripe** sur iPhone — message *« Lien Stripe introuvable… »*. Il faut **re-uploader** une build avec le code IAP récent (`git pull`, puis archive).

Checklist avant de tester sur iPhone :

1. **Code à jour** : `git pull` → commit ≥ `11f4fc2` (messages App Store, pas Stripe sur échec IAP)
2. **Numéro de build** : incrémenter `version:` dans `pubspec.yaml` (ex. `1.2.1+6`) avant chaque upload TestFlight
3. **Xcode** : Runner → **Signing & Capabilities** → **In-App Purchase** activé
4. **App Store Connect** : produits `Paychek.monthly` / `.quarterly` / `.annual` créés et liés à la version soumise
5. **Sandbox** : compte test créé dans App Store Connect (pas sur le Mac — sur le site)
6. Sur l’iPhone : app **TestFlight** (icône Paychek), **compte Firebase connecté** dans l’app, puis paywall

Si le bandeau parle encore de **Stripe** dans TestFlight → la build installée est **trop ancienne** (refaire upload + installer la nouvelle build dans TestFlight).

Si le message parle d’**App Store introuvable** → produits Connect ou capability IAP manquante.

## 5. IDs produits personnalisés (optionnel)

Build avec `--dart-define` :

```bash
flutter run --dart-define=PAYCHEK_APPLE_PRODUCT_MONTHLY=mon_id_mensuel \
  --dart-define=PAYCHEK_APPLE_PRODUCT_QUARTERLY=mon_id_trim \
  --dart-define=PAYCHEK_APPLE_PRODUCT_ANNUAL=mon_id_an
```

Les IDs doivent aussi être autorisés côté Cloud Function (liste par défaut dans `functions/apple_iap.js`).

## 6. Gestion abonnement

Utilisateurs Pro iOS : **Réglages → Compte → Gérer l’abonnement** ouvre les réglages d’abonnement Apple.
