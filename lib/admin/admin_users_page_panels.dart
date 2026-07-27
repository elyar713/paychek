part of 'admin_users_page.dart';

class _MaquetteCollapsibleCard extends StatefulWidget {
  const _MaquetteCollapsibleCard({
    required this.title,
    required this.child,
    this.leading,
    this.headerTrailing,
    this.bodyPadding = const EdgeInsets.all(22),
    this.initiallyExpanded = true,
  });

  final String title;
  final Widget child;
  final Widget? leading;
  final Widget? headerTrailing;
  final EdgeInsetsGeometry bodyPadding;
  final bool initiallyExpanded;

  @override
  State<_MaquetteCollapsibleCard> createState() =>
      _MaquetteCollapsibleCardState();
}

class _MaquetteCollapsibleCardState extends State<_MaquetteCollapsibleCard> {
  late bool _expanded = widget.initiallyExpanded;

  static const Color _card = Color(0xFF121212);
  static const Color _panel = Color(0xFF1A1A1A);
  static const Color _border = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
      color: const Color(0xFFCBD5E1),
    );

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _panel.withValues(alpha: 0.5),
              border: const Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          setState(() => _expanded = !_expanded),
                      hoverColor: Colors.white.withValues(alpha: 0.04),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if (widget.leading != null) ...[
                              widget.leading!,
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Text(
                                widget.title,
                                style: titleStyle,
                              ),
                            ),
                            Tooltip(
                              message:
                                  _expanded ? 'Replier' : 'Déplier',
                              waitDuration:
                                  const Duration(milliseconds: 400),
                              child: AnimatedRotation(
                                turns: _expanded ? 0.5 : 0,
                                duration:
                                    const Duration(milliseconds: 180),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.headerTrailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: widget.headerTrailing!,
                  ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: _expanded
                ? Padding(
                    padding: widget.bodyPadding,
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

/// Libellé chiffré pour la grille USAGE APP (Firestore `csv_imports` count).
class _CsvImportsCountLabel extends StatefulWidget {
  const _CsvImportsCountLabel({super.key, required this.userId});

  final String userId;

  @override
  State<_CsvImportsCountLabel> createState() => _CsvImportsCountLabelState();
}

class _CsvImportsCountLabelState extends State<_CsvImportsCountLabel> {
  late final Future<int?> _countFuture =
      paychekCsvImportsRecordedCount(widget.userId);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        );
    return FutureBuilder<int?>(
      future: _countFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AdminTheme.accent,
            ),
          );
        }
        if (snap.hasError) {
          return Tooltip(
            message: '${snap.error}',
            child: Text(
              '?',
              style: style?.copyWith(color: AdminTheme.warning),
            ),
          );
        }
        final n = snap.data;
        if (n == null) {
          return Tooltip(
            message:
                'Lecture impossible (droits Firebase, hors-ligne ou index). '
                'Déploie `firestore.indexes.json` puis `firebase deploy --only firestore:indexes`.',
            child: Text('—', style: style),
          );
        }
        return Text('$n', style: style);
      },
    );
  }
}

class _CsvImportsHistoryFirestore extends StatefulWidget {
  const _CsvImportsHistoryFirestore({
    required this.userId,
    required this.df,
  });

  final String userId;
  final DateFormat df;

  @override
  State<_CsvImportsHistoryFirestore> createState() =>
      _CsvImportsHistoryFirestoreState();
}

class _CsvImportsHistoryFirestoreState extends State<_CsvImportsHistoryFirestore> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _snapshots;

  @override
  void initState() {
    super.initState();
    _snapshots = paychekCsvImportsQuery(widget.userId).snapshots();
  }

  @override
  void didUpdateWidget(covariant _CsvImportsHistoryFirestore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      setState(() {
        _snapshots = paychekCsvImportsQuery(widget.userId).snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle th() => Theme.of(context).textTheme.labelSmall!.copyWith(
          color: AdminTheme.textMuted,
          fontWeight: FontWeight.w700,
        );

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _snapshots,
      builder: (context, snap) {
        if (snap.hasError) {
          final err = '${snap.error}';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText(
                err,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.warning,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Si le message parle d’index : déploie les index Firestore '
                '(`firebase deploy --only firestore:indexes`) puis réessaie.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.textMuted,
                      height: 1.35,
                    ),
              ),
            ],
          );
        }
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: AdminTheme.accent),
            ),
          );
        }

        final docsRaw = snap.data?.docs ?? [];
        final docs = csvImportDocsNewestFirst(docsRaw);
        final referenceLine =
            'Logiciels disponibles dans l’app : ${kPaychekCsvSoftwareLabelsOrdered.join(' · ')}.';

        if (docs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Aucun import CSV enregistré pour cet utilisateur '
                '(Firestore `paychek_users/${widget.userId}/$kPaychekCsvImportsSubcollection`).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.textMuted,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                referenceLine,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AdminTheme.textDim,
                      height: 1.35,
                    ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2.2),
                1: FlexColumnWidth(1.4),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2.2),
              },
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('DATE', style: th()),
                    ),
                    Text('LOGICIEL', style: th()),
                    Text('TRADES', style: th()),
                    Text('STATUT', style: th()),
                  ],
                ),
                ...docs.map((doc) {
                  final d = doc.data();
                  final ts = d['createdAt'];
                  final dateStr = ts is Timestamp
                      ? widget.df.format(ts.toDate().toLocal())
                      : '—';
                  final software = (d['software'] as String?)?.trim() ?? '—';
                  final trades = (d['tradeCount'] as num?)?.toInt() ?? 0;
                  final skipped =
                      (d['skippedDuplicates'] as num?)?.toInt() ?? 0;
                  final badge = _csvImportBadge(d);
                  final detail = _csvImportDetail(d, skipped);

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(dateStr),
                      ),
                      Text(software),
                      Text(
                        trades > 0
                            ? '$trades'
                            : (skipped > 0 ? '0 ($skipped ignorés)' : '0'),
                      ),
                      Tooltip(
                        message: detail ?? '',
                        child: Row(
                          children: [
                            Icon(
                              badge.icon,
                              size: 18,
                              color: badge.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${badge.shortLabel}'
                                '${detail != null && detail.isNotEmpty && detail.length < 60 ? ' — $detail' : ''}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: badge.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              referenceLine,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AdminTheme.textMuted,
                    height: 1.35,
                  ),
            ),
          ],
        );
      },
    );
  }
}

({Color color, IconData icon, String shortLabel}) _csvImportBadge(
  Map<String, dynamic> d,
) {
  final s = (d['status'] as String?) ?? '';
  final tradeCount = (d['tradeCount'] as num?)?.toInt() ?? 0;
  final skipped = (d['skippedDuplicates'] as num?)?.toInt() ?? 0;
  if (s == PaychekCsvImportLogStatus.success && tradeCount == 0 && skipped > 0) {
    return (
      color: AdminTheme.warning,
      icon: Icons.copy_all_rounded,
      shortLabel: 'Doublons',
    );
  }
  switch (s) {
    case PaychekCsvImportLogStatus.success:
      return (
        color: AdminTheme.accent,
        icon: Icons.check_circle_outline,
        shortLabel: 'Succès',
      );
    case PaychekCsvImportLogStatus.empty:
      return (
        color: AdminTheme.warning,
        icon: Icons.info_outline,
        shortLabel: 'Aucun trade',
      );
    case PaychekCsvImportLogStatus.error:
      return (
        color: Colors.redAccent,
        icon: Icons.error_outline,
        shortLabel: 'Erreur',
      );
    default:
      return (
        color: AdminTheme.textMuted,
        icon: Icons.help_outline,
        shortLabel: s.isEmpty ? '—' : s,
      );
  }
}

/// Détail lisible dans le tooltip (message court + fichier si présent).
String? _csvImportDetail(Map<String, dynamic> d, int skipped) {
  final parts = <String>[];
  final fn = (d['fileName'] as String?)?.trim();
  if (fn != null && fn.isNotEmpty) parts.add(fn);
  final parsed = (d['parsedRowCount'] as num?)?.toInt();
  if (parsed != null && parsed > 0) {
    parts.add('$parsed lignes parsées depuis le fichier');
  }
  final msg = (d['message'] as String?)?.trim();
  if (msg != null && msg.isNotEmpty) parts.add(msg);
  final trades = (d['tradeCount'] as num?)?.toInt() ?? 0;
  if (skipped > 0 && (parts.isEmpty || trades == 0)) {
    parts.add('$skipped doublon(s)');
  }
  return parts.isEmpty ? null : parts.join(' · ');
}

class _BillingStripePanel extends StatefulWidget {
  const _BillingStripePanel({
    required this.df,
    required this.user,
  });

  final DateFormat df;
  final AdminUserRow user;

  @override
  State<_BillingStripePanel> createState() => _BillingStripePanelState();
}

class _BillingStripePanelState extends State<_BillingStripePanel> {
  bool _refundBusy = false;
  bool _summaryLoading = true;
  AdminUserBillingSummary _summary = AdminUserBillingSummary.empty;
  final _amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(_loadSummary());
  }

  @override
  void didUpdateWidget(covariant _BillingStripePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id ||
        oldWidget.user.subscriptionTier != widget.user.subscriptionTier ||
        oldWidget.user.subscriptionProSinceUtc !=
            widget.user.subscriptionProSinceUtc ||
        oldWidget.user.subscriptionCurrentPeriodEnd !=
            widget.user.subscriptionCurrentPeriodEnd ||
        oldWidget.user.subscriberEntitlementActive !=
            widget.user.subscriberEntitlementActive ||
        oldWidget.user.subscriptionEndedAtUtc !=
            widget.user.subscriptionEndedAtUtc ||
        oldWidget.user.paymentMethod != widget.user.paymentMethod) {
      unawaited(_loadSummary());
    }
  }

  Future<void> _loadSummary() async {
    setState(() => _summaryLoading = true);
    try {
      final s = await resolveAdminUserBillingSummary(
        user: widget.user,
        dateFormat: widget.df,
      );
      if (!mounted) return;
      setState(() {
        _summary = s;
        _summaryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _summaryLoading = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRembourse(BuildContext context) async {
    if (_refundBusy) return;
    final amount = _amountCtrl.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indiquez le montant affiché dans l’e-mail (ex. 35 \$).'),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTheme.cardElevated,
        title: Text(
          'Envoyer l’e-mail de remboursement ?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        content: Text(
          "Aucun remboursement Stripe n'est effectué depuis cette action. "
          "Le client recevra un e-mail indiquant le montant : « $amount ». "
          "Effectuez le virement réel depuis le Dashboard Stripe comme d'habitude.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.45,
            color: AdminTheme.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFCA8A04),
              foregroundColor: Colors.black,
            ),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    setState(() => _refundBusy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final r = await paychekAdminNotifyUserRefundEmail(
        targetUserId: widget.user.id,
        amountLabel: amount,
      );
      if (!context.mounted) return;
      if (r.ok) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              r.amountLabel != null && r.amountLabel!.isNotEmpty
                  ? 'E-mail envoyé (montant : ${r.amountLabel}).'
                  : 'E-mail de remboursement envoyé au client.',
            ),
          ),
        );
      } else {
        messenger?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade900,
            content: Text(r.message ?? 'Envoi impossible.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _refundBusy = false);
    }
  }

  Widget _billingPair(
    String label,
    String value, {
    bool monospace = false,
    double valueSize = 15,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          value,
          maxLines: 2,
          style: GoogleFonts.plusJakartaSans(
            fontSize: valueSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
            fontFeatures: monospace
                ? const [FontFeature.tabularFigures()]
                : null,
          ).copyWith(
            fontFamily: monospace ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showHistory = adminUserHadSubscriptionHistory(widget.user);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminSubscriptionTracePanel(
          user: widget.user,
          dateFormat: widget.df,
        ),
        const SizedBox(height: 14),
        if (_summaryLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _billingPair('Montant payé', _summary.amountLabel),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child:
                          _billingPair('Date de paiement', _summary.paidAtLabel),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _billingPair(
                        'Type d\'abonnement',
                        _summary.cycleLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _billingPair(
                  'N° de transaction',
                  _summary.transactionIdLabel,
                  monospace: true,
                  valueSize: 12,
                ),
              ],
            ),
          ),
        if (!showHistory && !_summaryLoading) ...[
          const SizedBox(height: 10),
          Text(
            'Aucun historique de paiement.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AdminTheme.textMuted,
                ),
          ),
        ],
        if (showHistory &&
            !widget.user.hasEffectiveProAccess &&
            !_summaryLoading) ...[
          const SizedBox(height: 8),
          Text(
            'Dernier achat enregistré (abonnement plus actif).',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
        if (widget.user.paymentMethod.trim().toLowerCase() == 'stripe') ...[
        const SizedBox(height: 16),
        Text(
          'Montant (e-mail client uniquement — Stripe manuel)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AdminTheme.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _amountCtrl,
                enabled: !_refundBusy,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: r'ex: 35 $',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AdminTheme.textDim,
                    fontSize: 13,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _refundBusy ? null : () => unawaited(_onRembourse(context)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE2E8F0),
                side: const BorderSide(color: Color(0xFFC5A059)),
              ),
              child: _refundBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Remboursement'),
            ),
          ],
        ),
        ],
      ],
    );
  }
}

/// Ligne Safeguard (Inactive / Lite / Pro) sous la facturation — fiche utilisateur.
class _AdminUserSafeguardStatusCard extends StatefulWidget {
  const _AdminUserSafeguardStatusCard({
    required this.userId,
    required this.email,
  });

  final String userId;
  final String email;

  @override
  State<_AdminUserSafeguardStatusCard> createState() =>
      _AdminUserSafeguardStatusCardState();
}

class _AdminUserSafeguardStatusCardState
    extends State<_AdminUserSafeguardStatusCard> {
  bool _loading = true;
  bool _saving = false;
  AdminSafeguardStatus _status = AdminSafeguardStatus.empty;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant _AdminUserSafeguardStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.email != widget.email) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await loadAdminSafeguardStatus(
        userId: widget.userId,
        email: widget.email,
      );
      if (!mounted) return;
      setState(() {
        _status = s;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = AdminSafeguardStatus.empty;
        _loading = false;
      });
    }
  }

  Future<void> _copyKey(BuildContext context) async {
    final key = _status.licenseKey.trim();
    if (key.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: key));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Safeguard key copied.')),
    );
  }

  Future<void> _toggleRevoke(BuildContext context) async {
    final lic = _status.license;
    if (lic == null) return;
    setState(() => _saving = true);
    try {
      if (lic.revoked) {
        await unrevokeSafeguardLicense(lic.key);
      } else {
        await revokeSafeguardLicense(lic.key);
      }
      if (!mounted) return;
      await _load();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lic.revoked
                ? 'Safeguard license restored.'
                : 'Safeguard license revoked.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Safeguard action failed: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _metaPair(String label, String value, {bool monospace = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.45,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.3,
          ).copyWith(fontFamily: monospace ? 'monospace' : null),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = _status.badge;
    final df = DateFormat('dd MMM yyyy');
    final expiryLabel = _status.expiryAt != null
        ? df.format(_status.expiryAt!.toLocal())
        : '—';
    final createdLabel = _status.createdAt != null
        ? df.format(_status.createdAt!.toLocal())
        : '—';
    final hasLicense = _status.license != null || _status.licenseKey.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 18,
                color: badge.color,
              ),
              const SizedBox(width: 8),
              Text(
                'SAFEGUARD',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              const Spacer(),
              if (_loading || _saving)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: badge.gradientColors,
                    ),
                  ),
                  child: Text(
                    badge.label.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.08 * 11,
                      color: badge.foreground,
                    ),
                  ),
                ),
            ],
          ),
          if (!_loading) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 18,
              runSpacing: 14,
              children: [
                SizedBox(width: 180, child: _metaPair('Type', _status.planLabel)),
                SizedBox(
                  width: 140,
                  child: _metaPair('Activation', _status.activationLabel),
                ),
                SizedBox(width: 150, child: _metaPair('Expiry', expiryLabel)),
                SizedBox(width: 150, child: _metaPair('Created', createdLabel)),
                SizedBox(
                  width: 150,
                  child: _metaPair('Source', _status.sourceLabel),
                ),
                SizedBox(
                  width: 220,
                  child: _metaPair(
                    'Linked email',
                    _status.linkedEmail.isEmpty ? '—' : _status.linkedEmail,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _metaPair(
              'Key',
              hasLicense ? _status.licenseKey : 'No linked license',
              monospace: hasLicense,
            ),
            if (_status.trialClaimed && badge == AdminSafeguardBadge.lite) ...[
              const SizedBox(height: 10),
              Text(
                '7-day trial already claimed for this account.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.textMuted,
                ),
              ),
            ],
            if (_status.revokedOnly) ...[
              const SizedBox(height: 8),
              Text(
                'Only revoked licenses found for this user.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: hasLicense ? () => _copyKey(context) : null,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy key'),
                ),
                OutlinedButton.icon(
                  onPressed: _loading || _saving ? null : () => _load(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh'),
                ),
                OutlinedButton.icon(
                  onPressed: _status.license == null || _saving
                      ? null
                      : () => _toggleRevoke(context),
                  icon: Icon(
                    _status.license?.revoked == true
                        ? Icons.restart_alt_rounded
                        : Icons.block_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _status.license?.revoked == true ? 'Restore' : 'Revoke',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
