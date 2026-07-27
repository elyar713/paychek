import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'social_auth_config.dart';
import 'social_auth_web_context_stub.dart'
    if (dart.library.html) 'social_auth_web_context_web.dart';

bool _isFirebaseWebPopupCancelled(FirebaseAuthException e) {
  final c = e.code.toLowerCase();
  return c.contains('popup-closed-by-user') ||
      c.contains('cancelled-popup-request') ||
      c == 'web-context-cancelled';
}

bool _isAppleAudienceMismatch(FirebaseAuthException e) {
  final msg = '${e.code} ${e.message}'.toLowerCase();
  return msg.contains('audience') && msg.contains('id token');
}

String _generateAppleSignInNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(
    length,
    (_) => charset[random.nextInt(charset.length)],
  ).join();
}

String _sha256NonceForApple(String input) {
  return sha256.convert(utf8.encode(input)).toString();
}

bool _isFirebaseWebPopupBlocked(FirebaseAuthException e) {
  final c = e.code.toLowerCase();
  return c.contains('popup-blocked') || c.contains('popup-closed');
}

/// Firebase Auth web : redirect (prod / iframe) ou popup (localhost).
Future<UserCredential?> _webSignInWithAuthProvider(AuthProvider provider) async {
  if (paychekWebSocialAuthPrefersRedirect()) {
    await paychekWebSignInWithRedirect(provider);
    return null;
  }
  try {
    return await FirebaseAuth.instance.signInWithPopup(provider);
  } on FirebaseAuthException catch (e) {
    if (_isFirebaseWebPopupCancelled(e)) {
      return null;
    }
    if (_isFirebaseWebPopupBlocked(e)) {
      await paychekWebSignInWithRedirect(provider);
      return null;
    }
    rethrow;
  }
}

Completer<void>? _googleInitCompleter;

/// Initialise Google Sign-In une seule fois (évite les échecs « déjà init » / idToken null).
Future<void> ensureGoogleSignInInitialized() async {
  if (kIsWeb) return;
  if (!isGoogleSignInAvailableOnThisPlatform()) return;

  final existing = _googleInitCompleter;
  if (existing != null) {
    await existing.future;
    return;
  }
  final c = Completer<void>();
  _googleInitCompleter = c;
  try {
    final webClientId = kGoogleOAuthWebClientId.trim();
    await GoogleSignIn.instance.initialize(
      serverClientId: webClientId.isNotEmpty ? webClientId : null,
    );
    c.complete();
  } catch (e, st) {
    _googleInitCompleter = null;
    c.completeError(e, st);
    rethrow;
  }
}

Future<UserCredential?> _firebaseFromGoogleAccount(GoogleSignInAccount account) async {
  final idToken = account.authentication.idToken;
  if (idToken == null || idToken.isEmpty) {
    debugPrint(
      '[Paychek] Google Sign-In: idToken null — vérifie serverClientId (ID client OAuth Web) '
      'dans lib/reglage/social_auth_config.dart et google-services.json / GoogleService-Info.plist.',
    );
    throw StateError('google_web_client_id');
  }
  final credential = GoogleAuthProvider.credential(idToken: idToken);
  return FirebaseAuth.instance.signInWithCredential(credential);
}

/// Ancienne restauration One Tap — désactivée (ouvrait le sélecteur Google de force).
/// La session Firebase Auth native suffit au démarrage.
Future<bool> paychekTryRestoreGoogleFirebaseSession() async {
  return false;
}

/// Connexion Google → Firebase. Retourne `null` si l’utilisateur a annulé.
///
/// N’appelle **jamais** One Tap / restore automatique : uniquement sur action
/// utilisateur (bouton Google).
Future<UserCredential?> signInWithGoogle() async {
  if (kIsWeb) {
    return _webSignInWithAuthProvider(GoogleAuthProvider());
  }

  if (!isGoogleSignInAvailableOnThisPlatform()) {
    throw UnsupportedError('google_sign_in');
  }

  await ensureGoogleSignInInitialized();

  Future<GoogleSignInAccount> authenticateOnce() {
    return GoogleSignIn.instance.authenticate(
      scopeHint: const ['email', 'profile'],
    );
  }

  try {
    GoogleSignInAccount account;
    try {
      account = await authenticateOnce();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw StateError('google_android_sha1');
      }
      debugPrint(
        '[Paychek] Google authenticate failed (${e.code} ${e.description}), '
        'signOut + retry…',
      );
      try {
        await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 3));
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 250));
      try {
        account = await authenticateOnce();
      } on GoogleSignInException catch (e2) {
        if (e2.code == GoogleSignInExceptionCode.canceled ||
            e2.code == GoogleSignInExceptionCode.interrupted) {
          return null;
        }
        if (e2.code == GoogleSignInExceptionCode.clientConfigurationError ||
            e2.code == GoogleSignInExceptionCode.providerConfigurationError) {
          throw StateError('google_android_sha1');
        }
        return _signInWithGoogleFirebaseProvider(cause: e2);
      }
    }

    try {
      return await _firebaseFromGoogleAccount(account);
    } on StateError catch (e) {
      if (e.message != 'google_web_client_id') rethrow;
      return _signInWithGoogleFirebaseProvider(cause: e);
    }
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled ||
        e.code == GoogleSignInExceptionCode.interrupted) {
      return null;
    }
    if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
        e.code == GoogleSignInExceptionCode.providerConfigurationError) {
      throw StateError('google_android_sha1');
    }
    rethrow;
  }
}

/// Fallback Android : [FirebaseAuth.signInWithProvider] (ne dépend pas du plugin
/// `google_sign_in` pour le picker). SHA-1 Firebase toujours requis.
Future<UserCredential?> _signInWithGoogleFirebaseProvider({Object? cause}) async {
  debugPrint(
    '[Paychek] Google plugin path failed ($cause) → Firebase signInWithProvider',
  );
  try {
    final provider = GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');
    return await FirebaseAuth.instance.signInWithProvider(provider);
  } on FirebaseAuthException catch (e) {
    if (_isFirebaseWebPopupCancelled(e)) return null;
    final code = e.code.toLowerCase();
    if (code.contains('canceled') ||
        code.contains('cancelled') ||
        code.contains('web-context-cancelled')) {
      return null;
    }
    // Erreur typique SHA-1 manquant / mauvais client OAuth.
    if (code.contains('developer') ||
        code.contains('invalid-credential') ||
        code.contains('internal-error') ||
        '${e.message}'.toLowerCase().contains('error 10') ||
        '${e.message}'.toLowerCase().contains('12500')) {
      throw StateError('google_android_sha1');
    }
    rethrow;
  }
}

Future<void> ensurePaychekFacebookWebSdkInitialized() async {
  if (!kIsWeb) return;
  if (FacebookAuth.instance.isWebSdkInitialized) return;
  await FacebookAuth.instance.webAndDesktopInitialize(
    appId: kPaychekFacebookAppId,
    cookie: true,
    xfbml: true,
    version: 'v19.0',
  );
}

Future<UserCredential?> signInWithFacebook() async {
  if (kIsWeb) {
    await ensurePaychekFacebookWebSdkInitialized();
    if (!FacebookAuth.instance.isWebSdkInitialized) {
      throw StateError(
        'facebook_web_sdk_not_initialized: Meta → Facebook Login → '
        '« Se connecter avec le SDK JavaScript » = Oui, domaine paychek.pro',
      );
    }
  }

  final result = await FacebookAuth.instance.login(
    permissions: const ['email', 'public_profile'],
    loginTracking: kIsWeb ? LoginTracking.enabled : LoginTracking.limited,
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

/// Flux OAuth Apple via **Services ID** Firebase (audience du jeton = Services ID).
Future<UserCredential?> _signInWithAppleOAuthServicesFlow(String servicesId) async {
  final available = await SignInWithApple.isAvailable();
  if (!available) {
    throw SignInWithAppleNotSupportedException(
      message: 'Sign in with Apple is not available on this OS version.',
    );
  }

  final rawNonce = _generateAppleSignInNonce();
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: _sha256NonceForApple(rawNonce),
    webAuthenticationOptions: WebAuthenticationOptions(
      clientId: servicesId,
      redirectUri: Uri.parse(kPaychekFirebaseAppleRedirectUri),
    ),
  );
  final idToken = appleCredential.identityToken;
  if (idToken == null || idToken.isEmpty) {
    throw StateError('apple_no_id_token');
  }
  final oauthCredential = OAuthProvider('apple.com').credential(
    idToken: idToken,
    rawNonce: rawNonce,
    accessToken: appleCredential.authorizationCode,
  );
  final cred = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  debugPrint(
    '[Paychek] Apple OAuth Services ID flow OK uid=${cred.user?.uid} servicesId=$servicesId',
  );
  return cred;
}

/// Flux natif iOS (audience jeton = Bundle ID `pro.paychek.app`).
Future<UserCredential?> _signInWithAppleNativeProvider() async {
  final provider = AppleAuthProvider();
  provider.addScope('email');
  provider.addScope('name');
  final cred = await FirebaseAuth.instance.signInWithProvider(provider);
  debugPrint('[Paychek] Apple native provider OK uid=${cred.user?.uid}');
  return cred;
}

/// Apple → Firebase.
Future<UserCredential?> signInWithApple() async {
  // Web : même chemin que Google (Firebase popup / redirect).
  // Le package sign_in_with_apple + AppleID.auth.popup avec redirectUri =
  // Firebase handler casse le retour popup (« Invalid client id or web redirect url »).
  if (kIsWeb) {
    final provider = AppleAuthProvider();
    provider.addScope('email');
    provider.addScope('name');
    try {
      return await _webSignInWithAuthProvider(provider);
    } on FirebaseAuthException catch (e) {
      if (_isFirebaseWebPopupCancelled(e)) return null;
      debugPrint(
        '[Paychek] Apple web FirebaseAuthException: ${e.code} ${e.message}',
      );
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

  // Firebase n’a qu’un seul « Services ID » pour web + mobile.
  // On utilise toujours le Services ID OAuth (`pro.paychek.signin`) sur iOS/macOS
  // pour que Firebase puisse rester sur cette valeur (requis pour le web).
  // Flux natif Bundle ID uniquement si Firebase est encore sur `pro.paychek.app`.
  final servicesId = kPaychekAppleFirebaseServicesId.trim();
  final useOAuthServicesFlow = servicesId.isNotEmpty &&
      servicesId != kPaychekIosBundleId;

  try {
    if (useOAuthServicesFlow) {
      return await _signInWithAppleOAuthServicesFlow(servicesId);
    }
    return await _signInWithAppleNativeProvider();
  } on SignInWithAppleAuthorizationException catch (e) {
    if (e.code == AuthorizationErrorCode.canceled) {
      return null;
    }
    rethrow;
  } on FirebaseAuthException catch (e) {
    if (_isFirebaseWebPopupCancelled(e)) {
      return null;
    }
    // Ancien Firebase = Bundle ID → natif OK ; nouveau = Services ID → OAuth.
    if (_isAppleAudienceMismatch(e)) {
      final oauthId = kPaychekAppleWebServicesIdForAuth;
      debugPrint(
        '[Paychek] Apple audience mismatch → OAuth Services ID $oauthId',
      );
      return _signInWithAppleOAuthServicesFlow(oauthId);
    }
    debugPrint(
      '[Paychek] Apple Sign-In FirebaseAuthException: ${e.code} ${e.message}',
    );
    rethrow;
  }
}

bool isAppleSignInAvailableOnThisPlatform() {
  // Web : Services ID `pro.paychek.signin` + return URL Firebase handler.
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

bool isGoogleSignInAvailableOnThisPlatform() {
  if (kIsWeb) return true;
  try {
    return GoogleSignIn.instance.supportsAuthenticate();
  } catch (_) {
    return false;
  }
}

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

Future<void> signOutEverywhere() async {
  const netTimeout = Duration(seconds: 5);
  try {
    await FirebaseAuth.instance.signOut().timeout(netTimeout);
  } catch (e, st) {
    debugPrint('[Paychek] FirebaseAuth.signOut: $e\n$st');
  }
  if (isFacebookSignInAvailableOnThisPlatform()) {
    try {
      await FacebookAuth.instance.logOut().timeout(netTimeout);
    } catch (e, st) {
      debugPrint('[Paychek] FacebookAuth.logOut: $e\n$st');
    }
  }
  // Déconnexion Google pour ne pas auto-reconnecter un autre utilisateur sur l’appareil.
  try {
    if (!kIsWeb && isGoogleSignInAvailableOnThisPlatform()) {
      await ensureGoogleSignInInitialized();
      await GoogleSignIn.instance.signOut().timeout(netTimeout);
    }
  } catch (e, st) {
    debugPrint('[Paychek] GoogleSignIn signOut: $e\n$st');
  }
}

/// Alias explicite (suppression de compte).
Future<void> signOutGoogleCompletely() async {
  if (kIsWeb || !isGoogleSignInAvailableOnThisPlatform()) return;
  try {
    await ensureGoogleSignInInitialized();
    await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 5));
  } catch (e, st) {
    debugPrint('[Paychek] GoogleSignIn signOut: $e\n$st');
  }
}
