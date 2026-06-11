import 'dart:async' show StreamSubscription, unawaited;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../auth/post_auth_gate.dart';
import '../reglage/app_locale_scope.dart';
import '../shared/paychek_boot_splash.dart';
import 'web_landing_auth_query_host.dart';
import 'web_landing_unauthenticated.dart';
import 'web_return_to_landing_stub.dart'
    if (dart.library.html) 'web_return_to_landing_web.dart';

/// Web :
/// - non connecté → landing HTML (`web/landing.html` dans une iframe) ;
/// - connecté → tableau de bord.
///
/// Les CTA auth de la page HTML envoient un `postMessage` JSON
/// `{ "type": "paychek-auth", "mode": "login"|"signup" }` pour ouvrir les modales Firebase.
/// Le menu langues envoie `{ "type": "paychek-locale", "code": "fr"|"en"|… }` (codes [ReglageLanguagePrefs.availableCodes]).
class WebAuthGate extends StatefulWidget {
  const WebAuthGate({super.key});

  @override
  State<WebAuthGate> createState() => _WebAuthGateState();
}

class _WebAuthGateState extends State<WebAuthGate> {
  bool _authReady = false;
  User? _user;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrapAuth());
  }

  static bool _isSignupAuthQuery(String? auth) {
    final a = auth?.toLowerCase().trim();
    return a == 'signup' || a == 'register' || a == 'inscription';
  }

  static bool _hasAuthIntentQuery() {
    final auth = Uri.base.queryParameters['auth']?.trim();
    return auth != null && auth.isNotEmpty;
  }

  /// Évite le flash landing → app quand Firebase Web restaure la session (null puis User).
  Future<void> _bootstrapAuth() async {
    final auth = FirebaseAuth.instance;
    final fastAuthIntent = _hasAuthIntentQuery();
    User? resolved = fastAuthIntent ? auth.currentUser : null;
    if (!fastAuthIntent) {
      resolved = await auth.authStateChanges().first;
      resolved ??= auth.currentUser;
    }
    if (resolved == null && !fastAuthIntent) {
      try {
        resolved = await auth
            .authStateChanges()
            .skip(1)
            .first
            .timeout(
              const Duration(milliseconds: 350),
              onTimeout: () => null,
            );
      } catch (_) {}
      resolved ??= auth.currentUser;
    }
    if (!mounted) return;
    setState(() {
      _user = resolved;
      _authReady = true;
    });
    _authSub = auth.authStateChanges().skip(1).listen((u) {
      if (!mounted) return;
      final wasSignedIn = _user != null;
      setState(() => _user = u);
      if (kIsWeb && wasSignedIn && u == null) {
        paychekReturnToLandingAfterLogout();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_authReady) {
      return const PaychekBootSplash();
    }
    final u = _user;
    if (u == null) {
      final auth = Uri.base.queryParameters['auth']?.toLowerCase().trim();
      final authOnly = auth != null && auth.isNotEmpty;
      if (authOnly) {
        return WebLandingAuthQueryHost(
          signup: _isSignupAuthQuery(auth),
        );
      }
      return Builder(
        builder: (dialogContext) => buildWebLandingUnauthenticated(
          dialogContext,
          (code) => AppLocaleScope.of(dialogContext).selectCode(code),
        ),
      );
    }
    return PostAuthGate(key: ValueKey(u.uid), user: u);
  }
}
