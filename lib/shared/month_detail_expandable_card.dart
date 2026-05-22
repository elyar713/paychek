import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dashboard/widgets/donut_ring.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_month.dart';
import '../trade/trade_models.dart';
import '../trade/trade_plan_analysis.dart';
import '../trade/trade_stats.dart';
import '../trade/trade_tokens.dart';

/// Trading session bucket for hour-of-day (labels via [AppLocalizations]).
enum _TradeMonthSession { asia, europe, us }

_TradeMonthSession _tradeMonthSessionForHour(int hour) {
  if (hour >= 1 && hour < 9) return _TradeMonthSession.asia;
  if (hour >= 9 && hour < 17) return _TradeMonthSession.europe;
  return _TradeMonthSession.us;
}

String _tradeMonthSessionTitle(AppLocalizations l, _TradeMonthSession s) {
  switch (s) {
    case _TradeMonthSession.asia:
      return l.tradeSessionAsia;
    case _TradeMonthSession.europe:
      return l.tradeSessionEurope;
    case _TradeMonthSession.us:
      return l.tradeSessionUs;
  }
}

class MonthDetailExpandableCard extends StatefulWidget {
  const MonthDetailExpandableCard({
    super.key,
    required this.monthStart,
    required this.monthTrades,
    required this.currencySymbol,
    required this.initialCapital,
    required this.onExportPdf,
    this.onTradeSelected,
    this.onExpandHeaderLockedTap,
  });

  final DateTime monthStart;
  final List<TradeListItem> monthTrades;
  final String currencySymbol;
  final double? initialCapital;
  final VoidCallback onExportPdf;
  final void Function(TradeListItem)? onTradeSelected;

  /// Si non null : tap sur l’en-tête (repli / dépli) n’ouvre pas le panneau — appelle ce callback (ex. Lite).
  final VoidCallback? onExpandHeaderLockedTap;

  @override
  State<MonthDetailExpandableCard> createState() => _MonthDetailExpandableCardState();
}

class _MonthDetailExpandableCardState extends State<MonthDetailExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final nextMonth = (widget.monthStart.month == 12)
        ? DateTime(widget.monthStart.year + 1, 1, 1)
        : DateTime(widget.monthStart.year, widget.monthStart.month + 1, 1);

    final count = widget.monthTrades.length;
    final net = widget.monthTrades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
    final avg = count <= 0 ? 0.0 : (net / count);
    final pct = (widget.initialCapital != null && widget.initialCapital! > 0)
        ? (net / widget.initialCapital!) * 100.0
        : null;

    final monthSparklineCumulative = _monthCumulativeDailyPnl(
      widget.monthTrades,
      widget.monthStart,
      nextMonth,
    );

    final rangeLabel = '${_formatDayLabelFr(widget.monthStart)} - ${_formatDayLabelFr(
      nextMonth.subtract(const Duration(days: 1)),
    )}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TradeTokens.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TradeTokens.cardBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (widget.onExpandHeaderLockedTap != null) {
                widget.onExpandHeaderLockedTap!();
                return;
              }
              setState(() => _isExpanded = !_isExpanded);
            },
            child: _buildHeader(
              context: context,
              l: l,
              monthStart: widget.monthStart,
              rangeLabel: rangeLabel,
              count: count,
              avg: avg,
              net: net,
              pct: pct,
              monthSparklineCumulative: monthSparklineCumulative,
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            _buildExpandedContent(
              context: context,
              l: l,
              monthStart: widget.monthStart,
              nextMonth: nextMonth,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required AppLocalizations l,
    required DateTime monthStart,
    required String rangeLabel,
    required int count,
    required double avg,
    required double net,
    required double? pct,
    required List<double> monthSparklineCumulative,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: _monthHeaderSparkline(monthSparklineCumulative),
        ),
        Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.monthName(monthStart.month),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  rangeLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TradeTokens.textDate,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.calDayTradesCount(count),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TradeTokens.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 96,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l.tradeAverageShort,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: TradeTokens.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 8,
                          letterSpacing: 0.55,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatMoney(avg)}${widget.currencySymbol}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: avg < 0
                              ? TradeTokens.lossNeon
                              : TradeTokens.profitNeon,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          height: 1.05,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.labelGain,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: TradeTokens.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 8,
                          letterSpacing: 0.55,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatMoney(net)}${widget.currencySymbol}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: net < 0
                              ? TradeTokens.lossNeon
                              : (net == 0 ? Colors.white : TradeTokens.profitNeon),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          height: 1.05,
                        ),
                  ),
                  if (pct != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2).replaceAll('.', ',')}%',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: pct < 0
                                ? TradeTokens.lossNeon
                                : (pct == 0 ? Colors.white : TradeTokens.profitNeon),
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: l.tradeExportPdfTooltip,
              onPressed: widget.onExportPdf,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              color: TradeTokens.textSecondary,
              iconSize: 18,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 2),
            Icon(
              _isExpanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: TradeTokens.textSecondary,
              size: 18,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedContent({
    required BuildContext context,
    required AppLocalizations l,
    required DateTime monthStart,
    required DateTime nextMonth,
  }) {
    double avgPct(List<double> xs) =>
        xs.isEmpty ? 0.0 : (xs.fold<double>(0.0, (a, b) => a + b) / xs.length);

    final avgChecklist = avgPct(
      widget.monthTrades
          .map(tradeEffectiveChecklistPct)
          .whereType<double>()
          .toList(),
    );
    final avgPlan = avgPct(
      widget.monthTrades.map(tradeEffectivePlanPct).whereType<double>().toList(),
    );
    final avgStrategie = avgPct(
      widget.monthTrades
          .map(tradeEffectiveStrategiePct)
          .whereType<double>()
          .toList(),
    );
    final avgEtat = avgPct(
      widget.monthTrades.map(tradeEffectiveEtatPct).whereType<double>().toList(),
    );
    final winMonth = computeTradeStats(widget.monthTrades).winRatePctDisplay;
    final principeCount =
        widget.monthTrades.where((e) => e.mindset == TradeMindset.principe).length;
    final feelingCount =
        widget.monthTrades.where((e) => e.mindset == TradeMindset.feeling).length;
    final wMonth =
        widget.monthTrades.where((e) => e.countsAsClosedWin).length;
    final lossMonth =
        widget.monthTrades.where((e) => e.countsAsClosedLoss).length;
    final bMonth =
        widget.monthTrades.where((e) => e.countsAsClosedBreakevenOrFlat).length;

    final sessionCounts = <_TradeMonthSession, int>{
      _TradeMonthSession.asia: 0,
      _TradeMonthSession.europe: 0,
      _TradeMonthSession.us: 0,
    };
    for (final t in widget.monthTrades) {
      final bucket = _tradeMonthSessionForHour(t.entreeAt.toLocal().hour);
      sessionCounts[bucket] = (sessionCounts[bucket] ?? 0) + 1;
    }
    final maxCount =
        sessionCounts.values.fold<int>(0, (a, b) => a > b ? a : b);

    final monthSparklineCumulative = _monthCumulativeDailyPnl(
      widget.monthTrades,
      monthStart,
      nextMonth,
    );
    final daysInMonth = nextMonth.difference(monthStart).inDays;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final itemW = (w - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: itemW,
                    child: _ringCell(
                      context: context,
                      l: l,
                      title: l.tradeSectionChecklist,
                      pctVal: avgChecklist,
                      color: TradeTokens.profitNeon,
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: _ringCell(
                      context: context,
                      l: l,
                      title: l.tradeSectionPlan,
                      pctVal: avgPlan,
                      color: TradeTokens.mustard,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: Center(
                      child: DonutRing(
                        progress: (winMonth / 100.0).clamp(0.0, 1.0),
                        centerPrimary: '$winMonth%',
                        centerSecondary: l.dashboardRingWin,
                        size: 64,
                        strokeWidth: 6,
                        ringColor: winMonth < 50
                            ? TradeTokens.lossNeon
                            : TradeTokens.profitNeon,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: Center(
                      child: Text(
                        l.tradeMonthTitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: TradeTokens.textSecondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.3,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _wlbChip(
                          context,
                          label: 'W',
                          count: wMonth,
                          color: TradeTokens.profitNeon,
                        ),
                        const SizedBox(width: 8),
                        _wlbChip(
                          context,
                          label: 'L',
                          count: lossMonth,
                          color: TradeTokens.lossNeon,
                        ),
                        const SizedBox(width: 8),
                        _wlbChip(
                          context,
                          label: 'B',
                          count: bMonth,
                          color: TradeTokens.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: _ringCell(
                      context: context,
                      l: l,
                      title: l.tradeSectionStrategie,
                      pctVal: avgStrategie,
                      color: const Color(0xFF6EA8FF),
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: _ringCell(
                      context: context,
                      l: l,
                      title: l.tradeSectionEtat,
                      pctVal: avgEtat,
                      color: TradeTokens.lossNeon,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _mindsetChip(
                context,
                icon: Icons.verified_rounded,
                label: l.tradeMindsetPrinciple,
                count: principeCount,
                color: TradeTokens.profitNeon,
              ),
              const SizedBox(width: 8),
              _mindsetChip(
                context,
                icon: Icons.psychology_alt_rounded,
                label: l.tradeMindsetFeeling,
                count: feelingCount,
                color: TradeTokens.lossNeon,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sessionBar(
            context,
            label: _tradeMonthSessionTitle(l, _TradeMonthSession.asia),
            count: sessionCounts[_TradeMonthSession.asia] ?? 0,
            maxCount: maxCount,
            barColor: const Color(0xFF6EA8FF),
          ),
          const SizedBox(height: 8),
          _sessionBar(
            context,
            label: _tradeMonthSessionTitle(l, _TradeMonthSession.europe),
            count: sessionCounts[_TradeMonthSession.europe] ?? 0,
            maxCount: maxCount,
            barColor: TradeTokens.mustard,
          ),
          const SizedBox(height: 8),
          _sessionBar(
            context,
            label: _tradeMonthSessionTitle(l, _TradeMonthSession.us),
            count: sessionCounts[_TradeMonthSession.us] ?? 0,
            maxCount: maxCount,
            barColor: TradeTokens.profitNeon,
          ),
          const SizedBox(height: 12),
          Container(
            height: 110,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TradeTokens.pillInactiveBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TradeTokens.cardBorder),
            ),
            child: _monthEvolutionChart(
              context,
              l,
              monthSparklineCumulative,
              monthTrades: widget.monthTrades,
              monthStart: monthStart,
              nextMonth: nextMonth,
              daysInMonth: daysInMonth,
            ),
          ),
          if (widget.monthTrades.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l.tradeTradesMonthHeading,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: TradeTokens.mustard,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: 8),
            for (final t in (List<TradeListItem>.of(widget.monthTrades)
              ..sort((a, b) => b.entreeAt.compareTo(a.entreeAt))))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTradeRow(context, l, t),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTradeRow(BuildContext context, AppLocalizations l, TradeListItem t) {
    String hm(DateTime d) {
      String p2(int v) => v.toString().padLeft(2, '0');
      final local = d.toLocal();
      return '${p2(local.hour)}:${p2(local.minute)}';
    }

    final sideLabel = t.breakeven
        ? l.tradeSideBreakevenShort
        : (t.side == TradeSide.achat ? l.tradeSideBuyShort : l.tradeSideSellShort);
    final sideColor = t.breakeven
        ? TradeTokens.textSecondary
        : (t.side == TradeSide.achat
            ? TradeTokens.profitNeon
            : TradeTokens.lossNeon);
    final gainColor = t.gainAmount < 0
        ? TradeTokens.lossNeon
        : (t.gainAmount == 0 ? Colors.white : TradeTokens.profitNeon);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTradeSelected != null ? () => widget.onTradeSelected!(t) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: TradeTokens.pillInactiveBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TradeTokens.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.pair,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: sideColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(
                              TradeTokens.radiusSideBadge,
                            ),
                          ),
                          child: Text(
                            sideLabel,
                            style: TextStyle(
                              color: sideColor.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hm(t.entreeAt)} • ${_tradeMonthSessionTitle(l, _tradeMonthSessionForHour(t.entreeAt.toLocal().hour))}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: TradeTokens.textDate,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_formatMoney(t.gainAmount)}${widget.currencySymbol}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: gainColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== HELPERS =====

  String _formatDayLabelFr(DateTime d) {
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${p2(d.day)}/${p2(d.month)}';
  }

  String _formatMoney(double amount) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (abs >= 1000000) {
      return '$sign${(abs / 1000000).toStringAsFixed(2)}M';
    } else if (abs >= 1000) {
      return '$sign${(abs / 1000).toStringAsFixed(1)}K';
    } else {
      return '$sign${abs.toStringAsFixed(0)}';
    }
  }

  String _formatDateTime(AppLocalizations l, DateTime dt) {
    String p2(int v) => v.toString().padLeft(2, '0');
    final local = dt.toLocal();
    return '${local.day} ${l.monthAbbrev(local.month)} ${p2(local.hour)}:${p2(local.minute)}';
  }

  List<double> _monthCumulativeDailyPnl(
    List<TradeListItem> trades,
    DateTime monthStart,
    DateTime nextMonth,
  ) {
    final daysInMonth = nextMonth.difference(monthStart).inDays;
    if (daysInMonth <= 0) return [0.0];
    
    final dailySums = List.filled(daysInMonth, 0.0);
    for (final t in trades) {
      final dayIndex = t.entreeAt.toLocal().difference(monthStart).inDays;
      if (dayIndex >= 0 && dayIndex < daysInMonth) {
        dailySums[dayIndex] += t.gainAmount;
      }
    }
    final cumulative = <double>[];
    var acc = 0.0;
    for (final v in dailySums) {
      acc += v;
      cumulative.add(acc);
    }
    if (cumulative.isEmpty) return [0.0];
    return cumulative;
  }

  Widget _monthHeaderSparkline(List<double> cumulative) {
    return SizedBox(
      width: 88,
      height: 16,
      child: CustomPaint(
        painter: _MonthSparklinePainter(cumulative),
      ),
    );
  }

  Widget _ringCell({
    required BuildContext context,
    required AppLocalizations l,
    required String title,
    required double pctVal,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.tradeAverageShort,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: TradeTokens.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 8,
                letterSpacing: 0.35,
              ),
        ),
        const SizedBox(height: 8),
        DonutRing(
          progress: (pctVal / 100.0).clamp(0.0, 1.0),
          centerPrimary: '${pctVal.round()}%',
          centerSecondary: title,
          size: 58,
          strokeWidth: 6,
          ringColor: color,
        ),
      ],
    );
  }

  Widget _wlbChip(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TradeTokens.pillInactiveBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TradeTokens.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Widget _mindsetChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TradeTokens.pillInactiveBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TradeTokens.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Widget _sessionBar(
    BuildContext context, {
    required String label,
    required int count,
    required int maxCount,
    Color? barColor,
  }) {
    final frac = maxCount <= 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
    final c = barColor ?? TradeTokens.profitNeon;
    final track = count <= 0
        ? const Color(0xFF2A2A2A).withValues(alpha: 0.9)
        : c.withValues(alpha: 0.18);
    final fill = c.withValues(alpha: 0.95);
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
          ),
        ),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: track,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: frac,
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
          ),
        ),
      ],
    );
  }

  Widget _monthEvolutionChart(
    BuildContext context,
    AppLocalizations l,
    List<double> cumulative, {
    required List<TradeListItem> monthTrades,
    required DateTime monthStart,
    required DateTime nextMonth,
    required int daysInMonth,
  }) {
    final safeCumulative = cumulative.isEmpty ? [0.0] : cumulative;

    return _MonthEvolutionInteractiveChart(
      dailyCumulative: safeCumulative,
      monthTrades: monthTrades,
      monthStart: monthStart,
      nextMonth: nextMonth,
      daysInMonth: daysInMonth > 0 ? daysInMonth : 1,
      formatMoney: (v) => '${_formatMoney(v)}${widget.currencySymbol}',
      formatEntree: (dt) => _formatDateTime(l, dt),
    );
  }
}

// ===== SPARKLINE PAINTER =====

class _MonthSparklinePainter extends CustomPainter {
  _MonthSparklinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const pad = 2.0;
    final h = (size.height - 2 * pad).clamp(1.0, size.height);
    final w = size.width;

    if (values.every((v) => v.abs() < 1e-6)) {
      final y = pad + h / 2;
      final p = Paint()
        ..color = TradeTokens.textSecondary.withValues(alpha: 0.75)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, y), Offset(w, y), p);
      return;
    }

    var minRaw = values.first;
    var maxRaw = values.first;
    for (final v in values) {
      if (v < minRaw) minRaw = v;
      if (v > maxRaw) maxRaw = v;
    }
    final extent =
        math.max(math.max(minRaw.abs(), maxRaw.abs()), 1e-6) * 1.18;

    final n = values.length;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          n <= 1 ? w / 2 : (i / (n - 1)) * w,
          pad +
              h -
              ((values[i] + extent) / (2 * extent)).clamp(0.0, 1.0) * h,
        ),
    ];
    final path = _smoothStrokePathThroughPoints(pts);
    final zeroY = pad + h / 2;

    final gainPaint = Paint()
      ..color = TradeTokens.profitNeon
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final lossPaint = Paint()
      ..color = TradeTokens.lossNeon
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, zeroY));
    canvas.drawPath(path, gainPaint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, zeroY, w, size.height));
    canvas.drawPath(path, lossPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MonthSparklinePainter oldDelegate) {
    final a = oldDelegate.values;
    final b = values;
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
  }
}

Path _smoothStrokePathThroughPoints(List<Offset> pts, {double tension = 4.5}) {
  if (pts.isEmpty) return Path();
  if (pts.length == 1) {
    return Path()..moveTo(pts[0].dx, pts[0].dy);
  }
  if (pts.length == 2) {
    return Path()
      ..moveTo(pts[0].dx, pts[0].dy)
      ..lineTo(pts[1].dx, pts[1].dy);
  }
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < pts.length - 1; i++) {
    final p0 = pts[i == 0 ? 0 : i - 1];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = pts[i + 2 >= pts.length ? pts.length - 1 : i + 2];
    final cp1 = Offset(
      p1.dx + (p2.dx - p0.dx) / tension,
      p1.dy + (p2.dy - p0.dy) / tension,
    );
    final cp2 = Offset(
      p2.dx - (p3.dx - p1.dx) / tension,
      p2.dy - (p3.dy - p1.dy) / tension,
    );
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
  }
  return path;
}

// ===== INTERACTIVE CHART =====

class _MonthEvolutionInteractiveChart extends StatefulWidget {
  const _MonthEvolutionInteractiveChart({
    required this.dailyCumulative,
    required this.monthTrades,
    required this.monthStart,
    required this.nextMonth,
    required this.daysInMonth,
    required this.formatMoney,
    required this.formatEntree,
  });

  final List<double> dailyCumulative;
  final List<TradeListItem> monthTrades;
  final DateTime monthStart;
  final DateTime nextMonth;
  final int daysInMonth;
  final String Function(double) formatMoney;
  final String Function(DateTime) formatEntree;

  @override
  State<_MonthEvolutionInteractiveChart> createState() =>
      _MonthEvolutionInteractiveChartState();
}

class _MonthEvolutionInteractiveChartState
    extends State<_MonthEvolutionInteractiveChart> {
  int? _selectedChronoIndex;

  @override
  Widget build(BuildContext context) {
    final n = widget.daysInMonth <= 0
        ? widget.dailyCumulative.length
        : widget.daysInMonth;
    final labels = <int>{
      1,
      if (n >= 8) 8,
      if (n >= 15) 15,
      if (n >= 22) 22,
      if (n >= 28) 28,
      if (n >= 1) n,
    }.toList()
      ..sort();

    final sorted = List<TradeListItem>.of(widget.monthTrades)
      ..sort((a, b) => a.entreeAt.compareTo(b.entreeAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final layout = _MonthEvolutionLayout.compute(
                size: size,
                dailyCumulative: widget.dailyCumulative,
                trades: widget.monthTrades,
                monthStart: widget.monthStart,
                nextMonth: widget.nextMonth,
                selectedChronoIndex: _selectedChronoIndex,
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  if (layout == null) return;
                  final hit = layout.hitTestNearest(details.localPosition, 16);
                  setState(() {
                    if (hit == null) {
                      _selectedChronoIndex = null;
                    } else if (_selectedChronoIndex == hit) {
                      _selectedChronoIndex = null;
                    } else {
                      _selectedChronoIndex = hit;
                    }
                  });
                },
                child: CustomPaint(
                  painter: _MonthEvolutionLayoutPainter(layout),
                  child: const SizedBox.expand(),
                ),
              );
            },
          ),
        ),
        if (_selectedChronoIndex != null &&
            _selectedChronoIndex! >= 0 &&
            _selectedChronoIndex! < sorted.length) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: TradeTokens.cardBg.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: TradeTokens.mustard.withValues(alpha: 0.35),
                ),
              ),
              child: Builder(
                builder: (context) {
                  final t = sorted[_selectedChronoIndex!];
                  final gainColor = t.gainAmount < 0
                      ? TradeTokens.lossNeon
                      : (t.gainAmount == 0
                          ? Colors.white
                          : TradeTokens.profitNeon);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedChronoIndex! + 1}/${sorted.length} · ${t.pair} · ${widget.formatMoney(t.gainAmount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: gainColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        widget.formatEntree(t.entreeAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TradeTokens.textDate,
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                          height: 1.1,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 6),
        Container(
          height: 1,
          color: TradeTokens.cardBorder.withValues(alpha: 0.65),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final d in labels)
              Text(
                '$d',
                style: const TextStyle(
                  color: TradeTokens.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ===== CHART LAYOUT & PAINTER =====

const double _kMonthChartCurveTension = 4.5;

double _cubicBezier1D(double t, double v0, double v1, double v2, double v3) {
  final u = 1 - t;
  return u * u * u * v0 +
      3 * u * u * t * v1 +
      3 * u * t * t * v2 +
      t * t * t * v3;
}

double? _yOnSmoothCurveAtX(
  List<Offset> pts,
  double x, {
  double tension = _kMonthChartCurveTension,
}) {
  if (pts.isEmpty) return null;
  if (pts.length == 1) return pts[0].dy;
  if (pts.length == 2) {
    final a = pts[0];
    final b = pts[1];
    if ((b.dx - a.dx).abs() < 1e-6) return a.dy;
    final t = ((x - a.dx) / (b.dx - a.dx)).clamp(0.0, 1.0);
    return a.dy + t * (b.dy - a.dy);
  }

  double? bestY;
  var bestErr = double.infinity;

  for (var i = 0; i < pts.length - 1; i++) {
    final p0 = pts[i == 0 ? 0 : i - 1];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = pts[i + 2 >= pts.length ? pts.length - 1 : i + 2];
    final cp1 = Offset(
      p1.dx + (p2.dx - p0.dx) / tension,
      p1.dy + (p2.dy - p0.dy) / tension,
    );
    final cp2 = Offset(
      p2.dx - (p3.dx - p1.dx) / tension,
      p2.dy - (p3.dy - p1.dy) / tension,
    );

    double xAt(double t) =>
        _cubicBezier1D(t, p1.dx, cp1.dx, cp2.dx, p2.dx);
    double yAt(double t) =>
        _cubicBezier1D(t, p1.dy, cp1.dy, cp2.dy, p2.dy);

    var segT = 0.0;
    var segErr = double.infinity;
    for (var s = 0; s <= 64; s++) {
      final t = s / 64.0;
      final err = (xAt(t) - x).abs();
      if (err < segErr) {
        segErr = err;
        segT = t;
      }
    }
    var lo = (segT - 0.08).clamp(0.0, 1.0);
    var hi = (segT + 0.08).clamp(0.0, 1.0);
    for (var k = 0; k < 18; k++) {
      final m1 = lo + (hi - lo) / 3;
      final m2 = hi - (hi - lo) / 3;
      final e1 = (xAt(m1) - x).abs();
      final e2 = (xAt(m2) - x).abs();
      if (e1 < e2) {
        hi = m2;
      } else {
        lo = m1;
      }
    }
    final tRef = (lo + hi) / 2;
    final errRef = (xAt(tRef) - x).abs();
    if (errRef < segErr) {
      segErr = errRef;
      segT = tRef;
    }

    if (segErr < bestErr) {
      bestErr = segErr;
      bestY = yAt(segT);
    }
  }

  return bestY;
}

class _MonthEvolutionLayout {
  _MonthEvolutionLayout({
    required this.sortedTrades,
    required this.tradeCum,
    required this.tradeOffsets,
    required this.minV,
    required this.maxV,
    required this.pad,
    required this.w,
    required this.h,
    required this.dailyCumulative,
    required this.selectedChronoIndex,
  });

  final List<TradeListItem> sortedTrades;
  final List<double> tradeCum;
  final List<Offset> tradeOffsets;
  /// Bornes d’affichage **symétriques** autour de 0 (P&L cumulé).
  final double minV;
  final double maxV;
  final double pad;
  final double w;
  final double h;
  final List<double> dailyCumulative;
  final int? selectedChronoIndex;

  static _MonthEvolutionLayout? compute({
    required Size size,
    required List<double> dailyCumulative,
    required List<TradeListItem> trades,
    required DateTime monthStart,
    required DateTime nextMonth,
    required int? selectedChronoIndex,
  }) {
    if (dailyCumulative.isEmpty) return null;

    const pad = 2.0;
    final w = size.width;
    final h = (size.height - 2 * pad).clamp(1.0, size.height);

    final sorted = List<TradeListItem>.of(trades)
      ..sort((a, b) => a.entreeAt.compareTo(b.entreeAt));
    final tradeCum = <double>[];
    var acc = 0.0;
    for (final t in sorted) {
      acc += t.gainAmount;
      tradeCum.add(acc);
    }

    var minRaw = dailyCumulative.first;
    var maxRaw = dailyCumulative.first;
    for (final v in dailyCumulative) {
      if (v < minRaw) minRaw = v;
      if (v > maxRaw) maxRaw = v;
    }
    for (final v in tradeCum) {
      if (v < minRaw) minRaw = v;
      if (v > maxRaw) maxRaw = v;
    }
    final maxAbs = math.max(math.max(minRaw.abs(), maxRaw.abs()), 1e-6);
    final displayExtent = maxAbs * 1.15;
    var minV = -displayExtent;
    var maxV = displayExtent;

    double yFor(double v) {
      if (maxV == minV) return pad + h / 2;
      final span = maxV - minV;
      return pad + h - ((v - minV) / span) * h;
    }

    final totalMs = nextMonth.difference(monthStart).inMilliseconds;
    final denom = totalMs <= 0 ? 1 : totalMs;

    final nDays = dailyCumulative.length;
    final linePts = <Offset>[
      for (var i = 0; i < nDays; i++)
        Offset(
          nDays <= 1 ? w / 2 : (i / (nDays - 1)) * w,
          yFor(dailyCumulative[i]),
        ),
    ];

    final tradeOffsets = <Offset>[];
    for (var i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      final dtMs = t.entreeAt.toLocal().difference(monthStart).inMilliseconds;
      final clamped = dtMs.clamp(0, denom).toDouble();
      final x = (clamped / denom) * w;
      final yOnCurve = _yOnSmoothCurveAtX(linePts, x) ?? yFor(tradeCum[i]);
      tradeOffsets.add(Offset(x, yOnCurve));
    }

    return _MonthEvolutionLayout(
      sortedTrades: sorted,
      tradeCum: tradeCum,
      tradeOffsets: tradeOffsets,
      minV: minV,
      maxV: maxV,
      pad: pad,
      w: w,
      h: h,
      dailyCumulative: dailyCumulative,
      selectedChronoIndex: selectedChronoIndex,
    );
  }

  int? hitTestNearest(Offset local, double radius) {
    if (tradeOffsets.isEmpty) return null;
    var bestI = -1;
    var bestD = double.infinity;
    for (var i = 0; i < tradeOffsets.length; i++) {
      final d = (tradeOffsets[i] - local).distance;
      if (d < bestD && d <= radius) {
        bestD = d;
        bestI = i;
      }
    }
    return bestI < 0 ? null : bestI;
  }

  void paint(Canvas canvas) {
    double yFor(double v) {
      if (maxV == minV) return pad + h / 2;
      final span = maxV - minV;
      return pad + h - ((v - minV) / span) * h;
    }

    final gainStroke = Paint()
      ..color = TradeTokens.profitNeon
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final lossStroke = Paint()
      ..color = TradeTokens.lossNeon
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final n = dailyCumulative.length;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          n <= 1 ? w / 2 : (i / (n - 1)) * w,
          yFor(dailyCumulative[i]),
        ),
    ];
    final curvePath =
        _smoothStrokePathThroughPoints(pts, tension: _kMonthChartCurveTension);
    final zeroY = yFor(0);

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, zeroY));
    canvas.drawPath(curvePath, gainStroke);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, zeroY, w, pad + h + 8));
    canvas.drawPath(curvePath, lossStroke);
    canvas.restore();

    if (sortedTrades.isEmpty) return;
    final stroke = Paint()
      ..color = TradeTokens.cardBg.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final selRing = Paint()
      ..color = TradeTokens.mustard.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < tradeOffsets.length; i++) {
      final center = tradeOffsets[i];
      final selected = selectedChronoIndex == i;
      final r = selected ? 4.2 : 2.4;
      final fill = Paint()
        ..color =
            (tradeCum[i] >= 0 ? TradeTokens.profitNeon : TradeTokens.lossNeon)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, r, fill);
      canvas.drawCircle(center, r, stroke);
      if (selected) {
        canvas.drawCircle(center, r + 2.5, selRing);
      }
    }
  }
}

class _MonthEvolutionLayoutPainter extends CustomPainter {
  _MonthEvolutionLayoutPainter(this.layout);

  final _MonthEvolutionLayout? layout;

  @override
  void paint(Canvas canvas, Size size) {
    layout?.paint(canvas);
  }

  @override
  bool shouldRepaint(covariant _MonthEvolutionLayoutPainter oldDelegate) =>
      oldDelegate.layout != layout;
}
