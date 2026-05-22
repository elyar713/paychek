part of 'analyse_controller.dart';

DateTime _calendarDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _sameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Champs HTF / tendance / méta (date, biais, notes). Utiliser avec
/// [AnalyseControllerContextePhaseSnapshots] puis [AnalyseControllerContexte].
mixin AnalyseControllerContexteFields on ChangeNotifier {
  bool _contextEnabled = true;
  bool get contextEnabled => _contextEnabled;
  set contextEnabled(bool v) {
    if (v == _contextEnabled) return;
    _contextEnabled = v;
    rebalanceAnalyseSectionImpacts();
    notifyListeners();
  }

  DateTime _contexteAnalyseDate = _calendarDateOnly(DateTime.now());

  DateTime get contexteAnalyseDate => _contexteAnalyseDate;
  set contexteAnalyseDate(DateTime v) {
    final next = _calendarDateOnly(v);
    if (_sameCalendarDay(_contexteAnalyseDate, next)) return;
    _contexteAnalyseDate = next;
    notifyListeners();
  }

  String get contexteAnalyseDateLabel {
    final d = _contexteAnalyseDate;
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  AnalyseDirectionBias _bias = AnalyseDirectionBias.surveiller;
  AnalyseDirectionBias get bias => _bias;
  set bias(AnalyseDirectionBias v) {
    if (v == _bias) return;
    _bias = v;
    notifyListeners();
  }

  ContextePick<AnalyseTimeframe> _htfPick =
      const ContextePick.enumOf(AnalyseTimeframe.daily);
  ContextePick<AnalyseTimeframe> get htfPick => _htfPick;
  set htfPick(ContextePick<AnalyseTimeframe> v) {
    if (v == _htfPick) return;
    _htfPick = v;
    notifyListeners();
  }

  final Set<AnalyseTimeframe> _htfPillsVisible =
      Set<AnalyseTimeframe>.from(AnalyseTimeframe.values);

  final List<String> _htfCustomLabels = <String>[];

  List<String> get htfCustomLabels => List.unmodifiable(_htfCustomLabels);

  List<AnalyseTimeframe> get htfPillsVisibleOrdered => AnalyseTimeframe.values
      .where((AnalyseTimeframe e) => _htfPillsVisible.contains(e))
      .toList();

  int get htfTotalPillCount => _htfPillsVisible.length + _htfCustomLabels.length;

  bool isHtfPillVisible(AnalyseTimeframe t) => _htfPillsVisible.contains(t);

  ContextePick<AnalyseTimeframe> _firstAvailableHtfPick() {
    if (htfPillsVisibleOrdered.isNotEmpty) {
      return ContextePick.enumOf(htfPillsVisibleOrdered.first);
    }
    if (_htfCustomLabels.isNotEmpty) {
      return ContextePick.customLabel(_htfCustomLabels.first);
    }
    return const ContextePick.enumOf(AnalyseTimeframe.daily);
  }

  void toggleHtfPill(AnalyseTimeframe t) {
    if (_htfPillsVisible.contains(t) && htfTotalPillCount <= 1) return;
    if (_htfPillsVisible.contains(t)) {
      _htfPillsVisible.remove(t);
      if (_htfPick.enumVal == t) {
        _htfPick = _firstAvailableHtfPick();
      }
    } else {
      _htfPillsVisible.add(t);
    }
    if (_htfPick.isEnum && !_htfPillsVisible.contains(_htfPick.enumVal!)) {
      _htfPick = _firstAvailableHtfPick();
    }
    notifyListeners();
  }

  void addHtfCustomLabel(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return;
    if (_htfCustomLabels.contains(s)) return;
    _htfCustomLabels.add(s);
    _htfPick = ContextePick.customLabel(s);
    notifyListeners();
  }

  void removeHtfCustomLabel(String s) {
    if (htfTotalPillCount <= 1) return;
    if (!_htfCustomLabels.remove(s)) return;
    if (_htfPick.custom == s) {
      _htfPick = _firstAvailableHtfPick();
    }
    notifyListeners();
  }

  ContextePick<AnalyseLocalTrend> _localTrendPick =
      const ContextePick.enumOf(AnalyseLocalTrend.haussiere);
  ContextePick<AnalyseLocalTrend> get localTrendPick => _localTrendPick;
  set localTrendPick(ContextePick<AnalyseLocalTrend> v) {
    if (v == _localTrendPick) return;
    _localTrendPick = v;
    notifyListeners();
  }

  final Set<AnalyseLocalTrend> _trendPillsVisible =
      Set<AnalyseLocalTrend>.from(AnalyseLocalTrend.values);

  final List<String> _trendCustomLabels = <String>[];

  List<String> get trendCustomLabels => List.unmodifiable(_trendCustomLabels);

  List<AnalyseLocalTrend> get trendPillsVisibleOrdered =>
      AnalyseLocalTrend.values
          .where((AnalyseLocalTrend e) => _trendPillsVisible.contains(e))
          .toList();

  bool isTrendPillVisible(AnalyseLocalTrend t) =>
      _trendPillsVisible.contains(t);

  void toggleTrendPill(AnalyseLocalTrend t) {
    if (_trendPillsVisible.contains(t) && _trendPillsVisible.length <= 1) {
      return;
    }
    if (_trendPillsVisible.contains(t)) {
      _trendPillsVisible.remove(t);
      if (_localTrendPick.enumVal == t) {
        _localTrendPick =
            ContextePick.enumOf(trendPillsVisibleOrdered.first);
      }
    } else {
      _trendPillsVisible.add(t);
    }
    if (_localTrendPick.isEnum &&
        !_trendPillsVisible.contains(_localTrendPick.enumVal!)) {
      _localTrendPick =
          ContextePick.enumOf(trendPillsVisibleOrdered.first);
    }
    notifyListeners();
  }

  void addTrendCustomLabel(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return;
    if (_trendCustomLabels.contains(s)) return;
    _trendCustomLabels.add(s);
    _localTrendPick = ContextePick.customLabel(s);
    notifyListeners();
  }

  void removeTrendCustomLabel(String s) {
    if (!_trendCustomLabels.remove(s)) return;
    if (_localTrendPick.custom == s) {
      _localTrendPick =
          ContextePick.enumOf(trendPillsVisibleOrdered.first);
    }
    notifyListeners();
  }

  String _notesTimeframe = '';
  String get notesTimeframe => _notesTimeframe;
  set notesTimeframe(String v) {
    if (v == _notesTimeframe) return;
    _notesTimeframe = v;
    notifyListeners();
  }

  String _analyseActif = '';
  String get analyseActif => _analyseActif;
  set analyseActif(String v) {
    if (v == _analyseActif) return;
    _analyseActif = v;
    notifyListeners();
  }

  String _nomAnalyse = '';
  String get nomAnalyse => _nomAnalyse;
  set nomAnalyse(String v) {
    if (v == _nomAnalyse) return;
    _nomAnalyse = v;
    notifyListeners();
  }

  /// Après validation du rapport : zone Tendance principale (texte + pilules par défaut).
  void resetContexteMainAfterValidation() {
    _analyseActif = '';
    _nomAnalyse = '';
    _notesTimeframe = '';
    _bias = AnalyseDirectionBias.surveiller;
    _contexteAnalyseDate = _calendarDateOnly(DateTime.now());
    _htfCustomLabels.clear();
    _htfPillsVisible
      ..clear()
      ..addAll(AnalyseTimeframe.values);
    _htfPick = const ContextePick.enumOf(AnalyseTimeframe.daily);
    _trendCustomLabels.clear();
    _trendPillsVisible
      ..clear()
      ..addAll(AnalyseLocalTrend.values);
    _localTrendPick = const ContextePick.enumOf(AnalyseLocalTrend.haussiere);
    notifyListeners();
  }

  /// Avant restauration depuis le rapport : toutes les pilules enum visibles, customs effacés.
  void prepareContextePillsForApplyFromReport() {
    _htfCustomLabels.clear();
    _htfPillsVisible
      ..clear()
      ..addAll(AnalyseTimeframe.values);
    _trendCustomLabels.clear();
    _trendPillsVisible
      ..clear()
      ..addAll(AnalyseLocalTrend.values);
    notifyListeners();
  }
}
