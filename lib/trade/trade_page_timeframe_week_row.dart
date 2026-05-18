part of 'trade_page.dart';

extension _TradePageTimeframeWeekRow on _TradePageState {
  Widget _timeframeWeekDetailRow(
    BuildContext context,
    DateTime monday,
    List<TradeListItem> weekTrades, {
    required Map<String, GlobalKey> tradeKeys,
  }) {
    final weekKey = _weekKey(monday);
    final count = weekTrades.length;
    final net = weekTrades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
    final avg = count <= 0 ? 0.0 : (net / count);
    final cap = UserPortfolioScope.of(context)
        .effectiveCapitalAmount(UserCapitalScope.of(context));
    final pct = (cap != null && cap > 0) ? (net / cap) * 100.0 : null;
    final n = TradingWeekScope.of(context).tradingDaysPerWeek;
    final weekDays =
        List<DateTime>.generate(n, (i) => monday.add(Duration(days: i)));
    final weekBars = _weekDailyNetForDays(weekTrades, weekDays);
    final weekCountBars = _weekDailyCountForDays(weekTrades, weekDays);

    final rangeEnd = weekDays.last;
    final rangeLabel =
        '${_formatDayLabel(context, monday)} - ${_formatDayLabel(context, rangeEnd)}';

    double avgPct(List<double> xs) =>
        xs.isEmpty ? 0.0 : (xs.fold<double>(0.0, (a, b) => a + b) / xs.length);

    final avgChecklist = avgPct(weekTrades.map((e) => e.checklistPct).toList());
    final avgPlan = avgPct(weekTrades.map((e) => e.planPct).toList());
    final avgStrategie = avgPct(weekTrades.map((e) => e.strategiePct).toList());
    final avgEtat = avgPct(weekTrades.map((e) => e.etatPct).toList());
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

    String hm(DateTime d) {
      String p2(int v) => v.toString().padLeft(2, '0');
      final l = d.toLocal();
      return '${p2(l.hour)}:${p2(l.minute)}';
    }

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
              _expandedWeekKey = null;
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
                        '${hm(t.entreeAt)} • ${tradeSessionLabel(rowL, tradeSessionBucketId(t.entreeAt))}',
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
              avgChecklist: avgChecklist,
              avgPlan: avgPlan,
              avgStrategie: avgStrategie,
              avgEtat: avgEtat,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _safeSetState(() {
          _expandedWeekKey = _expandedWeekKey == weekKey ? null : weekKey;
          if (_expandedWeekKey != weekKey) {
            _weekSelectedDayIndexByKey.remove(weekKey);
          }
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
