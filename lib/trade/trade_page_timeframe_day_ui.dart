part of 'trade_page.dart';

extension _TradePageTimeframeDayUi on _TradePageState {
  Widget _dayDetailCardHeader({
    required BuildContext context,
    required AppLocalizations l10n,
    required DateTime dLocal,
    required int count,
    required double? pct,
    required double avg,
    required double net,
    required String dayKey,
    required VoidCallback onExportPdf,
  }) {
    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDayLabel(context, dLocal),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              _tradesLabel(context, count),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TradeTokens.textDate,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              pct == null
                  ? '—'
                  : '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2).replaceAll('.', ',')}%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: pct == null
                        ? TradeTokens.textSecondary
                        : (pct < 0
                            ? TradeTokens.lossNeon
                            : (pct == 0
                                ? Colors.white
                                : TradeTokens.profitNeon)),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1.05,
                  ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.tradeAverageShort,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TradeTokens.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.6,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              '${_formatMoney(avg)}\$',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color:
                        avg < 0 ? TradeTokens.lossNeon : TradeTokens.profitNeon,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1.05,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.tradeGainShort,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TradeTokens.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.6,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              '${_formatMoney(net)}\$',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: net < 0
                        ? TradeTokens.lossNeon
                        : (net == 0 ? Colors.white : TradeTokens.profitNeon),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1.05,
                  ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: l10n.tradeExportPdfTooltip,
          onPressed: onExportPdf,
          icon: const Icon(Icons.picture_as_pdf_rounded),
          color: TradeTokens.textSecondary,
          iconSize: 18,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 2),
        Icon(
          _expandedDayKey == dayKey
              ? Icons.expand_less_rounded
              : Icons.expand_more_rounded,
          color: TradeTokens.textSecondary,
          size: 18,
        ),
      ],
    );
  }

  Widget _dayDetailCardExpanded({
    required BuildContext context,
    required AppLocalizations l10n,
    required int winDay,
    required double? avgChecklist,
    required double? avgPlan,
    required double? avgStrategie,
    required double? avgEtat,
    required int wDay,
    required int lDay,
    required int bDay,
    required int principeCount,
    required int feelingCount,
    required Map<String, int> counts,
    required int maxCount,
    required List<TradeListItem> dayTrades,
    required Widget Function({
      required String title,
      required double? pctVal,
      required Color color,
    }) ringCell,
    required Widget Function(TradeListItem t) tradeRowFor,
  }) {
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
                    child: ringCell(
                      title: l10n.tradeLabelChecklist,
                      pctVal: avgChecklist,
                      color: TradeTokens.profitNeon,
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: ringCell(
                      title: l10n.tradeLabelPlan,
                      pctVal: avgPlan,
                      color: TradeTokens.mustard,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: Center(
                      child: DonutRing(
                        progress: (winDay / 100.0).clamp(0.0, 1.0),
                        centerPrimary: '$winDay%',
                        centerSecondary: l10n.tradeWinDayRingSubtitle,
                        size: 64,
                        strokeWidth: 6,
                        ringColor: winDay < 50
                            ? TradeTokens.lossNeon
                            : TradeTokens.profitNeon,
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
                          count: wDay,
                          color: TradeTokens.profitNeon,
                        ),
                        const SizedBox(width: 8),
                        _wlbChip(
                          context,
                          label: 'L',
                          count: lDay,
                          color: TradeTokens.lossNeon,
                        ),
                        const SizedBox(width: 8),
                        _wlbChip(
                          context,
                          label: 'B',
                          count: bDay,
                          color: TradeTokens.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: const SizedBox.shrink(),
                  ),
                  SizedBox(
                    width: itemW,
                    child: ringCell(
                      title: l10n.tradeLabelStrategie,
                      pctVal: avgStrategie,
                      color: const Color(0xFF6EA8FF),
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: ringCell(
                      title: l10n.tradeLabelEtat,
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
                label: l10n.tradeMindsetPrinciple,
                count: principeCount,
                color: TradeTokens.profitNeon,
              ),
              const SizedBox(width: 8),
              _mindsetChip(
                context,
                icon: Icons.psychology_alt_rounded,
                label: l10n.tradeMindsetFeeling,
                count: feelingCount,
                color: TradeTokens.lossNeon,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sessionBar(
            context,
            label: l10n.tradeSessionAsia,
            count: counts[kTradeSessionAsia] ?? 0,
            maxCount: maxCount,
            barColor: const Color(0xFF6EA8FF),
          ),
          const SizedBox(height: 8),
          _sessionBar(
            context,
            label: l10n.tradeSessionEurope,
            count: counts[kTradeSessionEurope] ?? 0,
            maxCount: maxCount,
            barColor: TradeTokens.mustard,
          ),
          const SizedBox(height: 8),
          _sessionBar(
            context,
            label: l10n.tradeSessionUs,
            count: counts[kTradeSessionUs] ?? 0,
            maxCount: maxCount,
            barColor: TradeTokens.profitNeon,
          ),
          const SizedBox(height: 8),
          _sessionBar(
            context,
            label: l10n.tradeSessionLate,
            count: counts[kTradeSessionLate] ?? 0,
            maxCount: maxCount,
            barColor: TradeTokens.textSecondary,
          ),
          if (dayTrades.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.tradeTradesListHeading,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: TradeTokens.mustard,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: 8),
            for (final t in (dayTrades.toList()
              ..sort((a, b) => b.entreeAt.compareTo(a.entreeAt))))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: tradeRowFor(t),
              ),
          ],
        ],
      ),
    );
  }
}
