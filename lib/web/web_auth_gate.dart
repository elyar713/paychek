import 'dart:async' show StreamSubscription, unawaited;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

import '../auth/post_auth_gate.dart';
import '../questionnaire/questionnaire_completion_prefs.dart';
import '../reglage/app_locale_scope.dart';
import '../reglage/social_auth_web_context_stub.dart'
    if (dart.library.html) '../reglage/social_auth_web_context_web.dart';
import '../shared/paychek_boot_splash.dart';
import '../trade/journal_demo_notice_prefs.dart';
import 'paychek_web_hide_auth_boot_stub.dart'
    if (dart.library.html) 'paychek_web_hide_auth_boot_web.dart';
import 'web_landing_auth_query_host.dart';
import 'web_landing_unauthenticated.dart';
import 'web_return_to_landing_stub.dart'
    if (dart.library.html) 'web_return_to_landing_web.dart';

/// Web : landing HTML si déconnecté, app si session Firebase active.
class WebAuthGate extends StatefulWidget {
  const WebAuthGate({super.key});

  @override
  State<WebAuthGate> createState() => _WebAuthGateState();
}

class _WebAuthGateState extends State<WebAuthGate> {
  bool _bootDone = false;
  String? _webOAuthBootstrapError;
  StreamSubscription<User?>? _authSub;
  User? _lastSignedInUser;

  @override
  void initState() {
    super.initState();
    unawaited(_boot());
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  static bool _isSignupAuthQuery(String? auth) {
    final a = auth?.toLowerCase().trim();
    return a == 'signup' || a == 'register' || a == 'inscription';
  }

  static bool _hasAuthIntentQuery() {
    final auth = Uri.base.queryParameters['auth']?.trim();
    return auth != null && auth.isNotEmpty;
  }

  static String _formatWebOAuthError(FirebaseAuthException e) {
    final msg = e.message?.trim();
    final base = msg != null && msg.isNotEmpty
        ? '${e.code}: $msg'
        : e.code;
    if (e.code == 'auth/unauthorized-domain') {
      return '$base\n\nAjoutez paychek.pro dans Firebase → Authentication → Settings → Authorized domains.';
    }
    return base;
  }

  Future<void> _markNewUserIfNeeded(UserCredential? cred) async {
    final user = cred?.user;
    if (user == null) return;
    if (cred?.additionalUserInfo?.isNewUser != true) return;
    final uid = user.uid;
    await QuestionnaireCompletionPrefs.markIncomplete(uid);
    await JournalDemoNoticePrefs.markPendingAfterSignup(uid);
  }

  Future<void> _boot() async {
    try {
      if (kIsWeb) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          paychekHideAuthBootLoader();
        });
        try {
          final redirectCred = await paychekWebCompleteRedirectSignInIfPending();
          final user = redirectCred?.user ?? FirebaseAuth.instance.currentUser;
          if (user != null) {
            _lastSignedInUser = user;
            await _markNewUserIfNeeded(redirectCred);
            if (paychekIsAuthOverlayFrame()) {
              paychekCompleteAuthOverlaySuccess();
            } else if (_hasAuthIntentQuery()) {
              paychekStripAuthQueryFromUrl();
            }
          }
        } on FirebaseAuthException catch (e) {
          debugPrint('[Paychek] Web redirect resume: ${e.code} ${e.message}');
          _webOAuthBootstrapError = _formatWebOAuthError(e);
        }
      }
      _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthUser);
    } catch (e, st) {
      debugPrint('[Paychek] WebAuthGate boot error: $e\n$st');
    } finally {
      if (mounted) {
        setState(() => _bootDone = true);
      }
    }
  }

  void _onAuthUser(User? user) {
    if (!mounted) return;
    final wasSignedIn = _lastSignedInUser != null;
    _lastSignedInUser = user;
    if (user != null) {
      if (kIsWeb && _hasAuthIntentQuery()) {
        paychekStripAuthQueryFromUrl();
      }
      setState(() {});
      return;
    }
    if (kIsWeb && wasSignedIn) {
      paychekReturnToLandingAfterLogout();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootDone) {
      return const PaychekBootSplash();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snap) {
        final user = snap.data ?? FirebaseAuth.instance.currentUser;
        if (user != null) {
          return PostAuthGate(key: ValueKey(user.uid), user: user);
        }

        final auth = Uri.base.queryParameters['auth']?.toLowerCase().trim();
        final authOnly = auth != null && auth.isNotEmpty;
        if (authOnly) {
          return WebLandingAuthQueryHost(
            signup: _isSignupAuthQuery(auth),
            oauthError:
                _webOAuthBootstrapError ?? paychekWebAuthRedirectStatusMessage,
          );
        }

        return Builder(
          builder: (dialogContext) => buildWebLandingUnauthenticated(
            dialogContext,
            (code) => AppLocaleScope.of(dialogContext).selectCode(code),
          ),
        );
      },
    );
  }
}
