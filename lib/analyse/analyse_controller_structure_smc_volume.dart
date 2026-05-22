part of 'analyse_controller_structure_smc.dart';

/// SMC + profil de volume.
mixin AnalyseControllerStructureSmcIndicators on AnalyseControllerStructureIndicators {
  String _smcZone = '';
  String get smcZone => _smcZone;
  set smcZone(String v) {
    if (v == _smcZone) return;
    _smcZone = v;
    notifyListeners();
  }

  String _smcFvg = '';
  String get smcFvg => _smcFvg;
  set smcFvg(String v) {
    if (v == _smcFvg) return;
    _smcFvg = v;
    notifyListeners();
  }

  String _smcLiquidityPools = '';
  String get smcLiquidityPools => _smcLiquidityPools;
  set smcLiquidityPools(String v) {
    if (v == _smcLiquidityPools) return;
    _smcLiquidityPools = v;
    notifyListeners();
  }

  /// Niveau Fib sélectionné (ex. `0.618`) ; `null` si aucune puce.
  String? _smcFibLevel = '0.618';
  String? get smcFibLevel => _smcFibLevel;
  set smcFibLevel(String? v) {
    if (v == _smcFibLevel) return;
    _smcFibLevel = v;
    notifyListeners();
  }

  String _smcFibPrice = '';
  String get smcFibPrice => _smcFibPrice;
  set smcFibPrice(String v) {
    if (v == _smcFibPrice) return;
    _smcFibPrice = v;
    notifyListeners();
  }

  /// Timeframe SMC (OB) — mêmes presets que Structure / Indicateurs.
  String _smcTf = AnalyseStructureChartTf.h1.label;
  final List<String> _smcTfCustom = <String>[];

  String get smcTf => _smcTf;
  set smcTf(String v) {
    final nv = v.trim();
    if (nv.isEmpty) return;
    if (nv == _smcTf) return;
    _smcTf = nv;
    notifyListeners();
  }

  List<String> get smcTfCustom => List.unmodifiable(_smcTfCustom);

  void registerSmcTfCustom(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (_smcTfCustom.contains(v)) return;
    _smcTfCustom.add(v);
  }

  void addSmcTfCustom(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    registerSmcTfCustom(v);
    if (v == _smcTf) return;
    _smcTf = v;
    notifyListeners();
  }

  final List<String> _smcExtraFields = <String>[];

  List<String> get smcExtraFields => List.unmodifiable(_smcExtraFields);

  void addSmcExtraLine(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return;
    if (_smcExtraFields.contains(t)) return;
    _smcExtraFields.add(t);
    notifyListeners();
  }

  void removeSmcExtraFieldAt(int index) {
    if (index < 0 || index >= _smcExtraFields.length) return;
    _smcExtraFields.removeAt(index);
    notifyListeners();
  }

  final List<String> _smcZoneExtras = <String>[];
  final List<String> _smcFvgExtras = <String>[];
  final List<String> _smcLiquidityExtras = <String>[];

  List<String> get smcZoneExtras => List.unmodifiable(_smcZoneExtras);
  List<String> get smcFvgExtras => List.unmodifiable(_smcFvgExtras);
  List<String> get smcLiquidityExtras => List.unmodifiable(_smcLiquidityExtras);

  void addSmcZoneExtra(String raw) {
    _smcZoneExtras.add(raw);
    notifyListeners();
  }

  void setSmcZoneExtraAt(int index, String value) {
    if (index < 0 || index >= _smcZoneExtras.length) return;
    _smcZoneExtras[index] = value;
    notifyListeners();
  }

  void removeSmcZoneExtraAt(int index) {
    if (index < 0 || index >= _smcZoneExtras.length) return;
    _smcZoneExtras.removeAt(index);
    notifyListeners();
  }

  void addSmcFvgExtra(String raw) {
    _smcFvgExtras.add(raw);
    notifyListeners();
  }

  void setSmcFvgExtraAt(int index, String value) {
    if (index < 0 || index >= _smcFvgExtras.length) return;
    _smcFvgExtras[index] = value;
    notifyListeners();
  }

  void removeSmcFvgExtraAt(int index) {
    if (index < 0 || index >= _smcFvgExtras.length) return;
    _smcFvgExtras.removeAt(index);
    notifyListeners();
  }

  void addSmcLiquidityExtra(String raw) {
    _smcLiquidityExtras.add(raw);
    notifyListeners();
  }

  void setSmcLiquidityExtraAt(int index, String value) {
    if (index < 0 || index >= _smcLiquidityExtras.length) return;
    _smcLiquidityExtras[index] = value;
    notifyListeners();
  }

  void removeSmcLiquidityExtraAt(int index) {
    if (index < 0 || index >= _smcLiquidityExtras.length) return;
    _smcLiquidityExtras.removeAt(index);
    notifyListeners();
  }

  List<String> _smcMergedExtraFields() => [
        for (final e in _smcZoneExtras)
          if (e.trim().isNotEmpty) 'OB: ${e.trim()}',
        for (final e in _smcFvgExtras)
          if (e.trim().isNotEmpty) 'FVG: ${e.trim()}',
        for (final e in _smcLiquidityExtras)
          if (e.trim().isNotEmpty) 'LIQ: ${e.trim()}',
        ..._smcExtraFields,
      ];

  bool _smcEnabled = true;
  bool get smcEnabled => _smcEnabled;
  set smcEnabled(bool v) {
    if (v == _smcEnabled) return;
    _smcEnabled = v;
    rebalanceAnalyseSectionImpacts();
    notifyListeners();
  }

  String _notesSmc = '';
  String get notesSmc => _notesSmc;
  set notesSmc(String v) {
    if (v == _notesSmc) return;
    _notesSmc = v;
    notifyListeners();
  }

  final List<AnalyseSmcSnapshot> _smcSnapshots = <AnalyseSmcSnapshot>[];

  List<AnalyseSmcSnapshot> get smcSnapshots => List.unmodifiable(_smcSnapshots);

  void duplicateSmc() {
    _smcSnapshots.add(
      AnalyseSmcSnapshot(
        smcTf: _smcTf,
        smcZone: _smcZone,
        smcFvg: _smcFvg,
        smcLiquidityPools: _smcLiquidityPools,
        smcFibLevel: _smcFibLevel,
        smcFibPrice: _smcFibPrice,
        notesSmc: _notesSmc,
        extraFields: _smcMergedExtraFields(),
      ),
    );
    notifyListeners();
  }

  void removeSmcSnapshot(int index) {
    if (index < 0 || index >= _smcSnapshots.length) return;
    _smcSnapshots.removeAt(index);
    notifyListeners();
  }

  void _mutateSmcSnapshot(
    int index,
    AnalyseSmcSnapshot Function(AnalyseSmcSnapshot s) f,
  ) {
    if (index < 0 || index >= _smcSnapshots.length) return;
    _smcSnapshots[index] = f(_smcSnapshots[index]);
    notifyListeners();
  }

  void setSmcSnapshotTf(int index, String tf) {
    final nv = tf.trim();
    if (nv.isEmpty) return;
    _mutateSmcSnapshot(index, (s) {
      if (s.smcTf == nv) return s;
      return s.copyWith(smcTf: nv);
    });
  }

  void addSmcSnapshotTfCustom(int index, String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    registerSmcTfCustom(v);
    setSmcSnapshotTf(index, v);
  }

  void setSmcSnapshotZone(int index, String v) {
    _mutateSmcSnapshot(index, (s) {
      if (s.smcZone == v) return s;
      return s.copyWith(smcZone: v);
    });
  }

  void setSmcSnapshotFvg(int index, String v) {
    _mutateSmcSnapshot(index, (s) {
      if (s.smcFvg == v) return s;
      return s.copyWith(smcFvg: v);
    });
  }

  void setSmcSnapshotLiquidityPools(int index, String v) {
    _mutateSmcSnapshot(index, (s) {
      if (s.smcLiquidityPools == v) return s;
      return s.copyWith(smcLiquidityPools: v);
    });
  }

  void setSmcSnapshotFibLevel(int index, String? v) {
    _mutateSmcSnapshot(index, (s) {
      if (s.smcFibLevel == v) return s;
      return s.withFibLevel(v);
    });
  }

  void setSmcSnapshotFibPrice(int index, String v) {
    _mutateSmcSnapshot(index, (s) {
      if (s.smcFibPrice == v) return s;
      return s.copyWith(smcFibPrice: v);
    });
  }

  void setSmcSnapshotNotes(int index, String v) {
    _mutateSmcSnapshot(index, (s) {
      if (s.notesSmc == v) return s;
      return s.copyWith(notesSmc: v);
    });
  }

  void updateSmcSnapshotExtraField(int snapshotIndex, int fieldIndex, String v) {
    _mutateSmcSnapshot(snapshotIndex, (s) {
      if (fieldIndex < 0 || fieldIndex >= s.extraFields.length) return s;
      final list = List<String>.from(s.extraFields);
      if (list[fieldIndex] == v) return s;
      list[fieldIndex] = v;
      return s.copyWith(extraFields: list);
    });
  }

  void addSmcSnapshotExtraField(int snapshotIndex) {
    _mutateSmcSnapshot(snapshotIndex, (s) {
      final list = List<String>.from(s.extraFields)..add('');
      return s.copyWith(extraFields: list);
    });
  }

  void removeSmcSnapshotExtraField(int snapshotIndex, int fieldIndex) {
    _mutateSmcSnapshot(snapshotIndex, (s) {
      if (fieldIndex < 0 || fieldIndex >= s.extraFields.length) return s;
      final list = List<String>.from(s.extraFields)..removeAt(fieldIndex);
      return s.copyWith(extraFields: list);
    });
  }

  bool _volumeProfileEnabled = true;
  bool get volumeProfileEnabled => _volumeProfileEnabled;
  set volumeProfileEnabled(bool v) {
    if (v == _volumeProfileEnabled) return;
    _volumeProfileEnabled = v;
    notifyListeners();
  }

  /// Libellé du type de profil (legacy / démo) — l’UI utilise [volumeProfileTf] + zone.
  String _volumeProfileModeLabel = 'Volume profile';
  String get volumeProfileModeLabel => _volumeProfileModeLabel;
  set volumeProfileModeLabel(String v) {
    final t = v.trim();
    final nv = t.isEmpty ? 'Volume profile' : t;
    if (nv == _volumeProfileModeLabel) return;
    _volumeProfileModeLabel = nv;
    notifyListeners();
  }

  String _volumeProfileTf = AnalyseStructureChartTf.daily.label;
  final List<String> _volumeProfileTfCustom = <String>[];

  String get volumeProfileTf => _volumeProfileTf;
  set volumeProfileTf(String v) {
    final nv = v.trim();
    if (nv.isEmpty || nv == _volumeProfileTf) return;
    _volumeProfileTf = nv;
    notifyListeners();
  }

  List<String> get volumeProfileTfCustom => List.unmodifiable(_volumeProfileTfCustom);

  void addVolumeProfileTfCustom(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (_volumeProfileTfCustom.contains(v)) return;
    _volumeProfileTfCustom.add(v);
    _volumeProfileTf = v;
    notifyListeners();
  }

  bool _volumeProfileZoneActive = false;
  bool get volumeProfileZoneActive => _volumeProfileZoneActive;
  set volumeProfileZoneActive(bool v) {
    if (v == _volumeProfileZoneActive) return;
    _volumeProfileZoneActive = v;
    notifyListeners();
  }

  String _volumeProfileZoneFrom = '';
  String get volumeProfileZoneFrom => _volumeProfileZoneFrom;
  set volumeProfileZoneFrom(String v) {
    if (v == _volumeProfileZoneFrom) return;
    _volumeProfileZoneFrom = v;
    notifyListeners();
  }

  String _volumeProfileZoneTo = '';
  String get volumeProfileZoneTo => _volumeProfileZoneTo;
  set volumeProfileZoneTo(String v) {
    if (v == _volumeProfileZoneTo) return;
    _volumeProfileZoneTo = v;
    notifyListeners();
  }

  String _volumeProfilePoc = '';
  String get volumeProfilePoc => _volumeProfilePoc;
  set volumeProfilePoc(String v) {
    if (v == _volumeProfilePoc) return;
    _volumeProfilePoc = v;
    notifyListeners();
  }

  String _volumeProfileVah = '';
  String get volumeProfileVah => _volumeProfileVah;
  set volumeProfileVah(String v) {
    if (v == _volumeProfileVah) return;
    _volumeProfileVah = v;
    notifyListeners();
  }

  String _volumeProfileVal = '';
  String get volumeProfileVal => _volumeProfileVal;
  set volumeProfileVal(String v) {
    if (v == _volumeProfileVal) return;
    _volumeProfileVal = v;
    notifyListeners();
  }

  String _notesVolumeProfile = '';
  String get notesVolumeProfile => _notesVolumeProfile;
  set notesVolumeProfile(String v) {
    if (v == _notesVolumeProfile) return;
    _notesVolumeProfile = v;
    notifyListeners();
  }

  AnalyseSmcSnapshot _blankSmcSnapshot() {
    return AnalyseSmcSnapshot(
      smcTf: AnalyseStructureChartTf.h1.label,
      smcZone: '',
      smcFvg: '',
      smcLiquidityPools: '',
      smcFibLevel: '0.618',
      smcFibPrice: '',
      notesSmc: '',
      extraFields: const [],
    );
  }

  void resetSmcVolumeMainAfterValidation() {
    _smcZone = '';
    _smcFvg = '';
    _smcLiquidityPools = '';
    _smcFibLevel = '0.618';
    _smcFibPrice = '';
    _smcTf = AnalyseStructureChartTf.h1.label;
    _notesSmc = '';
    _smcExtraFields.clear();
    _smcZoneExtras.clear();
    _smcFvgExtras.clear();
    _smcLiquidityExtras.clear();
    _volumeProfilePoc = '';
    _volumeProfileVah = '';
    _volumeProfileVal = '';
    _notesVolumeProfile = '';
    _volumeProfileModeLabel = 'Volume profile';
    _volumeProfileTf = AnalyseStructureChartTf.daily.label;
    _volumeProfileZoneActive = false;
    _volumeProfileZoneFrom = '';
    _volumeProfileZoneTo = '';
    notifyListeners();
  }

  void resetSmcCopiesAfterValidation() {
    for (var i = 0; i < _smcSnapshots.length; i++) {
      _smcSnapshots[i] = _blankSmcSnapshot();
    }
    notifyListeners();
  }

  void replaceSmcSnapshots(List<AnalyseSmcSnapshot> next) {
    _smcSnapshots
      ..clear()
      ..addAll(next);
    notifyListeners();
  }
}
