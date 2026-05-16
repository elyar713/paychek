import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import 'paychek_prefs_scope.dart';
import 'paychek_user_firestore.dart';
import 'trading_week_scope.dart';

/// Sync cloud de la préférence « semaine affichée » (5j / 7j).
///
/// Document : `paychek_users/{uid}/sync_data/trading_week_v1`.
abstract final class TradingWeekFirestoreSync {
  TradingWeekFirestoreSync._();

  static const _docId = 'trading_week_v1';
  static const _kRevBase = 'trading_week_rev_v1';

  static int _suppressPush = 0;

  static String _revPrefsKey() => paychekScopedPrefsKey(_kRevBase);

  static DocumentReference<Map<String, dynamic>> _doc(User u) =>
      FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(u.uid)
          .collection('sync_data')
          .doc(_docId);

  static Future<int> _readLocalRev() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_revPrefsKey()) ?? 0;
  }

  static Future<void> _writeLocalRev(int rev) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_revPrefsKey(), rev);
  }

  /// Fusionne le cloud dans [ctrl] si plus récent ; sinon pousse le local.
  static Future<void> mergeFromCloud(TradingWeekController ctrl) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      final snap = await _doc(u).get();
      if (!snap.exists) {
        await _pushFull(u, ctrl);
        return;
      }
      final data = snap.data();
      if (data == null) return;
      final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;
      final cloudDays = (data['days'] as num?)?.toInt();

      if (cloudRev > localRev) {
        if (cloudDays == 5 || cloudDays == 7) {
          await ctrl.applyFromCloud(cloudDays!);
        }
        await _writeLocalRev(cloudRev);
        return;
      }
      if (cloudRev < localRev) {
        await _pushFull(u, ctrl);
      }
    } catch (e, st) {
      debugPrint('[Paychek] TradingWeekFirestoreSync.merge: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  /// Applique une mise à jour reçue via `snapshots()` si le `rev` cloud est plus récent.
  static Future<void> handleRemoteSnapshot(
    TradingWeekController ctrl,
    Map<String, dynamic> data,
  ) async {
    final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;
    if (cloudRev <= 0) return;
    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      if (cloudRev <= localRev) return;
      final cloudDays = (data['days'] as num?)?.toInt();
      if (cloudDays == 5 || cloudDays == 7) {
        await ctrl.applyFromCloud(cloudDays!);
        await _writeLocalRev(cloudRev);
      }
    } catch (e, st) {
      debugPrint('[Paychek] TradingWeekFirestoreSync.remote: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  static Future<void> pushIfSignedIn(TradingWeekController ctrl) async {
    if (_suppressPush > 0) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    try {
      await _pushFull(u, ctrl);
    } catch (e, st) {
      debugPrint('[Paychek] TradingWeekFirestoreSync.push: $e\n$st');
    }
  }

  static Future<void> _pushFull(User u, TradingWeekController ctrl) async {
    final localRev = await _readLocalRev();
    final snap = await _doc(u).get();
    final cloudRev = snap.exists
        ? ((snap.data()?['rev'] as num?)?.toInt() ?? 0)
        : 0;
    final now = DateTime.now().microsecondsSinceEpoch;
    var rev = now;
    if (rev <= localRev || rev <= cloudRev) {
      rev = (localRev > cloudRev ? localRev : cloudRev) + 1;
    }
    await _doc(u).set(<String, dynamic>{
      'v': 1,
      'rev': rev,
      'days': ctrl.tradingDaysPerWeek,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _writeLocalRev(rev);
  }
}

