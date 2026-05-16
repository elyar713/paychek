import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'strategie_setup_storage_codec.dart';
import 'widgets/strategie_setup_card.dart';

/// Setup épinglé pour l’aperçu **Stratégie** sur le dashboard.
abstract final class StrategieStarredSetupStorage {
  StrategieStarredSetupStorage._();

  static const _kBase = 'strategie_dashboard_starred_setup_v1';
  static String get _key => paychekScopedPrefsKey(_kBase);

  static Future<void> save(StrategieSetupCardData data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(encodeStrategieSetupCardData(data)));
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }

  static Future<StrategieSetupCardData?> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return decodeStrategieSetupCardData(m);
    } catch (_) {
      return null;
    }
  }

  static bool matches(
    StrategieSetupCardData? starred,
    StrategieSetupCardData candidate,
  ) {
    if (starred == null) return false;
    return strategieSetupsEqualForStar(starred, candidate);
  }
}
