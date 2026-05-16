import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'performance_discipline_rollups.dart';
import 'performance_locale_copy.dart';
import 'performance_trade_model.dart';

TextStyle _lensBase() => GoogleFonts.plusJakartaSans(
      fontSize: 15,
      height: 1.4,
      color: const Color(0xFFCCCCCC),
      fontWeight: FontWeight.w300,
    );

TextStyle _lensBold(Color c) => _lensBase().copyWith(color: c, fontWeight: FontWeight.w700);

String _txt(Locale locale, String fr, String en, String es, String de, String pt, String ko) =>
    performancePickLocale(locale, fr, en, es, de, pt, ko);

String _tradeWord(Locale locale, int n) => performanceTradeWordPlural(locale.languageCode, n);

/// Une puce par axe discipline (pas de regroupement ×2 / ×3).
List<PaychekLensChip> _buildDisciplineChips(DisciplineRollups roll, Locale locale) {
  final items = <(String name, int pct, Color col)>[
    (_txt(locale, 'État', 'State', 'Estado', 'Zustand', 'Estado', '상태'), roll.avgEtat.round(), kLensEtat),
    ('CL', roll.avgChecklist.round(), kLensChecklist),
    (_txt(locale, 'Strat', 'Strat', 'Estrategia', 'Strat.', 'Estrat.', '전략'), roll.avgStrategie.round(), kLensStrategie),
    (_txt(locale, 'Analyse', 'Analysis', 'Análisis', 'Analyse', 'Análise', '분석'), roll.avgPlan.round(), kLensPlan),
  ];
  return [
    for (final it in items)
      PaychekLensChip(
        text: '${it.$1} ${it.$2} %',
        background: const Color(0xFF222222),
        foreground: it.$3,
      ),
  ];
}

class PaychekLensChip {
  const PaychekLensChip({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;
}

class PaychekLensSnapshot {
  const PaychekLensSnapshot({
    required this.narrativeSpans,
    required this.chips,
  });

  final List<InlineSpan> narrativeSpans;
  final List<PaychekLensChip> chips;
}

PaychekLensSnapshot buildPaychekLensSnapshot(List<Trade> trades, {required Locale locale}) {
  if (trades.isEmpty) {
    return PaychekLensSnapshot(
      narrativeSpans: [
        TextSpan(
          text: _txt(
            locale,
            "Ajoutez des trades depuis le journal pour obtenir une synthèse basée sur votre stratégie, vos pertes, le délai de position et vos scores discipline (état mental, checklist, analyse, stratégie).",
            'Add trades from your journal to get a summary based on your strategy, losses, position holding time, and discipline scores (mental state, checklist, analysis, strategy).',
            'Añade trades desde tu diario para obtener un resumen basado en tu estrategia, pérdidas, tiempo en posición y puntuaciones de disciplina (estado mental, checklist, análisis, estrategia).',
            'Fügen Sie Trades aus dem Journal hinzu, um eine Auswertung zu erhalten – Strategie, Verluste, Haltezeit und Disziplinwerte (mental, Checkliste, Analyse, Strategie).',
            'Adicione trades do diário para ver um resumo com base na estratégia, perdas, tempo em posição e disciplina (mental, checklist, análise, estratégia).',
            '일지에서 트레이드를 추가하면 전략·손실·보유 시간·규율 점수(멘탈·체크리스트·분석·전략) 요약을 볼 수 있습니다.',
          ),
          style: _lensBase(),
        ),
      ],
      chips: const [],
    );
  }

  final n = trades.length;
  final worst = worstSingleLoss(trades);
  final avgDur = averageDurationMinutes(trades);
  final roll = computeDisciplineRollups(trades);

  final spans = <InlineSpan>[
    TextSpan(text: _txt(locale, 'Sur cette période : ', 'For this period: ', 'En este período: ', 'In diesem Zeitraum: ', 'Neste período: ', '이번 기간: '), style: _lensBase()),
    TextSpan(text: '$n', style: _lensBold(kLensAccentNum)),
    TextSpan(
      text: n > 1
          ? _txt(locale, ' trades. ', ' trades. ', ' trades. ', ' Trades. ', ' trades. ', ' 트레이드. ')
          : _txt(locale, ' trade. ', ' trade. ', ' trade. ', ' Trade. ', ' trade. ', ' 트레이드. '),
      style: _lensBase(),
    ),
    TextSpan(text: _txt(locale, 'Perte max sur une position : ', 'Max loss on one position: ', 'Pérdida máx. en una posición: ', 'Max. Verlust je Position: ', 'Perda máx. em uma posição: ', '포지션당 최대 손실: '), style: _lensBase()),
    TextSpan(text: worst.toStringAsFixed(0), style: _lensBold(kLensLoss)),
    TextSpan(text: _txt(locale, '. Durée moyenne des positions : ', '. Average position duration: ', '. Duración media de posición: ', '. Mittlere Positionsdauer: ', '. Duração média das posições: ', '. 평균 보유 시간: '), style: _lensBase()),
    TextSpan(text: '${avgDur.round()}', style: _lensBold(kLensDuration)),
    TextSpan(text: _txt(locale, ' min. ', ' min. ', ' min. ', ' Min. ', ' min. ', '분. '), style: _lensBase()),
  ];

  final beforeNews = trades.where((t) => t.avantNews).toList(growable: false);
  final afterNews = trades.where((t) => t.apresNews).toList(growable: false);
  if (beforeNews.isNotEmpty || afterNews.isNotEmpty) {
    int wins(List<Trade> xs) => xs.where((t) => t.win).length;
    int total(List<Trade> xs) => xs.length;
    int wrPct(List<Trade> xs) =>
        xs.isEmpty ? 0 : ((wins(xs) / total(xs)) * 100).round();
    spans.addAll([
      TextSpan(
        text: _txt(
          locale,
          'News : ',
          'News: ',
          'Noticias: ',
          'News: ',
          'Notícias: ',
          '뉴스: ',
        ),
        style: _lensBase(),
      ),
      if (beforeNews.isNotEmpty)
        TextSpan(
          text: _txt(
            locale,
            'Avant ${total(beforeNews)} (${wrPct(beforeNews)}% WR)',
            'Before ${total(beforeNews)} (${wrPct(beforeNews)}% WR)',
            'Antes ${total(beforeNews)} (${wrPct(beforeNews)}% WR)',
            'Vor ${total(beforeNews)} (${wrPct(beforeNews)}% WR)',
            'Antes ${total(beforeNews)} (${wrPct(beforeNews)}% WR)',
            '전 ${total(beforeNews)}개 (${wrPct(beforeNews)}% WR)',
          ),
          style: _lensBold(kLensWinrate),
        ),
      if (beforeNews.isNotEmpty && afterNews.isNotEmpty)
        TextSpan(text: _txt(locale, ' · ', ' · ', ' · ', ' · ', ' · ', ' · '), style: _lensBase()),
      if (afterNews.isNotEmpty)
        TextSpan(
          text: _txt(
            locale,
            'Après ${total(afterNews)} (${wrPct(afterNews)}% WR). ',
            'After ${total(afterNews)} (${wrPct(afterNews)}% WR). ',
            'Después ${total(afterNews)} (${wrPct(afterNews)}% WR). ',
            'Nach ${total(afterNews)} (${wrPct(afterNews)}% WR). ',
            'Depois ${total(afterNews)} (${wrPct(afterNews)}% WR). ',
            '후 ${total(afterNews)}개 (${wrPct(afterNews)}% WR). ',
          ),
          style: _lensBold(kLensWinrate),
        ),
      if (afterNews.isEmpty)
        TextSpan(text: '. ', style: _lensBase()),
    ]);
  }

  if (roll.hasData) {
    final ae = roll.avgEtat.round();
    final ac = roll.avgChecklist.round();
    final ast = roll.avgStrategie.round();
    final ap = roll.avgPlan.round();
    spans.addAll([
      TextSpan(text: _txt(locale, 'Globaux discipline : état mental ', 'Discipline totals: mental state ', 'Totales disciplina: estado mental ', 'Disziplin gesamt: mental ', 'Totais disciplina: estado mental ', '규율 합계: 멘탈 '), style: _lensBase()),
      TextSpan(text: '$ae', style: _lensBold(kLensEtat)),
      TextSpan(text: _txt(locale, ' %, checklist ', '%, checklist ', ' %, checklist ', ' %, Checkliste ', ' %, checklist ', ' %, 체크리스트 '), style: _lensBase()),
      TextSpan(text: '$ac', style: _lensBold(kLensChecklist)),
      TextSpan(text: _txt(locale, ' %, stratégie ', '%, strategy ', ' %, estrategia ', ' %, Strategie ', ' %, estratégia ', ' %, 전략 '), style: _lensBase()),
      TextSpan(text: '$ast', style: _lensBold(kLensStrategie)),
      TextSpan(text: _txt(locale, ' %, analyse / plan ', '%, analysis / plan ', ' %, análisis / plan ', ' %, Analyse / Plan ', ' %, análise / plano ', ' %, 분석/계획 '), style: _lensBase()),
      TextSpan(text: '$ap', style: _lensBold(kLensPlan)),
      TextSpan(text: _txt(locale, ' %. ', '%. ', ' %. ', ' %. ', ' %. ', ' %. '), style: _lensBase()),
    ]);

    final wrs = winRatesStrategieHighVsForced(trades);
    final wrHigh = wrs.$1;
    final nHigh = wrs.$2;
    final wrLow = wrs.$3;
    final nLow = wrs.$4;
    if (nHigh >= 2 && nLow >= 2 && wrHigh > wrLow + 0.05) {
      spans.addAll([
        TextSpan(
          text: _txt(
            locale,
            'Votre winrate est nettement plus élevé lorsque la stratégie est respectée (',
            'Your win rate is clearly higher when strategy is respected (',
            'Tu win rate es claramente más alto cuando se respeta la estrategia (',
            'Ihre Gewinnrate ist deutlich höher, wenn die Strategie eingehalten wird (',
            'Seu win rate é bem maior quando a estratégia é respeitada (',
            '전략을 지킬 때 승률이 훨씬 높습니다 (',
          ),
          style: _lensBase(),
        ),
        TextSpan(text: '${(wrHigh * 100).round()}', style: _lensBold(kLensWinrate)),
        TextSpan(text: _txt(locale, ' % vs ', '% vs ', ' % vs ', ' % vs ', ' % vs ', ' % 대 '), style: _lensBase()),
        TextSpan(text: '${(wrLow * 100).round()}', style: _lensBold(kLensLoss)),
        TextSpan(
          text: _txt(locale, ' % sur les exécutions plus lâches). ', '% on looser executions). ', ' % en ejecuciones más laxas). ', ' % bei lockereren Umsetzungen). ', ' % em execuções mais soltas). ', '느슨한 실행 대비). '),
          style: _lensBase(),
        ),
      ]);
    } else if (roll.avgStrategie < 55 || roll.avgChecklist < 55) {
      spans.add(TextSpan(
        text: _txt(
          locale,
          'Des écarts sur checklist ou stratégie peuvent peser sur la constance des résultats. ',
          'Gaps in checklist or strategy can weigh on result consistency. ',
          'Las brechas en checklist o estrategia pueden afectar la constancia de resultados. ',
          'Lücken bei Checkliste oder Strategie können die Ergebniskonstanz belasten. ',
          'Falhas na checklist ou na estratégia podem afetar a constância dos resultados. ',
          '체크리스트나 전략의 차이가 결과의 일관성에 영향을 줄 수 있습니다. ',
        ),
        style: _lensBase(),
      ));
    } else if (roll.avgEtat >= 65 && roll.avgStrategie >= 65) {
      spans.add(TextSpan(
        text: _txt(
          locale,
          'État mental et stratégie restent alignés avec une discipline soutenue. ',
          'Mental state and strategy stay aligned with sustained discipline. ',
          'Estado mental y estrategia se mantienen alineados con disciplina sostenida. ',
          'Mentalzustand und Strategie bleiben mit solider Disziplin im Einklang. ',
          'Estado mental e estratégia alinhados com disciplina consistente. ',
          '멘탈과 전략이 꾸준한 규율과 잘 맞습니다. ',
        ),
        style: _lensBase(),
      ));
    }
  } else {
    spans.add(TextSpan(
      text: _txt(
        locale,
        'Renseignez la discipline (checklist, stratégie, état, plan) sur vos trades dans le journal pour affiner cette analyse. ',
        'Fill in discipline data (checklist, strategy, state, plan) on your journal trades to refine this analysis. ',
        'Completa datos de disciplina (checklist, estrategia, estado, plan) en tus trades del diario para afinar este análisis. ',
        'Tragen Sie Disziplin (Checkliste, Strategie, Zustand, Plan) bei Ihren Journal-Trades ein, um diese Analyse zu verfeinern. ',
        'Preencha disciplina (checklist, estratégia, estado, plano) nos trades do diário para refinar esta análise. ',
        '일지 트레이드에 규율(체크리스트·전략·상태·계획)을 입력하면 분석이 정교해집니다. ',
      ),
      style: _lensBase(),
    ));
  }

  final chips = <PaychekLensChip>[
    PaychekLensChip(text: '$n ${_tradeWord(locale, n)}', background: Colors.white, foreground: Colors.black),
    PaychekLensChip(
      text: _txt(locale, 'Perte max ${worst.toStringAsFixed(0)}', 'Max loss ${worst.toStringAsFixed(0)}', 'Pérdida máx ${worst.toStringAsFixed(0)}', 'Max. Verlust ${worst.toStringAsFixed(0)}', 'Perda máx ${worst.toStringAsFixed(0)}', '최대 손실 ${worst.toStringAsFixed(0)}'),
      background: Colors.white,
      foreground: kLensLoss,
    ),
    PaychekLensChip(
      text: _txt(locale, 'Durée Ø ${avgDur.round()} min', 'Avg duration ${avgDur.round()} min', 'Duración media ${avgDur.round()} min', 'Ø Dauer ${avgDur.round()} Min', 'Duração Ø ${avgDur.round()} min', '평균 ${avgDur.round()}분'),
      background: Colors.white,
      foreground: kLensDuration,
    ),
  ];
  if (roll.hasData) {
    chips.addAll(_buildDisciplineChips(roll, locale));
  }

  return PaychekLensSnapshot(narrativeSpans: spans, chips: chips);
}

String disciplineImpactObservation(List<Trade> trades, {required Locale locale}) {
  final wrs = winRatesStrategieHighVsForced(trades);
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
