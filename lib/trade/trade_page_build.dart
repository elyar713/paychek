part of 'trade_page.dart';

extension _TradePageBuild on _TradePageState {
  Widget _buildTradePage(BuildContext context) {
    final store = TradeJournalScope.of(context);
    final capStore = UserCapitalScope.of(context);
    final pf = UserPortfolioScope.of(context);
    final tradingWeek = TradingWeekScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([store, capStore, pf, tradingWeek]),
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        final allRaw = activeJournalTradesOrDemo(context);
        final items = _visibleItems.toList();
        for (final it in items) {
          _tradeKeysById.putIfAbsent(it.id, GlobalKey.new);
        }
        _tradeKeysById.removeWhere((id, _) => !items.any((e) => e.id == id));
        final tradeKeys = <String, GlobalKey>{
          for (final it in items) it.id: _tradeKeysById[it.id]!,
        };

        // Bandeau du haut : même périmètre que les compteurs W/L/B/O (filtre paire
        // « plus tradés »). Le timeframe n’applique qu’à la liste / cartes.
        final baseForBar = _pairFilter == null
            ? allRaw
            : allRaw.where((e) => e.pair == _pairFilter).toList();
        final s = _stats(baseForBar);
        final win = computeTradeStats(baseForBar).winRatePctDisplay;
        final openPositions = baseForBar.where((e) => e.sortieAt == null).toList();
        final openCount = openPositions.length;
        final cap = pf.effectiveCapitalAmount(capStore);
        final pctNetVsCapital =
            (cap != null && cap > 0) ? (s.net / cap) * 100.0 : null;
        final mostTraded = _mostTradedPairs(allRaw);

        final countAll = baseForBar.length;
        final countW =
            baseForBar.where((e) => e.countsAsClosedWin).length;
        final countL =
            baseForBar.where((e) => e.countsAsClosedLoss).length;
        final countB = baseForBar
            .where((e) => e.countsAsClosedBreakevenOrFlat)
            .length;
        final countOpen = baseForBar.where((e) => e.sortieAt == null).length;

        return ColoredBox(
          color: TradeTokens.bg,
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hPad = PaychekPageHeader.horizontalPad(constraints.maxWidth);
                final maxW = math.min(
                  1180.0,
                  math.max(0.0, constraints.maxWidth - 2 * hPad),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PaychekPageHeader(
                      onBack: widget.onNavigateToDashboard,
                      reserveLeadingWidthWhenNoBack:
                          widget.onNavigateToDashboard == null,
                      title: l.navTrade,
                      subtitle: l.tradePageIntro,
                      subtitleMaxLines: 2,
                      maxContentWidth: 1180,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxW),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                  if (openPositions.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final p in openPositions.take(6))
                          _openPositionPill(
                            context,
                            p,
                            selected: _expandedOpenPositionId == p.id,
                            onTap: () {
                              _safeSetState(() {
                                _expandedOpenPositionId =
                                    _expandedOpenPositionId == p.id ? null : p.id;
                              });
                            },
                          ),
                      ],
                    ),
                    if (_expandedOpenPositionId != null) ...[
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final sel = openPositions
                              .where((e) => e.id == _expandedOpenPositionId)
                              .toList();
                          if (sel.isEmpty) return const SizedBox.shrink();
                          final t = sel.first;
                          return Text(
                            l.tradeOpenPositionLine(
                              _formatDateTime(t.entreeAt),
                            ),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: TradeTokens.textSecondary,
                                  fontSize: 11,
                                  height: 1.25,
                                ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 14),
                  ],
                  TradeSummaryBar(
                    profitNetLabel: '${_formatMoney(s.net)}\$',
                    profitNetSubLabel: pctNetVsCapital == null
                        ? null
                        : l.tradePctOfCapital(
                            '${pctNetVsCapital >= 0 ? '+' : ''}${pctNetVsCapital.toStringAsFixed(2).replaceAll('.', ',')}',
                          ),
                    profitNetColor: s.net < 0
                        ? TradeTokens.lossNeon
                        : (s.net == 0 ? Colors.white : TradeTokens.profitNeon),
                    winRateLabel: '$win%',
                    tradesLabel: '${s.count}',
                    breakdownLabel: openCount == 0
                        ? l.tradeSummaryBreakdownShort(s.w, s.l, s.b)
                        : l.tradeSummaryBreakdownWithOpen(
                            s.w,
                            s.l,
                            s.b,
                            openCount,
                          ),
                  ),
                  const SizedBox(height: 12),
                  _timeframeWeekRow(context, allRaw),
                  const SizedBox(height: 12),
                  TradeFilterPills(
                    labels: _tradeFilterLabels(l),
                    subLabels: [
                      _tradesLabel(context, countAll),
                      _tradesLabel(context, countW),
                      _tradesLabel(context, countL),
                      _tradesLabel(context, countB),
                      _tradesLabel(context, countOpen),
                    ],
                    selectedIndex: _filterIndex,
                    onSelected: (i) {
                      _safeSetState(() {
                        _filterIndex = i;
                        // Un filtre principal remplace le filtre "actif".
                        _pairFilter = null;
                      });
                    },
                  ),
                  if (items.isNotEmpty) ...[
                    buildPlanAnalysisMissingNotice(
                      context,
                      missingCount: countTradesMissingPlanAnalysis(items),
                      totalCount: items.length,
                    ),
                    buildStrategieExecutionMissingNotice(
                      context,
                      missingCount:
                          countTradesMissingStrategieExecution(items),
                      totalCount: items.length,
                    ),
                    buildChecklistMissingNotice(
                      context,
                      missingCount: countTradesMissingChecklist(items),
                      totalCount: items.length,
                    ),
                    buildEtatMissingNotice(
                      context,
                      missingCount: countTradesMissingEtat(items),
                      totalCount: items.length,
                    ),
                  ],
                  if (mostTraded.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l.tradeMostTradedHeading,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: TradeTokens.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in mostTraded.take(6))
                          _mostTradedPill(
                            context,
                            e.pair,
                            e.count,
                            selected: _pairFilter == e.pair,
                            onTap: () {
                              _safeSetState(() {
                                // Toggle : re-cliquer enlève le filtre actif.
                                _pairFilter = _pairFilter == e.pair ? null : e.pair;
                                _filterIndex = 0; // Tous
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Transform.scale(
                        scale: 0.92,
                        alignment: Alignment.centerRight,
                        child: TimeframePills(
                          labels: _tradeTimeframePillLabels(l),
                          selectedIndex: _timeframeIndex,
                          onChanged: (i) => _safeSetState(() {
                            _timeframeIndex = i;
                            if (i != 0) _expandedDayKey = null;
                            if (i != 1) _expandedWeekKey = null;
                            if (i != 2) _expandedMonthKey = null;
                          }),
                        ),
                      ),
                    ),
                  ] else ...[
                    // pas d'actifs
                  ],
                  const SizedBox(height: 16),
                  if (_timeframeIndex == 0) ..._buildDayCards(allRaw, tradeKeys),
                  if (_timeframeIndex == 1) ..._buildWeekCards(allRaw, tradeKeys),
                  if (_timeframeIndex == 2) ..._buildMonthCards(allRaw, tradeKeys),
                  if (_timeframeIndex != 0 && _timeframeIndex != 2)
                    for (final item in items)
                      Container(
                        key: tradeKeys[item.id],
                        child: TradeCard(
                          item: item,
                          expanded: _expandedTradeId == item.id,
                          tradeNumberOfDay: _tradeNumberOfDay(item, allRaw),
                          checklistController: widget.checklistController,
                          onToggle: () {
                            _safeSetState(() {
                              _expandedTradeId =
                                  _expandedTradeId == item.id ? null : item.id;
                            });
                          },
                          onTapOutsideWhenExpanded: () {
                            if (_expandedTradeId != item.id) return;
                            _safeSetState(() => _expandedTradeId = null);
                          },
                          onEdit: () => widget.onEditTrade(item),
                          onExportPdf: () => exportTradePdf(
                            context,
                            item,
                            checklistController: widget.checklistController,
                          ),
                          onDelete: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) {
                                final l = AppLocalizations.of(ctx)!;
                                return AlertDialog(
                                  backgroundColor: TradeTokens.cardBg,
                                  title: Text(
                                    l.tradeDeleteConfirmTitle,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  content: Text(
                                    l.tradeDeleteConfirmBody,
                                    style: TextStyle(
                                      color: TradeTokens.textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(l.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(
                                        l.delete,
                                        style: TextStyle(
                                          color: TradeTokens.lossNeon,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (ok != true) return;
                            if (!context.mounted) return;
                            TradeJournalScope.of(context).removeById(item.id);
                          },
                        ),
                      ),
                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

