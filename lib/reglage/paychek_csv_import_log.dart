import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'paychek_user_firestore.dart';

/// Sous-collection : `paychek_users/{uid}/csv_imports/{eventId}`
const String kPaychekCsvImportsSubcollection = 'csv_imports';

abstract final class PaychekCsvImportLogStatus {
  static const success = 'success';
  static const empty = 'empty';
  static const error = 'error';
}

/// Écrit une ligne de journal d’import (ne bloque pas l’UI si Firestore échoue).
Future<void> logPaychekUserCsvImportEvent({
  required String software,
  required String status,
  int tradeCount = 0,
  int skippedDuplicates = 0,
  int parsedRowCount = 0,
  String? message,
  String? fileName,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  var msg = message?.trim();
  if (msg != null && msg.length > 420) {
    msg = '${msg.substring(0, 420)}…';
  }
  try {
    await FirebaseFirestore.instance
        .collection(kPaychekUsersCollection)
        .doc(uid)
        .collection(kPaychekCsvImportsSubcollection)
        .add(<String, dynamic>{
      'software': software,
      'status': status,
      'tradeCount': tradeCount,
      'skippedDuplicates': skippedDuplicates,
      'parsedRowCount': parsedRowCount,
      if (msg != null && msg.isNotEmpty) 'message': msg,
      if (fileName != null && fileName.trim().isNotEmpty) 'fileName': fileName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (e, st) {
    debugPrint('[Paychek] logPaychekUserCsvImportEvent: $e\n$st');
  }
}

Query<Map<String, dynamic>> paychekCsvImportsQuery(String uid) => FirebaseFirestore
    .instance
    .collection(kPaychekUsersCollection)
    .doc(uid)
    .collection(kPaychekCsvImportsSubcollection)
    .orderBy('createdAt', descending: true)
    .limit(25);

/// Agrégation — une lecture légère pour l’admin (nombre d’entrées dans le journal).
/// Retourne `null` seulement si aucune stratégie ne réussit (réseau, règles, etc.).
Future<int?> paychekCsvImportsRecordedCount(String uid) async {
  final col = FirebaseFirestore.instance
      .collection(kPaychekUsersCollection)
      .doc(uid)
      .collection(kPaychekCsvImportsSubcollection);
  try {
    final agg = await col.count().get();
    final c = agg.count;
    if (c != null) return c;
  } catch (e, st) {
    debugPrint('[Paychek] paychekCsvImportsRecordedCount aggregate: $e\n$st');
  }
  try {
    final q = await col.limit(500).get();
    return q.docs.length;
  } catch (e2, st2) {
    debugPrint('[Paychek] paychekCsvImportsRecordedCount fallback get: $e2\n$st2');
    return null;
  }
}

/// Trie les documents d’historique CSV par [createdAt] (plus récent en premier).
List<QueryDocumentSnapshot<Map<String, dynamic>>> csvImportDocsNewestFirst(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  final out = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);
  int ms(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final ts = d.data()['createdAt'];
    if (ts is Timestamp) return ts.millisecondsSinceEpoch;
    return 0;
  }

  out.sort((a, b) => ms(b).compareTo(ms(a)));
  return out;
}
