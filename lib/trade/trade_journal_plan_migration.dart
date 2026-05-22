import '../analyse/analyse_report_snapshot.dart';
import 'trade_models.dart';

/// Retire les % plan « fantômes » (repli GOLD / symbole à l’import CSV) et marque les plans choisis à la main.
List<TradeListItem> applyJournalPlanExplicitMigration(
  List<TradeListItem> items,
) {
  var changed = false;
  final out = <TradeListItem>[];
  for (final t in items) {
    final n = normalizeTradePlanExplicitLink(t);
    if (n != t) changed = true;
    out.add(n);
  }
  return changed ? out : items;
}

bool journalPlanMigrationWouldChange(List<TradeListItem> items) {
  for (final t in items) {
    if (normalizeTradePlanExplicitLink(t) != t) return true;
  }
  return false;
}

/// Import CSV historique : stratégie 50 %, pas de mindset explicite, plan auto sans PDF joint.
bool isLikelyAutoCsvPlan(TradeListItem t) {
  if (t.linkedAnalyseReport != null) return false;
  if (t.linkedAnalysePdfBytes != null && t.linkedAnalysePdfBytes!.isNotEmpty) {
    return false;
  }
  if (t.planNonRespectIds.isNotEmpty) return false;
  if (t.planReport == null && t.planPct == 0) return false;
  return t.strategiePct == 50 && !t.mindsetExplicit;
}

bool legacyInferredPlanLinkedExplicit(TradeListItem t) {
  if (t.linkedAnalyseReport != null) return true;
  if (t.linkedAnalysePdfBytes != null && t.linkedAnalysePdfBytes!.isNotEmpty) {
    return true;
  }
  if (t.planNonRespectIds.isNotEmpty) return true;
  return false;
}

TradeListItem normalizeTradePlanExplicitLink(TradeListItem t) {
  final now = DateTime.now().millisecondsSinceEpoch;

  if (t.planLinkedExplicit) {
    return t;
  }

  if (isLikelyAutoCsvPlan(t)) {
    return _rebuild(
      t,
      planPct: 0,
      stripPlanReport: true,
      planNonRespectIds: const {},
      planLinkedExplicit: false,
      syncRev: now,
    );
  }

  if (legacyInferredPlanLinkedExplicit(t)) {
    return _rebuild(t, planLinkedExplicit: true, syncRev: now);
  }

  if (t.planReport != null && t.planPct > 0) {
    return _rebuild(t, planLinkedExplicit: true, syncRev: now);
  }

  if (t.planReport != null || t.planPct > 0) {
    return _rebuild(
      t,
      planPct: 0,
      stripPlanReport: true,
      planLinkedExplicit: false,
      syncRev: now,
    );
  }

  return t;
}

TradeListItem _rebuild(
  TradeListItem t, {
  double? planPct,
  AnalyseReportSnapshot? planReport,
  bool stripPlanReport = false,
  Set<String>? planNonRespectIds,
  bool? planLinkedExplicit,
  int? syncRev,
}) {
  return TradeListItem(
    id: t.id,
    pair: t.pair,
    side: t.side,
    amountLabel: t.amountLabel,
    gainAmount: t.gainAmount,
    commissionAmount: t.commissionAmount,
    dateLine: t.dateLine,
    entreeAt: t.entreeAt,
    sortieAt: t.sortieAt,
    breakeven: t.breakeven,
    avantNews: t.avantNews,
    apresNews: t.apresNews,
    quantiteLabel: t.quantiteLabel,
    screenshotPath: t.screenshotPath,
    screenshotBytes: t.screenshotBytes,
    prixEntreeLabel: t.prixEntreeLabel,
    prixSortieLabel: t.prixSortieLabel,
    checklistPct: t.checklistPct,
    planPct: planPct ?? t.planPct,
    strategiePct: t.strategiePct,
    etatPct: t.etatPct,
    mindset: t.mindset,
    mindsetExplicit: t.mindsetExplicit,
    planLinkedExplicit: planLinkedExplicit ?? t.planLinkedExplicit,
    strategieLinkedExplicit: t.strategieLinkedExplicit,
    checklistLinkedExplicit: t.checklistLinkedExplicit,
    etatLinkedExplicit: t.etatLinkedExplicit,
    strategieTitle: t.strategieTitle,
    planReport: stripPlanReport ? null : (planReport ?? t.planReport),
    linkedAnalyseReport: t.linkedAnalyseReport,
    linkedAnalysePdfBytes: t.linkedAnalysePdfBytes,
    linkedAnalysePdfFileName: t.linkedAnalysePdfFileName,
    strategieNonRespectIds: t.strategieNonRespectIds,
    planNonRespectIds: planNonRespectIds ?? t.planNonRespectIds,
    checklistNonRespectIds: t.checklistNonRespectIds,
    etatNonRespectIds: t.etatNonRespectIds,
    isProfit: t.isProfit,
    assetClass: t.assetClass,
    performanceLite: t.performanceLite,
    portfolioId: t.portfolioId,
    psychTags: t.psychTags,
    userNote: t.userNote,
    syncRev: syncRev ?? t.syncRev,
  );
}
