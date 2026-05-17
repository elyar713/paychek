part of 'performance_page.dart';

extension _PerformancePageUiCustomLens on _PerformancePageState {
  // Conservé pour les extensions Performance ; la page utilise [PaychekLensSection].
  // ignore: unused_element
  Widget _cardCustomDisciplineLens({
    required List<Trade> trades,
    required PerformanceCustomLensConfig config,
    required List<ChecklistSectionData> checklistSections,
    ValueChanged<PerformanceCustomLensConfig>? onConfigChanged,
    VoidCallback? onAdd,
    VoidCallback? onReset,
    VoidCallback? onRemove,
    bool readOnly = false,
  }) {
    return PerformanceCustomLensCard(
      trades: trades,
      config: config,
      checklistSections: checklistSections,
      onConfigChanged: onConfigChanged,
      onAdd: onAdd,
      onReset: onReset,
      onRemove: onRemove,
      readOnly: readOnly,
    );
  }
}
