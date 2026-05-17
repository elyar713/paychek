import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'performance_custom_lens_model.dart';

class PerformanceCustomLensStorage {
  PerformanceCustomLensStorage._();

  static const _kSavedBase = 'paychek_perf_custom_lens_saved_v2';
  static const _kLegacyDraftBase = 'paychek_perf_custom_lens_v1';

  static String get _kSaved => paychekScopedPrefsKey(_kSavedBase);
  static String get _kLegacyDraft => paychekScopedPrefsKey(_kLegacyDraftBase);

  static const int maxSavedCards = 12;

  static Future<List<PerformanceCustomLensSavedCard>> loadSavedCards() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kSaved);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return [
            for (final e in decoded)
              if (e is Map<String, dynamic>)
                PerformanceCustomLensSavedCard.fromJson(e),
          ];
        }
      } catch (_) {}
    }

    // Migration : ancien brouillon persisté → une carte enregistrée si configurée.
    final legacy = p.getString(_kLegacyDraft);
    if (legacy != null && legacy.isNotEmpty) {
      try {
        final decoded = jsonDecode(legacy);
        if (decoded is Map<String, dynamic>) {
          final cfg = PerformanceCustomLensConfig.fromJson(decoded);
          if (cfg.elementId.isNotEmpty) {
            final migrated = [
              PerformanceCustomLensSavedCard(
                id: 'legacy_${DateTime.now().millisecondsSinceEpoch}',
                config: cfg,
                savedAtMillis: DateTime.now().millisecondsSinceEpoch,
              ),
            ];
            await saveSavedCards(migrated);
            await p.remove(_kLegacyDraft);
            return migrated;
          }
        }
      } catch (_) {}
    }
    return const [];
  }

  static Future<void> saveSavedCards(List<PerformanceCustomLensSavedCard> cards) async {
    final p = await SharedPreferences.getInstance();
    final slice = cards.length <= maxSavedCards
        ? cards
        : cards.sublist(cards.length - maxSavedCards);
    await p.setString(
      _kSaved,
      jsonEncode([for (final c in slice) c.toJson()]),
    );
  }
}
