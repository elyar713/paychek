import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'strategie_setup_storage_codec.dart';
import 'widgets/strategie_setup_card.dart';
import 'widgets/strategie_setup_cards_content.dart';

/// Source de vérité (mémoire + disque) pour la liste "Setups & modèles".
///
/// Objectif : les menus (ex. Ajouter trade) et la page Stratégie restent synchronisés
/// (ajout / édition / suppression) sans attendre un chargement async à chaque ouverture.
abstract final class StrategieSetupsStore {
  StrategieSetupsStore._();

  static const _kBase = 'strategie_setups_list_v1';
  static String get _key => paychekScopedPrefsKey(_kBase);
  static const _maxItems = 60;

  static bool _loadedOnce = false;

  static final ValueNotifier<List<StrategieSetupCardData>> notifier =
      ValueNotifier<List<StrategieSetupCardData>>(
    List<StrategieSetupCardData>.from(strategieSetupDefaultCardDataList()),
  );

  static Future<void> ensureLoaded() async {
    if (_loadedOnce) return;
    _loadedOnce = true;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    // Clé absente : garder [notifier] initial (défauts). Clé présente y compris
    // `items: []` après reset : appliquer la liste (vide ou non).
    if (raw == null || raw.isEmpty) return;
    notifier.value = _decodeListFromPrefs(raw);
  }

  /// À appeler quand l’utilisateur Auth change (uid/email).
  /// Réinitialise le cache mémoire pour recharger depuis les clés scoped.
  static void resetForAccountChange() {
    _loadedOnce = false;
    notifier.value = List<StrategieSetupCardData>.from(
      strategieSetupDefaultCardDataList(),
    );
  }

  static Future<void> setAll(List<StrategieSetupCardData> setups) async {
    final capped =
        setups.length <= _maxItems ? setups : setups.sublist(0, _maxItems);
    notifier.value = List<StrategieSetupCardData>.from(capped);
    await _saveAllToDisk(notifier.value);
  }

  static Future<void> _saveAllToDisk(List<StrategieSetupCardData> setups) async {
    final p = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'v': 1,
      'items': [for (final s in setups) encodeStrategieSetupCardData(s)],
    };
    await p.setString(_key, jsonEncode(payload));
  }

  static List<StrategieSetupCardData> _decodeListFromPrefs(String raw) {
    try {
      final root = jsonDecode(raw);
      if (root is! Map<String, dynamic>) return const [];
      final items = root['items'];
      if (items is! List) return const [];
      final out = <StrategieSetupCardData>[];
      for (final it in items) {
        if (it is Map<String, dynamic>) {
          try {
            out.add(decodeStrategieSetupCardData(it));
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
}

