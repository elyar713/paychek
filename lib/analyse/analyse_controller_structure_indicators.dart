part of 'analyse_controller_structure_smc.dart';

/// Notes indicateurs + section Indicateurs (liste, TF, champs sup., snapshots).
mixin AnalyseControllerStructureIndicators on AnalyseControllerStructureSnapshots {
  String _notesIndicators = '';
  String get notesIndicators => _notesIndicators;
  set notesIndicators(String v) {
    if (v == _notesIndicators) return;
    _notesIndicators = v;
    notifyListeners();
  }

  bool _indicatorsEnabled = true;
  bool get indicatorsEnabled => _indicatorsEnabled;
  set indicatorsEnabled(bool v) {
    if (v == _indicatorsEnabled) return;
    _indicatorsEnabled = v;
    rebalanceAnalyseSectionImpacts();
    notifyListeners();
  }

  final List<String> indicators =
      List<String>.from(kAnalyseDefaultEntrySignalLabels);

  /// Outils du setup cochés (tap sur pilule). Ordre d’affichage rapport = ordre de [indicators].
  final Set<String> _indicatorsSetupSelected =
      Set<String>.from(kAnalyseDefaultEntrySignalLabels);

  bool indicatorSetupIsSelected(String name) =>
      _indicatorsSetupSelected.contains(name);

  void toggleIndicatorsSetupSelection(String name) {
    if (!indicators.contains(name)) return;
    if (_indicatorsSetupSelected.contains(name)) {
      _indicatorsSetupSelected.remove(name);
    } else {
      _indicatorsSetupSelected.add(name);
    }
    notifyListeners();
  }

  void addCustomIndicator(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return;
    if (indicators.contains(s)) return;
    indicators.add(s);
    _indicatorsSetupSelected.add(s);
    notifyListeners();
  }

  void removeIndicatorAt(int index) {
    if (index < 0 || index >= indicators.length) return;
    final removed = indicators.removeAt(index);
    _indicatorsSetupSelected.remove(removed);
    notifyListeners();
  }

  /// Timeframe de la section Indicateurs (même presets que Structure & chartisme).
  String _indicatorsTf = AnalyseStructureChartTf.m5.label;
  final List<String> _indicatorsTfCustom = <String>[];

  String get indicatorsTf => _indicatorsTf;
  set indicatorsTf(String v) {
    final nv = v.trim();
    if (nv.isEmpty) return;
    if (nv == _indicatorsTf) return;
    _indicatorsTf = nv;
    notifyListeners();
  }

  List<String> get indicatorsTfCustom => List.unmodifiable(_indicatorsTfCustom);

  void registerIndicatorsTfCustom(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (_indicatorsTfCustom.contains(v)) return;
    _indicatorsTfCustom.add(v);
  }

  void addIndicatorsTfCustom(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    registerIndicatorsTfCustom(v);
    if (v == _indicatorsTf) return;
    _indicatorsTf = v;
    notifyListeners();
  }

  final List<AnalyseIndicatorsSnapshot> _indicatorsSnapshots =
      <AnalyseIndicatorsSnapshot>[];

  List<AnalyseIndicatorsSnapshot> get indicatorsSnapshots =>
      List.unmodifiable(_indicatorsSnapshots);

  /// Copie TF + setup + champs crayon + notes ; **pas** le curseur confiance / impact.
  void duplicateIndicators() {
    final selectedOrdered = <String>[
      for (final n in indicators)
        if (_indicatorsSetupSelected.contains(n)) n
    ];
    _indicatorsSnapshots.add(
      AnalyseIndicatorsSnapshot(
        indicatorsTf: _indicatorsTf,
        indicatorNames: List<String>.from(indicators),
        indicatorSetupSelected: selectedOrdered,
        extraFields: List<String>.from(_indicatorExtraFields),
        notesIndicators: _notesIndicators,
      ),
    );
    notifyListeners();
  }

  void removeIndicatorsSnapshot(int index) {
    if (index < 0 || index >= _indicatorsSnapshots.length) return;
    _indicatorsSnapshots.removeAt(index);
    notifyListeners();
  }

  void _mutateIndicatorsSnapshot(
    int index,
    AnalyseIndicatorsSnapshot Function(AnalyseIndicatorsSnapshot s) f,
  ) {
    if (index < 0 || index >= _indicatorsSnapshots.length) return;
    _indicatorsSnapshots[index] = f(_indicatorsSnapshots[index]);
    notifyListeners();
  }

  void setIndicatorsSnapshotTf(int index, String tf) {
    final nv = tf.trim();
    if (nv.isEmpty) return;
    _mutateIndicatorsSnapshot(index, (s) => s.copyWith(indicatorsTf: nv));
  }

  void addIndicatorsSnapshotTfCustom(int index, String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    registerIndicatorsTfCustom(v);
    setIndicatorsSnapshotTf(index, v);
  }

  void setIndicatorsSnapshotNotes(int index, String v) {
    _mutateIndicatorsSnapshot(index, (s) {
      if (s.notesIndicators == v) return s;
      return s.copyWith(notesIndicators: v);
    });
  }

  void updateIndicatorsSnapshotExtraField(int index, int fieldIndex, String v) {
    _mutateIndicatorsSnapshot(index, (s) {
      if (fieldIndex < 0 || fieldIndex >= s.extraFields.length) return s;
      final list = List<String>.from(s.extraFields);
      if (list[fieldIndex] == v) return s;
      list[fieldIndex] = v;
      return s.copyWith(extraFields: list);
    });
  }

  void addIndicatorsSnapshotExtraField(int index) {
    _mutateIndicatorsSnapshot(index, (s) {
      final list = List<String>.from(s.extraFields)..add('');
      return s.copyWith(extraFields: list);
    });
  }

  void removeIndicatorsSnapshotExtraField(int index, int fieldIndex) {
    _mutateIndicatorsSnapshot(index, (s) {
      if (fieldIndex < 0 || fieldIndex >= s.extraFields.length) return s;
      final list = List<String>.from(s.extraFields)..removeAt(fieldIndex);
      return s.copyWith(extraFields: list);
    });
  }

  void addIndicatorsSnapshotIndicator(int index, String raw) {
    final name = raw.trim();
    if (name.isEmpty) return;
    _mutateIndicatorsSnapshot(index, (s) {
      if (s.indicatorNames.contains(name)) return s;
      final list = List<String>.from(s.indicatorNames)..add(name);
      final sel = List<String>.from(s.activeIndicatorSetup)..add(name);
      return s.copyWith(indicatorNames: list, indicatorSetupSelected: sel);
    });
  }

  void removeIndicatorsSnapshotIndicatorAt(int index, int at) {
    _mutateIndicatorsSnapshot(index, (s) {
      if (at < 0 || at >= s.indicatorNames.length) return s;
      final removed = s.indicatorNames[at];
      final list = List<String>.from(s.indicatorNames)..removeAt(at);
      final sel = [
        for (final n in s.activeIndicatorSetup)
          if (n != removed) n
      ];
      return s.copyWith(indicatorNames: list, indicatorSetupSelected: sel);
    });
  }

  void toggleIndicatorsSnapshotSetupSelection(int index, String name) {
    _mutateIndicatorsSnapshot(index, (s) {
      if (!s.indicatorNames.contains(name)) return s;
      final set = s.activeIndicatorSetup.toSet();
      if (set.contains(name)) {
        set.remove(name);
      } else {
        set.add(name);
      }
      final ordered = <String>[
        for (final n in s.indicatorNames)
          if (set.contains(n)) n
      ];
      return s.copyWith(indicatorSetupSelected: ordered);
    });
  }

  final List<String> _indicatorExtraFields = <String>[];

  List<String> get indicatorExtraFields =>
      List.unmodifiable(_indicatorExtraFields);

  void addIndicatorExtraField() {
    _indicatorExtraFields.add('');
    notifyListeners();
  }

  void updateIndicatorExtraField(int index, String v) {
    if (index < 0 || index >= _indicatorExtraFields.length) return;
    if (_indicatorExtraFields[index] == v) return;
    _indicatorExtraFields[index] = v;
    notifyListeners();
  }

  void removeIndicatorExtraField(int index) {
    if (index < 0 || index >= _indicatorExtraFields.length) return;
    _indicatorExtraFields.removeAt(index);
    notifyListeners();
  }

  AnalyseIndicatorsSnapshot _blankIndicatorsSnapshot() {
    return AnalyseIndicatorsSnapshot(
      indicatorsTf: AnalyseStructureChartTf.m5.label,
      indicatorNames: const [],
      indicatorSetupSelected: const [],
      extraFields: const [],
      notesIndicators: '',
    );
  }

  void resetIndicatorsMainAfterValidation() {
    _notesIndicators = '';
    _indicatorExtraFields.clear();
    _indicatorsTf = AnalyseStructureChartTf.m5.label;
    indicators.clear();
    indicators.addAll(kAnalyseDefaultEntrySignalLabels);
    _indicatorsSetupSelected
      ..clear()
      ..addAll(kAnalyseDefaultEntrySignalLabels);
    notifyListeners();
  }

  void resetIndicatorsCopiesAfterValidation() {
    for (var i = 0; i < _indicatorsSnapshots.length; i++) {
      _indicatorsSnapshots[i] = _blankIndicatorsSnapshot();
    }
    notifyListeners();
  }

  void replaceIndicatorsPaletteAndSetup(List<String> palette, Set<String> selected) {
    indicators.clear();
    indicators.addAll(palette);
    _indicatorsSetupSelected
      ..clear()
      ..addAll(selected);
    notifyListeners();
  }

  void replaceIndicatorsSnapshots(List<AnalyseIndicatorsSnapshot> next) {
    _indicatorsSnapshots
      ..clear()
      ..addAll(next);
    notifyListeners();
  }
}
