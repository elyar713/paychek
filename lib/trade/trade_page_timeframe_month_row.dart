part of 'trade_page.dart';

extension _TradePageTimeframeMonthRow on _TradePageState {
  Widget _timeframeMonthDetailRow(
    BuildContext context,
    DateTime monthStart,
    List<TradeListItem> monthTrades, {
    required Map<String, GlobalKey> tradeKeys,
  }) {
    final nextMonth = (monthStart.month == 12)
        ? DateTime(monthStart.year + 1, 1, 1)
        : DateTime(monthStart.year, monthStart.month + 1, 1);

    final monthKey = _monthKey(monthStart);

    final count = monthTrades.length;
    final net = monthTrades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
    final avg = count <= 0 ? 0.0 : (net / count);
    final cap = UserPortfolioScope.of(context)
        .effectiveCapitalAmount(UserCapitalScope.of(context));
    final pct = (cap != null && cap > 0) ? (net / cap) * 100.0 : null;

    double avgPct(List<double> xs) =>
        xs.isEmpty ? 0.0 : (xs.fold<double>(0.0, (a, b) => a + b) / xs.length);

    final avgChecklist = avgPct(monthTrades.map((e) => e.checklistPct).toList());
    final avgPlan = avgPct(monthTrades.map((e) => e.planPct).toList());
    final avgStrategie = avgPct(monthTrades.map((e) => e.strategiePct).toList());
    final avgEtat = avgPct(monthTrades.map((e) => e.etatPct).toList());
    final winMonth = computeTradeStats(monthTrades).winRatePctDisplay;
    final principeCount =
        monthTrades.where((e) => e.mindset == TradeMindset.principe).length;
    final feelingCount =
        monthTrades.where((e) => e.mindset == TradeMindset.feeling).length;
    final wMonth = monthTrades.where((e) => e.countsAsClosedWin).length;
    final lMonth = monthTrades.where((e) => e.countsAsClosedLoss).length;
    final bMonth =
        monthTrades.where((e) => e.countsAsClosedBreakevenOrFlat).length;

    final counts = tradeSessionCountsEmpty();
    for (final t in monthTrades) {
      final id = tradeSessionBucketId(t.entreeAt);
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final maxCount = counts.values.fold<int>(0, (a, b) => a > b ? a : b);

    final loc = AppLocalizations.of(context)!;

    Widget rowTrade(TradeListItem t) {
      final rowL = AppLocalizations.of(context)!;
      final sideLabel = t.breakeven
          ? rowL.tradeSideBreakevenShort
          : (t.side == TradeSide.achat
              ? rowL.tradeSideBuyShort
              : rowL.tradeSideSellShort);
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
          onTap: () {
            _safeSetState(() {
              _timeframeIndex = 3; // ALL
              _expandedTradeId = t.id;
              _expandedMonthKey = null;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToTrade(t.id, tradeKeys);
            });
          },
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
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
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
                        _formatTradeRowWhenLine(
                          context,
                          t.entreeAt,
                          sessionLabel: tradeSessionLabel(
                            rowL,
                            tradeSessionBucketId(t.entreeAt),
                          ),
                          withDate: true,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: TradeTokens.textDate,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                      ),
                      buildTradePsychTagsRow(t),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_formatMoney(t.gainAmount)}\$',
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

    Widget ringCell({
      required String title,
      required double pctVal,
      required Color color,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.tradeAverageShort,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: TradeTokens.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 8,
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: 4),
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

    final rangeLabel =
        '${_formatDayLabel(context, monthStart)} - ${_formatDayLabel(context, nextMonth.subtract(const Duration(days: 1)))}';

    final monthSparklineCumulative =
        _monthCumulativeDailyPnl(monthTrades, monthStart, nextMonth);

    final header = _monthDetailCardHeader(
      context: context,
      l10n: loc,
      monthStart: monthStart,
      rangeLabel: rangeLabel,
      count: count,
      avg: avg,
      net: net,
      pct: pct,
      monthSparklineCumulative: monthSparklineCumulative,
      monthCardExpanded: _expandedMonthKey == monthKey,
      onExportPdf: () async {
        await exportMonthPdf(
          context: context,
          monthStart: monthStart,
          monthTrades: monthTrades,
          initialCapital: cap,
          filenamePrefix: 'trades_month',
          checklistController: widget.checklistController,
        );
      },
    );

    final expanded = AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: _expandedMonthKey == monthKey
          ? _monthDetailCardExpanded(
              context: context,
              l10n: loc,
              avgChecklist: avgChecklist,
              avgPlan: avgPlan,
              winMonth: winMonth,
              avgStrategie: avgStrategie,
              avgEtat: avgEtat,
              wMonth: wMonth,
              lMonth: lMonth,
              bMonth: bMonth,
              principeCount: principeCount,
              feelingCount: feelingCount,
              counts: counts,
              maxCount: maxCount,
              monthStart: monthStart,
              nextMonth: nextMonth,
              monthTrades: monthTrades,
              monthSparklineCumulative: monthSparklineCumulative,
              daysInMonth: nextMonth.difference(monthStart).inDays,
              ringCell: ringCell,
              rowTrade: rowTrade,
            )
          : const SizedBox.shrink(),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _safeSetState(() {
          _expandedMonthKey = _expandedMonthKey == monthKey ? null : monthKey;
        }),
        borderRadius: BorderRadius.circular(TradeTokens.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: TradeTokens.cardBg,
            borderRadius: BorderRadius.circular(TradeTokens.radiusLg),
            border: Border.all(color: TradeTokens.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              expanded,
            ],
          ),
        ),
      ),
    );
  }
}
