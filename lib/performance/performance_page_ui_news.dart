part of 'performance_page.dart';

extension _PerformancePageUiNews on _PerformancePageState {
  Widget _cardNewsTiming(List<Trade> trades) {
    final code = Localizations.localeOf(context).languageCode;
    String txt(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);

    final before = trades.where((t) => t.avantNews).toList(growable: false);
    final after = trades.where((t) => t.apresNews).toList(growable: false);
    final any = before.isNotEmpty || after.isNotEmpty;

    int wins(List<Trade> xs) => xs.where((t) => t.win).length;
    double wr(List<Trade> xs) => xs.isEmpty ? 0 : wins(xs) / xs.length;

    Widget row(String label, List<Trade> xs, Color color) {
      final n = xs.length;
      final rate = wr(xs);
      final right = n == 0 ? '-' : '${(rate * 100).round()}% WR';
      final fill = n == 0 ? 0.0 : rate.clamp(0.0, 1.0);
      return _disciplineBandRow(
        label,
        right,
        fill,
        color,
        sub: n > 0 ? '$n ${performanceTradeWordPlural(code, n)}' : null,
      );
    }

    return _dashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            LucideIcons.radio,
            txt(
              'Avant / Après news',
              'Before / After news',
              'Antes / Después de noticias',
              'Vor / Nach News',
              'Antes / Depois de notícias',
              '뉴스 전 / 후',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            txt(
              'Winrate des trades taggés “Avant news” / “Après news” (si renseigné dans Ajouter trade).',
              'Win rate for trades tagged “Before news” / “After news” (if set in Add trade).',
              'Win rate de trades etiquetados “Antes de noticias” / “Después de noticias” (si se indicó al añadir).',
              'Gewinnrate für Trades mit Tag “Vor/Nach News” (wenn beim Hinzufügen gesetzt).',
              'Win rate de trades marcados “Antes/Depois de notícias” (se definido ao adicionar).',
              '“뉴스 전/후”로 태그된 트레이드 승률(추가 화면에서 체크한 경우).',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF888888),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          if (!any)
            Text(
              txt(
                'Aucun trade taggé “Avant news” / “Après news” sur la période.',
                'No trades tagged “Before/After news” in this period.',
                'No hay trades etiquetados “Antes/Después de noticias” en este período.',
                'Keine Trades mit Tag “Vor/Nach News” in diesem Zeitraum.',
                'Nenhum trade marcado “Antes/Depois de notícias” neste período.',
                '이 기간에 “뉴스 전/후” 태그 트레이드가 없습니다.',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: const Color(0xFF888888),
                height: 1.4,
              ),
            )
          else ...[
            row(
              txt('Avant news', 'Before news', 'Antes de noticias', 'Vor News', 'Antes de notícias', '뉴스 전'),
              before,
              Colors.white,
            ),
            row(
              txt('Après news', 'After news', 'Después de noticias', 'Nach News', 'Depois de notícias', '뉴스 후'),
              after,
              _kGreen,
            ),
          ],
        ],
      ),
    );
  }
}

