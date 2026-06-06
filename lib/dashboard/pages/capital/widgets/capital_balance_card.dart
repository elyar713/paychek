import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../analyse/analyse_report_snapshot.dart';
import '../../../../checklist/checklist_page_controller.dart';
import '../../../../checklist/checklist_progress_ring.dart';
import '../../../../etat_mental/mental_state_controller.dart';
import '../../../../etat_mental/mental_state_tokens.dart';
import '../../../../questionnaire/user_capital_scope.dart';
import '../../../../reglage/trading_week_scope.dart';
import '../../../../reglage/user_portfolio_scope.dart';
import '../../../../trade/trade_journal_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../trade/trade_journal_scope.dart';
import '../../../../trade/trade_stats.dart';
import '../../../../web/paychek_web_tokens.dart';
import '../../../capital_evolution_computed.dart';
import '../../../dashboard_tokens.dart';
import '../../../widgets/capital_evolution_chart_section.dart';
import '../../../widgets/dashboard_analyse_prep_ring.dart';
import '../../../widgets/donut_ring.dart';
import '../../../widgets/timeframe_pills.dart';

/// Solde + petite case périodes + montants + anneaux dans une carte arrondie.
class CapitalBalanceCard extends StatelessWidget {
  const CapitalBalanceCard({
    super.key,
    required this.timeframeIndex,
    required this.onTimeframeChanged,
    required this.checklistController,
    required this.onOpenChecklist,
    required this.onOpenEtatMental,
    required this.onOpenPerformance,
    required this.onOpenTrade,
    this.analysePreviewSnapshot,
    this.onOpenAnalyse,
    this.onOpenTradeById,
    this.onOpenTradeDayKey,
    this.hideTimeframePills = false,
    this.cardDecoration,
    this.webPairStretch = false,
  });

  final int timeframeIndex;
  final ValueChanged<int> onTimeframeChanged;
  final ChecklistPageController checklistController;
  final VoidCallback onOpenChecklist;
  final VoidCallback onOpenEtatMental;
  final VoidCallback onOpenPerformance;
  final VoidCallback onOpenTrade;
  final AnalyseReportSnapshot? analysePreviewSnapshot;
  final VoidCallback? onOpenAnalyse;
  final ValueChanged<String>? onOpenTradeById;
  final ValueChanged<String>? onOpenTradeDayKey;
  final bool hideTimeframePills;
  final BoxDecoration? cardDecoration;

  /// Web : ligne Capital + Evolution ([Table]) — [Spacer] pour remplir la hauteur commune.
  final bool webPairStretch;

  /// Web : proche des 64 px de la maquette (`w-16`).
  static const double _ringSizeWeb = 56;

  @override
  Widget build(BuildContext context) {
    final amountStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.05,
        );
    final soldeDeltaStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: DashboardTokens.accent,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          height: 1,
        );

    final store = UserCapitalScope.of(context);
    final portfolioStore = UserPortfolioScope.of(context);
    final tradingWeek = TradingWeekScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([store, portfolioStore, tradingWeek]),
      builder: (context, _) {
        return ListenableBuilder(
          listenable: checklistController,
          builder: (context, _) {
            final checklistPct = checklistController.checklistCompletionPercent;
            return ListenableBuilder(
              listenable: MentalStateController.instance,
              builder: (context, _) {
                final emScore = MentalStateController.instance.overallScore;
                final emPct = '${emScore.round()}%';
                final tradesStore = TradeJournalScope.of(context);
                return ListenableBuilder(
                  listenable: Listenable.merge([tradesStore, portfolioStore, store]),
                  builder: (context, _) {
                final l = AppLocalizations.of(context)!;
                final baseCapital = portfolioStore.effectiveCapitalAmount(store);
                final sym = portfolioStore.effectiveCurrencySymbol(store);
                final tfLabels = [
                  l.dashboardTfDay,
                  l.dashboardTfWeek,
                  l.dashboardTfMonth,
                  l.dashboardTfAll,
                ];
                final allTrades = activeJournalTradesOrDemo(context);
                final daysPerWeek = tradingWeek.tradingDaysPerWeek;
                final capitalMetrics =
                    CapitalEvolutionComputed.resolveDashboardCapitalMetrics(
                  allTrades,
                  timeframeIndex,
                  tradingDaysPerWeek: daysPerWeek,
                );
                final win = computeTradeStats(
                  capitalMetrics.tradesInPeriod,
                ).winRatePctDisplay;
                final periodNet = capitalMetrics.periodNet;
                final solde = (baseCapital == null)
                    ? null
                    : (baseCapital + capitalMetrics.allTimeNet);
                final mainAmount = _formatMainAmount(solde);
                final pct = (baseCapital != null && baseCapital > 0)
                    ? (periodNet / baseCapital) * 100.0
                    : null;
                final positiveAccent =
                    kIsWeb ? PaychekWebTokens.accentMint : DashboardTokens.accent;
                final deltaColor =
                    periodNet < 0 ? DashboardTokens.negative : positiveAccent;
                final signedDelta = _formatSignedAmount(periodNet);
                final signedPct = pct == null
                    ? null
                    : '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1).replaceAll('.', ',')}%';
                final rw = _ringSizeWeb;
                final trackWeb = const Color(0xFF1F2937);
                final analyseSnap = analysePreviewSnapshot;
                final openAnalyse = onOpenAnalyse;
                return Container(
              width: double.infinity,
              padding: DashboardTokens.cardPadding,
              decoration: cardDecoration ?? DashboardTokens.cardBoxDecoration(),
              child: kIsWeb
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.dashboardCapitalBalanceHeader.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: PaychekWebTokens.textGray500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sur web, cette carte peut être rendue dans une largeur très étroite (split/rail).
                        // ScaleDown évite les overflows tout en gardant l’alignement à gauche.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                mainAmount,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  color: DashboardTokens.onMatteEmphasis,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                sym,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: PaychekWebTokens.textGray500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              periodNet < 0
                                  ? Icons.trending_down_rounded
                                  : Icons.trending_up_rounded,
                              color: deltaColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                signedPct != null
                                    ? '$signedDelta $sym ($signedPct)'
                                    : '$signedDelta $sym',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: deltaColor,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.only(top: 24),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: PaychekWebTokens.borderGray800
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final items = <Widget>[
                                _webRingCaption(
                                  ring: DonutRing(
                                    progress: win / 100.0,
                                    centerPrimary: '$win%',
                                    centerSecondary: l.dashboardRingWin,
                                    size: rw,
                                    strokeWidth: 4,
                                    ringColor: PaychekWebTokens.accentMint,
                                    trackColor: trackWeb,
                                    showInnerSecondary: false,
                                    onTap: onOpenPerformance,
                                  ),
                                  caption: l.tradeSummaryWinRate,
                                ),
                                _webRingCaption(
                                  ring: DonutRing(
                                    progress: emScore / 100.0,
                                    centerPrimary: emPct,
                                    centerSecondary: l.dashboardRingState,
                                    size: rw,
                                    strokeWidth: 4,
                                    ringColor: PaychekWebTokens.accentMint,
                                    trackColor: trackWeb,
                                    showInnerSecondary: false,
                                    onTap: onOpenEtatMental,
                                  ),
                                  caption: l.dashboardRingState,
                                ),
                                _webRingCaption(
                                  ring: ChecklistProgressRing(
                                    percent: checklistPct,
                                    size: rw,
                                    strokeWidth: 4,
                                    hideInnerClLabel: true,
                                    onTap: onOpenChecklist,
                                  ),
                                  caption: l.checklistProgressCl,
                                ),
                                if (analyseSnap != null && openAnalyse != null)
                                  _webRingCaption(
                                    ring: DashboardAnalysePrepRing(
                                      snapshot: analyseSnap,
                                      size: rw,
                                      strokeWidth: 4,
                                      ringColor: PaychekWebTokens.accentMint,
                                      trackColor: trackWeb,
                                      onTap: openAnalyse,
                                    ),
                                    caption: l.dashboardRingAnalyseWeb,
                                  ),
                              ];

                              return _CapitalBalanceWebRingsRow(
                                items: items,
                                ringSize: rw,
                                maxWidth: constraints.maxWidth,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Transform.translate(
                          offset: const Offset(-8, 0),
                          child: Text(
                            l.dashboardCapitalBalanceHeader,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: DashboardTokens.muted,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (!hideTimeframePills) const Spacer(),
                        if (!hideTimeframePills)
                          TimeframePills(
                            labels: tfLabels,
                            selectedIndex: timeframeIndex,
                            onChanged: onTimeframeChanged,
                          ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, rowConstraints) {
                      final ringCount =
                          (analyseSnap != null && openAnalyse != null) ? 4 : 3;
                      final ringSize =
                          _CapitalBalanceRingsLayout.mobileRingSize(
                        rowMaxWidth: rowConstraints.maxWidth,
                        bottomRingCount: ringCount,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Transform.translate(
                                  offset: const Offset(-4, -10),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: mainAmount,
                                          style: amountStyle,
                                        ),
                                        TextSpan(
                                          text: ' $sym',
                                          style: amountStyle?.copyWith(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    periodNet < 0
                                        ? Icons.trending_down
                                        : Icons.trending_up,
                                    color: deltaColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '$signedDelta ',
                                              style: soldeDeltaStyle?.copyWith(
                                                color: deltaColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            TextSpan(
                                              text: sym,
                                              style: soldeDeltaStyle?.copyWith(
                                                fontSize: 9.5,
                                                color: deltaColor,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                      ),
                                      if (signedPct != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          signedPct,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                          style: soldeDeltaStyle?.copyWith(
                                            color: deltaColor.withValues(
                                              alpha: 0.85,
                                            ),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _CapitalBalanceMobileRingsRow(
                            ringSize: ringSize,
                            win: win,
                            emScore: emScore,
                            emPct: emPct,
                            checklistPct: checklistPct,
                            analyseSnapshot: analyseSnap,
                            onOpenPerformance: onOpenPerformance,
                            onOpenEtatMental: onOpenEtatMental,
                            onOpenChecklist: onOpenChecklist,
                            onOpenAnalyse: openAnalyse,
                          ),
                        ],
                      );
                    },
                  ),
                  if (!kIsWeb && onOpenTradeById != null) ...[
                    const CapitalEvolutionMergedDivider(),
                    CapitalEvolutionChartSection(
                      timeframeIndex: timeframeIndex,
                      onOpenTradeById: onOpenTradeById!,
                      onOpenTradeDayKey: onOpenTradeDayKey,
                    ),
                  ],
                ],
              ),
            );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Espacement anneaux carte Capital (web + mobile).
abstract final class _CapitalBalanceRingsLayout {
  _CapitalBalanceRingsLayout._();

  static const double webGap = 12;
  static const double webWrapSpacing = 28;
  static const double webWrapRunSpacing = 20;
  static const double mobileGap = 14;
  static const double mobileRingMax = 56;
  static const double mobileRingCompactMax = 50;

  /// Taille anneaux mobile (une seule ligne, espacement via [MainAxisAlignment.spaceBetween]).
  static double mobileRingSize({
    required double rowMaxWidth,
    required int bottomRingCount,
  }) {
    const minSize = 38.0;
    const minGap = mobileGap;
    final preferred =
        bottomRingCount >= 4 ? mobileRingCompactMax : mobileRingMax;
    final needed =
        preferred * bottomRingCount + (minGap * (bottomRingCount - 1));
    if (rowMaxWidth >= needed) return preferred;
    final fitted =
        (rowMaxWidth - minGap * (bottomRingCount - 1)) / bottomRingCount;
    return fitted.clamp(minSize, preferred);
  }

  static double mobileStrokeForSize(double size) =>
      size >= 50 ? 5.0 : (size >= 42 ? 4.5 : 4.0);
}

class _CapitalBalanceWebRingsRow extends StatelessWidget {
  const _CapitalBalanceWebRingsRow({
    required this.items,
    required this.ringSize,
    required this.maxWidth,
  });

  final List<Widget> items;
  final double ringSize;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final n = items.length;
    final minRow =
        (ringSize * n) + (_CapitalBalanceRingsLayout.webGap * (n - 1));
    if (maxWidth < minRow + 24) {
      return Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: _CapitalBalanceRingsLayout.webWrapSpacing,
          runSpacing: _CapitalBalanceRingsLayout.webWrapRunSpacing,
          children: items,
        ),
      );
    }
    return Row(
      children: [
        for (var i = 0; i < n; i++) ...[
          if (i > 0) const SizedBox(width: _CapitalBalanceRingsLayout.webGap),
          Expanded(
            child: Center(child: items[i]),
          ),
        ],
      ],
    );
  }
}

class _CapitalBalanceMobileRingsRow extends StatelessWidget {
  const _CapitalBalanceMobileRingsRow({
    required this.ringSize,
    required this.win,
    required this.emScore,
    required this.emPct,
    required this.checklistPct,
    this.analyseSnapshot,
    required this.onOpenPerformance,
    required this.onOpenEtatMental,
    required this.onOpenChecklist,
    this.onOpenAnalyse,
  });

  final double ringSize;
  final int win;
  final double emScore;
  final String emPct;
  final int checklistPct;
  final AnalyseReportSnapshot? analyseSnapshot;
  final VoidCallback onOpenPerformance;
  final VoidCallback onOpenEtatMental;
  final VoidCallback onOpenChecklist;
  final VoidCallback? onOpenAnalyse;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final stroke = _CapitalBalanceRingsLayout.mobileStrokeForSize(ringSize);

    final rings = <Widget>[
      DonutRing(
        progress: win / 100.0,
        centerPrimary: '$win%',
        centerSecondary: l.dashboardRingWin,
        size: ringSize,
        strokeWidth: stroke,
        onTap: onOpenPerformance,
      ),
      DonutRing(
        progress: emScore / 100.0,
        centerPrimary: emPct,
        centerSecondary: l.dashboardRingState,
        size: ringSize,
        strokeWidth: stroke,
        ringColor: MentalStateTokens.ringStrokeForScore(emScore),
        onTap: onOpenEtatMental,
      ),
      ChecklistProgressRing(
        percent: checklistPct,
        size: ringSize,
        strokeWidth: stroke,
        onTap: onOpenChecklist,
      ),
      if (analyseSnapshot != null && onOpenAnalyse != null)
        DashboardAnalysePrepRing(
          snapshot: analyseSnapshot!,
          size: ringSize,
          strokeWidth: stroke,
          onTap: onOpenAnalyse,
          centerSecondary: l.dashboardRingAnalyseMobile,
        ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rings,
    );
  }
}

Widget _webRingCaption({
  required Widget ring,
  required String caption,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ring,
      const SizedBox(height: 8),
      Text(
        caption.toUpperCase(),
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: PaychekWebTokens.textGray500,
        ),
      ),
    ],
  );
}

String _formatSignedAmount(double amount) {
  final v = amount;
  final sign = v >= 0 ? '+' : '-';
  final abs = v.abs();
  if (abs == abs.roundToDouble()) {
    return '$sign${_separateThousands(abs.round())}';
  }
  final s = abs.toStringAsFixed(2).replaceAll('.', ',');
  return '$sign$s';
}

String _formatMainAmount(double? amount) {
  if (amount == null) return '10 450,00';
  final v = amount;
  final sign = v < 0 ? '-' : '';
  final fixed = v.abs().toStringAsFixed(2);
  final dot = fixed.indexOf('.');
  final intVal = int.parse(fixed.substring(0, dot));
  final dec = fixed.substring(dot + 1);
  return '$sign${_separateThousands(intVal)},$dec';
}

String _separateThousands(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  if (n < 0) buf.write('-');
  final len = s.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}



