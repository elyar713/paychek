import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../paychek_billing_plan.dart';
import '../../paywall_compare_rows.dart';
import '../paywall_unified_gold_compare_table.dart';
import 'paywall_mobile_compare_table.dart';
import 'paywall_mobile_tokens.dart';

/// Paywall mobile (maquette noir & or : plans, tableau, CTA).
class PaychekMobileUpgradePaywall extends StatefulWidget {
  const PaychekMobileUpgradePaywall({
    super.key,
    required this.onSubscribe,
    this.showTopClose = true,
    this.onClose,
    this.header,
    this.footerActions,
    this.feedbackBanner,
  });

  final Future<void> Function(PaychekBillingCycle cycle) onSubscribe;
  final bool showTopClose;
  final VoidCallback? onClose;
  final Widget? header;
  final Widget? footerActions;
  final Widget? feedbackBanner;

  @override
  State<PaychekMobileUpgradePaywall> createState() =>
      _PaychekMobileUpgradePaywallState();
}

class _PaychekMobileUpgradePaywallState extends State<PaychekMobileUpgradePaywall> {
  PaychekBillingCycle _selected = PaychekBillingCycle.annual;

  TextStyle _text({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.35,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? Colors.white,
    );
  }

  bool _badgeIsGold(PaychekBillingCycle cycle) {
    return switch (cycle) {
      PaychekBillingCycle.annual => _selected == PaychekBillingCycle.annual,
      PaychekBillingCycle.quarterly => _selected == PaychekBillingCycle.quarterly,
      PaychekBillingCycle.monthly => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final rows = buildPaywallCompareRows(l);

    return ColoredBox(
      color: PaywallMobileTokens.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showTopClose)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _closeButton(),
                  _premiumPill(l),
                  const SizedBox(width: 32),
                ],
              )
            else
              Align(alignment: Alignment.centerRight, child: _premiumPill(l)),
            if (widget.header != null) ...[
              const SizedBox(height: 12),
              widget.header!,
            ],
            const SizedBox(height: 20),
            ...PaychekBillingPlanCatalog.mobileDisplayOrder.map(_planCard),
            const SizedBox(height: 20),
            if (kIsWeb)
              PaywallUnifiedGoldCompareTable(
                rows: rows,
                compact: true,
                liteFooter: _webTableLiteFooter(l),
                proFooter: _webTableProFooter(l),
              )
            else
              PaywallMobileCompareTable(rows: rows),
            const SizedBox(height: 20),
            if (widget.feedbackBanner != null) ...[
              widget.feedbackBanner!,
              const SizedBox(height: 12),
            ],
            if (!kIsWeb) _subscribeButton(l),
            if (widget.footerActions != null) ...[
              const SizedBox(height: 16),
              widget.footerActions!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _closeButton() {
    return Material(
      color: PaywallMobileTokens.neutral900.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: PaywallMobileTokens.neutral800.withValues(alpha: 0.8),
        ),
      ),
      child: InkWell(
        onTap: widget.onClose,
        borderRadius: BorderRadius.circular(999),
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: PaywallMobileTokens.neutral400,
          ),
        ),
      ),
    );
  }

  Widget _premiumPill(AppLocalizations l) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: PaywallMobileTokens.goldPillBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: PaywallMobileTokens.amber500.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          l.paywallGoldPremiumPill.toUpperCase(),
          style: _text(
            size: 10,
            weight: FontWeight.w900,
            color: PaywallMobileTokens.amber400,
            letterSpacing: 1.8,
          ),
        ),
      ),
    );
  }

  Widget _planCard(PaychekBillingCycle cycle) {
    final l = AppLocalizations.of(context)!;
    final selected = _selected == cycle;
    final perMonth = PaychekBillingPlanCatalog.pricePerMonth(cycle);
    final total = PaychekBillingPlanCatalog.totalPrice(cycle);

    late final String title;
    late final String? badge;
    late final Widget subtitle;
    late final String billing;

    switch (cycle) {
      case PaychekBillingCycle.annual:
        title = l.paywallMobilePlanAnnualTitle;
        badge = l.paywallMobilePlanSavings44;
        subtitle = _perMonthSubtitle(l, perMonth, selected);
        billing = l.paywallMobilePlanAnnualBilling;
      case PaychekBillingCycle.quarterly:
        title = l.paywallMobilePlanQuarterlyTitle;
        badge = l.paywallMobilePlanPopular;
        subtitle = _perMonthSubtitle(l, perMonth, selected);
        billing = l.paywallMobilePlanQuarterlyBilling;
      case PaychekBillingCycle.monthly:
        title = l.paywallMobilePlanMonthlyTitle;
        badge = null;
        subtitle = Text(
          l.paywallMobilePlanMonthlyCommitment,
          style: _text(size: 10, color: PaywallMobileTokens.neutral400),
        );
        billing = l.paywallMobilePlanMonthlyBilling;
    }

    final badgeGold = badge != null && _badgeIsGold(cycle);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selected = cycle),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedScale(
            scale: selected ? 1.02 : 1,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: selected ? PaywallMobileTokens.selectedPlanGradient : null,
                color: selected ? null : PaywallMobileTokens.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? PaywallMobileTokens.amber500.withValues(alpha: 0.8)
                      : PaywallMobileTokens.neutral800,
                  width: 2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: PaywallMobileTokens.amber500.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (badge != null)
                    Positioned(
                      top: -20,
                      right: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: badgeGold ? PaywallMobileTokens.goldGradient : null,
                          color: badgeGold ? null : PaywallMobileTokens.neutral800,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: badgeGold
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          child: Text(
                            badge.toUpperCase(),
                            style: _text(
                              size: 8,
                              weight: FontWeight.w900,
                              color: badgeGold
                                  ? Colors.black
                                  : (cycle == PaychekBillingCycle.quarterly &&
                                          !badgeGold
                                      ? PaywallMobileTokens.neutral500
                                      : PaywallMobileTokens.neutral400),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      _radio(selected),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: _text(
                                size: 12,
                                weight: selected ? FontWeight.w900 : FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : PaywallMobileTokens.neutral200,
                              ),
                            ),
                            const SizedBox(height: 2),
                            subtitle,
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l.paywallMobilePlanTotalLine(total),
                            style: _text(
                              size: 14,
                              weight: FontWeight.w900,
                              color: selected
                                  ? Colors.white
                                  : PaywallMobileTokens.neutral200,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            billing,
                            style: _text(
                              size: 9,
                              color: PaywallMobileTokens.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _perMonthSubtitle(AppLocalizations l, String price, bool selected) {
    final base = _text(size: 10, color: PaywallMobileTokens.neutral400);
    if (!selected) {
      return Text(l.paywallMobilePlanPerMonthLine(price), style: base);
    }
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: l.paywallMobilePlanPerMonthPrefix),
          TextSpan(
            text: '$price${l.paywallMobilePlanPerMonthPriceSuffix}',
            style: base.copyWith(
              color: PaywallMobileTokens.amber400,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: l.paywallMobilePlanPerMonthEnd),
        ],
      ),
    );
  }

  Widget _radio(bool selected) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? PaywallMobileTokens.amber500 : PaywallMobileTokens.neutral700,
          width: 2,
        ),
        color: selected
            ? PaywallMobileTokens.amber500.withValues(alpha: 0.2)
            : Colors.transparent,
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? PaywallMobileTokens.amber500 : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _webTableLiteFooter(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PaywallMobileTokens.neutral800),
          color: PaywallMobileTokens.neutral950,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              l.paywallGoldYourPlanLabel.toUpperCase(),
              style: _text(
                size: 10,
                weight: FontWeight.w800,
                color: PaywallMobileTokens.neutral500,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _webTableProFooter(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: PaywallMobileTokens.goldGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: PaywallMobileTokens.amber500.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => unawaited(widget.onSubscribe(_selected)),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: Center(
                child: Text(
                  l.paywallSubscribeButton.toUpperCase(),
                  style: _text(
                    size: 10,
                    weight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _subscribeButton(AppLocalizations l) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: PaywallMobileTokens.goldGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PaywallMobileTokens.amber500.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => unawaited(widget.onSubscribe(_selected)),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l.paywallSubscribeButton.toUpperCase(),
                  style: _text(
                    size: 12,
                    weight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
