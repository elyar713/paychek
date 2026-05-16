import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'analyse_report_snapshot.dart';
import 'analyse_report_snapshot_codec.dart';
import '../reglage/paychek_prefs_scope.dart';

/// Rapport épinglé pour l’aperçu « Mon Analyse » sur le dashboard.
abstract final class AnalyseStarredReportStorage {
  AnalyseStarredReportStorage._();

  static const _kBase = 'analyse_dashboard_starred_snapshot_v1';
  static String get _key => paychekScopedPrefsKey(_kBase);

  static Future<void> save(AnalyseReportSnapshot snapshot) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(encodeAnalyseReportSnapshot(snapshot)));
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }

  static Future<AnalyseReportSnapshot?> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return decodeAnalyseReportSnapshot(m);
    } catch (_) {
      return null;
    }
  }

  static bool matches(
    AnalyseReportSnapshot? starred,
    AnalyseReportSnapshot candidate,
  ) {
    if (starred == null) return false;
    return analyseSnapshotsEqualForStar(starred, candidate);
  }
}
