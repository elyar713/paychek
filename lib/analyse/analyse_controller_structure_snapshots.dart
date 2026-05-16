part of 'analyse_controller_structure_smc.dart';

/// Mutations des [AnalyseStructureSnapshot] (copies Structure).
mixin AnalyseControllerStructureSnapshots on AnalyseControllerStructureFields {
  void _mutateStructureSnapshot(
    int index,
    AnalyseStructureSnapshot Function(AnalyseStructureSnapshot s) f,
  ) {
    if (index < 0 || index >= _structureSnapshots.length) return;
    _structureSnapshots[index] = f(_structureSnapshots[index]);
    notifyListeners();
  }

  void setStructureSnapshotTf(int index, String tf) {
    final nv = tf.trim();
    if (nv.isEmpty) return;
    _mutateStructureSnapshot(index, (s) => s.copyWith(structureTf: nv));
  }

  void addStructureSnapshotTfCustom(int index, String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    registerStructureTfCustom(v);
    setStructureSnapshotTf(index, v);
  }

  void setStructureSnapshotDernierPoint(int index, String v) {
    _mutateStructureSnapshot(index, (s) => s.copyWith(dernierPoint: v));
  }

  void setStructureSnapshotSupportMaj(int index, String v) {
    _mutateStructureSnapshot(index, (s) => s.copyWith(structureSupportMaj: v));
  }

  void setStructureSnapshotResistanceMaj(int index, String v) {
    _mutateStructureSnapshot(
      index,
      (s) => s.copyWith(structureResistanceMaj: v),
    );
  }

  void setStructureSnapshotSupportTested(int index, bool v) {
    _mutateStructureSnapshot(
      index,
      (s) => s.copyWith(structureSupportTested: v),
    );
  }

  void setStructureSnapshotResistanceTested(int index, bool v) {
    _mutateStructureSnapshot(
      index,
      (s) => s.copyWith(structureResistanceTested: v),
    );
  }

  void addStructureSnapshotExtraSupport(int index) {
    _mutateStructureSnapshot(index, (s) {
      final list = [
        for (final e in s.extraSupports)
          AnalyseStructureExtraLevel(price: e.price, tenue: e.tenue),
        AnalyseStructureExtraLevel(price: ''),
      ];
      return s.copyWith(extraSupports: list);
    });
  }

  void addStructureSnapshotExtraResistance(int index) {
    _mutateStructureSnapshot(index, (s) {
      final list = [
        for (final e in s.extraResistances)
          AnalyseStructureExtraLevel(price: e.price, tenue: e.tenue),
        AnalyseStructureExtraLevel(price: ''),
      ];
      return s.copyWith(extraResistances: list);
    });
  }

  void updateStructureSnapshotExtraSupport(int snapIdx, int lineIdx, String price) {
    _mutateStructureSnapshot(snapIdx, (s) {
      if (lineIdx < 0 || lineIdx >= s.extraSupports.length) return s;
      final list = <AnalyseStructureExtraLevel>[
        for (var j = 0; j < s.extraSupports.length; j++)
          j == lineIdx
              ? AnalyseStructureExtraLevel(
                  price: price,
                  tenue: s.extraSupports[j].tenue,
                )
              : AnalyseStructureExtraLevel(
                  price: s.extraSupports[j].price,
                  tenue: s.extraSupports[j].tenue,
                ),
      ];
      return s.copyWith(extraSupports: list);
    });
  }

  void updateStructureSnapshotExtraSupportTenue(
    int snapIdx,
    int lineIdx,
    AnalyseStructureTenue? tenue,
  ) {
    _mutateStructureSnapshot(snapIdx, (s) {
      if (lineIdx < 0 || lineIdx >= s.extraSupports.length) return s;
      final list = <AnalyseStructureExtraLevel>[
        for (var j = 0; j < s.extraSupports.length; j++)
          j == lineIdx
              ? AnalyseStructureExtraLevel(
                  price: s.extraSupports[j].price,
                  tenue: tenue,
                )
              : AnalyseStructureExtraLevel(
                  price: s.extraSupports[j].price,
                  tenue: s.extraSupports[j].tenue,
                ),
      ];
      return s.copyWith(extraSupports: list);
    });
  }

  void updateStructureSnapshotExtraResistance(
    int snapIdx,
    int lineIdx,
    String price,
  ) {
    _mutateStructureSnapshot(snapIdx, (s) {
      if (lineIdx < 0 || lineIdx >= s.extraResistances.length) return s;
      final list = <AnalyseStructureExtraLevel>[
        for (var j = 0; j < s.extraResistances.length; j++)
          j == lineIdx
              ? AnalyseStructureExtraLevel(
                  price: price,
                  tenue: s.extraResistances[j].tenue,
                )
              : AnalyseStructureExtraLevel(
                  price: s.extraResistances[j].price,
                  tenue: s.extraResistances[j].tenue,
                ),
      ];
      return s.copyWith(extraResistances: list);
    });
  }

  void updateStructureSnapshotExtraResistanceTenue(
    int snapIdx,
    int lineIdx,
    AnalyseStructureTenue? tenue,
  ) {
    _mutateStructureSnapshot(snapIdx, (s) {
      if (lineIdx < 0 || lineIdx >= s.extraResistances.length) return s;
      final list = <AnalyseStructureExtraLevel>[
        for (var j = 0; j < s.extraResistances.length; j++)
          j == lineIdx
              ? AnalyseStructureExtraLevel(
                  price: s.extraResistances[j].price,
                  tenue: tenue,
                )
              : AnalyseStructureExtraLevel(
                  price: s.extraResistances[j].price,
                  tenue: s.extraResistances[j].tenue,
                ),
      ];
      return s.copyWith(extraResistances: list);
    });
  }

  void removeStructureSnapshotExtraSupport(int snapIdx, int lineIdx) {
    _mutateStructureSnapshot(snapIdx, (s) {
      if (lineIdx < 0 || lineIdx >= s.extraSupports.length) return s;
      final list = <AnalyseStructureExtraLevel>[
        for (var j = 0; j < s.extraSupports.length; j++)
          if (j != lineIdx)
            AnalyseStructureExtraLevel(
              price: s.extraSupports[j].price,
              tenue: s.extraSupports[j].tenue,
            ),
      ];
      return s.copyWith(extraSupports: list);
    });
  }

  void removeStructureSnapshotExtraResistance(int snapIdx, int lineIdx) {
    _mutateStructureSnapshot(snapIdx, (s) {
      if (lineIdx < 0 || lineIdx >= s.extraResistances.length) return s;
      final list = <AnalyseStructureExtraLevel>[
        for (var j = 0; j < s.extraResistances.length; j++)
          if (j != lineIdx)
            AnalyseStructureExtraLevel(
              price: s.extraResistances[j].price,
              tenue: s.extraResistances[j].tenue,
            ),
      ];
      return s.copyWith(extraResistances: list);
    });
  }
}
