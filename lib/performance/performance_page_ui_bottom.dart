part of 'performance_page.dart';

extension _PerformancePageUiBottom on _PerformancePageState {
  String _marketLabel(AjouterTradeAssetClass market, AppLocalizations l) {
    final code = Localizations.localeOf(context).languageCode;
    switch (market) {
      case AjouterTradeAssetClass.forex:
        return 'Forex';
      case AjouterTradeAssetClass.indice:
        return performancePickLang(code, 'Indice', 'Index', 'Índice', 'Index', 'Índice', '지수');
      case AjouterTradeAssetClass.future:
        return performancePickLang(code, 'Future', 'Futures', 'Futuros', 'Futures', 'Futuros', '선물');
      case AjouterTradeAssetClass.crypto:
        return 'Crypto';
      case AjouterTradeAssetClass.stock:
        return performancePickLang(code, 'Action', 'Stock', 'Acción', 'Aktie', 'Ação', '주식');
      case AjouterTradeAssetClass.matieresPremieres:
        return performancePickLang(
          code,
          'Matières premières',
          'Commodities',
          'Materias primas',
          'Rohstoffe',
          'Commodities',
          '원자재',
        );
    }
  }

  /// Piste + remplissage en pilule (coins ronds), plus lisible qu’un [LinearProgressIndicator] plat.
  /// [fill01] null = piste vide seulement.
  Widget _roundedHistogramBar({
    double? fill01,
    required Color fillColor,
    double height = 11,
  }) {
    final r = height / 2;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        var fillW = 0.0;
        if (fill01 != null) {
          final eff = fill01.clamp(0.0, 1.0);
          if (eff > 0) {
            fillW = w * eff;
            final minDot = math.max(height * 0.92, w * 0.032);
            if (fillW < minDot) fillW = minDot;
            if (fillW > w) fillW = w;
          }
        }

        return SizedBox(
          height: height,
          width: w,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.centerLeft,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(r),
                  border: Border.all(color: const Color(0xFF2E2E2E)),
                ),
                child: SizedBox(width: w, height: height),
              ),
              if (fillW > 0)
                Container(
                  width: fillW,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r),
                    color: fillColor,
                    boxShadow: [
                      BoxShadow(
                        color: fillColor.withValues(alpha: 0.22),
                        blurRadius: 8,
                        spreadRadius: -1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _cardVolume() {
    final code = Localizations.localeOf(context).languageCode;
    String t(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);
    final vol = volumeBucketWinRatesForMarche(_visibleTrades, _volumeSectionMarche);

    return _dashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            LucideIcons.layers,
            t('Volume & Taille de Lot', 'Volume & Lot Size', 'Volumen y tamaño de lote', 'Volumen & Lotgröße', 'Volume e tamanho do lote', '거래량·랏 크기'),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final m in AjouterTradeAssetClass.values)
                _volumeMarcheChip(m),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            t('Winrate par tranche', 'Win rate by range', 'Win rate por rango', 'Gewinnrate nach Band', 'Win rate por faixa', '구간별 승률'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7A7A7A),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < vol.length; i++)
            _volumeBucketRow(
              vol[i],
              i == 0 ? _kGreen : (i == 1 ? Colors.white : _kRed),
            ),
        ],
      ),
    );
  }

  Widget _volumeMarcheChip(AjouterTradeAssetClass m) => _assetMarcheChip(
        m: m,
        selected: _volumeSectionMarche,
        onSelected: () => _setVolumeSectionMarche(m),
      );

  Widget _mostTradedMarcheChip(AjouterTradeAssetClass m) => _assetMarcheChip(
        m: m,
        selected: _mostTradedSectionMarche,
        onSelected: () => _setMostTradedSectionMarche(m),
      );

  Widget _assetMarcheChip({
    required AjouterTradeAssetClass m,
    required AjouterTradeAssetClass selected,
    required VoidCallback onSelected,
  }) {
    final l = AppLocalizations.of(context)!;
    final sel = selected == m;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF2C3A48) : const Color(0xFF141414),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: sel ? const Color(0xFF4A5A6A) : const Color(0xFF333333),
            ),
          ),
          child: Text(
            _marketLabel(m, l),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: sel ? Colors.white : const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _volumeBucketRow(VolumeBucketStat v, Color fillColor) {
    final code = Localizations.localeOf(context).languageCode;
    String t(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);
    String tradesWord(int n) => performanceTradeWordPlural(code, n);

    final has = v.count > 0;
    final right = has ? '${(v.winRate * 100).round()}% WR' : '-';
    final sub = has
        ? '${v.count} ${tradesWord(v.count)}'
        : t('Aucun trade dans ce bucket', 'No trades in this bucket', 'Sin trades en este bloque', 'Kein Trade in diesem Bereich', 'Nenhum trade nesta faixa', '이 구간에 트레이드 없음');
    final fill = v.winRate.clamp(0.0, 1.0);
    // Barre invisible à 0 % : on garde un minimum visible si au moins un trade.
    final indicatorValue = !has
        ? null
        : (fill < 0.02
            ? 0.06
            : fill);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  v.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDDDDDD),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    right,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: has ? fillColor : const Color(0xFF666666),
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (!has)
            Container(
              height: 5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFF333333)),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: indicatorValue,
                minHeight: 5,
                backgroundColor: const Color(0xFF111111),
                color: fillColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _cardMostTradedAssetBars(List<AssetTradeBarStat> stats) {
    final code = Localizations.localeOf(context).languageCode;
    String t(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);
    final maxCount = stats.isEmpty ? 1 : stats.map((e) => e.count).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _performanceSectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            LucideIcons.trendingUp,
            t('Actif le plus tradé', 'Most traded asset', 'Activo más tradeado', 'Meist gehandeltes Instrument', 'Ativo mais negociado', '가장 많이 거래한 종목'),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final m in AjouterTradeAssetClass.values) _mostTradedMarcheChip(m),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t(
              'Nombre de trades par symbole (période filtrée). Barres = volume relatif, pourcentage = winrate.',
              'Number of trades per symbol (filtered period). Bars = relative volume, percentage = win rate.',
              'Número de trades por símbolo (período filtrado). Barras = volumen relativo, porcentaje = win rate.',
              'Anzahl Trades pro Symbol (gefilterter Zeitraum). Balken = relatives Volumen, Prozent = Gewinnrate.',
              'Número de trades por símbolo (período filtrado). Barras = volume relativo, % = win rate.',
              '심볼별 트레이드 수(필터 기간). 막대 = 상대 거래량, % = 승률.',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF888888),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          if (stats.isEmpty)
            Text(
              t(
                'Aucun trade pour ce marché sur la période (symbole renseigné).',
                'No trades for this market in the period (symbol required).',
                'Sin trades para este mercado en el período (símbolo requerido).',
                'Keine Trades für diesen Markt im Zeitraum (Symbol erforderlich).',
                'Nenhum trade para este mercado no período (símbolo obrigatório).',
                '이 기간·시장에 해당하는 트레이드가 없습니다(종목 필요).',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFFAAAAAA),
                height: 1.45,
              ),
            )
          else
            for (var i = 0; i < stats.length; i++)
              _mostTradedAssetBarRow(
                stats[i],
                maxCount,
                i.isEven ? Colors.white : const Color(0xFF6B7A8A),
              ),
        ],
      ),
    );
  }

  Widget _mostTradedAssetBarRow(AssetTradeBarStat s, int maxCount, Color barColor) {
    final code = Localizations.localeOf(context).languageCode;
    String tradesWord(int n) => performanceTradeWordPlural(code, n);

    final fill = maxCount <= 0 ? 0.0 : (s.count / maxCount).clamp(0.0, 1.0);
    final wrPct = (s.winRate * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  s.symbol,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFDDDDDD),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${s.count} ${tradesWord(s.count)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  Text(
                    '$wrPct% WR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: s.winRate >= 0.5 ? _kGreen : _kRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          _roundedHistogramBar(
            fill01: fill < 0.04 ? 0.04 : fill,
            fillColor: barColor,
            height: 11,
          ),
        ],
      ),
    );
  }

  Widget _dashCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _performanceSectionDecoration(),
      child: child,
    );
  }

  Widget _cardTitle(IconData icon, String title, {Color titleColor = const Color(0xFF9A9A9A)}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _kGreen.withValues(alpha: 0.9)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 12, color: _kGrey),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }

  Widget _statBarRow(String left, String right, double fill, Color fillColor, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  left,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFCCCCCC)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    right,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: fillColor),
                  ),
                  if (sub != null)
                    Text(
                      sub,
                      style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w500, color: const Color(0xFF666666)),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fill.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: const Color(0xFF111111),
              color: fillColor,
            ),
          ),
        ],
      ),
    );
  }
}
