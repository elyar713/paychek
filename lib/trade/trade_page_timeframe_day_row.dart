part of 'trade_page.dart';

extension _TradePageTimeframeDayRow on _TradePageState {
  Widget _timeframeDayRow(
    BuildContext context,
    DateTime day,
    List<TradeListItem> dayTrades, {
    required Map<String, GlobalKey> tradeKeys,
  }) {
    final dLocal = day.toLocal();
    final dayKey = '${dLocal.year.toString().padLeft(4, '0')}-'
        '${dLocal.month.toString().padLeft(2, '0')}-'
        '${dLocal.day.toString().padLeft(2, '0')}';
    final count = dayTrades.length;
    final net = dayTrades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
    final avg = count <= 0 ? 0.0 : (net / count);
    final cap = UserPortfolioScope.of(context)
        .effectiveCapitalAmount(UserCapitalScope.of(context));
    final pct = (cap != null && cap > 0) ? (net / cap) * 100.0 : null;

    double avgPct(List<double> xs) =>
        xs.isEmpty ? 0.0 : (xs.fold<double>(0.0, (a, b) => a + b) / xs.length);

    final avgChecklist = avgPct(dayTrades.map((e) => e.checklistPct).toList());
    final avgPlan = avgPct(dayTrades.map((e) => e.planPct).toList());
    final avgStrategie = avgPct(dayTrades.map((e) => e.strategiePct).toList());
    final avgEtat = avgPct(dayTrades.map((e) => e.etatPct).toList());
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

    String hm(DateTime d) {
      String p2(int v) => v.toString().padLeft(2, '0');
      final l = d.toLocal();
      return '${p2(l.hour)}:${p2(l.minute)}';
    }

    Widget dayTradeRow(
      TradeListItem t, {
      required VoidCallback onTap,
    }) {
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
          onTap: onTap,
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

    final expanded = AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: _expandedDayKey == dayKey
          ? _dayDetailCardExpanded(
              context: context,
              l10n: loc,
              winDay: winDay,
              avgChecklist: avgChecklist,
              avgPlan: avgPlan,
              avgStrategie: avgStrategie,
              avgEtat: avgEtat,
              wDay: wDay,
              lDay: lDay,
              bDay: bDay,
              principeCount: principeCount,
              feelingCount: feelingCount,
              counts: counts,
              maxCount: maxCount,
              dayTrades: dayTrades,
              ringCell: ringCell,
              tradeRowFor: (t) => dayTradeRow(
                    t,
                    onTap: () {
                      _safeSetState(() {
                        _timeframeIndex = 3; // ALL
                        _expandedTradeId = t.id;
                        _expandedDayKey = null;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToTrade(t.id, tradeKeys);
                      });
                    },
                  ),
            )
          : const SizedBox.shrink(),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _safeSetState(() {
          _expandedDayKey = _expandedDayKey == dayKey ? null : dayKey;
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
