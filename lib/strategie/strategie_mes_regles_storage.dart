import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../reglage/paychek_prefs_scope.dart';
import 'strategie_feedback_reference.dart';
import 'strategie_firestore_sync.dart';
import 'strategie_realtime_notifier.dart';

/// « Mes règles d'or » — titre + lignes, persistés localement et synchronisés cloud.
class StrategieMesReglesPersisted {
  const StrategieMesReglesPersisted({
    required this.sectionTitle,
    required this.rules,
    this.isCustom = false,
  });

  final String sectionTitle;
  final List<String> rules;
  final bool isCustom;
}

abstract final class StrategieMesReglesStore {
  StrategieMesReglesStore._();

  static const _kBase = 'strategie_mes_regles_v1';
  static String get _key => paychekScopedPrefsKey(_kBase);

  static bool _loadedOnce = false;

  static StrategieMesReglesPersisted _defaultsFor(Locale locale) {
    final l = lookupAppLocalizations(locale);
    return StrategieMesReglesPersisted(
      sectionTitle: l.ajouterTradeStrategieGoldRules.toUpperCase(),
      rules: StrategieFeedbackReference.mesReglesDor(locale),
      isCustom: false,
    );
  }

  static final ValueNotifier<StrategieMesReglesPersisted> notifier =
      ValueNotifier<StrategieMesReglesPersisted>(
    _defaultsFor(const Locale('fr')),
  );

  static Future<void> ensureLoaded() async {
    if (_loadedOnce) return;
    _loadedOnce = true;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return;
    final decoded = _decode(raw);
    if (decoded != null) {
      notifier.value = decoded;
      return;
    }
    await p.remove(_key);
    notifier.value = StrategieMesReglesPersisted(
      sectionTitle: _defaultsFor(const Locale('fr')).sectionTitle,
      rules: List<String>.from(StrategieFeedbackReference.mesReglesDorDefautFr),
      isCustom: false,
    );
  }

  static void resetForAccountChange() {
    _loadedOnce = false;
    notifier.value = _defaultsFor(const Locale('fr'));
  }

  static List<String> rulesForLocale(Locale locale) {
    final v = notifier.value;
    if (v.isCustom) return List<String>.from(v.rules);
    return StrategieFeedbackReference.mesReglesDor(locale);
  }

  static String sectionTitleForLocale(Locale locale) {
    final v = notifier.value;
    if (v.isCustom) return v.sectionTitle;
    return lookupAppLocalizations(locale)
        .ajouterTradeStrategieGoldRules
        .toUpperCase();
  }

  static bool isStockGoldenTitle(String title) {
    final t = title.trim().toUpperCase();
    for (final code in ['fr', 'en', 'es', 'de', 'pt', 'ko']) {
      final l = lookupAppLocalizations(Locale(code));
      if (t == l.ajouterTradeStrategieGoldRules.toUpperCase()) return true;
    }
    return t == 'MES RÈGLES D\'OR' || t == 'MY GOLDEN RULES';
  }

  static bool isStockGoldenRules(List<String> rules) {
    for (final code in ['fr', 'en', 'es', 'de', 'pt', 'ko']) {
      if (_listsEqual(rules, StrategieFeedbackReference.mesReglesDor(Locale(code)))) {
        return true;
      }
    }
    return false;
  }

  static bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Enregistre uniquement si le contenu diffère des textes par défaut (toute langue).
  /// Sinon efface la persistance custom pour laisser [mesReglesDor] suivre la locale.
  static Future<void> persistIfCustomized({
    required String sectionTitle,
    required List<String> rules,
  }) async {
    final trimmed = rules
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList(growable: false);
    final title = sectionTitle.trim();
    if (trimmed.isNotEmpty &&
        isStockGoldenRules(trimmed) &&
        title.isNotEmpty &&
        isStockGoldenTitle(title)) {
      await revertToDefaults();
      return;
    }
    await save(sectionTitle: sectionTitle, rules: rules);
  }

  static Future<void> revertToDefaults() async {
    notifier.value = StrategieMesReglesPersisted(
      sectionTitle: _defaultsFor(const Locale('fr')).sectionTitle,
      rules: List<String>.from(StrategieFeedbackReference.mesReglesDorDefautFr),
      isCustom: false,
    );
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
    StrategieRealtimeNotifier.bump();
    await StrategieFirestoreSync.pushIfSignedIn();
  }

  static Future<void> save({
    required String sectionTitle,
    required List<String> rules,
  }) async {
    final trimmed = rules
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList(growable: false);
    final data = StrategieMesReglesPersisted(
      sectionTitle: sectionTitle.trim().isEmpty
          ? _defaultsFor(const Locale('fr')).sectionTitle
          : sectionTitle.trim().toUpperCase(),
      rules: trimmed,
      isCustom: true,
    );
    notifier.value = data;
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'v': 1,
        'isCustom': true,
        'sectionTitle': data.sectionTitle,
        'rules': data.rules,
      }),
    );
    StrategieRealtimeNotifier.bump();
    await StrategieFirestoreSync.pushIfSignedIn();
  }

  static Future<void> applyFromCloud({
    required String sectionTitle,
    required List<String> rules,
    required bool isCustom,
  }) async {
    final p = await SharedPreferences.getInstance();
    if (!isCustom) {
      await p.remove(_key);
      notifier.value = _defaultsFor(const Locale('fr'));
      return;
    }
    notifier.value = StrategieMesReglesPersisted(
      sectionTitle: sectionTitle,
      rules: List<String>.from(rules),
      isCustom: true,
    );
    await p.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'v': 1,
        'isCustom': true,
        'sectionTitle': sectionTitle,
        'rules': rules,
      }),
    );
  }

  static StrategieMesReglesPersisted? _decode(String raw) {
    try {
      final root = jsonDecode(raw);
      if (root is! Map<String, dynamic>) return null;
      final isCustom = root['isCustom'] as bool? ?? true;
      if (!isCustom) return null;
      final title = (root['sectionTitle'] as String?)?.trim();
      final rulesRaw = root['rules'];
      final rules = <String>[];
      if (rulesRaw is List) {
        for (final e in rulesRaw) {
          final t = '$e'.trim();
          if (t.isNotEmpty) rules.add(t);
        }
      }
      if (title == null || title.isEmpty) return null;
      if (isStockGoldenRules(rules) && isStockGoldenTitle(title)) {
        return null;
      }
      return StrategieMesReglesPersisted(
        sectionTitle: title.toUpperCase(),
        rules: rules,
        isCustom: true,
      );
    } catch (_) {
      return null;
    }
  }
}
