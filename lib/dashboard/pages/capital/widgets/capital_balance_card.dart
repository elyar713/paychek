import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../checklist/checklist_page_controller.dart';
import '../../../../checklist/checklist_progress_ring.dart';
import '../../../../etat_mental/mental_state_controller.dart';
import '../../../../etat_mental/mental_state_tokens.dart';
import '../../../../questionnaire/user_capital_scope.dart';
import '../../../../reglage/user_portfolio_scope.dart';
import '../../../../trade/trade_journal_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../trade/trade_journal_scope.dart';
import '../../../../trade/trade_stats.dart';
import '../../../../web/paychek_web_tokens.dart';
import '../../../dashboard_tokens.dart';
import '../../../widgets/capital_evolution_chart_section.dart';
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
  final ValueChanged<String>? onOpenTradeById;
  final ValueChanged<String>? onOpenTradeDayKey;
  final bool hideTimeframePills;
  final BoxDecoration? cardDecoration;

  /// Web : ligne Capital + Evolution ([Table]) — [Spacer] pour remplir la hauteur commune.
  final bool webPairStretch;

  /// Mobile : anneaux compacts.
  static const double _ringSize = 45;

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
    return ListenableBuilder(
      listenable: Listenable.merge([store, portfolioStore]),
      builder: (context, _) {
        final baseCapital = portfolioStore.effectiveCapitalAmount(store);
        final sym = portfolioStore.effectiveCurrencySymbol(store);
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
                  listenable: Listenable.merge([tradesStore, portfolioStore]),
                  builder: (context, _) {
                final l = AppLocalizations.of(context)!;
                final tfLabels = [
                  l.dashboardTfDay,
                  l.dashboardTfWeek,
                  l.dashboardTfMonth,
                  l.dashboardTfAll,
                ];
                final allTrades = activeJournalTradesOrDemo(context);
                final win = computeTradeStats(allTrades).winRatePctDisplay;
                final profitNet =
                    allTrades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
                final solde = (baseCapital == null) ? null : (baseCapital + profitNet);
                final mainAmount = _formatMainAmount(solde);
                final pct = (baseCapital != null && baseCapital > 0)
                    ? (profitNet / baseCapital) * 100.0
                    : null;
                final positiveAccent =
                    kIsWeb ? PaychekWebTokens.accentMint : DashboardTokens.accent;
                final deltaColor =
                    profitNet < 0 ? DashboardTokens.negative : positiveAccent;
                final signedDelta = _formatSignedAmount(profitNet);
                final signedPct = pct == null
                    ? null
                    : '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1).replaceAll('.', ',')}%';
                final rw = _ringSizeWeb;
                final trackWeb = const Color(0xFF1F2937);
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
                              profitNet < 0
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
                              ];

                              // En web (rail/split), cette carte peut être rendue très étroite.
                              // On évite les overflows: en dessous d’un seuil, on “wrap” sur plusieurs lignes.
                              final isTight = constraints.maxWidth < (rw * 3) + 48;
                              if (isTight) {
                                return Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 20,
                                    runSpacing: 16,
                                    children: items,
                                  ),
                                );
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: items,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
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
                                      style: amountStyle?.copyWith(fontSize: 17),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  profitNet < 0
                                      ? Icons.trending_down
                                      : Icons.trending_up,
                                  color: deltaColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '$signedDelta ',
                                              style:
                                                  soldeDeltaStyle?.copyWith(
                                                color: deltaColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            TextSpan(
                                              text: sym,
                                              style:
                                                  soldeDeltaStyle?.copyWith(
                                                fontSize: 9.5,
                                                color: deltaColor,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (signedPct != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          signedPct,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DonutRing(
                                progress: win / 100.0,
                                centerPrimary: '$win%',
                                centerSecondary: l.dashboardRingWin,
                                size: _ringSize,
                                strokeWidth: 4,
                                onTap: onOpenPerformance,
                              ),
                              const SizedBox(width: 6),
                              DonutRing(
                                progress: emScore / 100.0,
                                centerPrimary: emPct,
                                centerSecondary: l.dashboardRingState,
                                size: _ringSize,
                                strokeWidth: 4,
                                ringColor: MentalStateTokens.ringStrokeForScore(
                                  emScore,
                                ),
                                onTap: onOpenEtatMental,
                              ),
                              const SizedBox(width: 6),
                              ChecklistProgressRing(
                                percent: checklistPct,
                                size: _ringSize,
                                strokeWidth: 4,
                                onTap: onOpenChecklist,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
  if (amount == null) return '10 450';
  final v = amount;
  if (v == v.roundToDouble()) return _separateThousands(v.round());
  return v.toStringAsFixed(2).replaceAll('.', ',');
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



