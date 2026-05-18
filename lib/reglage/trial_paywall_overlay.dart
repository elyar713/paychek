import 'dart:async' show unawaited;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import 'paychek_billing_plan.dart';
import 'paychek_billing_remote.dart';
import 'paychek_checkout_launch.dart';
import 'paywall/mobile/paychek_mobile_upgrade_paywall.dart';
import 'paywall/mobile/paywall_mobile_tokens.dart';
import 'paywall_compare_rows.dart';
import 'paywall_compare_split_table.dart';
import 'stripe_entitlement_sync.dart';
import 'trial_paywall_config.dart';

const Color _kEmerald500 = Color(0xFF10B981);
const Color _kEmerald600 = Color(0xFF059669);
const Color _kSlate500 = Color(0xFF64748B);
const Color _kSlate400 = Color(0xFF94A3B8);
const Color _kSlate700 = Color(0xFF334155);
const Color _kPaywallBg = Color(0xFF000000);
const double _kMaxContentWidth = 448;

/// Paywall Pro (essai terminé). Mobile : maquette or ; web : legacy émeraude.
class TrialPaywallOverlay extends StatefulWidget {
  const TrialPaywallOverlay({
    super.key,
    required this.trialAnchorUtc,
    required this.onReloadTrialGate,
    this.onDismissLite,
    this.displayTrialEndUtc,
  });

  final DateTime trialAnchorUtc;
  final DateTime? displayTrialEndUtc;
  final Future<bool> Function() onReloadTrialGate;
  final VoidCallback? onDismissLite;

  @override
  State<TrialPaywallOverlay> createState() => _TrialPaywallOverlayState();
}

class _TrialPaywallOverlayState extends State<TrialPaywallOverlay> {
  String? _feedbackBanner;
  PaychekBillingCycle _prefetchCycle = PaychekBillingCycle.annual;
  Uri? _prefetchedCheckoutUri;

  @override
  void initState() {
    super.initState();
    unawaited(_prefetchCheckoutUri(_prefetchCycle));
  }

  Future<void> _prefetchCheckoutUri(PaychekBillingCycle cycle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uri = await buildPaywallSubscribeUriAsync(
      cycle: cycle,
      firebaseEmail: user.email,
      firebaseUid: user.uid,
    );
    if (!mounted) return;
    setState(() {
      _prefetchCycle = cycle;
      _prefetchedCheckoutUri = uri;
    });
  }

  void _setBanner(String? text) {
    if (!mounted) return;
    setState(() => _feedbackBanner = text);
  }

  TextStyle _font({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.35,
    double letterSpacing = 0,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? Colors.white,
      shadows: shadows,
    );
  }

  Widget? _feedbackBannerWidget() {
    final b = _feedbackBanner;
    if (b == null || b.isEmpty) return null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF2A1810),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                b,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: _kSlate400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trialHeadline(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PAYCHEK',
          textAlign: TextAlign.center,
          style: _font(
            size: 10,
            weight: FontWeight.w900,
            color: _kSlate500,
            letterSpacing: 4,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n.paywallHeadlineBefore.trimRight(),
              textAlign: TextAlign.center,
              style: _font(
                size: 30,
                weight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
                letterSpacing: -0.6,
              ),
            ),
            Text(
              l10n.paywallHeadlineAccent,
              textAlign: TextAlign.center,
              style: _font(
                size: 30,
                weight: FontWeight.w800,
                color: _kEmerald500,
                height: 1.15,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            l10n.paywallUpgradeSubtitle,
            textAlign: TextAlign.center,
            style: _font(
              size: 14,
              weight: FontWeight.w400,
              color: _kSlate400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _webLegacyCompare(AppLocalizations l10n) {
    final capLite = _font(
      size: 9,
      weight: FontWeight.w700,
      color: _kSlate500,
      letterSpacing: 2.5,
      height: 1.2,
    );
    final capPro = capLite.copyWith(color: _kEmerald500);
    final nameLite = _font(size: 20, weight: FontWeight.w500, color: _kSlate400);
    final namePro = _font(
      size: 24,
      weight: FontWeight.w700,
      color: Colors.white,
      height: 1.1,
      shadows: [
        Shadow(
          color: _kEmerald500.withValues(alpha: 0.4),
          blurRadius: 15,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(l10n.paywallCompareCurrentPlan.toUpperCase(), style: capLite),
                    const SizedBox(height: 2),
                    Text(l10n.paywallPlanLiteName, style: nameLite),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(l10n.paywallCompareRecommended.toUpperCase(), style: capPro),
                    const SizedBox(height: 2),
                    Text(l10n.paywallPlanProName, style: namePro, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ),
        PaywallCompareSplitTable(
          rows: buildPaywallCompareRows(l10n),
          theme: PaywallCompareTheme.trialEmerald,
          liteFooter: const SizedBox.shrink(),
          proFooter: const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.paywallPriceAnnualHighlight,
          textAlign: TextAlign.center,
          style: _font(
            size: 18,
            weight: FontWeight.w700,
            color: _kEmerald500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.paywallPriceApproxPerMonth.toUpperCase(),
          textAlign: TextAlign.center,
          style: _font(
            size: 10,
            weight: FontWeight.w600,
            color: _kSlate500,
            letterSpacing: 2.2,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Future<void> _onSubscribe(
    BuildContext context,
    AppLocalizations l10n,
    PaychekBillingCycle cycle,
  ) async {
    _setBanner(null);
    if (_prefetchCycle != cycle) {
      unawaited(_prefetchCheckoutUri(cycle));
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _setBanner(l10n.paywallStoreNotConfigured);
      return;
    }
    var uri = _prefetchCycle == cycle ? _prefetchedCheckoutUri : null;
    if (uri == null) {
      PaychekBillingRemote.invalidateCache();
      uri = await buildPaywallSubscribeUriAsync(
        cycle: cycle,
        firebaseEmail: user.email,
        firebaseUid: user.uid,
      );
    }
    if (uri == null) {
      _setBanner(l10n.paywallStoreNotConfigured);
      return;
    }
    debugLogPaychekCheckoutUri(uri);
    final ok = await launchPaychekCheckoutUri(uri);
    if (!context.mounted) return;
    if (!ok) {
      _setBanner(l10n.paywallStoreNotConfigured);
    }
  }

  Widget _trialFooterActions(BuildContext context, AppLocalizations l10n) {
    final dismiss = widget.onDismissLite;
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            _setBanner(null);
            await PaychekStripeEntitlementSync.syncFromStripe(maxAttempts: 3);
            final stillLite = await widget.onReloadTrialGate();
            if (!context.mounted) return;
            if (stillLite) {
              _setBanner(l10n.paywallRestoreNothingFound);
            }
          },
          child: Text(
            l10n.paywallRestoreButton,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PaywallMobileTokens.amber400,
            ),
          ),
        ),
        if (dismiss != null)
          TextButton(
            onPressed: dismiss,
            child: Text(
              l10n.paywallContinueFreemium,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: PaywallMobileTokens.neutral500,
                decoration: TextDecoration.underline,
                decorationColor: PaywallMobileTokens.neutral500,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!kIsWeb) {
      return Material(
        color: const Color(0xFF020205),
        child: SafeArea(
          child: PaychekMobileUpgradePaywall(
            showTopClose: false,
            header: _trialHeadline(l10n),
            feedbackBanner: _feedbackBannerWidget(),
            footerActions: _trialFooterActions(context, l10n),
            onSubscribe: (cycle) => _onSubscribe(context, l10n, cycle),
          ),
        ),
      );
    }

    return Material(
      color: _kPaywallBg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _trialHeadline(l10n),
                  const SizedBox(height: 24),
                  _webLegacyCompare(l10n),
                  const SizedBox(height: 24),
                  if (_feedbackBannerWidget() != null) ...[
                    _feedbackBannerWidget()!,
                    const SizedBox(height: 16),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [_kEmerald500, _kEmerald600],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _kEmerald500.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onSubscribe(
                                context,
                                l10n,
                                PaychekBillingCycle.annual,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  l10n.paywallSubscribeButton,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _trialFooterActions(context, l10n),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.paywallLegalFooter.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: _font(
                        size: 9,
                        weight: FontWeight.w500,
                        color: _kSlate700,
                        height: 1.45,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
