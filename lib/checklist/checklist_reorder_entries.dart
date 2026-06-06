import 'checklist_models.dart';

sealed class ChecklistFlatReorderEntry {
  const ChecklistFlatReorderEntry();
}

class ChecklistFlatReorderHeader extends ChecklistFlatReorderEntry {
  const ChecklistFlatReorderHeader({
    required this.sectionId,
    required this.title,
  });

  final String sectionId;
  final String title;
}

class ChecklistFlatReorderItem extends ChecklistFlatReorderEntry {
  const ChecklistFlatReorderItem({
    required this.sectionId,
    required this.item,
  });

  final String sectionId;
  final ChecklistItemData item;
}

List<ChecklistFlatReorderEntry> buildChecklistFlatReorderEntries(
  List<ChecklistSectionData> sections,
) {
  final out = <ChecklistFlatReorderEntry>[];
  for (final section in sections) {
    out.add(
      ChecklistFlatReorderHeader(
        sectionId: section.id,
        title: section.title,
      ),
    );
    for (final item in section.items) {
      out.add(
        ChecklistFlatReorderItem(sectionId: section.id, item: item),
      );
    }
  }
  return out;
}

/// Reconstruit sections + ordre des items depuis la liste aplatie.
List<ChecklistSectionData> checklistSectionsFromFlatReorder(
  List<ChecklistFlatReorderEntry> flat,
  List<ChecklistSectionData> original,
) {
  final byId = {for (final s in original) s.id: s};
  final orderedSectionIds = <String>[];
  final itemsBySection = {
    for (final s in original) s.id: <ChecklistItemData>[],
  };

  String? currentSectionId;
  for (final entry in flat) {
    switch (entry) {
      case ChecklistFlatReorderHeader(:final sectionId):
        currentSectionId = sectionId;
        if (!orderedSectionIds.contains(sectionId)) {
          orderedSectionIds.add(sectionId);
        }
      case ChecklistFlatReorderItem(:final item):
        if (currentSectionId == null) continue;
        itemsBySection[currentSectionId]!.add(item);
    }
  }

  for (final s in original) {
    if (!orderedSectionIds.contains(s.id)) {
      orderedSectionIds.add(s.id);
    }
  }

  return [
    for (final id in orderedSectionIds)
      if (byId.containsKey(id))
        byId[id]!.copyWith(items: itemsBySection[id] ?? const []),
  ];
}

int _snapItemInsertIndex(
  List<ChecklistFlatReorderEntry> flat,
  int insertAt,
) {
  if (flat.isEmpty) return 0;
  insertAt = insertAt.clamp(0, flat.length);

  // Jamais avant le premier en-tête de section.
  if (insertAt == 0 && flat.first is ChecklistFlatReorderHeader) {
    return 1.clamp(0, flat.length);
  }

  // Si la cible est un en-tête → insérer juste après (dans cette section).
  if (insertAt < flat.length && flat[insertAt] is ChecklistFlatReorderHeader) {
    return (insertAt + 1).clamp(0, flat.length);
  }

  return insertAt;
}

/// Cible valide pour un bloc section : toujours sur un en-tête (jamais entre les critères).
int _snapSectionBlockInsertIndex(
  List<ChecklistFlatReorderEntry> flat,
  int insertAt,
) {
  if (flat.isEmpty) return 0;
  insertAt = insertAt.clamp(0, flat.length);
  if (insertAt >= flat.length) return flat.length;
  if (flat[insertAt] is ChecklistFlatReorderHeader) return insertAt;

  for (var i = insertAt; i >= 0; i--) {
    if (flat[i] is ChecklistFlatReorderHeader) return i;
  }
  return 0;
}

/// Déplace un bloc section (en-tête + lignes) dans la liste aplatie.
List<ChecklistFlatReorderEntry> reorderChecklistSectionBlockInFlat(
  List<ChecklistFlatReorderEntry> flat,
  int oldHeaderIndex,
  int newIndex,
) {
  if (oldHeaderIndex < 0 || oldHeaderIndex >= flat.length) return flat;
  if (flat[oldHeaderIndex] is! ChecklistFlatReorderHeader) return flat;

  var end = oldHeaderIndex + 1;
  while (end < flat.length && flat[end] is ChecklistFlatReorderItem) {
    end++;
  }
  final block = flat.sublist(oldHeaderIndex, end);
  final next = [...flat]..removeRange(oldHeaderIndex, end);

  var insertAt = newIndex;
  if (insertAt > oldHeaderIndex) {
    insertAt -= block.length;
  }
  insertAt = insertAt.clamp(0, next.length);
  insertAt = _snapSectionBlockInsertIndex(next, insertAt);
  next.insertAll(insertAt, block);
  return next;
}

/// Déplace une ligne dans la liste aplatie (y compris vers une autre section).
List<ChecklistFlatReorderEntry> reorderChecklistItemInFlat(
  List<ChecklistFlatReorderEntry> flat,
  int oldIndex,
  int newIndex,
) {
  if (oldIndex < 0 || oldIndex >= flat.length) return flat;
  if (flat[oldIndex] is! ChecklistFlatReorderItem) return flat;

  var insertAt = newIndex;
  if (insertAt > oldIndex) insertAt--;

  final next = [...flat];
  final moved = next.removeAt(oldIndex) as ChecklistFlatReorderItem;
  insertAt = insertAt.clamp(0, next.length);
  insertAt = _snapItemInsertIndex(next, insertAt);
  next.insert(insertAt, moved);
  return next;
}
