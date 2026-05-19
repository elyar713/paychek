part of 'performance_export_pdf.dart';

Future<Uint8List> buildPerformancePdf({
  required List<Trade> disciplineTrades,
  required List<Trade> visibleTradesForAssets,
  required PerformancePeriodFilter periodFilter,
  required DateTime anchor,
  DateTime? customStart,
  required List<StrategieSessionPersisted> sessions,
  required StrategieGestionRisqueParams gestionParams,
  double? capitalAmount,
  required int journalItemCount,
  required List<PerformanceCustomLensSavedCard> customLensSavedCards,
  required List<ChecklistSectionData> checklistSections,
  required AppLocalizations l,
  required Locale uiLocale,
}) async {
  final locale = uiLocale;
  await PaychekPdfFonts.ensureLoaded();
  _perfPdfKo = locale.languageCode == 'ko';
  final pdfTheme = PaychekPdfFonts.theme();

  final t = disciplineTrades;
  final tm = visibleTradesForAssets;
  final agg = t.isEmpty
      ? const TradeAggregates(wins: 0, losses: 0, breakeven: 0)
      : aggregateTrades(t);
  final wrPct = (agg.winrate * 100).round();
  final now = DateTime.now();
  final exportDate =
      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  final period = _pdfText(_periodLabel(periodFilter, anchor, customStart, locale));
  final roll = computeDisciplineRollups(t);
  final worst = t.isEmpty ? 0.0 : worstSingleLoss(t);
  final avgDur = averageDurationMinutes(t);
  final slots = timeSlotWinRates(t, locale: locale);
  final wm = winRatesMindsetPrincipeFeeling(tm);
  final wrP = wm.$1;
  final nP = wm.$2;
  final wrF = wm.$3;
  final nF = wm.$4;
  final hv = computeHoraireTradingViolationStats(trades: t, sessions: sessions);
  final warnings = paychekStrategieWarnings(
    trades: t,
    params: gestionParams,
    sessions: sessions,
    locale: locale,
    capitalAmount: capitalAmount,
  );
  final (clFull, nCl) = winRateChecklistBand(t, (p) => p >= 80);
  final (plFull, nPl) = winRatePlanBand(t, (p) => p >= 80);
  final (etFull, nEt) = winRateEtatBand(t, (p) => p >= 80);
  final (wrStratOk, nStratOk, wrStratNo, nStratNo) =
      winRatesStrategieHighVsForced(t);
  final setupTitles = StrategieSetupsStore.notifier.value.map((e) => e.title).toList();
  final setupStats = winRatesByStrategieSetupTitles(t, setupTitles);
  StrategieSetupWinStat? topSetup;
  for (final s in setupStats) {
    if (s.count > 0) {
      topSetup = s;
      break;
    }
  }
  final violations = aggregateStrategieNonRespect(t);
  final buckets = durationBucketWinRates(t);
  final bestDur = pickBestDurationBucketByWinrate(buckets);
  final assets = computeTopAssetBarStats(visibleTradesForAssets, maxBars: 6);
  final obs = disciplineImpactObservation(t, locale: locale);
  final dailyJournalBuckets = dailyJournalVolumeBucketWinRatesLocalized(
    t,
    locale: locale,
  );

  final String journalLine = journalItemCount <= 0
      ? _p(
          locale,
          'journal - 0 trade',
          'journal - 0 trades',
          'diario - 0 operaciones',
          'Journal - 0 Trades',
          'diário - 0 trades',
          '저널 - 트레이드 0건',
        )
      : 'journal - $journalItemCount ${performanceTradeWordPlural(locale.languageCode, journalItemCount)}';
  final sourceLine =
      '${_p(locale, 'Source :', 'Source:', 'Fuente:', 'Quelle:', 'Fonte:', '출처:')} $journalLine';

  final lensIntro = StringBuffer();
  if (t.isEmpty) {
    lensIntro.write(
      _p(
        locale,
        "Ajoutez des trades depuis le journal pour obtenir une synthèse basée sur votre stratégie, vos pertes, le délai de position et vos scores discipline (état mental, checklist, analyse, stratégie).",
        'Add trades from your journal to get a summary based on your strategy, losses, position holding time, and discipline scores (mental state, checklist, analysis, strategy).',
        'Añade trades desde tu diario para obtener un resumen basado en tu estrategia, pérdidas, tiempo en posición y puntuaciones de disciplina (estado mental, checklist, análisis, estrategia).',
        'Fügen Sie Trades aus dem Journal hinzu, um eine Auswertung zu erhalten – Strategie, Verluste, Haltezeit und Disziplinwerte (mental, Checkliste, Analyse, Strategie).',
        'Adicione trades do diário para ver um resumo com base na estratégia, perdas, tempo em posição e disciplina (mental, checklist, análise, estratégia).',
        '일지에서 트레이드를 추가하면 전략·손실·보유 시간·규율 점수(멘탈·체크리스트·분석·전략) 요약을 볼 수 있습니다.',
      ),
    );
  } else {
    final n = t.length;
    lensIntro.write(
      _p(
        locale,
        'Sur cette période : ',
        'For this period: ',
        'En este período: ',
        'In diesem Zeitraum: ',
        'Neste período: ',
        '이번 기간: ',
      ),
    );
    lensIntro.write('$n');
    lensIntro.write(
      n > 1
          ? _p(locale, ' trades. ', ' trades. ', ' trades. ', ' Trades. ', ' trades. ', ' 트레이드. ')
          : _p(locale, ' trade. ', ' trade. ', ' trade. ', ' Trade. ', ' trade. ', ' 트레이드. '),
    );
    lensIntro.write(
      _p(
        locale,
        'Perte max sur une position : ',
        'Max loss on one position: ',
        'Pérdida máx. en una posición: ',
        'Max. Verlust je Position: ',
        'Perda máx. em uma posição: ',
        '포지션당 최대 손실: ',
      ),
    );
    lensIntro.write(worst.toStringAsFixed(0));
    lensIntro.write(
      _p(
        locale,
        '. Durée moyenne des positions : ',
        '. Average position duration: ',
        '. Duración media de posición: ',
        '. Mittlere Positionsdauer: ',
        '. Duração média das posições: ',
        '. 평균 보유 시간: ',
      ),
    );
    lensIntro.write('${avgDur.round()}');
    lensIntro.write(
      _p(locale, ' min. ', ' min. ', ' min. ', ' Min. ', ' min. ', '분. '),
    );
    if (roll.hasData) {
      final ae = roll.avgEtat.round();
      final ac = roll.avgChecklist.round();
      final ast = roll.avgStrategie.round();
      final ap = roll.avgPlan.round();
      lensIntro.write(
        _p(
          locale,
          'Globaux discipline : état mental ',
          'Discipline totals: mental state ',
          'Totales disciplina: estado mental ',
          'Disziplin gesamt: mental ',
          'Totais disciplina: estado mental ',
          '규율 합계: 멘탈 ',
        ),
      );
      lensIntro.write('$ae');
      lensIntro.write(
        _p(locale, ' %, checklist ', '%, checklist ', ' %, checklist ', ' %, Checkliste ', ' %, checklist ', ' %, 체크리스트 '),
      );
      lensIntro.write('$ac');
      lensIntro.write(
        _p(locale, ' %, stratégie ', '%, strategy ', ' %, estrategia ', ' %, Strategie ', ' %, estratégia ', ' %, 전략 '),
      );
      lensIntro.write('$ast');
      lensIntro.write(
        _p(locale, ' %, analyse / plan ', '%, analysis / plan ', ' %, análisis / plan ', ' %, Analyse / Plan ', ' %, análise / plano ', ' %, 분석/계획 '),
      );
      lensIntro.write('$ap');
      lensIntro.write(_p(locale, ' %. ', '%. ', ' %. ', ' %. ', ' %. ', ' %. '));
    }
  }

  final chips = <pw.Widget>[];
  if (roll.hasData) {
    chips.addAll([
      _chipTag('${_p(locale, 'État', 'State', 'Estado', 'Zustand', 'Estado', '상태')} ${roll.avgEtat.round()}%', PdfColors.grey600),
      _chipTag('CL ${roll.avgChecklist.round()}%', _cGreen()),
      _chipTag('${_p(locale, 'Strat', 'Strat', 'Estrat.', 'Strat.', 'Estrat.', '전략')} ${roll.avgStrategie.round()}%', _cOrange()),
      _chipTag('${_p(locale, 'Analyse', 'Analysis', 'Análisis', 'Analyse', 'Análise', '분석')} ${roll.avgPlan.round()}%', _cOrange()),
    ]);
  }

  final docTitle = _p(
    locale,
    'Journal de performance',
    'Performance journal',
    'Diario de rendimiento',
    'Performance-Journal',
    'Diário de performance',
    '퍼포먼스 저널',
  );
  final doc = pw.Document(
    title: paychekPdfNormalize(docTitle),
    author: 'PAYCHEK',
    theme: pdfTheme,
  );

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 40, 32, 36),
        theme: pdfTheme,
        buildBackground: (ctx) => pw.Container(color: _kCardBg),
      ),
      build: (context) => [
        pw.Center(
          child: _pdfW(
            docTitle.toUpperCase(),
            bold: true,
            fontSize: 18,
            color: _kPrimary,
            letterSpacing: 1.2,
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Container(
            width: 48,
            height: 3,
            decoration: pw.BoxDecoration(
              color: _kAccent,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: _pdfW(
            _p(
              locale,
              'Export $exportDate',
              'Performance journal - Export $exportDate',
              'Diario de rendimiento - Exportación $exportDate',
              'Performance-Journal - Export $exportDate',
              'Diário de performance - Exportação $exportDate',
              '퍼포먼스 저널 - 내보내기 $exportDate',
            ),
            fontSize: 9,
            color: _kMuted,
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Center(
          child: _pdfW(
            '${l.tradePdfPeriode}: $period',
            fontSize: 9,
            color: PdfColors.grey700,
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Container(height: 1, color: _kBorder),
        pw.SizedBox(height: 14),
        _headerWinrateRow(locale, l, wrPct, agg, sourceLine),
        pw.SizedBox(height: 12),
        _capitalEvolutionChartSection(locale, l, tm, capitalAmount),
        pw.SizedBox(height: 12),
        _sectionTitle('PAYCHEK LENS'),
        _card(
          bg: _kCardBg,
          children: [
            _pdfW(
              lensIntro.toString(),
              fontSize: 10,
              color: PdfColors.grey900,
              height: 1.4,
            ),
            if (chips.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Wrap(spacing: 6, runSpacing: 6, children: chips),
            ],
            if (warnings.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: _pdfW(
                  _p(
                    locale,
                    'AVERTISSEMENTS - SEUILS STRATÉGIE',
                    'WARNINGS — STRATEGY THRESHOLDS',
                    'ADVERTENCIAS - UMBRALES DE ESTRATEGIA',
                    'WARNHINWEISE – STRATEGIESCHWELLEN',
                    'AVISOS - LIMITES DA ESTRATÉGIA',
                    '경고 - 전략 기준선',
                  ),
                  bold: true,
                  fontSize: 9,
                  color: _cRedDark(),
                  letterSpacing: 0.4,
                ),
              ),
              for (final w in warnings.take(8)) _pdfBulletLine(w, warningStyle: true),
            ],
          ],
        ),
        ..._customLensPdfSection(
          locale: locale,
          l: l,
          trades: t,
          savedCards: customLensSavedCards,
          checklistSections: checklistSections,
        ),
        pw.SizedBox(height: 10),
        _sectionTitle(
          _p(
            locale,
            'JOURNÉE & VOLUME',
            'DAY & VOLUME',
            'DÍA Y VOLUMEN',
            'TAG & VOLUMEN',
            'DIA E VOLUME',
            '일·거래량',
          ),
        ),
        _card(
          bg: _kCardBg,
          children: [
            _pdfW(
              _p(
                locale,
                'Winrate selon le nombre de trades pris le même jour (période filtrée). '
                    'Tranches : 1 à 5, 6 à 10, plus de 10 trades / journée.',
                'Win rate by number of trades taken the same calendar day (filtered period). '
                    'Buckets: 1–5, 6–10, over 10 trades / day.',
                'Win rate según trades el mismo día (periodo filtrado). '
                    'Tramos: 1–5, 6–10, más de 10 trades / día.',
                'Gewinnrate nach Anzahl der Trades am selben Tag (gefiltert). '
                    'Stufen: 1–5, 6–10, über 10 Trades / Tag.',
                'Win rate por trades no mesmo dia (período filtrado). '
                    'Faixas: 1–5, 6–10, mais de 10 trades / dia.',
                '동일 거래일 기준 거래 수(필터 기간)별 승률. 구간: 1–5, 6–10, 하루 10건 초과.',
              ),
              fontSize: 8,
              color: _kMuted,
              height: 1.4,
            ),
            pw.SizedBox(height: 10),
            for (var i = 0; i < dailyJournalBuckets.length; i++)
              _dailyJournalBucketRow(locale, dailyJournalBuckets[i], i),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _card(
                topPadding: 0,
                children: [
                  _sectionTitle(
                    _p(
                      locale,
                      'HORAIRES DE PERFORMANCE',
                      'PERFORMANCE HOURS',
                      'HORARIOS DE RENDIMIENTO',
                      'PERFORMANCE-ZEITEN',
                      'HORÁRIOS DE PERFORMANCE',
                      '시간대별 성과',
                    ),
                  ),
                  _pdfW(
                    _p(
                      locale,
                      'Winrate par plage horaire.',
                      'Win rate by time window.',
                      'Win rate por franja horaria.',
                      'Gewinnrate nach Zeitfenster.',
                      'Win rate por janela de horário.',
                      '시간대별 승률.',
                    ),
                    fontSize: 8,
                    color: _kMuted,
                  ),
                  pw.SizedBox(height: 8),
                  for (final s in slots)
                    _horaireRow(
                      locale,
                      s.label,
                      s.winRate,
                      s.count,
                    ),
                  if (hv.sessionsConfigurees && hv.pendantFenetreNoTrade > 0) ...[
                    pw.SizedBox(height: 8),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: _cRedBg(),
                        border: pw.Border.all(color: _cRedDark()),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: _pdfW(
                        '${hv.pendantFenetreNoTrade} ${performanceTradeWordPlural(locale.languageCode, hv.pendantFenetreNoTrade)} '
                        '${_p(locale, 'en session No Trade.', 'during a No Trade session.', 'en sesión No Trade.', 'in einer No-Trade-Session.', 'em sessão No Trade.', '노트레이드 세션에서.')}',
                        bold: true,
                        fontSize: 9,
                        color: _cRedDark(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _card(
                children: [
                  _sectionTitle(
                    _p(
                      locale,
                      'MINDSET PRINCIPE / FEELING',
                      'MINDSET PRINCIPLE / FEELING',
                      'MINDSET PRINCIPIO / FEELING',
                      'MINDSET PRINZIP / FEELING',
                      'MINDSET PRINCÍPIO / FEELING',
                      '마인드셋 원칙 / 느낌',
                    ),
                  ),
                  _statPdfRow(locale, l.tradeMindsetPrinciple, wrP, nP, _cGreen()),
                  pw.SizedBox(height: 6),
                  _statPdfRow(locale, l.tradeMindsetFeeling, wrF, nF, _cOrange()),
                  pw.SizedBox(height: 8),
                  _mindsetFooter(locale, wrP, nP, wrF, nF),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        _sectionTitle(
          _p(
            locale,
            'DISCIPLINE & IMPACT',
            'DISCIPLINE & IMPACT',
            'DISCIPLINA & IMPACTO',
            'DISZIPLIN & IMPACT',
            'DISCIPLINA & IMPACTO',
            '규율 & 영향',
          ),
        ),
        _card(
          bg: _kCardBg,
          children: [
            _pdfW(
              _p(
                locale,
                'Détails - tranche respectée 80-100 % (winrate sur la période filtrée).',
                'Detail — 80–100% band (win rate on the filtered period).',
                'Detalle — banda 80–100 % (win rate en el período filtrado).',
                'Details – Band 80–100 % (Gewinnrate, gefilterter Zeitraum).',
                'Detalhe — faixa 80–100 % (win rate no período filtrado).',
                '상세 — 80~100% 구간 (필터 기간 승률).',
              ),
              fontSize: 8,
              color: _kMuted,
              height: 1.35,
            ),
            pw.SizedBox(height: 10),
            _discBar(
              locale,
              '${l.ajouterTradeDisciplineChecklistTitle} (${_p(locale, 'plan de session', 'session plan', 'plan de sesión', 'Session', 'plano de sessão', '세션 계획')})',
              clFull,
              nCl,
              _cGreen(),
            ),
            pw.SizedBox(height: 8),
            _discBar(
              locale,
              '${l.ajouterTradeDisciplinePlanTitle} (${_p(locale, 'plan de trade', 'trade plan', 'plan de trade', 'Trade-Plan', 'plano de trade', '트레이드 계획')})',
              plFull,
              nPl,
              _cGreen(),
            ),
            pw.SizedBox(height: 8),
            _discBar(
              locale,
              l.ajouterTradeDisciplineEtatTitle,
              etFull,
              nEt,
              _cGreen(),
            ),
            if (topSetup != null) ...[
              pw.SizedBox(height: 8),
              _discBar(
                locale,
                '${_p(locale, 'Exécution stratégique', 'Strategy execution', 'Ejecución estratégica', 'Strategische Ausführung', 'Execução estratégica', '전략 실행')} (${topSetup.title})',
                topSetup.winRate,
                topSetup.count,
                _cGreen(),
              ),
            ],
            if (nStratOk + nStratNo > 0) ...[
              pw.SizedBox(height: 10),
              _pdfW(
                _p(
                  locale,
                  'Stratégie respectée (slider Ajouter trade)',
                  'Strategy respected (Add trade slider)',
                  'Estrategia respetada (slider Añadir trade)',
                  'Strategie eingehalten (Slider Trade hinzufügen)',
                  'Estratégia respeitada (slider Adicionar trade)',
                  '전략 준수(트레이드 추가 슬라이더)',
                ),
                fontSize: 8,
                color: _kMuted,
              ),
              pw.SizedBox(height: 6),
              _discBar(
                locale,
                _p(
                  locale,
                  'Respectée (≥ 50 %)',
                  'Respected (≥ 50%)',
                  'Respetada (≥ 50%)',
                  'Eingehalten (≥ 50 %)',
                  'Respeitada (≥ 50%)',
                  '준수(≥50%)',
                ),
                wrStratOk,
                nStratOk,
                _cOrange(),
              ),
              pw.SizedBox(height: 8),
              _discBar(
                locale,
                _p(
                  locale,
                  'Forcée (< 50 %)',
                  'Forced (< 50%)',
                  'Forzada (< 50%)',
                  'Erzwungen (< 50 %)',
                  'Forçada (< 50%)',
                  '억지(<50%)',
                ),
                wrStratNo,
                nStratNo,
                _cRedDark(),
              ),
            ],
            if (violations.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _pdfW(
                _p(
                  locale,
                  'POINTS NON RESPECTÉS',
                  'MISSED RULES',
                  'PUNTOS NO CUMPLIDOS',
                  'NICHT BEACHTETE PUNKTE',
                  'REGRAS NÃO RESPEITADAS',
                  '미준수 항목',
                ),
                bold: true,
                fontSize: 9,
                color: _cRedDark(),
              ),
              pw.SizedBox(height: 6),
              for (final v in violations.take(12))
                _pdfBulletLine(
                  '${labelForStrategieNonRespectId(v.id, v.strategieTitle, l: l, locale: locale)} (x${v.count})',
                  warningStyle: true,
                ),
            ],
            pw.SizedBox(height: 10),
            _pdfW(
              '${_p(locale, 'Observation :', 'Observation:', 'Observación:', 'Beobachtung:', 'Observação:', '관찰:')} $obs',
              fontSize: 9,
              color: PdfColors.grey800,
              height: 1.35,
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _card(
                children: [
                  _sectionTitle(
                    _p(
                      locale,
                      'DURÉE DES POSITIONS',
                      'POSITION DURATION',
                      'DURACIÓN DE POSICIONES',
                      'POSITIONSDAUER',
                      'DURAÇÃO DAS POSIÇÕES',
                      '포지션 보유 시간',
                    ),
                  ),
                  if (bestDur != null)
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _pdfW(
                          '${_p(locale, 'Meilleur : ', 'Best: ', 'Mejor: ', 'Beste: ', 'Melhor: ', '최고: ')}${bestDur.label}',
                          fontSize: 9,
                          color: PdfColors.grey800,
                        ),
                        _pdfW(
                          '${(bestDur.winRate * 100).round()}% · ${bestDur.count} ${performanceTradeWordPlural(locale.languageCode, bestDur.count)}',
                          bold: true,
                          fontSize: 10,
                          color: _cGreen(),
                        ),
                      ],
                    )
                  else
                    _pdfW(
                      _p(
                        locale,
                        'Pas assez de données.',
                        'Not enough data.',
                        'Datos insuficientes.',
                        'Zu wenig Daten.',
                        'Dados insuficientes.',
                        '데이터가 부족합니다.',
                      ),
                      fontSize: 9,
                    ),
                  pw.SizedBox(height: 8),
                  for (final b in buckets.take(5))
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 3),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          _pdfW(b.label, fontSize: 8),
                          _pdfW(
                            b.count > 0
                                ? '${(b.winRate * 100).round()}% (${b.count} ${performanceTradeWordPlural(locale.languageCode, b.count)})'
                                : '— (0 ${performanceTradeWordPlural(locale.languageCode, 0)})',
                            fontSize: 8,
                            color: PdfColors.grey700,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _card(
                children: [
                  _sectionTitle(l.tradeMostTradedHeading.toUpperCase()),
                  if (assets.isEmpty)
                    _pdfW(
                      _p(
                        locale,
                        'Aucun symbole renseigné sur la période.',
                        'No symbol entered for this period.',
                        'Sin símbolo en este período.',
                        'Kein Symbol in diesem Zeitraum.',
                        'Nenhum símbolo neste período.',
                        '이 기간에 입력된 심볼이 없습니다.',
                      ),
                      fontSize: 9,
                    )
                  else
                    for (final a in assets)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: _pdfW(
                                a.symbol,
                                bold: true,
                                fontSize: 10,
                                color: PdfColors.grey900,
                              ),
                            ),
                            _pdfW(
                              '${a.count} ${performanceTradeWordPlural(locale.languageCode, a.count)} · ${(a.winRate * 100).round()}% WR',
                              bold: true,
                              fontSize: 9,
                              color: a.winRate >= 0.5 ? _cGreen() : _cRed(),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Center(
          child: _pdfW(
            _p(
              locale,
              'PAYCHEK - données journal, filtre Performance aligné sur l\'écran.',
              'PAYCHEK — journal data; Performance filter matches the screen.',
              'PAYCHEK - datos del diario; filtro Rendimiento alineado con la pantalla.',
              'PAYCHEK – Journaldaten; Performance-Filter wie im Bildschirm.',
              'PAYCHEK - dados do diário; filtro Performance como na tela.',
              'PAYCHEK - 일지 데이터, 화면과 동일한 퍼포먼스 필터.',
            ),
            fontSize: 8,
            color: PdfColors.grey500,
            fontStyle: pw.FontStyle.italic,
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );

  return doc.save();
}
