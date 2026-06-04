import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'admin_models.dart';
import 'admin_theme.dart';

/// Couleur d’accent stable par canal (liste + fiche utilisateur).
Color adminPaymentMethodAccentColor(String raw) {
  final t = raw.trim().toLowerCase();
  return switch (t) {
    'stripe' => const Color(0xFF818CF8),
    'apple' || 'apple_iap' => const Color(0xFFE2E8F0),
    'google' || 'google_play' => const Color(0xFF93C5FD),
    'admin' => const Color(0xFFF59E0B),
    _ => const Color(0xFF94A3B8),
  };
}

String adminPaymentMethodDisplayLabel(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '—';
  return switch (t.toLowerCase()) {
    'stripe' => 'Stripe',
    'apple' || 'apple_iap' => 'Apple',
    'google' || 'google_play' => 'Google Play',
    'admin' => 'Admin',
    _ => t,
  };
}

String adminSubscriptionEndReasonLabel(String? raw) {
  final r = raw?.trim() ?? '';
  if (r.isEmpty) return '—';
  return switch (r) {
    'google_play_expired_or_inactive' =>
      'Google Play : abonnement expiré ou inactif',
    'expired_or_inactive' => 'Abonnement expiré ou inactif',
    'subscription_inactive' => 'Abonnement inactif',
    _ => r.replaceAll('_', ' '),
  };
}

/// Compte ayant eu au moins un achat / canal renseigné (même si Lite aujourd’hui).
bool adminUserHadSubscriptionHistory(AdminUserRow u) {
  if (u.paymentMethod.trim().isNotEmpty) return true;
  if (u.googlePlayProductId != null && u.googlePlayProductId!.isNotEmpty) {
    return true;
  }
  return u.subscriptionProSinceUtc != null ||
      u.subscriptionCurrentPeriodEnd != null ||
      u.subscriptionEndedAtUtc != null;
}

/// Libellé statut pour la trace admin.
String adminSubscriptionTraceStatusLabel(AdminUserRow u) {
  final now = DateTime.now().toUtc();
  final end = u.subscriptionCurrentPeriodEnd;
  final periodPast = end != null && !end.isAfter(now);
  if (u.hasEffectiveProAccess && !periodPast) {
    return 'Actif';
  }
  if (u.subscriberEntitlementActive && !periodPast) {
    return 'Actif (entitlements)';
  }
  if (periodPast || u.subscriptionEndedAtUtc != null) {
    return 'Expiré / révoqué';
  }
  if (u.hasPaidPlan) return 'Pro (tier)';
  return 'Lite';
}

Color adminSubscriptionTraceStatusColor(AdminUserRow u) {
  final status = adminSubscriptionTraceStatusLabel(u);
  if (status.startsWith('Actif')) return const Color(0xFF34D399);
  if (status.contains('Expiré') || status.contains('révoqué')) {
    return const Color(0xFFF59E0B);
  }
  return AdminTheme.textMuted;
}

String adminBillingSectionTitle(String paymentMethod) {
  final t = paymentMethod.trim().toLowerCase();
  return switch (t) {
    'stripe' => 'FACTURATION · STRIPE',
    'apple' || 'apple_iap' => 'FACTURATION · APPLE',
    'google' || 'google_play' => 'FACTURATION · GOOGLE PLAY',
    '' => 'FACTURATION',
    _ => 'FACTURATION · ${adminPaymentMethodDisplayLabel(paymentMethod).toUpperCase()}',
  };
}

/// Carte « trace » : canal, statut, dates, raison de fin (lecture seule).
class AdminSubscriptionTracePanel extends StatelessWidget {
  const AdminSubscriptionTracePanel({
    super.key,
    required this.user,
    required this.dateFormat,
  });

  final AdminUserRow user;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (!adminUserHadSubscriptionHistory(user)) {
      return Text(
        'Aucun historique d’abonnement enregistré.',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: AdminTheme.textMuted,
        ),
      );
    }

    final channel = adminPaymentMethodDisplayLabel(user.paymentMethod);
    final accent = adminPaymentMethodAccentColor(user.paymentMethod);
    final status = adminSubscriptionTraceStatusLabel(user);
    final statusColor = adminSubscriptionTraceStatusColor(user);

    String fmt(DateTime? u) =>
        u != null ? dateFormat.format(u.toLocal()) : '—';

    Widget row(String label, String value, {Color? valueColor}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 128,
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.45,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final product = user.googlePlayProductId?.trim();
    final reason = adminSubscriptionEndReasonLabel(user.subscriptionEndReason);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(
                'TRACE ABONNEMENT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          row('Canal', channel, valueColor: accent),
          row('Statut', status, valueColor: statusColor),
          if (product != null && product.isNotEmpty)
            row('Produit Play', product),
          row('Pro depuis', fmt(user.subscriptionProSinceUtc)),
          row('Fin de période', fmt(user.subscriptionCurrentPeriodEnd)),
          row('Révoqué le', fmt(user.subscriptionEndedAtUtc)),
          row('Motif', reason,
              valueColor: user.subscriptionEndedAtUtc != null
                  ? const Color(0xFFFBBF24)
                  : null),
          row(
            'Tier Firestore',
            user.subscriptionTier.adminShortLabel,
          ),
        ],
      ),
    );
  }
}
