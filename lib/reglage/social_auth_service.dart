import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'social_auth_config.dart';

bool _isFirebaseWebPopupCancelled(FirebaseAuthException e) {
  final c = e.code.toLowerCase();
  return c.contains('popup-closed-by-user') ||
      c.contains('cancelled-popup-request') ||
      c == 'web-context-cancelled';
}

/// Connexion Google → Firebase. Retourne `null` si l’utilisateur a annulé.
///
/// **Web** : [FirebaseAuth.signInWithPopup] (pas besoin de `kGoogleOAuthWebClientId`).
/// **Mobile / macOS** : plugin `google_sign_in` + jeton vers Firebase.
Future<UserCredential?> signInWithGoogle() async {
  if (kIsWeb) {
    try {
      return await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } on FirebaseAuthException catch (e) {
      if (_isFirebaseWebPopupCancelled(e)) {
        return null;
      }
      rethrow;
    }
  }

  bool supported;
  try {
    supported = GoogleSignIn.instance.supportsAuthenticate();
  } catch (_) {
    supported = false;
  }
  if (!supported) {
    throw UnsupportedError('google_sign_in');
  }

  // [main] initialise déjà ; en cas d’échec silencieux ou hot restart, on réessaie ici
  // pour que `authenticate()` renvoie bien un idToken (Android / iOS / macOS).
  final webClientId = kGoogleOAuthWebClientId.trim();
  if (webClientId.isNotEmpty) {
    try {
      await GoogleSignIn.instance.initialize(serverClientId: webClientId);
    } catch (e, st) {
      debugPrint('[Paychek] GoogleSignIn.initialize before authenticate: $e\n$st');
    }
  }

  try {
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: const ['email', 'profile'],
    );
    final auth = account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      debugPrint(
        '[Paychek] Google Sign-In: idToken null — vérifie serverClientId (ID client OAuth Web) '
        'dans lib/reglage/social_auth_config.dart et google-services.json / GoogleService-Info.plist.',
      );
      throw StateError('google_web_client_id');
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return FirebaseAuth.instance.signInWithCredential(credential);
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled ||
        e.code == GoogleSignInExceptionCode.interrupted) {
      return null;
    }
    rethrow;
  }
}

/// Connexion Facebook → Firebase. Retourne `null` si l’utilisateur a annulé.
///
/// **Web** : [FirebaseAuth.signInWithPopup] (configure Facebook dans la console Firebase).
/// **Autres** : SDK `flutter_facebook_auth`.
Future<UserCredential?> signInWithFacebook() async {
  if (kIsWeb) {
    try {
      return await FirebaseAuth.instance
          .signInWithPopup(FacebookAuthProvider());
    } on FirebaseAuthException catch (e) {
      if (_isFirebaseWebPopupCancelled(e)) {
        return null;
      }
      rethrow;
    }
  }

  final result = await FacebookAuth.instance.login(
    permissions: const ['email', 'public_profile'],
  );
  switch (result.status) {
    case LoginStatus.cancelled:
    case LoginStatus.operationInProgress:
      return null;
    case LoginStatus.failed:
      throw StateError(result.message ?? 'facebook_login_failed');
    case LoginStatus.success:
      break;
  }
  final token = result.accessToken;
  if (token == null) {
    return null;
  }
  final credential = FacebookAuthProvider.credential(token.tokenString);
  return FirebaseAuth.instance.signInWithCredential(credential);
}

/// Apple → Firebase.
/// **Web** : popup Firebase.
/// **iOS / macOS** : [SignInWithApple.getAppleIDCredential] + OAuth.
/// **Android** : non branché ici (configuration spécifique) — l’appelant doit afficher un message.
Future<UserCredential?> signInWithApple() async {
  if (kIsWeb) {
    try {
      final provider = OAuthProvider('apple.com');
      return await FirebaseAuth.instance.signInWithPopup(provider);
    } on FirebaseAuthException catch (e) {
      if (_isFirebaseWebPopupCancelled(e)) {
        return null;
      }
      rethrow;
    }
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    throw StateError('apple_sign_in_use_google_android');
  }

  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.fuchsia) {
    throw StateError('apple_sign_in_unavailable_desktop');
  }

  if (defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.macOS) {
    throw UnsupportedError('apple_sign_in_native');
  }

  final available = await SignInWithApple.isAvailable();
  if (!available) {
    throw SignInWithAppleNotSupportedException(
      message: 'Sign in with Apple is not available on this OS version.',
    );
  }

  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final idToken = appleCredential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      debugPrint('[Paychek] Apple Sign-In: identityToken null');
      throw StateError('apple_no_id_token');
    }
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: idToken,
      accessToken: appleCredential.authorizationCode,
    );
    return FirebaseAuth.instance.signInWithCredential(oauthCredential);
  } on SignInWithAppleAuthorizationException catch (e) {
    if (e.code == AuthorizationErrorCode.canceled) {
      return null;
    }
    rethrow;
  }
}

/// Apple : Web (popup) + iOS/macOS natif. Android : bouton visible mais message côté UI si non supporté.
bool isAppleSignInAvailableOnThisPlatform() {
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.android:
      return true;
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return false;
  }
}

/// `true` si le bouton Google peut lancer le flux (plugin enregistré et [authenticate] supporté).
///
/// Sur Windows/Linux il n’y a pas d’implémentation `google_sign_in` : la plateforme par défaut
/// lève [UnimplementedError] — on renvoie `false` sans faire planter l’app.
bool isGoogleSignInAvailableOnThisPlatform() {
  if (kIsWeb) return true;
  try {
    return GoogleSignIn.instance.supportsAuthenticate();
  } catch (_) {
    return false;
  }
}

/// Facebook via `flutter_facebook_auth` : Android, iOS, Web, **macOS** (desktop).
/// Pas de plugin Windows/Linux → éviter d’ouvrir un flux voué à l’échec.
bool isFacebookSignInAvailableOnThisPlatform() {
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return false;
  }
}

/// Déconnexion Firebase + Google / Facebook pour que le prochain login ne réutilise pas la session SSO.
///
/// Les erreurs réseau / plugin sont **capturées** : l’effacement du profil en local doit quand même
/// s’exécuter ensuite (voir [ReglagePage]).
Future<void> signOutEverywhere() async {
  const netTimeout = Duration(seconds: 5);
  try {
    await FirebaseAuth.instance.signOut().timeout(netTimeout);
  } catch (e, st) {
    debugPrint('[Paychek] FirebaseAuth.signOut: $e\n$st');
  }
  // Sur le Web le SSO passe par Firebase (popup) : pas de SDK Google/Facebook à couper ici
  // (GoogleSignIn.signOut sur web peut rester bloqué → timeouts dans la console).
  if (!kIsWeb && isFacebookSignInAvailableOnThisPlatform()) {
    try {
      await FacebookAuth.instance.logOut().timeout(netTimeout);
    } catch (e, st) {
      debugPrint('[Paychek] FacebookAuth.logOut: $e\n$st');
    }
  }
  try {
    if (!kIsWeb && isGoogleSignInAvailableOnThisPlatform()) {
      await GoogleSignIn.instance.signOut().timeout(netTimeout);
    }
  } catch (e, st) {
    debugPrint('[Paychek] GoogleSignIn signOut: $e\n$st');
  }
}
