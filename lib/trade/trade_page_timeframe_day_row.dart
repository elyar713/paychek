part of 'trade_page.dart';

extension _TradePageTimeframeDayRow on _TradePageState {
  Widget _timeframeDayRow(
    BuildContext context,
    DateTime day,
    List<TradeListItem> dayTrades, {
    required List<TradeListItem> allRaw,
    required Map<String, GlobalKey> tradeKeys,
  }) {
    final dLocal = day.toLocal();
    final dayKey = '${dLocal.year.toString().padLeft(4, '0')}-'
        '${dLocal.month.toString().padLeft(2, '0')}-'
        '${dLocal.day.toString().padLeft(2, '0')}';
    final count = dayTrades.length;
    final net = dayTrades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
    final avg = count <= 0 ? 0.0 : (net / count);
    final baseCap = UserPortfolioScope.of(context)
        .effectiveCapitalAmount(UserCapitalScope.of(context));
    final pct = gainPctOfReferenceCapital(
      net,
      capitalAtDayStart(
        baseCapital: baseCap,
        day: dLocal,
        allTrades: allRaw,
      ),
    );

    final avgChecklistVal = averageExplicitChecklistPct(dayTrades);
    final avgPlanVal = averageExplicitPlanPct(dayTrades);
    final avgStrategieVal = averageExplicitStrategiePct(dayTrades);
    final avgEtatVal = averageExplicitEtatPct(dayTrades);
    final winDay = computeTradeStats(dayTrades).winRatePctDisplay;
    final principeCount =
        dayTrades.where((e) => e.mindset == TradeMindset.principe).length;
    final feelingCount =
        dayTrades.where((e) => e.mindset == TradeMindset.feeling).length;
    final wDay = dayTrades.where((e) => e.countsAsClosedWin).length;
    final lDay = dayTrades.where((e) => e.countsAsClosedLoss).length;
    final bDay =
        dayTrades.where((e) => e.countsAsClosedBreakevenOrFlat).length;

    final counts = tradeSessionCountsEmpty();
    for (final t in dayTrades) {
      final id = tradeSessionBucketId(t.entreeAt);
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final maxCount = counts.values.fold<int>(0, (a, b) => a > b ? a : b);
    final capitalBeforeById = baseCap != null
        ? capitalBeforeTradeById(baseCapital: baseCap, allTrades: allRaw)
        : null;

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

    final loc = AppLocalizations.of(context)!;
    final header = _dayDetailCardHeader(
      context: context,
      l10n: loc,
      dLocal: dLocal,
      count: count,
      pct: pct,
      avg: avg,
      net: net,
      dayKey: dayKey,
      onExportPdf: () async {
        final sessionCounts = counts;
        if (!context.mounted) return;
        final lPdf = AppLocalizations.of(context)!;
        final checklist = await checklistControllerReadyForPdfExport(
          widget.checklistController,
        );
        final storedReports = await loadAnalyseReportsForPdfExport();
        final disciplineAvgs = averageDisciplineDisplayForTrades(
          dayTrades,
          checklist,
          storedReports,
        );
        if (!context.mounted) return;
        final bytes = await buildTradeTimeframePdf(
          l: lPdf,
          title: lPdf.tradePdfExportDayTitle,
          rangeLabel: _formatDayLabel(context, dLocal),
          count: count,
          net: net,
          avg: avg,
          pct: pct,
          winRatePct: winDay,
          avgChecklist: disciplineAvgs.checklist,
          avgPlan: disciplineAvgs.plan,
          avgStrategie: disciplineAvgs.strategie,
          avgEtat: disciplineAvgs.etat,
          principeCount: principeCount,
          feelingCount: feelingCount,
          sessionCounts: sessionCounts,
          trades: dayTrades,
        );
        final filename = 'trades_day_$dayKey.pdf';
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
      child: _expandedDayKey == dayKey
          ? _dayDetailCardExpanded(
              context: context,
              l10n: loc,
              winDay: winDay,
              avgChecklist: avgChecklistVal,
              avgPlan: avgPlanVal,
              avgStrategie: avgStrategieVal,
              avgEtat: avgEtatVal,
              wDay: wDay,
              lDay: lDay,
              bDay: bDay,
              principeCount: principeCount,
              feelingCount: feelingCount,
              counts: counts,
              maxCount: maxCount,
              dayTrades: dayTrades,
              ringCell: ringCell,
              tradeRowFor: (t) => _buildExpandableTradeCard(
                    context,
                    t,
                    tradeKeys,
                    allRaw,
                    capitalBeforeById: capitalBeforeById,
                  ),
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
                if (_expandedDayKey == dayKey) {
                  _expandedDayKey = null;
                  if (dayTrades.any((t) => t.id == _expandedTradeId)) {
                    _expandedTradeId = null;
                  }
                } else {
                  _expandedDayKey = dayKey;
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
