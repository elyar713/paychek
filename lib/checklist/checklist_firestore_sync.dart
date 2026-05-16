import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_firestore_push_guard.dart';
import '../reglage/paychek_prefs_scope.dart';
import '../reglage/paychek_user_firestore.dart';
import 'checklist_models.dart';
import 'checklist_realtime_notifier.dart';
import 'checklist_sections_storage.dart';

/// Sync cloud de la checklist « Nouveau trade » (sections + lignes + coches).
///
/// Document : `paychek_users/{uid}/sync_data/checklist_nouveau_trade_v1`.
abstract final class ChecklistFirestoreSync {
  ChecklistFirestoreSync._();

  static const _docId = 'checklist_nouveau_trade_v1';
  static const _kRevBase = 'checklist_nouveau_trade_rev_v1';

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

  static List<ChecklistSectionData>? _sectionsFromData(Map<String, dynamic> data) {
    final raw = data['sections'];
    return ChecklistSectionsStorage.decodeSectionsList(raw);
  }

  /// Au démarrage / changement de compte : fusionne le cloud dans les prefs.
  static Future<void> mergeFromCloud() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      final snap = await _doc(u).get();
      if (!snap.exists) {
        await _pushFull(u);
        return;
      }
      final data = snap.data();
      if (data == null) return;
      final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;

      if (cloudRev > localRev) {
        final sections = _sectionsFromData(data);
        if (sections != null) {
          await ChecklistSectionsStorage.save(sections);
          await _writeLocalRev(cloudRev);
          ChecklistRealtimeNotifier.bump();
        }
        return;
      }
      if (cloudRev < localRev) {
        await PaychekFirestorePushGuard.adoptCloudWhenLocalRevAhead(
          localRev: localRev,
          cloudRev: cloudRev,
          label: 'ChecklistFirestoreSync',
          applyCloud: () async {
            final sections = _sectionsFromData(data);
            if (sections != null) {
              await ChecklistSectionsStorage.save(sections);
            }
          },
          writeLocalRev: _writeLocalRev,
          afterApply: () async => ChecklistRealtimeNotifier.bump(),
        );
      }
    } catch (e, st) {
      debugPrint('[Paychek] ChecklistFirestoreSync.merge: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  /// Listener `snapshots()` : applique si `rev` cloud plus récent.
  static Future<void> handleRemoteSnapshot(Map<String, dynamic> data) async {
    final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;
    if (cloudRev <= 0) return;
    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      if (cloudRev <= localRev) return;
      final sections = _sectionsFromData(data);
      if (sections == null) return;
      await ChecklistSectionsStorage.save(sections);
      await _writeLocalRev(cloudRev);
      ChecklistRealtimeNotifier.bump();
    } catch (e, st) {
      debugPrint('[Paychek] ChecklistFirestoreSync.remote: $e\n$st');
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
      debugPrint('[Paychek] ChecklistFirestoreSync.push: $e\n$st');
    }
  }

  static Future<void> _pushFull(User u) async {
    final localRev = await _readLocalRev();
    final snap = await _doc(u).get();
    final cloudData = snap.data();
    final cloudRev = snap.exists
        ? ((cloudData?['rev'] as num?)?.toInt() ?? 0)
        : 0;

    var sections = await ChecklistSectionsStorage.load();
    if (sections == null || sections.isEmpty) {
      final cloudSections =
          cloudData != null ? _sectionsFromData(cloudData) : null;
      if (cloudSections != null && cloudSections.isNotEmpty) {
        debugPrint(
          '[Paychek] ChecklistFirestoreSync.push skipped: '
          'local empty but cloud has checklist data.',
        );
        return;
      }
      sections = defaultNouveauTradeSections();
      await ChecklistSectionsStorage.save(sections);
    }

    var rev = DateTime.now().microsecondsSinceEpoch;
    if (rev <= localRev || rev <= cloudRev) {
      rev = (localRev > cloudRev ? localRev : cloudRev) + 1;
    }

    final encoded = <Map<String, dynamic>>[
      for (final s in sections)
        <String, dynamic>{
          'id': s.id,
          'title': s.title,
          'items': [
            for (final i in s.items)
              <String, dynamic>{
                'id': i.id,
                'label': i.label,
                'checked': i.checked,
              },
          ],
        },
    ];

    await _doc(u).set(<String, dynamic>{
      'v': 1,
      'rev': rev,
      'sections': encoded,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _writeLocalRev(rev);
    ChecklistRealtimeNotifier.bump();
  }
}
