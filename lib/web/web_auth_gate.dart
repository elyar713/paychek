import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../auth/post_auth_gate.dart';
import '../reglage/app_locale_scope.dart';
import 'web_landing_auth_dialogs.dart';
import 'web_landing_unauthenticated.dart';
import '../shared/paychek_frame_callbacks.dart';

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
  bool _openedUrlAuth = false;

  @override
  void initState() {
    super.initState();
    PaychekFrameCallbacks.runPostFrame(() {
      if (!mounted || !kIsWeb || _openedUrlAuth) return;
      final auth = Uri.base.queryParameters['auth']?.toLowerCase().trim();
      if (auth == null) return;
      _openedUrlAuth = true;
      if (auth == 'signup' || auth == 'register' || auth == 'inscription') {
        showWebLandingSignupDialog(context);
      } else if (auth == 'login' || auth == 'signin' || auth == 'connexion') {
        showWebLandingLoginDialog(context);
      }
    }, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final u = snap.data ?? FirebaseAuth.instance.currentUser;
        if (u == null) {
          // Contexte sous le [Navigator] de [MaterialApp] pour [showDialog].
          return Builder(
            builder: (dialogContext) => buildWebLandingUnauthenticated(
              dialogContext,
              (code) => AppLocaleScope.of(dialogContext).selectCode(code),
            ),
          );
        }
        return PostAuthGate(key: ValueKey(u.uid), user: u);
      },
    );
  }
}
