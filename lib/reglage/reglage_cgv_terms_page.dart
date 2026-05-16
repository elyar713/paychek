import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

/// Page plein écran : CGV Paychek selon la langue de l’app ([AppLocalizations]).
class ReglageCgvTermsPage extends StatelessWidget {
  const ReglageCgvTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.settingsCgvPageTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
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
