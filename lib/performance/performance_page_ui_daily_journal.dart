part of 'performance_page.dart';

extension _PerformancePageUiDailyJournal on _PerformancePageState {
  Widget _cardDailyJournalVolume(List<DailyJournalVolumeBucketStat> stats) {
    final code = Localizations.localeOf(context).languageCode;
    String t(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);
    String tradeWord(int n) => performanceTradeWordPlural(code, n);
    String dayWord(int n) => performanceDayWordPlural(code, n);
    // Tiret ASCII : le « — » (U+2014) peut manquer au sous-ensemble web de Plus Jakarta Sans (carré / tofu).
    String wrLabel(double wr, int n) =>
        n > 0 ? '${(wr * 100).round()}% WR' : '-';

    return _dashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            LucideIcons.calendarDays,
            t(
              'Journée & volume',
              'Day & volume',
              'Día y volumen',
              'Tag & Volumen',
              'Dia e volume',
              '일·거래량',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              'Winrate selon le nombre de trades pris le même jour (période filtrée). Tranches : 1 à 5, 6 à 10, plus de 10 trades / journée.',
              'Win rate by number of trades taken on the same day (filtered period). Ranges: 1 to 5, 6 to 10, more than 10 trades/day.',
              'Win rate según el número de trades tomados el mismo día (período filtrado). Rangos: 1 a 5, 6 a 10, más de 10 trades/día.',
              'Gewinnrate nach Anzahl Trades am selben Tag (gefiltert). Bereiche: 1–5, 6–10, mehr als 10 Trades/Tag.',
              'Win rate pelo número de trades no mesmo dia (período filtrado). Faixas: 1 a 5, 6 a 10, mais de 10 trades/dia.',
              '같은 날 진입한 트레이드 수 기준 승률(필터 기간). 구간: 1–5, 6–10, 10초과/일.',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: PerformanceTokens.labelMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < stats.length; i++)
            _statBarRow(
              stats[i].label,
              wrLabel(stats[i].winRate, stats[i].tradeCount),
              stats[i].winRate,
              i == 0 ? _kGreen : (i == 1 ? Colors.white : _kRed),
              sub: stats[i].tradeCount > 0
                  ? '${stats[i].tradeCount} ${tradeWord(stats[i].tradeCount)} · '
                        '${stats[i].dayCount} ${dayWord(stats[i].dayCount)}'
                  : null,
            ),
        ],
      ),
    );
  }
}
