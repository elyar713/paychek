import 'package:flutter/foundation.dart';

import '../analyse/analyse_default_demo_seed.dart';
import '../analyse/analyse_report_snapshot.dart';
import '../analyse/analyse_reports_storage.dart';
import '../checklist/checklist_page_controller.dart';
import '../etat_mental/mental_state_controller.dart';
import 'trade_models.dart';
import 'trade_plan_analysis.dart';

/// % discipline dérivés des anneaux / scores du **jour d’entrée** du trade.
@immutable
class TradeDisciplineDaySnapshot {
  const TradeDisciplineDaySnapshot({
    required this.checklistPct,
    required this.etatPct,
    this.planPct,
    this.planReport,
  });

  final double checklistPct;
  final double etatPct;

  /// `null` si aucun rapport Mon Analyse n’est lié au trade.
  final double? planPct;
  final AnalyseReportSnapshot? planReport;
}

DateTime tradeEntryDateOnly(DateTime entryAt) => DateTime(
      entryAt.year,
      entryAt.month,
      entryAt.day,
    );

/// Rapport Mon Analyse le plus pertinent pour un symbole importé.
AnalyseReportSnapshot? planReportForImportedSymbol(
  String pair,
  List<AnalyseReportSnapshot> stored,
) {
  if (stored.isEmpty) return null;
  final p = pair.toUpperCase().replaceAll(RegExp(r'\s+'), '');
  for (final r in stored) {
    final a = r.actif.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (a.isEmpty) continue;
    if (p == a || p.contains(a) || a.contains(p)) return r;
  }
  return pickStoredAnalyseReportDefaultPreferGold(stored);
}

/// Aligné sur la sauvegarde manuelle Ajouter trade (anneaux + confiance analyse).
TradeDisciplineDaySnapshot resolveTradeDisciplineForEntryDay({
  required DateTime entryAt,
  required ChecklistPageController checklist,
  List<AnalyseReportSnapshot> storedReports = const [],
  AnalyseReportSnapshot? planReport,
}) {
  final day = tradeEntryDateOnly(entryAt);
  final checklistRaw = checklist.completionPercentForCalendarDay(
        day,
        tradeCount: 1,
      ) ??
      checklist.completionPercentOnDay(day);
  final checklistPct = checklistRaw.toDouble().clamp(0.0, 100.0);

  final mental = MentalStateController.instance;
  final historical = mental.overallScoreForCalendarDay(day);
  final etatPct = (historical ?? mental.overallScore).toDouble().clamp(0.0, 100.0);

  final planSel = planReport;
  final double? planPct = planSel == null
      ? null
      : resolvePlanGlobalConfidencePercent(
          planSel,
          storedReports,
        ).toDouble().clamp(0.0, 100.0);

  final freshPlan = planSel == null
      ? null
      : (findStoredAnalyseReportMatch(planSel, storedReports) ?? planSel);

  return TradeDisciplineDaySnapshot(
    checklistPct: checklistPct,
    etatPct: etatPct,
    planPct: planPct,
    planReport: freshPlan,
  );
}

/// % discipline affichés (PDF, cartes) — anneaux jour + confiance analyse ; stratégie = journal.
class TradeDisciplineDisplay {
  const TradeDisciplineDisplay({
    this.checklistPct,
    this.planPct,
    this.etatPct,
    this.strategiePct,
    this.planReport,
  });

  final double? checklistPct;
  final double? planPct;
  final double? etatPct;
  final double? strategiePct;
  final AnalyseReportSnapshot? planReport;
}

TradeDisciplineDisplay resolveTradeDisciplineDisplay({
  required TradeListItem trade,
  required ChecklistPageController checklist,
  List<AnalyseReportSnapshot> storedReports = const [],
}) {
  final explicitPlan = trade.linkedAnalyseReport ??
      (trade.planLinkedExplicit ? trade.planReport : null);
  final snap = resolveTradeDisciplineForEntryDay(
    entryAt: trade.entreeAt,
    checklist: checklist,
    storedReports: storedReports,
    planReport: explicitPlan,
  );
  return TradeDisciplineDisplay(
    checklistPct: tradeHasExplicitChecklist(trade) ? trade.checklistPct : null,
    planPct: snap.planPct,
    etatPct: tradeHasExplicitEtat(trade) ? trade.etatPct : null,
    strategiePct: trade.strategieLinkedExplicit ? trade.strategiePct : null,
    planReport: snap.planReport ?? explicitPlan,
  );
}

/// Moyennes discipline pour exports PDF (semaine / mois).
({
  double checklist,
  double plan,
  double strategie,
  double etat,
}) averageDisciplineDisplayForTrades(
  List<TradeListItem> trades,
  ChecklistPageController checklist,
  List<AnalyseReportSnapshot> storedReports,
) {
  double avg(Iterable<double> xs) =>
      xs.isEmpty ? 0.0 : xs.reduce((a, b) => a + b) / xs.length;
  if (trades.isEmpty) {
    return (checklist: 0.0, plan: 0.0, strategie: 0.0, etat: 0.0);
  }
  final displays = [
    for (final t in trades)
      resolveTradeDisciplineDisplay(
        trade: t,
        checklist: checklist,
        storedReports: storedReports,
      ),
  ];
  return (
    checklist: avg(displays.map((d) => d.checklistPct).whereType<double>()),
    plan: avg(displays.map((d) => d.planPct).whereType<double>()),
    strategie: avg(displays.map((d) => d.strategiePct).whereType<double>()),
    etat: avg(displays.map((d) => d.etatPct).whereType<double>()),
  );
}

/// Checklist hydratée si besoin (ex. export depuis le calendrier).
Future<ChecklistPageController> checklistControllerReadyForPdfExport(
  ChecklistPageController? existing,
) async {
  if (existing != null) return existing;
  final c = ChecklistPageController();
  await c.hydrateFromStorage();
  return c;
}

Future<List<AnalyseReportSnapshot>> loadAnalyseReportsForPdfExport() =>
    AnalyseReportsStorage.loadAll();
