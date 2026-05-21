import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'ajouter_trade_discipline_settings_sheet.dart';

abstract final class AjouterTradeDisciplinePrefsStorage {
  AjouterTradeDisciplinePrefsStorage._();

  static const _kBase = 'ajouter_trade_discipline_prefs_v1';

  static String get _key => paychekScopedPrefsKey(_kBase);

  static Future<AjouterTradeDisciplinePrefs> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) {
      return AjouterTradeDisciplinePrefs.defaults;
    }
    try {
      final m = jsonDecode(raw);
      if (m is! Map) return AjouterTradeDisciplinePrefs.defaults;
      return AjouterTradeDisciplinePrefs.fromJson(
        Map<String, dynamic>.from(m),
      );
    } catch (_) {
      return AjouterTradeDisciplinePrefs.defaults;
    }
  }

  static Future<void> save(AjouterTradeDisciplinePrefs prefs) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(prefs.toJson()));
  }
}
