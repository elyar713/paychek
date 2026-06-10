part of 'coach_ai_page.dart';

extension _CoachAiPageCardsStory on _CoachAiPageState {
  Widget _paychekTrainingRoutineCard() {
    const steps = <(IconData, String, String)>[
      (Icons.checklist_rtl_outlined, 'Chaque jour', 'Checklist + état mental (2 min)'),
      (Icons.insights_outlined, 'Avant chaque trade', 'Plan d\'analyse + stratégie'),
      (Icons.sell_outlined, 'Après le trade', 'Tag psych (FOMO, TILT…) + non-respect si besoin'),
      (Icons.calendar_month_outlined, '4 semaines', 'Saisie régulière → patterns chiffrés dans PAYCHEK'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF14532D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entraînement PAYCHEK (modeste, mais efficace)',
            style: _coachText(size: 13.5, color: const Color(0xFF6EE7B7), weight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'La discipline demande de la constance — pas la perfection.',
            style: _coachText(size: 12.5, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          for (final s in steps) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(s.$1, size: 16, color: const Color(0xFF34D399)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${s.$2}  ',
                            style: _coachText(size: 13, color: const Color(0xFF34D399), weight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: s.$3,
                            style: _coachText(size: 13, color: const Color(0xFFD1D5DB), weight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPillarImprovementCard(_CoachAiMessage m, String question) {
    final snap = _computeAuditSnapshot();
    final pillarId = CoachAiPillarCoaching.resolvePillarId(question);
    final pillar = switch (pillarId) {
      'checklist' => snap.disciplinePillars[0],
      'analysis' => snap.disciplinePillars[1],
      'mental' => snap.disciplinePillars[3],
      _ => snap.disciplinePillars[2],
    };
    final lang = _responseLang(question);
    final title = CoachAiPillarCoaching.pillarTitle(pillarId, lang);
    final target = CoachAiPillarCoaching.extractTargetPercent(question);
    final targetLabel = target != null ? '$target %' : null;
    final isReinforcement = CoachAiPillarCoaching.isReinforcementQuestion(question) ||
        CoachAiPillarCoaching.isStrategyOpinionQuestion(question);
    final completionPercent = snap.tradesTotal > 0
        ? ((pillar.recorded * 100) / snap.tradesTotal).round()
        : 0;
    final hasTrainingPlan = CoachAiPillarCoaching.shouldIncludeTrainingSystem(
      pillarId: pillarId,
      completionPercent: completionPercent,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF14532D)),
            ),
            alignment: Alignment.center,
            child: Icon(pillar.icon, size: 17, color: const Color(0xFF34D399)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isReinforcement
                              ? (lang == 'fr' ? 'Coach · $title' : 'Coach · $title')
                              : (hasTrainingPlan
                                  ? (lang == 'fr'
                                      ? 'Plan · $title · 4 sem.'
                                      : 'Plan · $title · 4 wk')
                                  : (lang == 'fr' ? 'Plan · $title' : 'Plan · $title')),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 27 / 2,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (targetLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF422006).withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            targetLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isReinforcement
                        ? (lang == 'fr'
                            ? (CoachAiPillarCoaching.isStrategyOpinionQuestion(question)
                                ? 'Mon avis sur ta stratégie (pas un audit ENREGISTRÉ).'
                                : 'Réponse directe à ta question (les chiffres servent le conseil, pas un audit).')
                            : (CoachAiPillarCoaching.isStrategyOpinionQuestion(question)
                                ? 'My view on your strategy (not a recorded-trade audit).'
                                : 'Direct answer to your question (numbers support advice, not an audit).'))
                        : (hasTrainingPlan
                            ? (lang == 'fr'
                                ? 'Plan d’action + entraînement 4 semaines (pas audit ENREGISTRÉ).'
                                : 'Action plan + 4-week training (not recorded-trade audit).')
                            : (lang == 'fr'
                                ? 'Coaching actionnable (pas audit ENREGISTRÉ / NON ENREGISTRÉ).'
                                : 'Actionable coaching (not recorded vs missing audit).')),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isReinforcement) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _performanceMetricChip(
                          lang == 'fr' ? 'Renseignés' : 'Logged',
                          '${pillar.recorded}/${pillar.total}',
                        ),
                        _performanceMetricChip(
                          lang == 'fr' ? 'Non-respect' : 'Violations',
                          '${pillar.nonRespect}',
                        ),
                        if (pillar.recordedClosed > 0)
                          _performanceMetricChip(
                            'Winrate',
                            '${pillar.winrateRecorded.toStringAsFixed(0)}%',
                          ),
                      ],
                    ),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _CoachExpandableInsight(text: m.text),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachingStoryCard(_CoachAiMessage m, String question) {
    final focus = CoachAiCoachingStory.buildFocus(
      _coachJournalTrades(),
      question,
    );
    final themes = focus?.themes ?? <String>[];
    final lang = _responseLang(question);
    final subtitle = CoachAiFocus.coachingStoryCardSubtitle(
      languageCode: lang,
      asksHowToFix: focus?.asksHowToFix ?? false,
      asksOpinion: focus?.asksOpinion ?? false,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF422006).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.45)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.forum_outlined, size: 17, color: Color(0xFFF59E0B)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Coach',
                          style: _coachText(size: 16, color: const Color(0xFFF59E0B), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: subtitle,
                          style: _coachText(size: 16, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (themes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in themes)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF422006).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              t,
                              style: _coachText(size: 12, color: const Color(0xFFFDE68A), weight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _CoachExpandableInsight(text: m.text),
                  ],
                  ...() {
                    final related = CoachAiRelatedTrades.build(
                      _coachJournalTrades(),
                      question,
                      themes: themes,
                    );
                    if (related == null || related.rows.isEmpty) {
                      return <Widget>[];
                    }
                    return [
                      const SizedBox(height: 14),
                      Text(
                        related.title,
                        style: _coachText(
                          size: 13,
                          color: const Color(0xFFA78BFA),
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        related.subtitle,
                        style: _coachText(
                          size: 11.5,
                          color: const Color(0xFF6B7280),
                          weight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._buildCoachTradeRowTiles(related.rows),
                    ];
                  }(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCoachTradeRowTiles(List<CoachTradeListRow> rows) {
    return [
      for (final row in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.pair,
                        style: _coachText(size: 14, color: Colors.white, weight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      row.sideLabel,
                      style: _coachText(size: 10, color: const Color(0xFF6B7280), weight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      row.isClosed
                          ? '${row.pnl >= 0 ? '+' : ''}${row.pnl}'
                          : 'Ouvert',
                      style: _coachText(
                        size: 13,
                        color: row.isClosed
                            ? (row.pnl >= 0
                                ? const Color(0xFF34D399)
                                : const Color(0xFFF87171))
                            : const Color(0xFFF59E0B),
                        weight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  row.dateLabel,
                  style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (row.psychTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in row.psychTags)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: row.matchedTags.any((m) => m.toLowerCase() == t.toLowerCase())
                                ? const Color(0xFF4C1D95).withValues(alpha: 0.45)
                                : const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: row.matchedTags.any((m) => m.toLowerCase() == t.toLowerCase())
                                  ? const Color(0xFFA78BFA)
                                  : const Color(0xFF374151),
                            ),
                          ),
                          child: Text(
                            t,
                            style: _coachText(
                              size: 10,
                              color: row.matchedTags.any((m) => m.toLowerCase() == t.toLowerCase())
                                  ? const Color(0xFFE9D5FF)
                                  : const Color(0xFF9CA3AF),
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
    ];
  }

  Widget _buildPsychWhyCard(_CoachAiMessage m, String question) {
    final focus = CoachAiPsychAnalysis.buildFocus(
      _coachJournalTrades(),
      question,
    );
    final tag = focus?.tagQuery ?? 'émotion';
    final stats = focus?.tagStats;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF14532D)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.psychology_alt_outlined, size: 17, color: Color(0xFF34D399)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pourquoi ',
                          style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: tag,
                          style: _coachText(size: 16, color: const Color(0xFFF59E0B), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' ?',
                          style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (stats != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _performanceMetricChip('Trades tagués', '${stats.trades}'),
                        _performanceMetricChip(
                          'Winrate',
                          '${stats.winrate}%',
                          color: stats.closed > 0
                              ? (stats.winrate >= 50
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFF87171))
                              : const Color(0xFF9CA3AF),
                        ),
                        _performanceMetricChip(
                          'PnL',
                          '${stats.pnl}',
                          color: stats.pnl >= 0
                              ? const Color(0xFF34D399)
                              : const Color(0xFFF87171),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tague tes trades sur Ajouter un trade (section TAG) pour que PAYCHEK relie $tag à tes résultats.',
                      style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _paychekTrainingRoutineCard(),
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _CoachExpandableInsight(text: m.text),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNonRespectCard(_CoachAiMessage m) {
    final report = CoachAiNonRespectAnalysis.buildReport(
      context,
      _coachJournalTrades(),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF14532D)),
            ),
            alignment: Alignment.center,
            child: const Text('✨', style: TextStyle(fontSize: 14)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: 'Non-respect',
                          style: _coachText(size: 16, color: const Color(0xFFF87171), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' & pertes',
                          style: _coachText(size: 16, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (report == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Aucun point « non respecté » enregistré sur tes trades pour l’instant. '
                      'Coche-les sur Ajouter un trade pour que le Coach calcule l’impact.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        height: 1.45,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (report != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _performanceMetricChip(
                          'Trades avec écart',
                          '${report.tradesWithAnyViolation}',
                          color: const Color(0xFF9CA3AF),
                        ),
                        _performanceMetricChip(
                          'Pertes (clôturées)',
                          '${report.closedLossesWithViolation}',
                          color: const Color(0xFFF87171),
                        ),
                        _performanceMetricChip(
                          'Gains (clôturés)',
                          '${report.closedWinsWithViolation}',
                          color: const Color(0xFF34D399),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...report.topItems.take(6).map((v) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: CoachAiNonRespectAnalysis.pillarLabel(v.pillar),
                                      style: _coachText(
                                        size: 13,
                                        color: switch (v.pillar) {
                                          'strategy' => const Color(0xFF34D399),
                                          'analysisPlan' => const Color(0xFF60A5FA),
                                          'checklist' => const Color(0xFFF59E0B),
                                          _ => const Color(0xFFA78BFA),
                                        },
                                        weight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '  ·  ',
                                      style: _coachText(size: 13, color: const Color(0xFF4B5563), weight: FontWeight.w700),
                                    ),
                                    TextSpan(
                                      text: v.label,
                                      style: _coachText(size: 12.5, color: Colors.white, weight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _performanceMetricChip(
                                    'Fois',
                                    '${v.count}',
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  _performanceMetricChip(
                                    'Pertes liées',
                                    '${v.onClosedLosses}',
                                    color: v.onClosedLosses > 0
                                        ? const Color(0xFFF87171)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                  if (v.onClosedLosses + v.onClosedWins > 0)
                                    _performanceMetricChip(
                                      '% perte',
                                      '${v.lossRateWhenViolatedPercent}%',
                                      color: v.lossRateWhenViolatedPercent >= 50
                                          ? const Color(0xFFF87171)
                                          : const Color(0xFF34D399),
                                    ),
                                  _performanceMetricChip(
                                    'PnL',
                                    '${v.pnlSumWhenViolated}',
                                    color: v.pnlSumWhenViolated >= 0
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFFF87171),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _coachNarrativeBlock(m.text, maxLines: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeListCard(_CoachAiMessage m, String question) {
    final report = CoachAiTradeListQuery.build(
      _coachJournalTrades(),
      question,
    );
    final tag = CoachAiPsychAnalysis.extractTagQuery(question);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF14532D)),
            ),
            alignment: Alignment.center,
            child: const Text('✨', style: TextStyle(fontSize: 14)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Trades',
                          style: _coachText(size: 16, color: const Color(0xFFA78BFA), weight: FontWeight.w800),
                        ),
                        if (tag != null)
                          TextSpan(
                            text: ' · $tag',
                            style: _coachText(size: 16, color: Colors.white, weight: FontWeight.w800),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.headline,
                    style: _coachText(size: 12, color: const Color(0xFF9CA3AF), weight: FontWeight.w600),
                  ),
                  if (report.rows.isEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      report.hint,
                      style: _coachText(size: 13.5, color: const Color(0xFF6B7280), weight: FontWeight.w500),
                    ),
                  ],
                  if (report.rows.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._buildCoachTradeRowTiles(report.rows),
                  ],
                  if (report.hint.isNotEmpty && report.rows.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      report.hint,
                      style: _coachText(size: 12.5, color: const Color(0xFF6B7280), weight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryFollowUpCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final title = CoachAiFocus.storyFollowUpCardTitle(lang);
    final body = m.text.trim();
    final fallbackSteps = CoachAiConversation.storyFollowUpSteps(lang);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF14532D)),
            ),
            alignment: Alignment.center,
            child: const Text('✨', style: TextStyle(fontSize: 14)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: _coachText(size: 15, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' · mode d’emploi',
                          style: _coachText(size: 15, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CoachAiFormattedNarrative(text: body),
                  ] else ...[
                    const SizedBox(height: 12),
                    for (var i = 0; i < fallbackSteps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: _coachText(size: 13, color: const Color(0xFF6EE7B7), weight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fallbackSteps[i],
                                style: _coachText(size: 14, color: const Color(0xFFE5E7EB), weight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
