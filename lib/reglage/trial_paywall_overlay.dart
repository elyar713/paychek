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
import 'stripe_entitlement_sync.dart';
import 'trial_paywall_config.dart';

const Color _kEmerald500 = Color(0xFF10B981);
const Color _kSlate500 = Color(0xFF64748B);
const Color _kSlate400 = Color(0xFF94A3B8);
const Color _kSlate700 = Color(0xFF334155);
const Color _kPaywallBg = Color(0xFF000000);
const double _kMaxContentWidth = 448;

/// Paywall Pro (essai terminé). Mobile & web : plans + tableau comparatif or unifié.
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

  Widget _trialFooterWithLegal(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _trialFooterActions(context, l10n),
        if (kIsWeb) ...[
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget body = PaychekMobileUpgradePaywall(
      showTopClose: false,
      header: _trialHeadline(l10n),
      feedbackBanner: _feedbackBannerWidget(),
      footerActions: _trialFooterWithLegal(context, l10n),
      onSubscribe: (cycle) => _onSubscribe(context, l10n, cycle),
    );

    if (kIsWeb) {
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
          child: body,
        ),
      );
    }

    return Material(
      color: kIsWeb ? _kPaywallBg : const Color(0xFF020205),
      child: SafeArea(child: body),
    );
  }
}
