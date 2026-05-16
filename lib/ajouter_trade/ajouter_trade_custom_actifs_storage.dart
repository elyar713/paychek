import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ajouter_trade_asset_class.dart';
import '../reglage/paychek_prefs_scope.dart';

/// Actifs personnalisés ajoutés par l'utilisateur, séparés par marché.
///
/// Chargé une fois (cache mémoire), puis utilisé par [ajouterTradeActifsPour].
class AjouterTradeCustomActifsStorage {
  AjouterTradeCustomActifsStorage._();

  static const String _kBase = 'paychek_custom_actifs_v1';
  static String get _key => paychekScopedPrefsKey(_kBase);

  static final ValueNotifier<Map<AjouterTradeAssetClass, List<String>>> notifier =
      ValueNotifier<Map<AjouterTradeAssetClass, List<String>>>(
    <AjouterTradeAssetClass, List<String>>{},
  );

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final out = <AjouterTradeAssetClass, List<String>>{};
      for (final entry in decoded.entries) {
        final k = entry.key?.toString();
        final v = entry.value;
        if (k == null) continue;
        final cls = _parseClass(k);
        if (cls == null) continue;
        if (v is List) {
          final list = v
              .map((e) => e?.toString() ?? '')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(growable: false);
          if (list.isNotEmpty) out[cls] = list;
        }
      }
      if (out.isNotEmpty) notifier.value = out;
    } catch (_) {
      // Ignore corrupted prefs.
    }
  }

  /// À appeler quand l’utilisateur Auth change (uid/email).
  static void resetForAccountChange() {
    _loaded = false;
    notifier.value = <AjouterTradeAssetClass, List<String>>{};
  }

  static Future<void> add(AjouterTradeAssetClass cls, String symbol) async {
    final sym = symbol.trim().toUpperCase();
    if (sym.isEmpty) return;
    final current = Map<AjouterTradeAssetClass, List<String>>.from(notifier.value);
    final list = List<String>.from(current[cls] ?? const <String>[]);
    if (list.any((e) => e.toUpperCase() == sym)) return;
    list.add(sym);
    list.sort((a, b) => a.compareTo(b));
    current[cls] = list;
    notifier.value = current;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(_encode(current)));
  }

  static Map<String, List<String>> _encode(
    Map<AjouterTradeAssetClass, List<String>> m,
  ) {
    final out = <String, List<String>>{};
    for (final e in m.entries) {
      out[_encodeClass(e.key)] = e.value;
    }
    return out;
  }

  static String _encodeClass(AjouterTradeAssetClass c) => c.name;

  static AjouterTradeAssetClass? _parseClass(String raw) {
    for (final c in AjouterTradeAssetClass.values) {
      if (c.name == raw) return c;
    }
    return null;
  }
}

