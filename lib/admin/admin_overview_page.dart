import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'admin_models.dart';
import 'admin_overview_data.dart';
import 'admin_overview_payment_glyphs.dart';
import 'admin_theme.dart';

/// Palette alignée sur la maquette React (Tailwind).
abstract final class _OverviewUi {
  static const Color canvas = Color(0xFF080808);
  static const Color panel = Color(0xFF111111);
  static const Color borderSubtle = Color(0x0DFFFFFF);
  static const Color borderHover = Color(0x33FFFFFF);
  static const Color iconBg = Color(0x0DFFFFFF);
  static const Color iconBgHover = Color(0x1AFFFFFF);
  static const Color titleMuted = Color(0xFF6B7280);
  static const Color subtitleGray = Color(0xFF9CA3AF);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueHighlightBorder = Color(0x663B82F6);
  static const Color blueHighlightFill = Color(0x053B82F6);
  static const Color emerald = Color(0xFF34D399);
  static const Color emeraldBadgeBg = Color(0x1A34D399);
  static const Color orangeBar = Color(0xFFF97316);
  static const Color grayBar = Color(0xFF6B7280);
  static const Color androidGreen = Color(0xFF34D399);
  static const Color iosSilver = Color(0xFF93C5FD);
  static const Color webIndigo = Color(0xFF6366F1);
}

class AdminOverviewPage extends StatefulWidget {
  const AdminOverviewPage({super.key});

  @override
  State<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminOverviewPage>
    with SingleTickerProviderStateMixin {
  AdminOverviewData? _data;
  Object? _loadError;
  bool _busy = false;
  Timer? _timer;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _load();
    _timer = Timer.periodic(const Duration(seconds: 90), (_) => _load());
  }

  @override
  void dispose() {
    _pulse.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final showBlockingSpinner = _data == null;
    if (showBlockingSpinner && mounted) setState(() => _busy = true);
    try {
      final next = await fetchAdminOverviewData();
      if (!mounted) return;
      setState(() {
        _data = next;
        _loadError = null;
        _busy = false;
      });
    } catch (e, st) {
      debugPrint('[AdminOverview] $e\n$st');
      if (!mounted) return;
      setState(() {
        _loadError = e;
        if (showBlockingSpinner || _busy) _busy = false;
      });
    }
  }

  double _chartMaxY(List<double> values) {
    final m = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    if (m <= 0) return 6;
    return m * 1.18;
  }

  TextStyle _body(double size, Color c, [FontWeight w = FontWeight.w500]) {
    return GoogleFonts.plusJakartaSans(fontSize: size, color: c, fontWeight: w);
  }

  int _gridCols(double w) {
    if (w >= 1024) return 4;
    if (w >= 640) return 2;
    return 1;
  }

  double _cellW(double maxW, int cols, double gap) {
    if (cols <= 1) return maxW;
    return (maxW - (cols - 1) * gap) / cols;
  }

  @override
  Widget build(BuildContext context) {
    final dt =
        DateFormat.Hm(Localizations.localeOf(context).toLanguageTag());
    final d = _data;
    final err = _loadError;

    if (err != null && d == null && !_busy) {
      return ColoredBox(
        color: _OverviewUi.canvas,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: _body(14, AdminTheme.warning, FontWeight.w600),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminTheme.accent,
                  ),
                  onPressed: _load,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final values = d?.signupsPerDay30 ?? List<double>.filled(30, 0);
    final maxY = _chartMaxY(values);
    const minY = 0.0;

    return ColoredBox(
      color: _OverviewUi.canvas,
      child: RefreshIndicator(
        color: _OverviewUi.blue,
        backgroundColor: _OverviewUi.panel,
        onRefresh: _load,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            physics: const AlwaysScrollableScrollPhysics(),
          ),
          child: LayoutBuilder(
            builder: (context, outerConstraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: outerConstraints.maxWidth,
                    minHeight: outerConstraints.maxHeight,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (d != null) ...[
                              _OverviewHeader(
                                lastUpdateLocal: dt.format(d.loadedAtUtc.toLocal()),
                                pulse: _pulse,
                              ),
                            ],
                            if (err != null && d != null) ...[
                              const SizedBox(height: 12),
                              SelectableText(
                                'Dernière erreur lors d’un rafraîchissement : $err',
                                style: _body(12, AdminTheme.warning),
                              ),
                            ],
                            if (d != null) ...[
                              const SizedBox(height: 28),
                              LayoutBuilder(
                                builder: (context, c) {
                                  final w = c.maxWidth;
                                  const gap = 16.0;
                                  final cols = _gridCols(w);
                                  final cellW = _cellW(w, cols, gap);

                                  String? trendSignup;
                                  if (d.usersGrowthPct != null) {
                                    final p = d.usersGrowthPct!;
                                    if (p.abs() < 0.05) {
                                      trendSignup = '~0 %';
                                    } else {
                                      trendSignup =
                                          '${p > 0 ? '+' : ''}${p.toStringAsFixed(1)} %';
                                    }
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Wrap(
                                        spacing: gap,
                                        runSpacing: gap,
                                        children: [
                                          SizedBox(
                                            width: cellW,
                                            child: _StatCard(
                                              title: 'Total users',
                                              value: _fmtInt(d.totalUsers),
                                              icon: Icons.groups_rounded,
                                              highlight: true,
                                              trend: trendSignup,
                                            ),
                                          ),
                                          SizedBox(
                                            width: cellW,
                                            child: _StatCard(
                                              title: 'Active (24h)',
                                              value: _fmtInt(d.active24h),
                                              icon: Icons.bolt_rounded,
                                              subtitle:
                                                  'Comptes vus dans la fenêtre 24 h',
                                            ),
                                          ),
                                          SizedBox(
                                            width: cellW,
                                            child: _TicketsPendingCard(
                                              totalPending:
                                                  d.ticketsPendingApprox,
                                              account: d
                                                  .supportTicketsPendingKindAccount,
                                              billing: d
                                                  .supportTicketsPendingKindBilling,
                                              feature: d
                                                  .supportTicketsPendingKindFeature,
                                              other: d
                                                  .supportTicketsPendingKindOther,
                                              formatInt: _fmtInt,
                                            ),
                                          ),
                                          SizedBox(
                                            width: cellW,
                                            child: _LiteProSplitCard(
                                              lite: d.usersWithLiteTier,
                                              pro: d.usersWithProTier,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: gap),
                                      Wrap(
                                        spacing: gap,
                                        runSpacing: gap,
                                        children: [
                                          SizedBox(
                                            width: cellW,
                                            child: _Payments24hCard(
                                              stripeCount: d.paymentsProStripe24h,
                                              appleCount: d.paymentsProApple24h,
                                              googleCount: d.paymentsProGoogle24h,
                                              formatInt: _fmtInt,
                                            ),
                                          ),
                                          SizedBox(
                                            width: cellW,
                                            child: _StatCard(
                                              title: 'Nouvelles inscriptions',
                                              value: _fmtInt(
                                                d.usersCreatedLast24h,
                                              ),
                                              icon: Icons.person_add_rounded,
                                              subtitle: 'Créées en 24 h (UTC)',
                                            ),
                                          ),
                                          SizedBox(
                                            width: cellW,
                                            child: _StatCard(
                                              title: 'Sans tier',
                                              value: _fmtInt(
                                                d.usersTierUnsetOrOther,
                                              ),
                                              icon: Icons.pie_chart_outline_rounded,
                                              subtitle: 'Non segmentés',
                                            ),
                                          ),
                                          SizedBox(
                                            width: cellW,
                                            child: _StatCard(
                                              title: 'Conversion',
                                              value: d.totalUsers > 0
                                                  ? '${(100.0 * d.usersWithProTier / d.totalUsers).toStringAsFixed(0)} %'
                                                  : '—',
                                              icon: Icons.trending_up_rounded,
                                              subtitle: 'Part Pro / total users',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 28),
                                      LayoutBuilder(
                                        builder: (context, sectionC) {
                                          final wide =
                                              sectionC.maxWidth >= 720;
                                          if (wide) {
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: _TicketsThemePanel(
                                                    data: d,
                                                  ),
                                                ),
                                                const SizedBox(width: 24),
                                                Expanded(
                                                  child: _PlatformsPanel(
                                                    data: d,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              _TicketsThemePanel(data: d),
                                              const SizedBox(height: 24),
                                              _PlatformsPanel(data: d),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 28),
                                      LayoutBuilder(
                                        builder: (context, lc) {
                                          final narrow = lc.maxWidth < 900;
                                          final chart = _SignupChartCard(
                                            values: values,
                                            minY: minY,
                                            maxY: maxY,
                                            chartStartUtc:
                                                d.signupsChartStartUtc,
                                          );
                                          final feedItems =
                                              d.liveFeed.isEmpty
                                                  ? <AdminLiveFeedItem>[
                                                      AdminLiveFeedItem(
                                                        message:
                                                            'Aucun ticket récent.',
                                                        actor: '—',
                                                        agoLabel: '—',
                                                        dotColor: _OverviewUi
                                                            .borderSubtle,
                                                      ),
                                                    ]
                                                  : d.liveFeed;
                                          final feed = _LiveFeedCard(
                                            items: feedItems,
                                          );
                                          if (narrow) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                chart,
                                                const SizedBox(height: 20),
                                                SizedBox(
                                                  height: 320,
                                                  child: feed,
                                                ),
                                              ],
                                            );
                                          }
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(flex: 7, child: chart),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                flex: 3,
                                                child: SizedBox(
                                                  height: 340,
                                                  child: feed,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                            if (d == null && _busy)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 80),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: _OverviewUi.blue,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _fmtInt(int n) {
    final s = n.toString();
    return s.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
    required this.lastUpdateLocal,
    required this.pulse,
  });

  final String lastUpdateLocal;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 22),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _OverviewUi.borderSubtle),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 560;
          final title = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 26,
                color: _OverviewUi.blue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vue d’ensemble',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          );
          final meta = Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _OverviewUi.iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _OverviewUi.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: Tween<double>(begin: 0.45, end: 1).animate(pulse),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _OverviewUi.emerald,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Mise à jour : $lastUpdateLocal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _OverviewUi.subtitleGray,
                  ),
                ),
              ],
            ),
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 6),
                Text(
                  'Analyse des segments et de l’activité.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _OverviewUi.titleMuted,
                  ),
                ),
                const SizedBox(height: 14),
                meta,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 6),
                    Text(
                      'Analyse des segments et de l’activité.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _OverviewUi.titleMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: meta,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.trend,
    this.highlight = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final String? trend;
  final bool highlight;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.highlight;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: h ? _OverviewUi.blueHighlightFill : _OverviewUi.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: h
                ? _OverviewUi.blueHighlightBorder
                : (_hover ? _OverviewUi.borderHover : _OverviewUi.borderSubtle),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: h
                        ? const Color(0x333B82F6)
                        : (_hover
                            ? _OverviewUi.iconBgHover
                            : _OverviewUi.iconBg),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: h
                        ? _OverviewUi.blue
                        : (_hover
                            ? Colors.white.withValues(alpha: 0.85)
                            : _OverviewUi.titleMuted),
                  ),
                ),
                const Spacer(),
                if (widget.trend != null && widget.trend!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _OverviewUi.emeraldBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.north_east_rounded,
                          size: 12,
                          color: _OverviewUi.emerald,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.trend!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _OverviewUi.emerald,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.title.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _OverviewUi.titleMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
            if (widget.subtitle != null &&
                widget.subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                widget.subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _OverviewUi.titleMuted,
                  height: 1.25,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TicketsPendingCard extends StatefulWidget {
  const _TicketsPendingCard({
    required this.totalPending,
    required this.account,
    required this.billing,
    required this.feature,
    required this.other,
    required this.formatInt,
  });

  final int totalPending;
  final int account;
  final int billing;
  final int feature;
  final int other;
  final String Function(int) formatInt;

  @override
  State<_TicketsPendingCard> createState() => _TicketsPendingCardState();
}

class _TicketsPendingCardState extends State<_TicketsPendingCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _OverviewUi.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                _hover ? _OverviewUi.borderHover : _OverviewUi.borderSubtle,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 46,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _hover
                                ? _OverviewUi.iconBgHover
                                : _OverviewUi.iconBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.confirmation_num_rounded,
                            size: 20,
                            color: _hover
                                ? Colors.white.withValues(alpha: 0.85)
                                : _OverviewUi.titleMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'TICKETS ATTENTE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _OverviewUi.titleMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.formatInt(widget.totalPending),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.8,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: _OverviewUi.borderSubtle,
                ),
              ),
              Expanded(
                flex: 54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _pendingKindRow(
                      'Compte',
                      widget.account,
                      _OverviewUi.blue,
                    ),
                    const SizedBox(height: 8),
                    _pendingKindRow(
                      'Facturation',
                      widget.billing,
                      _OverviewUi.orangeBar,
                    ),
                    const SizedBox(height: 8),
                    _pendingKindRow(
                      'Fonctionnalité',
                      widget.feature,
                      AdminTheme.accent,
                    ),
                    const SizedBox(height: 8),
                    _pendingKindRow(
                      'Autre',
                      widget.other,
                      _OverviewUi.grayBar,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pendingKindRow(String label, int n, Color dot) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dot,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _OverviewUi.subtitleGray,
            ),
          ),
        ),
        Text(
          widget.formatInt(n),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

/// Pro dont le tier a été mis à jour en 24 h (UTC), ventilé par canal ([paymentMethod]).
class _Payments24hCard extends StatefulWidget {
  const _Payments24hCard({
    required this.stripeCount,
    required this.appleCount,
    required this.googleCount,
    required this.formatInt,
  });

  final int stripeCount;
  final int appleCount;
  final int googleCount;
  final String Function(int) formatInt;

  @override
  State<_Payments24hCard> createState() => _Payments24hCardState();
}

class _Payments24hCardState extends State<_Payments24hCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _OverviewUi.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                _hover ? _OverviewUi.borderHover : _OverviewUi.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PAIEMENTS (24 H)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _OverviewUi.titleMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _paymentChannelColumn(
                    tooltip: 'Stripe · Pro mis à jour en 24 h',
                    glyph: AdminOverviewPaymentGlyphs.stripe(22),
                    count: widget.stripeCount,
                  ),
                ),
                Expanded(
                  child: _paymentChannelColumn(
                    tooltip: 'App Store · Pro mis à jour en 24 h',
                    glyph: AdminOverviewPaymentGlyphs.apple(22),
                    count: widget.appleCount,
                  ),
                ),
                Expanded(
                  child: _paymentChannelColumn(
                    tooltip: 'Google Play · Pro mis à jour en 24 h',
                    glyph: AdminOverviewPaymentGlyphs.google(22),
                    count: widget.googleCount,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentChannelColumn({
    required String tooltip,
    required Widget glyph,
    required int count,
  }) {
    return Tooltip(
      message: tooltip,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _OverviewUi.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: glyph,
          ),
          const SizedBox(height: 10),
          Text(
            widget.formatInt(count),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiteProSplitCard extends StatefulWidget {
  const _LiteProSplitCard({
    required this.lite,
    required this.pro,
  });

  final int lite;
  final int pro;

  @override
  State<_LiteProSplitCard> createState() => _LiteProSplitCardState();
}

class _LiteProSplitCardState extends State<_LiteProSplitCard> {
  int? _hoverSide;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _OverviewUi.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _OverviewUi.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _splitCell(
                side: 0,
                icon: Icons.credit_card_rounded,
                label: 'Lite',
                value: widget.lite,
                iconHoverColor: _OverviewUi.blue,
              ),
            ),
            const VerticalDivider(width: 1, color: _OverviewUi.borderSubtle),
            Expanded(
              child: _splitCell(
                side: 1,
                icon: Icons.workspace_premium_rounded,
                label: 'Pro',
                value: widget.pro,
                iconHoverColor: const Color(0xFFFBBF24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _splitCell({
    required int side,
    required IconData icon,
    required String label,
    required int value,
    required Color iconHoverColor,
  }) {
    final hover = _hoverSide == side;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoverSide = side),
      onExit: (_) => setState(() => _hoverSide = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        color: hover
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.transparent,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _OverviewUi.iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: hover ? iconHoverColor : _OverviewUi.titleMuted,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _OverviewUi.titleMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$value',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.total,
    required this.barColor,
    this.glow = false,
  });

  final String label;
  final int value;
  final int total;
  final Color barColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: barColor,
                  boxShadow: glow
                      ? [
                          BoxShadow(
                            blurRadius: 10,
                            spreadRadius: 0,
                            color: barColor.withValues(alpha: 0.35),
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _OverviewUi.subtitleGray,
                  ),
                ),
              ),
              Text(
                '$value',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: _OverviewUi.iconBg,
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketsThemePanel extends StatelessWidget {
  const _TicketsThemePanel({required this.data});

  final AdminOverviewData data;

  @override
  Widget build(BuildContext context) {
    final t = data.supportTicketsTotal;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _OverviewUi.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _OverviewUi.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TICKETS PAR THÈME',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _OverviewUi.titleMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _ProgressRow(
            label: 'Compte',
            value: data.supportTicketsKindAccount,
            total: t,
            barColor: _OverviewUi.blue,
            glow: true,
          ),
          _ProgressRow(
            label: 'Facturation',
            value: data.supportTicketsKindBilling,
            total: t,
            barColor: _OverviewUi.orangeBar,
          ),
          _ProgressRow(
            label: 'Fonctionnalité',
            value: data.supportTicketsKindFeature,
            total: t,
            barColor: AdminTheme.accent,
            glow: true,
          ),
          _ProgressRow(
            label: 'Autre',
            value: data.supportTicketsKindOtherBundled,
            total: t,
            barColor: _OverviewUi.grayBar,
          ),
        ],
      ),
    );
  }
}

class _PlatformsPanel extends StatelessWidget {
  const _PlatformsPanel({required this.data});

  final AdminOverviewData data;

  @override
  Widget build(BuildContext context) {
    final t = data.totalUsers;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _OverviewUi.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _OverviewUi.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAR PLATEFORME',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _OverviewUi.titleMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _ProgressRow(
            label: 'Android',
            value: data.usersSeenOnAndroid,
            total: t,
            barColor: _OverviewUi.androidGreen,
          ),
          _ProgressRow(
            label: 'iOS',
            value: data.usersSeenOnIos,
            total: t,
            barColor: _OverviewUi.iosSilver,
          ),
          _ProgressRow(
            label: 'Web',
            value: data.usersSeenOnWeb,
            total: t,
            barColor: _OverviewUi.webIndigo,
            glow: true,
          ),
        ],
      ),
    );
  }
}

class _SignupChartCard extends StatelessWidget {
  const _SignupChartCard({
    required this.values,
    required this.minY,
    required this.maxY,
    required this.chartStartUtc,
  });

  final List<double> values;
  final double minY;
  final double maxY;
  final DateTime chartStartUtc;

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      values.length,
      (i) => FlSpot(i.toDouble(), values[i]),
    );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _OverviewUi.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _OverviewUi.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'NOUVELLES INSCRIPTIONS / JOUR (30 J, UTC)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _OverviewUi.titleMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (values.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 5,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: _OverviewUi.borderSubtle,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        v.round().toString(),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 34,
                      getTitlesWidget: (v, _) {
                        final n = values.length;
                        if (n <= 0) return const SizedBox.shrink();
                        final i = v.round().clamp(0, n - 1);
                        if (i % 5 != 0 && i != 0 && i != n - 1) {
                          return const SizedBox.shrink();
                        }
                        final dayUtc = chartStartUtc.add(Duration(days: i));
                        final label = DateFormat('dd/MM').format(
                          DateTime.utc(
                            dayUtc.year,
                            dayUtc.month,
                            dayUtc.day,
                          ),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    maxContentWidth: 220,
                    getTooltipColor: (_) => _OverviewUi.panel,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final n = values.length;
                        if (n <= 0) {
                          return LineTooltipItem(
                            '—',
                            const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          );
                        }
                        final i = spot.x.round().clamp(0, n - 1);
                        final count = values[i].round();
                        final dayUtc = chartStartUtc.add(Duration(days: i));
                        final dateStr = DateFormat('dd/MM/yyyy').format(
                          DateTime.utc(
                            dayUtc.year,
                            dayUtc.month,
                            dayUtc.day,
                          ),
                        );
                        final label = count <= 1
                            ? '$count inscription'
                            : '$count inscriptions';
                        return LineTooltipItem(
                          '$dateStr (UTC)\n$label',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 1.35,
                            fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _OverviewUi.blue,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _OverviewUi.blue.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
              duration: Duration.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveFeedCard extends StatelessWidget {
  const _LiveFeedCard({required this.items});

  final List<AdminLiveFeedItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _OverviewUi.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _OverviewUi.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'DERNIERS TICKETS SUPPORT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _OverviewUi.titleMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: _OverviewUi.borderSubtle,
              ),
              itemBuilder: (context, i) {
                final e = items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: e.dotColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6,
                              color: e.dotColor.withValues(alpha: 0.45),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.message,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
