/// Snapshot checklist d’un jour (pourcentage + lignes non cochées).
class ChecklistDailyDaySnapshot {
  const ChecklistDailyDaySnapshot({
    required this.percent,
    this.uncheckedItemIds = const [],
  });

  final int percent;
  final List<String> uncheckedItemIds;

  ChecklistDailyDaySnapshot copyWith({
    int? percent,
    List<String>? uncheckedItemIds,
  }) {
    return ChecklistDailyDaySnapshot(
      percent: percent ?? this.percent,
      uncheckedItemIds: uncheckedItemIds ?? this.uncheckedItemIds,
    );
  }
}

/// Ligne affichée dans la carte « non cochés ».
class ChecklistUncheckedDayEntry {
  const ChecklistUncheckedDayEntry({
    required this.sectionId,
    required this.sectionTitle,
    required this.itemId,
    required this.itemLabel,
  });

  final String sectionId;
  final String sectionTitle;
  final String itemId;
  final String itemLabel;
}
