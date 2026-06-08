part of 'trade_page.dart';

extension _TradePageTimeframeMonthRow on _TradePageState {
  Widget _timeframeMonthDetailRow(
    BuildContext context,
    DateTime monthStart,
    List<TradeListItem> monthTrades, {
    required List<TradeListItem> allRaw,
    required Map<String, GlobalKey> tradeKeys,
  }) {
    final nextMonth = (monthStart.month == 12)
        ? DateTime(monthStart.year + 1, 1, 1)
        : DateTime(monthStart.year, monthStart.month + 1, 1);

    final monthKey = _monthKey(monthStart);

    final count = monthTrades.length;
    final net = monthTrades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
    final avg = count <= 0 ? 0.0 : (net / count);
    final baseCap = UserPortfolioScope.of(context)
        .effectiveCapitalAmount(UserCapitalScope.of(context));
    final monthRefCap = capitalAtMonthStart(
      baseCapital: baseCap,
      monthStart: monthStart,
      allTrades: allRaw,
    );
    final pct = gainPctOfReferenceCapital(net, monthRefCap);

    final avgChecklistVal = averageExplicitChecklistPct(monthTrades);
    final avgPlanVal = averageExplicitPlanPct(monthTrades);
    final avgStrategieVal = averageExplicitStrategiePct(monthTrades);
    final avgEtatVal = averageExplicitEtatPct(monthTrades);
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

    final capitalBeforeById = baseCap != null
        ? capitalBeforeTradeById(baseCapital: baseCap, allTrades: allRaw)
        : null;
    Widget rowTrade(TradeListItem t) => _buildExpandableTradeCard(
          context,
          t,
          tradeKeys,
          allRaw,
          capitalBeforeById: capitalBeforeById,
        );

    Widget ringCell({
      required String title,
      required double? pctVal,
      required Color color,
    }) {
      final lRing = AppLocalizations.of(context)!;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            lRing.tradeAverageShort,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: TradeTokens.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 8,
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: 4),
          DonutRing(
            progress: pctVal == null ? 0 : (pctVal / 100.0).clamp(0.0, 1.0),
            centerPrimary: pctVal != null
                ? '${pctVal.round()}%'
                : (title == lRing.tradeLabelChecklist
                    ? lRing.tradeChecklistNoData
                    : title == lRing.tradeLabelEtat
                        ? lRing.tradeEtatNoData
                        : title == lRing.tradeLabelStrategie
                            ? lRing.tradeStrategieExecutionNoData
                            : lRing.tradePlanAnalysisNoData),
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
          initialCapital: monthRefCap,
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
              avgChecklist: avgChecklistVal,
              avgPlan: avgPlanVal,
              winMonth: winMonth,
              avgStrategie: avgStrategieVal,
              avgEtat: avgEtatVal,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TradeTokens.cardBg,
        borderRadius: BorderRadius.circular(TradeTokens.radiusLg),
        border: Border.all(color: TradeTokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _safeSetState(() {
                if (_expandedMonthKey == monthKey) {
                  _expandedMonthKey = null;
                  if (monthTrades.any((t) => t.id == _expandedTradeId)) {
                    _expandedTradeId = null;
                  }
                } else {
                  _expandedMonthKey = monthKey;
                }
              }),
              borderRadius: BorderRadius.circular(TradeTokens.radiusLg),
              child: header,
            ),
          ),
          expanded,
        ],
      ),
    );
  }
}
