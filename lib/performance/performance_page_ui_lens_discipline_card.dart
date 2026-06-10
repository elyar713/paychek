part of 'performance_page.dart';

extension _PerformancePageUiLensDisciplineCard on _PerformancePageState {
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
