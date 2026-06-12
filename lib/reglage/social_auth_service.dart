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

/// Connexion Google → Firebase. Retourne `null` si l’utilisateur a annulé.
Future<UserCredential?> signInWithGoogle() async {
  if (kIsWeb) {
    return _webSignInWithAuthProvider(GoogleAuthProvider());
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
  if (kIsWeb) {
    return _signInWithAppleOAuthServicesFlow(kPaychekAppleWebServicesIdForAuth);
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
    // Mismatch audience : Firebase attend le Services ID OAuth, pas le Bundle ID.
    if (_isAppleAudienceMismatch(e) && servicesId.isNotEmpty) {
      debugPrint('[Paychek] Apple native audience mismatch → OAuth Services ID flow');
      return _signInWithAppleOAuthServicesFlow(servicesId);
    }
    debugPrint(
      '[Paychek] Apple Sign-In FirebaseAuthException: ${e.code} ${e.message}',
    );
    rethrow;
  }
}

bool isAppleSignInAvailableOnThisPlatform() {
  // Web : désactivé tant que Firebase reste sur pro.paychek.app (build iOS en revue).
  // Réactiver après App Store + Firebase aligné sur pro.paychek.signin.
  if (kIsWeb) return false;
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
  try {
    if (!kIsWeb && isGoogleSignInAvailableOnThisPlatform()) {
      await GoogleSignIn.instance.signOut().timeout(netTimeout);
    }
  } catch (e, st) {
    debugPrint('[Paychek] GoogleSignIn signOut: $e\n$st');
  }
}
