import 'app_localizations.dart';
import '../checklist/checklist_prompts.dart';

String? _canonicalSectionTitle(String sectionId) {
  return switch (sectionId) {
    ChecklistPrompts.sectionIdAnalyse => ChecklistPrompts.sectionTitleAnalyse,
    ChecklistPrompts.sectionIdRisque => ChecklistPrompts.sectionTitleRisque,
    ChecklistPrompts.sectionIdPsy => ChecklistPrompts.sectionTitlePsy,
    _ => null,
  };
}

/// Associe les ids de sections par défaut ([ChecklistPrompts]) aux chaînes [AppLocalizations].
/// Si l’utilisateur a modifié le titre ([stored] ≠ libellé canonique), renvoie [stored].
String checklistSectionTitle(
  AppLocalizations l,
  String sectionId,
  String stored,
) {
  final canonical = _canonicalSectionTitle(sectionId);
  if (canonical != null) {
    if (stored != canonical) return stored;
    return switch (sectionId) {
      ChecklistPrompts.sectionIdAnalyse => l.checklistSectionAnalyse,
      ChecklistPrompts.sectionIdRisque => l.checklistSectionRisque,
      ChecklistPrompts.sectionIdPsy => l.checklistSectionPsy,
      _ => stored,
    };
  }
  return stored;
}

String? _canonicalItemLabel(String itemId) {
  return switch (itemId) {
    ChecklistPrompts.itemIdAnalyse1 => ChecklistPrompts.itemLabelAnalyse1,
    ChecklistPrompts.itemIdAnalyse2 => ChecklistPrompts.itemLabelAnalyse2,
    ChecklistPrompts.itemIdAnalyse3 => ChecklistPrompts.itemLabelAnalyse3,
    ChecklistPrompts.itemIdRisque1 => ChecklistPrompts.itemLabelRisque1,
    ChecklistPrompts.itemIdRisque2 => ChecklistPrompts.itemLabelRisque2,
    ChecklistPrompts.itemIdRisque3 => ChecklistPrompts.itemLabelRisque3,
    ChecklistPrompts.itemIdPsy1 => ChecklistPrompts.itemLabelPsy1,
    ChecklistPrompts.itemIdPsy2 => ChecklistPrompts.itemLabelPsy2,
    ChecklistPrompts.itemIdPsy3 => ChecklistPrompts.itemLabelPsy3,
    _ => null,
  };
}

/// Associe les ids d’items par défaut aux libellés [AppLocalizations].
/// Si l’utilisateur a modifié le critère ([stored] ≠ libellé canonique), renvoie [stored].
String checklistItemLabel(
  AppLocalizations l,
  String itemId,
  String stored,
) {
  final canonical = _canonicalItemLabel(itemId);
  if (canonical != null) {
    if (stored != canonical) return stored;
    return switch (itemId) {
      ChecklistPrompts.itemIdAnalyse1 => l.checklistItemAnalyse1,
      ChecklistPrompts.itemIdAnalyse2 => l.checklistItemAnalyse2,
      ChecklistPrompts.itemIdAnalyse3 => l.checklistItemAnalyse3,
      ChecklistPrompts.itemIdRisque1 => l.checklistItemRisque1,
      ChecklistPrompts.itemIdRisque2 => l.checklistItemRisque2,
      ChecklistPrompts.itemIdRisque3 => l.checklistItemRisque3,
      ChecklistPrompts.itemIdPsy1 => l.checklistItemPsy1,
      ChecklistPrompts.itemIdPsy2 => l.checklistItemPsy2,
      ChecklistPrompts.itemIdPsy3 => l.checklistItemPsy3,
      _ => stored,
    };
  }
  return stored;
}
