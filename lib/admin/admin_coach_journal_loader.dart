import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../reglage/paychek_user_firestore.dart';
import '../reglage/user_portfolio_models.dart';
import '../trade/trade_journal_storage.dart';
import '../trade/trade_models.dart';

/// Sync Firestore temps réel d’un compte **app** pour le labo Coach admin.
abstract final class AdminCoachJournalLoader {
  static const _journalDocId = 'journal_trades_v1';
  static const _portfolioDocId = 'capital_portfolio_v1';

  static DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .doc(uid.trim());

  /// Résout l’UID à partir de l’e-mail `paychek_users.email`.
  static Future<String?> resolveUidByEmail(String email) async {
    final raw = email.trim();
    if (raw.isEmpty) return null;
    final tries = <String>{
      raw,
      raw.toLowerCase(),
    };
    for (final e in tries) {
      final snap = await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .where('email', isEqualTo: e)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) return snap.docs.first.id;
    }
    return null;
  }

  static Future<List<({String id, String email})>> fetchRecentAppUsers({
    int limit = 40,
  }) async {
    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .orderBy('lastSeenAt', descending: true)
          .limit(limit)
          .get();
    } catch (_) {
      snap = await FirebaseFirestore.instance
          .collection(kPaychekUsersCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
    }
    final out = <({String id, String email})>[];
    for (final doc in snap.docs) {
      final email = '${doc.data()['email'] ?? ''}'.trim();
      out.add((id: doc.id, email: email.isEmpty ? doc.id : email));
    }
    return out;
  }

  static List<TradeListItem> parseTradesFromData(Map<String, dynamic>? data) {
    if (data == null) return const [];
    final rawItems = data['items'];
    if (rawItems is! List) return const [];
    final out = <TradeListItem>[];
    for (final e in rawItems) {
      if (e is! Map) continue;
      final t = tradeJournalTradeFromMap(Map<String, dynamic>.from(e));
      if (t != null) out.add(t);
    }
    return out;
  }

  static Future<List<TradeListItem>> loadTradesForUid(String uid) async {
    final id = uid.trim();
    if (id.isEmpty) return const [];
    final snap = await _userDoc(id)
        .collection('sync_data')
        .doc(_journalDocId)
        .get();
    return parseTradesFromData(snap.data());
  }

  static ({List<UserPortfolio> portfolios, String? activePortfolioId})
      parsePortfoliosFromData(Map<String, dynamic>? data) {
    if (data == null) {
      return (portfolios: const <UserPortfolio>[], activePortfolioId: null);
    }
    final rawList = data['portfolios'];
    final portfolios = <UserPortfolio>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is! Map) continue;
        try {
          portfolios.add(
            UserPortfolio.fromJson(Map<String, dynamic>.from(e)),
          );
        } catch (_) {}
      }
    }
    final activeId = data['activePortfolioId'] as String?;
    return (portfolios: portfolios, activePortfolioId: activeId);
  }

  static Future<({List<UserPortfolio> portfolios, String? activePortfolioId})>
      loadPortfoliosForUid(String uid) async {
    final id = uid.trim();
    if (id.isEmpty) {
      return (portfolios: const <UserPortfolio>[], activePortfolioId: null);
    }
    final snap = await _userDoc(id)
        .collection('sync_data')
        .doc(_portfolioDocId)
        .get();
    return parsePortfoliosFromData(snap.data());
  }

  static Set<String> portfolioIdsIn(Iterable<TradeListItem> trades) =>
      trades.map((t) => t.portfolioId).toSet();

  /// Écoute `journal_trades_v1` + `capital_portfolio_v1` pour un UID app.
  static AdminCoachLiveSync listenLive({
    required String uid,
    required void Function(List<TradeListItem> trades) onTrades,
    required void Function(
      List<UserPortfolio> portfolios,
      String? activePortfolioId,
    ) onPortfolios,
    void Function(Object error)? onError,
  }) {
    final id = uid.trim();
    final journalSub = _userDoc(id)
        .collection('sync_data')
        .doc(_journalDocId)
        .snapshots()
        .listen(
      (snap) => onTrades(parseTradesFromData(snap.data())),
      onError: onError,
    );
    final portfolioSub = _userDoc(id)
        .collection('sync_data')
        .doc(_portfolioDocId)
        .snapshots()
        .listen(
      (snap) {
        final parsed = parsePortfoliosFromData(snap.data());
        onPortfolios(parsed.portfolios, parsed.activePortfolioId);
      },
      onError: onError,
    );
    return AdminCoachLiveSync._(() {
      journalSub.cancel();
      portfolioSub.cancel();
    });
  }
}

/// Annule les listeners Firestore du labo Coach.
final class AdminCoachLiveSync {
  AdminCoachLiveSync._(this.cancel);
  final void Function() cancel;
}
