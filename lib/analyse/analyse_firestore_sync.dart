import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_firestore_push_guard.dart';
import '../reglage/paychek_prefs_scope.dart';
import '../reglage/paychek_user_firestore.dart';
import 'analyse_report_snapshot.dart';
import 'analyse_report_snapshot_codec.dart';
import 'analyse_reports_storage.dart';
import 'analyse_starred_report_storage.dart';
import 'analyse_templates_storage.dart';
import 'analyse_realtime_notifier.dart';

/// Sync cloud de la page « Mon Analyse ».
///
/// Données synchronisées (bundle) :
/// - rapports validés (liste)
/// - rapport épinglé (dashboard)
/// - templates de contexte (puces)
///
/// Document : `paychek_users/{uid}/sync_data/analysis_v1`.
abstract final class AnalyseFirestoreSync {
  AnalyseFirestoreSync._();

  static const _docId = 'analysis_v1';
  static const _kRevBase = 'analysis_rev_v1';

  static int _suppressPush = 0;

  static String _revPrefsKey() => paychekScopedPrefsKey(_kRevBase);

  static DocumentReference<Map<String, dynamic>> _doc(User u) =>
      FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(u.uid)
          .collection('sync_data')
          .doc(_docId);

  static Future<void> mergeFromCloud() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _suppressPush++;
    try {
      final snap = await _doc(u).get();
      if (!snap.exists) {
        await _pushFull(u);
        return;
      }
      final data = snap.data();
      if (data == null) return;

      final cloudRev = (data['rev'] as num?)?.toInt();
      if (cloudRev == null) {
        // Ancien doc sans rev : adopter le cloud.
        await _applyCloudPayload(data);
        return;
      }

      final localRev = await _readLocalRev();
      if (cloudRev > localRev) {
        await _applyCloudPayload(data);
        await _writeLocalRev(cloudRev);
        return;
      }
      if (cloudRev < localRev) {
        await PaychekFirestorePushGuard.adoptCloudWhenLocalRevAhead(
          localRev: localRev,
          cloudRev: cloudRev,
          label: 'AnalyseFirestoreSync',
          applyCloud: () => _applyCloudPayload(data),
          writeLocalRev: _writeLocalRev,
        );
      }
    } catch (e, st) {
      debugPrint('[Paychek] AnalyseFirestoreSync.merge: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  /// Applique une mise à jour reçue via `snapshots()` si le `rev` cloud est plus récent.
  static Future<void> handleRemoteSnapshot(Map<String, dynamic> data) async {
    final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;
    if (cloudRev <= 0) return;
    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      if (cloudRev <= localRev) return;
      await _applyCloudPayload(data);
      await _writeLocalRev(cloudRev);
    } catch (e, st) {
      debugPrint('[Paychek] AnalyseFirestoreSync.remote: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  static Future<void> pushIfSignedIn() async {
    if (_suppressPush > 0 || PaychekFirestorePushGuard.isSuppressed) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    try {
      await _pushFull(u);
    } catch (e, st) {
      debugPrint('[Paychek] AnalyseFirestoreSync.push: $e\n$st');
    }
  }

  static Future<int> _readLocalRev() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_revPrefsKey()) ?? 0;
  }

  static Future<void> _writeLocalRev(int rev) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_revPrefsKey(), rev);
  }

  static Future<void> _pushFull(User u) async {
    final reports = await AnalyseReportsStorage.loadAll();
    final starred = await AnalyseStarredReportStorage.load();
    final templates = await AnalyseTemplatesStorage.loadAll();

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
        'reports': [for (final r in reports) encodeAnalyseReportSnapshot(r)],
        'templates': <String, dynamic>{
          'v': 2,
          'templates': templates,
        },
        'starred': starred != null ? encodeAnalyseReportSnapshot(starred) : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return rev;
    });

    // Local rev (cache) : s'aligne sur le rev cloud.
    await _writeLocalRev(nextRev);
    AnalyseRealtimeNotifier.bump();
  }

  static Future<void> _applyCloudPayload(Map<String, dynamic> data) async {
    final rawReports = data['reports'];
    if (rawReports is List) {
      final out = <AnalyseReportSnapshot>[];
      for (final e in rawReports) {
        if (e is Map) {
          try {
            out.add(decodeAnalyseReportSnapshot(Map<String, dynamic>.from(e)));
          } catch (_) {}
        }
      }
      await AnalyseReportsStorage.saveAll(out);
    }

    // Ne pas toucher au local si la clé est absente (anciens docs / payload partiel) :
    // avant : `data['starred'] == null` effaçait l’étoile à tort.
    if (data.containsKey('starred')) {
      final rawStar = data['starred'];
      if (rawStar == null) {
        await AnalyseStarredReportStorage.clear();
      } else if (rawStar is Map) {
        try {
          final snap =
              decodeAnalyseReportSnapshot(Map<String, dynamic>.from(rawStar));
          await AnalyseStarredReportStorage.save(snap);
        } catch (_) {}
      }
    }

    final rawTemplates = data['templates'];
    if (rawTemplates is Map) {
      final root = Map<String, dynamic>.from(rawTemplates);
      final t = root['templates'];
      if (root['v'] == 2 && t is Map) {
        final out = <String, Map<String, dynamic>>{};
        for (final e in t.entries) {
          if (e.value is Map) {
            final m = Map<String, dynamic>.from(e.value as Map);
            if (m['v'] == 1) out[e.key.toString()] = m;
          }
        }
        await AnalyseTemplatesStorage.saveAll(out);
      }
    }
    // Si [templates] est absent : ne pas effacer le local ; le dashboard relit quand même.
    AnalyseRealtimeNotifier.bumpReports();
    AnalyseRealtimeNotifier.bump();
  }
}

