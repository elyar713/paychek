part of 'analyse_controller.dart';

const String _kFeuilleContextePillsTemplatesBundleKeyBase =
    'analyse_feuille_contexte_pills_templates_v2';
String get _kFeuilleContextePillsTemplatesBundleKey =>
    paychekScopedPrefsKey(_kFeuilleContextePillsTemplatesBundleKeyBase);

/// Persistance des modèles de puces (SharedPreferences). Chaîner après
/// [AnalyseControllerContextePhaseSnapshots].
mixin AnalyseControllerContexte on AnalyseControllerContextePhaseSnapshots {
  Map<String, dynamic> _serializeFeuilleContextePillsTemplate() => {
        'v': 1,
        'htfVis': _htfPillsVisible.map((e) => e.name).toList(),
        'htfCust': List<String>.from(_htfCustomLabels),
        'htfPick': _htfPick.isEnum
            ? {'t': 'e', 'n': _htfPick.enumVal!.name}
            : {'t': 'c', 'v': _htfPick.custom ?? ''},
        'trVis': _trendPillsVisible.map((e) => e.name).toList(),
        'trCust': List<String>.from(_trendCustomLabels),
        'trPick': _localTrendPick.isEnum
            ? {'t': 'e', 'n': _localTrendPick.enumVal!.name}
            : {'t': 'c', 'v': _localTrendPick.custom ?? ''},
        'phVis': _phasePillsVisible.map((e) => e.name).toList(),
        'phCust': List<String>.from(_phaseCustomLabels),
        'phPick': _phasePick.isEnum
            ? {'t': 'e', 'n': _phasePick.enumVal!.name}
            : {'t': 'c', 'v': _phasePick.custom ?? ''},
      };

  ContextePick<AnalyseTimeframe> _parseHtfPickMap(Map<String, dynamic>? m) {
    if (m == null) {
      return const ContextePick.enumOf(AnalyseTimeframe.daily);
    }
    if (m['t'] == 'e' && m['n'] is String) {
      try {
        return ContextePick.enumOf(
          AnalyseTimeframe.values.byName(m['n'] as String),
        );
      } catch (_) {}
    }
    if (m['t'] == 'c' && m['v'] is String) {
      return ContextePick.customLabel(m['v'] as String);
    }
    return const ContextePick.enumOf(AnalyseTimeframe.daily);
  }

  ContextePick<AnalyseLocalTrend> _parseTrendPickMap(Map<String, dynamic>? m) {
    if (m == null) {
      return const ContextePick.enumOf(AnalyseLocalTrend.haussiere);
    }
    if (m['t'] == 'e' && m['n'] is String) {
      try {
        return ContextePick.enumOf(
          AnalyseLocalTrend.values.byName(m['n'] as String),
        );
      } catch (_) {}
    }
    if (m['t'] == 'c' && m['v'] is String) {
      return ContextePick.customLabel(m['v'] as String);
    }
    return const ContextePick.enumOf(AnalyseLocalTrend.haussiere);
  }

  ContextePick<AnalysePhase> _parsePhasePickMap(Map<String, dynamic>? m) {
    if (m == null) {
      return const ContextePick.enumOf(AnalysePhase.impulsion);
    }
    if (m['t'] == 'e' && m['n'] is String) {
      try {
        return ContextePick.enumOf(
          AnalysePhase.values.byName(m['n'] as String),
        );
      } catch (_) {}
    }
    if (m['t'] == 'c' && m['v'] is String) {
      return ContextePick.customLabel(m['v'] as String);
    }
    return const ContextePick.enumOf(AnalysePhase.impulsion);
  }

  void _applyFeuilleContextePillsTemplate(Map<String, dynamic> root) {
    if (root['v'] != 1) return;

    final htfNames = (root['htfVis'] as List?)?.cast<String>() ?? [];
    final htfCust = (root['htfCust'] as List?)?.cast<String>() ?? [];
    var htfVis = <AnalyseTimeframe>{};
    for (final n in htfNames) {
      try {
        htfVis.add(AnalyseTimeframe.values.byName(n));
      } catch (_) {}
    }
    if (htfVis.isEmpty) {
      htfVis = Set<AnalyseTimeframe>.from(AnalyseTimeframe.values);
    }
    _htfPillsVisible
      ..clear()
      ..addAll(htfVis);
    _htfCustomLabels
      ..clear()
      ..addAll(htfCust);
    _htfPick = _parseHtfPickMap(
      root['htfPick'] as Map<String, dynamic>?,
    );
    if (_htfPick.isEnum && !_htfPillsVisible.contains(_htfPick.enumVal!)) {
      _htfPick = ContextePick.enumOf(htfPillsVisibleOrdered.first);
    }
    if (!_htfPick.isEnum &&
        !_htfCustomLabels.contains(_htfPick.custom)) {
      _htfPick = ContextePick.enumOf(htfPillsVisibleOrdered.first);
    }

    final trNames = (root['trVis'] as List?)?.cast<String>() ?? [];
    final trCust = (root['trCust'] as List?)?.cast<String>() ?? [];
    var trVis = <AnalyseLocalTrend>{};
    for (final n in trNames) {
      try {
        trVis.add(AnalyseLocalTrend.values.byName(n));
      } catch (_) {}
    }
    if (trVis.isEmpty) {
      trVis = Set<AnalyseLocalTrend>.from(AnalyseLocalTrend.values);
    }
    _trendPillsVisible
      ..clear()
      ..addAll(trVis);
    _trendCustomLabels
      ..clear()
      ..addAll(trCust);
    _localTrendPick = _parseTrendPickMap(
      root['trPick'] as Map<String, dynamic>?,
    );
    if (_localTrendPick.isEnum &&
        !_trendPillsVisible.contains(_localTrendPick.enumVal!)) {
      _localTrendPick =
          ContextePick.enumOf(trendPillsVisibleOrdered.first);
    }
    if (!_localTrendPick.isEnum &&
        !_trendCustomLabels.contains(_localTrendPick.custom)) {
      _localTrendPick =
          ContextePick.enumOf(trendPillsVisibleOrdered.first);
    }

    final phNames = (root['phVis'] as List?)?.cast<String>() ?? [];
    final phCust = (root['phCust'] as List?)?.cast<String>() ?? [];
    var phVis = <AnalysePhase>{};
    for (final n in phNames) {
      try {
        phVis.add(AnalysePhase.values.byName(n));
      } catch (_) {}
    }
    if (phVis.isEmpty) {
      phVis = Set<AnalysePhase>.from(AnalysePhase.values);
    }
    _phasePillsVisible
      ..clear()
      ..addAll(phVis);
    _phaseCustomLabels
      ..clear()
      ..addAll(phCust);
    _phasePick = _parsePhasePickMap(
      root['phPick'] as Map<String, dynamic>?,
    );
    if (_phasePick.isEnum && !_phasePillsVisible.contains(_phasePick.enumVal!)) {
      _phasePick = ContextePick.enumOf(phasePillsVisibleOrdered.first);
    }
    if (!_phasePick.isEnum &&
        !_phaseCustomLabels.contains(_phasePick.custom)) {
      _phasePick = ContextePick.enumOf(phasePillsVisibleOrdered.first);
    }

    notifyListeners();
  }

  Map<String, Map<String, dynamic>> _parseTemplatesBundleMap(Map<dynamic, dynamic> raw) {
    final out = <String, Map<String, dynamic>>{};
    raw.forEach((k, v) {
      if (v is Map) {
        final m = Map<String, dynamic>.from(v);
        if (m['v'] == 1) {
          out[k.toString()] = m;
        }
      }
    });
    return out;
  }

  Future<Map<String, Map<String, dynamic>>> _loadTemplatesBundle() async {
    final prefs = await SharedPreferences.getInstance();
    final rawV2 = prefs.getString(_kFeuilleContextePillsTemplatesBundleKey);
    if (rawV2 != null && rawV2.trim().isNotEmpty) {
      try {
        final m = jsonDecode(rawV2) as Map<String, dynamic>;
        if (m['v'] == 2 && m['templates'] is Map) {
          final map = _parseTemplatesBundleMap(m['templates'] as Map<dynamic, dynamic>);
          // Ancien nom auto-migré : retirer pour ne pas polluer la liste.
          if (map.remove('Modèle enregistré') != null) {
            await _persistTemplatesBundle(map);
          }
          return map;
        }
      } catch (_) {}
    }
    return {};
  }

  Future<void> _persistTemplatesBundle(Map<String, Map<String, dynamic>> all) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kFeuilleContextePillsTemplatesBundleKey,
      jsonEncode({'v': 2, 'templates': all}),
    );
  }

  /// Noms des modèles enregistrés (tri alphabétique).
  Future<List<String>> listFeuilleContextePillsTemplateNames() async {
    final all = await _loadTemplatesBundle();
    final names = all.keys.toList();
    names.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
    return names;
  }

  /// Enregistre les puces actuelles sous [name] (écrase un nom existant).
  Future<void> saveFeuilleContextePillsTemplateNamed(String name) async {
    final key = name.trim();
    if (key.isEmpty) return;
    final all = await _loadTemplatesBundle();
    all[key] = Map<String, dynamic>.from(_serializeFeuilleContextePillsTemplate());
    await _persistTemplatesBundle(all);
    // Hook : la page Analyse synchronise via un push debounced global.
    // (Le push est déclenché côté UI pour ne pas dépendre de Firebase ici.)
  }

  /// Applique le modèle [name] s’il existe.
  Future<void> applyFeuilleContextePillsTemplateNamed(String name) async {
    final all = await _loadTemplatesBundle();
    final data = all[name];
    if (data != null) {
      _applyFeuilleContextePillsTemplate(data);
    }
  }

  /// Supprime le modèle [name].
  Future<void> deleteFeuilleContextePillsTemplateNamed(String name) async {
    final key = name.trim();
    if (key.isEmpty) return;
    final all = await _loadTemplatesBundle();
    if (all.remove(key) != null) {
      await _persistTemplatesBundle(all);
    }
  }

  /// Renomme un modèle. Si [newName] existe déjà, son contenu est remplacé.
  Future<void> renameFeuilleContextePillsTemplateNamed(
    String oldName,
    String newName,
  ) async {
    final o = oldName.trim();
    final n = newName.trim();
    if (o.isEmpty || n.isEmpty || o == n) return;
    final all = await _loadTemplatesBundle();
    final data = all.remove(o);
    if (data == null) return;
    all[n] = data;
    await _persistTemplatesBundle(all);
  }
}
