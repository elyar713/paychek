import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../reglage/paychek_support_ticket_submit.dart';
import '../reglage/paychek_user_firestore.dart';
import 'admin_models.dart';

/// Données consolidées pour l’admin — Vue d’ensemble (Firestore).
class AdminOverviewData {
  const AdminOverviewData({
    required this.loadedAtUtc,
    required this.totalUsers,
    required this.usersCreatedLast30d,
    required this.usersCreatedPrev30d,
    required this.usersGrowthPct,
    required this.active24h,
    required this.activeRatePct,
    required this.usersWithProTier,
    required this.usersWithLiteTier,
    required this.paymentsProStripe24h,
    required this.paymentsProApple24h,
    required this.paymentsProGoogle24h,
    required this.usersCreatedLast24h,
    required this.ticketsPendingApprox,
    required this.supportTicketsPendingKindAccount,
    required this.supportTicketsPendingKindBilling,
    required this.supportTicketsPendingKindFeature,
    required this.supportTicketsPendingKindOther,
    required this.supportTicketsTotal,
    required this.supportTicketsKindAccount,
    required this.supportTicketsKindBilling,
    required this.supportTicketsKindFeature,
    required this.supportTicketsKindOtherBundled,
    required this.usersSeenOnAndroid,
    required this.usersSeenOnIos,
    required this.usersSeenOnWeb,
    required this.signupsPerDay30,
    required this.signupsChartStartUtc,
    required this.liveFeed,
  });

  final DateTime loadedAtUtc;
  final int totalUsers;
  final int usersCreatedLast30d;
  final int usersCreatedPrev30d;

  /// Tendance inscriptions entre les 30 j et les 30 j précédentes ; `null` si aucune inscription sur la fenêtre ancienne.
  final double? usersGrowthPct;

  final int active24h;
  final double activeRatePct;

  /// Compteur Firestore (`subscriptionTier == pro`) — IAP, Stripe, admin, etc.
  final int usersWithProTier;

  /// Compteur `subscriptionTier == lite` (champ explicite — sans champ ≈ Lite côté app mais non compté ici).
  final int usersWithLiteTier;

  /// Pro (`subscriptionTier == pro`) avec `paymentMethod == stripe` et
  /// `subscriptionTierUpdatedAt` dans les dernières 24 h (UTC).
  final int paymentsProStripe24h;

  /// Idem pour l’App Store : `paymentMethod` ∈ { apple, apple_iap }.
  final int paymentsProApple24h;

  /// Idem pour Google Play : `paymentMethod` ∈ { google, google_play }.
  final int paymentsProGoogle24h;

  /// Profils `paychek_users` créés dans les dernières 24 h (`createdAt`, UTC).
  final int usersCreatedLast24h;

  /// `totalUsers` — [usersWithProTier] — [usersWithLiteTier] (approx. profils sans tier explicite ou legacy).
  int get usersTierUnsetOrOther =>
      (totalUsers - usersWithProTier - usersWithLiteTier)
          .clamp(0, 999999999);

  /// `total tickets` − `status == answered` (les tickets sans champ `status` comptent dans le total comme non répondus).
  final int ticketsPendingApprox;

  /// Tickets non répondus (`kind == account` − `account` avec `status == answered`).
  final int supportTicketsPendingKindAccount;

  /// Idem `kind == billing`.
  final int supportTicketsPendingKindBilling;

  /// Idem `kind == feature`.
  final int supportTicketsPendingKindFeature;

  /// Autres sujets / kind absent : reste des tickets en attente (cohérent avec [ticketsPendingApprox]).
  final int supportTicketsPendingKindOther;

  /// Nombre total de tickets support (= somme des quatre lignes ci-dessous si cohérent).
  final int supportTicketsTotal;

  /// Tickets avec `kind == account`.
  final int supportTicketsKindAccount;

  /// Tickets avec `kind == billing`.
  final int supportTicketsKindBilling;

  /// Tickets avec `kind == feature`.
  final int supportTicketsKindFeature;

  /// Tout le reste : `other`, valeur inconnue, champ `kind` absent ou vide (`total − compte − facturation − fonctionnalité`).
  final int supportTicketsKindOtherBundled;

  /// Profils dont `platformsSeen` mentionne cette plateforme (au moins une connexion / synchro depuis l’app).
  ///
  /// Les trois totaux peuvent se chevaucher (même utilisateur sur plusieurs canaux).
  final int usersSeenOnAndroid;

  /// Voir [usersSeenOnAndroid].
  final int usersSeenOnIos;

  /// Voir [usersSeenOnAndroid].
  final int usersSeenOnWeb;

  /// 30 valeurs UTC : index 0 = jour J−29, 29 = aujourd’hui (UTC).
  final List<double> signupsPerDay30;

  /// Minuit UTC du jour d’index 0 de [signupsPerDay30] (même origine que l’agrégation).
  final DateTime signupsChartStartUtc;

  final List<AdminLiveFeedItem> liveFeed;
}

DateTime _utcDay(DateTime utc) =>
    DateTime.utc(utc.year, utc.month, utc.day);

DateTime _adminUserDocCreatedAtUtc(DocumentSnapshot<Map<String, dynamic>> d) {
  final data = d.data() ?? {};
  return paychekResolveUserJoinedAtUtc(data) ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

int _requireCount(AggregateQuerySnapshot snap) {
  final c = snap.count;
  return c ?? 0;
}

String paychekAdminRelativeTimeFr({
  required DateTime pastUtc,
  required DateTime nowUtc,
}) {
  final d = nowUtc.difference(pastUtc);
  if (d.isNegative) return "à l'instant";
  if (d.inSeconds < 55) return "à l'instant";
  if (d.inMinutes < 56) return 'il y a ${d.inMinutes} min';
  if (d.inHours < 25) return 'il y a ${d.inHours} h';
  if (d.inDays <= 34) return 'il y a ${d.inDays} j';
  return 'il y a ${(d.inDays ~/ 30)} mois';
}

/// Chargement parallèle (agrégats + derniers tickets).
Future<AdminOverviewData> fetchAdminOverviewData({
  FirebaseFirestore? firestore,
}) async {
  final db = firestore ?? FirebaseFirestore.instance;
  final usersCol = db.collection(kPaychekUsersCollection);
  final ticketsCol = db.collection(kPaychekSupportTicketsCollection);

  final nowUtc = DateTime.now().toUtc();
  final todayUtc = _utcDay(nowUtc);
  final dayStartUtc = DateTime.utc(todayUtc.year, todayUtc.month, todayUtc.day);
  /// Premier jour (UTC minuit) de la fenêtre des 30 jours du graphique — index 0.
  final startWindowUtc =
      dayStartUtc.subtract(const Duration(days: 29));
  /// Bloc précédent de 30 jours juste avant [startWindowUtc].
  final prevWindowStartUtc =
      startWindowUtc.subtract(const Duration(days: 30));

  final cutoff24h = Timestamp.fromDate(nowUtc.subtract(const Duration(hours: 24)));
  final tsLast30Window = Timestamp.fromDate(startWindowUtc);
  final tsPrevStart = Timestamp.fromDate(prevWindowStartUtc);
  final tsPrevEndExclusive = Timestamp.fromDate(startWindowUtc);

  final totalUsersFut = usersCol.count().get();
  final active24Fut = usersCol.where('lastSeenAt', isGreaterThanOrEqualTo: cutoff24h).count().get();

  final proTierFut =
      usersCol.where('subscriptionTier', isEqualTo: 'pro').count().get();

  final signupLastFut = usersCol
      .where('createdAt', isGreaterThanOrEqualTo: tsLast30Window)
      .count()
      .get();

  final signupPrevFut = usersCol
      .where('createdAt', isGreaterThanOrEqualTo: tsPrevStart)
      .where('createdAt', isLessThan: tsPrevEndExclusive)
      .count()
      .get();

  final ticketsTotalFut = ticketsCol.count().get();
  final ticketsAnsweredFut =
      ticketsCol.where('status', isEqualTo: 'answered').count().get();

  final ticketsKindAccountFut =
      ticketsCol.where('kind', isEqualTo: 'account').count().get();
  final ticketsKindBillingFut =
      ticketsCol.where('kind', isEqualTo: 'billing').count().get();
  final ticketsKindFeatureFut =
      ticketsCol.where('kind', isEqualTo: 'feature').count().get();

  final ticketsAnsweredAccountFut = ticketsCol
      .where('kind', isEqualTo: 'account')
      .where('status', isEqualTo: 'answered')
      .count()
      .get();
  final ticketsAnsweredBillingFut = ticketsCol
      .where('kind', isEqualTo: 'billing')
      .where('status', isEqualTo: 'answered')
      .count()
      .get();
  final ticketsAnsweredFeatureFut = ticketsCol
      .where('kind', isEqualTo: 'feature')
      .where('status', isEqualTo: 'answered')
      .count()
      .get();

  final recentTicketsFut =
      ticketsCol.orderBy('createdAt', descending: true).limit(14).get();

  final histogramFut = usersCol
      .where('createdAt', isGreaterThanOrEqualTo: tsLast30Window)
      .orderBy('createdAt')
      .get();

  /// Champ `paychek_users.platformsSeen` : libellés en minuscules (web, ios, android).
  final usersPlatformAndroidFut =
      usersCol.where('platformsSeen', arrayContains: 'android').count().get();
  final usersPlatformIosFut =
      usersCol.where('platformsSeen', arrayContains: 'ios').count().get();
  final usersPlatformWebFut =
      usersCol.where('platformsSeen', arrayContains: 'web').count().get();

  final liteTierFut =
      usersCol.where('subscriptionTier', isEqualTo: 'lite').count().get();
  /// Ordre des filtres aligné sur l’index composite Firestore :
  /// paymentMethod → subscriptionTier → subscriptionTierUpdatedAt.
  final paidStripe24Fut = usersCol
      .where('paymentMethod', isEqualTo: 'stripe')
      .where('subscriptionTier', isEqualTo: 'pro')
      .where(
        kPaychekUserFieldSubscriptionTierUpdatedAt,
        isGreaterThanOrEqualTo: cutoff24h,
      )
      .count()
      .get();
  final paidApple24Fut = usersCol
      .where('paymentMethod', isEqualTo: 'apple')
      .where('subscriptionTier', isEqualTo: 'pro')
      .where(
        kPaychekUserFieldSubscriptionTierUpdatedAt,
        isGreaterThanOrEqualTo: cutoff24h,
      )
      .count()
      .get();
  final paidAppleIap24Fut = usersCol
      .where('paymentMethod', isEqualTo: 'apple_iap')
      .where('subscriptionTier', isEqualTo: 'pro')
      .where(
        kPaychekUserFieldSubscriptionTierUpdatedAt,
        isGreaterThanOrEqualTo: cutoff24h,
      )
      .count()
      .get();
  final paidGoogle24Fut = usersCol
      .where('paymentMethod', isEqualTo: 'google')
      .where('subscriptionTier', isEqualTo: 'pro')
      .where(
        kPaychekUserFieldSubscriptionTierUpdatedAt,
        isGreaterThanOrEqualTo: cutoff24h,
      )
      .count()
      .get();
  final paidGooglePlay24Fut = usersCol
      .where('paymentMethod', isEqualTo: 'google_play')
      .where('subscriptionTier', isEqualTo: 'pro')
      .where(
        kPaychekUserFieldSubscriptionTierUpdatedAt,
        isGreaterThanOrEqualTo: cutoff24h,
      )
      .count()
      .get();
  final signups24Fut = usersCol
      .where('createdAt', isGreaterThanOrEqualTo: cutoff24h)
      .count()
      .get();

  final results = await Future.wait(<Future<Object>>[
    totalUsersFut,
    active24Fut,
    proTierFut,
    signupLastFut,
    signupPrevFut,
    ticketsTotalFut,
    ticketsAnsweredFut,
    ticketsKindAccountFut,
    ticketsKindBillingFut,
    ticketsKindFeatureFut,
    recentTicketsFut,
    histogramFut,
    usersPlatformAndroidFut,
    usersPlatformIosFut,
    usersPlatformWebFut,
    liteTierFut,
    paidStripe24Fut,
    paidApple24Fut,
    paidAppleIap24Fut,
    paidGoogle24Fut,
    paidGooglePlay24Fut,
    ticketsAnsweredAccountFut,
    ticketsAnsweredBillingFut,
    ticketsAnsweredFeatureFut,
    signups24Fut,
  ]);

  final totalUsers = _requireCount(results[0] as AggregateQuerySnapshot);
  final active24h = _requireCount(results[1] as AggregateQuerySnapshot);
  final usersProTier =
      _requireCount(results[2] as AggregateQuerySnapshot);
  final usersCreatedLast30d =
      _requireCount(results[3] as AggregateQuerySnapshot);
  final usersCreatedPrev30d =
      _requireCount(results[4] as AggregateQuerySnapshot);
  final ticketsTotal = _requireCount(results[5] as AggregateQuerySnapshot);
  final ticketsAnswered =
      _requireCount(results[6] as AggregateQuerySnapshot);
  final kindAccount =
      _requireCount(results[7] as AggregateQuerySnapshot);
  final kindBilling =
      _requireCount(results[8] as AggregateQuerySnapshot);
  final kindFeature =
      _requireCount(results[9] as AggregateQuerySnapshot);
  final recentSnap = results[10] as QuerySnapshot<Map<String, dynamic>>;
  final histSnap = results[11] as QuerySnapshot<Map<String, dynamic>>;
  final platAndroid =
      _requireCount(results[12] as AggregateQuerySnapshot);
  final platIos = _requireCount(results[13] as AggregateQuerySnapshot);
  final platWeb = _requireCount(results[14] as AggregateQuerySnapshot);
  final usersLite =
      _requireCount(results[15] as AggregateQuerySnapshot);
  final paidStripe24 =
      _requireCount(results[16] as AggregateQuerySnapshot);
  final paidApple24 =
      _requireCount(results[17] as AggregateQuerySnapshot);
  final paidAppleIap24 =
      _requireCount(results[18] as AggregateQuerySnapshot);
  final paidGoogle24 =
      _requireCount(results[19] as AggregateQuerySnapshot);
  final paidGooglePlay24 =
      _requireCount(results[20] as AggregateQuerySnapshot);
  final answeredKindAccount =
      _requireCount(results[21] as AggregateQuerySnapshot);
  final answeredKindBilling =
      _requireCount(results[22] as AggregateQuerySnapshot);
  final answeredKindFeature =
      _requireCount(results[23] as AggregateQuerySnapshot);
  final signups24 =
      _requireCount(results[24] as AggregateQuerySnapshot);
  final paymentsApple24 = paidApple24 + paidAppleIap24;
  final paymentsGoogle24 = paidGoogle24 + paidGooglePlay24;

  final kindOtherBundled = (ticketsTotal - kindAccount - kindBilling - kindFeature)
      .clamp(0, 999999999);

  final answeredOtherBundled = (ticketsAnswered -
          answeredKindAccount -
          answeredKindBilling -
          answeredKindFeature)
      .clamp(0, 999999999);

  final pendingKindAccount =
      (kindAccount - answeredKindAccount).clamp(0, 999999999);
  final pendingKindBilling =
      (kindBilling - answeredKindBilling).clamp(0, 999999999);
  final pendingKindFeature =
      (kindFeature - answeredKindFeature).clamp(0, 999999999);
  final pendingKindOther =
      (kindOtherBundled - answeredOtherBundled).clamp(0, 999999999);

  double? growthPct;
  if (usersCreatedPrev30d > 0) {
    growthPct = ((usersCreatedLast30d - usersCreatedPrev30d) /
            usersCreatedPrev30d) *
        100.0;
  }

  final activeRatePct =
      totalUsers > 0 ? (100.0 * active24h / totalUsers) : 0.0;

  final ticketsPendingApprox =
      (ticketsTotal - ticketsAnswered).clamp(0, 999999999);

  final buckets = List<double>.filled(30, 0);
  for (final doc in histSnap.docs) {
    final c = _utcDay(_adminUserDocCreatedAtUtc(doc));
    if (c.isBefore(startWindowUtc) || c.isAfter(dayStartUtc)) continue;
    final idx = c.difference(startWindowUtc).inDays;
    if (idx >= 0 && idx < 30) buckets[idx] += 1;
  }

  final feed = _buildTicketFeed(nowUtc: nowUtc, snap: recentSnap);

  return AdminOverviewData(
    loadedAtUtc: nowUtc,
    totalUsers: totalUsers,
    usersCreatedLast30d: usersCreatedLast30d,
    usersCreatedPrev30d: usersCreatedPrev30d,
    usersGrowthPct: growthPct,
    active24h: active24h,
    activeRatePct: activeRatePct,
    usersWithProTier: usersProTier,
    usersWithLiteTier: usersLite,
    paymentsProStripe24h: paidStripe24,
    paymentsProApple24h: paymentsApple24,
    paymentsProGoogle24h: paymentsGoogle24,
    usersCreatedLast24h: signups24,
    ticketsPendingApprox: ticketsPendingApprox,
    supportTicketsPendingKindAccount: pendingKindAccount,
    supportTicketsPendingKindBilling: pendingKindBilling,
    supportTicketsPendingKindFeature: pendingKindFeature,
    supportTicketsPendingKindOther: pendingKindOther,
    supportTicketsTotal: ticketsTotal,
    supportTicketsKindAccount: kindAccount,
    supportTicketsKindBilling: kindBilling,
    supportTicketsKindFeature: kindFeature,
    supportTicketsKindOtherBundled: kindOtherBundled,
    usersSeenOnAndroid: platAndroid,
    usersSeenOnIos: platIos,
    usersSeenOnWeb: platWeb,
    signupsPerDay30: buckets,
    signupsChartStartUtc: startWindowUtc,
    liveFeed: feed,
  );
}

String _ticketKindShortFr(Object? raw) {
  switch ('$raw'.trim()) {
    case 'account':
      return 'Compte';
    case 'billing':
      return 'Facturation';
    case 'feature':
      return 'Idée';
    case 'other':
    default:
      return '$raw'.trim().isEmpty ? 'Support' : '$raw'.trim();
  }
}

List<AdminLiveFeedItem> _buildTicketFeed({
  required DateTime nowUtc,
  required QuerySnapshot<Map<String, dynamic>> snap,
}) {
  final out = <AdminLiveFeedItem>[];
  for (final doc in snap.docs) {
    final d = doc.data();
    final kind = _ticketKindShortFr(d['kind']);
    final refLine = paychekSupportHumanRefLine(doc.id, d);
    final replyEmail =
        '${d['replyEmail']}'.trim().isEmpty ? '(sans email)' : '${d['replyEmail']}'.trim();

    Color dot;
    final st = d['staffUnread'] == true;
    final sta = '${d['status']}'.trim().toLowerCase();
    if (sta == 'answered') {
      dot = const Color(0xFF64748B);
    } else if (st || sta.isEmpty || sta == 'open' || sta == 'nouveau') {
      dot = const Color(0xFFEAB308);
    } else {
      dot = const Color(0xFF3B82F6);
    }

    var tsUtc = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final crt = d['createdAt'];
    if (crt is Timestamp) tsUtc = crt.toDate().toUtc();
    final referencePast =
        tsUtc.isAfter(nowUtc) ? nowUtc : tsUtc;

    out.add(
      AdminLiveFeedItem(
        message: '$kind · $refLine',
        actor: replyEmail,
        agoLabel: paychekAdminRelativeTimeFr(
          pastUtc: referencePast,
          nowUtc: nowUtc,
        ),
        dotColor: dot,
      ),
    );
  }
  return out;
}
