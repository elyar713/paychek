import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_firestore_push_guard.dart';
import '../reglage/paychek_prefs_scope.dart';
import '../reglage/paychek_user_firestore.dart';
import 'strategie_gestion_risque_storage.dart';
import 'strategie_horaires_sessions_storage.dart';
import 'strategie_mes_regles_storage.dart';
import 'strategie_setups_store.dart';
import 'strategie_setup_storage_codec.dart';
import 'strategie_setup_usage_store.dart';
import 'strategie_starred_setup_storage.dart';
import 'strategie_realtime_notifier.dart';
import 'widgets/strategie_setup_card.dart';

/// Sync cloud de la page « Ma Stratégie » (setups + calendrier usage + horaires + risque + favori).
///
/// Document : `paychek_users/{uid}/sync_data/strategie_v1`.
abstract final class StrategieFirestoreSync {
  StrategieFirestoreSync._();

  static const _docId = 'strategie_v1';
  static const _kRevBase = 'strategie_rev_v1';

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

  static Future<void> mergeFromCloud() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _suppressPush++;
    try {
      await StrategieSetupsStore.ensureLoaded();
      await StrategieSetupUsageStore.ensureLoaded();
      await StrategieMesReglesStore.ensureLoaded();

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
        await _applyCloudPayload(data);
        await _writeLocalRev(cloudRev);
        return;
      }
      if (cloudRev < localRev) {
        await PaychekFirestorePushGuard.adoptCloudWhenLocalRevAhead(
          localRev: localRev,
          cloudRev: cloudRev,
          label: 'StrategieFirestoreSync',
          applyCloud: () => _applyCloudPayload(data),
          writeLocalRev: _writeLocalRev,
          afterApply: () async => StrategieRealtimeNotifier.bump(),
        );
      }
    } catch (e, st) {
      debugPrint('[Paychek] StrategieFirestoreSync.merge: $e\n$st');
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
      await StrategieSetupsStore.ensureLoaded();
      await StrategieSetupUsageStore.ensureLoaded();
      await StrategieMesReglesStore.ensureLoaded();
      final localRev = await _readLocalRev();
      if (cloudRev <= localRev) return;
      await _applyCloudPayload(data);
      await _writeLocalRev(cloudRev);
    } catch (e, st) {
      debugPrint('[Paychek] StrategieFirestoreSync.remote: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  /// [riskOverride] / [sessionsOverride] : valeurs fraîches en mémoire (évite une course
  /// avec SharedPreferences si le push part juste après un `save` local).
  static Future<void> pushIfSignedIn({
    StrategieGestionRisqueParams? riskOverride,
    List<StrategieSessionPersisted>? sessionsOverride,
  }) async {
    if (_suppressPush > 0 || PaychekFirestorePushGuard.isSuppressed) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    try {
      await _pushFull(
        u,
        riskOverride: riskOverride,
        sessionsOverride: sessionsOverride,
      );
    } catch (e, st) {
      debugPrint('[Paychek] StrategieFirestoreSync.push: $e\n$st');
    }
  }

  static Future<void> _pushFull(
    User u, {
    StrategieGestionRisqueParams? riskOverride,
    List<StrategieSessionPersisted>? sessionsOverride,
  }) async {
    await StrategieSetupsStore.ensureLoaded();
    await StrategieSetupUsageStore.ensureLoaded();
    await StrategieMesReglesStore.ensureLoaded();
    final setups = StrategieSetupsStore.notifier.value;
    final usage = StrategieSetupUsageStore.notifier.value;
    final sessions =
        sessionsOverride ?? await StrategieHorairesSessionsStorage.load();
    final risk = riskOverride ?? await StrategieGestionRisqueStorage.load();
    final goldenRules = StrategieMesReglesStore.notifier.value;
    final starred = await StrategieStarredSetupStorage.load();

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

    final payload = <String, dynamic>{
      'v': 1,
      'rev': rev,
      'setups': [for (final s in setups) encodeStrategieSetupCardData(s)],
      'usage': {
        for (final e in usage.entries) e.key: (e.value.toList()..sort()),
      },
      'sessions': [for (final s in sessions) s.toJson()],
      'risk': <String, dynamic>{
        'riskPct': risk.riskPct,
        'lossPct': risk.lossPct,
        'tradesPerDay': risk.tradesPerDay,
        'rrRatio': risk.rrRatio,
      },
      'goldenRules': <String, dynamic>{
        'isCustom': goldenRules.isCustom,
        'sectionTitle': goldenRules.sectionTitle,
        'rules': goldenRules.rules,
      },
      if (starred != null) 'starred': encodeStrategieSetupCardData(starred),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _doc(u).set(payload);
    await _writeLocalRev(rev);
    StrategieRealtimeNotifier.bump();
  }

  static Future<void> _applyCloudPayload(Map<String, dynamic> data) async {
    final rawSetups = data['setups'];
    if (rawSetups is List) {
      final out = <StrategieSetupCardData>[];
      for (final e in rawSetups) {
        if (e is Map) {
          try {
            out.add(decodeStrategieSetupCardData(Map<String, dynamic>.from(e)));
          } catch (_) {}
        }
      }
      if (out.isNotEmpty) {
        await StrategieSetupsStore.setAll(out);
      } else {
        await StrategieSetupsStore.setAll(const <StrategieSetupCardData>[]);
      }
    }

    final rawUsage = data['usage'];
    if (rawUsage is Map) {
      final out = <String, Set<int>>{};
      for (final e in rawUsage.entries) {
        final k = e.key.toString();
        final v = e.value;
        if (v is List) {
          out[k] = {
            for (final x in v)
              if (x is int) x else int.tryParse('$x') ?? 0,
          }..removeWhere((dk) => dk <= 0);
        }
      }
      await StrategieSetupUsageStore.setAll(out);
    }

    final rawSessions = data['sessions'];
    if (rawSessions is List) {
      final out = <StrategieSessionPersisted>[];
      for (final e in rawSessions) {
        if (e is Map<String, dynamic>) {
          final s = StrategieSessionPersisted.fromJson(e);
          if (s != null) out.add(s);
        } else if (e is Map) {
          final s = StrategieSessionPersisted.fromJson(
            Map<String, dynamic>.from(e),
          );
          if (s != null) out.add(s);
        }
      }
      if (out.isNotEmpty) {
        await StrategieHorairesSessionsStorage.save(out);
      }
    }

    final rawRisk = data['risk'];
    if (rawRisk is Map) {
      final m = Map<String, dynamic>.from(rawRisk);
      final params = StrategieGestionRisqueParams(
        riskPct: (m['riskPct'] as num?)?.toDouble() ??
            StrategieGestionRisqueParams.defaults.riskPct,
        lossPct: (m['lossPct'] as num?)?.toDouble() ??
            StrategieGestionRisqueParams.defaults.lossPct,
        tradesPerDay: (m['tradesPerDay'] as num?)?.toInt() ??
            StrategieGestionRisqueParams.defaults.tradesPerDay,
        rrRatio: (m['rrRatio'] as num?)?.toDouble() ??
            StrategieGestionRisqueParams.defaults.rrRatio,
      );
      await StrategieGestionRisqueStorage.save(params);
    }

    final rawGolden = data['goldenRules'];
    if (rawGolden is Map) {
      final m = Map<String, dynamic>.from(rawGolden);
      final isCustom = m['isCustom'] as bool? ?? false;
      if (isCustom) {
        final title = (m['sectionTitle'] as String?)?.trim();
        final rulesRaw = m['rules'];
        final rules = <String>[];
        if (rulesRaw is List) {
          for (final e in rulesRaw) {
            final t = '$e'.trim();
            if (t.isNotEmpty) rules.add(t);
          }
        }
        if (title != null && title.isNotEmpty) {
          await StrategieMesReglesStore.applyFromCloud(
            sectionTitle: title.toUpperCase(),
            rules: rules,
            isCustom: true,
          );
        }
      } else {
        await StrategieMesReglesStore.applyFromCloud(
          sectionTitle: '',
          rules: const [],
          isCustom: false,
        );
      }
    }

    if (data.containsKey('starred')) {
      final rawStarred = data['starred'];
      if (rawStarred == null) {
        await StrategieStarredSetupStorage.clear();
      } else if (rawStarred is Map) {
      try {
        final decoded = decodeStrategieSetupCardData(
          Map<String, dynamic>.from(rawStarred),
        );
        await StrategieStarredSetupStorage.save(decoded);
      } catch (_) {}
      }
    }

    StrategieRealtimeNotifier.bump();
  }
}

