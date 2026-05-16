import 'package:firebase_auth/firebase_auth.dart';

/// Construit une clé SharedPreferences isolée par compte.
///
/// - Priorité: `uid` (stable) → email (si uid absent) → `guest`.
/// - Objectif: éviter que plusieurs comptes sur le même device/web partagent les mêmes données locales.
String paychekScopedPrefsKey(String baseKey) {
  final u = FirebaseAuth.instance.currentUser;
  final uid = u?.uid.trim();
  if (uid != null && uid.isNotEmpty) {
    return '${baseKey}__uid__$uid';
  }
  final email = (u?.email ?? '').trim().toLowerCase();
  if (email.isNotEmpty) {
    return '${baseKey}__email__$email';
  }
  return '${baseKey}__guest';
}

/// Même suffixe que [paychekScopedPrefsKey] pour un **uid Firebase** connu
/// (ex. sauvegarde du journal juste après déconnexion, quand [currentUser] est déjà null).
String paychekScopedPrefsKeyForUid(String baseKey, String firebaseUid) {
  final u = firebaseUid.trim();
  if (u.isEmpty) return '${baseKey}__guest';
  return '${baseKey}__uid__$u';
}
