import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'admin_theme.dart';

/// Profil staff stocké par UID admin (claim `admin`). Chemin aligné sur [firestore.rules].
const String kPaychekAdminProfilesCollection = 'paychek_admin_profiles';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _roleTitleCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  DocumentReference<Map<String, dynamic>>? _ref;

  InputDecoration _inputDeco(BuildContext context, String label, {String? hint}) {
    final borderColor = AdminTheme.border;
    final fill = AdminTheme.bg;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: fill,
      labelStyle:
          Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminTheme.textMuted),
      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AdminTheme.textDim,
          ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AdminTheme.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _smallCapsHeader(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: AdminTheme.textMuted,
      ),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _roleTitleCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      setState(() {
        _loading = false;
        _error = 'Session expirée — reconnecte-toi.';
      });
      return;
    }
    _ref = FirebaseFirestore.instance
        .collection(kPaychekAdminProfilesCollection)
        .doc(u.uid);

    try {
      await u.getIdToken(true);
      final snap = await _ref!.get();
      if (snap.exists) {
        final d = snap.data() ?? {};
        _firstNameCtrl.text = '${d['firstName'] ?? ''}'.trim();
        _lastNameCtrl.text = '${d['lastName'] ?? ''}'.trim();
        _roleTitleCtrl.text = '${d['roleTitle'] ?? ''}'.trim();
        _phoneCtrl.text = '${d['phone'] ?? ''}'.trim();
      } else {
        _prefillFromAuthDisplay(u);
      }
      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  void _prefillFromAuthDisplay(User u) {
    final dn = u.displayName?.trim();
    if (dn == null || dn.isEmpty) return;
    final parts =
        dn.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      _firstNameCtrl.text = parts.first;
      _lastNameCtrl.text = parts.sublist(1).join(' ');
    } else {
      _firstNameCtrl.text = dn;
    }
  }

  Future<void> _save() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null || _ref == null) return;
    setState(() => _saving = true);

    try {
      await u.getIdToken(true);
      final fn = _firstNameCtrl.text.trim();
      final ln = _lastNameCtrl.text.trim();
      final merged = '$fn $ln'.trim();

      await _ref!.set(<String, dynamic>{
        'firstName': fn,
        'lastName': ln,
        'roleTitle': _roleTitleCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': u.email?.trim() ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final dn = merged.isNotEmpty ? merged : null;
      if (dn != null && dn != u.displayName?.trim()) {
        await u.updateDisplayName(dn);
      }

      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Profil enregistré')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _updatedFooter() {
    if (_ref == null) return const SizedBox.shrink();
    final df =
        DateFormat.yMMMMd('fr_FR').add_Hm();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _ref!.snapshots(),
      builder: (context, snap) {
        final ts = snap.data?.data()?['updatedAt'];
        final text = ts is Timestamp
            ? df.format(ts.toDate().toLocal())
            : '—';
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Dernière mise à jour : $text',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AdminTheme.textDim,
                  ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    final email = (u?.email ?? '').trim();

    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Retour',
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      'Profil administrateur',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AdminTheme.accent),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AdminTheme.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AdminTheme.border,
                                width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.fromLTRB(
                              26,
                              28,
                              26,
                              24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: SelectableText(
                                      _error!,
                                      style: TextStyle(
                                        color: AdminTheme.warning,
                                      ),
                                    ),
                                  ),
                                _smallCapsHeader(
                                  'e-mail firebase (session)',
                                ),
                                const SizedBox(height: 8),
                                SelectableText(
                                  email.isEmpty ? '—' : email,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Le rôle admin est défini dans Firebase '
                                  '(custom claim « admin ») — '
                                  'non modifiable depuis cette console.',
                                  style:
                                      Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AdminTheme.textMuted,
                                            height: 1.42,
                                          ),
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(999),
                                      color:
                                          AdminTheme.accent.withValues(alpha: 0.18),
                                      border: Border.all(
                                        color: AdminTheme.accent.withValues(alpha: 0.55),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: 18,
                                          color: AdminTheme.accent,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Administrateur actif',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: AdminTheme.accent,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                TextField(
                                  controller: _firstNameCtrl,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: _inputDeco(
                                    context,
                                    'Prénom',
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _lastNameCtrl,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: _inputDeco(context, 'Nom'),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _roleTitleCtrl,
                                  decoration: _inputDeco(
                                    context,
                                    'Fonction / statut (interne)',
                                    hint: 'Ex: Directeur technique',
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  decoration: _inputDeco(
                                    context,
                                    'Téléphone (facultatif)',
                                    hint: '+33 6 00 00 00 00',
                                  ),
                                ),
                                const SizedBox(height: 28),
                                FilledButton.icon(
                                  onPressed: _saving ? null : _save,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AdminTheme.accent,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: _saving
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black.withValues(alpha: 0.7),
                                          ),
                                        )
                                      : const Icon(Icons.save_outlined),
                                  label: const Text(
                                    'Enregistrer le profil',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                _updatedFooter(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
