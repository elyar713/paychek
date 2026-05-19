/// Snapshot checklist d’un jour (pourcentage + lignes non cochées).
class ChecklistDailyDaySnapshot {
  const ChecklistDailyDaySnapshot({
    required this.percent,
    this.uncheckedEntries = const [],
  });

  final int percent;

  /// Libellés figés au moment de la clôture (ou avant suppression).
  final List<ChecklistUncheckedDayEntry> uncheckedEntries;

  List<String> get uncheckedItemIds => [
        for (final e in uncheckedEntries) e.itemId,
      ];

  ChecklistDailyDaySnapshot copyWith({
    int? percent,
    List<ChecklistUncheckedDayEntry>? uncheckedEntries,
  }) {
    return ChecklistDailyDaySnapshot(
      percent: percent ?? this.percent,
      uncheckedEntries: uncheckedEntries ?? this.uncheckedEntries,
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
