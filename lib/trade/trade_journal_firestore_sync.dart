import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../reglage/paychek_user_firestore.dart';
import 'trade_journal_storage.dart';
import 'trade_journal_store.dart';
import 'trade_models.dart';

/// Sync cloud du journal de trades (même compte Firebase sur web + mobile).
///
/// Document unique : `paychek_users/{uid}/sync_data/journal_trades_v1`.
/// Les captures ne sont pas envoyées en base64 (taille) ; elles restent en prefs locale.
abstract final class TradeJournalFirestoreSync {
  TradeJournalFirestoreSync._();

  static const _docId = 'journal_trades_v1';

  /// Une seule fusion à la fois : plusieurs [snapshots] en parallèle empilent des listes
  /// (pics mémoire / GC ~centaines de Mo sur appareils modestes).
  static Future<void> _remoteApplyChain = Future<void>.value();

  static DocumentReference<Map<String, dynamic>> _doc(User u) =>
      FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(u.uid)
          .collection('sync_data')
          .doc(_docId);

  /// Fusionne le cloud dans [store] puis ré-écrit prefs + cloud avec l’union.
  static Future<void> mergeFromCloudIntoStore(TradeJournalStore store) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    try {
      final snap = await _doc(u).get();
      await _mergeSnapshotIntoStore(u, store, snap, echoPushToCloud: true);
    } catch (e, st) {
      debugPrint('[Paychek] TradeJournalFirestoreSync.merge: $e\n$st');
    }
  }

  /// Même logique que [mergeFromCloudIntoStore], pour une mise à jour **snapshots()** temps réel.
  ///
  /// **Ne réécrit pas** le document Firestore ici : sinon chaque snapshot déclencherait un `set`,
  /// un nouveau snapshot, boucle infinie et surcharge mémoire (écran noir après hot restart).
  static Future<void> handleRemoteSnapshot(
    TradeJournalStore store,
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _remoteApplyChain = _remoteApplyChain.then((_) async {
      if (FirebaseAuth.instance.currentUser?.uid != u.uid) return;
      try {
        await _mergeSnapshotIntoStore(u, store, snap, echoPushToCloud: false);
      } catch (e, st) {
        debugPrint('[Paychek] TradeJournalFirestoreSync.remote: $e\n$st');
      }
    }).catchError((Object e, StackTrace st) {
      debugPrint('[Paychek] TradeJournalFirestoreSync.remote chain: $e\n$st');
    });
    await _remoteApplyChain;
  }

  static Future<void> _mergeSnapshotIntoStore(
    User u,
    TradeJournalStore store,
    DocumentSnapshot<Map<String, dynamic>> snap, {
    required bool echoPushToCloud,
  }) async {
    // Listener : doc absent → ne pas pousser ici (store souvent encore vide avant hydratation ;
    // la création cloud est faite par [mergeFromCloudIntoStore] avec echo).
    if (!snap.exists) {
      if (echoPushToCloud) {
        await pushFullJournal(u, List<TradeListItem>.from(store.items));
      }
      return;
    }
    final data = snap.data();
    if (data == null) return;
    final rawItems = data['items'];
    if (rawItems is! List) return;
    final cloud = <TradeListItem>[];
    for (final e in rawItems) {
      if (e is! Map) continue;
      final t = tradeJournalTradeFromMap(Map<String, dynamic>.from(e));
      if (t != null) cloud.add(t);
    }
    final local = List<TradeListItem>.from(store.items);
    final merged = _mergeBySyncRev(local, cloud);
    final changed = !_sameTradeIdsAndRevs(local, merged);
    if (changed) {
      store.replaceAll(merged);
      await TradeJournalStorage.save(merged);
    }
    // Hydratation : pousser seulement si l’union diffère du contenu cloud (ex. trades locaux
    // absents du cloud). Si le merge n’a fait qu’importer le cloud, un `set` serait inutile
    // et redéclencherait des snapshots / GC.
    if (echoPushToCloud && !_sameTradeIdsAndRevs(cloud, merged)) {
      await pushFullJournal(u, List<TradeListItem>.from(store.items));
    }
  }

  static Future<void> pushFullJournal(User u, List<TradeListItem> items) async {
    final cloudMaps = <Map<String, dynamic>>[
      for (final t in items) tradeJournalTradeToMapForFirestore(t),
    ];
    await _doc(u).set(<String, dynamic>{
      'v': 1,
      'items': cloudMaps,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> pushIfSignedIn(List<TradeListItem> items) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    try {
      await pushFullJournal(u, items);
    } catch (e, st) {
      debugPrint('[Paychek] TradeJournalFirestoreSync.push: $e\n$st');
    }
  }

  static List<TradeListItem> _mergeBySyncRev(
    List<TradeListItem> local,
    List<TradeListItem> cloud,
  ) {
    final byId = <String, TradeListItem>{};
    for (final t in cloud) {
      byId[t.id] = t;
    }
    for (final t in local) {
      final c = byId[t.id];
      if (c == null) {
        byId[t.id] = t;
        continue;
      }
      TradeListItem winner;
      if (t.syncRev > c.syncRev) {
        winner = t;
      } else if (c.syncRev > t.syncRev) {
        winner = c;
      } else {
        winner = c;
      }
      if ((winner.screenshotBytes == null || winner.screenshotBytes!.isEmpty)) {
        final bytes = t.screenshotBytes ?? c.screenshotBytes;
        if (bytes != null && bytes.isNotEmpty) {
          winner = winner.copyWith(screenshotBytes: bytes);
        }
      }
      byId[t.id] = winner;
    }
    final out = byId.values.toList();
    out.sort((a, b) => b.entreeAt.compareTo(a.entreeAt));
    return out;
  }

  static bool _sameTradeIdsAndRevs(List<TradeListItem> a, List<TradeListItem> b) {
    if (a.length != b.length) return false;
    final bm = {for (final t in b) t.id: t.syncRev};
    for (final t in a) {
      if (bm[t.id] != t.syncRev) return false;
    }
    return true;
  }
}
