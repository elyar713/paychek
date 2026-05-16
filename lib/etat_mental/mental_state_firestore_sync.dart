import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import '../reglage/paychek_user_firestore.dart';
import 'mental_state_controller.dart';
import 'mental_state_storage.dart';

/// Sync cloud de la page État mental (curseurs + poids + mini-calendrier).
///
/// Document : `paychek_users/{uid}/sync_data/mental_state_v1`.
abstract final class MentalStateFirestoreSync {
  MentalStateFirestoreSync._();

  static const _docId = 'mental_state_v1';
  static const _kRevBase = 'mental_state_rev_v1';

  static int _suppressPush = 0;

  /// Dernier `rev` cloud déjà pris en compte sur **cet** appareil (évite qu’un snapshot
  /// ancien traité en retard écrase un état plus récent — web/mobile en parallèle).
  static int _lastHandledRemoteRev = 0;

  /// `snapshots()` : traitement **séquentiel** pour respecter l’ordre des `rev`.
  static Future<void> _remoteSnapshotChain = Future.value();

  static String? _syncUid;

  static String _revPrefsKey() => paychekScopedPrefsKey(_kRevBase);

  static void _ensureUidForSync(String uid) {
    if (_syncUid == uid) return;
    _syncUid = uid;
    _lastHandledRemoteRev = 0;
  }

  static void _bumpHandledRemoteRev(int rev) {
    if (rev > _lastHandledRemoteRev) _lastHandledRemoteRev = rev;
  }

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

  static Future<void> mergeFromCloud(MentalStateController ctrl) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _ensureUidForSync(u.uid);
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

      if (cloudRev > localRev) {
        final bundleRaw = data['bundle'];
        final bundle = bundleRaw is Map
            ? Map<String, dynamic>.from(bundleRaw)
            : null;
        if (bundle != null) {
          await ctrl.applyFromCloudBundle(bundle);
        }
        await _writeLocalRev(cloudRev);
        _bumpHandledRemoteRev(cloudRev);
        return;
      }
      _bumpHandledRemoteRev(cloudRev);
      if (cloudRev < localRev) {
        await _pushFull(u, ctrl);
      }
    } catch (e, st) {
      debugPrint('[Paychek] MentalStateFirestoreSync.merge: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  /// Applique une mise à jour reçue via `snapshots()` si le `rev` cloud est plus récent.
  static void handleRemoteSnapshot(
    MentalStateController ctrl,
    Map<String, dynamic> data,
  ) {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _ensureUidForSync(u.uid);

    _remoteSnapshotChain = _remoteSnapshotChain
        .then((_) => _handleRemoteSnapshotOnce(ctrl, data))
        .catchError((Object e, StackTrace st) {
      debugPrint('[Paychek] MentalStateFirestoreSync.remote chain: $e\n$st');
    });
  }

  static Future<void> _handleRemoteSnapshotOnce(
    MentalStateController ctrl,
    Map<String, dynamic> data,
  ) async {
    final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;
    if (cloudRev <= 0) return;

    if (cloudRev < _lastHandledRemoteRev) {
      return;
    }

    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      if (cloudRev <= localRev) {
        _bumpHandledRemoteRev(cloudRev);
        return;
      }
      final bundleRaw = data['bundle'];
      final bundle =
          bundleRaw is Map ? Map<String, dynamic>.from(bundleRaw) : null;
      if (bundle != null) {
        await ctrl.applyFromCloudBundle(bundle);
        await _writeLocalRev(cloudRev);
        _bumpHandledRemoteRev(cloudRev);
      }
    } catch (e, st) {
      debugPrint('[Paychek] MentalStateFirestoreSync.remote: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  static Future<void> pushIfSignedIn(MentalStateController ctrl) async {
    if (_suppressPush > 0) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    try {
      await _pushFull(u, ctrl);
    } catch (e, st) {
      debugPrint('[Paychek] MentalStateFirestoreSync.push: $e\n$st');
    }
  }

  static Future<void> _pushFull(User u, MentalStateController ctrl) async {
    final bundle = ctrl.toCloudBundle();
    await MentalStateStorage.saveBundleMap(bundle);

    // IMPORTANT: utiliser une transaction pour générer un `rev` monotone côté serveur
    // (évite les conflits dus aux horloges client différentes entre Web / Android / iOS).
    final ref = _doc(u);
    final nextRev = await FirebaseFirestore.instance.runTransaction<int>((txn) async {
      final snap = await txn.get(ref);
      final current = snap.exists
          ? ((snap.data()?['rev'] as num?)?.toInt() ?? 0)
          : 0;
      final rev = current + 1;
      txn.set(ref, <String, dynamic>{
        'v': 1,
        'rev': rev,
        'bundle': bundle,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return rev;
    });
    await _writeLocalRev(nextRev);
    _bumpHandledRemoteRev(nextRev);
  }
}

