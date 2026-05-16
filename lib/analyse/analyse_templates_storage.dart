import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';

/// Persistance des modèles (templates) de puces de contexte Analyse.
///
/// Clé identique à celle utilisée dans `AnalyseController` (v2).
abstract final class AnalyseTemplatesStorage {
  AnalyseTemplatesStorage._();

  static const _kBase = 'analyse_feuille_contexte_pills_templates_v2';
  static String get _key => paychekScopedPrefsKey(_kBase);

  /// Charge la map complète `{ name: templateMap }`.
  static Future<Map<String, Map<String, dynamic>>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final root = jsonDecode(raw) as Map<String, dynamic>;
      if (root['v'] != 2) return {};
      final templates = root['templates'];
      if (templates is! Map) return {};
      final out = <String, Map<String, dynamic>>{};
      templates.forEach((k, v) {
        if (v is Map) {
          final m = Map<String, dynamic>.from(v);
          if (m['v'] == 1) out[k.toString()] = m;
        }
      });
      return out;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveAll(Map<String, Map<String, dynamic>> templates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{'v': 2, 'templates': templates}),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

