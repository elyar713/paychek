import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../checklist/checklist_page_controller.dart';
import '../etat_mental/mental_state_controller.dart';
import '../l10n/app_localizations.dart';
import '../performance/performance_trade_model.dart';
import 'trade_discipline_day_snapshot.dart';
import 'trade_models.dart';
import 'trade_tokens.dart';

/// Checklist du shell (dashboard) pour valider le jour d'entrée d'un trade.
ChecklistPageController? tradeDisciplineChecklistResolver;

/// Trade avec plan Mon Analyse **explicitement** lié (choix utilisateur ou PDF joint).
bool tradeHasExplicitPlanAnalysis(TradeListItem t) =>
    t.linkedAnalyseReport != null ||
    (t.planLinkedExplicit && (t.planReport != null || t.planPct > 0));

double? tradeEffectivePlanPct(TradeListItem t) =>
    tradeHasExplicitPlanAnalysis(t) ? t.planPct : null;

bool performanceTradeHasPlanAnalysis(Trade t) => t.planPct != null;

/// Trade avec exécution stratégique renseignée (slider / setup à l'enregistrement).
bool tradeHasExplicitStrategieExecution(TradeListItem t) =>
    t.strategieLinkedExplicit;

double? tradeEffectiveStrategiePct(TradeListItem t) =>
    t.strategieLinkedExplicit ? t.strategiePct : null;

bool performanceTradeHasStrategieExecution(Trade t) => t.strategiePct != null;

/// Rétroaction discipline sur le trade (cases « non respecté »).
bool tradeHasChecklistRetroOnItem(TradeListItem t) =>
    t.checklistNonRespectIds.isNotEmpty;

bool tradeHasEtatRetroOnItem(TradeListItem t) => t.etatNonRespectIds.isNotEmpty;

/// Jour d'entrée : au moins une case checklist cochée (calendrier / live).
bool entryDayHasChecklistActivity(DateTime entryAt) {
  final day = tradeEntryDateOnly(entryAt);
  final c = tradeDisciplineChecklistResolver;
  if (c != null) return c.hasChecklistCheckedOnDay(day);
  return false;
}

/// Jour d'entrée : état mental saisi (calendrier EM).
bool entryDayHasEtatActivity(DateTime entryAt) =>
    MentalStateController.instance.overallScoreForCalendarDay(
      tradeEntryDateOnly(entryAt),
    ) !=
    null;

/// Checklist comptée en Performance si calendrier coché ce jour ou rétro sur le trade.
bool tradeHasExplicitChecklist(TradeListItem t) =>
    tradeHasChecklistRetroOnItem(t) || entryDayHasChecklistActivity(t.entreeAt);

double? tradeEffectiveChecklistPct(TradeListItem t) =>
    tradeHasExplicitChecklist(t) ? t.checklistPct : null;

bool performanceTradeHasChecklist(Trade t) => t.checklistPct != null;

/// État mental compté si jour d'entrée réglé sur EM ou rétro sur le trade.
bool tradeHasExplicitEtat(TradeListItem t) =>
    tradeHasEtatRetroOnItem(t) || entryDayHasEtatActivity(t.entreeAt);

double? tradeEffectiveEtatPct(TradeListItem t) =>
    tradeHasExplicitEtat(t) ? t.etatPct : null;

bool performanceTradeHasEtat(Trade t) => t.etatPct != null;

int countTradesMissingPlanAnalysis(Iterable<TradeListItem> items) =>
    items.where((t) => !tradeHasExplicitPlanAnalysis(t)).length;

int countTradesMissingStrategieExecution(Iterable<TradeListItem> items) =>
    items.where((t) => !tradeHasExplicitStrategieExecution(t)).length;

int countTradesMissingChecklist(Iterable<TradeListItem> items) =>
    items.where((t) => !tradeHasExplicitChecklist(t)).length;

int countTradesMissingEtat(Iterable<TradeListItem> items) =>
    items.where((t) => !tradeHasExplicitEtat(t)).length;

/// Au moins un axe discipline (checklist, état, stratégie, plan) non renseigné explicitement.
bool tradeHasAnyDisciplineMissing(TradeListItem t) =>
    !tradeHasExplicitChecklist(t) ||
    !tradeHasExplicitEtat(t) ||
    !tradeHasExplicitStrategieExecution(t) ||
    !tradeHasExplicitPlanAnalysis(t);

int countJournalTradesWithAnyDisciplineMissing(Iterable<TradeListItem> items) =>
    items.where(tradeHasAnyDisciplineMissing).length;

int countPerformanceTradesMissingPlanAnalysis(Iterable<Trade> trades) =>
    trades.where((t) => !performanceTradeHasPlanAnalysis(t)).length;

int countPerformanceTradesMissingStrategieExecution(Iterable<Trade> trades) =>
    trades.where((t) => !performanceTradeHasStrategieExecution(t)).length;

int countPerformanceTradesMissingChecklist(Iterable<Trade> trades) =>
    trades.where((t) => !performanceTradeHasChecklist(t)).length;

int countPerformanceTradesMissingEtat(Iterable<Trade> trades) =>
    trades.where((t) => !performanceTradeHasEtat(t)).length;

double? averageExplicitPlanPct(Iterable<TradeListItem> items) {
  final xs = items.map(tradeEffectivePlanPct).whereType<double>().toList();
  if (xs.isEmpty) return null;
  return xs.reduce((a, b) => a + b) / xs.length;
}

double? averageExplicitStrategiePct(Iterable<TradeListItem> items) {
  final xs =
      items.map(tradeEffectiveStrategiePct).whereType<double>().toList();
  if (xs.isEmpty) return null;
  return xs.reduce((a, b) => a + b) / xs.length;
}

double? averageExplicitChecklistPct(Iterable<TradeListItem> items) {
  final xs =
      items.map(tradeEffectiveChecklistPct).whereType<double>().toList();
  if (xs.isEmpty) return null;
  return xs.reduce((a, b) => a + b) / xs.length;
}

double? averageExplicitEtatPct(Iterable<TradeListItem> items) {
  final xs = items.map(tradeEffectiveEtatPct).whereType<double>().toList();
  if (xs.isEmpty) return null;
  return xs.reduce((a, b) => a + b) / xs.length;
}

Widget _disciplineMissingNotice(
  BuildContext context, {
  required String text,
  bool compact = false,
}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: compact ? 10 : 14),
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 12 : 14,
      vertical: compact ? 10 : 12,
    ),
    decoration: BoxDecoration(
      color: const Color(0x1AF59E0B),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0x44F59E0B)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: compact ? 18 : 20,
          color: const Color(0xFFFBBF24),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: compact ? 11 : 12,
              height: 1.45,
              color:
                  compact ? TradeTokens.textSecondary : const Color(0xFFE5E7EB),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildPlanAnalysisMissingNotice(
  BuildContext context, {
  required int missingCount,
  required int totalCount,
  bool compact = false,
}) {
  if (missingCount <= 0 || totalCount <= 0) return const SizedBox.shrink();
  final l = AppLocalizations.of(context)!;
  final allMissing = missingCount >= totalCount;
  final text = allMissing
      ? l.tradePlanAnalysisMissingAll
      : l.tradePlanAnalysisMissingPartial(missingCount, totalCount);
  return _disciplineMissingNotice(context, text: text, compact: compact);
}

Widget buildStrategieExecutionMissingNotice(
  BuildContext context, {
  required int missingCount,
  required int totalCount,
  bool compact = false,
}) {
  if (missingCount <= 0 || totalCount <= 0) return const SizedBox.shrink();
  final l = AppLocalizations.of(context)!;
  final allMissing = missingCount >= totalCount;
  final text = allMissing
      ? l.tradeStrategieExecutionMissingAll
      : l.tradeStrategieExecutionMissingPartial(missingCount, totalCount);
  return _disciplineMissingNotice(context, text: text, compact: compact);
}

Widget buildChecklistMissingNotice(
  BuildContext context, {
  required int missingCount,
  required int totalCount,
  bool compact = false,
}) {
  if (missingCount <= 0 || totalCount <= 0) return const SizedBox.shrink();
  final l = AppLocalizations.of(context)!;
  final allMissing = missingCount >= totalCount;
  final text = allMissing
      ? l.tradeChecklistMissingAll
      : l.tradeChecklistMissingPartial(missingCount, totalCount);
  return _disciplineMissingNotice(context, text: text, compact: compact);
}

Widget buildEtatMissingNotice(
  BuildContext context, {
  required int missingCount,
  required int totalCount,
  bool compact = false,
}) {
  if (missingCount <= 0 || totalCount <= 0) return const SizedBox.shrink();
  final l = AppLocalizations.of(context)!;
  final allMissing = missingCount >= totalCount;
  final text = allMissing
      ? l.tradeEtatMissingAll
      : l.tradeEtatMissingPartial(missingCount, totalCount);
  return _disciplineMissingNotice(context, text: text, compact: compact);
}
