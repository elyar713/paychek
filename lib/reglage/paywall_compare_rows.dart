import '../l10n/app_localizations.dart';

/// Une ligne alignée du tableau comparatif Lite / Pro (tous paywalls).
class PaywallCompareRow {
  const PaywallCompareRow({
    this.liteLabel,
    this.liteIsCross = false,
    required this.proLabel,
    this.proIsChip = false,
  }) : assert(liteLabel != null || liteIsCross, 'liteLabel ou croix Lite');

  final String? liteLabel;
  final bool liteIsCross;
  final String proLabel;
  /// Badge doré / ambre pour « Analyses IA » (paywall Gold).
  final bool proIsChip;
}

/// Lignes 1–3 : inclus Lite vs équivalent Pro. Lignes 4–9 : ✗ Lite, modules Pro.
List<PaywallCompareRow> buildPaywallCompareRows(AppLocalizations l) {
  return [
    PaywallCompareRow(
      liteLabel: l.paywallLiteFeature1,
      proLabel: l.paywallProFeature1,
    ),
    PaywallCompareRow(
      liteLabel: l.paywallLiteFeature2,
      proLabel: l.paywallProFeature2,
    ),
    PaywallCompareRow(
      liteLabel: l.paywallLiteFeature3,
      proLabel: l.paywallProFeature3,
    ),
    PaywallCompareRow(liteIsCross: true, proLabel: l.paywallProFeature4),
    PaywallCompareRow(liteIsCross: true, proLabel: l.paywallProFeature5),
    PaywallCompareRow(liteIsCross: true, proLabel: l.paywallProFeature6),
    PaywallCompareRow(liteIsCross: true, proLabel: l.paywallProFeature7),
    PaywallCompareRow(liteIsCross: true, proLabel: l.paywallProFeature8),
    PaywallCompareRow(liteIsCross: true, proLabel: l.paywallProFeature9),
  ];
}
