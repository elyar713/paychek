/// Configuration pour les connexions sociales Firebase.
///
/// **Bureau Windows / Linux** : le package `google_sign_in` n’y enregistre pas de plugin ;
/// `flutter_facebook_auth` n’y propose Facebook que via **macOS** (pas Windows/Linux).
/// Utilise le build **Web** (`flutter run -d chrome`), **Android** ou **iOS** pour ces boutons.
///
/// **Google — Web** : le flux utilise [FirebaseAuth.signInWithPopup] ; cet ID n’est pas utilisé.
///
/// **Google — Android / iOS / macOS** : l’ID client OAuth de type **Application Web**
/// (client_type `3` dans `google-services.json`) est passé à [GoogleSignIn.initialize] comme
/// `serverClientId` pour que `authenticate()` renvoie un **`idToken`** utilisable par Firebase.
///
/// Surcharge optionnelle (CI / autre projet) :
/// `flutter run --dart-define=GOOGLE_OAUTH_WEB_CLIENT_ID=xxx.apps.googleusercontent.com`
library;

const String _kGoogleOAuthWebClientIdFromEnv = String.fromEnvironment(
  'GOOGLE_OAUTH_WEB_CLIENT_ID',
  defaultValue: '',
);

/// ID Web du projet **paychek-trading** (Firebase / Google Cloud, client OAuth « Web »).
const String kGoogleOAuthWebClientIdDefault =
    '738203717325-gke6ohrsg6192u3cnq8po9tbo2uc2jjn.apps.googleusercontent.com';

/// Chaîne utilisée par [GoogleSignIn.initialize] sur les plateformes natives.
String get kGoogleOAuthWebClientId {
  final fromEnv = _kGoogleOAuthWebClientIdFromEnv.trim();
  if (fromEnv.isNotEmpty) return fromEnv;
  return kGoogleOAuthWebClientIdDefault;
}

/// Meta Developer → appli Facebook (même ID que Android/iOS).
const String kPaychekFacebookAppId = '967493382672804';

/// Bundle iOS Paychek (audience du jeton Apple en flux natif).
const String kPaychekIosBundleId = 'pro.paychek.app';

/// Services ID **web** Apple (≠ Bundle iOS `pro.paychek.app`).
/// Apple Developer → Identifiers → Services ID → Sign in with Apple :
/// domaines `paychek.pro`, return URL [kPaychekFirebaseAppleRedirectUri].
/// Firebase Console → Auth → Apple → **ID de service** = cette valeur.
const String kPaychekAppleWebServicesId = 'pro.paychek.signin';

const String _kAppleWebServicesIdFromEnv = String.fromEnvironment(
  'PAYCHEK_APPLE_WEB_SERVICES_ID',
  defaultValue: '',
);

String get kPaychekAppleWebServicesIdForAuth {
  final fromEnv = _kAppleWebServicesIdFromEnv.trim();
  if (fromEnv.isNotEmpty) return fromEnv;
  return kPaychekAppleWebServicesId;
}

/// Callback OAuth Apple pour Firebase (web + flux iOS « Services ID »).
const String kPaychekFirebaseAppleRedirectUri =
    'https://paychek-trading.firebaseapp.com/__/auth/handler';

const String _kAppleServicesIdFromEnv = String.fromEnvironment(
  'PAYCHEK_APPLE_SERVICES_ID',
  defaultValue: '',
);

/// Aligné sur Firebase Console → Auth → Apple → **ID de service**.
///
/// Un seul champ Firebase pour **web + iOS**. Il doit être le Services ID OAuth
/// `pro.paychek.signin` (pas le Bundle `pro.paychek.app`) :
/// - web : Apple refuse le Bundle comme `client_id`
/// - iOS : flux OAuth Services ID (audience du jeton = `pro.paychek.signin`)
///
/// Ancien choix `pro.paychek.app` = mobile OK mais web cassé.
const String kPaychekAppleFirebaseServicesIdDefault = 'pro.paychek.signin';

/// **Services ID** Firebase (Auth → Apple). ≠ Bundle ID `pro.paychek.app`.
/// iOS utilise le flux OAuth avec ce Services ID pour matcher l’audience du jeton.
///
/// Surcharge CI : `--dart-define=PAYCHEK_APPLE_SERVICES_ID=xxx`
String get kPaychekAppleFirebaseServicesId {
  final fromEnv = _kAppleServicesIdFromEnv.trim();
  if (fromEnv.isNotEmpty) return fromEnv;
  return kPaychekAppleFirebaseServicesIdDefault;
}
