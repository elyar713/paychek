import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'dashboard_home_layout_keys.dart';

/// Ordre + activation des sections de l’accueil (persisté localement + sync Firestore).
class DashboardHomeLayoutStore extends ChangeNotifier {
  DashboardHomeLayoutStore()
      : _order = List<String>.from(DashboardHomeLayoutKeys.defaultOrder),
        _enabled = {
          for (final id in DashboardHomeLayoutKeys.defaultOrder) id: true,
        };

  static const _kOrderBase = 'dashboard_home_layout_order_v1';
  static const _kEnabledBase = 'dashboard_home_layout_enabled_v1';

  static String get _kOrder => paychekScopedPrefsKey(_kOrderBase);
  static String get _kEnabled => paychekScopedPrefsKey(_kEnabledBase);

  final List<String> _order;
  final Map<String, bool> _enabled;

  List<String> get sectionOrder => List.unmodifiable(_order);

  bool isEnabled(String id) => _enabled[id] ?? true;

  /// Sections visibles sur l’accueil, dans l’ordre choisi.
  Iterable<String> get orderedVisibleIds sync* {
    for (final id in _order) {
      if (isEnabled(id)) yield id;
    }
  }

  Future<void> load() async {
    // Même instance de store après changement de compte (clés prefs scopées par uid).
    // Sans réinitialisation : si le nouvel utilisateur n'a encore rien en local, l'ordre
    // et les cases « afficher » restent ceux du compte précédent (ex. invité web).
    _order
      ..clear()
      ..addAll(DashboardHomeLayoutKeys.defaultOrder);
    for (final id in DashboardHomeLayoutKeys.defaultOrder) {
      _enabled[id] = true;
    }

    final p = await SharedPreferences.getInstance();
    final rawOrder = p.getString(_kOrder);
    final rawEnabled = p.getString(_kEnabled);

    if (rawOrder != null && rawOrder.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawOrder);
        if (decoded is List) {
          final parsed = decoded.map((e) => e.toString()).toList();
          final merged = <String>[];
          for (final id in parsed) {
            if (DashboardHomeLayoutKeys.defaultOrder.contains(id) &&
                !merged.contains(id)) {
              merged.add(id);
            }
          }
          for (final id in DashboardHomeLayoutKeys.defaultOrder) {
            if (!merged.contains(id)) merged.add(id);
          }
          _order
            ..clear()
            ..addAll(merged);
        }
      } catch (_) {}
    }

    if (rawEnabled != null && rawEnabled.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawEnabled);
        if (decoded is Map) {
          for (final e in DashboardHomeLayoutKeys.defaultOrder) {
            final v = decoded[e];
            if (v is bool) _enabled[e] = v;
          }
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kOrder, jsonEncode(_order));
    await p.setString(_kEnabled, jsonEncode(_enabled));
  }

  /// Snapshot sérialisable pour Firestore (sync multi-device).
  Map<String, dynamic> toCloudSnapshot() => <String, dynamic>{
        'order': List<String>.from(_order),
        'enabled': Map<String, bool>.from(_enabled),
      };

  /// Applique un snapshot cloud (ordre + enabled) puis persiste localement.
  Future<void> applyFromCloud({
    required List<String> order,
    required Map<String, bool> enabled,
  }) async {
    _order
      ..clear()
      ..addAll(order);
    // Clé absente du document cloud = visible par défaut (ne pas réutiliser l'état mémoire
    // d'une autre session / compte).
    for (final id in DashboardHomeLayoutKeys.defaultOrder) {
      _enabled[id] = enabled[id] ?? true;
    }
    await _persist();
    notifyListeners();
  }

  void setSectionEnabled(String id, bool value) {
    if (!DashboardHomeLayoutKeys.defaultOrder.contains(id)) return;
    _enabled[id] = value;
    notifyListeners();
    _persist();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _order.length ||
        newIndex < 0 ||
        newIndex > _order.length) {
      return;
    }
    var to = newIndex;
    if (oldIndex < to) to -= 1;
    final id = _order.removeAt(oldIndex);
    _order.insert(to.clamp(0, _order.length), id);
    notifyListeners();
    _persist();
  }
}
