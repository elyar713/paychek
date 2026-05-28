import '../checklist/checklist_models.dart';
import '../checklist/checklist_page_controller.dart';
import 'coach_ai_response_format.dart';

class ChecklistTodaySection {
  const ChecklistTodaySection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<ChecklistTodayItem> items;
}

class ChecklistTodayItem {
  const ChecklistTodayItem({
    required this.label,
    required this.checked,
  });

  final String label;
  final bool checked;
}

class ChecklistTodaySnapshot {
  const ChecklistTodaySnapshot({
    required this.percent,
    required this.totalDue,
    required this.checkedDue,
    required this.sections,
  });

  final int percent;
  final int totalDue;
  final int checkedDue;
  final List<ChecklistTodaySection> sections;

  bool get hasItemsDueToday => totalDue > 0;
}

/// Checklist du jour (page Checklist PAYCHEK), pas l’audit discipline des trades.
abstract final class CoachAiChecklistToday {
  static bool isTodayChecklistQuestion(String question) {
    final q = question.toLowerCase();
    if (!RegExp(
      r'che?ck\s*list|checklist|checkliste|cheklist|chekliste|tâches? du jour|taches? du jour',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r'performance|winrate|pnl|bilan|non.?respect|enregistr|audit|combien|sur mes trades|'
      r'discipline enregistr|non.?respect',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r"aujourd'hui|aujourdhui|today|du jour|ce matin|ce soir|this morning|this evening",
    ).hasMatch(q)) {
      return true;
    }
    return RegExp(
      r"dis.?moi|montre|quelle est|quel est|what is|show me|ma checklist|mon checklist|la checklist",
    ).hasMatch(q);
  }

  static Future<ChecklistTodaySnapshot> buildTodaySnapshot() async {
    final controller = ChecklistPageController();
    await controller.hydrateFromStorage();
    final today = DateTime.now();
    final uncheckedIds = controller
        .uncheckedEntriesForDay(today)
        .map((e) => e.itemId)
        .toSet();

    final sections = <ChecklistTodaySection>[];
    for (final section in controller.sections) {
      if (!checklistSectionIsActive(section)) continue;
      final items = <ChecklistTodayItem>[];
      for (final item in section.items) {
        if (!item.isDueOnDay(today)) continue;
        items.add(
          ChecklistTodayItem(
            label: item.label,
            checked: !uncheckedIds.contains(item.id),
          ),
        );
      }
      if (items.isNotEmpty) {
        sections.add(ChecklistTodaySection(title: section.title, items: items));
      }
    }

    return ChecklistTodaySnapshot(
      percent: controller.completionPercentOnDay(today),
      totalDue: controller.totalItemsDueToday,
      checkedDue: controller.checkedItemsDueToday,
      sections: sections,
    );
  }

  static String todayCardTitle(String languageCode) {
    return switch (languageCode) {
      'en' => 'Checklist · today',
      'de' => 'Checkliste · heute',
      'es' => 'Checklist · hoy',
      _ => 'Checklist · aujourd’hui',
    };
  }

  static Future<Map<String, dynamic>> todayContextToJson(
    String languageCode, {
    bool briefFollowUp = false,
  }) async {
    final snap = await buildTodaySnapshot();
    return <String, dynamic>{
      'coachInstructions': briefFollowUp
          ? CoachAiResponseFormat.checklistTodayFollowUpInstructions(languageCode)
          : CoachAiResponseFormat.checklistTodayInstructions(languageCode),
      'hasItemsDueToday': snap.hasItemsDueToday,
      'completionPercent': snap.percent,
      'checkedDue': snap.checkedDue,
      'totalDue': snap.totalDue,
      'sections': [
        for (final section in snap.sections)
          <String, dynamic>{
            'title': section.title,
            'items': [
              for (final item in section.items)
                <String, dynamic>{
                  'label': item.label,
                  'checked': item.checked,
                },
            ],
          },
      ],
      'fillHintPath': languageCode == 'fr'
          ? 'Accueil → carte Checklist, ou Plus → Checklist'
          : 'Home → Checklist card, or More → Checklist',
    };
  }
}
