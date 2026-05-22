part of 'performance_page.dart';

extension _PerformancePageUiDuration on _PerformancePageState {
  Widget _cardDuration(List<DurationBucketStat> buckets) {
    final code = Localizations.localeOf(context).languageCode;
    String t(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);
    String trades(int n) => performanceTradeWordPlural(code, n);
    const emptyBucket = DurationBucketStat(label: '', winRate: 0, count: 0);
    final b = buckets.isNotEmpty
        ? buckets
        : List.generate(9, (_) => emptyBucket);
    final best = pickBestDurationBucketByWinrate(b);
    return _dashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            LucideIcons.clock,
            t(
              'Durée des positions',
              'Position duration',
              'Duración de posiciones',
              'Positionsdauer',
              'Duração das posições',
              '포지션 보유 시간',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              'Meilleur winrate calculé sur vos durées de position (période filtrée).',
              'Best win rate computed from your position durations (filtered period).',
              'Mejor win rate calculado sobre tus duraciones de posición (período filtrado).',
              'Beste Gewinnrate aus Ihren Positionsdauern (gefilterter Zeitraum).',
              'Melhor win rate com base nas durações de posição (período filtrado).',
              '포지션 보유 시간 기준 최고 승률(필터 기간).',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: PerformanceTokens.labelMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          if (best != null) ...[
            Text(
              t(
                'Meilleur winrate',
                'Best win rate',
                'Mejor win rate',
                'Beste Gewinnrate',
                'Melhor win rate',
                '최고 승률',
              ),
              style: _labelStyle(),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  best.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(best.winRate * 100).round()}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _kGreen,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              t(
                '${best.count} ${trades(best.count)} dans cette tranche',
                '${best.count} ${trades(best.count)} in this range',
                '${best.count} ${trades(best.count)} en este rango',
                '${best.count} ${trades(best.count)} in diesem Bereich',
                '${best.count} ${trades(best.count)} nesta faixa',
                '${best.count} ${trades(best.count)} 이 구간',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: _kGrey,
                height: 1.3,
              ),
            ),
          ] else
            Text(
              t(
                'Aucune durée de position disponible sur cette période.',
                'No position duration data available for this period.',
                'No hay datos de duración de posición para este período.',
                'Keine Positionsdauer für diesen Zeitraum.',
                'Nenhuma duração de posição neste período.',
                '이 기간에 포지션 보유 시간 데이터 없음.',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: PerformanceTokens.labelMuted,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 20),
          Container(height: 1, color: _kBorder),
          const SizedBox(height: 20),
          Text(
            t(
              'Répartition du winrate par durée de position',
              'Win rate distribution by position duration',
              'Distribución del win rate por duración de posición',
              'Gewinnrate nach Positionsdauer',
              'Distribuição do win rate por duração de posição',
              '보유 시간대별 승률 분포',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: PerformanceTokens.labelMuted,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < b.length; i++)
                    SizedBox(
                      width: 56,
                      child: _miniBar(
                        (b[i].winRate * 100).round(),
                        b[i].winRate,
                        b[i].label.isEmpty ? '-' : b[i].label,
                        i.isEven ? Colors.white : PerformanceTokens.labelFaint,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: PerformanceTokens.labelDim,
    letterSpacing: 0.5,
  );

  Widget _miniBar(int pctText, double wr, String label, Color color) {
    const trackH = 56.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$pctText%',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: trackH,
            width: double.infinity,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1,
                heightFactor: (0.12 + wr.clamp(0.0, 1.0) * 0.88).clamp(
                  0.12,
                  1.0,
                ),
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: PerformanceTokens.labelDim,
            ),
          ),
        ],
      ),
    );
  }
}
