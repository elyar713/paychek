import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'checklist_item_schedule.dart';
import 'checklist_models.dart';

/// Persistance JSON de la checklist « Nouveau Trade » (sections + lignes).
abstract final class ChecklistSectionsStorage {
  ChecklistSectionsStorage._();

  static const _kBase = 'checklist_nouveau_trade_sections_v1';

  static String get _key => paychekScopedPrefsKey(_kBase);

  /// JSON d’une ligne (prefs + Firestore).
  static Map<String, dynamic> encodeItem(ChecklistItemData item) {
    return {
      'id': item.id,
      'label': item.label,
      'checked': item.checked,
      if (item.checkedAt != null)
        'checkedAtMs': item.checkedAt!.toUtc().millisecondsSinceEpoch,
      if (item.schedule != null) 'schedule': item.schedule!.toJson(),
    };
  }

  static Future<void> save(List<ChecklistSectionData> sections) async {
    final p = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      sections
          .map(
            (s) => {
              'id': s.id,
              'title': s.title,
              'enabled': s.enabled,
              'items': s.items.map(encodeItem).toList(),
            },
          )
          .toList(),
    );
    await p.setString(_key, raw);
  }

  static Future<List<ChecklistSectionData>?> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decodeSectionsList(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Même schéma que la clé `sections` dans Firestore `checklist_nouveau_trade_v1`.
  static List<ChecklistSectionData>? decodeSectionsList(dynamic decoded) {
    if (decoded is! List) return null;
    final out = <ChecklistSectionData>[];
    for (final e in decoded) {
      if (e is! Map) continue;
      final id = e['id'];
      final title = e['title'];
      if (id is! String || title is! String) continue;
      final itemsRaw = e['items'];
      final items = <ChecklistItemData>[];
      if (itemsRaw is List) {
        for (final it in itemsRaw) {
          if (it is! Map) continue;
          final iid = it['id'];
          final lab = it['label'];
          if (iid is! String || lab is! String) continue;
          final sched = ChecklistItemSchedule.fromJson(it['schedule']);
          DateTime? checkedAt;
          final ms = it['checkedAtMs'];
          if (ms is int) {
            checkedAt = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
          }
          items.add(
            ChecklistItemData(
              id: iid,
              label: lab,
              checked: it['checked'] == true,
              checkedAt: checkedAt,
              schedule: sched,
            ),
          );
        }
      }
      final enabled = e['enabled'];
      out.add(
        ChecklistSectionData(
          id: id,
          title: title,
          items: items,
          enabled: enabled is bool ? enabled : true,
        ),
      );
    }
    return out.isEmpty ? null : out;
  }
}
