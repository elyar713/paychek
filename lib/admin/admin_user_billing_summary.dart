import 'package:intl/intl.dart';

import '../reglage/paychek_billing_plan.dart';
import 'admin_models.dart';
import 'admin_stripe_checkout_history.dart';

/// Synthèse facturation affichée sur le profil admin (montant, date, cycle).
class AdminUserBillingSummary {
  const AdminUserBillingSummary({
    required this.amountLabel,
    required this.paidAtLabel,
    required this.cycleLabel,
    required this.transactionIdLabel,
  });

  final String amountLabel;
  final String paidAtLabel;
  final String cycleLabel;

  /// Payment Intent ou session Checkout Stripe (`pi_…` / `cs_…`).
  final String transactionIdLabel;

  static const empty = AdminUserBillingSummary(
    amountLabel: '—',
    paidAtLabel: '—',
    cycleLabel: '—',
    transactionIdLabel: '—',
  );
}

String adminBillingCycleLabel(PaychekBillingCycle? cycle) => switch (cycle) {
      PaychekBillingCycle.monthly => '1 mois',
      PaychekBillingCycle.quarterly => '3 mois',
      PaychekBillingCycle.annual => '1 an',
      null => '—',
    };

/// Infère le cycle à partir de la durée entre début et fin de période Pro.
PaychekBillingCycle? adminInferBillingCycleFromPeriod({
  required DateTime? periodStartUtc,
  required DateTime? periodEndUtc,
}) {
  if (periodStartUtc == null || periodEndUtc == null) return null;
  final days = periodEndUtc.difference(periodStartUtc).inDays;
  if (days >= 300) return PaychekBillingCycle.annual;
  if (days >= 75) return PaychekBillingCycle.quarterly;
  if (days >= 20) return PaychekBillingCycle.monthly;
  return null;
}

PaychekBillingCycle? _cycleFromStripeAmountMajor(double amount, String currency) {
  final c = currency.trim().toUpperCase();
  if (c != 'USD' && c.isNotEmpty) return null;
  bool near(double a, double b) => (a - b).abs() < 0.75;
  if (near(amount, 8.99)) return PaychekBillingCycle.monthly;
  if (near(amount, 20.97)) return PaychekBillingCycle.quarterly;
  if (near(amount, 59.99)) return PaychekBillingCycle.annual;
  return null;
}

String _catalogAmountLabel(PaychekBillingCycle cycle) {
  final total = PaychekBillingPlanCatalog.totalPrice(cycle).replaceAll('.', ',');
  return '$total \$';
}

String _normalizeEmail(String email) => email.trim().toLowerCase();

StripeCheckoutSessionPreview? _latestPaidSessionForEmail(
  List<StripeCheckoutSessionPreview> sessions,
  String email,
) {
  final want = _normalizeEmail(email);
  if (want.isEmpty) return null;
  StripeCheckoutSessionPreview? best;
  for (final s in sessions) {
    if (_normalizeEmail(s.email) != want) continue;
    if (s.statusLabel != 'Réussi') continue;
    if (best == null || s.createdAtUtc.isAfter(best.createdAtUtc)) {
      best = s;
    }
  }
  return best;
}

/// Montant / date / cycle pour la carte FACTURATION du profil utilisateur.
Future<AdminUserBillingSummary> resolveAdminUserBillingSummary({
  required AdminUserRow user,
  required DateFormat dateFormat,
}) async {
  if (!user.hasPaidPlan) return AdminUserBillingSummary.empty;

  final paidAtUtc =
      user.subscriptionProSinceUtc ?? user.subscriptionTierUpdatedAt;
  var cycle = adminInferBillingCycleFromPeriod(
    periodStartUtc: paidAtUtc,
    periodEndUtc: user.subscriptionCurrentPeriodEnd,
  );

  String amountLabel = '—';
  String paidAtLabel =
      paidAtUtc != null ? dateFormat.format(paidAtUtc.toLocal()) : '—';
  var transactionIdLabel = '—';

  final pm = user.paymentMethod.trim().toLowerCase();
  final email = user.email.trim();
  if (pm == 'stripe' && email.isNotEmpty && !email.startsWith('(')) {
    final hist = await paychekAdminListStripeCheckoutSessions(limit: 50);
    final session = hist.sessions.isEmpty
        ? null
        : _latestPaidSessionForEmail(hist.sessions, email);
    if (session != null) {
      amountLabel = formatStripeMajorCurrency(
        session.amountMajor,
        session.currencyCode,
      );
      paidAtLabel = dateFormat.format(session.createdAtUtc.toLocal());
      if (session.idDisplay.isNotEmpty) {
        transactionIdLabel = session.idDisplay;
      }
      cycle ??= _cycleFromStripeAmountMajor(
        session.amountMajor,
        session.currencyCode,
      );
    }
  }

  if (amountLabel == '—' && cycle != null) {
    amountLabel = _catalogAmountLabel(cycle);
  }

  return AdminUserBillingSummary(
    amountLabel: amountLabel,
    paidAtLabel: paidAtLabel,
    cycleLabel: adminBillingCycleLabel(cycle),
    transactionIdLabel: transactionIdLabel,
  );
}
