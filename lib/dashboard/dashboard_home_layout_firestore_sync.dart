import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import '../reglage/paychek_user_firestore.dart';
import 'dashboard_home_layout_keys.dart';
import 'dashboard_home_layout_store.dart';

/// Sync cloud du layout d’accueil (ordre + activation des sections).
///
/// Document : `paychek_users/{uid}/sync_data/dashboard_home_layout_v1`.
abstract final class DashboardHomeLayoutFirestoreSync {
  DashboardHomeLayoutFirestoreSync._();

  static const _docId = 'dashboard_home_layout_v1';
  static const _kRevBase = 'dashboard_home_layout_rev_v1';

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

  static Future<void> mergeFromCloud(DashboardHomeLayoutStore store) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      final snap = await _doc(u).get();
      if (!snap.exists) {
        await _pushFull(u, store);
        return;
      }
      final data = snap.data();
      if (data == null) return;
      final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;

      if (cloudRev > localRev) {
        final rawOrder = data['order'];
        final rawEnabled = data['enabled'];
        final order = <String>[];
        if (rawOrder is List) {
          for (final e in rawOrder) {
            final id = e.toString();
            if (DashboardHomeLayoutKeys.defaultOrder.contains(id) &&
                !order.contains(id)) {
              order.add(id);
            }
          }
        }
        for (final id in DashboardHomeLayoutKeys.defaultOrder) {
          if (!order.contains(id)) order.add(id);
        }

        final enabled = <String, bool>{};
        if (rawEnabled is Map) {
          for (final id in DashboardHomeLayoutKeys.defaultOrder) {
            final v = rawEnabled[id];
            if (v is bool) enabled[id] = v;
          }
        }
        await store.applyFromCloud(order: order, enabled: enabled);
        await _writeLocalRev(cloudRev);
        return;
      }
      if (cloudRev < localRev) {
        await _pushFull(u, store);
      }
    } catch (e, st) {
      debugPrint('[Paychek] DashboardHomeLayoutFirestoreSync.merge: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  /// Applique une mise à jour reçue via `snapshots()` si le `rev` cloud est plus récent.
  static Future<void> handleRemoteSnapshot(
    DashboardHomeLayoutStore store,
    Map<String, dynamic> data,
  ) async {
    final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;
    if (cloudRev <= 0) return;
    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      if (cloudRev <= localRev) return;
      final rawOrder = data['order'];
      final rawEnabled = data['enabled'];
      final order = <String>[];
      if (rawOrder is List) {
        for (final e in rawOrder) {
          final id = e.toString();
          if (DashboardHomeLayoutKeys.defaultOrder.contains(id) &&
              !order.contains(id)) {
            order.add(id);
          }
        }
      }
      for (final id in DashboardHomeLayoutKeys.defaultOrder) {
        if (!order.contains(id)) order.add(id);
      }

      final enabled = <String, bool>{};
      if (rawEnabled is Map) {
        for (final id in DashboardHomeLayoutKeys.defaultOrder) {
          final v = rawEnabled[id];
          if (v is bool) enabled[id] = v;
        }
      }
      await store.applyFromCloud(order: order, enabled: enabled);
      await _writeLocalRev(cloudRev);
    } catch (e, st) {
      debugPrint('[Paychek] DashboardHomeLayoutFirestoreSync.remote: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  static Future<void> pushIfSignedIn(DashboardHomeLayoutStore store) async {
    if (_suppressPush > 0) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    try {
      await _pushFull(u, store);
    } catch (e, st) {
      debugPrint('[Paychek] DashboardHomeLayoutFirestoreSync.push: $e\n$st');
    }
  }

  static Future<void> _pushFull(User u, DashboardHomeLayoutStore store) async {
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
    final snapshot = store.toCloudSnapshot();
    await _doc(u).set(<String, dynamic>{
      'v': 1,
      'rev': rev,
      ...snapshot,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _writeLocalRev(rev);
  }
}
