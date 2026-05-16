import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';

/// Jours où l’utilisateur a indiqué avoir **utilisé** un setup (titre = même clé qu’« Ajouter trade » / Stratégie).
///
/// Stockage : `{ setupTitle: [ dayKey, ... ] }` avec [dayKey] = année×10000 + mois×100 + jour.
abstract final class StrategieSetupUsageStore {
  StrategieSetupUsageStore._();

  static const _kBase = 'strategie_setup_usage_history_v1';
  static String get _key => paychekScopedPrefsKey(_kBase);

  static bool _loadedOnce = false;

  /// Titre du setup → ensemble des [dayKey] marqués.
  static final ValueNotifier<Map<String, Set<int>>> notifier =
      ValueNotifier<Map<String, Set<int>>>({});

  static Future<void> ensureLoaded() async {
    if (_loadedOnce) return;
    _loadedOnce = true;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final out = <String, Set<int>>{};
      for (final e in decoded.entries) {
        final k = e.key;
        final v = e.value;
        if (k is! String || v is! List) continue;
        out[k] = {
          for (final x in v)
            if (x is int) x else int.tryParse('$x') ?? 0,
        }..removeWhere((dk) => dk <= 0);
      }
      notifier.value = out;
    } catch (_) {}
  }

  /// À appeler quand l’utilisateur Auth change (uid/email).
  static void resetForAccountChange() {
    _loadedOnce = false;
    notifier.value = {};
  }

  static Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    final m = <String, dynamic>{};
    for (final e in notifier.value.entries) {
      m[e.key] = e.value.toList()..sort();
    }
    await p.setString(_key, jsonEncode(m));
  }

  /// Remplace tout l'historique (utilisé par la sync cloud).
  static Future<void> setAll(Map<String, Set<int>> usage) async {
    final copy = <String, Set<int>>{};
    for (final e in usage.entries) {
      final k = e.key.trim();
      if (k.isEmpty) continue;
      final set = Set<int>.from(e.value)..removeWhere((dk) => dk <= 0);
      if (set.isEmpty) continue;
      copy[k] = set;
    }
    notifier.value = copy;
    await _persist();
  }

  static bool hasUsage(String setupTitle, int dayKey) =>
      notifier.value[setupTitle]?.contains(dayKey) ?? false;

  static Future<void> toggleDay(String setupTitle, int dayKey) async {
    final copy = <String, Set<int>>{
      for (final e in notifier.value.entries) e.key: Set<int>.from(e.value),
    };
    final set = copy.putIfAbsent(setupTitle, () => <int>{});
    if (set.contains(dayKey)) {
      set.remove(dayKey);
    } else {
      set.add(dayKey);
    }
    if (set.isEmpty) copy.remove(setupTitle);
    notifier.value = copy;
    await _persist();
  }
}
