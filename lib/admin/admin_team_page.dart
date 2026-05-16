import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_staff_admin_cloud.dart';
import 'admin_superadmin_gate.dart';
import 'admin_theme.dart';

/// Visible uniquement pour [paychekIsSuperadminFirebaseUser] : attribution du claim Firebase `admin`.
class AdminTeamPage extends StatefulWidget {
  const AdminTeamPage({super.key});

  @override
  State<AdminTeamPage> createState() => _AdminTeamPageState();
}

class _AdminTeamPageState extends State<AdminTeamPage> {
  final _emailCtrl = TextEditingController();
  final _seedFirstCtrl = TextEditingController();
  final _seedLastCtrl = TextEditingController();
  final _seedRoleCtrl = TextEditingController();
  final _seedPhoneCtrl = TextEditingController();

  bool _busy = false;
  bool _seedProfileExpanded = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _seedFirstCtrl.dispose();
    _seedLastCtrl.dispose();
    _seedRoleCtrl.dispose();
    _seedPhoneCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDeco(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminTheme.accent, width: 1.6),
        ),
      );

  Future<void> _run(bool grant) async {
    final email = _emailCtrl.text.trim().toLowerCase();
    if (!email.contains('@')) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Entre une adresse e-mail valide.')),
      );
      return;
    }

    final me = FirebaseAuth.instance.currentUser;
    if (!paychekIsSuperadminFirebaseUser(me)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Accès réservé au super-admin.')),
      );
      return;
    }

    PaychekStaffAdminSeedProfile? seed;
    if (grant &&
        (_seedFirstCtrl.text.trim().isNotEmpty ||
            _seedLastCtrl.text.trim().isNotEmpty ||
            _seedRoleCtrl.text.trim().isNotEmpty ||
            _seedPhoneCtrl.text.trim().isNotEmpty)) {
      seed = PaychekStaffAdminSeedProfile(
        firstName: _seedFirstCtrl.text,
        lastName: _seedLastCtrl.text,
        roleTitle: _seedRoleCtrl.text,
        phone: _seedPhoneCtrl.text,
      );
    }

    setState(() => _busy = true);
    try {
      final result = await paychekCallableManageStaffAdmin(
        targetEmailTrimmed: email,
        grant: grant,
        seedProfile: seed,
      );
      if (!mounted) return;

      final err = result.userFacingError;
      if (!result.ok || err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText(err ?? 'Erreur inconnue.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            grant
                ? 'Administrateur ajouté. La personne doit se déconnecter puis se reconnecter pour activer la console.'
                : 'Administrateur révoqué. La personne doit se déconnecter : le claim est retiré du jeton courant après reconnexion.',
          ),
          duration: const Duration(seconds: 10),
        ),
      );
      if (grant && email == me?.email?.trim().toLowerCase()) {
        await me?.reload();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    final isSuper = paychekIsSuperadminFirebaseUser(me);

    if (!isSuper) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 56, color: AdminTheme.warning),
              const SizedBox(height: 16),
              SelectableText(
                'Tu n’as pas accès au super-administrateur (e-mail hors liste configurée).\n'
                'Les comptes supplémentaires ne peuvent pas ouvrir cette page.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Accorder ou retirer le rôle « administrateur » Firebase (claim « admin ») pour que '
                'un collègue puisse répondre aux tickets dans cette console.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AdminTheme.textMuted,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Le compte cible doit déjà exister dans Firebase Authentication '
                '(inscription depuis l’app ou ajout manuel dans la console).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.textMuted,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: _fieldDeco(
                  'E-mail du futur administrateur',
                  hint: 'collegue@exemple.com',
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  initiallyExpanded: _seedProfileExpanded,
                  onExpansionChanged: (v) =>
                      setState(() => _seedProfileExpanded = v),
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'Profil Firestore initial (facultatif)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                  ),
                  subtitle: Text(
                    'Si tu renseignes au moins un champ, une entrée sera créée dans '
                    '`paychek_admin_profiles` et le Display Name Firebase peut être mis à jour.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AdminTheme.textMuted,
                          height: 1.35,
                        ),
                  ),
                  childrenPadding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 14),
                    TextField(
                      controller: _seedFirstCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration:
                          _fieldDeco('Prénom'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _seedLastCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: _fieldDeco('Nom'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _seedRoleCtrl,
                      decoration: _fieldDeco(
                        'Fonction / statut (interne)',
                        hint: 'Ex : responsable relation clientèle',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _seedPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _fieldDeco(
                        'Téléphone (facultatif)',
                        hint: '+33 6 00 00 00 00',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _busy ? null : () => _run(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AdminTheme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    icon: _busy
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          )
                        : const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Accorder l’admin'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _run(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminTheme.warning,
                      side: BorderSide(color: AdminTheme.warning.withValues(alpha: 0.85)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    icon: const Icon(Icons.person_off_outlined),
                    label: const Text('Révoquer l’admin'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Super-admins configurés dans le code (liste blanche)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AdminTheme.liveBlue,
                    ),
              ),
              const SizedBox(height: 8),
              ...kPaychekSuperadminEmailsLowercase.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SelectableText(
                    '· $e',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pour ajouter une autre adresse « super », modifie en parallèle '
                '`kPaychekSuperadminEmailsLowercase` dans `lib/admin/admin_superadmin_gate.dart` '
                'et `PAYCHEK_SUPERADMIN_EMAILS` dans `functions/index.js`, puis redéploie les Functions.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.textDim,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
