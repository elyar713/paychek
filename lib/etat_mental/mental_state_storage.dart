import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'mental_state_models.dart';

/// Persistance locale complète de l’état mental (curseurs + poids + listes).
///
/// Note: Le mini-calendrier (scores par jour) est persisté séparément dans
/// [MentalStateController] pour garder sa logique de trimming.
abstract final class MentalStateStorage {
  MentalStateStorage._();

  static const _kBundleBase = 'mental_state_bundle_v1';

  static String get _kBundle => paychekScopedPrefsKey(_kBundleBase);

  static Map<String, dynamic> encodeBundle({
    required double sleepValue,
    required double sleepWeight,
    required bool sleepInverse,
    required double routinesGlobalWeight,
    required double momentBlockWeight,
    required double emotionBlockWeight,
    required bool factorsShare100,
    required bool momentShare100,
    required bool emotionsShare100,
    required List<MentalStateMetric> factors,
    required List<MentalStateMetric> moment,
    required List<MentalStateEmotion> emotions,
    required List<String> selectedEmotionIds,
  }) {
    Map<String, dynamic> metric(MentalStateMetric m) => <String, dynamic>{
          'id': m.id,
          'label': m.label,
          'value': m.value,
          'weight': m.weight,
          'inverse': m.inverse,
          'barColor': m.barColor.toARGB32(),
          'isMainSlider': m.isMainSlider,
        };
    Map<String, dynamic> emotion(MentalStateEmotion e) => emotionToMap(e);
    return <String, dynamic>{
      'v': 1,
      'sleepValue': sleepValue,
      'sleepWeight': sleepWeight,
      'sleepInverse': sleepInverse,
      'routinesGlobalWeight': routinesGlobalWeight,
      'momentBlockWeight': momentBlockWeight,
      'emotionBlockWeight': emotionBlockWeight,
      'factorsShare100': factorsShare100,
      'momentShare100': momentShare100,
      'emotionsShare100': emotionsShare100,
      'selectedEmotionIds': selectedEmotionIds,
      'factors': factors.map(metric).toList(),
      'moment': moment.map(metric).toList(),
      'emotions': emotions.map(emotion).toList(),
    };
  }

  static MentalStateMetric? decodeMetric(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = (m['id'] as String?)?.trim();
    if (id == null || id.isEmpty) return null;
    final label = (m['label'] as String?) ?? '';
    final value = (m['value'] as num?)?.toDouble() ?? 0;
    final weight = (m['weight'] as num?)?.toDouble() ?? 0;
    final inverse = (m['inverse'] as bool?) ?? false;
    final colorV = (m['barColor'] as num?)?.toInt();
    final isMain = (m['isMainSlider'] as bool?) ?? false;
    return MentalStateMetric(
      id: id,
      label: label,
      value: value.clamp(0, 100),
      weight: weight.clamp(0, 100),
      inverse: inverse,
      barColor: Color(colorV ?? Colors.white.toARGB32()),
      isMainSlider: isMain,
    );
  }

  static Map<String, dynamic> emotionToMap(MentalStateEmotion e) =>
      <String, dynamic>{
        'id': e.id,
        'label': e.label,
        'value': e.value,
        'weight': e.weight,
        'inverse': e.inverse,
      };

  static List<MentalStateEmotion> decodeEmotionsList(Object? raw) {
    if (raw is! List) return const [];
    final out = <MentalStateEmotion>[];
    for (final e in raw) {
      final x = decodeEmotion(e);
      if (x != null) out.add(x);
    }
    return out;
  }

  static MentalStateEmotion? decodeEmotion(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = (m['id'] as String?)?.trim();
    if (id == null || id.isEmpty) return null;
    final label = (m['label'] as String?) ?? '';
    final value = (m['value'] as num?)?.toDouble() ?? 0;
    final weight = (m['weight'] as num?)?.toDouble() ?? 50;
    final inverse = (m['inverse'] as bool?) ?? false;
    return MentalStateEmotion(
      id: id,
      label: label,
      value: value.clamp(0, 100),
      weight: weight.clamp(0, 100),
      inverse: inverse,
    );
  }

  static Future<Map<String, dynamic>?> loadBundleMap() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kBundle);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  static Future<void> saveBundleMap(Map<String, dynamic> bundle) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBundle, jsonEncode(bundle));
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kBundle);
  }
}

