import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../trade/trade_models.dart';
import '../trade/trade_stats.dart';
import '../questionnaire/user_capital_scope.dart';
import '../reglage/user_portfolio_scope.dart';
import 'calendrier_constants.dart';
import 'calendrier_utils.dart';

class CalendrierMonthInfo extends StatelessWidget {
  const CalendrierMonthInfo({
    super.key,
    required this.monthTradesList,
    required this.monthlyObjective,
    required this.onShowObjectiveDialog,
  });

  final List<TradeListItem> monthTradesList;
  final double? monthlyObjective;
  final VoidCallback onShowObjectiveDialog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final winPct = computeTradeStats(monthTradesList).winRatePctDisplay;
    final totalCount = monthTradesList.length;
    final net = monthTradesList.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
    final capStore = UserCapitalScope.of(context);
    final pf = UserPortfolioScope.of(context);
    final cap = pf.effectiveCapitalAmount(capStore);
    final capSymbol = pf.effectiveCurrencySymbol(capStore);
    final pctOfCap = (cap != null && cap > 0) ? (net / cap) * 100.0 : null;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildWinrateCard(context, l, winPct),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTradesCard(context, l, totalCount),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCapitalCard(context, l, net, capSymbol, pctOfCap),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildObjectiveSection(context, l, net, capSymbol),
        ],
      ),
    );
  }

  Widget _buildWinrateCard(
    BuildContext context,
    AppLocalizations l,
    int winPct,
  ) {
    return SizedBox(
      height: kTopInfoCardHeight + 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: kCalCardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCalCardBorderResolved),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l.tradeWinrateLabel,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kWeekdayColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              '$winPct%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradesCard(
    BuildContext context,
    AppLocalizations l,
    int totalCount,
  ) {
    return SizedBox(
      height: kTopInfoCardHeight + 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: kCalCardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCalCardBorderResolved),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$totalCount',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l.tradeTradesListHeading,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: kWeekdayColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Wrap(
              spacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'W: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kWeekdayColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '${monthTradesList.where((t) => t.countsAsClosedWin).length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kGainText,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  'L: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kWeekdayColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '${monthTradesList.where((t) => t.countsAsClosedLoss).length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kLossText,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  'B: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kWeekdayColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '${monthTradesList.where((t) => t.countsAsClosedBreakevenOrFlat).length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: kBreakevenText,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapitalCard(
    BuildContext context,
    AppLocalizations l,
    double net,
    String capSymbol,
    double? pctOfCap,
  ) {
    return SizedBox(
      height: kTopInfoCardHeight + 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: kCalCardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCalCardBorderResolved),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              l.calPnlShort,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kWeekdayColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              formatMoneyWithCurrencySymbol(net, capSymbol),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: net < 0
                        ? kLossText
                        : (net == 0 ? kBreakevenText : kGainText),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              pctOfCap != null
                  ? l.tradePctOfCapital(
                      NumberFormat(
                        '#0.#',
                        Localizations.localeOf(context).toString(),
                      ).format(pctOfCap),
                    )
                  : '\u2014',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kWeekdayColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectiveSection(
    BuildContext context,
    AppLocalizations l,
    double net,
    String capSymbol,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: onShowObjectiveDialog,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.settings_outlined, size: 14, color: kWeekdayColor),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              l.calObjectiveLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: kWeekdayColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
            ),
            const Spacer(),
            Text(
              monthlyObjective != null
                  ? '${formatMoneyWithCurrencySymbol(net, capSymbol)} / ${formatMoneyWithCurrencySymbol(monthlyObjective!, capSymbol)}'
                  : '${formatMoneyWithCurrencySymbol(net, capSymbol)} / \u2014',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: net < 0 ? kLossText : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            if (monthlyObjective == null || monthlyObjective! <= 0) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 8,
                  width: double.infinity,
                  color: const Color(0xFF2A2A2A),
                ),
              );
            }
            
            // Calculer la proportion (peut être négative)
            final ratio = net / monthlyObjective!;
            
            // Si négatif, calculer la largeur basée sur la valeur absolue
            final fraction = ratio < 0 
                ? (net.abs() / monthlyObjective!).clamp(0.0, 1.0)
                : ratio.clamp(0.0, 1.0);
            
            // Couleur basée sur si c'est un gain ou une perte
            final barColor = net >= 0 ? kGainText : kLossText;
            final displayWidth = constraints.maxWidth * fraction;
            
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 8,
                width: double.infinity,
                color: const Color(0xFF2A2A2A),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: displayWidth,
                    height: 8,
                    color: barColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
