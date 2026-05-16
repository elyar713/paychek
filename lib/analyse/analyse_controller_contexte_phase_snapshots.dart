part of 'analyse_controller.dart';

/// Phase + blocs dupliqués (snapshots). Chaîner après [AnalyseControllerContexteFields].
mixin AnalyseControllerContextePhaseSnapshots on AnalyseControllerContexteFields {
  ContextePick<AnalysePhase> _phasePick =
      const ContextePick.enumOf(AnalysePhase.impulsion);
  ContextePick<AnalysePhase> get phasePick => _phasePick;
  set phasePick(ContextePick<AnalysePhase> v) {
    if (v == _phasePick) return;
    _phasePick = v;
    notifyListeners();
  }

  final Set<AnalysePhase> _phasePillsVisible =
      Set<AnalysePhase>.from(AnalysePhase.values);

  final List<String> _phaseCustomLabels = <String>[];

  List<String> get phaseCustomLabels => List.unmodifiable(_phaseCustomLabels);

  List<AnalysePhase> get phasePillsVisibleOrdered => AnalysePhase.values
      .where((AnalysePhase p) => _phasePillsVisible.contains(p))
      .toList();

  bool isPhasePillVisible(AnalysePhase p) => _phasePillsVisible.contains(p);

  void togglePhasePill(AnalysePhase p) {
    if (_phasePillsVisible.contains(p) && _phasePillsVisible.length <= 1) return;
    if (_phasePillsVisible.contains(p)) {
      _phasePillsVisible.remove(p);
      if (_phasePick.enumVal == p) {
        _phasePick = ContextePick.enumOf(phasePillsVisibleOrdered.first);
      }
    } else {
      _phasePillsVisible.add(p);
    }
    if (_phasePick.isEnum && !_phasePillsVisible.contains(_phasePick.enumVal!)) {
      _phasePick = ContextePick.enumOf(phasePillsVisibleOrdered.first);
    }
    notifyListeners();
  }

  void addPhaseCustomLabel(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return;
    if (_phaseCustomLabels.contains(s)) return;
    _phaseCustomLabels.add(s);
    _phasePick = ContextePick.customLabel(s);
    notifyListeners();
  }

  void removePhaseCustomLabel(String s) {
    if (!_phaseCustomLabels.remove(s)) return;
    if (_phasePick.custom == s) {
      _phasePick = ContextePick.enumOf(phasePillsVisibleOrdered.first);
    }
    notifyListeners();
  }

  final List<AnalyseContexteTendanceSnapshot> _contexteSnapshots =
      <AnalyseContexteTendanceSnapshot>[];
  List<AnalyseContexteTendanceSnapshot> get contexteSnapshots =>
      List.unmodifiable(_contexteSnapshots);

  /// Ajoute un bloc sous les puces avec les valeurs actuelles (direction, TF, tendance, phase).
  void duplicateContexteTendance() {
    _contexteSnapshots.add(
      AnalyseContexteTendanceSnapshot(
        bias: _bias,
        htfVisibleEnums: Set<AnalyseTimeframe>.from(_htfPillsVisible),
        htfCustomLabels: List<String>.from(_htfCustomLabels),
        htfPick: _htfPick,
        trendVisibleEnums: Set<AnalyseLocalTrend>.from(_trendPillsVisible),
        trendCustomLabels: List<String>.from(_trendCustomLabels),
        trendPick: _localTrendPick,
        phaseVisibleEnums: Set<AnalysePhase>.from(_phasePillsVisible),
        phaseCustomLabels: List<String>.from(_phaseCustomLabels),
        phasePick: _phasePick,
      ),
    );
    notifyListeners();
  }

  void removeContexteSnapshot(int index) {
    if (index < 0 || index >= _contexteSnapshots.length) return;
    _contexteSnapshots.removeAt(index);
    notifyListeners();
  }

  void preparePhasePillsForApplyFromReport() {
    _phaseCustomLabels.clear();
    _phasePillsVisible
      ..clear()
      ..addAll(AnalysePhase.values);
    notifyListeners();
  }

  AnalyseContexteTendanceSnapshot _blankContexteSnapshot() {
    return AnalyseContexteTendanceSnapshot(
      bias: AnalyseDirectionBias.surveiller,
      htfVisibleEnums: Set<AnalyseTimeframe>.from(AnalyseTimeframe.values),
      htfCustomLabels: const [],
      htfPick: const ContextePick.enumOf(AnalyseTimeframe.daily),
      trendVisibleEnums: Set<AnalyseLocalTrend>.from(AnalyseLocalTrend.values),
      trendCustomLabels: const [],
      trendPick: const ContextePick.enumOf(AnalyseLocalTrend.haussiere),
      phaseVisibleEnums: Set<AnalysePhase>.from(AnalysePhase.values),
      phaseCustomLabels: const [],
      phasePick: const ContextePick.enumOf(AnalysePhase.impulsion),
    );
  }

  /// Après validation : phase + pilules phase par défaut ; copies contexte conservées mais vidées.
  void resetPhaseAndContexteCopiesAfterValidation() {
    _phaseCustomLabels.clear();
    _phasePillsVisible
      ..clear()
      ..addAll(AnalysePhase.values);
    _phasePick = const ContextePick.enumOf(AnalysePhase.impulsion);
    for (var i = 0; i < _contexteSnapshots.length; i++) {
      _contexteSnapshots[i] = _blankContexteSnapshot();
    }
    notifyListeners();
  }

  /// Remplace la liste des copies contexte (ex. restauration depuis le rapport).
  void replaceContexteSnapshots(List<AnalyseContexteTendanceSnapshot> next) {
    _contexteSnapshots
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  void _mutateContexteSnapshot(
    int index,
    AnalyseContexteTendanceSnapshot Function(AnalyseContexteTendanceSnapshot s)
        f,
  ) {
    if (index < 0 || index >= _contexteSnapshots.length) return;
    _contexteSnapshots[index] = f(_contexteSnapshots[index]);
    notifyListeners();
  }

  void setContexteSnapshotBias(int index, AnalyseDirectionBias v) {
    _mutateContexteSnapshot(index, (s) => s.copyWith(bias: v));
  }

  void setContexteSnapshotHtfPick(int index, ContextePick<AnalyseTimeframe> v) {
    _mutateContexteSnapshot(index, (s) => s.copyWith(htfPick: v));
  }

  void toggleContexteSnapshotHtfPill(int index, AnalyseTimeframe t) {
    _mutateContexteSnapshot(index, (s) {
      var vis = Set<AnalyseTimeframe>.from(s.htfVisibleEnums);
      var pick = s.htfPick;
      if (vis.contains(t) && vis.length <= 1) return s;
      if (vis.contains(t)) {
        vis.remove(t);
        if (pick.enumVal == t) {
          pick = ContextePick.enumOf(
            AnalyseTimeframe.values.where((e) => vis.contains(e)).first,
          );
        }
      } else {
        vis.add(t);
      }
      if (pick.isEnum && !vis.contains(pick.enumVal!)) {
        pick = ContextePick.enumOf(
          AnalyseTimeframe.values.where((e) => vis.contains(e)).first,
        );
      }
      return s.copyWith(htfVisibleEnums: vis, htfPick: pick);
    });
  }

  void addContexteSnapshotHtfCustomLabel(int index, String raw) {
    final label = raw.trim();
    if (label.isEmpty) return;
    _mutateContexteSnapshot(index, (s) {
      final list = List<String>.from(s.htfCustomLabels);
      if (list.contains(label)) return s;
      list.add(label);
      return s.copyWith(
        htfCustomLabels: list,
        htfPick: ContextePick.customLabel(label),
      );
    });
  }

  void removeContexteSnapshotHtfCustomLabel(int index, String label) {
    _mutateContexteSnapshot(index, (s) {
      final list = List<String>.from(s.htfCustomLabels);
      if (!list.remove(label)) return s;
      var pick = s.htfPick;
      if (pick.custom == label) {
        pick = ContextePick.enumOf(
          AnalyseTimeframe.values
              .where((e) => s.htfVisibleEnums.contains(e))
              .first,
        );
      }
      return s.copyWith(htfCustomLabels: list, htfPick: pick);
    });
  }

  void setContexteSnapshotTrendPick(
    int index,
    ContextePick<AnalyseLocalTrend> v,
  ) {
    _mutateContexteSnapshot(index, (s) => s.copyWith(trendPick: v));
  }

  void toggleContexteSnapshotTrendPill(int index, AnalyseLocalTrend t) {
    _mutateContexteSnapshot(index, (s) {
      var vis = Set<AnalyseLocalTrend>.from(s.trendVisibleEnums);
      var pick = s.trendPick;
      if (vis.contains(t) && vis.length <= 1) return s;
      if (vis.contains(t)) {
        vis.remove(t);
        if (pick.enumVal == t) {
          pick = ContextePick.enumOf(
            AnalyseLocalTrend.values.where((e) => vis.contains(e)).first,
          );
        }
      } else {
        vis.add(t);
      }
      if (pick.isEnum && !vis.contains(pick.enumVal!)) {
        pick = ContextePick.enumOf(
          AnalyseLocalTrend.values.where((e) => vis.contains(e)).first,
        );
      }
      return s.copyWith(trendVisibleEnums: vis, trendPick: pick);
    });
  }

  void addContexteSnapshotTrendCustomLabel(int index, String raw) {
    final label = raw.trim();
    if (label.isEmpty) return;
    _mutateContexteSnapshot(index, (s) {
      final list = List<String>.from(s.trendCustomLabels);
      if (list.contains(label)) return s;
      list.add(label);
      return s.copyWith(
        trendCustomLabels: list,
        trendPick: ContextePick.customLabel(label),
      );
    });
  }

  void removeContexteSnapshotTrendCustomLabel(int index, String label) {
    _mutateContexteSnapshot(index, (s) {
      final list = List<String>.from(s.trendCustomLabels);
      if (!list.remove(label)) return s;
      var pick = s.trendPick;
      if (pick.custom == label) {
        pick = ContextePick.enumOf(
          AnalyseLocalTrend.values
              .where((e) => s.trendVisibleEnums.contains(e))
              .first,
        );
      }
      return s.copyWith(trendCustomLabels: list, trendPick: pick);
    });
  }

  void setContexteSnapshotPhasePick(int index, ContextePick<AnalysePhase> v) {
    _mutateContexteSnapshot(index, (s) => s.copyWith(phasePick: v));
  }

  void toggleContexteSnapshotPhasePill(int index, AnalysePhase p) {
    _mutateContexteSnapshot(index, (s) {
      var vis = Set<AnalysePhase>.from(s.phaseVisibleEnums);
      var pick = s.phasePick;
      if (vis.contains(p) && vis.length <= 1) return s;
      if (vis.contains(p)) {
        vis.remove(p);
        if (pick.enumVal == p) {
          pick = ContextePick.enumOf(
            AnalysePhase.values.where((e) => vis.contains(e)).first,
          );
        }
      } else {
        vis.add(p);
      }
      if (pick.isEnum && !vis.contains(pick.enumVal!)) {
        pick = ContextePick.enumOf(
          AnalysePhase.values.where((e) => vis.contains(e)).first,
        );
      }
      return s.copyWith(phaseVisibleEnums: vis, phasePick: pick);
    });
  }

  void addContexteSnapshotPhaseCustomLabel(int index, String raw) {
    final label = raw.trim();
    if (label.isEmpty) return;
    _mutateContexteSnapshot(index, (s) {
      final list = List<String>.from(s.phaseCustomLabels);
      if (list.contains(label)) return s;
      list.add(label);
      return s.copyWith(
        phaseCustomLabels: list,
        phasePick: ContextePick.customLabel(label),
      );
    });
  }

  void removeContexteSnapshotPhaseCustomLabel(int index, String label) {
    _mutateContexteSnapshot(index, (s) {
      final list = List<String>.from(s.phaseCustomLabels);
      if (!list.remove(label)) return s;
      var pick = s.phasePick;
      if (pick.custom == label) {
        pick = ContextePick.enumOf(
          AnalysePhase.values
              .where((e) => s.phaseVisibleEnums.contains(e))
              .first,
        );
      }
      return s.copyWith(phaseCustomLabels: list, phasePick: pick);
    });
  }
}
