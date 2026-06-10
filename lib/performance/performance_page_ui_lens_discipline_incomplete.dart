part of 'performance_page.dart';

extension _PerformancePageUiLensDisciplineIncomplete on _PerformancePageState {
  Widget _cardTradesNonRenseignes(PaychekLensSnapshot lens) {
    final code = Localizations.localeOf(context).languageCode;
    String txt(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);
    if (lens.tradeCount <= 0) return const SizedBox.shrink();

    final incomplete = _incompleteJournalTrades;
    final anyMissing = incomplete.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _performanceSectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.clipboardList,
                size: 16,
                color: PerformanceTokens.labelMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  txt(
                    'TRADES NON RENSEIGNÉS',
                    'UNFILLED TRADES',
                    'TRADES SIN DATOS',
                    'NICHT AUSGEFÜLLTE TRADES',
                    'TRADES NÃO PREENCHIDOS',
                    '미입력 트레이드',
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: PerformanceTokens.labelDim,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            txt(
              'Appuyez sur un trade pour l’ouvrir et compléter la discipline.',
              'Tap a trade to open it and fill in discipline.',
              'Toca un trade para abrirlo y completar la disciplina.',
              'Trade antippen, um Disziplin zu ergänzen.',
              'Toque num trade para abrir e completar a disciplina.',
              '트레이드를 눌러 규율을 입력하세요.',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              color: PerformanceTokens.labelFaint,
              height: 1.4,
            ),
          ),
          if (anyMissing > 0) ...[
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  height: 1.35,
                  color: PerformanceTokens.labelMuted,
                ),
                children: [
                  TextSpan(
                    text: '$anyMissing ',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: PerformanceTokens.labelMuted,
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: performanceTradeWordPlural(code, anyMissing),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 340),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: incomplete.length,
                separatorBuilder: (context, ignored) =>
                    const SizedBox(height: 6),
                itemBuilder: (context, index) =>
                    _incompleteTradeListTile(incomplete[index], txt: txt),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.badgeCheck,
                    size: 16,
                    color: _kGreen.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      txt(
                        'Tous les trades sont renseignés sur cette période.',
                        'All trades are filled on this period.',
                        'Todos los trades están completos en este período.',
                        'Alle Trades sind in diesem Zeitraum ausgefüllt.',
                        'Todos os trades estão preenchidos neste período.',
                        '이번 기간 모든 트레이드가 입력되었습니다.',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: PerformanceTokens.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _incompleteTradeListTile(
    TradeListItem item, {
    required String Function(String, String, String, String, String, String)
    txt,
  }) {
    final amountColor = item.isProfit ? _kGreen : _kRed;
    final missingChips = <Widget>[];
    if (!tradeHasExplicitChecklist(item)) {
      missingChips.add(
        _incompleteAxisChip(
          txt(
            'Checklist',
            'Checklist',
            'Checklist',
            'Checkliste',
            'Checklist',
            '체크',
          ),
          kLensChecklist,
        ),
      );
    }
    if (!tradeHasExplicitEtat(item)) {
      missingChips.add(
        _incompleteAxisChip(
          txt('État', 'Mental', 'Estado', 'Mental', 'Estado', '멘탈'),
          kLensEtat,
        ),
      );
    }
    if (!tradeHasExplicitStrategieExecution(item)) {
      missingChips.add(
        _incompleteAxisChip(
          txt(
            'Stratégie',
            'Strategy',
            'Estrategia',
            'Strategie',
            'Estratégia',
            '전략',
          ),
          kLensStrategie,
        ),
      );
    }
    if (!tradeHasExplicitPlanAnalysis(item)) {
      missingChips.add(
        _incompleteAxisChip(
          txt('Analyse', 'Analysis', 'Análisis', 'Analyse', 'Análise', '분석'),
          kLensPlan,
        ),
      );
    }

    return Material(
      color: PerformanceTokens.innerBgDeep,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _openIncompleteTrade(item),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PerformanceTokens.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.pair,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: DashboardTokens.onMatteEmphasis,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.amountLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: amountColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.dateLine,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        color: PerformanceTokens.labelDim,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (missingChips.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(spacing: 4, runSpacing: 4, children: missingChips),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: PerformanceTokens.labelFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _incompleteAxisChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color.withValues(alpha: 0.95),
        ),
      ),
    );
  }

  Widget _cardEye(PaychekLensSnapshot lens) {
    final code = Localizations.localeOf(context).languageCode;
    String txt(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _performanceSectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.eye, size: 18, color: _kGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PAYCHEK LENS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: DashboardTokens.onMatteEmphasis,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(_pulseCtrl),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _kRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _kRed.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (lens.tradeCount == 0) ...[
            Text(
              lens.insight ?? '',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.5,
                color: PerformanceTokens.labelMuted,
              ),
            ),
          ] else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 420;
                final kpis = [
                  _lensKpiTile(
                    label: txt(
                      'Trades',
                      'Trades',
                      'Trades',
                      'Trades',
                      'Trades',
                      '트레이드',
                    ),
                    value: '${lens.tradeCount}',
                    valueColor: kLensAccentNum,
                    icon: LucideIcons.layers,
                  ),
                  _lensKpiTile(
                    label: txt(
                      'Perte max',
                      'Max loss',
                      'Pérdida máx',
                      'Max. Verlust',
                      'Perda máx',
                      '최대 손실',
                    ),
                    value: lens.maxLoss.toStringAsFixed(0),
                    valueColor: kLensLoss,
                    icon: LucideIcons.trendingDown,
                  ),
                  _lensKpiTile(
                    label: txt(
                      'Durée Ø',
                      'Avg time',
                      'Duración Ø',
                      'Ø Dauer',
                      'Duração Ø',
                      '평균 시간',
                    ),
                    value: '${lens.avgDurationMinutes} min',
                    valueColor: kLensDuration,
                    icon: LucideIcons.clock,
                  ),
                ];
                if (wide) {
                  return Row(
                    children: [
                      for (var i = 0; i < kpis.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: kpis[i]),
                      ],
                    ],
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < kpis.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      kpis[i],
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: PerformanceTokens.cardBorder),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  txt(
                    'DISCIPLINE RENSEIGNÉE',
                    'FILLED-IN DISCIPLINE',
                    'DISCIPLINA RELLENADA',
                    'AUSGEFÜLLTE DISZIPLIN',
                    'DISCIPLINA PREENCHIDA',
                    '입력된 규율',
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: PerformanceTokens.labelDim,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    txt(
                      'uniquement trades avec données saisies',
                      'qualified trades only',
                      'solo trades con datos',
                      'nur ausgefüllte Trades',
                      'apenas trades qualificados',
                      '입력된 트레이드만',
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: PerformanceTokens.labelFaint,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 340;
                final tiles = [
                  for (final a in lens.axes) _lensAxisTile(a, txt: txt),
                ];
                if (!twoCol) {
                  return Column(
                    children: [
                      for (var i = 0; i < tiles.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        tiles[i],
                      ],
                    ],
                  );
                }
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: tiles[0]),
                        const SizedBox(width: 8),
                        Expanded(child: tiles[1]),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: tiles[2]),
                        const SizedBox(width: 8),
                        Expanded(child: tiles[3]),
                      ],
                    ),
                  ],
                );
              },
            ),
            if (lens.newsLine != null && lens.newsLine!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.newspaper,
                    size: 14,
                    color: PerformanceTokens.labelMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lens.newsLine!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        height: 1.4,
                        color: PerformanceTokens.labelMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (lens.insight != null && lens.insight!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: PerformanceTokens.innerBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PerformanceTokens.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 14,
                      color: _kGreen.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lens.insight!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          height: 1.45,
                          color: PerformanceTokens.textBright,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

}
