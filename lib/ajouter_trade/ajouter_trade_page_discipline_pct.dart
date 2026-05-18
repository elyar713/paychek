// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

/// Sources des % discipline enregistrés sur le trade → lus par Performance.
///
/// - Checklist : anneau du jour d'entrée
/// - État mental : anneau du jour d'entrée (ou score courant)
/// - Plan d'analyse : confiance globale du rapport sélectionné
/// - Stratégie : curseur « stratégie respectée » uniquement
extension _AjouterTradeDisciplinePct on _AjouterTradePageState {
  DateTime get _tradeEntryDateOnly => DateTime(
        _entreeDateTime.year,
        _entreeDateTime.month,
        _entreeDateTime.day,
      );

  int get _checklistRingPercent => widget.checklistController
      .completionPercentOnDay(_tradeEntryDateOnly);

  double get _mentalRingScore {
    final c = MentalStateController.instance;
    final historical = c.overallScoreForCalendarDay(_tradeEntryDateOnly);
    return historical ?? c.overallScore;
  }

  int get _planConfidencePercent => resolvePlanGlobalConfidencePercent(
        _planAnalyseSelectedReport,
        _planAnalyseStoredReports,
      );

  /// Valeurs persistées au journal (Performance).
  ({
    double checklistPct,
    double planPct,
    double strategiePct,
    double etatPct,
  }) disciplinePctForSave({
    List<AnalyseReportSnapshot>? storedReports,
  }) {
    final stored = storedReports ?? _planAnalyseStoredReports;
    final planPct = resolvePlanGlobalConfidencePercent(
      _planAnalyseSelectedReport,
      stored,
    );
    return (
      checklistPct: _checklistRingPercent.toDouble(),
      planPct: planPct.toDouble(),
      strategiePct: _strategieRespectPct,
      etatPct: _mentalRingScore,
    );
  }

  /// Menus rétroaction : anneaux / confiance en direct ; stratégie = curseur.
  double get _checklistPctForFeedback => _checklistRingPercent.toDouble();

  double get _planPctForFeedback => _planConfidencePercent.toDouble();

  double get _etatPctForFeedback => _mentalRingScore;
}
