import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';

/// État local du questionnaire par compte Firebase (indépendant du cache Firestore).
abstract final class QuestionnaireCompletionPrefs {
  QuestionnaireCompletionPrefs._();

  static const _kDoneBase = 'paychek_questionnaire_done_v1';
  static const _kPendingBase = 'paychek_questionnaire_pending_v1';

  static String _doneKey(String uid) =>
      paychekScopedPrefsKeyForUid(_kDoneBase, uid);

  static String _pendingKey(String uid) =>
      paychekScopedPrefsKeyForUid(_kPendingBase, uid);

  static Future<bool> isLocallyCompleted(String uid) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_doneKey(uid)) ?? false;
  }

  static Future<bool> isLocallyPending(String uid) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_pendingKey(uid)) ?? false;
  }

  /// Nouvelle inscription : questionnaire obligatoire sur cet appareil.
  static Future<void> markIncomplete(String uid) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_pendingKey(uid), true);
    await p.remove(_doneKey(uid));
  }

  /// Fin du flux questionnaire + capital.
  static Future<void> markCompleted(String uid) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_doneKey(uid), true);
    await p.remove(_pendingKey(uid));
  }
}
