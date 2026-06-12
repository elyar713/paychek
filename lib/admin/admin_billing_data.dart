import 'package:cloud_firestore/cloud_firestore.dart';

import '../reglage/paychek_billing_plan.dart';
import '../reglage/paychek_user_firestore.dart';
import 'admin_firestore_users.dart';
import 'admin_models.dart';
import 'admin_overview_data.dart';
import 'admin_stripe_checkout_history.dart';
import 'admin_user_billing_summary.dart';

/// Instantané comptabilité admin (overview + Stripe + abonnés Pro).
class AdminBillingSnapshot {
  const AdminBillingSnapshot({
    required this.loadedAtUtc,
    required this.overview,
    required this.stripeHistory,
    required this.proSubscribers,
  });

  final DateTime loadedAtUtc;
  final AdminOverviewData overview;
  final PaychekStripeCheckoutHistoryResult stripeHistory;
  final List<AdminUserRow> proSubscribers;

  /// Abonnés Pro avec accès effectif (tier ou entitlements, période non expirée).
  List<AdminUserRow> get activeProSubscribers {
    final now = DateTime.now().toUtc();
    return proSubscribers.where((u) {
      if (!u.hasEffectiveProAccess) return false;
      final end = u.subscriptionCurrentPeriodEnd;
      if (end != null && !end.isAfter(now)) return false;
      return true;
    }).toList();
  }

  int get activeProCount => activeProSubscribers.length;

  /// MRR estimé (catalogue USD) — approximation pour abonnés actifs.
  double get estimatedMrrUsd {
    var sum = 0.0;
    for (final u in activeProSubscribers) {
      sum += adminEstimatedMonthlyUsdForUser(u);
    }
    return sum;
  }

  /// Somme des checkouts Stripe « Réussi » sur les 30 derniers jours (USD normalisé).
  double get stripePaidRevenue30dUsd {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
    var sum = 0.0;
    for (final s in stripeHistory.sessions) {
      if (s.statusLabel != 'Réussi') continue;
      if (s.createdAtUtc.isBefore(cutoff)) continue;
      sum += _toUsdMajor(s.amountMajor, s.currencyCode);
    }
    return sum;
  }

  int proCountForChannel(String channelKey) {
    final key = channelKey.trim().toLowerCase();
    return activeProSubscribers.where((u) {
      final pm = u.paymentMethod.trim().toLowerCase();
      return switch (key) {
        'stripe' => pm == 'stripe',
        'apple' => pm == 'apple' || pm == 'apple_iap',
        'google' => pm == 'google' || pm == 'google_play',
        _ => pm.isEmpty || pm == key,
      };
    }).length;
  }

  List<StripeCheckoutSessionPreview> get successfulStripeSessions {
    return stripeHistory.sessions
        .where((s) => s.statusLabel == 'Réussi')
        .toList();
  }
}

double _toUsdMajor(double major, String currencyCode) {
  final c = currencyCode.trim().toUpperCase();
  if (c == 'USD' || c.isEmpty) return major;
  // Hors USD : montant brut affiché (pas de conversion FX côté admin).
  return major;
}

/// Estimation mensuelle catalogue pour un abonné actif.
double adminEstimatedMonthlyUsdForUser(AdminUserRow user) {
  var cycle = adminInferBillingCycleFromPeriod(
    periodStartUtc: user.subscriptionProSinceUtc ?? user.subscriptionTierUpdatedAt,
    periodEndUtc: user.subscriptionCurrentPeriodEnd,
  );
  final productId = user.googlePlayProductId?.trim().toLowerCase() ?? '';
  if (cycle == null && productId.isNotEmpty) {
    if (productId.contains('annual')) {
      cycle = PaychekBillingCycle.annual;
    } else if (productId.contains('quarterly')) {
      cycle = PaychekBillingCycle.quarterly;
    } else if (productId.contains('monthly')) {
      cycle = PaychekBillingCycle.monthly;
    }
  }
  return switch (cycle) {
    PaychekBillingCycle.monthly => 8.99,
    PaychekBillingCycle.quarterly => 20.99 / 3,
    PaychekBillingCycle.annual => 59.99 / 12,
    null => 8.99,
  };
}

Future<List<AdminUserRow>> _fetchProSubscribers() async {
  final snap = await FirebaseFirestore.instance
      .collection(kPaychekUsersCollection)
      .where('subscriptionTier', isEqualTo: 'pro')
      .limit(150)
      .get();
  final rows = snap.docs.map(adminUserRowFromFirestore).toList();
  final enriched = await adminEnrichUsersWithEntitlements(rows);
  enriched.sort((a, b) {
    final aT = a.subscriptionProSinceUtc ??
        a.subscriptionTierUpdatedAt ??
        a.joinedAt;
    final bT = b.subscriptionProSinceUtc ??
        b.subscriptionTierUpdatedAt ??
        b.joinedAt;
    return bT.compareTo(aT);
  });
  return enriched;
}

Future<AdminBillingSnapshot> fetchAdminBillingSnapshot() async {
  final results = await Future.wait<Object>([
    fetchAdminOverviewData(),
    paychekAdminListStripeCheckoutSessions(limit: 50),
    _fetchProSubscribers(),
  ]);
  return AdminBillingSnapshot(
    loadedAtUtc: DateTime.now().toUtc(),
    overview: results[0] as AdminOverviewData,
    stripeHistory: results[1] as PaychekStripeCheckoutHistoryResult,
    proSubscribers: results[2] as List<AdminUserRow>,
  );
}

String adminBillingCycleLabelForUser(AdminUserRow user) {
  final cycle = adminInferBillingCycleFromPeriod(
    periodStartUtc: user.subscriptionProSinceUtc ?? user.subscriptionTierUpdatedAt,
    periodEndUtc: user.subscriptionCurrentPeriodEnd,
  );
  final productId = user.googlePlayProductId?.trim().toLowerCase() ?? '';
  if (cycle == null && productId.isNotEmpty) {
    if (productId.contains('annual')) {
      return adminBillingCycleLabel(PaychekBillingCycle.annual);
    }
    if (productId.contains('quarterly')) {
      return adminBillingCycleLabel(PaychekBillingCycle.quarterly);
    }
    if (productId.contains('monthly')) {
      return adminBillingCycleLabel(PaychekBillingCycle.monthly);
    }
  }
  return adminBillingCycleLabel(cycle);
}

String adminBillingEstimatedAmountLabel(AdminUserRow user) {
  final cycle = adminInferBillingCycleFromPeriod(
    periodStartUtc: user.subscriptionProSinceUtc ?? user.subscriptionTierUpdatedAt,
    periodEndUtc: user.subscriptionCurrentPeriodEnd,
  );
  final productId = user.googlePlayProductId?.trim().toLowerCase() ?? '';
  PaychekBillingCycle? resolved = cycle;
  if (resolved == null && productId.isNotEmpty) {
    if (productId.contains('annual')) {
      resolved = PaychekBillingCycle.annual;
    } else if (productId.contains('quarterly')) {
      resolved = PaychekBillingCycle.quarterly;
    } else if (productId.contains('monthly')) {
      resolved = PaychekBillingCycle.monthly;
    }
  }
  if (resolved == null) return '—';
  final total =
      PaychekBillingPlanCatalog.totalPrice(resolved).replaceAll('.', ',');
  return '$total \$';
}
