part of 'admin_users_page.dart';

/// Canal store réel (jamais `admin`) à partir user + entitlement.
String? _adminInferStorePaymentChannel(
  Map<String, dynamic>? user,
  Map<String, dynamic>? ent,
) {
  String norm(String? raw) {
    final t = (raw ?? '').trim().toLowerCase();
    if (t == 'google') return 'google_play';
    if (t == 'apple') return 'apple_iap';
    return t;
  }

  bool isStore(String v) =>
      v == 'google_play' || v == 'apple_iap' || v == 'stripe';

  final pm = norm(user?['paymentMethod']?.toString());
  if (isStore(pm)) return pm;

  final provider = norm(
    (ent?['provider'] ?? user?['paymentProvider'])?.toString(),
  );
  if (isStore(provider)) return provider;

  final googleToken =
      '${ent?['googlePlayPurchaseToken'] ?? ''}'.trim();
  if (googleToken.isNotEmpty) return 'google_play';

  final appleTx =
      '${ent?['appleTransactionId'] ?? ent?['appleOriginalTransactionId'] ?? ''}'
          .trim();
  if (appleTx.isNotEmpty) return 'apple_iap';

  final stripeId =
      '${user?['stripeCustomerId'] ?? ent?['stripeCustomerId'] ?? ent?['stripeSubscriptionId'] ?? ent?['stripeCheckoutSessionId'] ?? ''}'
          .trim();
  if (stripeId.isNotEmpty) return 'stripe';

  return null;
}

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
            'Freemium enregistré (Premium inchangé).',
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
              'RÉGLAGE FREEMIUM (ESSAI)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.55,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Indépendant du Premium : changer cette date ne modifie pas '
              'l’abonnement Pro / cadeau admin.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.35,
                color: const Color(0xFF94A3B8),
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

/// Offre **Premium (Pro)** pour N jours (geste support / feedback) — pas le freemium.
class _AdminGrantSubscriptionDaysControl extends StatefulWidget {
  const _AdminGrantSubscriptionDaysControl({
    required this.userId,
    required this.currentPeriodEnd,
    required this.isPro,
    required this.df,
    required this.scaffoldContext,
  });

  final String userId;
  final DateTime? currentPeriodEnd;
  final bool isPro;
  final DateFormat df;
  final BuildContext scaffoldContext;

  @override
  State<_AdminGrantSubscriptionDaysControl> createState() =>
      _AdminGrantSubscriptionDaysControlState();
}

class _AdminGrantSubscriptionDaysControlState
    extends State<_AdminGrantSubscriptionDaysControl> {
  bool _saving = false;

  /// Relit la fin Pro cloud (évite une prop stale du tableau).
  Future<DateTime> _resolveBaseEndUtc() async {
    final now = DateTime.now().toUtc();
    DateTime? best = widget.currentPeriodEnd?.toUtc();
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId)
          .get();
      final entSnap = await FirebaseFirestore.instance
          .collection(kPaychekSubscriberEntitlementsCollection)
          .doc(widget.userId)
          .get();
      final fromUser = paychekParseFirestoreInstantUtc(
        userSnap.data()?[kPaychekUserFieldSubscriptionCurrentPeriodEnd],
      );
      final fromEnt = paychekParseFirestoreInstantUtc(
        entSnap.data()?['currentPeriodEnd'],
      );
      for (final c in [fromUser, fromEnt, best]) {
        if (c == null) continue;
        if (best == null || c.isAfter(best)) best = c;
      }
    } catch (_) {}
    if (best != null && best.isAfter(now)) return best;
    return now;
  }

  Future<void> _grantDays(int days) async {
    if (_saving || days < 1) return;
    final snackCtx = widget.scaffoldContext;
    final messenger = ScaffoldMessenger.maybeOf(snackCtx);
    final baseEnd = await _resolveBaseEndUtc();
    if (!mounted) return;
    final preview = baseEnd.add(Duration(days: days));
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Offrir $days jour${days > 1 ? 's' : ''} Premium (Pro) ?',
          ),
          content: Text(
            'Active uniquement le Premium (Pro).\n'
            'Le freemium / essai 7 j n’est pas modifié.\n\n'
            'Fin Premium :\n'
            '${widget.df.format(preview.toLocal())}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Activer Premium'),
            ),
          ],
        );
      },
    );
    if (confirm != true || !mounted) return;

    setState(() => _saving = true);
    try {
      final newEnd = baseEnd.add(Duration(days: days));
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(widget.userId);
      final entRef = FirebaseFirestore.instance
          .collection(kPaychekSubscriberEntitlementsCollection)
          .doc(widget.userId);

      final userSnap = await userRef.get();
      final entSnap = await entRef.get();
      final storeChannel = _adminInferStorePaymentChannel(
        userSnap.data(),
        entSnap.data(),
      );

      // Premium uniquement — ne jamais lire/écrire trialFreemiumOverrideUntil.
      // Cadeau : ne force jamais paymentMethod=admin ; restaure Google/Apple/Stripe si connu.
      final userPatch = <String, dynamic>{
        'subscriptionTier': PaychekSubscriptionTier.pro.firestoreValue,
        'isPremium': true,
        kPaychekUserFieldSubscriptionCurrentPeriodEnd:
            Timestamp.fromDate(newEnd),
        'adminCompPeriodEnd': Timestamp.fromDate(newEnd),
        kPaychekUserFieldSubscriptionProSinceUtc:
            FieldValue.serverTimestamp(),
        kPaychekUserFieldSubscriptionTierUpdatedAt:
            FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (storeChannel != null) {
        userPatch['paymentMethod'] = storeChannel;
        userPatch['paymentProvider'] = storeChannel;
      }

      final entPatch = <String, dynamic>{
        'active': true,
        'currentPeriodEnd': Timestamp.fromDate(newEnd),
        'adminCompPeriodEnd': Timestamp.fromDate(newEnd),
        'proSinceUtc': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'adminGrantDays': days,
        'adminGrantAt': FieldValue.serverTimestamp(),
      };
      if (storeChannel != null) {
        entPatch['provider'] = storeChannel;
      }

      batch.set(userRef, userPatch, SetOptions(merge: true));
      batch.set(entRef, entPatch, SetOptions(merge: true));

      await batch.commit();

      // Vérifie que l’écriture a bien pris (évite un faux succès UI).
      final verify = await entRef.get();
      final writtenEnd = paychekParseFirestoreInstantUtc(
        verify.data()?['currentPeriodEnd'],
      );
      if (writtenEnd == null ||
          writtenEnd.difference(newEnd).abs() > const Duration(minutes: 2)) {
        throw StateError(
          'Écriture Premium non confirmée dans Firestore '
          '(vérifie le claim admin).',
        );
      }

      if (!snackCtx.mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Premium +$days j (freemium inchangé) → fin '
            '${widget.df.format(newEnd.toLocal())}',
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

  Future<void> _grantCustomDays() async {
    final ctrl = TextEditingController(text: '3');
    final days = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jours Premium (Pro)'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre de jours Premium',
            hintText: '3',
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (v) {
            final n = int.tryParse(v.trim());
            if (n != null && n > 0) Navigator.pop(ctx, n);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              if (n != null && n > 0) Navigator.pop(ctx, n);
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (days == null || !mounted) return;
    await _grantDays(days);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final end = widget.currentPeriodEnd;

    return AbsorbPointer(
      absorbing: _saving,
      child: Opacity(
        opacity: _saving ? 0.55 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OFFRIR PREMIUM (PRO)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF34D399),
                letterSpacing: 0.55,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              end == null
                  ? (widget.isPro
                      ? 'Pro sans date de fin → le cadeau part d’aujourd’hui'
                      : 'Compte Lite / freemium → passera en Premium')
                  : 'Fin Premium actuelle : ${widget.df.format(end.toLocal())}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Active le plan Premium (badge Pro) uniquement.\n'
              'Ne touche pas au freemium / essai (date d’essai inchangée).\n'
              'Ex. +3 j Premium pour un feedback.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.35,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _saving ? null : () => _grantDays(3),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    foregroundColor: const Color(0xFF0A0A0A),
                  ),
                  child: const Text('+3 j Premium'),
                ),
                FilledButton.tonal(
                  onPressed: _saving ? null : () => _grantDays(7),
                  child: const Text('+7 j Premium'),
                ),
                FilledButton.tonal(
                  onPressed: _saving ? null : () => _grantDays(30),
                  child: const Text('+30 j Premium'),
                ),
                OutlinedButton(
                  onPressed: _saving ? null : _grantCustomDays,
                  child: const Text('Autre…'),
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
