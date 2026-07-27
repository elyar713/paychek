# OAuth Google / Apple sur paychek.pro (web)

Localhost fonctionne, **paychek.pro** non → vérifier ces 3 consoles (dans l’ordre).

## 1. Firebase — domaines autorisés

**Firebase Console** → **Authentication** → **Settings** → **Authorized domains**

Ajouter si absent :

| Domaine |
|---------|
| `paychek.pro` |
| `www.paychek.pro` |
| `paychek-trading.firebaseapp.com` |
| `localhost` |

Sans `paychek.pro` → erreur **`auth/unauthorized-domain`**.

---

## 2. Google Cloud — client OAuth Web

**Google Cloud Console** → projet **paychek-trading** → **APIs & Services** → **Credentials**

Ouvrir le client **Web** :  
`738203717325-gke6ohrsg6192u3cnq8po9tbo2uc2jjn.apps.googleusercontent.com`

### Authorized JavaScript origins

```
https://paychek.pro
https://www.paychek.pro
https://paychek-trading.firebaseapp.com
http://localhost
http://127.0.0.1
```

### Authorized redirect URIs

```
https://paychek-trading.firebaseapp.com/__/auth/handler
```

---

## 3. Google Cloud — clé API navigateur (web)

**Credentials** → clé API utilisée par l’app web (`AIzaSyB_hs_…` dans `firebase_options.dart`)

Si **Application restrictions** = **HTTP referrers**, ajouter :

```
https://paychek.pro/*
https://www.paychek.pro/*
https://paychek-trading.web.app/*
https://paychek-trading.firebaseapp.com/*
http://localhost/*
```

Sans ces referrers, Google / Firebase Auth échoue **uniquement en production**.

---

## 4. Facebook — connexion web

Sur le web, Paychek utilise **Firebase redirect** (`signInWithRedirect`). L’App ID envoyé à Meta vient **uniquement** de Firebase Console (pas du code).

### Firebase (obligatoire — cause n°1 de « ID d’app non valide »)

[Authentication → Facebook](https://console.firebase.google.com/project/paychek-trading/authentication/providers)

| Champ | Valeur |
|-------|--------|
| **Activé** | Oui |
| **App ID** | `967493382672804` — copier depuis Meta → Settings → Basic |
| **App secret** | Meta → Settings → Basic → **Show** → coller ici |

Si l’App ID Firebase est vide, ancien ou différent → Meta affiche **« ID d’app non valide »**.

URI de redirection OAuth (affiché par Firebase) :

```
https://paychek-trading.firebaseapp.com/__/auth/handler
```

### Meta Developer (developers.facebook.com)

App **967493382672804** :

1. **Settings → Basic** : vérifier que l’App ID existe et que l’app n’est pas supprimée.
2. **Use cases** ou **Products** → **Facebook Login** → **Settings** :
   - **Se connecter avec le SDK JavaScript** : **Oui**
   - **Domaines autorisés pour le SDK Javascript** : `paychek.pro` (et `localhost` en dev)
   - **Valid OAuth Redirect URIs** (toutes les lignes, une par ligne) :
     ```
     https://paychek.pro/
     https://paychek.pro/?auth=login
     https://paychek-trading.firebaseapp.com/__/auth/handler
     http://localhost/
     ```
3. **Settings → Basic** → **App domains** : `paychek.pro`
4. Plateforme **Website** : `https://paychek.pro/`
5. Mode **Development** : votre compte Facebook doit être **Tester** ou **Admin** de l’app.
6. Si vous régénérez le **App secret** sur Meta, recopiez-le dans Firebase.

Erreur **« ID d’app non valide »** sur la page Meta → l’App ID dans l’URL (`client_id=`) ne correspond pas à une app Meta valide, ou l’app est restreinte / en mode dev sans rôle testeur.

---

## 5. Apple — connexion web

Sur le web, Paychek utilise **Firebase** (`signInWithPopup` / `signInWithRedirect` + `AppleAuthProvider`), comme Google — **pas** le popup Apple JS direct.

Erreur Apple **« Invalid client id or web redirect url »** : le web ne peut pas utiliser le Bundle iOS `pro.paychek.app` comme client OAuth. Il faut un **Services ID web** distinct, et Firebase doit l’utiliser.

### 1. Apple Developer (developer.apple.com)

**Certificates, Identifiers & Profiles** → **Identifiers** → **+** → **Services IDs** :

| Champ | Valeur |
|-------|--------|
| Description | Paychek Web |
| Identifier | `pro.paychek.signin` |

Cocher **Sign in with Apple** → **Configure** :

| Champ | Valeur |
|-------|--------|
| Primary App ID | Paychek (`pro.paychek.app`) |
| Domains | `paychek.pro` |
| Return URLs | `https://paychek-trading.firebaseapp.com/__/auth/handler` |

Enregistrer (et **Save** une 2ᵉ fois sur l’écran Services ID).

### 2. Firebase Console

[Authentication → Apple](https://console.firebase.google.com/project/paychek-trading/authentication/providers) :

| Champ | Valeur |
|-------|--------|
| **Services ID** | `pro.paychek.signin` (**pas** `pro.paychek.app`) |
| Team ID, Key ID, clé `.p8` | inchangés (même clé Apple) |

**Enregistrer.**

> **Conflit historique :** `pro.paychek.app` dans Firebase = iOS natif OK, **web cassé**.
> La bonne config unique = `pro.paychek.signin` : web OK + iOS via flux OAuth Services ID
> (déjà dans le code ; rebuild / release iOS après le changement Console).

### 3. Test

1. https://paychek.pro/?auth=login (fenêtre principale, pas iframe)
2. Clic Apple → popup / redirect Apple
3. Si erreur : lire le dialogue rouge (code Firebase)

---

## 6. Déploiement

Après changement de code :

```powershell
.\scripts\deploy_web_hosting_only.ps1
```

Sur paychek.pro, l’app utilise **`signInWithRedirect`** (pas popup) — au clic Google, la page doit **quitter** paychek.pro vers accounts.google.com.

---

## Test rapide

1. Ouvrir https://paychek.pro/?auth=login  
2. Clic **Google** → redirection vers Google (pas simple fermeture silencieuse)  
3. Si bandeau rouge en haut → lire le code Firebase (`unauthorized-domain`, etc.)
