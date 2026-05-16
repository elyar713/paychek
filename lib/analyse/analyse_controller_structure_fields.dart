part of 'analyse_controller_structure_smc.dart';

/// Structure & chartisme : TF, tenues, S/R, niveaux supplémentaires, blocs dupliqués (liste).
mixin AnalyseControllerStructureFields on ChangeNotifier {
  bool _structureEnabled = true;
  bool get structureEnabled => _structureEnabled;
  set structureEnabled(bool v) {
    if (v == _structureEnabled) return;
    _structureEnabled = v;
    notifyListeners();
  }

  /// TF affiché (préréglage ou personnalisé).
  String _structureTf = AnalyseStructureChartTf.h1.label;
  final List<String> _structureTfCustom = <String>[];

  String get structureTf => _structureTf;
  set structureTf(String v) {
    final nv = v.trim();
    if (nv.isEmpty) return;
    if (nv == _structureTf) return;
    _structureTf = nv;
    notifyListeners();
  }

  List<String> get structureTfCustom => List.unmodifiable(_structureTfCustom);

  /// Ajoute un libellé TF personnalisé au menu (sans changer le TF principal).
  void registerStructureTfCustom(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (_structureTfCustom.contains(v)) return;
    _structureTfCustom.add(v);
  }

  void addStructureTfCustom(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    registerStructureTfCustom(v);
    if (v == _structureTf) return;
    _structureTf = v;
    notifyListeners();
  }

  AnalyseStructureTenue? _structureTenue = AnalyseStructureTenue.tenu;
  AnalyseStructureTenue? get structureTenue => _structureTenue;
  set structureTenue(AnalyseStructureTenue? v) {
    if (v == _structureTenue) return;
    _structureTenue = v;
    notifyListeners();
  }

  String _structureSupportMaj = '';
  String get structureSupportMaj => _structureSupportMaj;
  set structureSupportMaj(String v) {
    if (v == _structureSupportMaj) return;
    _structureSupportMaj = v;
    notifyListeners();
  }

  String _structureResistanceMaj = '';
  String get structureResistanceMaj => _structureResistanceMaj;
  set structureResistanceMaj(String v) {
    if (v == _structureResistanceMaj) return;
    _structureResistanceMaj = v;
    notifyListeners();
  }

  bool _structureSupportTested = false;
  bool get structureSupportTested => _structureSupportTested;
  set structureSupportTested(bool v) {
    if (v == _structureSupportTested) return;
    _structureSupportTested = v;
    notifyListeners();
  }

  bool _structureResistanceTested = false;
  bool get structureResistanceTested => _structureResistanceTested;
  set structureResistanceTested(bool v) {
    if (v == _structureResistanceTested) return;
    _structureResistanceTested = v;
    notifyListeners();
  }

  final List<AnalyseStructureExtraLevel> _extraSupports = <AnalyseStructureExtraLevel>[];
  final List<AnalyseStructureExtraLevel> _extraResistances = <AnalyseStructureExtraLevel>[];

  List<AnalyseStructureExtraLevel> get extraSupports => List.unmodifiable(_extraSupports);
  List<AnalyseStructureExtraLevel> get extraResistances => List.unmodifiable(_extraResistances);

  void addExtraSupport(AnalyseStructureExtraLevel level) {
    _extraSupports.add(level);
    notifyListeners();
  }

  void addExtraResistance(AnalyseStructureExtraLevel level) {
    _extraResistances.add(level);
    notifyListeners();
  }

  void updateExtraSupport(int index, String price) {
    if (index < 0 || index >= _extraSupports.length) return;
    if (_extraSupports[index].price == price) return;
    _extraSupports[index].price = price;
    notifyListeners();
  }

  void updateExtraSupportTenue(int index, AnalyseStructureTenue? tenue) {
    if (index < 0 || index >= _extraSupports.length) return;
    if (_extraSupports[index].tenue == tenue) return;
    _extraSupports[index].tenue = tenue;
    notifyListeners();
  }

  void updateExtraResistance(int index, String price) {
    if (index < 0 || index >= _extraResistances.length) return;
    if (_extraResistances[index].price == price) return;
    _extraResistances[index].price = price;
    notifyListeners();
  }

  void updateExtraResistanceTenue(int index, AnalyseStructureTenue? tenue) {
    if (index < 0 || index >= _extraResistances.length) return;
    if (_extraResistances[index].tenue == tenue) return;
    _extraResistances[index].tenue = tenue;
    notifyListeners();
  }

  String _structureDernierPoint = '';
  String get structureDernierPoint => _structureDernierPoint;
  set structureDernierPoint(String v) {
    if (v == _structureDernierPoint) return;
    _structureDernierPoint = v;
    notifyListeners();
  }

  String _notesStructure = '';
  String get notesStructure => _notesStructure;
  set notesStructure(String v) {
    if (v == _notesStructure) return;
    _notesStructure = v;
    notifyListeners();
  }

  final List<AnalyseStructureSnapshot> _structureSnapshots =
      <AnalyseStructureSnapshot>[];

  List<AnalyseStructureSnapshot> get structureSnapshots =>
      List.unmodifiable(_structureSnapshots);

  /// Ajoute un bloc Structure **vierge** (même champs que l’original, saisie indépendante).
  void duplicateStructure() {
    _structureSnapshots.add(
      AnalyseStructureSnapshot(
        structureTf: AnalyseStructureChartTf.h1.label,
        dernierPoint: '',
        structureTenue: AnalyseStructureTenue.tenu,
        structureSupportMaj: '',
        structureResistanceMaj: '',
        structureSupportTested: false,
        structureResistanceTested: false,
        extraSupports: const [],
        extraResistances: const [],
      ),
    );
    notifyListeners();
  }

  void removeExtraSupport(int index) {
    if (index < 0 || index >= _extraSupports.length) return;
    _extraSupports.removeAt(index);
    notifyListeners();
  }

  void removeExtraResistance(int index) {
    if (index < 0 || index >= _extraResistances.length) return;
    _extraResistances.removeAt(index);
    notifyListeners();
  }

  void removeStructureSnapshot(int index) {
    if (index < 0 || index >= _structureSnapshots.length) return;
    _structureSnapshots.removeAt(index);
    notifyListeners();
  }

  AnalyseStructureSnapshot _blankStructureSnapshot() {
    return AnalyseStructureSnapshot(
      structureTf: AnalyseStructureChartTf.h1.label,
      dernierPoint: '',
      structureTenue: AnalyseStructureTenue.tenu,
      structureSupportMaj: '',
      structureResistanceMaj: '',
      structureSupportTested: false,
      structureResistanceTested: false,
      extraSupports: const [],
      extraResistances: const [],
    );
  }

  void resetStructureMainAfterValidation() {
    _structureTf = AnalyseStructureChartTf.h1.label;
    _structureDernierPoint = '';
    _structureSupportMaj = '';
    _structureResistanceMaj = '';
    _structureTenue = AnalyseStructureTenue.tenu;
    _structureSupportTested = false;
    _structureResistanceTested = false;
    _notesStructure = '';
    _extraSupports.clear();
    _extraResistances.clear();
    notifyListeners();
  }

  void resetStructureCopiesAfterValidation() {
    for (var i = 0; i < _structureSnapshots.length; i++) {
      _structureSnapshots[i] = _blankStructureSnapshot();
    }
    notifyListeners();
  }

  void replaceStructureSnapshots(List<AnalyseStructureSnapshot> next) {
    _structureSnapshots
      ..clear()
      ..addAll(next);
    notifyListeners();
  }
}
