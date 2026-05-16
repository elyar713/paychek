import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'analyse_report_snapshot.dart';
import 'analyse_report_snapshot_codec.dart';
import '../reglage/paychek_prefs_scope.dart';

/// Persistance simple des rapports générés (liste).
abstract final class AnalyseReportsStorage {
  AnalyseReportsStorage._();

  static const _kBase = 'analyse_reports_list_v1';
  static String get _key => paychekScopedPrefsKey(_kBase);
  static const _maxItems = 50;

  static Future<List<AnalyseReportSnapshot>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final root = jsonDecode(raw);
      if (root is! Map<String, dynamic>) return const [];
      final items = root['items'];
      if (items is! List) return const [];
      final out = <AnalyseReportSnapshot>[];
      for (final it in items) {
        if (it is Map<String, dynamic>) {
          try {
            out.add(decodeAnalyseReportSnapshot(it));
          } catch (_) {
            // skip invalid
          }
        }
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  static Future<void> saveAll(List<AnalyseReportSnapshot> reports) async {
    final p = await SharedPreferences.getInstance();
    final capped = reports.length <= _maxItems
        ? reports
        : reports.sublist(0, _maxItems);
    final payload = <String, dynamic>{
      'v': 1,
      'items': [for (final r in capped) encodeAnalyseReportSnapshot(r)],
    };
    await p.setString(_key, jsonEncode(payload));
  }

  static Future<void> add(AnalyseReportSnapshot snapshot) async {
    final current = await loadAll();
    final snapJson = jsonEncode(encodeAnalyseReportSnapshot(snapshot));
    final deduped = <AnalyseReportSnapshot>[
      snapshot,
      for (final s in current)
        if (jsonEncode(encodeAnalyseReportSnapshot(s)) != snapJson) s,
    ];
    await saveAll(deduped);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}

