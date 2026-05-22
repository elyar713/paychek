import 'package:flutter/material.dart';

import '../trade/trade_plan_analysis.dart';
import 'performance_discipline_rollups.dart';
import 'performance_locale_copy.dart';
import 'performance_trade_model.dart';

String _txt(
  Locale locale,
  String fr,
  String en,
  String es,
  String de,
  String pt,
  String ko,
) => performancePickLocale(locale, fr, en, es, de, pt, ko);

/// Axe discipline affiché dans Paychek Lens (données **explicites** uniquement).
enum PaychekLensAxisKind { checklist, etat, strategie, plan }

class PaychekLensAxisStat {
  const PaychekLensAxisStat({
    required this.kind,
    required this.label,
    required this.color,
    required this.qualifiedCount,
    required this.totalCount,
    this.avgPct,
    this.winRateOnQualified,
  });

  final PaychekLensAxisKind kind;
  final String label;
  final Color color;
  final int qualifiedCount;
  final int totalCount;

  /// Moyenne % sur les trades qualifiés ; `null` si aucun trade qualifié.
  final double? avgPct;

  /// Winrate sur les trades qualifiés (tous, pas par bande).
  final double? winRateOnQualified;

  bool get isActive => qualifiedCount > 0;

  int get missingCount => (totalCount - qualifiedCount).clamp(0, totalCount);

  double get coverage =>
      totalCount <= 0 ? 0.0 : (qualifiedCount / totalCount).clamp(0.0, 1.0);
}

/// Synthèse structurée pour la carte Paychek Lens (Performance).
class PaychekLensSnapshot {
  const PaychekLensSnapshot({
    required this.tradeCount,
    required this.maxLoss,
    required this.avgDurationMinutes,
    required this.axes,
    this.newsLine,
    this.insight,
  });

  final int tradeCount;
  final double maxLoss;
  final int avgDurationMinutes;
  final List<PaychekLensAxisStat> axes;
  final String? newsLine;
  final String? insight;

  int get qualifiedDisciplineTradeCount {
    var maxQ = 0;
    for (final a in axes) {
      if (a.qualifiedCount > maxQ) maxQ = a.qualifiedCount;
    }
    return maxQ;
  }

  bool get hasAnyDisciplineAxis => axes.any((a) => a.isActive);

  factory PaychekLensSnapshot.empty(Locale locale) {
    return PaychekLensSnapshot(
      tradeCount: 0,
      maxLoss: 0,
      avgDurationMinutes: 0,
      axes: const [],
      insight: _txt(
        locale,
        'Ajoutez des trades au journal pour voir volume, durée et discipline renseignée (checklist, état mental, stratégie, plan).',
        'Add journal trades to see volume, duration, and filled-in discipline (checklist, mental state, strategy, plan).',
        'Añade trades al diario para ver volumen, duración y disciplina rellenada.',
        'Fügen Sie Journal-Trades hinzu für Volumen, Dauer und ausgefüllte Disziplin.',
        'Adicione trades ao diário para ver volume, duração e disciplina preenchida.',
        '일지에 트레이드를 추가하면 거래량·시간·규율을 볼 수 있습니다.',
      ),
    );
  }
}

double? _winRateOnTrades(List<Trade> trades) {
  if (trades.isEmpty) return null;
  final w = trades.where((t) => t.win).length;
  return w / trades.length;
}

/// Trades Performance avec au moins un axe discipline non renseigné (explicite).
int countTradesWithAnyDisciplineMissing(List<Trade> trades) => trades
    .where(
      (t) =>
          !performanceTradeHasChecklist(t) ||
          !performanceTradeHasEtat(t) ||
          !performanceTradeHasStrategieExecution(t) ||
          !performanceTradeHasPlanAnalysis(t),
    )
    .length;

List<Trade> _filter(List<Trade> trades, bool Function(Trade) pred) =>
    trades.where(pred).toList(growable: false);

PaychekLensAxisStat _axisStat({
  required PaychekLensAxisKind kind,
  required String label,
  required Color color,
  required int total,
  required int qualified,
  required double? avgPct,
  required List<Trade> qualifiedTrades,
}) {
  return PaychekLensAxisStat(
    kind: kind,
    label: label,
    color: color,
    qualifiedCount: qualified,
    totalCount: total,
    avgPct: qualified > 0 ? avgPct : null,
    winRateOnQualified: _winRateOnTrades(qualifiedTrades),
  );
}

String? _buildInsight({
  required Locale locale,
  required int total,
  required List<PaychekLensAxisStat> axes,
  required List<Trade> trades,
  required DisciplineRollups roll,
}) {
  if (total == 0) return null;

  final missingAny = axes.where((a) => !a.isActive).length;
  if (!axes.any((a) => a.isActive)) {
    return _txt(
      locale,
      'Aucune discipline renseignée sur cette période. Cochez la checklist, réglez l’état mental, ou complétez stratégie / plan depuis Ajouter trade.',
      'No discipline filled on this period. Check the checklist, set mental state, or complete strategy / plan when adding a trade.',
      'Sin disciplina en este período. Marca checklist, estado mental o estrategia / plan al añadir trade.',
      'Keine Disziplin in diesem Zeitraum. Checkliste, Mentalzustand oder Strategie / Plan beim Trade-Eintrag.',
      'Sem disciplina neste período. Preencha checklist, estado mental ou estratégia / plano ao adicionar trade.',
      '이번 기간 규율 데이터 없음. 트레이드 추가 시 체크리스트·멘탈·전략·계획을 입력하세요.',
    );
  }

  final tradesStrat = _filter(trades, performanceTradeHasStrategieExecution);
  final wrs = winRatesStrategieHighVsForced(tradesStrat);
  if (wrs.$2 >= 2 && wrs.$4 >= 2 && wrs.$1 > wrs.$3 + 0.08) {
    return _txt(
      locale,
      'Stratégie respectée (≥50 %) : ${(wrs.$1 * 100).round()} % WR vs ${(wrs.$3 * 100).round()} % quand elle est forcée — la discipline paie.',
      'Strategy respected (≥50%): ${(wrs.$1 * 100).round()}% WR vs ${(wrs.$3 * 100).round()}% when forced — discipline pays off.',
      'Estrategia respetada (≥50%): ${(wrs.$1 * 100).round()}% WR vs ${(wrs.$3 * 100).round()}% forzada.',
      'Strategie eingehalten (≥50 %): ${(wrs.$1 * 100).round()} % WR vs ${(wrs.$3 * 100).round()} % erzwungen.',
      'Estratégia respeitada (≥50%): ${(wrs.$1 * 100).round()}% WR vs ${(wrs.$3 * 100).round()}% forçada.',
      '전략 준수(≥50%): ${(wrs.$1 * 100).round()}% WR vs 강제 ${(wrs.$3 * 100).round()}%.',
    );
  }

  if (missingAny >= 2) {
    return _txt(
      locale,
      'Les moyennes ci-dessous ne comptent que les trades où vous avez renseigné chaque axe. Horaires & gestion du risque restent dans leurs cartes dédiées.',
      'Averages below only include trades where you filled each axis. Hours & risk management stay in their dedicated cards.',
      'Las medias solo incluyen trades con cada eje rellenado. Horarios y riesgo tienen sus propias tarjetas.',
      'Mittelwerte nur für Trades mit ausgefüllter Achse. Zeiten & Risiko in eigenen Karten.',
      'Médias só nos trades com cada eixo preenchido. Horários e risco têm cartões próprios.',
      '평균은 해당 축을 입력한 트레이드만 포함합니다. 시간·리스크는 별도 카드입니다.',
    );
  }

  final cl = axes.firstWhere((a) => a.kind == PaychekLensAxisKind.checklist);
  final et = axes.firstWhere((a) => a.kind == PaychekLensAxisKind.etat);
  if (cl.isActive &&
      et.isActive &&
      (cl.avgPct ?? 0) >= 65 &&
      (et.avgPct ?? 0) >= 65) {
    return _txt(
      locale,
      'Checklist et état mental solides sur les trades renseignés — bon socle de session.',
      'Solid checklist and mental state on filled trades — a strong session foundation.',
      'Checklist y estado mental sólidos en los trades rellenados.',
      'Solide Checkliste und Mentalzustand bei ausgefüllten Trades.',
      'Checklist e estado mental sólidos nos trades preenchidos.',
      '입력된 트레이드에서 체크리스트·멘탈이 탄탄합니다.',
    );
  }

  return disciplineImpactObservation(trades, locale: locale);
}

PaychekLensSnapshot buildPaychekLensSnapshot(
  List<Trade> trades, {
  required Locale locale,
}) {
  if (trades.isEmpty) return PaychekLensSnapshot.empty(locale);

  final n = trades.length;
  final worst = worstSingleLoss(trades);
  final avgDur = averageDurationMinutes(trades);
  final roll = computeDisciplineRollups(trades);

  final nCl = roll.tradesWithChecklist;
  final nEt = roll.tradesWithEtat;
  final nSt = roll.tradesWithStrategie;
  final nPl = roll.tradesWithPlan;

  final axes = [
    _axisStat(
      kind: PaychekLensAxisKind.checklist,
      label: _txt(
        locale,
        'Checklist',
        'Checklist',
        'Checklist',
        'Checkliste',
        'Checklist',
        '체크리스트',
      ),
      color: kLensChecklist,
      total: n,
      qualified: nCl,
      avgPct: roll.avgChecklist,
      qualifiedTrades: _filter(trades, performanceTradeHasChecklist),
    ),
    _axisStat(
      kind: PaychekLensAxisKind.etat,
      label: _txt(
        locale,
        'État mental',
        'Mental state',
        'Estado mental',
        'Mentalzustand',
        'Estado mental',
        '멘탈',
      ),
      color: kLensEtat,
      total: n,
      qualified: nEt,
      avgPct: roll.avgEtat,
      qualifiedTrades: _filter(trades, performanceTradeHasEtat),
    ),
    _axisStat(
      kind: PaychekLensAxisKind.strategie,
      label: _txt(
        locale,
        'Stratégie',
        'Strategy',
        'Estrategia',
        'Strategie',
        'Estratégia',
        '전략',
      ),
      color: kLensStrategie,
      total: n,
      qualified: nSt,
      avgPct: roll.avgStrategie,
      qualifiedTrades: _filter(trades, performanceTradeHasStrategieExecution),
    ),
    _axisStat(
      kind: PaychekLensAxisKind.plan,
      label: _txt(
        locale,
        'Analyse',
        'Analysis',
        'Análisis',
        'Analyse',
        'Análise',
        '분석',
      ),
      color: kLensPlan,
      total: n,
      qualified: nPl,
      avgPct: roll.avgPlan,
      qualifiedTrades: _filter(trades, performanceTradeHasPlanAnalysis),
    ),
  ];

  String? newsLine;
  final beforeNews = trades.where((t) => t.avantNews).toList();
  final afterNews = trades.where((t) => t.apresNews).toList();
  if (beforeNews.isNotEmpty || afterNews.isNotEmpty) {
    int wrPct(List<Trade> xs) {
      if (xs.isEmpty) return 0;
      return ((_winRateOnTrades(xs) ?? 0) * 100).round();
    }

    final parts = <String>[];
    if (beforeNews.isNotEmpty) {
      parts.add(
        _txt(
          locale,
          'Avant news ${beforeNews.length} (${wrPct(beforeNews)}% WR)',
          'Before news ${beforeNews.length} (${wrPct(beforeNews)}% WR)',
          'Antes noticias ${beforeNews.length} (${wrPct(beforeNews)}% WR)',
          'Vor News ${beforeNews.length} (${wrPct(beforeNews)}% WR)',
          'Antes notícias ${beforeNews.length} (${wrPct(beforeNews)}% WR)',
          '뉴스 전 ${beforeNews.length} (${wrPct(beforeNews)}% WR)',
        ),
      );
    }
    if (afterNews.isNotEmpty) {
      parts.add(
        _txt(
          locale,
          'Après news ${afterNews.length} (${wrPct(afterNews)}% WR)',
          'After news ${afterNews.length} (${wrPct(afterNews)}% WR)',
          'Después noticias ${afterNews.length} (${wrPct(afterNews)}% WR)',
          'Nach News ${afterNews.length} (${wrPct(afterNews)}% WR)',
          'Depois notícias ${afterNews.length} (${wrPct(afterNews)}% WR)',
          '뉴스 후 ${afterNews.length} (${wrPct(afterNews)}% WR)',
        ),
      );
    }
    newsLine = parts.join(' · ');
  }

  final insight = _buildInsight(
    locale: locale,
    total: n,
    axes: axes,
    trades: trades,
    roll: roll,
  );

  return PaychekLensSnapshot(
    tradeCount: n,
    maxLoss: worst,
    avgDurationMinutes: avgDur.round(),
    axes: axes,
    newsLine: newsLine,
    insight: insight,
  );
}

String disciplineImpactObservation(
  List<Trade> trades, {
  required Locale locale,
}) {
  final tradesStrat = trades
      .where(performanceTradeHasStrategieExecution)
      .toList();
  final wrs = winRatesStrategieHighVsForced(tradesStrat);
  final wrHigh = wrs.$1;
  final nHigh = wrs.$2;
  final wrLow = wrs.$3;
  final nLow = wrs.$4;
  final wm = winRatesMindsetPrincipeFeeling(trades);
  final wrP = wm.$1;
  final nP = wm.$2;
  final wrF = wm.$3;
  final nF = wm.$4;

  if (nHigh >= 2 && nLow >= 2 && wrHigh > wrLow + 0.08) {
    return _txt(
      locale,
      'Vous êtes nettement plus rentable lorsque la stratégie est respectée (setups A+) que sur des exécutions plus lâches (hors plan).',
      'You are clearly more profitable when strategy is respected (A+ setups) than on looser executions (off-plan).',
      'Eres claramente más rentable cuando respetas la estrategia (setups A+) que en ejecuciones más laxas (fuera de plan).',
      'Sie sind deutlich profitabler, wenn die Strategie eingehalten wird (A+-Setups), als bei lockereren Umsetzungen (ohne Plan).',
      'Você é claramente mais rentável com a estratégia respeitada (setups A+) do que em execuções soltas (fora do plano).',
      '전략을 지킬 때(A+ 셋업)가 계획 밖 느슨한 실행보다 수익성이 훨씬 높습니다.',
    );
  }
  if (nP >= 2 && nF >= 2 && (wrP - wrF).abs() > 0.1) {
    return wrP > wrF
        ? _txt(
            locale,
            'Le mindset Principe affiche un meilleur winrate que le Feeling sur cette période.',
            'Principle mindset shows a better win rate than Feeling during this period.',
            'El mindset Principio muestra mejor win rate que Feeling en este período.',
            'Das Prinzip-Mindset zeigt in dieser Phase eine bessere Gewinnrate als Feeling.',
            'O mindset Princípio tem win rate melhor que o Feeling neste período.',
            '이번 기간에는 원칙 마인드셋이 느낌보다 승률이 높습니다.',
          )
        : _txt(
            locale,
            'Le mindset Feeling ressort plus performant ici : gardez une exécution consciente.',
            'Feeling mindset performs better here: keep execution conscious.',
            'El mindset Feeling rinde mejor aquí: mantén una ejecución consciente.',
            'Das Feeling-Mindset schneidet hier besser ab: bleiben Sie bei der Ausführung bewusst.',
            'O mindset Feeling vai melhor aqui: mantenha a execução consciente.',
            '여기서는 느낌 마인드셋이 더 낫습니다. 실행을 의식적으로 유지하세요.',
          );
  }
  if (computeDisciplineRollups(trades).hasData) {
    return _txt(
      locale,
      'Surveillez la cohérence entre checklist, stratégie et état mental d’un trade à l’autre.',
      'Watch consistency between checklist, strategy and mental state from one trade to another.',
      'Vigila la coherencia entre checklist, estrategia y estado mental de un trade a otro.',
      'Achten Sie von Trade zu Trade auf Konsistenz zwischen Checkliste, Strategie und Mentalzustand.',
      'Mantenha consistência entre checklist, estratégia e estado mental de um trade ao outro.',
      '트레이드마다 체크리스트·전략·멘탈의 일관성을 점검하세요.',
    );
  }
  return _txt(
    locale,
    'Renseignez la discipline sur vos trades pour obtenir des observations personnalisées.',
    'Fill in discipline fields on your trades to get personalized insights.',
    'Completa la disciplina en tus trades para obtener observaciones personalizadas.',
    'Tragen Sie Disziplin-Felder bei Ihren Trades ein, um persönliche Hinweise zu erhalten.',
    'Preencha a disciplina nos trades para ver observações personalizadas.',
    '트레이드에 규율 항목을 입력하면 맞춤 관찰을 볼 수 있습니다.',
  );
}
