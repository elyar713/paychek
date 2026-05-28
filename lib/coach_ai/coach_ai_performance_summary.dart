import '../trade/trade_models.dart';
import '../trade/trade_plan_analysis.dart';

class CoachPerformanceBucket {
  const CoachPerformanceBucket({
    required this.tradesTotal,
    required this.tradesClosed,
    required this.wins,
    required this.losses,
    required this.breakevenOrFlat,
    required this.winratePercent,
    required this.pnlTotal,
  });

  final int tradesTotal;
  final int tradesClosed;
  final int wins;
  final int losses;
  final int breakevenOrFlat;
  final double winratePercent;
  final double pnlTotal;
}

class CoachPerformanceSplit {
  const CoachPerformanceSplit({
    required this.global,
    required this.fullyRecorded,
    required this.disciplineIncomplete,
    required this.perPillarRecordedOnly,
  });

  final CoachPerformanceBucket global;
  final CoachPerformanceBucket fullyRecorded;
  final CoachPerformanceBucket disciplineIncomplete;
  final Map<String, CoachPerformanceBucket> perPillarRecordedOnly;
}

abstract final class CoachAiPerformanceSummary {
  /// « dit moi ma performance », « quel est mon rendement », etc.
  static bool isGeneralPerformanceQuestion(String question) {
    final q = question.toLowerCase();
    if (CoachAiPerformanceSummary._isSpecificPillar(q)) return false;
    return RegExp(
      r'dit moi.{0,30}(ma |mon )?performance|'
      r'(ma|mon)\s+performance|'
      r'quel.*performance|'
      r'quelle.*performance|'
      r'performance\s+(actuelle|globale|générale|generale)|'
      r'mon\s+(winrate|pnl|rendement)|'
      r'comment.*performance',
    ).hasMatch(q);
  }

  static bool _isSpecificPillar(String q) {
    if (RegExp(r'checklist').hasMatch(q)) return true;
    if (RegExp(r'analyse|analysis|plan d.?analyse').hasMatch(q)) return true;
    if (RegExp(r'strat(é|e)gie|strategy').hasMatch(q)) return true;
    if (RegExp(r'état mental|etat mental|mental state').hasMatch(q)) return true;
    if (RegExp(r'fomo|tilt|peur|sommeil|focus|émotion|emotion').hasMatch(q)) return true;
    if (RegExp(r'non.?respect').hasMatch(q)) return true;
    return false;
  }

  static CoachPerformanceBucket _bucket(Iterable<TradeListItem> trades) {
    var closed = 0;
    var wins = 0;
    var losses = 0;
    var be = 0;
    var pnl = 0.0;
    final list = trades.toList();
    for (final t in list) {
      pnl += t.gainAmount;
      if (!t.isClosed) continue;
      closed++;
      if (t.countsAsClosedWin) wins++;
      if (t.countsAsClosedLoss) losses++;
      if (t.countsAsClosedBreakevenOrFlat) be++;
    }
    final wr = closed > 0 ? (wins * 100 / closed) : 0.0;
    return CoachPerformanceBucket(
      tradesTotal: list.length,
      tradesClosed: closed,
      wins: wins,
      losses: losses,
      breakevenOrFlat: be,
      winratePercent: double.parse(wr.toStringAsFixed(1)),
      pnlTotal: double.parse(pnl.toStringAsFixed(2)),
    );
  }

  static CoachPerformanceSplit build(Iterable<TradeListItem> trades) {
    final all = trades.toList();
    final complete = <TradeListItem>[];
    final incomplete = <TradeListItem>[];
    for (final t in all) {
      if (tradeHasAnyDisciplineMissing(t)) {
        incomplete.add(t);
      } else {
        complete.add(t);
      }
    }

    CoachPerformanceBucket pillarRecorded(
      bool Function(TradeListItem t) isRecorded,
    ) {
      final subset = all.where(isRecorded).toList();
      return _bucket(subset);
    }

    return CoachPerformanceSplit(
      global: _bucket(all),
      fullyRecorded: _bucket(complete),
      disciplineIncomplete: _bucket(incomplete),
      perPillarRecordedOnly: <String, CoachPerformanceBucket>{
        'checklist': pillarRecorded(tradeHasExplicitChecklist),
        'analysisPlan': pillarRecorded(tradeHasExplicitPlanAnalysis),
        'strategy': pillarRecorded(tradeHasExplicitStrategieExecution),
        'mentalState': pillarRecorded(tradeHasExplicitEtat),
      },
    );
  }

  static Map<String, dynamic> splitToJson(CoachPerformanceSplit s) {
    Map<String, dynamic> b(CoachPerformanceBucket x) => <String, dynamic>{
      'tradesTotal': x.tradesTotal,
      'tradesClosed': x.tradesClosed,
      'wins': x.wins,
      'losses': x.losses,
      'breakevenOrFlat': x.breakevenOrFlat,
      'winratePercent': x.winratePercent,
      'pnlTotal': x.pnlTotal,
    };

    return <String, dynamic>{
      'global': b(s.global),
      'fullyRecordedDiscipline': b(s.fullyRecorded),
      'disciplineIncomplete': b(s.disciplineIncomplete),
      'perPillarRecordedOnly': s.perPillarRecordedOnly.map(
        (k, v) => MapEntry(k, b(v)),
      ),
      'note':
          'fullyRecordedDiscipline = les 4 piliers (checklist, analyse, stratégie, état mental) '
          'sont renseignés sur le trade. disciplineIncomplete = au moins un pilier manquant. '
          'perPillarRecordedOnly = performance calculée uniquement sur les trades où CE pilier est enregistré.',
    };
  }
}
