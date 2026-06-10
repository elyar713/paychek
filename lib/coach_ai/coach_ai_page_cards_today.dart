part of 'coach_ai_page.dart';

extension _CoachAiPageCardsToday on _CoachAiPageState {
  Widget _buildCalendarTodayCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final title = CoachAiCalendar.todayCardTitle(lang);
    final body = m.text.trim();
    final trades = _coachJournalTrades();

    Color pnlColor(double v) {
      if (v > 0) return const Color(0xFF34D399);
      if (v < 0) return const Color(0xFFF87171);
      return const Color(0xFF9CA3AF);
    }

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
              color: const Color(0xFF134E4A).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF115E59)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.calendar_today_rounded, size: 17, color: Color(0xFF2DD4BF)),
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
              child: FutureBuilder<CalendarTodaySnapshot>(
                future: CoachAiCalendar.buildTodaySnapshot(trades),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: _coachText(
                                size: 15,
                                color: const Color(0xFF2DD4BF),
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (data != null)
                            Text(
                              data.dateLabel,
                              style: _coachText(size: 12, color: const Color(0xFF6B7280)),
                            ),
                        ],
                      ),
                      if (data != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatMoneyLocal(data.pnlToday),
                                style: _coachText(
                                  size: 18,
                                  color: pnlColor(data.pnlToday),
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              lang == 'fr'
                                  ? '${data.tradesToday} trade${data.tradesToday > 1 ? 's' : ''}'
                                  : '${data.tradesToday} trade${data.tradesToday == 1 ? '' : 's'}',
                              style: _coachText(size: 13, color: const Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (data.checklistPercent != null)
                              _analysisChip(
                                lang == 'fr'
                                    ? 'Checklist ${data.checklistPercent}%'
                                    : 'Checklist ${data.checklistPercent}%',
                                const Color(0xFFF59E0B),
                              ),
                            if (data.mentalScore != null)
                              _analysisChip(
                                lang == 'fr'
                                    ? 'Mental ${data.mentalScore}%'
                                    : 'Mental ${data.mentalScore}%',
                                const Color(0xFF34D399),
                              ),
                            for (final setup in data.setupsUsedToday.take(2))
                              _analysisChip(setup, const Color(0xFFC084FC)),
                          ],
                        ),
                        if (data.monthlyObjective != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            lang == 'fr'
                                ? 'Mois : ${formatMoneyLocal(data.monthPnl)} / objectif ${formatMoneyLocal(data.monthlyObjective!)}'
                                : 'Month: ${formatMoneyLocal(data.monthPnl)} / goal ${formatMoneyLocal(data.monthlyObjective!)}',
                            style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarMonthCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final title = CoachAiCalendar.monthCardTitle(lang);
    final body = m.text.trim();
    final trades = _coachJournalTrades();

    Color pnlColor(double v) {
      if (v > 0) return const Color(0xFF34D399);
      if (v < 0) return const Color(0xFFF87171);
      return const Color(0xFF9CA3AF);
    }

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
              color: const Color(0xFF134E4A).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF115E59)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.calendar_month_rounded, size: 17, color: Color(0xFF2DD4BF)),
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
              child: FutureBuilder<CalendarMonthSnapshot>(
                future: CoachAiCalendar.buildMonthSnapshot(trades, lang),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.monthLabel ?? title,
                        style: _coachText(
                          size: 15,
                          color: const Color(0xFF2DD4BF),
                          weight: FontWeight.w800,
                        ),
                      ),
                      if (data != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          formatMoneyLocal(data.monthPnl),
                          style: _coachText(
                            size: 18,
                            color: pnlColor(data.monthPnl),
                            weight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _analysisChip(
                              lang == 'fr'
                                  ? '${data.monthTrades} trades · WR ${data.monthWinratePercent}%'
                                  : '${data.monthTrades} trades · WR ${data.monthWinratePercent}%',
                              const Color(0xFF60A5FA),
                            ),
                            _analysisChip(
                              lang == 'fr'
                                  ? '${data.greenDays}J+ / ${data.redDays}J-'
                                  : '${data.greenDays} green / ${data.redDays} red',
                              const Color(0xFF34D399),
                            ),
                            if (data.objectiveProgressPercent != null)
                              _analysisChip(
                                lang == 'fr'
                                    ? 'Objectif ${data.objectiveProgressPercent}%'
                                    : 'Goal ${data.objectiveProgressPercent}%',
                                const Color(0xFFF59E0B),
                              ),
                          ],
                        ),
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyTodayCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final title = CoachAiStrategyToday.todayCardTitle(lang);
    final body = m.text.trim();

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
              color: const Color(0xFF581C87).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF7E22CE)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.track_changes_rounded, size: 17, color: Color(0xFFC084FC)),
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
              child: FutureBuilder<StrategyTodaySnapshot>(
                future: CoachAiStrategyToday.buildTodaySnapshot(),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: _coachText(
                          size: 15,
                          color: const Color(0xFFC084FC),
                          weight: FontWeight.w800,
                        ),
                      ),
                      if (data != null && data.hasData) ...[
                        const SizedBox(height: 10),
                        if (data.setupTitle.isNotEmpty)
                          Text(
                            data.setupTitle,
                            style: _coachText(
                              size: 14,
                              color: const Color(0xFFF3F4F6),
                              weight: FontWeight.w800,
                            ),
                          ),
                        if (data.signalText.isNotEmpty && data.signalText != '—') ...[
                          const SizedBox(height: 6),
                          Text(
                            data.signalText,
                            style: _coachText(size: 13, color: const Color(0xFFD1D5DB)),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (data.timeframes.isNotEmpty && data.timeframes != '—')
                              _analysisChip(data.timeframes, const Color(0xFF7C3AED)),
                            if (data.pattern.isNotEmpty && data.pattern != '—')
                              _analysisChip(data.pattern, const Color(0xFF2563EB)),
                            if (data.indicateurs.isNotEmpty && data.indicateurs != '—')
                              _analysisChip(data.indicateurs, const Color(0xFF059669)),
                            _analysisChip(
                              lang == 'fr'
                                  ? 'Risque ${data.riskPct}% · RR ${data.rrRatio}'
                                  : 'Risk ${data.riskPct}% · RR ${data.rrRatio}',
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                        if (data.rules.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          for (final rule in data.rules.take(3))
                            if (rule.heading.isNotEmpty || rule.body.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  rule.heading.isNotEmpty
                                      ? '${rule.heading}${rule.body.isNotEmpty ? ' — ${rule.body}' : ''}'
                                      : rule.body,
                                  style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                                ),
                              ),
                        ],
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTodayCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final title = CoachAiAnalysisToday.todayCardTitle(lang);
    final body = m.text.trim();

    Color confidenceColor(int score) {
      if (score >= 70) return const Color(0xFF34D399);
      if (score >= 40) return const Color(0xFFFBBF24);
      return const Color(0xFFF87171);
    }

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
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF1D4ED8)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.insights_outlined, size: 17, color: Color(0xFF60A5FA)),
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
              child: FutureBuilder<AnalysisTodaySnapshot>(
                future: CoachAiAnalysisToday.buildTodaySnapshot(),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: _coachText(
                                size: 15,
                                color: const Color(0xFF60A5FA),
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (data != null && data.hasData)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: confidenceColor(data.globalConfidencePercent)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: confidenceColor(data.globalConfidencePercent)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                '${data.globalConfidencePercent}%',
                                style: _coachText(
                                  size: 13,
                                  color: confidenceColor(data.globalConfidencePercent),
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (data != null && data.hasData) ...[
                        const SizedBox(height: 10),
                        if (data.actif.isNotEmpty)
                          Text(
                            data.actif,
                            style: _coachText(
                              size: 14,
                              color: const Color(0xFFF3F4F6),
                              weight: FontWeight.w800,
                            ),
                          ),
                        if (data.sousTitre.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            data.sousTitre,
                            style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (data.biasLabel.isNotEmpty)
                              _analysisChip(data.biasLabel, const Color(0xFF2563EB)),
                            if (data.trendLabel.isNotEmpty)
                              _analysisChip(data.trendLabel, const Color(0xFF7C3AED)),
                            if (data.phaseLabel.isNotEmpty)
                              _analysisChip(data.phaseLabel, const Color(0xFF059669)),
                            if (data.confluenceScore > 0)
                              _analysisChip(
                                lang == 'fr'
                                    ? 'Confluence ${data.confluenceScore}'
                                    : 'Confluence ${data.confluenceScore}',
                                const Color(0xFFF59E0B),
                              ),
                          ],
                        ),
                        if (data.contexteTfLine.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            data.contexteTfLine,
                            style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                        if (data.support.isNotEmpty || data.resistance.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            [
                              if (data.support.isNotEmpty) 'S ${data.support}',
                              if (data.resistance.isNotEmpty) 'R ${data.resistance}',
                            ].join('  ·  '),
                            style: _coachText(size: 13, color: const Color(0xFFD1D5DB)),
                          ),
                        ],
                        if (!data.isToday && data.contexteDateLabel.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            lang == 'fr'
                                ? 'Date analyse : ${data.contexteDateLabel}'
                                : 'Analysis date: ${data.contexteDateLabel}',
                            style: _coachText(size: 11, color: const Color(0xFF6B7280)),
                          ),
                        ],
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: _coachText(size: 11, color: color, weight: FontWeight.w700),
      ),
    );
  }

  Widget _buildChecklistTodayCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final title = CoachAiChecklistToday.todayCardTitle(lang);
    final body = m.text.trim();

    Color scoreColor(int score) {
      if (score >= 80) return const Color(0xFF34D399);
      if (score >= 40) return const Color(0xFFFBBF24);
      return const Color(0xFFF87171);
    }

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
              color: const Color(0xFF78350F).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF92400E)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.checklist_rounded, size: 17, color: Color(0xFFFBBF24)),
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
              child: FutureBuilder<ChecklistTodaySnapshot>(
                future: CoachAiChecklistToday.buildTodaySnapshot(),
                builder: (context, snap) {
                  final data = snap.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: _coachText(
                                size: 15,
                                color: const Color(0xFFFBBF24),
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (data != null && data.hasItemsDueToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: scoreColor(data.percent).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: scoreColor(data.percent).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                '${data.percent}%',
                                style: _coachText(
                                  size: 13,
                                  color: scoreColor(data.percent),
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (data != null && data.hasItemsDueToday) ...[
                        const SizedBox(height: 10),
                        for (final section in data.sections) ...[
                          if (section.title.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              section.title,
                              style: _coachText(
                                size: 12,
                                color: const Color(0xFF9CA3AF),
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                          for (final item in section.items)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    item.checked
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    size: 16,
                                    color: item.checked
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: _coachText(
                                        size: 13,
                                        color: item.checked
                                            ? const Color(0xFFD1D5DB)
                                            : const Color(0xFF9CA3AF),
                                        weight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CoachAiFormattedNarrative(text: body),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentalTodayCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final l10n = AppLocalizations.of(context)!;
    final snap = CoachAiMentalAnalysis.buildTodaySnapshot(
      l10n,
      _coachJournalTrades(),
    );
    final bd = snap.breakdown;
    final title = CoachAiMentalAnalysis.todayCardTitle(lang);
    final body = m.text.trim();

    Color scoreColor(int score) {
      if (score >= 50) return const Color(0xFF34D399);
      return const Color(0xFFF87171);
    }

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
            child: const Icon(Icons.psychology_outlined, size: 17, color: Color(0xFF34D399)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: _coachText(size: 15, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                      ),
                      if (bd != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: scoreColor(bd.overallPercent).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: scoreColor(bd.overallPercent).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            '${bd.overallPercent}%',
                            style: _coachText(
                              size: 13,
                              color: scoreColor(bd.overallPercent),
                              weight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CoachAiFormattedNarrative(text: body),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentalEmotionCard(_CoachAiMessage m, String question) {
    final mentalQuery =
        CoachAiMentalAnalysis.extractMentalQuery(question) ??
        const CoachMentalQuery(kind: 'emotion', label: 'émotion');
    final stats = CoachAiMentalAnalysis.buildStatsForQuery(
      _coachJournalTrades(),
      mentalQuery,
    );
    final query = stats?.query ?? mentalQuery;
    final title = CoachAiMentalAnalysis.displayTitle(query);
    final compareParts = _mentalCompareLabels(query).split('|');
    final leftTitle = compareParts.first;
    final rightTitle = compareParts.length > 1 ? compareParts[1] : 'Autre';

    String? verdict;
    if (stats != null) {
      if (stats.matchedTrades == 0 && stats.otherEtatTrades > 0) {
        verdict =
            'Aucun trade en $leftTitle — compare surtout la colonne $rightTitle (${stats.otherEtatTrades} trades).';
      } else if (stats.matchedClosed > 0 && stats.otherClosed > 0) {
        final wrDiff = stats.matchedWinrate - stats.otherWinrate;
        if (wrDiff.abs() >= 8) {
          verdict = wrDiff < 0
              ? 'Winrate ${wrDiff.abs().toStringAsFixed(0)} pts plus bas en $leftTitle.'
              : 'Winrate ${wrDiff.abs().toStringAsFixed(0)} pts plus haut en $leftTitle.';
        }
      }
    }

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
            child: const Icon(Icons.psychology_outlined, size: 17, color: Color(0xFF34D399)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _coachMentalFocusTitle(title)),
                      if (query.polarity == 'low')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F1D1D).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'BAS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              color: const Color(0xFFF87171),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (query.polarity == 'high')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'HAUT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              color: const Color(0xFF34D399),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (stats == null) ...[
                    const SizedBox(height: 10),
                    Text(
                      mentalQuery.kind == 'metric'
                          ? 'Renseigne ton état mental sur tes jours de trade pour activer cette comparaison.'
                          : 'Renseigne les émotions du jour sur tes trades pour activer cette comparaison.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        height: 1.45,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (stats != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1F2937)),
                      ),
                      child: _coachCoverageLine(
                        tradesEtat: stats.tradesWithEtatMental,
                        tradesMetric:
                            stats.query.kind == 'metric' ? stats.tradesWithMetricValue : null,
                        metricLabel: stats.query.kind == 'metric' ? stats.query.label : null,
                        split: stats.query.kind == 'metric' ? stats.splitValueUsed : null,
                      ),
                    ),
                    if (verdict != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF422006).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                verdict,
                                style: _coachText(
                                  size: 13.5,
                                  height: 1.4,
                                  color: const Color(0xFFFDE68A),
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _coachMentalCompareColumn(
                            title: leftTitle,
                            subtitle: 'Focus demandé',
                            trades: stats.matchedTrades,
                            closed: stats.matchedClosed,
                            winrate: stats.matchedWinrate,
                            pnl: stats.matchedPnl,
                            isPrimary: true,
                          ),
                          const SizedBox(width: 10),
                          _coachMentalCompareColumn(
                            title: rightTitle,
                            subtitle: 'Comparaison',
                            trades: stats.otherEtatTrades,
                            closed: stats.otherClosed,
                            winrate: stats.otherWinrate,
                            pnl: stats.otherPnl,
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
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
}
