part of 'coach_ai_page.dart';

extension _CoachAiPageCardsPerf on _CoachAiPageState {
  Widget _buildAppPricingCard(_CoachAiMessage m) {
    final lang = _responseLang(m.relatedUserQuestion);
    final title = CoachAiAppPricing.cardTitle(lang);
    final subtitle = CoachAiAppPricing.cardSubtitle(lang);
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
              color: const Color(0xFF422006).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.45)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.payments_outlined, size: 17, color: Color(0xFFF59E0B)),
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
                          style: _coachText(size: 15, color: const Color(0xFFF59E0B), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: subtitle,
                          style: _coachText(size: 15, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
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

  Widget _buildAppHelpCard(_CoachAiMessage m, String question, {required String focus}) {
    final lang = _responseLang(question);
    final steps = CoachAiAppHelp.uiStepsForQuestion(question, lang);
    final slug = CoachAiAppHelp.resolveGuideSlug(question);
    final hybrid = focus == 'app_help_hybrid' || CoachAiAppHelp.usesHybridHelpLayout(question);
    final intro = hybrid ? CoachAiAppHelp.workflowCoachIntro(lang) : null;
    final title = CoachAiAppHelp.localCardTitle(question, lang) ??
        (slug == null
            ? 'Aide PAYCHEK'
            : helpCenterArticles
                .where((a) => a.slug == slug)
                .map((a) => a.frenchTitle)
                .firstOrNull ??
                'Aide PAYCHEK');
    final subtitle = hybrid
        ? (lang == 'fr' ? ' · explication + mode d’emploi' : ' · guide + how-to')
        : (lang == 'fr' ? ' · mode d’emploi' : ' · how-to');

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
                          text: subtitle,
                          style: _coachText(size: 15, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (intro != null && intro.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF422006).withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        intro,
                        style: _coachText(
                          size: 13.5,
                          height: 1.5,
                          color: const Color(0xFFFDE68A),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (steps.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    if (hybrid)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          lang == 'fr' ? 'Où cliquer dans l’app' : 'Where to tap in the app',
                          style: _coachText(
                            size: 12,
                            color: const Color(0xFF9CA3AF),
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    for (var i = 0; i < steps.length; i++)
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
                                steps[i],
                                style: _coachText(size: 14, color: const Color(0xFFE5E7EB), weight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  if (m.text.trim().isNotEmpty && steps.isEmpty) ...[
                    const SizedBox(height: 8),
                    CoachAiFormattedNarrative(text: m.text),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOvertradingCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final body = m.text.trim();
    final trades = _coachJournalTrades();
    final period = CoachAiPerformanceFocus.resolvePeriod(question);
    final periodLabel = CoachAiPerformanceFocus.periodLabel(period, lang);

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
              color: const Color(0xFF7C2D12).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF9A3412)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.speed_rounded, size: 17, color: Color(0xFFFB923C)),
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
                  Text(
                    lang == 'fr' ? 'Overtrading · $periodLabel' : 'Overtrading · $periodLabel',
                    style: _coachText(size: 15, color: const Color(0xFFFB923C), weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  for (final bucket in CoachAiPerformanceFocus.overtradingSnapshots(
                    trades,
                    lang,
                    question,
                  ))
                    if (bucket.hasData)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                bucket.label,
                                style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                              ),
                            ),
                            Text(
                              '${bucket.winratePercent}% WR · ${bucket.tradeCount} trades',
                              style: _coachText(size: 12, color: const Color(0xFFD1D5DB)),
                            ),
                          ],
                        ),
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

  Widget _buildPerformanceLensCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final body = m.text.trim();
    final trades = _coachJournalTrades();
    final period = CoachAiPerformanceFocus.resolvePeriod(question);
    final periodLabel = CoachAiPerformanceFocus.periodLabel(period, lang);
    final composite = CoachAiPerformanceFocus.compositeDisciplinePercent(trades, question);

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
            child: const Icon(Icons.visibility_outlined, size: 17, color: Color(0xFF34D399)),
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
                          'Paychek Lens · $periodLabel',
                          style: _coachText(size: 15, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                      ),
                      if (composite != null)
                        Text(
                          '$composite%',
                          style: _coachText(size: 14, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final axis in CoachAiPerformanceFocus.lensAxisSnapshots(trades, lang, question))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${axis.label} : ${axis.qualifiedCount}/${axis.totalCount}',
                        style: _coachText(size: 12, color: const Color(0xFF9CA3AF)),
                      ),
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

  Widget _buildPerformanceSummaryCard(_CoachAiMessage m, String question) {
    final lang = _responseLang(question);
    final period = CoachAiPerformanceFocus.resolvePeriod(question);
    final periodLabel = CoachAiPerformanceFocus.periodLabel(period, lang);
    final split = CoachAiPerformanceSummary.build(
      CoachAiPerformanceFocus.filterJournalItems(
        _coachJournalTrades(),
        period,
      ),
    );
    final recorded = split.fullyRecorded;
    final incomplete = split.disciplineIncomplete;
    final global = split.global;

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
                          text: 'Performance',
                          style: _coachText(size: 16, color: const Color(0xFF34D399), weight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: ' · $periodLabel',
                          style: _coachText(size: 16, color: Colors.white, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Journal : ${global.tradesTotal} trades · ${global.tradesClosed} clôturés · '
                    'PnL ${global.pnlTotal >= 0 ? '+' : ''}${global.pnlTotal} · '
                    'WR ${global.winratePercent}%',
                    style: _coachText(size: 13, color: const Color(0xFF6B7280), weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _coachMentalCompareColumn(
                          title: 'Enregistrés',
                          subtitle: '4/4 discipline',
                          trades: recorded.tradesTotal,
                          closed: recorded.tradesClosed,
                          winrate: recorded.winratePercent,
                          pnl: recorded.pnlTotal,
                          isPrimary: true,
                        ),
                        const SizedBox(width: 10),
                        _coachMentalCompareColumn(
                          title: 'Non enregistrés',
                          subtitle: 'Donnée(s) manquante(s)',
                          trades: incomplete.tradesTotal,
                          closed: incomplete.tradesClosed,
                          winrate: incomplete.winratePercent,
                          pnl: incomplete.pnlTotal,
                          isPrimary: false,
                        ),
                      ],
                    ),
                  ),
                  if (incomplete.tradesTotal > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Complète checklist, analyse, stratégie et état mental sur tes trades '
                      'pour une performance PAYCHEK fiable.',
                      style: _coachText(size: 13, color: const Color(0xFF9CA3AF), weight: FontWeight.w500),
                    ),
                  ],
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

  Widget _buildAiAuditCard(_CoachAiMessage m, {required String focus}) {
    final snap = _computeAuditSnapshot();
    final diagnosis = _extractSectionBody(m.text, '3');
    final actions = _extractSectionBody(m.text, '4');
    final focusedPillar = _pillarForFocus(snap.disciplinePillars, focus);
    final isFull = focus == 'full';
    final pillar = focusedPillar;
    final isPillarFocus = pillar != null;
    final isTradeCountFocus = focus == 'trade_count';
    final showDetailed = isFull || isPillarFocus;

    Widget infoBlock({
      required IconData icon,
      required String title,
      required String body,
    }) {
      if (body.isEmpty) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: const Color(0xFF34D399)),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                height: 1.45,
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
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
            child: const Text('✨', style: TextStyle(fontSize: 14)),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F2937)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.26),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📊', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 8),
                      Text(
                        isPillarFocus ? 'Focus ${pillar.title}' : 'Bilan Paychek',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 27 / 2,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPillarFocus
                        ? 'Analyse ciblée sur ${pillar.title.toLowerCase()} (trades enregistrés uniquement).'
                        : 'Voici un récapitulatif de votre activité :',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.4,
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isFull) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _kpiTile('Trades totaux', '${snap.tradesTotal}'),
                        _kpiTile('Trades clôturés', '${snap.tradesClosed}'),
                        _kpiTile('Gagnants', '${snap.wins}'),
                        _kpiTile('Perdants', '${snap.losses}'),
                        _kpiTile('Winrate', '${snap.winratePercent}%'),
                        _kpiTile(
                          'PnL total',
                          '${snap.pnlTotal}',
                          valueColor: snap.pnlTotal >= 0
                              ? const Color(0xFF34D399)
                              : const Color(0xFFF87171),
                        ),
                      ],
                    ),
                  ],
                  if (showDetailed) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Audit discipline',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (isPillarFocus) _disciplinePillarCard(pillar)
                        else
                          for (final pillar in snap.disciplinePillars)
                            _disciplinePillarCard(pillar),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF14532D)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFF34D399),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pour calculer les performances, PAYCHEK prend en compte '
                              'uniquement les trades enregistrés (checklist, analyse, '
                              'stratégie, état mental). '
                              'Si tu veux un bilan sur tous tes trades, complète les '
                              'données manquantes depuis la page Ajouter un trade.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.2,
                                height: 1.45,
                                color: const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Diagnostic performance',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bilan calculé uniquement sur les trades enregistrés de chaque section.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isPillarFocus) _performancePillarSection(pillar)
                    else
                      for (final pillar in snap.disciplinePillars)
                        _performancePillarSection(pillar),
                  ],
                  if (m.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _coachNarrativeBlock(
                      diagnosis.isNotEmpty && !isTradeCountFocus ? diagnosis : m.text,
                      maxLines: isPillarFocus ? 4 : (isTradeCountFocus ? 3 : 5),
                    ),
                  ],
                  if (isFull && diagnosis.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    infoBlock(
                      icon: Icons.analytics_outlined,
                      title: 'Analyse coach',
                      body: diagnosis,
                    ),
                  ],
                  if (isFull && actions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    infoBlock(
                      icon: Icons.flag_circle_outlined,
                      title: 'Plan d\'action',
                      body: actions,
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
