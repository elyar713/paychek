import 'dart:ui' show Locale;

import '../ajouter_trade/ajouter_trade_plan_analyse_feedback_items.dart';
import '../checklist/checklist_models.dart'
    show ChecklistSectionData, defaultNouveauTradeSections;
import '../etat_mental/mental_state_controller.dart';
import '../l10n/app_localizations.dart';
import '../strategie/strategie_feedback_reference.dart';
import '../strategie/widgets/strategie_setup_cards_content.dart';
import 'performance_custom_lens_model.dart';
import 'performance_custom_lens_plan.dart';
import 'performance_trade_model.dart';

/// Catalogue complet des éléments sélectionnables (pas seulement ceux vus dans les trades).
List<PerformanceCustomLensElementOption> performanceCustomLensMasterCatalog({
  required PerformanceCustomLensDimension dimension,
  required List<Trade> trades,
  required AppLocalizations l,
  required Locale locale,
  List<ChecklistSectionData> checklistSections = const [],
  PerformanceCustomLensPlanIndex? planIndex,
}) {
  final checklistSource = checklistSections.isEmpty
      ? defaultNouveauTradeSections()
      : checklistSections;
  final counts = <String, int>{};
  for (final t in trades) {
    if (t.performanceLite) continue;
    void bump(String id) => counts[id] = (counts[id] ?? 0) + 1;
    switch (dimension) {
      case PerformanceCustomLensDimension.etat:
        for (final id in t.etatNonRespectIds ?? const <String>{}) {
          bump(id);
        }
        for (final tag in t.psychTags) {
          bump('psych:$tag');
        }
      case PerformanceCustomLensDimension.checklist:
        for (final id in t.checklistNonRespectIds ?? const <String>{}) {
          bump(id);
        }
      case PerformanceCustomLensDimension.plan:
        for (final id in t.planNonRespectIds ?? const <String>{}) {
          bump(id);
        }
      case PerformanceCustomLensDimension.strategie:
        for (final id in t.strategieNonRespectIds ?? const <String>{}) {
          bump(id);
        }
    }
  }

  final ids = <String>{};

  switch (dimension) {
    case PerformanceCustomLensDimension.etat:
      final c = MentalStateController.instance;
      ids.add('etat_sleep');
      for (final m in c.moment) {
        ids.add('moment:${m.id}');
      }
      for (final e in c.emotions) {
        ids.add('emotion:${e.id}');
      }
      for (final f in c.factors) {
        ids.add('factor:${f.id}');
      }
      const psychKnown = ['FOMO', 'TILT', 'REVENGE', 'HESITATION'];
      for (final tag in psychKnown) {
        ids.add('psych:$tag');
      }
    case PerformanceCustomLensDimension.checklist:
      for (final s in checklistSource) {
        for (final it in s.items) {
          ids.add('${s.id}:${it.id}');
        }
      }
    case PerformanceCustomLensDimension.plan:
      if (planIndex != null) {
        ids.addAll(planIndex.ids);
      } else {
        for (final t in trades) {
          final report = t.planReport;
          if (report == null) continue;
          for (final e in planAnalyseFeedbackEntriesFor(report, l)) {
            if (e is PlanAnalyseFeedbackRow) ids.add(e.id);
          }
        }
      }
    case PerformanceCustomLensDimension.strategie:
      final regles = StrategieFeedbackReference.mesReglesDor(locale);
      for (var i = 0; i < regles.length; i++) {
        ids.add('mes_regles_$i');
      }
      final gestion = StrategieFeedbackReference.gestionRisque(locale);
      for (var i = 0; i < gestion.length; i++) {
        ids.add('gestion_risque_$i');
      }
      final horaires = StrategieFeedbackReference.horairesSessions(locale);
      for (var i = 0; i < horaires.length; i++) {
        ids.add('horaire_$i');
      }
      ids.addAll(const [
        'setup_timeframes',
        'setup_indicateurs',
        'setup_pattern',
        'setup_signal',
      ]);
      final titles = <String>{};
      for (final t in trades) {
        final title = t.strategieTitle?.trim();
        if (title != null && title.isNotEmpty) titles.add(title);
      }
      for (final title in titles) {
        final data = strategieSetupCardDataPourTitre(title);
        if (data == null) continue;
        for (var i = 0; i < data.ruleBlocks.length; i++) {
          ids.add('setup_rule_$i');
        }
      }
  }

  ids.addAll(counts.keys);

  final sorted = ids.toList()
    ..sort((a, b) {
      final ca = counts[a] ?? 0;
      final cb = counts[b] ?? 0;
      if (ca != cb) return cb.compareTo(ca);
      return a.compareTo(b);
    });

  return [
    for (final id in sorted)
      PerformanceCustomLensElementOption(
        id: id,
        label: id,
        tradeHits: counts[id] ?? 0,
      ),
  ];
}
