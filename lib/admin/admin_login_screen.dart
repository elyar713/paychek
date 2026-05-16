import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../reglage/social_auth_service.dart';
import 'admin_branding.dart';
import 'admin_theme.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AdminTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AdminTheme.border),
                  ),
                  child: const PaychekAdminLogoRow(),
                ),
                const SizedBox(height: 28),
                Text(
                  'Connexion',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Même projet Firebase que l’app Paychek (Auth + Firestore).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AdminTheme.card.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AdminTheme.border.withValues(alpha: 0.9),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comptes admin et app',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'La liste des profils (paychek_users) regroupe tous les utilisateurs '
                          'de l’app, identifiés par leur UID Firebase — ce n’est pas une fusion avec '
                          'l’admin : si tu ouvres Paychek avec le même compte Google que la console, '
                          'ta fiche apparaît aussi dans cette liste, comme n’importe quel client.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.45,
                                color: AdminTheme.textMuted,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'E-mail + mot de passe et Google (même adresse e-mail) sont souvent '
                          'deux comptes Firebase différents (deux UID) tant qu’ils ne sont pas '
                          'liés dans la console Firebase, section Authentication. Pour la superadmin : '
                          'le claim admin doit être posé sur l’UID avec lequel tu te connectes '
                          '(en pratique : ton compte Google si tu n’utilises plus le mot de passe).',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.45,
                                color: AdminTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enabled: !_busy,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _password,
                  obscureText: true,
                  enabled: !_busy,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _busy ? null : _sendPasswordReset,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _busy ? null : _signInEmail,
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminTheme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('Se connecter'),
                ),
                const SizedBox(height: 16),
                if (isGoogleSignInAvailableOnThisPlatform())
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _signInGoogle,
                    icon: const Icon(Icons.login, size: 20),
                    label: const Text('Google'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _snack(
        'Saisis ton adresse e-mail ci-dessus pour recevoir le lien.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _snack(
        'Si un compte existe pour cet e-mail, tu recevras un lien pour en définir un nouveau.',
      );
    } on FirebaseAuthException catch (e) {
      final code = e.code.trim().toLowerCase();
      if (code == 'user-not-found') {
        _snack(
          'Si un compte existe pour cet e-mail, tu recevras un lien pour en définir un nouveau.',
        );
      } else if (code == 'too-many-requests') {
        _snack('Trop de demandes. Réessaie dans quelques minutes.');
      } else if (code == 'invalid-email') {
        _snack('Adresse e-mail invalide');
      } else if (code == 'network-request-failed' ||
          code == 'web-context-cancelled') {
        _snack('Erreur réseau. Réessayez.');
      } else {
        _snack(e.message ?? e.code);
      }
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInEmail() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _snack('Saisis email et mot de passe.');
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _snack(e.message ?? e.code);
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() => _busy = true);
    try {
      await signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      _snack(e.message ?? e.code);
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
