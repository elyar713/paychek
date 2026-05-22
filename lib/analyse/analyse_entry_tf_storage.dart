import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'analyse_controller.dart';

/// Timeframe ENTRÉE (section Indicateurs) choisi par l'utilisateur.
abstract final class AnalyseEntryTfStorage {
  AnalyseEntryTfStorage._();

  static const _kBase = 'analyse_entry_ltf_tf_v1';
  static String get _key => paychekScopedPrefsKey(_kBase);

  static Future<void> saveFromController(AnalyseController c) async {
    await save(
      label: c.indicatorsTf,
      customs: c.indicatorsTfCustom,
    );
  }

  static Future<void> save({
    required String label,
    required List<String> customs,
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'v': 1,
        'label': trimmed,
        'customs': customs.map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      }),
    );
  }

  static Future<void> applyToController(AnalyseController c) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return;
    try {
      final root = jsonDecode(raw) as Map<String, dynamic>;
      if (root['v'] != 1) return;
      final customs = root['customs'];
      if (customs is List) {
        for (final item in customs) {
          c.registerIndicatorsTfCustom(item.toString());
        }
      }
      final label = root['label']?.toString().trim();
      if (label != null && label.isNotEmpty) {
        c.indicatorsTf = label;
      }
    } catch (_) {
      // Préférence corrompue : ignorer, garder le défaut M5.
    }
  }
}
