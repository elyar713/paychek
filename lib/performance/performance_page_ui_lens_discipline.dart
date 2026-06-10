part of 'performance_page.dart';

extension _PerformancePageUiLensDisciplineWarn on _PerformancePageState {
  Widget _strategieWarningStatChip({
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PerformanceTokens.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kRed,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: PerformanceTokens.labelMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _strategieWarningStatChips(
    PaychekStrategieWarning warning,
    String Function(String, String, String, String, String, String) txt,
  ) {
    final chips = <Widget>[];
    final tc = warning.tradeCount ?? 0;
    final dj = warning.distinctDayCount ?? 0;
    final mj = warning.distinctMonthCount ?? 0;
    if (tc > 0) {
      chips.add(
        _strategieWarningStatChip(
          value: '$tc',
          label: txt('trades', 'trades', 'trades', 'Trades', 'trades', '거래'),
        ),
      );
    }
    if (dj > 0) {
      chips.add(
        _strategieWarningStatChip(
          value: '$dj',
          label: txt('jours', 'days', 'días', 'Tage', 'dias', '일'),
        ),
      );
    }
    if (mj > 0) {
      chips.add(
        _strategieWarningStatChip(
          value: '$mj',
          label: txt('mois', 'months', 'meses', 'Monate', 'meses', '개월'),
        ),
      );
    }
    return chips;
  }

  Widget _strategieWarningTile(PaychekStrategieWarning warning) {
    final code = Localizations.localeOf(context).languageCode;
    String txt(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) =>
        perf6(code, fr, en, es, de, pt, ko);
    final statChips = _strategieWarningStatChips(warning, txt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kRed.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.alertTriangle,
                size: 16,
                color: _kRed.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  warning.message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.45,
                    color: PerformanceTokens.textBright,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (statChips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: statChips),
          ],
        ],
      ),
    );
  }

  Widget _cardStrategieWarnings(List<PaychekStrategieWarning> strategieWarnings) {
    if (strategieWarnings.isEmpty) return const SizedBox.shrink();
    final code = Localizations.localeOf(context).languageCode;
    String txt(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);

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
              color: PerformanceTokens.labelDim,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            txt(
              'Chaque ligne résume un écart ; les chiffres indiquent combien de trades, sur combien de jours et de mois distincts.',
              'Each row summarizes one breach; figures show how many trades, on how many distinct days and months.',
              'Cada fila resume un incumplimiento; las cifras indican trades, días y meses distintos.',
              'Jede Zeile fasst einen Verstoß zusammen; Zahlen = Trades, Tage und Monate.',
              'Cada linha resume um desvio; números = trades, dias e meses distintos.',
              '각 항목은 위반 요약이며, 숫자는 거래·일·월 수입니다.',
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              height: 1.35,
              color: PerformanceTokens.labelMuted,
            ),
          ),
          const SizedBox(height: 14),
          for (final w in strategieWarnings) _strategieWarningTile(w),
        ],
      ),
    );
  }

  /// Carte colonne gauche : liste des trades incomplets, tap → Ajouter trade.
}
