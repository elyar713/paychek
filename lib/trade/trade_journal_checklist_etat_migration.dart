import '../etat_mental/mental_state_controller.dart';
import 'trade_discipline_day_snapshot.dart';
import 'trade_models.dart';
import 'trade_plan_analysis.dart';

List<TradeListItem> applyJournalChecklistEtatExplicitMigration(
  List<TradeListItem> items,
) {
  var changed = false;
  final out = <TradeListItem>[];
  for (final t in items) {
    final n = normalizeTradeChecklistEtatExplicit(t);
    if (n != t) changed = true;
    out.add(n);
  }
  return changed ? out : items;
}

bool journalChecklistEtatMigrationWouldChange(List<TradeListItem> items) {
  for (final t in items) {
    if (normalizeTradeChecklistEtatExplicit(t) != t) return true;
  }
  return false;
}

bool isLikelyAutoCsvChecklist(TradeListItem t) {
  if (tradeHasChecklistRetroOnItem(t)) return false;
  if (!t.mindsetExplicit && !t.strategieLinkedExplicit && !t.planLinkedExplicit) {
    return t.checklistPct > 0;
  }
  return false;
}

bool isLikelyAutoCsvEtat(TradeListItem t) {
  if (tradeHasEtatRetroOnItem(t)) return false;
  if (!t.mindsetExplicit && !t.strategieLinkedExplicit && !t.planLinkedExplicit) {
    return t.etatPct > 0;
  }
  return false;
}

int _checklistPctForEntryDay(DateTime entryAt) {
  final c = tradeDisciplineChecklistResolver;
  if (c == null || !c.hasChecklistCheckedOnDay(tradeEntryDateOnly(entryAt))) {
    return 0;
  }
  return c.completionPercentOnDay(tradeEntryDateOnly(entryAt));
}

int _etatPctForEntryDay(DateTime entryAt) {
  final day = tradeEntryDateOnly(entryAt);
  final score = MentalStateController.instance.overallScoreForCalendarDay(day);
  if (score == null) return 0;
  return score.round().clamp(0, 100);
}

TradeListItem normalizeTradeChecklistEtatExplicit(TradeListItem t) {
  final now = DateTime.now().millisecondsSinceEpoch;
  var out = t;

  final clExplicit = tradeHasExplicitChecklist(out);
  final etExplicit = tradeHasExplicitEtat(out);

  if (isLikelyAutoCsvChecklist(out) ||
      out.checklistLinkedExplicit != clExplicit ||
      (out.checklistPct > 0 && !clExplicit)) {
    out = _rebuild(
      out,
      checklistPct: clExplicit
          ? (tradeHasChecklistRetroOnItem(out)
              ? out.checklistPct
              : _checklistPctForEntryDay(out.entreeAt).toDouble())
          : 0,
      checklistNonRespectIds:
          clExplicit ? out.checklistNonRespectIds : const <String>{},
      checklistLinkedExplicit: clExplicit,
      syncRev: now,
    );
  }

  if (isLikelyAutoCsvEtat(out) ||
      out.etatLinkedExplicit != etExplicit ||
      (out.etatPct > 0 && !etExplicit)) {
    out = _rebuild(
      out,
      etatPct: etExplicit
          ? (tradeHasEtatRetroOnItem(out)
              ? out.etatPct
              : _etatPctForEntryDay(out.entreeAt).toDouble())
          : 0,
      etatNonRespectIds: etExplicit ? out.etatNonRespectIds : const <String>{},
      etatLinkedExplicit: etExplicit,
      syncRev: now,
    );
  }

  return out;
}

/// Réaligne le journal après hydratation checklist (calendrier disponible).
void reconcileJournalChecklistEtatFromCalendar(
  List<TradeListItem> items, {
  void Function(List<TradeListItem> next)? onChanged,
}) {
  final next = applyJournalChecklistEtatExplicitMigration(items);
  if (!identical(next, items) && onChanged != null) {
    onChanged(next);
  }
}

TradeListItem _rebuild(
  TradeListItem t, {
  double? checklistPct,
  double? etatPct,
  Set<String>? checklistNonRespectIds,
  Set<String>? etatNonRespectIds,
  bool? checklistLinkedExplicit,
  bool? etatLinkedExplicit,
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
    checklistPct: checklistPct ?? t.checklistPct,
    planPct: t.planPct,
    strategiePct: t.strategiePct,
    etatPct: etatPct ?? t.etatPct,
    mindset: t.mindset,
    mindsetExplicit: t.mindsetExplicit,
    planLinkedExplicit: t.planLinkedExplicit,
    strategieLinkedExplicit: t.strategieLinkedExplicit,
    checklistLinkedExplicit:
        checklistLinkedExplicit ?? t.checklistLinkedExplicit,
    etatLinkedExplicit: etatLinkedExplicit ?? t.etatLinkedExplicit,
    strategieTitle: t.strategieTitle,
    planReport: t.planReport,
    linkedAnalyseReport: t.linkedAnalyseReport,
    linkedAnalysePdfBytes: t.linkedAnalysePdfBytes,
    linkedAnalysePdfFileName: t.linkedAnalysePdfFileName,
    strategieNonRespectIds: t.strategieNonRespectIds,
    planNonRespectIds: t.planNonRespectIds,
    checklistNonRespectIds:
        checklistNonRespectIds ?? t.checklistNonRespectIds,
    etatNonRespectIds: etatNonRespectIds ?? t.etatNonRespectIds,
    isProfit: t.isProfit,
    assetClass: t.assetClass,
    performanceLite: t.performanceLite,
    portfolioId: t.portfolioId,
    psychTags: t.psychTags,
    userNote: t.userNote,
    syncRev: syncRev ?? t.syncRev,
  );
}
