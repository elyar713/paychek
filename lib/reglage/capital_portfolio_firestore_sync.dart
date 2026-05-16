import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../questionnaire/user_capital_store.dart';
import 'paychek_firestore_push_guard.dart';
import 'paychek_prefs_scope.dart';
import 'paychek_user_firestore.dart';
import 'user_portfolio_store.dart';

/// Sync cloud du capital + liste de portefeuilles (web + mobile, même compte).
///
/// Document : `paychek_users/{uid}/sync_data/capital_portfolio_v1`.
/// Dernier réviseur gagne via [rev] (microsecondes), stocké aussi en prefs locale.
abstract final class CapitalPortfolioFirestoreSync {
  CapitalPortfolioFirestoreSync._();

  static const _docId = 'capital_portfolio_v1';
  static const _kBundleRev = 'capital_portfolio_bundle_rev_v1';

  static int _suppressPush = 0;

  /// Bloque les [pushIfSignedIn] pendant un rechargement de compte (évite d’écraser
  /// le cloud avec un capital vide entre `load()` et `mergeFromCloud()`).
  static Future<T> runWithPushSuppressed<T>(Future<T> Function() action) async =>
      PaychekFirestorePushGuard.runSuppressed(action);

  static String _revPrefsKey() => paychekScopedPrefsKey(_kBundleRev);

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

  /// Fusionne le cloud dans [capital] / [portfolio] si le doc est plus récent.
  static Future<void> mergeFromCloud(
    UserCapitalStore capital,
    UserPortfolioStore portfolio,
  ) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      final snap = await _doc(u).get();
      if (!snap.exists) {
        await _pushFull(u, capital, portfolio, allowWipeCloudCapital: true);
        return;
      }
      final data = snap.data();
      if (data == null) return;
      final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;

      if (cloudRev > localRev) {
        final capRaw = data['capital'];
        final capMap =
            capRaw is Map ? Map<String, dynamic>.from(capRaw) : null;
        await capital.applyFromFirestoreSnapshot(capMap);
        final rawList = data['portfolios'];
        final list = rawList is List ? rawList : <dynamic>[];
        final activeId = data['activePortfolioId'] as String?;
        await portfolio.applyFromFirestoreSnapshot(
          capital,
          list,
          activeId,
        );
        await _writeLocalRev(cloudRev);
        return;
      }
      if (cloudRev < localRev) {
        await PaychekFirestorePushGuard.adoptCloudWhenLocalRevAhead(
          localRev: localRev,
          cloudRev: cloudRev,
          label: 'CapitalPortfolioFirestoreSync',
          applyCloud: () async {
            final capRaw = data['capital'];
            final capMap =
                capRaw is Map ? Map<String, dynamic>.from(capRaw) : null;
            await capital.applyFromFirestoreSnapshot(capMap);
            final rawList = data['portfolios'];
            final list = rawList is List ? rawList : <dynamic>[];
            final activeId = data['activePortfolioId'] as String?;
            await portfolio.applyFromFirestoreSnapshot(
              capital,
              list,
              activeId,
            );
          },
          writeLocalRev: _writeLocalRev,
        );
      }
    } catch (e, st) {
      debugPrint('[Paychek] CapitalPortfolioFirestoreSync.merge: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  /// Applique une mise à jour reçue via `snapshots()` si le `rev` cloud est plus récent.
  static Future<void> handleRemoteSnapshot(
    Map<String, dynamic> data,
    UserCapitalStore capital,
    UserPortfolioStore portfolio,
  ) async {
    final cloudRev = (data['rev'] as num?)?.toInt() ?? 0;
    if (cloudRev <= 0) return;
    _suppressPush++;
    try {
      final localRev = await _readLocalRev();
      if (cloudRev <= localRev) return;
      final capRaw = data['capital'];
      final capMap = capRaw is Map ? Map<String, dynamic>.from(capRaw) : null;
      await capital.applyFromFirestoreSnapshot(capMap);
      final rawList = data['portfolios'];
      final list = rawList is List ? rawList : <dynamic>[];
      final activeId = data['activePortfolioId'] as String?;
      await portfolio.applyFromFirestoreSnapshot(capital, list, activeId);
      await _writeLocalRev(cloudRev);
    } catch (e, st) {
      debugPrint('[Paychek] CapitalPortfolioFirestoreSync.remote: $e\n$st');
    } finally {
      _suppressPush--;
    }
  }

  static Future<void> pushIfSignedIn(
    UserCapitalStore capital,
    UserPortfolioStore portfolio,
  ) async {
    if (_suppressPush > 0 || PaychekFirestorePushGuard.isSuppressed) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    try {
      await _pushFull(u, capital, portfolio, allowWipeCloudCapital: true);
    } catch (e, st) {
      debugPrint('[Paychek] CapitalPortfolioFirestoreSync.push: $e\n$st');
    }
  }

  static Future<void> _pushFull(
    User u,
    UserCapitalStore capital,
    UserPortfolioStore portfolio, {
    bool allowWipeCloudCapital = false,
  }) async {
    final localRev = await _readLocalRev();
    final snap = await _doc(u).get();
    final cloudData = snap.data();
    final cloudRev = snap.exists
        ? ((cloudData?['rev'] as num?)?.toInt() ?? 0)
        : 0;

    if (!allowWipeCloudCapital &&
        capital.capitalAmount == null &&
        snap.exists &&
        cloudData != null) {
      final capRaw = cloudData['capital'];
      if (capRaw is Map) {
        final cloudAmt = (capRaw['amount'] as num?)?.toDouble();
        if (cloudAmt != null &&
            !cloudAmt.isNaN &&
            !cloudAmt.isInfinite &&
            cloudAmt >= 0) {
          debugPrint(
            '[Paychek] CapitalPortfolioFirestoreSync.push skipped: '
            'local capital empty but cloud has $cloudAmt.',
          );
          return;
        }
      }
    }
    final now = DateTime.now().microsecondsSinceEpoch;
    var rev = now;
    if (rev <= localRev || rev <= cloudRev) {
      rev = (localRev > cloudRev ? localRev : cloudRev) + 1;
    }

    final cap = <String, dynamic>{
      'amount': capital.capitalAmount,
      'currencyCode': capital.currencyCode,
      'customName': capital.syncCustomCurrencyName,
      'customSymbol': capital.syncCustomCurrencySymbol,
    };
    final portMaps = portfolio.items.map((e) => e.toJson()).toList();

    await _doc(u).set(<String, dynamic>{
      'v': 1,
      'rev': rev,
      'capital': cap,
      'portfolios': portMaps,
      'activePortfolioId': portfolio.activePortfolioId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _writeLocalRev(rev);
  }
}
