import 'checklist_item_schedule.dart';
import 'checklist_models.dart';

/// Date+heure de la prochaine occurrence (tri : la plus proche en premier).
DateTime checklistItemNextOccurrence(
  ChecklistItemData item, [
  DateTime? from,
]) {
  return ChecklistItemSchedule.nextOccurrenceDateTime(
    ChecklistItemSchedule.effectiveSchedule(item.schedule),
    from,
  );
}

int checklistItemOccurrenceCompare(
  ChecklistItemData a,
  ChecklistItemData b, [
  DateTime? from,
]) {
  final ta = checklistItemNextOccurrence(a, from);
  final tb = checklistItemNextOccurrence(b, from);
  return ta.compareTo(tb);
}

/// Sections avec items triés ; sections ordonnées par la occurrence la plus proche.
List<ChecklistSectionData> checklistSectionsSortedBySchedule(
  List<ChecklistSectionData> sections, [
  DateTime? from,
]) {
  final out = sections.map((section) {
    final items = [...section.items]
      ..sort((a, b) => checklistItemOccurrenceCompare(a, b, from));
    return section.copyWith(items: items);
  }).toList();

  out.sort((a, b) {
    DateTime key(ChecklistSectionData s) {
      if (s.items.isEmpty) {
        return DateTime(9999, 12, 31, 23, 59);
      }
      return checklistItemNextOccurrence(s.items.first, from);
    }

    return key(a).compareTo(key(b));
  });

  return out;
}

void sortChecklistPreviewEntriesBySchedule<
    T extends ({String sectionId, ChecklistItemData item})>(
  List<T> entries, [
  DateTime? from,
]) {
  entries.sort(
    (a, b) => checklistItemOccurrenceCompare(a.item, b.item, from),
  );
}
