import 'package:flutter/material.dart';

import 'admin_models.dart';

/// Données de démonstration — remplacer par Firestore / Functions.
abstract final class AdminDemoData {
  AdminDemoData._();

  static const int totalUsers = 12482;
  static const double usersGrowthPct = 12;
  static const int active24h = 1840;
  static const double activeRatePct = 14.7;
  static const double mrrUsd = 42150;
  static const double mrrGrowthPct = 5;
  static const double storageLoadPct = 64;
  static const double churnRatePct = 3.2;

  /// Y par jour (30 points) — courbe type maquette.
  static List<double> signups30d() {
    const seed = [
      42, 38, 35, 41, 39, 44, 46, 43, 41, 47, 52, 49, 51, 48, 53, 56, 52, 50,
      49, 55, 58, 54, 53, 57, 55, 59, 56, 58, 60, 55,
    ];
    return seed.map((v) => v / 1.5).toList();
  }

  static List<AdminLiveFeedItem> liveFeed() => [
        AdminLiveFeedItem(
          message: 'Nouveau PDF de performance généré',
          actor: 'User_922',
          agoLabel: 'il y a 2 min',
          dotColor: const Color(0xFF22C55E),
        ),
        AdminLiveFeedItem(
          message: 'Import CSV réussi',
          actor: 'TraderPro',
          agoLabel: 'il y a 5 min',
          dotColor: const Color(0xFF3B82F6),
        ),
        AdminLiveFeedItem(
          message: 'Nouvel inscrit (FR)',
          actor: 'Alex_T',
          agoLabel: 'il y a 14 min',
          dotColor: const Color(0xFFEAB308),
        ),
        AdminLiveFeedItem(
          message: 'Abonnement Premium activé',
          actor: 'MarieDX',
          agoLabel: 'il y a 31 min',
          dotColor: const Color(0xFF22C55E),
        ),
      ];

  static List<AdminUserRow> users() => [
        AdminUserRow(
          id: 'u1',
          firstName: 'Camille',
          lastName: 'Dupont',
          birthDate: DateTime.utc(1995, 3, 12),
          appLanguageCode: 'fr',
          paymentMethod: 'stripe',
          email: 'pro@demo.mail',
          joinedAt: DateTime.now().subtract(const Duration(days: 400)),
          country: 'FR',
          subscriptionTier: PaychekSubscriptionTier.pro,
          importedTrades: 1842,
          platformsSeen: ['android', 'web'],
          lastSeenPlatform: 'android',
        ),
        AdminUserRow(
          id: 'u2',
          firstName: 'Alex',
          lastName: 'Martin',
          birthDate: DateTime.utc(2001, 7, 2),
          appLanguageCode: 'en',
          paymentMethod: 'apple',
          email: 'alex@demo.mail',
          joinedAt: DateTime.now().subtract(const Duration(days: 14)),
          country: 'FR',
          subscriptionTier: PaychekSubscriptionTier.lite,
          importedTrades: 42,
          platformsSeen: ['ios'],
          lastSeenPlatform: 'ios',
        ),
        AdminUserRow(
          id: 'u3',
          firstName: '',
          lastName: '',
          appLanguageCode: 'de',
          email: 'csv@demo.mail',
          joinedAt: DateTime.now().subtract(const Duration(days: 2)),
          country: 'DE',
          subscriptionTier: PaychekSubscriptionTier.lite,
          importedTrades: 128,
          platformsSeen: const [],
          accessWebEnabled: false,
          accessMobileEnabled: true,
        ),
      ];

  static List<PaymentRow> payments() => [
        PaymentRow(
          id: 'pi_8f2abc',
          amountUsd: 29.99,
          status: 'Réussi',
          userHandle: 'pro@demo.mail',
          date: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        PaymentRow(
          id: 'pi_9d1zzz',
          amountUsd: 29.99,
          status: 'Échoué',
          userHandle: 'alex@demo.mail',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  static List<(String code, String desc, double pctOff)> coupons() =>
      [('TRADER20', 'Influenceur campagne Q2', 20)];

  static List<SupportTicket> tickets() => [
        SupportTicket(
          id: 't1',
          subject: 'Compte — impossible de synchroniser le capital',
          fromEmail: 'trader@x.com',
          kind: 'Compte',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        SupportTicket(
          id: 't2',
          subject: 'Facturation — remboursement demandé',
          fromEmail: 'pay@z.com',
          kind: 'Facturation',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          status: 'en cours',
        ),
      ];

  static List<FeatureRequestRow> features() => [
        const FeatureRequestRow(
          id: 'f1',
          title: 'Export Excel mass des trades par année',
          votes: 24,
          status: 'À étudier',
        ),
        const FeatureRequestRow(
          id: 'f2',
          title: 'Mode sombre forcé navigateur Safari',
          votes: 8,
          status: 'Backlog',
        ),
      ];
}
