import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'admin_billing_data.dart';
import 'admin_models.dart';
import 'admin_subscription_trace.dart';
import 'admin_theme.dart';
import 'admin_user_billing_summary.dart';
import 'admin_user_payment_history.dart';

class AdminBillingPage extends StatefulWidget {
  const AdminBillingPage({super.key});

  @override
  State<AdminBillingPage> createState() => _AdminBillingPageState();
}

class _AdminBillingPageState extends State<AdminBillingPage> {
  AdminBillingSnapshot? _data;
  Object? _error;
  bool _loading = false;
  String _channelFilter = 'all';
  String _search = '';

  AdminUserRow? _selectedUser;
  AdminUserPaymentHistoryResult? _paymentHistory;
  AdminUserBillingSummary? _billingSummary;
  bool _detailLoading = false;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final blocking = _data == null;
    if (blocking && mounted) setState(() => _loading = true);
    try {
      final snap = await fetchAdminBillingSnapshot();
      if (!mounted) return;
      final filtered = _filteredSubscribers(snap);
      AdminUserRow? keep = _selectedUser;
      if (keep != null &&
          !filtered.any((u) => u.id == keep!.id)) {
        keep = filtered.isNotEmpty ? filtered.first : null;
      } else if (keep == null && filtered.isNotEmpty) {
        keep = filtered.first;
      }
      setState(() {
        _data = snap;
        _error = null;
        _loading = false;
        _selectedUser = keep;
      });
      if (keep != null) {
        unawaited(_loadUserDetail(keep));
      } else {
        setState(() {
          _paymentHistory = null;
          _billingSummary = null;
          _detailLoading = false;
          _detailError = null;
        });
      }
    } catch (e, st) {
      debugPrint('[AdminBilling] $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadUserDetail(AdminUserRow user) async {
    setState(() {
      _detailLoading = true;
      _detailError = null;
      _paymentHistory = null;
      _billingSummary = null;
    });
    final df = DateFormat('d MMM yyyy · HH:mm', 'fr_FR');
    try {
      final results = await Future.wait<Object>([
        paychekAdminListUserBillingHistory(
          uid: user.id,
          email: user.email,
        ),
        resolveAdminUserBillingSummary(user: user, dateFormat: df),
      ]);
      if (!mounted || _selectedUser?.id != user.id) return;
      final history = results[0] as AdminUserPaymentHistoryResult;
      setState(() {
        _paymentHistory = history;
        _billingSummary = results[1] as AdminUserBillingSummary;
        _detailLoading = false;
        _detailError = history.errorMessage ?? history.appleError;
      });
    } catch (e, st) {
      debugPrint('[AdminBilling] detail $e\n$st');
      if (!mounted || _selectedUser?.id != user.id) return;
      setState(() {
        _detailLoading = false;
        _detailError = '$e';
      });
    }
  }

  void _selectUser(AdminUserRow user) {
    if (_selectedUser?.id == user.id) return;
    setState(() => _selectedUser = user);
    unawaited(_loadUserDetail(user));
  }

  TextStyle _label(double size, Color c, [FontWeight w = FontWeight.w600]) {
    return GoogleFonts.plusJakartaSans(fontSize: size, color: c, fontWeight: w);
  }

  List<AdminUserRow> _filteredSubscribers(AdminBillingSnapshot snap) {
    var list = snap.proSubscribers;
    if (_channelFilter != 'all') {
      list = list.where((u) {
        final pm = u.paymentMethod.trim().toLowerCase();
        return switch (_channelFilter) {
          'stripe' => pm == 'stripe',
          'apple' => pm == 'apple' || pm == 'apple_iap',
          'google' => pm == 'google' || pm == 'google_play',
          _ => true,
        };
      }).toList();
    }
    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((u) => u.email.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM yyyy · HH:mm', 'fr_FR');
    final dfShort = DateFormat('d MMM yyyy', 'fr_FR');
    final snap = _data;

    if (_loading && snap == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && snap == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AdminTheme.warning, size: 40),
              const SizedBox(height: 12),
              Text(
                'Impossible de charger la comptabilité.',
                style: _label(14, Colors.white),
              ),
              const SizedBox(height: 8),
              Text('$_error', style: _label(12, AdminTheme.textMuted)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                style: FilledButton.styleFrom(
                  backgroundColor: AdminTheme.accent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (snap == null) return const SizedBox.shrink();

    final subscribers = _filteredSubscribers(snap);
    final stripeMode = snap.stripeHistory.stripeKeyMode;

    return RefreshIndicator(
      onRefresh: _load,
      color: AdminTheme.accent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cliquez un abonné pour voir tout son historique de paiements.',
                    style: _label(13, AdminTheme.textMuted),
                  ),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                TextButton.icon(
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Actualiser'),
                ),
              ],
            ),
            if (stripeMode != null && stripeMode.isNotEmpty) ...[
              Text(
                'Stripe : mode ${stripeMode == 'live' ? 'production' : stripeMode}',
                style: _label(11, AdminTheme.textDim, FontWeight.w700),
              ),
              const SizedBox(height: 12),
            ],
            LayoutBuilder(
              builder: (context, c) {
                final cols =
                    c.maxWidth >= 900 ? 4 : (c.maxWidth >= 520 ? 2 : 1);
                final gap = 12.0;
                final cellW = cols <= 1
                    ? c.maxWidth
                    : (c.maxWidth - (cols - 1) * gap) / cols;
                final kpis = [
                  _KpiCard(
                    label: 'Abonnés Pro actifs',
                    value: '${snap.activeProCount}',
                    sub:
                        '${snap.overview.usersWithProTier} tier Pro · ${snap.proSubscribers.length} profils',
                    icon: Icons.verified_user_outlined,
                    accent: AdminTheme.accent,
                  ),
                  _KpiCard(
                    label: 'MRR estimé',
                    value: '${snap.estimatedMrrUsd.toStringAsFixed(0)} \$',
                    sub: 'Catalogue USD (approx.)',
                    icon: Icons.trending_up_rounded,
                    accent: const Color(0xFF34D399),
                  ),
                  _KpiCard(
                    label: 'Stripe 30 j',
                    value:
                        '${snap.stripePaidRevenue30dUsd.toStringAsFixed(2)} \$',
                    sub:
                        '${snap.successfulStripeSessions.length} paiements réussis',
                    icon: Icons.payments_outlined,
                    accent: const Color(0xFF818CF8),
                  ),
                  _KpiCard(
                    label: 'Nouveaux Pro 24 h',
                    value:
                        '${snap.overview.paymentsProStripe24h + snap.overview.paymentsProApple24h + snap.overview.paymentsProGoogle24h}',
                    sub:
                        'S ${snap.overview.paymentsProStripe24h} · A ${snap.overview.paymentsProApple24h} · G ${snap.overview.paymentsProGoogle24h}',
                    icon: Icons.bolt_outlined,
                    accent: const Color(0xFFF59E0B),
                  ),
                ];
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final k in kpis) SizedBox(width: cellW, child: k),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _ChannelBreakdown(snap: snap),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _FilterChip(
                  label: 'Tous',
                  selected: _channelFilter == 'all',
                  onTap: () => setState(() => _channelFilter = 'all'),
                ),
                _FilterChip(
                  label: 'Stripe',
                  selected: _channelFilter == 'stripe',
                  onTap: () => setState(() => _channelFilter = 'stripe'),
                ),
                _FilterChip(
                  label: 'Apple',
                  selected: _channelFilter == 'apple',
                  onTap: () => setState(() => _channelFilter = 'apple'),
                ),
                _FilterChip(
                  label: 'Google Play',
                  selected: _channelFilter == 'google',
                  onTap: () => setState(() => _channelFilter = 'google'),
                ),
                SizedBox(
                  width: 220,
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: _label(13, Colors.white),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Filtrer e-mail…',
                      hintStyle: _label(13, AdminTheme.textDim),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final stacked = c.maxWidth < 960;
                final listPane = _SubscriberListPane(
                  users: subscribers,
                  selectedId: _selectedUser?.id,
                  dfShort: dfShort,
                  onSelect: _selectUser,
                );
                final detailPane = _UserBillingDetailPane(
                  user: _selectedUser,
                  df: df,
                  dfShort: dfShort,
                  loading: _detailLoading,
                  error: _detailError,
                  history: _paymentHistory,
                  summary: _billingSummary,
                  onRetry: _selectedUser == null
                      ? null
                      : () => unawaited(_loadUserDetail(_selectedUser!)),
                );
                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      listPane,
                      const SizedBox(height: 16),
                      detailPane,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: listPane),
                    const SizedBox(width: 16),
                    Expanded(flex: 7, child: detailPane),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Mis à jour ${df.format(snap.loadedAtUtc.toLocal())}',
              style: _label(11, AdminTheme.textDim),
            ),
          ],
        ),
      ),
    );
  }
}

Color _paymentStatusColor(String status) {
  final s = status.toLowerCase();
  if (s == 'réussi') return const Color(0xFF34D399);
  if (s.contains('remboursé')) return const Color(0xFF818CF8);
  if (s == 'expiré' || s == 'annulé') return AdminTheme.textMuted;
  if (s.contains('refusé') ||
      s.contains('échec') ||
      s == 'non payé' ||
      s.contains('action requise')) {
    return AdminTheme.warning;
  }
  return AdminTheme.textMuted;
}

class _SubscriberListPane extends StatelessWidget {
  const _SubscriberListPane({
    required this.users,
    required this.selectedId,
    required this.dfShort,
    required this.onSelect,
  });

  final List<AdminUserRow> users;
  final String? selectedId;
  final DateFormat dfShort;
  final ValueChanged<AdminUserRow> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 360),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              'ABONNÉS PRO',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AdminTheme.textDim,
              ),
            ),
          ),
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Aucun abonné ne correspond au filtre.',
                style: GoogleFonts.plusJakartaSans(
                  color: AdminTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            )
          else
            ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final u = users[i];
                  final selected = u.id == selectedId;
                  final status = adminSubscriptionTraceStatusLabel(u);
                  final statusColor = adminSubscriptionTraceStatusColor(u);
                  final channel = adminPaymentMethodDisplayLabel(u.paymentMethod);
                  final channelColor =
                      adminPaymentMethodAccentColor(u.paymentMethod);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelect(u),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: selected
                              ? AdminTheme.accent.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? AdminTheme.accent.withValues(alpha: 0.45)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    u.email.isEmpty ? '—' : u.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        channel,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: channelColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        adminBillingCycleLabelForUser(u),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: AdminTheme.textDim,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  status,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  adminBillingEstimatedAmountLabel(u),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AdminTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}

class _UserBillingDetailPane extends StatelessWidget {
  const _UserBillingDetailPane({
    required this.user,
    required this.df,
    required this.dfShort,
    required this.loading,
    required this.error,
    required this.history,
    required this.summary,
    required this.onRetry,
  });

  final AdminUserRow? user;
  final DateFormat df;
  final DateFormat dfShort;
  final bool loading;
  final String? error;
  final AdminUserPaymentHistoryResult? history;
  final AdminUserBillingSummary? summary;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return _panelShell(
        child: Center(
          child: Text(
            'Sélectionnez un abonné dans la liste.',
            style: GoogleFonts.plusJakartaSans(
              color: AdminTheme.textMuted,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final u = user!;
    final pm = u.paymentMethod.trim().toLowerCase();
    final isIap = pm == 'apple' ||
        pm == 'apple_iap' ||
        pm == 'google' ||
        pm == 'google_play';
    final payments = history?.payments ?? const <AdminUserPaymentLine>[];

    return _panelShell(
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    u.email.isEmpty ? '—' : u.email,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    'UID ${u.id}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AdminTheme.textDim,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  AdminSubscriptionTracePanel(user: u, dateFormat: dfShort),
                  if (summary != null && summary != AdminUserBillingSummary.empty) ...[
                    const SizedBox(height: 14),
                    _SummaryStrip(summary: summary!),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'HISTORIQUE DES PAIEMENTS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AdminTheme.textDim,
                          ),
                        ),
                      ),
                      if (history?.stripeKeyMode != null)
                        Text(
                          'Stripe ${history!.stripeKeyMode}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AdminTheme.textDim,
                          ),
                        ),
                      if (history?.appleConfigured == true) ...[
                        if (history?.stripeKeyMode != null)
                          const SizedBox(width: 8),
                        Text(
                          'Apple API',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AdminTheme.textDim,
                          ),
                        ),
                      ],
                      if (history?.googleConfigured == true) ...[
                        if (history?.stripeKeyMode != null ||
                            history?.appleConfigured == true)
                          const SizedBox(width: 8),
                        Text(
                          'Play API',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AdminTheme.textDim,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (error != null && error!.isNotEmpty) ...[
                    _AlertBanner(
                      icon: Icons.warning_amber_rounded,
                      color: AdminTheme.warning,
                      text: error!,
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: onRetry,
                          child: const Text('Réessayer'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                  if (payments.isEmpty && (error == null || error!.isEmpty))
                    Text(
                      isIap
                          ? 'Aucune transaction trouvée pour ce compte '
                              '${adminPaymentMethodDisplayLabel(u.paymentMethod)}.'
                          : 'Aucune transaction trouvée pour cet utilisateur.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AdminTheme.textMuted,
                        height: 1.45,
                      ),
                    )
                  else
                    ...payments.map(
                      (p) => _PaymentTimelineCard(payment: p, df: df),
                    ),
                  if (payments.length > 1) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${payments.length} opération(s) — du plus récent au plus ancien.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AdminTheme.textDim,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _panelShell({required Widget child}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 360),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: child,
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.summary});

  final AdminUserBillingSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 8,
        children: [
          _mini('Montant', summary.amountLabel),
          _mini('Payé le', summary.paidAtLabel),
          _mini('Cycle', summary.cycleLabel),
          _mini('Réf.', summary.transactionIdLabel, mono: true),
        ],
      ),
    );
  }

  Widget _mini(String label, String value, {bool mono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: (mono
                  ? const TextStyle(fontFamily: 'monospace')
                  : GoogleFonts.plusJakartaSans())
              .copyWith(
            fontSize: mono ? 11 : 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _PaymentTimelineCard extends StatelessWidget {
  const _PaymentTimelineCard({
    required this.payment,
    required this.df,
  });

  final AdminUserPaymentLine payment;
  final DateFormat df;

  @override
  Widget build(BuildContext context) {
    final color = _paymentStatusColor(payment.displayStatus);
    final providerColor = switch (payment.provider) {
      AdminPaymentProvider.appleIap => const Color(0xFFE2E8F0),
      AdminPaymentProvider.googlePlay => const Color(0xFF93C5FD),
      AdminPaymentProvider.stripe => const Color(0xFF818CF8),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: providerColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: providerColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            payment.providerLabel.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: providerColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            payment.displayStatus.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      payment.amountLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    if (payment.cycleHint.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Formule · ${payment.cycleHint}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AdminTheme.textMuted,
                        ),
                      ),
                    ],
                    if (payment.productId.isNotEmpty && payment.isStoreIap) ...[
                      const SizedBox(height: 2),
                      Text(
                        payment.productId,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AdminTheme.textDim,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                df.format(payment.createdAtUtc.toLocal()),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AdminTheme.textDim,
                ),
              ),
            ],
          ),
          if (payment.refundedLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Remboursé : ${payment.refundedLabel}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF818CF8),
              ),
            ),
          ],
          if (payment.failureMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              payment.failureMessage,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AdminTheme.warning,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Divider(color: AdminTheme.border.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: 8),
          if (payment.isStoreIap) ...[
            _detailRow('Transaction', payment.transactionId),
            if (payment.originalTransactionId.isNotEmpty &&
                payment.originalTransactionId != payment.transactionId)
              _detailRow(
                payment.isGooglePlay ? 'Purchase token' : 'Transaction orig.',
                payment.originalTransactionId,
              ),
            if (payment.environment.isNotEmpty)
              _detailRow('Environnement', payment.environment),
            if (payment.expiresAtUtc != null)
              _detailRow(
                'Expire le',
                df.format(payment.expiresAtUtc!.toLocal()),
              ),
            if (payment.paymentStatus.isNotEmpty)
              _detailRow('Statut Play', payment.paymentStatus),
          ] else ...[
            _detailRow('Session', payment.checkoutSessionId),
            if (payment.paymentIntentId.isNotEmpty)
              _detailRow('Payment Intent', payment.paymentIntentId),
            _detailRow('Statut session', payment.sessionStatus),
            _detailRow('Statut paiement', payment.paymentStatus),
            if (payment.email.isNotEmpty)
              _detailRow('E-mail checkout', payment.email),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AdminTheme.textDim,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: AdminTheme.textMuted,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AdminTheme.textDim,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AdminTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelBreakdown extends StatelessWidget {
  const _ChannelBreakdown({required this.snap});

  final AdminBillingSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final channels = [
      ('Stripe', 'stripe', const Color(0xFF818CF8)),
      ('Apple', 'apple', const Color(0xFFE2E8F0)),
      ('Google Play', 'google', const Color(0xFF93C5FD)),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition par canal (Pro actifs)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < channels.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(
                  child: _ChannelStat(
                    label: channels[i].$1,
                    count: snap.proCountForChannel(channels[i].$2),
                    color: channels[i].$3,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChannelStat extends StatelessWidget {
  const _ChannelStat({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AdminTheme.textDim,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$count',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AdminTheme.accent.withValues(alpha: 0.2),
      checkmarkColor: AdminTheme.accent,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: selected ? AdminTheme.accent : AdminTheme.textMuted,
      ),
      side: BorderSide(
        color: selected
            ? AdminTheme.accent.withValues(alpha: 0.5)
            : AdminTheme.border,
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
