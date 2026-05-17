import 'dart:ui' show Locale;

import '../ajouter_trade/ajouter_trade_page_non_respect_labels.dart';
import '../checklist/checklist_models.dart';
import '../checklist/checklist_prompts.dart';
import '../etat_mental/mental_state_controller.dart';
import '../l10n/app_localizations.dart';
import '../l10n/checklist_localizations.dart';
import 'performance_custom_lens_model.dart';
import 'performance_custom_lens_plan.dart';

String? _checklistItemStoredLabel(
  String elementId,
  List<ChecklistSectionData> sections,
) {
  final parts = elementId.split(':');
  if (parts.length == 2) {
    final sectionId = parts[0];
    final itemId = parts[1];
    for (final s in sections) {
      if (s.id != sectionId) continue;
      for (final it in s.items) {
        if (it.id == itemId) return it.label;
      }
    }
    return null;
  }
  for (final s in sections) {
    for (final it in s.items) {
      if (it.id == elementId) return it.label;
    }
  }
  return null;
}

String performanceCustomLensChecklistElementLabel(
  AppLocalizations l,
  String elementId,
  List<ChecklistSectionData> sections,
) {
  final parts = elementId.split(':');
  final itemId = parts.length == 2 ? parts[1] : elementId;
  final stored = _checklistItemStoredLabel(elementId, sections);
  if (stored != null && stored.isNotEmpty) {
    return checklistItemLabel(l, itemId, stored);
  }
  return checklistItemLabel(l, itemId, ChecklistPrompts.itemLineHint);
}

String performanceCustomLensElementLabel({
  required PerformanceCustomLensDimension dimension,
  required String elementId,
  required AppLocalizations l,
  required Locale locale,
  String? strategieTitleHint,
  PerformanceCustomLensPlanIndex? planIndex,
  List<ChecklistSectionData> checklistSections = const [],
}) {
  if (elementId.isEmpty) return '—';
  switch (dimension) {
    case PerformanceCustomLensDimension.etat:
      if (elementId == 'etat_sleep') return l.mentalSleepEnough;
      if (elementId.startsWith('psych:')) {
        return elementId.substring('psych:'.length);
      }
      final parts = elementId.split(':');
      if (parts.length == 2) {
        final c = MentalStateController.instance;
        if (parts[0] == 'moment') {
          final m = c.moment.where((e) => e.id == parts[1]).toList();
          if (m.isNotEmpty) return m.first.label;
        }
        if (parts[0] == 'emotion') {
          final e = c.emotions.where((e) => e.id == parts[1]).toList();
          if (e.isNotEmpty) return e.first.label;
        }
        if (parts[0] == 'factor') {
          final f = c.factors.where((e) => e.id == parts[1]).toList();
          if (f.isNotEmpty) return f.first.label;
        }
      }
      return elementId;
    case PerformanceCustomLensDimension.checklist:
      final sections = checklistSections.isEmpty
          ? defaultNouveauTradeSections()
          : checklistSections;
      return performanceCustomLensChecklistElementLabel(l, elementId, sections);
    case PerformanceCustomLensDimension.plan:
      if (planIndex != null) {
        return planIndex.labelFor(elementId);
      }
      return elementId;
    case PerformanceCustomLensDimension.strategie:
      return labelForStrategieNonRespectId(
        elementId,
        strategieTitleHint ?? '',
        l: l,
        locale: locale,
      );
  }
}
