import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'checklist_daily_day_snapshot.dart';

/// Historique local : % checklist + lignes non cochées par jour calendaire.
abstract final class ChecklistDailyCompletionStorage {
  ChecklistDailyCompletionStorage._();

  static const _kV2Base = 'checklist_daily_completion_v2';
  static const _kV1Base = 'checklist_daily_completion_v1';

  static String get _kV2 => paychekScopedPrefsKey(_kV2Base);
  static String get _kV1 => paychekScopedPrefsKey(_kV1Base);

  static int dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  static Future<Map<int, ChecklistDailyDaySnapshot>> load() async {
    final p = await SharedPreferences.getInstance();
    final rawV2 = p.getString(_kV2);
    if (rawV2 != null && rawV2.isNotEmpty) {
      final parsed = _decodeMap(rawV2);
      if (parsed != null) return parsed;
    }

    final rawV1 = p.getString(_kV1);
    if (rawV1 == null || rawV1.isEmpty) return {};
    try {
      final decoded = jsonDecode(rawV1);
      if (decoded is! Map) return {};
      final out = <int, ChecklistDailyDaySnapshot>{};
      for (final e in decoded.entries) {
        final k = int.tryParse(e.key.toString());
        final v = (e.value as num?)?.round();
        if (k != null && v != null) {
          out[k] = ChecklistDailyDaySnapshot(percent: v.clamp(0, 100));
        }
      }
      if (out.isNotEmpty) {
        await save(out);
      }
      return out;
    } catch (_) {
      return {};
    }
  }

  static ChecklistUncheckedDayEntry? _decodeEntry(dynamic v) {
    if (v is! Map) return null;
    final m = Map<String, dynamic>.from(v);
    final itemId = m['itemId']?.toString() ?? m['id']?.toString() ?? '';
    if (itemId.isEmpty) return null;
    return ChecklistUncheckedDayEntry(
      sectionId: m['sectionId']?.toString() ?? '',
      sectionTitle: m['sectionTitle']?.toString() ?? '',
      itemId: itemId,
      itemLabel: m['itemLabel']?.toString() ?? m['label']?.toString() ?? '',
    );
  }

  static List<ChecklistUncheckedDayEntry> _decodeUncheckedList(dynamic raw) {
    if (raw is! List) return const [];
    final entries = <ChecklistUncheckedDayEntry>[];
    for (final v in raw) {
      if (v is String && v.isNotEmpty) {
        entries.add(
          ChecklistUncheckedDayEntry(
            sectionId: '',
            sectionTitle: '',
            itemId: v,
            itemLabel: '',
          ),
        );
        continue;
      }
      final e = _decodeEntry(v);
      if (e != null) entries.add(e);
    }
    return entries;
  }

  static Map<int, ChecklistDailyDaySnapshot>? _decodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final out = <int, ChecklistDailyDaySnapshot>{};
      for (final e in decoded.entries) {
        final k = int.tryParse(e.key.toString());
        if (k == null) continue;
        final v = e.value;
        if (v is num) {
          out[k] = ChecklistDailyDaySnapshot(percent: v.round().clamp(0, 100));
          continue;
        }
        if (v is Map) {
          final m = Map<String, dynamic>.from(v);
          final pct = (m['percent'] as num?)?.round() ?? 0;
          final entries = _decodeUncheckedList(m['unchecked']);
          out[k] = ChecklistDailyDaySnapshot(
            percent: pct.clamp(0, 100),
            uncheckedEntries: entries,
          );
        }
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Map<int, ChecklistDailyDaySnapshot> map) async {
    final p = await SharedPreferences.getInstance();
    final encoded = <String, dynamic>{};
    for (final e in map.entries) {
      encoded['${e.key}'] = <String, dynamic>{
        'percent': e.value.percent,
        'unchecked': [
          for (final u in e.value.uncheckedEntries)
            <String, dynamic>{
              'sectionId': u.sectionId,
              'sectionTitle': u.sectionTitle,
              'itemId': u.itemId,
              'itemLabel': u.itemLabel,
            },
        ],
      };
    }
    await p.setString(_kV2, jsonEncode(encoded));
  }
}
