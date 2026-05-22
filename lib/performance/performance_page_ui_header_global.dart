part of 'performance_page.dart';

extension _PerformancePageUiHeaderGlobal on _PerformancePageState {
  Widget _dataSourceBanner() {
    final code = Localizations.localeOf(context).languageCode;
    String t(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);
    String tradesTxt(int n) => performanceTradeWordPlural(code, n);
    final pid = _portfolioStore?.activePortfolioId ?? kDefaultPortfolioId;
    final rawCount = _journalStore?.itemsForPortfolio(pid).length ?? 0;
    final shown = activeJournalTradesOrDemo(context);
    final n = shown.length;
    if (n == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          t(
            'Les analyses utilisent les trades de votre journal (onglet Trade). Ajoutez des trades pour voir des indicateurs réels.',
            'Analytics uses trades from your journal (Trade tab). Add trades to view real indicators.',
            'Los análisis usan los trades de tu diario (pestaña Trade). Agrega trades para ver indicadores reales.',
            'Die Auswertungen nutzen Trades aus Ihrem Journal (Trade-Tab). Fügen Sie Trades hinzu, um echte Kennzahlen zu sehen.',
            'As análises usam os trades do seu diário (aba Trade). Adicione trades para ver indicadores reais.',
            '분석은 일지(Trade 탭)의 트레이드를 사용합니다. 트레이드를 추가하면 실제 지표를 볼 수 있습니다.',
          ),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: _kGrey,
            height: 1.45,
          ),
        ),
      );
    }
    if (rawCount == 0 && n > 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(
                'Exemples de démonstration — $n ${tradesTxt(n)} (journal vide sur ce portefeuille).',
                'Demo sample — $n ${tradesTxt(n)} (journal empty for this portfolio).',
                'Muestra demo — $n ${tradesTxt(n)} (diario vacío en esta cartera).',
                'Demo-Beispiel — $n ${tradesTxt(n)} (Journal für dieses Portfolio leer).',
                'Demonstração — $n ${tradesTxt(n)} (diário vazio nesta carteira).',
                '데모 예시 — $n ${tradesTxt(n)}(이 포트폴리오 일지 비어 있음).',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: _kGrey,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t(
                'Enregistrez un trade pour afficher vos vraies statistiques.',
                'Save a trade to see your real statistics.',
                'Guarda un trade para ver tus estadísticas reales.',
                'Speichern Sie einen Trade, um Ihre echten Kennzahlen zu sehen.',
                'Salve um trade para ver suas estatísticas reais.',
                '트레이드를 저장하면 실제 통계가 표시됩니다.',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: PerformanceTokens.labelDim,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t(
          'Source : journal — $n ${tradesTxt(n)}',
          'Source: journal — $n ${tradesTxt(n)}',
          'Fuente: diario — $n ${tradesTxt(n)}',
          'Quelle: Journal — $n ${tradesTxt(n)}',
          'Fonte: diário — $n ${tradesTxt(n)}',
          '출처: 일지 — $n ${tradesTxt(n)}',
        ),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: PerformanceTokens.labelDim,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l = AppLocalizations.of(context)!;
    final code = Localizations.localeOf(context).languageCode;
    String t(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: _handleLeadingBack,
            style: IconButton.styleFrom(
              foregroundColor: _kGrey,
              padding: const EdgeInsets.all(10),
              minimumSize: const Size(40, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.homePerformance,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.4,
                      color: DashboardTokens.onMatteEmphasis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t(
                      'Indicateurs issus du journal et de la stratégie sur la période choisie.',
                      'Indicators from your journal and strategy for the selected period.',
                      'Indicadores del diario y la estrategia en el período elegido.',
                      'Kennzahlen aus Journal und Strategie für den gewählten Zeitraum.',
                      'Indicadores do diário e da estratégia no período escolhido.',
                      '선택한 기간의 일지·전략 지표.',
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: PerformanceTokens.labelMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 14, 0),
            child: Tooltip(
              message: t(
                'Exporter en PDF',
                'Export as PDF',
                'Exportar en PDF',
                'Als PDF exportieren',
                'Exportar em PDF',
                'PDF로 내보내기',
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: PerformanceTokens.greenTintBg,
                  border: Border.all(color: _kGreen, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _kGreen.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: widget.liteFreemiumRestricted
                        ? widget.onLiteFreemiumRestrictedTap
                        : _exportPerformancePdf,
                    borderRadius: BorderRadius.circular(14),
                    splashColor: _kGreen.withValues(alpha: 0.28),
                    highlightColor: _kGreen.withValues(alpha: 0.14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 23,
                            color: _kGreen,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'PDF',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: DashboardTokens.onMatteEmphasis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardGlobal(int winPct, TradeAggregates agg) {
    final code = Localizations.localeOf(context).languageCode;
    String t(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: _performanceSectionDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 104,
            height: 104,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(104, 104),
                  painter: WinrateRingPainter(
                    progress: agg.winrate.clamp(0.0, 1.0),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$winPct%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t(
                        'WINRATE',
                        'WINRATE',
                        'TASA',
                        'WINRATE',
                        'WINRATE',
                        '승률',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: PerformanceTokens.labelDim,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tradeRow(
                  t(
                    'Gagnants',
                    'Winners',
                    'Ganadores',
                    'Gewinner',
                    'Vencedores',
                    '승자',
                  ),
                  '${agg.wins}',
                  _kGreen,
                ),
                const SizedBox(height: 10),
                _tradeRow(
                  t(
                    'Perdants',
                    'Losers',
                    'Perdedores',
                    'Verlierer',
                    'Perdedores',
                    '패자',
                  ),
                  '${agg.losses}',
                  _kRed,
                ),
                const SizedBox(height: 10),
                _tradeRow(
                  t(
                    'Breakeven',
                    'Breakeven',
                    'Breakeven',
                    'Breakeven',
                    'Empate',
                    '본전',
                  ),
                  '${agg.breakeven}',
                  PerformanceTokens.labelFaint,
                ),
                const Divider(height: 20, color: _kBorder),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t(
                        'TOTAL TRADES',
                        'TOTAL TRADES',
                        'TOTAL DE TRADES',
                        'TRADES GESAMT',
                        'TOTAL DE TRADES',
                        '총 트레이드',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: PerformanceTokens.labelDim,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${agg.total}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiteFreemiumStatsPlaceholder() {
    final l = AppLocalizations.of(context)!;
    final code = Localizations.localeOf(context).languageCode;
    String t(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);
    final onTap = widget.onLiteFreemiumRestrictedTap;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
            decoration: _performanceSectionDecoration(),
            child: Column(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: _kGreen.withValues(alpha: 0.85),
                ),
                const SizedBox(height: 16),
                Text(
                  t(
                    'Statistiques réservées Pro',
                    'Pro statistics only',
                    'Estadísticas solo Pro',
                    'Statistiken nur mit Pro',
                    'Estatísticas apenas Pro',
                    'Pro 전용 통계',
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: DashboardTokens.onMatteEmphasis,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l.paywallLiteLimitedHint,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: PerformanceTokens.labelMuted,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    t(
                      'Appuyer pour passer à Pro',
                      'Tap to upgrade to Pro',
                      'Toca para pasar a Pro',
                      'Tippen für Pro-Upgrade',
                      'Toque para assinar o Pro',
                      '탭하여 Pro로 업그레이드',
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tradeRow(String label, String value, Color dot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: PerformanceTokens.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
