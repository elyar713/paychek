part of 'performance_page.dart';

extension _PerformancePageUiLensDiscipline on _PerformancePageState {
  Widget _strategieWarningBullet(String w) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.alertTriangle, size: 15, color: _kRed.withValues(alpha: 0.95)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              w,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.4,
                color: const Color(0xFFCCCCCC),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _strategieWarningsListColumn(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final w in items) _strategieWarningBullet(w)],
    );
  }

  static const Color _kWarningsSplitLine = Color(0xFF333333);

  Widget _cardStrategieWarnings(List<String> strategieWarnings) {
    if (strategieWarnings.isEmpty) return const SizedBox.shrink();
    final code = Localizations.localeOf(context).languageCode;
    String txt(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);
    final splitAt = (strategieWarnings.length / 2).ceil();
    final left = strategieWarnings.sublist(0, splitAt);
    final right = strategieWarnings.sublist(splitAt);

    Widget splitBody({required bool sideBySide}) {
      if (strategieWarnings.length <= 1) {
        return _strategieWarningsListColumn(strategieWarnings);
      }
      if (sideBySide) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _strategieWarningsListColumn(left)),
              const SizedBox(width: 16),
              Container(width: 1, color: _kWarningsSplitLine),
              const SizedBox(width: 16),
              Expanded(child: _strategieWarningsListColumn(right)),
            ],
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _strategieWarningsListColumn(left),
          Container(height: 1, color: _kWarningsSplitLine),
          const SizedBox(height: 12),
          _strategieWarningsListColumn(right),
        ],
      );
    }

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
              color: const Color(0xFF666666),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 520;
              return splitBody(sideBySide: sideBySide);
            },
          ),
        ],
      ),
    );
  }

  Widget _cardEye(PaychekLensSnapshot lens) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _performanceSectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.eye, size: 18, color: _kGreen),
                  const SizedBox(width: 8),
                  Text(
                    'PAYCHEK LENS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: DashboardTokens.onMatteEmphasis,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(_pulseCtrl),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _kRed,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: _kRed.withValues(alpha: 0.5), blurRadius: 8)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(children: lens.narrativeSpans),
          ),
          if (lens.chips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in lens.chips)
                  _chip(
                    c.text,
                    bg: c.background,
                    fg: c.foreground,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: fg),
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
        ? const Color(0xFFE2E2E2)
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
                    color: const Color(0xFFCCCCCC),
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
                  color: right == '-' ? const Color(0xFF666666) : barColor,
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
                  color: const Color(0xFF666666),
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
              backgroundColor: const Color(0xFF151515),
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
        color: const Color(0xFF060606),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2F2F2F)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: child,
      ),
    );
  }

  /// Bloc Mindset : en-tête, barres verticales, synthèse par nombre de trades Principe / Feeling.
  Widget _mindsetPerformanceBlock({
    required String Function(String fr, String en, String es, String de, String pt, String ko) txt,
    required String Function(int n) tradesWord,
    required String principleLabel,
    required String feelingLabel,
    required double wrP,
    required double wrF,
    required int nP,
    required int nF,
    required String wrTextP,
    required String wrTextF,
  }) {
    const trackH = 158.0;
    const gap = 14.0;

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
      final barColor = fillColor == Colors.white ? const Color(0xFFE8E8E8) : fillColor;
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
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: (wrText == '-' || n == 0) ? const Color(0xFF666666) : barColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: trackH,
            child: LayoutBuilder(
              builder: (context, c) {
                final w = math.min(104.0, c.maxWidth * 0.88);
                final radius = 18.0;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: w,
                    height: trackH,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
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
                Icon(rowIcon, size: 14, color: const Color(0xFFAAAAAA)),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
      Color kickerColor = const Color(0xFF6B6B6B),
      Color valueColor = Colors.white,
      IconData? icon,
      Color? iconColor,
      Color? dotColor,
    }) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF080808),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF262626)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kicker,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: kickerColor,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null && iconColor != null)
              Icon(icon, size: 18, color: iconColor),
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
                color: const Color(0xFF0A1210),
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
                    txt('Mindset', 'Mindset', 'Mindset', 'Mindset', 'Mindset', '마인드셋'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    txt('PRINCIPAL / FEELING', 'PRINCIPLE / FEELING', 'PRINCIPAL / FEELING', 'PRINZIP / FEELING', 'PRINCÍPIO / FEELING', '원칙 / 느낌'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6F6F6F),
                      letterSpacing: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: txt(
                'Hauteur des barres = win rate sur les trades classés Principe ou Feeling (période filtrée). Les deux cases en bas rappellent le volume de trades par mindset.',
                'Bar height = win rate on trades tagged Principle or Feeling (filtered period). The two tiles below show trade counts per mindset.',
                'Altura = win rate en trades Principio/Feeling (período). Las dos cajas abajo muestran el volumen por mindset.',
                'Balkenhöhe = Gewinnrate je Prinzip/Feeling (Zeitraum). Die Kästen unten zeigen die Trade-Anzahl pro Mindset.',
                'Altura = win rate em Princípio/Feeling (período). Os blocos abaixo mostram a contagem por mindset.',
                '막대 높이 = 원칙/느낌 태그 트레이드 승률(필터 기간). 아래 두 칸은 마인드셋별 트레이드 수입니다.',
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.info_outline_rounded, size: 19, color: const Color(0xFF5C5C5C)),
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
          ],
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: const Color(0xFF1F1F1F)),
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
            const SizedBox(width: 8),
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
          ],
        ),
      ],
    );
  }

  Widget _cardDiscipline() {
    final code = Localizations.localeOf(context).languageCode;
    String txt(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);
    String trades(int n) => performanceTradeWordPlural(code, n);
    final l = AppLocalizations.of(context)!;
    final t = _disciplineVisibleTrades;
    /// Mindset ne repose pas sur les % discipline : inclut aussi les saisies « lite » (import, etc.).
    final tm = _visibleTrades;
    final (fullWr, nFull) = winRateChecklistBand(t, (p) => p >= 80);
    final (partWr, nPart) = winRateChecklistBand(t, (p) => p >= 50 && p < 80);
    final (ignWr, nIgn) = winRateChecklistBand(t, (p) => p < 50);
    final (fullPl, nFullPl) = winRatePlanBand(t, (p) => p >= 80);
    final (partPl, nPartPl) = winRatePlanBand(t, (p) => p >= 50 && p < 80);
    final (ignPl, nIgnPl) = winRatePlanBand(t, (p) => p < 50);
    final (fullEt, nFullEt) = winRateEtatBand(t, (p) => p >= 80);
    final (partEt, nPartEt) = winRateEtatBand(t, (p) => p >= 50 && p < 80);
    final (ignEt, nIgnEt) = winRateEtatBand(t, (p) => p < 50);
    final (wrP, nP, wrF, nF) = winRatesMindsetPrincipeFeeling(tm);
    final strategieViolations = aggregateStrategieNonRespect(t);
              final (wrHighStrat, nHighStrat, wrLowStrat, nLowStrat) =
                  winRatesStrategieHighVsForced(t);

    String wrLabel(double wr, int n) => n > 0 ? '${(wr * 100).round()}% WR' : '-';

    return _dashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            LucideIcons.brain,
            txt('Discipline & Impact', 'Discipline & Impact', 'Disciplina e impacto', 'Disziplin & Wirkung', 'Disciplina e impacto', '규율·영향'),
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
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF888888), height: 1.45),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final threeCol = constraints.maxWidth >= 720;

              Widget checklistBlock() => Column(
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

              Widget analyseBlock() => Column(
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

              Widget etatBlock() => Column(
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
                    txt('Exécution Stratégique', 'Strategy execution', 'Ejecución estratégica', 'Strategieumsetzung', 'Execução da estratégia', '전략 실행'),
                  ),
                  const SizedBox(height: 6),
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
                      color: const Color(0xFF888888),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: StrategieSetupsStore.notifier,
                    builder: (context, _) {
                      final titles =
                          StrategieSetupsStore.notifier.value.map((e) => e.title).toList();
                      final stats = winRatesByStrategieSetupTitles(t, titles);
                      final any = stats.any((s) => s.count > 0);
                      if (!any) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            txt(
                              'Aucun trade avec stratégie renseignée sur cette période.',
                              'No trades with strategy filled in for this period.',
                              'No hay trades con estrategia rellenada en este período.',
                              'Keine Trades mit ausgefüllter Strategie in diesem Zeitraum.',
                              'Nenhum trade com estratégia preenchida neste período.',
                              '이 기간에 전략이 입력된 트레이드 없음.',
                            ),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF888888),
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
                                sub:
                                    '${s.count} ${trades(s.count)}',
                              ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
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
                      color: const Color(0xFF888888),
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
                    sub: nHighStrat > 0 ? '$nHighStrat ${trades(nHighStrat)}' : null,
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
                    sub: nLowStrat > 0 ? '$nLowStrat ${trades(nLowStrat)}' : null,
                  ),
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
                        color: const Color(0xFF888888),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...strategieViolations.take(14).map(
                          (v) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
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
                                      color: const Color(0xFFBBBBBB),
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
                    principleLabel: txt('Principal', 'Principle', 'Principio', 'Prinzip', 'Princípio', '원칙'),
                    feelingLabel: l.tradeMindsetFeeling,
                    wrP: wrP,
                    wrF: wrF,
                    nP: nP,
                    nF: nF,
                    wrTextP: wrLabel(wrP, nP),
                    wrTextF: nF > 0
                        ? wrLabel(wrF, nF)
                        : txt('0 % WR', '0% WR', '0 % WR', '0 % WR', '0 % WR', '0% WR'),
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
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFAAAAAA), height: 1.45),
              children: [
                TextSpan(
                  text: txt('Observation : ', 'Observation: ', 'Observación: ', 'Beobachtung: ', 'Observação: ', '관찰: '),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: disciplineImpactObservation(t, locale: Localizations.localeOf(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
