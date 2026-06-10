part of 'admin_users_page.dart';

class _AdminPlatformAccessControl extends StatefulWidget {
  const _AdminPlatformAccessControl({
    required this.userId,
    required this.webEnabled,
    required this.mobileEnabled,
    required this.scaffoldContext,
  });

  final String userId;
  final bool webEnabled;
  final bool mobileEnabled;
  final BuildContext scaffoldContext;

  @override
  State<_AdminPlatformAccessControl> createState() =>
      _AdminPlatformAccessControlState();
}

class _AdminPlatformAccessControlState extends State<_AdminPlatformAccessControl> {
  bool _saving = false;

  Future<void> _pushAccess({required bool web, required bool value}) async {
    if (_saving) return;
    final current = web ? widget.webEnabled : widget.mobileEnabled;
    if (value == current) return;

    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId)
          .update(<String, dynamic>{
        if (web) 'accessWebEnabled': value else 'accessMobileEnabled': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            web
                ? 'Web : ${value ? 'activé' : 'désactivé'}'
                : 'Mobile (Android/iOS) : ${value ? 'activé' : 'désactivé'}',
          ),
        ),
      );
    } catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Échec : $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _saving,
      child: Opacity(
        opacity: _saving ? 0.5 : 1,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Accès Web',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch.adaptive(
                  value: widget.webEnabled,
                  activeThumbColor: AdminTheme.accent,
                  activeTrackColor: AdminTheme.accent.withValues(alpha: 0.35),
                  onChanged: (v) => _pushAccess(web: true, value: v),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Accès mobile (Android / iOS)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch.adaptive(
                  value: widget.mobileEnabled,
                  activeThumbColor: AdminTheme.accent,
                  activeTrackColor: AdminTheme.accent.withValues(alpha: 0.35),
                  onChanged: (v) => _pushAccess(web: false, value: v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pastille d’engagement (7 j) : seul un rond coloré, la colonne « Statut » est retirée du tableau.
class _UserEngagementDot extends StatelessWidget {
  const _UserEngagementDot({required this.u});

  final AdminUserRow u;

  @override
  Widget build(BuildContext context) {
    final led = paychekAdminEngagementLed(u);
    final c = paychekAdminEngagementLedColor(led);
    final short = switch (led) {
      AdminEngagementLed.green => 'Actif',
      AdminEngagementLed.orange => 'Peu actif',
      AdminEngagementLed.red => 'Inactif',
    };
    return Tooltip(
      message: '$short\n${paychekAdminEngagementLedTooltip(led)}',
      waitDuration: const Duration(milliseconds: 400),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: c.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTrialFreemiumOverrideControl extends StatefulWidget {
  const _AdminTrialFreemiumOverrideControl({
    required this.userId,
    required this.joinedAt,
    required this.overrideUntil,
    required this.df,
    required this.scaffoldContext,
  });

  final String userId;
  final DateTime joinedAt;
  final DateTime? overrideUntil;
  final DateFormat df;
  final BuildContext scaffoldContext;

  @override
  State<_AdminTrialFreemiumOverrideControl> createState() =>
      _AdminTrialFreemiumOverrideControlState();
}

class _AdminTrialFreemiumOverrideControlState
    extends State<_AdminTrialFreemiumOverrideControl> {
  static const Duration _kTrial = Duration(days: 7);
  bool _saving = false;

  DateTime get _defaultEndUtc => widget.joinedAt.toUtc().add(_kTrial);

  DateTime get _effectiveEndUtc =>
      widget.overrideUntil ?? _defaultEndUtc;

  Future<void> _persistEndUtc(DateTime endUtc) async {
    if (_saving) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId)
          .set(
            <String, dynamic>{
              kPaychekUserFieldTrialFreemiumOverrideUntil:
                  Timestamp.fromDate(endUtc),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Date freemium enregistrée — l’app utilisera cette fin d’accès plein.',
          ),
        ),
      );
    } catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Échec : $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clearOverride() async {
    if (_saving) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId)
          .update(<String, dynamic>{
        kPaychekUserFieldTrialFreemiumOverrideUntil: FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Override supprimé — retour au calcul inscription + 7 j.'),
        ),
      );
    } catch (e) {
      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Échec : $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveEndUtc.toLocal(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null || !mounted) return;
    final endLocal = DateTime(
      picked.year,
      picked.month,
      picked.day,
      23,
      59,
      59,
      999,
    );
    await _persistEndUtc(endLocal.toUtc());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AbsorbPointer(
      absorbing: _saving,
      child: Opacity(
        opacity: _saving ? 0.55 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RÉGLAGE FREEMIUM',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.55,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.df.format(_effectiveEndUtc.toLocal()),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.overrideUntil != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x1A34D399),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0x4434D399)),
                    ),
                    child: Text(
                      'OVERRIDE ADMIN ACTIF',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x152563EB),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0x332563EB)),
                    ),
                    child: Text(
                      'FIN PAR DÉFAUT : INSCRIPTION + 7 J',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: _saving ? null : _pickEndDate,
                  child: const Text('Choisir la date de fin…'),
                ),
                if (widget.overrideUntil != null)
                  OutlinedButton(
                    onPressed: _saving ? null : _clearOverride,
                    child: const Text('Supprimer l’override'),
                  ),
              ],
            ),
            if (_saving) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _adminSupportKindLabelFr(String raw) {
  switch (raw.trim()) {
    case 'account':
      return 'Compte';
    case 'billing':
      return 'Facturation';
    case 'feature':
      return 'Fonctionnalité';
    case 'other':
      return 'Autre';
    default:
      return raw.trim().isEmpty ? '—' : raw.trim();
  }
}

/// Affichage : prénom ou partie locale de l’e-mail support (pas l’adresse complète si évitable).
String _adminSupportDisplayNameFromStaffEmail(String? email) {
  final e = email?.trim() ?? '';
  if (e.isEmpty) return 'Support';
  final at = e.indexOf('@');
  final local = (at >= 0 ? e.substring(0, at) : e).trim();
  if (local.isEmpty) return 'Support';
  final parts = local
      .split(RegExp(r'[._+\-]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return local;
  final buf = StringBuffer();
  for (final p in parts) {
    if (buf.isNotEmpty) buf.write(' ');
    buf.write(p[0].toUpperCase());
    if (p.length > 1) buf.write(p.substring(1).toLowerCase());
  }
  final s = buf.toString().trim();
  return s.isEmpty ? local : s;
}

enum _OutboundEmailKind { welcome, payment, refund, reply }

/// Lignes de la carte « e-mails envoyés » (tickets + indications profil).
class _OutboundSupportEmailEvent {
  const _OutboundSupportEmailEvent({
    required this.kind,
    required this.atUtc,
    this.ticketId,
    this.ticketLabel,
    this.staffEmail,
  });

  final _OutboundEmailKind kind;
  final DateTime atUtc;

  /// Présent pour bienvenue / réponse (navigation vers le ticket).
  final String? ticketId;
  final String? ticketLabel;
  final String? staffEmail;
}

_OutboundSupportEmailEvent? _paymentOutboundEmailEvent(AdminUserRow user) {
  if (user.subscriptionTier != PaychekSubscriptionTier.pro) return null;
  final pm = user.paymentMethod.trim().toLowerCase();
  if (pm == 'admin') return null;
  final ts = user.subscriptionProSinceUtc ?? user.subscriptionTierUpdatedAt;
  if (ts == null) return null;
  return _OutboundSupportEmailEvent(
    kind: _OutboundEmailKind.payment,
    atUtc: ts,
  );
}

Future<List<_OutboundSupportEmailEvent>> _loadOutboundSupportEmailsFromTickets(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> ticketDocs,
) async {
  if (ticketDocs.isEmpty) return const [];

  final perTicket = await Future.wait(ticketDocs.map((doc) async {
    final tid = doc.id;
    final td = doc.data();
    final label = paychekSupportHumanRefLine(tid, td);
    final local = <_OutboundSupportEmailEvent>[];

    final created = td['createdAt'];
    if (created is Timestamp) {
      local.add(
        _OutboundSupportEmailEvent(
          kind: _OutboundEmailKind.welcome,
          ticketId: tid,
          ticketLabel: label,
          atUtc: created.toDate().toUtc(),
        ),
      );
    }

    final mq = await doc.reference
        .collection(kPaychekSupportTicketMessagesSubcollection)
        .where('sender', isEqualTo: 'staff')
        .get();

    for (final msgDoc in mq.docs) {
      final md = msgDoc.data();
      final ts = md['createdAt'];
      if (ts is! Timestamp) continue;
      final agent = '${md['staffEmail'] ?? ''}'.trim();
      local.add(
        _OutboundSupportEmailEvent(
          kind: _OutboundEmailKind.reply,
          ticketId: tid,
          ticketLabel: label,
          atUtc: ts.toDate().toUtc(),
          staffEmail: agent.isEmpty ? null : agent,
        ),
      );
    }

    return local;
  }));

  return perTicket.expand((e) => e).toList(growable: false);
}

Future<List<_OutboundSupportEmailEvent>> _loadAllOutboundEmailEvents({
  required AdminUserRow user,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> ticketDocs,
}) async {
  final fromTickets = await _loadOutboundSupportEmailsFromTickets(ticketDocs);
  final payment = _paymentOutboundEmailEvent(user);
  final merged = <_OutboundSupportEmailEvent>[
    ...fromTickets,
    ?payment,
  ];
  merged.sort((a, b) => b.atUtc.compareTo(a.atUtc));
  return merged;
}

/// Titres homogènes pour la carte e-mails.
String _outboundEmailPrimaryTitle(_OutboundSupportEmailEvent e) {
  switch (e.kind) {
    case _OutboundEmailKind.welcome:
      final lab = (e.ticketLabel ?? '').trim();
      return lab.isEmpty
          ? 'E-mail de bienvenue'
          : 'E-mail de bienvenue · ticket #$lab';
    case _OutboundEmailKind.payment:
      return 'E-mail de paiement';
    case _OutboundEmailKind.refund:
      return 'E-mail de remboursement';
    case _OutboundEmailKind.reply:
      final name = _adminSupportDisplayNameFromStaffEmail(e.staffEmail);
      final lab = (e.ticketLabel ?? '').trim();
      final ticketBit = lab.isEmpty ? '' : ' · ticket #$lab';
      return 'E-mail de réponse — $name$ticketBit';
  }
}

IconData _outboundEmailIcon(_OutboundEmailKind k) {
  return switch (k) {
    _OutboundEmailKind.welcome => Icons.mark_email_read_outlined,
    _OutboundEmailKind.payment => Icons.payment_outlined,
    _OutboundEmailKind.refund => Icons.currency_exchange,
    _OutboundEmailKind.reply => Icons.reply_outlined,
  };
}
