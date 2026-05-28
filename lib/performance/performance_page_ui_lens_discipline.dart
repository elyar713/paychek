part of 'performance_page.dart';

extension _PerformancePageUiLensDiscipline on _PerformancePageState {
  Widget _strategieWarningStatChip({
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PerformanceTokens.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kRed,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: PerformanceTokens.labelMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _strategieWarningStatChips(
    PaychekStrategieWarning warning,
    String Function(String, String, String, String, String, String) txt,
  ) {
    final chips = <Widget>[];
    final tc = warning.tradeCount ?? 0;
    final dj = warning.distinctDayCount ?? 0;
    final mj = warning.distinctMonthCount ?? 0;
    if (tc > 0) {
      chips.add(
        _strategieWarningStatChip(
          value: '$tc',
          label: txt('trades', 'trades', 'trades', 'Trades', 'trades', '거래'),
        ),
      );
    }
    if (dj > 0) {
      chips.add(
        _strategieWarningStatChip(
          value: '$dj',
          label: txt('jours', 'days', 'días', 'Tage', 'dias', '일'),
        ),
      );
    }
    if (mj > 0) {
      chips.add(
        _strategieWarningStatChip(
          value: '$mj',
          label: txt('mois', 'months', 'meses', 'Monate', 'meses', '개월'),
        ),
      );
    }
    return chips;
  }

  Widget _strategieWarningTile(PaychekStrategieWarning warning) {
    final code = Localizations.localeOf(context).languageCode;
    String txt(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) =>
        perf6(code, fr, en, es, de, pt, ko);
    final statChips = _strategieWarningStatChips(warning, txt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kRed.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.alertTriangle,
                size: 16,
                color: _kRed.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  warning.message,
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
          if (statChips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: statChips),
          ],
        ],
      ),
    );
  }

  Widget _cardStrategieWarnings(List<PaychekStrategieWarning> strategieWarnings) {
    if (strategieWarnings.isEmpty) return const SizedBox.shrink();
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
          Text(
            txt(
              'AVERTISSEMENTS - SEUILS STRATÉGIE',
              'WARNINGS - STRATEGY THRESHOLDS',
              'ADVERTENCIAS - UMBRALES DE ESTRATEGIA',
              'HINWEISE - STRATEGIE-SCHWELLEN',
              'AVISOS - LIMITES DA ESTRATÉGIA',
              '경고 - 전략 임계값',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: PerformanceTokens.labelDim,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            txt(
              'Chaque ligne résume un écart ; les chiffres indiquent combien de trades, sur combien de jours et de mois distincts.',
              'Each row summarizes one breach; figures show how many trades, on how many distinct days and months.',
              'Cada fila resume un incumplimiento; las cifras indican trades, días y meses distintos.',
              'Jede Zeile fasst einen Verstoß zusammen; Zahlen = Trades, Tage und Monate.',
              'Cada linha resume um desvio; números = trades, dias e meses distintos.',
              '각 항목은 위반 요약이며, 숫자는 거래·일·월 수입니다.',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              height: 1.35,
              color: PerformanceTokens.labelMuted,
            ),
          ),
          const SizedBox(height: 14),
          for (final w in strategieWarnings) _strategieWarningTile(w),
        ],
      ),
    );
  }

  /// Carte colonne gauche : liste des trades incomplets, tap → Ajouter trade.
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

  Widget _lensKpiTile({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: PerformanceTokens.innerBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PerformanceTokens.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: valueColor.withValues(alpha: 0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: PerformanceTokens.labelDim,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _lensAxisIcon(PaychekLensAxisKind kind) {
    return switch (kind) {
      PaychekLensAxisKind.checklist => LucideIcons.listChecks,
      PaychekLensAxisKind.etat => LucideIcons.heartPulse,
      PaychekLensAxisKind.strategie => LucideIcons.crosshair,
      PaychekLensAxisKind.plan => LucideIcons.lineChart,
    };
  }

  Widget _lensAxisTile(
    PaychekLensAxisStat axis, {
    required String Function(String, String, String, String, String, String)
    txt,
  }) {
    final filled = axis.qualifiedCount;
    final missing = axis.missingCount;
    final active = axis.isActive;
    final wr = axis.winRateOnQualified;
    final lang = Localizations.localeOf(context).languageCode;
    final wrLine = active && wr != null ? '${(wr * 100).round()}% WR' : null;
    final tradeWordMissing = performanceTradeWordPlural(lang, missing);
    final nonRenseigneLabel = txt(
      missing > 1 ? 'non renseignés' : 'non renseigné',
      missing > 1 ? 'not filled' : 'not filled',
      missing > 1 ? 'sin datos' : 'sin dato',
      missing > 1 ? 'nicht ausgefüllt' : 'nicht ausgefüllt',
      missing > 1 ? 'não preenchidos' : 'não preenchido',
      '미입력',
    );
    final tradesRenseignesLabel = txt(
      filled > 1 ? 'trades renseignés' : 'trade renseigné',
      filled > 1 ? 'filled trades' : 'filled trade',
      filled > 1 ? 'trades rellenados' : 'trade rellenado',
      filled > 1 ? 'ausgefüllte Trades' : 'ausgefüllter Trade',
      filled > 1 ? 'trades preenchidos' : 'trade preenchido',
      filled > 1 ? '입력된 트레이드' : '입력된 트레이드',
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: active
            ? PerformanceTokens.innerBg
            : PerformanceTokens.innerBgDeep,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? axis.color.withValues(alpha: 0.45)
              : PerformanceTokens.innerBgDeep,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _lensAxisIcon(axis.kind),
                size: 14,
                color: active ? axis.color : PerformanceTokens.labelFaint,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  axis.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? DashboardTokens.onMatteEmphasis
                        : PerformanceTokens.labelDim,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (missing > 0) ...[
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  height: 1.35,
                  color: PerformanceTokens.labelDim,
                ),
                children: [
                  TextSpan(
                    text: '$missing ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: PerformanceTokens.labelMuted,
                    ),
                  ),
                  TextSpan(
                    text: '$tradeWordMissing $nonRenseigneLabel',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (active) ...[
            SizedBox(height: missing > 0 ? 8 : 10),
            Text(
              '$filled',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: axis.color,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tradesRenseignesLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: PerformanceTokens.labelMuted,
              ),
            ),
          ] else if (missing <= 0) ...[
            const SizedBox(height: 10),
            Text(
              txt(
                'Non renseigné',
                'Not filled',
                'Sin datos',
                'Nicht ausgefüllt',
                'Não preenchido',
                '미입력',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: PerformanceTokens.labelFaint,
              ),
            ),
          ],
          const SizedBox(height: 8),
          _lensAxisSplitBar(
            filled: filled,
            missing: missing,
            filledColor: axis.color,
          ),
          const SizedBox(height: 8),
          if (active && wr != null) ...[
            _lensAxisWrBar(winRate: wr),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                wrLine!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: kLensWinrate,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Barre de progression WR (0–100 %) sur les trades renseignés.
  Widget _lensAxisWrBar({required double winRate}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: winRate.clamp(0.0, 1.0),
        minHeight: 4,
        backgroundColor: PerformanceTokens.innerBgDeep,
        color: kLensWinrate,
      ),
    );
  }

  /// Barre double : partie colorée = renseigné, gris = non renseigné.
  Widget _lensAxisSplitBar({
    required int filled,
    required int missing,
    required Color filledColor,
  }) {
    final total = filled + missing;
    if (total <= 0) {
      return Container(
        height: 6,
        decoration: BoxDecoration(
          color: PerformanceTokens.innerBgDeep,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        child: Row(
          children: [
            if (filled > 0)
              Expanded(
                flex: filled,
                child: ColoredBox(color: filledColor),
              ),
            if (missing > 0)
              Expanded(
                flex: missing,
                child: const ColoredBox(
                  color: PerformanceTokens.chipBorderInactive,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Ligne compacte type maquette : libellé, % WR, fine barre verte / blanche / rouge.
  Widget _disciplineBandRow(
    String left,
    String right,
    double fill,
    Color fillColor, {
    String? sub,
  }) {
    final barColor = fillColor == Colors.white
        ? PerformanceTokens.textPrimary
        : fillColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  left,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: PerformanceTokens.textBright,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                right,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: right == '-' ? PerformanceTokens.labelDim : barColor,
                ),
              ),
            ],
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                sub,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: PerformanceTokens.labelDim,
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fill.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: PerformanceTokens.innerBgDeep,
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Cadre autour de chaque pilier (checklist / analyse / mental) pour la lisibilité.
  Widget _disciplineStatFrame(Widget child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PerformanceTokens.innerBgDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PerformanceTokens.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: child,
      ),
    );
  }

  /// Bloc Mindset : en-tête, barres verticales, synthèse Principe / Feeling / Talent.
  Widget _mindsetPerformanceBlock({
    required String Function(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    )
    txt,
    required String Function(int n) tradesWord,
    required String principleLabel,
    required String feelingLabel,
    required String talentLabel,
    required double wrP,
    required double wrF,
    required double wrT,
    required int nP,
    required int nF,
    required int nT,
    required String wrTextP,
    required String wrTextF,
    required String wrTextT,
  }) {
    const trackH = 158.0;
    const gap = 10.0;
    const talentGrey = PerformanceTokens.labelMuted;
    final compactMindsetUi =
        !kIsWeb && MediaQuery.sizeOf(context).shortestSide < 600;
    final wrFontSize = compactMindsetUi ? 12.0 : 14.0;
    final labelFontSize = compactMindsetUi ? 9.0 : 12.0;
    final labelIconSize = compactMindsetUi ? 11.0 : 14.0;
    final tradeValueFontSize = compactMindsetUi ? 13.0 : 20.0;
    final tradeKickerFontSize = compactMindsetUi ? 7.0 : 8.0;
    final statTilePad = compactMindsetUi
        ? const EdgeInsets.fromLTRB(8, 8, 6, 8)
        : const EdgeInsets.fromLTRB(12, 10, 10, 10);
    final statIconSize = compactMindsetUi ? 14.0 : 18.0;
    final statRowGap = compactMindsetUi ? 6.0 : 8.0;

    Widget columnFor({
      required IconData rowIcon,
      required String name,
      required String wrText,
      required double wr,
      required int n,
      required Color fillColor,

      /// Si vrai et [n] == 0 : piste vide, aucun segment coloré (ex. Feeling sans trade).
      bool hideFillIfEmpty = false,
    }) {
      final barColor = fillColor == Colors.white
          ? PerformanceTokens.textBright
          : fillColor;
      final emptyNoFill = hideFillIfEmpty && n == 0;
      final fill = n > 0 ? wr.clamp(0.0, 1.0) : 0.0;
      const minFill = 0.08;
      final double barH;
      if (emptyNoFill) {
        barH = 0;
      } else if (n > 0) {
        // 0 % WR avec trades : petit segment en bas (dans la piste, via ClipRRect).
        final h = fill <= 0 ? trackH * minFill : trackH * fill;
        barH = h.clamp(trackH * minFill, trackH);
      } else {
        barH = trackH * minFill;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              wrText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: wrFontSize,
                fontWeight: FontWeight.w800,
                color: (wrText == '-' || n == 0)
                    ? PerformanceTokens.labelDim
                    : barColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: trackH,
            child: LayoutBuilder(
              builder: (context, c) {
                final w = math.min(72.0, c.maxWidth * 0.88);
                final radius = 18.0;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: w,
                    height: trackH,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: PerformanceTokens.innerBgDeep,
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(color: PerformanceTokens.cardBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius - 1),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (barH > 0)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: barH,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                        math.min(radius, math.min(barH, w) / 2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  rowIcon,
                  size: labelIconSize,
                  color: PerformanceTokens.textSecondary,
                ),
                SizedBox(width: compactMindsetUi ? 4 : 6),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget mindsetStatTile({
      required String kicker,
      required String value,
      Color kickerColor = PerformanceTokens.labelDim,
      Color valueColor = Colors.white,
      IconData? icon,
      Color? iconColor,
      Color? dotColor,
    }) {
      return Container(
        padding: statTilePad,
        decoration: BoxDecoration(
          color: PerformanceTokens.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PerformanceTokens.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kicker,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: tradeKickerFontSize,
                      fontWeight: FontWeight.w800,
                      color: kickerColor,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: tradeValueFontSize,
                        fontWeight: FontWeight.w800,
                        color: valueColor,
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null && iconColor != null)
              Icon(icon, size: statIconSize, color: iconColor),
            if (dotColor != null)
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.45),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: PerformanceTokens.greenTintBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kGreen.withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: _kGreen.withValues(alpha: 0.32),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Icon(LucideIcons.sparkles, color: _kGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txt(
                      'Mindset',
                      'Mindset',
                      'Mindset',
                      'Mindset',
                      'Mindset',
                      '마인드셋',
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    txt(
                      'PRINCIPAL / FEELING / TALENT',
                      'PRINCIPLE / FEELING / TALENT',
                      'PRINCIPAL / FEELING / TALENTO',
                      'PRINZIP / FEELING / TALENT',
                      'PRINCÍPIO / FEELING / TALENTO',
                      '원칙 / 느낌 / 탤런트',
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: PerformanceTokens.labelDim,
                      letterSpacing: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: txt(
                'Hauteur des barres = win rate par mindset (période filtrée). Talent = trades sans mention Principe ni Feeling. Les cases en bas indiquent le volume par catégorie.',
                'Bar height = win rate per mindset (filtered period). Talent = trades with neither Principle nor Feeling selected. Tiles below show volume per category.',
                'Altura = win rate por mindset (período). Talento = trades sin Principio ni Feeling indicados. Los bloques abajo muestran el volumen.',
                'Balkenhöhe = Gewinnrate je Mindset (Zeitraum). Talent = Trades ohne Prinzip- oder Feeling-Angabe. Kästen unten = Anzahl.',
                'Altura = win rate por mindset (período). Talento = trades sem menção a Princípio ou Feeling. Blocos abaixo = volume.',
                '막대 높이 = 마인드셋별 승률(필터 기간). 탤런트 = 원칙·느낌 모두 미선택 트레이드. 아래 칸은 건수입니다.',
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 19,
                  color: PerformanceTokens.labelDim,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: columnFor(
                rowIcon: LucideIcons.brain,
                name: principleLabel,
                wrText: wrTextP,
                wr: wrP,
                n: nP,
                fillColor: _kGreen,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: columnFor(
                rowIcon: LucideIcons.heartPulse,
                name: feelingLabel,
                wrText: wrTextF,
                wr: wrF,
                n: nF,
                fillColor: _kRed,
                hideFillIfEmpty: true,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: columnFor(
                rowIcon: LucideIcons.star,
                name: talentLabel,
                wrText: wrTextT,
                wr: wrT,
                n: nT,
                fillColor: talentGrey,
                hideFillIfEmpty: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: PerformanceTokens.divider),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: mindsetStatTile(
                kicker: principleLabel.toUpperCase(),
                value: '$nP ${tradesWord(nP)}',
                kickerColor: _kGreen,
                valueColor: _kGreen,
                icon: LucideIcons.brain,
                iconColor: _kGreen,
              ),
            ),
            SizedBox(width: statRowGap),
            Expanded(
              child: mindsetStatTile(
                kicker: feelingLabel.toUpperCase(),
                value: '$nF ${tradesWord(nF)}',
                kickerColor: _kRed,
                valueColor: _kRed,
                icon: LucideIcons.heartPulse,
                iconColor: _kRed,
              ),
            ),
            SizedBox(width: statRowGap),
            Expanded(
              child: mindsetStatTile(
                kicker: talentLabel.toUpperCase(),
                value: '$nT ${tradesWord(nT)}',
                kickerColor: talentGrey,
                valueColor: talentGrey,
                icon: LucideIcons.star,
                iconColor: talentGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardDiscipline() {
    final code = Localizations.localeOf(context).languageCode;
    String txt(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);
    String trades(int n) => performanceTradeWordPlural(code, n);
    final l = AppLocalizations.of(context)!;
    final t = _disciplineVisibleTrades;

    /// Mindset ne repose pas sur les % discipline : inclut aussi les saisies « lite » (import, etc.).
    final tm = _visibleTrades;
    final checklistTradeCount = t.where(performanceTradeHasChecklist).length;
    final etatTradeCount = t.where(performanceTradeHasEtat).length;
    final tChecklist = t
        .where(performanceTradeHasChecklist)
        .toList(growable: false);
    final tEtat = t.where(performanceTradeHasEtat).toList(growable: false);
    final (fullWr, nFull) = winRateChecklistBand(tChecklist, (p) => p >= 80);
    final (partWr, nPart) = winRateChecklistBand(
      tChecklist,
      (p) => p >= 50 && p < 80,
    );
    final (ignWr, nIgn) = winRateChecklistBand(tChecklist, (p) => p < 50);
    final planTradeCount = t.where(performanceTradeHasPlanAnalysis).length;
    final strategieTradeCount = t
        .where(performanceTradeHasStrategieExecution)
        .length;
    final tStrategie = t
        .where(performanceTradeHasStrategieExecution)
        .toList(growable: false);
    final (fullPl, nFullPl) = winRatePlanBand(t, (p) => p >= 80);
    final (partPl, nPartPl) = winRatePlanBand(t, (p) => p >= 50 && p < 80);
    final (ignPl, nIgnPl) = winRatePlanBand(t, (p) => p < 50);
    final (fullEt, nFullEt) = winRateEtatBand(tEtat, (p) => p >= 80);
    final (partEt, nPartEt) = winRateEtatBand(tEtat, (p) => p >= 50 && p < 80);
    final (ignEt, nIgnEt) = winRateEtatBand(tEtat, (p) => p < 50);
    final (wrP, nP, wrF, nF, wrT, nT) = winRatesMindsetPrincipeFeeling(tm);
    final strategieViolations = aggregateStrategieNonRespect(tStrategie);
    final (wrHighStrat, nHighStrat, wrLowStrat, nLowStrat) =
        winRatesStrategieHighVsForced(tStrategie);

    String wrLabel(double wr, int n) =>
        n > 0 ? '${(wr * 100).round()}% WR' : '-';

    return _dashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            LucideIcons.brain,
            txt(
              'Discipline & Impact',
              'Discipline & Impact',
              'Disciplina e impacto',
              'Disziplin & Wirkung',
              'Disciplina e impacto',
              '규율·영향',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            txt(
              'Rentabilité selon le respect de vos règles sur la période filtrée (données journal).',
              'Profitability based on rule adherence for the filtered period (journal data).',
              'Rentabilidad según el respeto de tus reglas en el período filtrado (datos del diario).',
              'Rentabilität nach Regelbefolgung im gefilterten Zeitraum (Journaldaten).',
              'Rentabilidade conforme o cumprimento das regras no período filtrado (dados do diário).',
              '필터 기간 규칙 준수에 따른 수익성(일지 데이터).',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: PerformanceTokens.labelMuted,
              height: 1.45,
            ),
          ),
          if (t.isNotEmpty && planTradeCount < t.length)
            buildPlanAnalysisMissingNotice(
              context,
              missingCount: countPerformanceTradesMissingPlanAnalysis(t),
              totalCount: t.length,
              compact: true,
            ),
          if (t.isNotEmpty && strategieTradeCount < t.length)
            buildStrategieExecutionMissingNotice(
              context,
              missingCount: countPerformanceTradesMissingStrategieExecution(t),
              totalCount: t.length,
              compact: true,
            ),
          if (t.isNotEmpty && checklistTradeCount < t.length)
            buildChecklistMissingNotice(
              context,
              missingCount: countPerformanceTradesMissingChecklist(t),
              totalCount: t.length,
              compact: true,
            ),
          if (t.isNotEmpty && etatTradeCount < t.length)
            buildEtatMissingNotice(
              context,
              missingCount: countPerformanceTradesMissingEtat(t),
              totalCount: t.length,
              compact: true,
            ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final threeCol = constraints.maxWidth >= 720;

              Widget checklistBlock() {
                if (checklistTradeCount == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionTitle(
                        LucideIcons.listChecks,
                        txt(
                          'Check-list (Plan de session)',
                          'Checklist (session plan)',
                          'Checklist (plan de sesión)',
                          'Checkliste (Sessionplan)',
                          'Checklist (plano de sessão)',
                          '체크리스트(세션 계획)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l.performanceChecklistSectionEmpty,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          height: 1.45,
                          color: PerformanceTokens.labelMuted,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle(
                      LucideIcons.listChecks,
                      txt(
                        'Check-list (Plan de session)',
                        'Checklist (session plan)',
                        'Checklist (plan de sesión)',
                        'Checkliste (Sessionplan)',
                        'Checklist (plano de sessão)',
                        '체크리스트(세션 계획)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _disciplineBandRow(
                      txt(
                        'Respectée (80 % – 100 %)',
                        'Followed (80% - 100%)',
                        'Seguida (80% - 100%)',
                        'Eingehalten (80 % – 100 %)',
                        'Respeitada (80% – 100%)',
                        '준수(80–100%)',
                      ),
                      wrLabel(fullWr, nFull),
                      fullWr,
                      _kGreen,
                      sub: nFull > 0 ? '$nFull ${trades(nFull)}' : null,
                    ),
                    _disciplineBandRow(
                      txt(
                        'Partielle (50 % – 80 %)',
                        'Partial (50% - 80%)',
                        'Parcial (50% - 80%)',
                        'Teilweise (50 % – 80 %)',
                        'Parcial (50% – 80%)',
                        '부분(50–80%)',
                      ),
                      wrLabel(partWr, nPart),
                      partWr,
                      Colors.white,
                      sub: nPart > 0 ? '$nPart ${trades(nPart)}' : null,
                    ),
                    _disciplineBandRow(
                      txt(
                        'Ignorée (< 50 %)',
                        'Ignored (< 50%)',
                        'Ignorada (< 50%)',
                        'Ignoriert (< 50 %)',
                        'Ignorada (< 50%)',
                        '미준수(<50%)',
                      ),
                      wrLabel(ignWr, nIgn),
                      ignWr,
                      _kRed,
                      sub: nIgn > 0 ? '$nIgn ${trades(nIgn)}' : null,
                    ),
                  ],
                );
              }

              Widget etatBlock() {
                if (etatTradeCount == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionTitle(
                        LucideIcons.heartPulse,
                        txt(
                          'État mental',
                          'Mental state',
                          'Estado mental',
                          'Mentalzustand',
                          'Estado mental',
                          '멘탈',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l.performanceEtatSectionEmpty,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          height: 1.45,
                          color: PerformanceTokens.labelMuted,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle(
                      LucideIcons.heartPulse,
                      txt(
                        'État mental',
                        'Mental state',
                        'Estado mental',
                        'Mentalzustand',
                        'Estado mental',
                        '멘탈',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _disciplineBandRow(
                      txt(
                        'Respectée (80 % – 100 %)',
                        'Followed (80% - 100%)',
                        'Seguida (80% - 100%)',
                        'Eingehalten (80 % – 100 %)',
                        'Respeitada (80% – 100%)',
                        '준수(80–100%)',
                      ),
                      wrLabel(fullEt, nFullEt),
                      fullEt,
                      _kGreen,
                      sub: nFullEt > 0 ? '$nFullEt ${trades(nFullEt)}' : null,
                    ),
                    _disciplineBandRow(
                      txt(
                        'Partielle (50 % – 80 %)',
                        'Partial (50% - 80%)',
                        'Parcial (50% - 80%)',
                        'Teilweise (50 % – 80 %)',
                        'Parcial (50% – 80%)',
                        '부분(50–80%)',
                      ),
                      wrLabel(partEt, nPartEt),
                      partEt,
                      Colors.white,
                      sub: nPartEt > 0 ? '$nPartEt ${trades(nPartEt)}' : null,
                    ),
                    _disciplineBandRow(
                      txt(
                        'Ignorée (< 50 %)',
                        'Ignored (< 50%)',
                        'Ignorada (< 50%)',
                        'Ignoriert (< 50 %)',
                        'Ignorada (< 50%)',
                        '미준수(<50%)',
                      ),
                      wrLabel(ignEt, nIgnEt),
                      ignEt,
                      _kRed,
                      sub: nIgnEt > 0 ? '$nIgnEt ${trades(nIgnEt)}' : null,
                    ),
                  ],
                );
              }

              Widget analyseBlock() {
                if (planTradeCount == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionTitle(
                        LucideIcons.lineChart,
                        txt(
                          'Analyse (plan de trade)',
                          'Analysis (trade plan)',
                          'Análisis (plan de trade)',
                          'Analyse (Tradeplan)',
                          'Análise (plano de trade)',
                          '분석(트레이드 계획)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l.performancePlanAnalysisSectionEmpty,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          height: 1.45,
                          color: PerformanceTokens.labelMuted,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle(
                      LucideIcons.lineChart,
                      txt(
                        'Analyse (plan de trade)',
                        'Analysis (trade plan)',
                        'Análisis (plan de trade)',
                        'Analyse (Tradeplan)',
                        'Análise (plano de trade)',
                        '분석(트레이드 계획)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _disciplineBandRow(
                      txt(
                        'Respectée (80 % – 100 %)',
                        'Followed (80% - 100%)',
                        'Seguida (80% - 100%)',
                        'Eingehalten (80 % – 100 %)',
                        'Respeitada (80% – 100%)',
                        '준수(80–100%)',
                      ),
                      wrLabel(fullPl, nFullPl),
                      fullPl,
                      _kGreen,
                      sub: nFullPl > 0 ? '$nFullPl ${trades(nFullPl)}' : null,
                    ),
                    _disciplineBandRow(
                      txt(
                        'Partielle (50 % – 80 %)',
                        'Partial (50% - 80%)',
                        'Parcial (50% - 80%)',
                        'Teilweise (50 % – 80 %)',
                        'Parcial (50% – 80%)',
                        '부분(50–80%)',
                      ),
                      wrLabel(partPl, nPartPl),
                      partPl,
                      Colors.white,
                      sub: nPartPl > 0 ? '$nPartPl ${trades(nPartPl)}' : null,
                    ),
                    _disciplineBandRow(
                      txt(
                        'Ignorée (< 50 %)',
                        'Ignored (< 50%)',
                        'Ignorada (< 50%)',
                        'Ignoriert (< 50 %)',
                        'Ignorada (< 50%)',
                        '미준수(<50%)',
                      ),
                      wrLabel(ignPl, nIgnPl),
                      ignPl,
                      _kRed,
                      sub: nIgnPl > 0 ? '$nIgnPl ${trades(nIgnPl)}' : null,
                    ),
                  ],
                );
              }

              if (!threeCol) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _disciplineStatFrame(checklistBlock()),
                    const SizedBox(height: 14),
                    _disciplineStatFrame(analyseBlock()),
                    const SizedBox(height: 14),
                    _disciplineStatFrame(etatBlock()),
                  ],
                );
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _disciplineStatFrame(checklistBlock())),
                    const SizedBox(width: 10),
                    Expanded(child: _disciplineStatFrame(analyseBlock())),
                    const SizedBox(width: 10),
                    Expanded(child: _disciplineStatFrame(etatBlock())),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 720;

              final Widget strategieSection = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: sideBySide ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  _sectionTitle(
                    LucideIcons.crosshair,
                    txt(
                      'Exécution Stratégique',
                      'Strategy execution',
                      'Ejecución estratégica',
                      'Strategieumsetzung',
                      'Execução da estratégia',
                      '전략 실행',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    txt(
                      'Horaires, sessions et gestion du risque : cartes dédiées plus haut (calcul automatique).',
                      'Hours, sessions and risk management: dedicated cards above (automatic).',
                      'Horarios, sesiones y gestión de riesgo: tarjetas arriba (automático).',
                      'Zeiten, Sessions und Risiko: eigene Karten oben (automatisch).',
                      'Horários, sessões e gestão de risco: cartões acima (automático).',
                      '시간·세션·리스크 관리: 상단 전용 카드(자동 계산).',
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: PerformanceTokens.labelDim,
                      height: 1.35,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    txt(
                      'Winrate par setup (titres de la page Stratégie), données journal.',
                      'Win rate by setup (titles from Strategy page), journal data.',
                      'Win rate por setup (títulos de la página Estrategia), datos del diario.',
                      'Gewinnrate pro Setup (Titel von der Strategie-Seite), Journaldaten.',
                      'Win rate por setup (títulos da página Estratégia), dados do diário.',
                      '셋업별 승률(전략 페이지 제목), 일지 데이터.',
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: PerformanceTokens.labelMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: StrategieSetupsStore.notifier,
                    builder: (context, _) {
                      final titles = StrategieSetupsStore.notifier.value
                          .map((e) => e.title)
                          .toList();
                      final stats = winRatesByStrategieSetupTitles(
                        tStrategie,
                        titles,
                      );
                      final any = stats.any((s) => s.count > 0);
                      if (!any) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            strategieTradeCount == 0
                                ? l.performanceStrategieExecutionSectionEmpty
                                : txt(
                                    'Aucun trade avec stratégie renseignée sur cette période.',
                                    'No trades with strategy filled in for this period.',
                                    'No hay trades con estrategia rellenada en este período.',
                                    'Keine Trades mit ausgefüllter Strategie in diesem Zeitraum.',
                                    'Nenhum trade com estratégia preenchida neste período.',
                                    '이 기간에 전략이 입력된 트레이드 없음.',
                                  ),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: PerformanceTokens.labelMuted,
                              height: 1.4,
                            ),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final s in stats)
                            if (s.count > 0)
                              _statBarRow(
                                s.title,
                                wrLabel(s.winRate, s.count),
                                s.winRate,
                                s.winRate >= 0.5 ? _kGreen : _kRed,
                                sub: '${s.count} ${trades(s.count)}',
                              ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  if (strategieTradeCount == 0) ...[
                    Text(
                      l.performanceStrategieExecutionSectionEmpty,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        height: 1.45,
                        color: PerformanceTokens.labelMuted,
                      ),
                    ),
                  ] else ...[
                    Text(
                      txt(
                        'Winrate selon “Stratégie respectée” (slider Ajouter trade).',
                        'Win rate based on “Strategy respected” (Add trade slider).',
                        'Win rate según “Estrategia respetada” (slider de Añadir trade).',
                        'Winrate nach „Strategie eingehalten“ (Slider Trade hinzufügen).',
                        'Win rate conforme “Estratégia respeitada” (slider Adicionar trade).',
                        '“전략 준수”(트레이드 추가 슬라이더) 기준 승률.',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: PerformanceTokens.labelMuted,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _disciplineBandRow(
                      txt(
                        'Stratégie respectée (≥ 50 %)',
                        'Strategy respected (≥ 50%)',
                        'Estrategia respetada (≥ 50%)',
                        'Strategie eingehalten (≥ 50 %)',
                        'Estratégia respeitada (≥ 50%)',
                        '전략 준수(≥50%)',
                      ),
                      wrLabel(wrHighStrat, nHighStrat),
                      wrHighStrat,
                      kLensStrategie,
                      sub: nHighStrat > 0
                          ? '$nHighStrat ${trades(nHighStrat)}'
                          : null,
                    ),
                    _disciplineBandRow(
                      txt(
                        'Stratégie forcée (< 50 %)',
                        'Forced strategy (< 50%)',
                        'Estrategia forzada (< 50%)',
                        'Erzwungene Strategie (< 50 %)',
                        'Estratégia forçada (< 50%)',
                        '억지 전략(<50%)',
                      ),
                      wrLabel(wrLowStrat, nLowStrat),
                      wrLowStrat,
                      _kRed,
                      sub: nLowStrat > 0
                          ? '$nLowStrat ${trades(nLowStrat)}'
                          : null,
                    ),
                  ],
                  if (strategieViolations.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      txt(
                        'Points non respectés (rétroaction slider - agrégé sur la période)',
                        'Unfollowed points (slider feedback - aggregated over period)',
                        'Puntos no respetados (feedback del slider - agregado en el período)',
                        'Nicht eingehaltene Punkte (Slider-Feedback - aggregiert über den Zeitraum)',
                        'Pontos não seguidos (feedback do slider - agregado no período)',
                        '미준수 항목(슬라이더 피드백 - 기간 합산)',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: PerformanceTokens.labelMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...strategieViolations
                        .take(14)
                        .map(
                          (v) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PerformanceTokens.cardBg,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: _kBorder),
                                  ),
                                  child: Text(
                                    '${v.count}×',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _kRed,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    labelForStrategieNonRespectId(
                                      v.id,
                                      v.strategieTitle,
                                      l: AppLocalizations.of(context)!,
                                      locale: Localizations.localeOf(context),
                                    ),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: PerformanceTokens.textBright,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ],
              );

              final Widget mindsetSection = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: sideBySide ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  _mindsetPerformanceBlock(
                    txt: txt,
                    tradesWord: trades,
                    principleLabel: txt(
                      'Principal',
                      'Principle',
                      'Principio',
                      'Prinzip',
                      'Princípio',
                      '원칙',
                    ),
                    feelingLabel: l.tradeMindsetFeeling,
                    talentLabel: l.tradeMindsetTalent,
                    wrP: wrP,
                    wrF: wrF,
                    wrT: wrT,
                    nP: nP,
                    nF: nF,
                    nT: nT,
                    wrTextP: wrLabel(wrP, nP),
                    wrTextF: nF > 0
                        ? wrLabel(wrF, nF)
                        : txt(
                            '0 % WR',
                            '0% WR',
                            '0 % WR',
                            '0 % WR',
                            '0 % WR',
                            '0% WR',
                          ),
                    wrTextT: wrLabel(wrT, nT),
                  ),
                ],
              );

              if (sideBySide) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _disciplineStatFrame(strategieSection)),
                      const SizedBox(width: 10),
                      Expanded(child: _disciplineStatFrame(mindsetSection)),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  strategieSection,
                  const SizedBox(height: 24),
                  mindsetSection,
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: _kBorder),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: PerformanceTokens.textSecondary,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: txt(
                    'Observation : ',
                    'Observation: ',
                    'Observación: ',
                    'Beobachtung: ',
                    'Observação: ',
                    '관찰: ',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: disciplineImpactObservation(
                    t,
                    locale: Localizations.localeOf(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
