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
