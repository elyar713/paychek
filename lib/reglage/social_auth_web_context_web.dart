// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async' show TimeoutException;
import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

bool _paychekWebOAuthRedirectInProgress = false;
bool _redirectResultConsumed = false;
UserCredential? _cachedRedirectCredential;
String? _paychekWebAuthRedirectStatusMessage;

String? get paychekWebAuthRedirectStatusMessage =>
    _paychekWebAuthRedirectStatusMessage;

bool paychekWebOAuthRedirectInProgress() => _paychekWebOAuthRedirectInProgress;

/// Redirect seulement en iframe ; fenêtre principale → popup (credential direct).
bool paychekWebSocialAuthPrefersRedirect() {
  try {
    if (Uri.base.queryParameters['overlay'] == '1') return true;
    if (html.window.parent != html.window) return true;
    return false;
  } catch (_) {
    return false;
  }
}

bool _urlLooksLikeOAuthReturn() {
  try {
    final href = html.window.location.href;
    final hash = html.window.location.hash;
    return href.contains('__/auth/') ||
        hash.contains('__/auth/') ||
        hash.contains('id_token') ||
        hash.contains('access_token');
  } catch (_) {
    return false;
  }
}

Future<UserCredential?> paychekWebPrimeFirebaseAuthRedirect() async {
  _paychekWebAuthRedirectStatusMessage = null;
  try {
    final result = await paychekWebCompleteRedirectSignInIfPending();
    if (result?.user != null || FirebaseAuth.instance.currentUser != null) {
      return result;
    }
    if (_urlLooksLikeOAuthReturn()) {
      _paychekWebAuthRedirectStatusMessage =
          'Google est revenu sur Paychek mais la session n’a pas été reprise. '
          'Videz les données du site (F12 → Application → Clear site data) puis réessayez.';
      debugPrint('[Paychek] OAuth return URL but no Firebase user');
    }
    return result;
  } on FirebaseAuthException catch (e) {
    _paychekWebAuthRedirectStatusMessage = '${e.code}: ${e.message}';
    rethrow;
  }
}

Future<UserCredential?> paychekWebCompleteRedirectSignInIfPending() async {
  if (_redirectResultConsumed) {
    return _cachedRedirectCredential;
  }
  _redirectResultConsumed = true;
  try {
    final result = await FirebaseAuth.instance.getRedirectResult().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('[Paychek] getRedirectResult timeout');
        throw TimeoutException('getRedirectResult');
      },
    );
    final user = result.user;
    if (user != null) {
      debugPrint('[Paychek] Web redirect sign-in OK uid=${user.uid}');
      _cachedRedirectCredential = result;
      return result;
    }
    _cachedRedirectCredential = null;
    return null;
  } on FirebaseAuthException catch (e) {
    debugPrint(
      '[Paychek] Web redirect sign-in error: ${e.code} ${e.message}',
    );
    rethrow;
  } on TimeoutException {
    _cachedRedirectCredential = null;
    return null;
  }
}

Future<void> paychekWebSignInWithRedirect(AuthProvider provider) async {
  _paychekWebOAuthRedirectInProgress = true;
  _redirectResultConsumed = false;
  _cachedRedirectCredential = null;
  await FirebaseAuth.instance.signInWithRedirect(provider);
}
