import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../paychek_apple_iap_checkout.dart';
import '../paychek_apple_iap_service.dart';
import '../paychek_entitlement_local_sync.dart';
import '../paychek_google_play_iap_checkout.dart';
import '../paychek_google_play_iap_service.dart';
import '../paychek_subscription_platform.dart';
import 'mobile/paywall_mobile_tokens.dart';

/// Bouton « Restaurer les achats » exigé par l’App Store (3.1.1) — action explicite au tap.
class PaychekRestorePurchasesButton extends StatefulWidget {
  const PaychekRestorePurchasesButton({
    super.key,
    this.onAfterRestore,
    this.compact = false,
  });

  /// Appelé après tentative (ex. recharger le paywall / profil).
  final Future<void> Function(bool restoredPro)? onAfterRestore;

  final bool compact;

  @override
  State<PaychekRestorePurchasesButton> createState() =>
      _PaychekRestorePurchasesButtonState();
}

class _PaychekRestorePurchasesButtonState
    extends State<PaychekRestorePurchasesButton> {
  bool _busy = false;

  Future<void> _onRestore() async {
    if (_busy || !paychekUsesNativeStoreIap) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() => _busy = true);
    var restored = false;
    try {
      if (paychekUsesNativeAppleIap) {
        final outcome = await restoreProOnMobileStore();
        restored = outcome == PaychekAppleIapPurchaseOutcome.success;
      } else if (paychekUsesNativeGooglePlayIap) {
        final outcome = await restoreProOnAndroidStore();
        restored = outcome == PaychekGooglePlayIapPurchaseOutcome.success;
      }
      if (restored) {
        await PaychekEntitlementLocalSync.refreshProFromServer();
      }
      if (!mounted) return;
      if (restored) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(l10n.paywallRestorePurchasesSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(l10n.paywallRestoreNothingFound),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      await widget.onAfterRestore?.call(restored);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!paychekUsesNativeStoreIap) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: _busy ? null : _onRestore,
      child: _busy
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: PaywallMobileTokens.amber400,
              ),
            )
          : Text(
              l10n.paywallRestorePurchasesButton,
              style: GoogleFonts.plusJakartaSans(
                fontSize: widget.compact ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: PaywallMobileTokens.amber400,
                decoration: TextDecoration.underline,
                decorationColor: PaywallMobileTokens.amber400.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
    );
  }
}
