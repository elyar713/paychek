# Checklist resoumission App Store — Paychek (v1.0+)

Référence rejet : Submission `125e50d0-7e2c-4f10-aab7-aa320262a9b6` (11 juin 2026).

Bundle ID : `pro.paychek.app`  
Produits IAP : `Paychek.monthly`, `Paychek_quarterly`, `Paychek_annual`

---

## Blocage n°1 — Compte développeur **Organization** (3.2.1 viii)

**Impossible à contourner par le code.**

| Étape | Où | Action |
|-------|-----|--------|
| 1 | [developer.apple.com/contact](https://developer.apple.com/contact/) | Demander la **conversion Individual → Organization** (SARL, SAS, EURL, etc.) |
| 2 | Documents | Préparer : extrait Kbis / immatriculation, D-U-N-S si demandé, site `paychek.pro` |
| 3 | Alternative | Créer un compte Organization neuf + [transférer l’app](https://developer.apple.com/help/app-store-connect/transfer-an-app/overview) |
| 4 | Vérification | App Store Connect → **Users and Access** → le compte doit afficher **Organization**, pas **Individual** |

> Ne resoumettez pas tant que ce point n’est pas réglé : rejet automatique garanti pour une app « financial services ».

---

## Blocage n°2 — Sign in with Apple sur iPad (2.1 a)

### Correctifs déjà dans le repo

- Nonce Firebase (`rawNonce` + hash SHA-256) dans `lib/reglage/social_auth_service.dart`
- `presentationContextProvider` iPad dans `packages/sign_in_with_apple/.../SignInWithAppleAvailablePlugin.swift`

### Avant archive

| # | Console | Vérification |
|---|---------|--------------|
| 1 | **Firebase** → Authentication → Sign-in method | **Apple** = Activé |
| 2 | **Apple Developer** → Identifiers → `pro.paychek.app` | Capability **Sign In with Apple** cochée |
| 3 | **Apple Developer** → Keys / Services ID | Service ID lié à Firebase si configuré côté console |
| 4 | `ios/Runner/Runner.entitlements` | `com.apple.developer.applesignin` = `Default` |
| 5 | `ios/Runner/GoogleService-Info.plist` | `BUNDLE_ID` = `pro.paychek.app` |

### Test obligatoire (iPad)

Utiliser le script Mac : `scripts/ios/test_apple_signin_ipad.sh`

Scénario manuel :

1. **Supprimer** toute version de Paychek sur l’iPad / simulateur
2. Installer le **build release** (pas debug si possible)
3. Splash → langue → écran connexion
4. **Sign in with Apple** → Face ID / mot de passe Apple
5. **Attendu** : disparition de l’écran login → splash/questionnaire ou dashboard (pas de blocage sur login)
6. Tester aussi **Google** et **email** pour confirmer que seul Apple était cassé

### Notes pour App Review

Dans **App Review Information → Notes** :

```
Sign in with Apple was fixed for iPad (Firebase nonce + ASAuthorizationController presentation anchor).
Tested on iPad simulator/device: after Apple sign-in, the app proceeds to the main flow (questionnaire or dashboard).
Demo account (email/password): [si vous en fournissez un]
```

---

## Blocage n°3 — Abonnements auto-renouvelables (3.1.2 c)

### Dans l’app (déjà corrigé)

Paywall IAP natif affiche :

- Titre / durée / prix des plans (mensuel, trimestriel, annuel)
- Liens **cliquables** : Privacy Policy + Terms of Use (`PaychekPaywallLegalFooter`)

**Où le reviewer doit regarder :**

1. Ouvrir l’app connecté
2. Déclencher le paywall : essai expiré **ou** Réglages → Upgrade / bouton Gold
3. Scroller en bas → liens **Privacy policy** et **Terms of sale**

URLs :

- Privacy : `https://paychek.pro/privacy-en.html`
- Terms (EULA) : `https://paychek.pro/terms.html`

### App Store Connect — champs exacts

#### App Information

| Champ | Valeur |
|-------|--------|
| **Privacy Policy URL** | `https://paychek.pro/privacy-en.html` |

#### Version 1.x → App Store → Description (fin du texte)

Ajouter un paragraphe **en anglais** (langue de review) :

```
Terms of Use (EULA): https://paychek.pro/terms.html
Privacy Policy: https://paychek.pro/privacy-en.html

Auto-renewable subscriptions:
- Paychek Pro Monthly (Paychek.monthly) — 1 month
- Paychek Pro Quarterly (Paychek_quarterly) — 3 months
- Paychek Pro Annual (Paychek_annual) — 1 year
Prices are shown in the in-app purchase flow before confirmation.
Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period in Settings → Apple ID → Subscriptions.
```

*(Adapter les libellés affichés dans App Store Connect si vos noms produits diffèrent.)*

#### EULA (optionnel si texte custom)

**App Information** → **License Agreement** → **Custom EULA**  
OU lien standard Apple + URL terms dans la description (comme ci-dessus).

#### In-App Purchases

Pour chaque abonnement (`Paychek.monthly`, etc.) :

| Champ | Contenu |
|-------|---------|
| **Reference Name** | Ex. Paychek Pro Monthly |
| **Subscription Duration** | 1 month / 3 months / 1 year |
| **Price** | Aligné sur le paywall |
| **Localization** | Nom + description clairs (ex. « Paychek Pro — full journal access ») |
| **Review screenshot** | Capture du paywall avec prix visible |

#### App Review Information

| Champ | Contenu |
|-------|---------|
| **Notes** | « Subscription legal links are at the bottom of the upgrade paywall (Privacy Policy + Terms of Use). See attached screen recording. » |
| **Attachment** | **Screen recording** iPad : login Apple OK + scroll paywall jusqu’aux liens légaux |

---

## App Privacy — photos / caméra (screenshots trades)

Paychek permet d’attacher une image **optionnelle** (galerie ou caméra) sur l’écran **Ajouter un trade** et le **rapport d’analyse**. Pas d’accès en arrière-plan.

### Textes iOS (`ios/Runner/Info.plist`)

| Clé | Texte (anglais — langue principale App Store) |
|-----|-----------------------------------------------|
| `NSCameraUsageDescription` | Paychek needs camera access so you can attach a chart or setup photo to a trade or analysis report. |
| `NSPhotoLibraryUsageDescription` | Paychek needs photo library access so you can choose an image to attach to a trade or analysis report. |

La popup système s’affiche **au tap** sur « Ajouter une capture » → Galerie ou Caméra (pas au lancement de l’app).

### App Store Connect → App Privacy (questionnaire)

Chemin : **App Store Connect** → votre app → **Confidentialité de l’app** (App Privacy) → **Modifier**.

Réponses recommandées pour Paychek :

| Question | Réponse |
|----------|---------|
| Collectez-vous des données ? | **Oui** |
| **Photos ou vidéos** | **Oui** |
| Liées à l’utilisateur ? | **Oui** (contenu qu’il choisit lui-même) |
| Utilisation | **Fonctionnalité de l’app** (journal / rapport) |
| Collectées à chaque utilisation ? | **Oui** (seulement quand l’utilisateur ajoute une image) |
| Utilisées pour le suivi ? | **Non** |
| Partagées avec des tiers ? | **Non** (sauf sync Firebase de *son* compte si vous stockez les images — si oui, indiquer « stockage cloud » lié au compte) |

**Caméra** : si le questionnaire propose une entrée séparée « Caméra », même logique — fonctionnalité app, pas de suivi.

> Si les screenshots sont **uniquement locales** (pas uploadées Firestore) : Photos = oui, mais pas de « données partagées avec des tiers ». Vérifiez votre implémentation (sync journal).

### Ce qu’il ne faut pas cocher

- Pas de « accès complet à la photothèque en arrière-plan »
- Pas de « suivi publicitaire » via photos
- Pas de permission `READ_MEDIA_*` persistante sur Android (déjà retirée dans le manifest)

---

## Build & soumission

```bash
# Sur Mac uniquement
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
# Ou Xcode → Product → Archive → Distribute → App Store Connect
```

| Étape | Action |
|-------|--------|
| 1 | Incrémenter **Build** (ex. 45+) dans `pubspec.yaml` |
| 2 | Upload IPA via Transporter ou Xcode |
| 3 | Sélectionner le build dans App Store Connect |
| 4 | **Reply** au message de rejet avec le texte ci-dessous |
| 5 | Submit for Review |

---

## Modèle de réponse (Reply in App Store Connect)

```
Hello App Review,

Thank you for the detailed feedback. We addressed all three points:

1) Sign in with Apple (Guideline 2.1a): Fixed iPad presentation context and Firebase Apple nonce handling. Tested on iPad — sign-in now proceeds past the login screen.

2) Subscriptions (Guideline 3.1.2c): Updated App Store metadata with functional Privacy Policy and Terms of Use URLs. The in-app purchase flow displays subscription title, duration, price, and tappable legal links at the bottom of the paywall.

3) Organization account (Guideline 3.2.1viii): [CHOOSE ONE]
   - Our Apple Developer Program account has been converted to an Organization account.
   - OR: The app is now submitted under our Organization account [Company Name].

A screen recording is attached in App Review Information showing Sign in with Apple on iPad and the subscription legal links.

Best regards,
[Your name]
```

---

## Ordre recommandé

1. Compte **Organization** validé  
2. Tests iPad Sign in with Apple (script + manuel)  
3. Métadonnées App Store Connect mises à jour  
4. Nouveau build uploadé  
5. Reply + resoumission
