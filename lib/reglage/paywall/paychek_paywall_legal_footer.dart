import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../paychek_brand_links.dart';
import '../paychek_checkout_launch.dart';
import '../paychek_subscription_platform.dart';

/// Pied légal paywall IAP : facturation + liens cliquables CGU / confidentialité.
class PaychekPaywallLegalFooter extends StatelessWidget {
  const PaychekPaywallLegalFooter({
    super.key,
    this.textColor,
    this.linkColor,
    this.fontSize = 9,
  });

  final Color? textColor;
  final Color? linkColor;
  final double fontSize;

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchPaychekCheckoutUri(uri);
    if (!context.mounted || ok) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.accountAuthErrorNetwork,
          style: const TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A2A2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = textColor ?? const Color(0xFF334155);
    final accent = linkColor ?? const Color(0xFF94A3B8);
    final base = GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: -0.2,
      color: muted,
    );
    final linkStyle = base.copyWith(
      color: accent,
      decoration: TextDecoration.underline,
      decorationColor: accent,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            paychekPaywallLegalFooterLabel(l10n).toUpperCase(),
            textAlign: TextAlign.center,
            style: base,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              InkWell(
                onTap: () => unawaited(
                  _openUrl(context, kPaychekPrivacyPolicyUrl),
                ),
                child: Text(l10n.settingsPrivacyRowTitle, style: linkStyle),
              ),
              Text('•', style: base),
              InkWell(
                onTap: () => unawaited(
                  _openUrl(context, kPaychekTermsOfUseUrl),
                ),
                child: Text(l10n.settingsCgvPageTitle, style: linkStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
