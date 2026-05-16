import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'paychek_client_platform.dart';
import 'paychek_user_firestore.dart';

/// Résultat du contrôle administrateur (accès web / mobile).
enum PaychekRemoteAccessBlock {
  webDisabled,
  mobileDisabled,
}

/// Lit `paychek_users/{uid}` après sync client : si l’admin a désactivé cette plateforme,
/// l’app doit refuser l’accès (`null` = pas de blocage ou erreur réseau).
Future<PaychekRemoteAccessBlock?> evaluatePaychekRemoteAccess(User user) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(user.uid)
        .get();
    if (!snap.exists) return null;
    final d = snap.data();
    if (d == null) return null;

    final label = PaychekClientPlatform.currentSyncLabel();
    if (label == 'web') {
      if (d['accessWebEnabled'] == false) return PaychekRemoteAccessBlock.webDisabled;
      return null;
    }
    if (label == 'android' || label == 'ios') {
      if (d['accessMobileEnabled'] == false) {
        return PaychekRemoteAccessBlock.mobileDisabled;
      }
      return null;
    }
    return null;
  } catch (_) {
    return null;
  }
}
