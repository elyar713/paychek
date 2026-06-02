import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';

/// Affichage unique de l’avertissement « données démo » après une nouvelle inscription.
abstract final class JournalDemoNoticePrefs {
  JournalDemoNoticePrefs._();

  static const _kPendingBase = 'paychek_journal_demo_notice_pending_v1';

  static String _pendingKey(String uid) =>
      paychekScopedPrefsKeyForUid(_kPendingBase, uid);

  /// À appeler après inscription (e-mail ou réseau social, nouveau compte).
  static Future<void> markPendingAfterSignup(String uid) async {
    final id = uid.trim();
    if (id.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_pendingKey(id), true);
  }

  /// `true` une seule fois si l’avertissement était en attente (consomme le flag).
  static Future<bool> consumePending(String uid) async {
    final id = uid.trim();
    if (id.isEmpty) return false;
    final p = await SharedPreferences.getInstance();
    final key = _pendingKey(id);
    if (p.getBool(key) != true) return false;
    await p.remove(key);
    return true;
  }
}
