import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'stripe_entitlement_sync.dart';

/// Supprime le compte Firebase Auth + données Firestore (Cloud Function).
///
/// Lance [FirebaseFunctionsException] avec code `failed-precondition` si
/// `requires-recent-login` (reconnexion requise).
Future<void> deletePaychekUserAccountRemote() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('not_signed_in');
  }
  final fn = FirebaseFunctions.instanceFor(region: kPaychekFunctionsRegion);
  await fn.httpsCallable('deletePaychekUserAccount').call<Object?>();
}

String paychekDeleteAccountErrorMessage(FirebaseFunctionsException e) {
  if (e.code == 'failed-precondition' &&
      '${e.message}'.contains('requires-recent-login')) {
    return 'requires-recent-login';
  }
  return e.message ?? e.code;
}

String paychekDeleteAccountAuthErrorMessage(FirebaseAuthException e) {
  if (e.code == 'requires-recent-login') {
    return 'requires-recent-login';
  }
  return e.message ?? e.code;
}

Future<void> deletePaychekUserAccountFully() async {
  try {
    await deletePaychekUserAccountRemote();
  } on FirebaseFunctionsException catch (e, st) {
    debugPrint('[Paychek] deletePaychekUserAccountRemote: $e\n$st');
    rethrow;
  }
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e, st) {
    debugPrint('[Paychek] signOut after account delete: $e\n$st');
  }
}
