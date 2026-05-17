import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'paychek_prefs_scope.dart';

abstract final class ReglageLanguagePrefs {
  /// Base utilisée avec [paychekScopedPrefsKey] — une préférence par compte / guest.
  static const _kLanguageCodeBase = 'app_language_code';
  static const _kUpdatedAtMsBase = 'app_language_updated_at_ms_v1';
  static const String codeEnglish = 'en';
  static const String codeSpanish = 'es';
  static const String codeFrench = 'fr';
  static const String codeGerman = 'de';
  static const String codeKorean = 'ko';
  static const String codePortuguese = 'pt';
  static const Set<String> availableCodes = <String>{
    codeEnglish,
    codeFrench,
    codeSpanish,
    codePortuguese,
    codeGerman,
    codeKorean,
  };
  static const String defaultCode = codeEnglish;

  /// Ancienne clé globale (avant isolation par compte) : `app_language_code` sans suffixe.
  static Future<void> _migrateLegacyGlobalIfNeeded(SharedPreferences p) async {
    final scoped = paychekScopedPrefsKey(_kLanguageCodeBase);
    if (p.getString(scoped) != null) return;
    final legacy = p.getString(_kLanguageCodeBase);
    if (legacy != null && availableCodes.contains(legacy)) {
      await p.setString(scoped, legacy);
      await p.remove(_kLanguageCodeBase);
    }
  }

  static String _guestScopedKey(String baseKey) => '${baseKey}__guest';

  static String? _readCodeIfValid(String? raw) {
    if (raw != null && availableCodes.contains(raw)) return raw;
    return null;
  }

  /// Après connexion : reprend le choix fait sur la landing (`__guest`) si le compte n’a pas encore de langue.
  static Future<void> promoteGuestLanguageToCurrentAccountIfNeeded() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final p = await SharedPreferences.getInstance();
    await _migrateLegacyGlobalIfNeeded(p);
    final scopedCodeKey = paychekScopedPrefsKey(_kLanguageCodeBase);
    if (_readCodeIfValid(p.getString(scopedCodeKey)) != null) return;

    final guestCode = _readCodeIfValid(
      p.getString(_guestScopedKey(_kLanguageCodeBase)),
    );
    if (guestCode == null) return;

    final guestAtKey = _guestScopedKey(_kUpdatedAtMsBase);
    final ms =
        p.getInt(guestAtKey) ?? DateTime.now().millisecondsSinceEpoch;
    await save(guestCode, updatedAtMillis: ms);
  }

  static Future<String> loadCode() async {
    final p = await SharedPreferences.getInstance();
    await _migrateLegacyGlobalIfNeeded(p);
    final scopedKey = paychekScopedPrefsKey(_kLanguageCodeBase);
    final scoped = _readCodeIfValid(p.getString(scopedKey));
    if (scoped != null) return scoped;

    final guest = _readCodeIfValid(
      p.getString(_guestScopedKey(_kLanguageCodeBase)),
    );
    if (guest != null) return guest;

    final legacy = _readCodeIfValid(p.getString(_kLanguageCodeBase));
    if (legacy != null) return legacy;

    return defaultCode;
  }

  /// Horodatage local du dernier choix explicite (compare à [appLanguageUpdatedAt] Firestore).
  static Future<int> loadUpdatedAtMillis() async {
    final p = await SharedPreferences.getInstance();
    await _migrateLegacyGlobalIfNeeded(p);
    final scopedKey = paychekScopedPrefsKey(_kUpdatedAtMsBase);
    final scopedMs = p.getInt(scopedKey);
    if (scopedMs != null) return scopedMs;

    final guestMs = p.getInt(_guestScopedKey(_kUpdatedAtMsBase));
    if (guestMs != null) return guestMs;

    return p.getInt(_kUpdatedAtMsBase) ?? 0;
  }

  static Future<void> save(String code, {int? updatedAtMillis}) async {
    final p = await SharedPreferences.getInstance();
    await _migrateLegacyGlobalIfNeeded(p);
    final safe = availableCodes.contains(code) ? code : defaultCode;
    final codeKey = paychekScopedPrefsKey(_kLanguageCodeBase);
    final atKey = paychekScopedPrefsKey(_kUpdatedAtMsBase);
    final ms = updatedAtMillis ?? DateTime.now().millisecondsSinceEpoch;
    await p.setString(codeKey, safe);
    await p.setInt(atKey, ms);
  }

  static Locale localeFromCode(String code) {
    switch (code) {
      case codeEnglish:
        return const Locale('en');
      case codeSpanish:
        return const Locale('es');
      case codePortuguese:
        return const Locale('pt');
      case codeGerman:
        return const Locale('de');
      case codeKorean:
        return const Locale('ko');
      case codeFrench:
        return const Locale('fr');
      default:
        return const Locale('en');
    }
  }

  static String codeFromLocale(Locale locale) {
    final lang = locale.languageCode.toLowerCase();
    return availableCodes.contains(lang) ? lang : defaultCode;
  }
}
