import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'admin_layout.dart';
import 'admin_safeguard_licenses.dart';
import 'admin_theme.dart';

/// Console admin — licences Paychek Safeguard (desktop NinjaTrader).
class AdminSafeguardPage extends StatefulWidget {
  const AdminSafeguardPage({super.key});

  @override
  State<AdminSafeguardPage> createState() => _AdminSafeguardPageState();
}

class _AdminSafeguardPageState extends State<AdminSafeguardPage> {
  final _noteCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _customDaysCtrl = TextEditingController();

  List<SafeguardLicense> _licenses = [];
  Object? _error;
  bool _loading = true;
  bool _minting = false;
  int _maxActivations = 1;
  int? _validityDays = 365;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _emailCtrl.dispose();
    _searchCtrl.dispose();
    _customDaysCtrl.dispose();
    super.dispose();
  }

  int get _resolvedValidityDays {
    if (_validityDays != null) return _validityDays!;
    final parsed = int.tryParse(_customDaysCtrl.text.trim());
    if (parsed == null || parsed < 1) return 365;
    return parsed;
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await fetchSafeguardLicenses();
      if (!mounted) return;
      setState(() {
        _licenses = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  List<SafeguardLicense> get _filtered {
    final q = _searchCtrl.text.trim().toUpperCase();
    if (q.isEmpty) return _licenses;
    return _licenses.where((l) {
      return l.key.contains(q) ||
          l.note.toUpperCase().contains(q) ||
          (l.userEmail ?? '').toUpperCase().contains(q) ||
          l.createdByEmail.toUpperCase().contains(q);
    }).toList();
  }

  List<SafeguardLicense> get _filteredActive =>
      _filtered.where((l) => !l.revoked).toList();

  List<SafeguardLicense> get _filteredTrash =>
      _filtered.where((l) => l.revoked).toList();

  int get _proCount =>
      _licenses.where((l) => !l.revoked && l.plan == 'pro').length;
  int get _unusedCount => _licenses.where((l) => l.isUnused).length;
  int get _activeCount => _licenses.where((l) => l.isActive).length;
  int get _revokedCount => _licenses.where((l) => l.revoked).length;

  Future<void> _mint() async {
    if (_validityDays == null) {
      final parsed = int.tryParse(_customDaysCtrl.text.trim());
      if (parsed == null || parsed < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entre un nombre de jours valide pour l’option +.'),
          ),
        );
        return;
      }
    }
    setState(() => _minting = true);
    try {
      final deliveryEmail = _emailCtrl.text.trim();
      final localeCode = Localizations.localeOf(context).languageCode;
      final created = await mintSafeguardLicense(
        plan: 'pro',
        note: _noteCtrl.text,
        maxActivations: _maxActivations,
        userEmail: deliveryEmail,
        validity: Duration(days: _resolvedValidityDays),
      );
      String? mailWarning;
      if (deliveryEmail.isNotEmpty) {
        try {
          await adminSendSafeguardLicenseEmail(
            licenseKey: created.key,
            email: deliveryEmail,
            note: _noteCtrl.text,
            locale: localeCode,
          );
        } catch (e) {
          mailWarning = '$e';
        }
      }
      if (!mounted) return;
      _noteCtrl.clear();
      _emailCtrl.clear();
      await Clipboard.setData(ClipboardData(text: created.key));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              mailWarning == null ? null : Colors.red.shade900,
          content: Text(
            mailWarning == null
                ? deliveryEmail.isNotEmpty
                    ? 'Licence créée, copiée et e-mail envoyé : ${created.key}'
                    : 'Licence créée ($_resolvedValidityDays j) et copiée : ${created.key}'
                : 'Licence créée : ${created.key}\nE-mail non envoyé : $mailWarning',
          ),
          duration: Duration(seconds: mailWarning == null ? 6 : 12),
        ),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: SelectableText('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _minting = false);
    }
  }

  Future<void> _toggleRevoke(SafeguardLicense license) async {
    try {
      if (license.revoked) {
        await unrevokeSafeguardLicense(license.key);
      } else {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AdminTheme.card,
            title: const Text('Révoquer cette licence ?'),
            content: Text(
              '${license.key}\n\n'
              'Safeguard ne pourra plus valider cette clé.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Révoquer'),
              ),
            ],
          ),
        );
        if (ok != true) return;
        await revokeSafeguardLicense(license.key);
      }
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: SelectableText('Erreur : $e')),
      );
    }
  }

  Future<void> _extendLicense(SafeguardLicense license) async {
    final days = await showDialog<int>(
      context: context,
      builder: (ctx) => const _ExtendDaysDialog(),
    );
    if (days == null || days < 1 || !mounted) return;
    try {
      final newEnd = await extendSafeguardLicense(
        key: license.key,
        days: days,
      );
      if (!mounted) return;
      final df = DateFormat.yMMMd().add_Hm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '+$days j → expire le ${df.format(newEnd.toLocal())}',
          ),
        ),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: SelectableText('Erreur : $e')),
      );
    }
  }

  Future<void> _resendLicenseEmail(SafeguardLicense license) async {
    final localeCode = Localizations.localeOf(context).languageCode;
    final prefilled = (license.userEmail ?? '').trim();
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => _ResendEmailDialog(initialEmail: prefilled),
    );
    if (email == null || email.trim().isEmpty || !mounted) return;
    try {
      await adminSendSafeguardLicenseEmail(
        licenseKey: license.key,
        email: email.trim(),
        note: license.note,
        locale: localeCode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail renvoyé à ${email.trim()}')),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('E-mail non envoyé : $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = AdminLayout.pagePadding(context);

    return ColoredBox(
      color: AdminTheme.bg,
      child: RefreshIndicator(
        color: AdminTheme.accent,
        onRefresh: _reload,
        child: ListView(
          padding: pad,
          children: [
            Text(
              'Paychek Safeguard — licences desktop (NinjaTrader). '
              'Génère des codes Pro PAYC-XXXX-XXXX-XXXX pour tes clients.',
              style: GoogleFonts.plusJakartaSans(
                color: AdminTheme.textMuted,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            _StatsRow(
              pro: _proCount,
              unused: _unusedCount,
              active: _activeCount,
              revoked: _revokedCount,
            ),
            const SizedBox(height: 20),
            _MintCard(
              noteCtrl: _noteCtrl,
              emailCtrl: _emailCtrl,
              customDaysCtrl: _customDaysCtrl,
              maxActivations: _maxActivations,
              validityDays: _validityDays,
              minting: _minting,
              onMaxChanged: (v) => setState(() => _maxActivations = v),
              onValidityChanged: (v) => setState(() => _validityDays = v),
              onMint: _minting ? null : _mint,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 20),
                      hintText: 'Rechercher clé, note, e-mail…',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: _loading ? null : _reload,
                  tooltip: 'Actualiser',
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SelectableText(
                  'Erreur chargement : $_error',
                  style: const TextStyle(color: Color(0xFFF87171)),
                ),
              ),
            if (_loading && _licenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Aucune licence pour le moment.\nCrée une clé Pro ci-dessus.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: AdminTheme.textDim,
                    height: 1.5,
                  ),
                ),
              )
            else ...[
              _SectionTitle(
                icon: Icons.inventory_2_outlined,
                title: 'Licences',
                count: _filteredActive.length,
              ),
              const SizedBox(height: 10),
              if (_filteredActive.isEmpty)
                _EmptySectionCard(
                  text: 'Aucune licence active avec ce filtre.',
                )
              else
                ..._filteredActive.map(
                  (lic) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LicenseTile(
                      license: lic,
                      onCopy: () async {
                        await Clipboard.setData(ClipboardData(text: lic.key));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copié : ${lic.key}')),
                        );
                      },
                      onExtend: () => _extendLicense(lic),
                      onResendEmail: () => _resendLicenseEmail(lic),
                      onToggleRevoke: () => _toggleRevoke(lic),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              _SectionTitle(
                icon: Icons.delete_outline_rounded,
                title: 'Corbeille',
                count: _filteredTrash.length,
                accent: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 10),
              if (_filteredTrash.isEmpty)
                _EmptySectionCard(
                  text: 'Aucun code supprimé dans la corbeille.',
                )
              else
                ..._filteredTrash.map(
                  (lic) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LicenseTile(
                      license: lic,
                      onCopy: () async {
                        await Clipboard.setData(ClipboardData(text: lic.key));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copié : ${lic.key}')),
                        );
                      },
                      onResendEmail: () => _resendLicenseEmail(lic),
                      onToggleRevoke: () => _toggleRevoke(lic),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.pro,
    required this.unused,
    required this.active,
    required this.revoked,
  });

  final int pro;
  final int unused;
  final int active;
  final int revoked;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Pro', pro, AdminTheme.accent),
      ('Non utilisées', unused, AdminTheme.liveBlue),
      ('Activées', active, AdminTheme.warning),
      ('Révoquées', revoked, const Color(0xFFEF4444)),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 720;
        final children = items
            .map(
              (e) => _StatChip(label: e.$1, value: e.$2, color: e.$3),
            )
            .toList();
        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: children[i]),
              ],
            ],
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children
              .map((w) => SizedBox(width: (c.maxWidth - 10) / 2, child: w))
              .toList(),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AdminTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.count,
    this.accent,
  });

  final IconData icon;
  final String title;
  final int count;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AdminTheme.textMuted;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: AdminTheme.textDim,
        ),
      ),
    );
  }
}

class _MintCard extends StatelessWidget {
  const _MintCard({
    required this.noteCtrl,
    required this.emailCtrl,
    required this.customDaysCtrl,
    required this.maxActivations,
    required this.validityDays,
    required this.minting,
    required this.onMaxChanged,
    required this.onValidityChanged,
    required this.onMint,
  });

  final TextEditingController noteCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController customDaysCtrl;
  final int maxActivations;
  final int? validityDays;
  final bool minting;
  final ValueChanged<int> onMaxChanged;
  final ValueChanged<int?> onValidityChanged;
  final VoidCallback? onMint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminTheme.cardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key_outlined, color: AdminTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Créer une licence Pro',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Note (optionnel)',
              hintText: 'Ex. client Jean — Ninja Sim',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-mail client (optionnel)',
              hintText: 'lien journal Paychek',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Durée de la clé',
            style: GoogleFonts.plusJakartaSans(
              color: AdminTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final days in const [3, 7, 30, 365])
                ChoiceChip(
                  label: Text(days == 365 ? '365 j' : '$days j'),
                  selected: validityDays == days,
                  onSelected: minting ? null : (_) => onValidityChanged(days),
                ),
              ChoiceChip(
                label: const Text('+'),
                selected: validityDays == null,
                onSelected: minting ? null : (_) => onValidityChanged(null),
              ),
            ],
          ),
          if (validityDays == null) ...[
            const SizedBox(height: 10),
            TextField(
              controller: customDaysCtrl,
              enabled: !minting,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Nombre de jours personnalisé',
                hintText: 'Ex. 14',
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Machines max',
                style: GoogleFonts.plusJakartaSans(
                  color: AdminTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: maxActivations,
                dropdownColor: AdminTheme.card,
                items: const [1, 2, 3, 4, 5]
                    .map(
                      (n) => DropdownMenuItem(value: n, child: Text('$n')),
                    )
                    .toList(),
                onChanged: minting
                    ? null
                    : (v) {
                        if (v != null) onMaxChanged(v);
                      },
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onMint,
                icon: minting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(minting ? 'Création…' : 'Générer la clé'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExtendDaysDialog extends StatefulWidget {
  const _ExtendDaysDialog();

  @override
  State<_ExtendDaysDialog> createState() => _ExtendDaysDialogState();
}

class _ExtendDaysDialogState extends State<_ExtendDaysDialog> {
  int? _preset = 7;
  final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  int? get _resolved {
    if (_preset != null) return _preset;
    final n = int.tryParse(_customCtrl.text.trim());
    if (n == null || n < 1) return null;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AdminTheme.card,
      title: const Text('Ajouter des jours'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Prolonge la date d’expiration de la clé.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AdminTheme.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in const [3, 7, 30, 365])
                ChoiceChip(
                  label: Text('+$d j'),
                  selected: _preset == d,
                  onSelected: (_) => setState(() => _preset = d),
                ),
              ChoiceChip(
                label: const Text('+'),
                selected: _preset == null,
                onSelected: (_) => setState(() => _preset = null),
              ),
            ],
          ),
          if (_preset == null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Nombre de jours',
                hintText: 'Ex. 14',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _resolved == null
              ? null
              : () => Navigator.pop(context, _resolved),
          child: Text(_resolved == null ? 'Ajouter' : 'Ajouter +$_resolved j'),
        ),
      ],
    );
  }
}

class _ResendEmailDialog extends StatefulWidget {
  const _ResendEmailDialog({this.initialEmail = ''});

  final String initialEmail;

  @override
  State<_ResendEmailDialog> createState() => _ResendEmailDialogState();
}

class _ResendEmailDialogState extends State<_ResendEmailDialog> {
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = _emailCtrl.text.trim();
    final valid = email.contains('@') && email.length <= 320;
    return AlertDialog(
      backgroundColor: AdminTheme.card,
      title: const Text('Renvoyer l’e-mail'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Le client recevra la clé, la date d’expiration et le lien de téléchargement.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AdminTheme.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailCtrl,
            autofocus: widget.initialEmail.trim().isEmpty,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-mail client',
              hintText: 'client@email.com',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: valid ? () => Navigator.pop(context, email) : null,
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}

class _LicenseTile extends StatelessWidget {
  const _LicenseTile({
    required this.license,
    required this.onCopy,
    required this.onToggleRevoke,
    this.onExtend,
    this.onResendEmail,
  });

  final SafeguardLicense license;
  final VoidCallback onCopy;
  final VoidCallback onToggleRevoke;
  final VoidCallback? onExtend;
  final VoidCallback? onResendEmail;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd().add_Hm();
    final created = license.createdAt != null
        ? df.format(license.createdAt!.toLocal())
        : '—';
    final expires = license.expiresAt != null
        ? df.format(license.expiresAt!.toLocal())
        : null;

    Color statusColor;
    String statusLabel;
    if (license.revoked) {
      statusColor = const Color(0xFFEF4444);
      statusLabel = 'Révoquée';
    } else if (license.isActive) {
      statusColor = AdminTheme.warning;
      statusLabel = 'Activée (${license.activationCount})';
    } else {
      statusColor = AdminTheme.accent;
      statusLabel = 'Disponible';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: license.revoked
              ? const Color(0x44EF4444)
              : AdminTheme.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  license.key,
                  style: GoogleFonts.robotoMono(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MiniPill(label: statusLabel, color: statusColor),
                    _MiniPill(
                      label: license.plan.toUpperCase(),
                      color: AdminTheme.liveBlue,
                    ),
                    Text(
                      'Créée $created',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AdminTheme.textDim,
                      ),
                    ),
                  ],
                ),
                if (license.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    license.note,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AdminTheme.textMuted,
                    ),
                  ),
                ],
                if ((license.userEmail ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    license.userEmail!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AdminTheme.textDim,
                    ),
                  ),
                ],
                if (expires != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Expire le $expires',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AdminTheme.textDim,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copier',
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 18),
          ),
          if (onResendEmail != null)
            IconButton(
              tooltip: 'Renvoyer l’e-mail',
              onPressed: onResendEmail,
              icon: const Icon(Icons.mark_email_unread_outlined, size: 18),
            ),
          if (onExtend != null && !license.revoked)
            IconButton(
              tooltip: 'Ajouter des jours',
              onPressed: onExtend,
              icon: const Icon(Icons.more_time_rounded, size: 18),
            ),
          IconButton(
            tooltip: license.revoked ? 'Réactiver' : 'Révoquer',
            onPressed: onToggleRevoke,
            icon: Icon(
              license.revoked
                  ? Icons.restart_alt_rounded
                  : Icons.block_rounded,
              size: 18,
              color: license.revoked
                  ? AdminTheme.accent
                  : const Color(0xFFF87171),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
