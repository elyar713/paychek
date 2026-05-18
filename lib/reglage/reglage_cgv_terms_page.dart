import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../widgets/paychek_page_header.dart';

/// Page plein écran : CGV Paychek selon la langue de l’app ([AppLocalizations]).
class ReglageCgvTermsPage extends StatelessWidget {
  const ReglageCgvTermsPage({super.key, this.onCloseInShell});

  /// Dashboard overlay : fermeture sans [Navigator.pop].
  final VoidCallback? onCloseInShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final back = PaychekPageHeader.resolveBack(
      context,
      onCloseInShell: onCloseInShell,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaychekPageHeader(
              onBack: back,
              title: l10n.settingsCgvPageTitle,
              subtitle: l10n.settingsCgvRowSubtitle,
              maxContentWidth: 720,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  PaychekPageHeader.horizontalPad(
                    MediaQuery.sizeOf(context).width,
                  ),
                  0,
                  PaychekPageHeader.horizontalPad(
                    MediaQuery.sizeOf(context).width,
                  ),
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.settingsCgvDocHeading,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: DashboardTokens.onMatteEmphasis,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _block(l10n.settingsCgv1Title, l10n.settingsCgv1Body),
                    _block(l10n.settingsCgv2Title, l10n.settingsCgv2Body),
                    _block(l10n.settingsCgv3Title, l10n.settingsCgv3Body),
                    _block(l10n.settingsCgv4Title, l10n.settingsCgv4Body),
                    _block(l10n.settingsCgv5Title, l10n.settingsCgv5Body),
                    _block(l10n.settingsCgv6Title, l10n.settingsCgv6Body),
                    _block(l10n.settingsCgv7Title, l10n.settingsCgv7Body),
                    _block(l10n.settingsCgv8Title, l10n.settingsCgv8Body),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _block(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DashboardTokens.onMatteEmphasis,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DashboardTokens.labelGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
