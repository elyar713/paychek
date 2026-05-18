import 'checklist_item_schedule.dart';
import 'checklist_prompts.dart';

/// Données d’une ligne de checklist (sans logique UI).
class ChecklistItemData {
  const ChecklistItemData({
    required this.id,
    required this.label,
    this.checked = false,
    this.schedule,
  });

  final String id;
  final String label;
  final bool checked;
  final ChecklistItemSchedule? schedule;

  ChecklistItemData copyWith({
    String? label,
    bool? checked,
    ChecklistItemSchedule? schedule,
    bool clearSchedule = false,
  }) {
    return ChecklistItemData(
      id: id,
      label: label ?? this.label,
      checked: checked ?? this.checked,
      schedule: clearSchedule ? null : (schedule ?? this.schedule),
    );
  }

  /// Rappel actif pour [day] (défaut : aujourd’hui).
  bool isDueOnDay([DateTime? day]) =>
      ChecklistItemSchedule.isDueOnDay(
        ChecklistItemSchedule.effectiveSchedule(schedule),
        day,
      );
}

/// Groupe de lignes avec titre de section.
class ChecklistSectionData {
  const ChecklistSectionData({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<ChecklistItemData> items;

  ChecklistSectionData copyWith({
    String? title,
    List<ChecklistItemData>? items,
  }) {
    return ChecklistSectionData(
      id: id,
      title: title ?? this.title,
      items: items ?? this.items,
    );
  }
}

/// Sections par défaut (nouveaux utilisateurs) : news, analyse, risque, psy.
List<ChecklistSectionData> defaultNouveauTradeSections() {
  return [
    const ChecklistSectionData(
      id: ChecklistPrompts.sectionIdNews,
      title: ChecklistPrompts.sectionTitleNews,
      items: [
        ChecklistItemData(
          id: ChecklistPrompts.itemIdNews1,
          label: ChecklistPrompts.itemLabelNews1,
        ),
        ChecklistItemData(
          id: ChecklistPrompts.itemIdNews2,
          label: ChecklistPrompts.itemLabelNews2,
        ),
        ChecklistItemData(
          id: ChecklistPrompts.itemIdNews3,
          label: ChecklistPrompts.itemLabelNews3,
        ),
        ChecklistItemData(
          id: ChecklistPrompts.itemIdNews4,
          label: ChecklistPrompts.itemLabelNews4,
        ),
      ],
    ),
    const ChecklistSectionData(
      id: ChecklistPrompts.sectionIdAnalyse,
      title: ChecklistPrompts.sectionTitleAnalyse,
      items: [
        ChecklistItemData(
          id: ChecklistPrompts.itemIdAnalyse1,
          label: ChecklistPrompts.itemLabelAnalyse1,
        ),
        ChecklistItemData(
          id: ChecklistPrompts.itemIdAnalyse2,
          label: ChecklistPrompts.itemLabelAnalyse2,
        ),
        ChecklistItemData(
          id: ChecklistPrompts.itemIdAnalyse3,
          label: ChecklistPrompts.itemLabelAnalyse3,
        ),
      ],
    ),
    const ChecklistSectionData(
      id: ChecklistPrompts.sectionIdRisque,
      title: ChecklistPrompts.sectionTitleRisque,
      items: [
        ChecklistItemData(
          id: ChecklistPrompts.itemIdRisque1,
          label: ChecklistPrompts.itemLabelRisque1,
        ),
        ChecklistItemData(
          id: ChecklistPrompts.itemIdRisque2,
          label: ChecklistPrompts.itemLabelRisque2,
        ),
        ChecklistItemData(
          id: ChecklistPrompts.itemIdRisque3,
          label: ChecklistPrompts.itemLabelRisque3,
        ),
      ],
    ),
    const ChecklistSectionData(
      id: ChecklistPrompts.sectionIdPsy,
      title: ChecklistPrompts.sectionTitlePsy,
      items: [
        ChecklistItemData(
          id: ChecklistPrompts.itemIdPsy1,
          label: ChecklistPrompts.itemLabelPsy1,
        ),
        ChecklistItemData(
          id: ChecklistPrompts.itemIdPsy2,
          label: ChecklistPrompts.itemLabelPsy2,
        ),
        ChecklistItemData(
          id: ChecklistPrompts.itemIdPsy3,
          label: ChecklistPrompts.itemLabelPsy3,
        ),
      ],
    ),
  ];
}
