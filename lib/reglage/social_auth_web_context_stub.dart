import 'package:firebase_auth/firebase_auth.dart';

bool paychekWebSocialAuthPrefersRedirect() => false;

bool paychekWebOAuthRedirectInProgress() => false;

String? get paychekWebAuthRedirectStatusMessage => null;

Future<UserCredential?> paychekWebPrimeFirebaseAuthRedirect() async => null;

Future<UserCredential?> paychekWebCompleteRedirectSignInIfPending() async =>
    null;

Future<void> paychekWebSignInWithRedirect(AuthProvider provider) async {}
