import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'reglage_profile_connect_tokens.dart';

/// Logo Paychek (SVG) — connexion / inscription mobile et réglages.
class PaychekBrandLogoMark extends StatelessWidget {
  const PaychekBrandLogoMark({
    super.key,
    this.height = 48,
  });

  static const String assetPath = 'assets/branding/app_icon.svg';

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        semanticsLabel: 'Paychek',
      ),
    );
  }
}

class ReglageProfileAuthTabButton extends StatelessWidget {
  const ReglageProfileAuthTabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? kReglageProfileBrandTeal : const Color(0xFF1A1A1C),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected
                  ? Colors.black
                  : DashboardTokens.onMatteEmphasis,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bloc logo centré (fond #050505) — page compte hors style « terminal ».
class ReglageProfileNavbarHorizontalLogo extends StatelessWidget {
  const ReglageProfileNavbarHorizontalLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PaychekBrandLogoMark(height: 52),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.splashTagline,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.35,
              color: DashboardTokens.labelGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class ReglageProfileGoogleBrandMark extends StatelessWidget {
  const ReglageProfileGoogleBrandMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        kReglageProfileSvgGoogleG,
        fit: BoxFit.contain,
        clipBehavior: Clip.hardEdge,
      ),
    );
  }
}

class ReglageProfileDiscordBrandMark extends StatelessWidget {
  const ReglageProfileDiscordBrandMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        kReglageProfileSvgDiscord,
        fit: BoxFit.contain,
        clipBehavior: Clip.hardEdge,
      ),
    );
  }
}

/// Pastille Facebook (bleu marque).
class ReglageProfileFacebookBrandMark extends StatelessWidget {
  const ReglageProfileFacebookBrandMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: kReglageProfileFacebookBlue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Transform.translate(
            offset: Offset(0, -size * 0.02),
            child: Text(
              'f',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.62,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
