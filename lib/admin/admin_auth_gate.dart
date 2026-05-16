import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_branding.dart';
import 'admin_login_screen.dart';
import 'admin_shell.dart';
import 'admin_theme.dart';

/// N’ouvre le shell qu’avec un compte Firebase dont le **custom claim** `admin` est `true`.
///
/// Définir le claim (une fois) avec le Admin SDK Node :  
/// `admin.auth().setCustomUserClaims(uid, { admin: true })`
class AdminAuthGate extends StatelessWidget {
  const AdminAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _AdminBootScaffold();
        }
        final user = snap.data;
        if (user == null) {
          return const AdminLoginScreen();
        }
        return FutureBuilder<bool>(
          future: _tokenHasAdminClaim(user),
          builder: (context, adminSnap) {
            if (adminSnap.connectionState != ConnectionState.done) {
              return const _AdminBootScaffold();
            }
            if (adminSnap.data != true) {
              return _AdminForbiddenScreen(email: user.email);
            }
            return const AdminShell();
          },
        );
      },
    );
  }

  static Future<bool> _tokenHasAdminClaim(User user) async {
    final t = await user.getIdTokenResult(true);
    return t.claims?['admin'] == true;
  }
}

class _AdminBootScaffold extends StatelessWidget {
  const _AdminBootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AdminTheme.accent,
          ),
        ),
      ),
    );
  }
}

class _AdminForbiddenScreen extends StatelessWidget {
  const _AdminForbiddenScreen({this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PaychekAdminLogoRow(compact: true),
                const SizedBox(height: 24),
                const Icon(Icons.lock_outline, size: 48, color: AdminTheme.textMuted),
                const SizedBox(height: 16),
                Text(
                  'Accès refusé',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  email != null
                      ? 'Le compte « $email » n’a pas le rôle admin '
                          '(claim Firebase `admin`).'
                      : 'Compte sans rôle admin.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AdminTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Attribue le claim avec Firebase Admin SDK puis reconnecte-toi.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminTheme.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Changer de compte'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
