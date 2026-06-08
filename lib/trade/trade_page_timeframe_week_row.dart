part of 'trade_page.dart';

extension _TradePageTimeframeWeekRow on _TradePageState {
  Widget _timeframeWeekDetailRow(
    BuildContext context,
    DateTime monday,
    List<TradeListItem> weekTrades, {
    required List<TradeListItem> allRaw,
    required Map<String, GlobalKey> tradeKeys,
  }) {
    final weekKey = _weekKey(monday);
    final count = weekTrades.length;
    final net = weekTrades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
    final avg = count <= 0 ? 0.0 : (net / count);
    final baseCap = UserPortfolioScope.of(context)
        .effectiveCapitalAmount(UserCapitalScope.of(context));
    final pct = gainPctOfReferenceCapital(
      net,
      capitalAtWeekStart(
        baseCapital: baseCap,
        weekMonday: monday,
        allTrades: allRaw,
      ),
    );
    final n = TradingWeekScope.of(context).tradingDaysPerWeek;
    final weekDays =
        List<DateTime>.generate(n, (i) => monday.add(Duration(days: i)));
    final weekBars = _weekDailyNetForDays(weekTrades, weekDays);
    final weekCountBars = _weekDailyCountForDays(weekTrades, weekDays);

    final rangeEnd = weekDays.last;
    final rangeLabel =
        '${_formatDayLabel(context, monday)} - ${_formatDayLabel(context, rangeEnd)}';

    final avgChecklistVal = averageExplicitChecklistPct(weekTrades);
    final avgPlanVal = averageExplicitPlanPct(weekTrades);
    final avgStrategieVal = averageExplicitStrategiePct(weekTrades);
    final avgEtatVal = averageExplicitEtatPct(weekTrades);
    final winWeek = computeTradeStats(weekTrades).winRatePctDisplay;
    final principeCount =
        weekTrades.where((e) => e.mindset == TradeMindset.principe).length;
    final feelingCount =
        weekTrades.where((e) => e.mindset == TradeMindset.feeling).length;
    final wWeek = weekTrades.where((e) => e.countsAsClosedWin).length;
    final lWeek = weekTrades.where((e) => e.countsAsClosedLoss).length;
    final bWeek =
        weekTrades.where((e) => e.countsAsClosedBreakevenOrFlat).length;

    final counts = tradeSessionCountsEmpty();
    for (final t in weekTrades) {
      final id = tradeSessionBucketId(t.entreeAt);
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final maxCount = counts.values.fold<int>(0, (a, b) => a > b ? a : b);
    final weekNetBars = weekBars;

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

    final header = _weekDetailCardHeader(
      context: context,
      l10n: loc,
      rangeLabel: rangeLabel,
      count: count,
      weekBars: weekBars,
      weekCountBars: weekCountBars,
      avg: avg,
      net: net,
      pct: pct,
      weekKey: weekKey,
      onExportPdf: () async {
        final sessionCounts = counts;
        if (!context.mounted) return;
        final lPdf = AppLocalizations.of(context)!;
        final localeTag = Localizations.localeOf(context).toString();
        final weekDayLabels = weekDays
            .map((d) => DateFormat.E(localeTag).format(d))
            .toList();
        final checklist = await checklistControllerReadyForPdfExport(
          widget.checklistController,
        );
        final storedReports = await loadAnalyseReportsForPdfExport();
        final disciplineAvgs = averageDisciplineDisplayForTrades(
          weekTrades,
          checklist,
          storedReports,
        );
        if (!context.mounted) return;
        final bytes = await buildTradeTimeframePdf(
          l: lPdf,
          title: lPdf.tradePdfExportWeekTitle,
          rangeLabel: rangeLabel,
          count: count,
          net: net,
          avg: avg,
          pct: pct,
          winRatePct: winWeek,
          avgChecklist: disciplineAvgs.checklist,
          avgPlan: disciplineAvgs.plan,
          avgStrategie: disciplineAvgs.strategie,
          avgEtat: disciplineAvgs.etat,
          principeCount: principeCount,
          feelingCount: feelingCount,
          sessionCounts: sessionCounts,
          weekDayLabels: weekDayLabels,
          weekBars: weekBars,
          trades: weekTrades,
        );
        final filename = 'trades_week_$weekKey.pdf';
        if (!context.mounted) return;
        await exportTradeTimeframePdf(
          context,
          bytes: bytes,
          filename: filename,
        );
      },
    );

    final expanded = AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: _expandedWeekKey == weekKey
          ? _weekDetailCardExpanded(
              context: context,
              l10n: loc,
              weekKey: weekKey,
              weekNetBars: weekNetBars,
              weekCountBars: weekCountBars,
              net: net,
              winWeek: winWeek,
              avgChecklist: avgChecklistVal,
              avgPlan: avgPlanVal,
              avgStrategie: avgStrategieVal,
              avgEtat: avgEtatVal,
              wWeek: wWeek,
              lWeek: lWeek,
              bWeek: bWeek,
              principeCount: principeCount,
              feelingCount: feelingCount,
              counts: counts,
              maxCount: maxCount,
              weekTrades: weekTrades,
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
                if (_expandedWeekKey == weekKey) {
                  _expandedWeekKey = null;
                  _weekSelectedDayIndexByKey.remove(weekKey);
                  if (weekTrades.any((t) => t.id == _expandedTradeId)) {
                    _expandedTradeId = null;
                  }
                } else {
                  _expandedWeekKey = weekKey;
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
