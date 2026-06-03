# Abonnement Pro via App Store (iOS)

## 1. App Store Connect

1. [App Store Connect](https://appstoreconnect.apple.com) → **Paychek** (`pro.paychek.app`)
2. **Monétisation** → **Abonnements** → créer un **groupe d’abonnements** (ex. `paychek_pro`)
3. Créer **3 abonnements auto-renouvelables** avec ces identifiants **exactement** (ou les mêmes que dans le projet) :

| Formule   | Product ID        | Prix indicatif (maquette) |
|-----------|-------------------|---------------------------|
| Mensuel   | `Paychek.monthly` | 8,99 $/mois               |
| Trimestriel | `Paychek_quarterly` | 20,97 $ / 3 mois        |
| Annuel    | `Paychek_annual`  | 59,99 $/an                |

> Les IDs sont **sensibles à la casse** — doivent correspondre **exactement** à App Store Connect.  
> Apple **ne libère pas** un identifiant déjà utilisé (même après suppression d’un groupe) : si `Paychek.quarterly` / `Paychek.annual` ne peuvent plus être créés, garde `Paychek_quarterly` / `Paychek_annual` et aligne le code (déjà le cas dans ce dépôt).

4. Pour chaque produit : métadonnées, prix, **révision App Store** (souvent liée à une nouvelle version de l’app).
5. **Utilisateurs et accès** → **Sandbox** : créer un compte test Apple pour tester les achats.

## 1 bis. Erreur Transporter `objective_c.framework` (slice simulateur)

Si l’upload échoue avec *« references an unsupported platform in the arm64 slice »* :

1. Le projet épingle `path_provider_foundation: 2.5.1` (évite le paquet FFI `objective_c`).
2. Sur le Mac, avant l’IPA : `flutter clean`, supprimer `build/native_assets`, puis `./tool/build_ios_release.sh`.
3. Ne pas archiver juste après un build **simulateur** sans `flutter clean`.

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
4. **App Store Connect** : produits `Paychek.monthly` / `Paychek_quarterly` / `Paychek_annual` créés et liés à la version soumise
5. **Sandbox** : compte test créé dans App Store Connect (pas sur le Mac — sur le site)
6. Sur l’iPhone : app **TestFlight** (icône Paychek), **compte Firebase connecté** dans l’app, puis paywall

Si le bandeau parle encore de **Stripe** dans TestFlight → la build installée est **trop ancienne** (refaire upload + installer la nouvelle build dans TestFlight).

Si le message parle d’**App Store introuvable** → produits Connect ou capability IAP manquante.

## 4 bis. « Métadonnées manquantes » qui reste après Enregistrer

### Limites de caractères (bouton Enregistrer grisé)

| Champ | Maximum |
|--------|---------|
| Nom d’affichage (chaque abo) | **30** |
| Description (chaque abo) | **45** |
| Nom d’affichage du **groupe** | **30** |

Le compteur sous le champ = caractères **restants**. Si la description dépasse 45, **Enregistrer** reste désactivé et l’état langue reste « Finaliser avant soumission ».

Exemples qui passent :

- EN description : `Unlimited journal, stats, strategy, PDF` (39 car.)
- FR description : `Journal illimité, stats, stratégie, PDF` (≤ 45 car.)
- Nom : `Paychek Pro Monthly` (≤ 30 car.)

Éviter tirets spéciaux, retours ligne, emojis dans les **noms** d’affichage.

Si prix, langue, disponibilité et capture review sont remplis mais le statut ne change pas :

### A. Localisation du **groupe** (cause la plus fréquente)

Les abos affichent tous « Métadonnées manquantes » alors que le problème est le **groupe**, pas chaque produit.

1. **Monétisation** → **Abonnements**
2. Cliquer le **groupe** (ex. `paychek 1M`) — **pas** `Paychek.monthly`
3. Descendre jusqu’à **Localisations** / **Subscription Group Localization**
4. **+** → au moins **Anglais (États-Unis)** (et **Français** si la fiche App Store est en français)
5. **Nom d’affichage du groupe** : `Paychek Pro` (obligatoire ; pas seulement le nom de référence interne)
6. **Enregistrer** → recharger la page → rouvrir `Paychek.monthly` : statut **Prêt à soumettre**

### B. Autres vérifications

- **Prix** : « Tarification actuelle pour les nouveaux abonnés » avec un palier actif (pas seulement la section vide)
- **Langue** sur l’abo : colonne **État** ≠ « Finaliser avant soumission » (ouvrir la langue → Enregistrer)
- **Capture review** : si la miniature s’affiche mais le statut ne bouge pas, **supprimer** (−) et **re-uploader** le PNG
- **Version iOS** : lier `Paychek.monthly` dans **Achats intégrés et abonnements** de la version (bandeau bleu premier abo)
- **Accords, taxe et banque** : contrat **Apps payantes** = Actif
- Répéter pour `Paychek_quarterly` et `Paychek_annual`

## 4 ter. Capture d’écran « review » abonnement

Apple refuse souvent les images **redimensionnées à la main** (Photoshop, sites web, WhatsApp). Il faut une taille **exacte** de la [liste officielle](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications).

### Méthode fiable (recommandée) — Simulateur iOS sur Mac

1. Xcode → **Window → Devices and Simulators** → simulateur **iPhone 15 Pro Max** (ou 16 Pro Max)
2. Lancer Paychek sur le simulateur (`flutter run` ou Xcode Run)
3. Ouvrir le **paywall**
4. **File → New Screen Shot** dans le Simulator (ou `Cmd+S`) → PNG sur le Bureau
5. Vérifier : `sips -g pixelWidth -g pixelHeight ~/Desktop/*.png`  
   → doit afficher **1290×2796**, **1284×2778**, **1260×2736** ou **1320×2868** selon le modèle
6. Upload ce **PNG natif** (sans recadrage) dans Connect

### Script projet (si tu as déjà une capture iPhone)

```bash
chmod +x tool/paywall_review_screenshot.sh
./tool/paywall_review_screenshot.sh ~/Downloads/capture.png 1284x2778
# Si refusé, essayer :
./tool/paywall_review_screenshot.sh ~/Downloads/capture.png 1260x2736
./tool/paywall_review_screenshot.sh ~/Downloads/capture.png 1320x2868
./tool/paywall_review_screenshot.sh ~/Downloads/capture.png 1242x2688
```

Installe ImageMagick si possible (`brew install imagemagick`) — le script produit un JPEG sRGB sans métadonnées d’orientation.

### Dans App Store Connect

1. Cliquer le **−** rouge pour **supprimer** toute capture refusée
2. Uploader **un seul** fichier
3. **Enregistrer**

Tailles portrait iPhone les plus utilisées pour la review IAP :

| Taille |
|--------|
| 1284 × 2778 |
| 1290 × 2796 |
| 1260 × 2736 |
| 1320 × 2868 |
| 1242 × 2688 |
| 1179 × 2556 |

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
