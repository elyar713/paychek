import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'checklist_models.dart';

/// Persistance JSON de la checklist « Nouveau Trade » (sections + lignes).
abstract final class ChecklistSectionsStorage {
  ChecklistSectionsStorage._();

  static const _kBase = 'checklist_nouveau_trade_sections_v1';

  static String get _key => paychekScopedPrefsKey(_kBase);

  static Future<void> save(List<ChecklistSectionData> sections) async {
    final p = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      sections
          .map(
            (s) => {
              'id': s.id,
              'title': s.title,
              'items': s.items
                  .map(
                    (i) => {
                      'id': i.id,
                      'label': i.label,
                      'checked': i.checked,
                    },
                  )
                  .toList(),
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
          items.add(
            ChecklistItemData(
              id: iid,
              label: lab,
              checked: it['checked'] == true,
            ),
          );
        }
      }
      out.add(ChecklistSectionData(id: id, title: title, items: items));
    }
    return out.isEmpty ? null : out;
  }
}
