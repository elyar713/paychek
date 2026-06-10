part of 'performance_page.dart';

extension _PerformancePageUiLensDisciplineLens on _PerformancePageState {
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

}
