import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';

/// Préférences des rappels locaux checklist (mobile iOS / Android).
abstract final class ChecklistNotificationPrefs {
  ChecklistNotificationPrefs._();

  static const _kEnabledBase = 'checklist_reminders_enabled_v1';

  static String get _kEnabled => paychekScopedPrefsKey(_kEnabledBase);

  /// Activé par défaut ; l’utilisateur peut couper dans Réglages.
  static Future<bool> isEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kEnabled) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, value);
  }
}
