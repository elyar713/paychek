import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'reglage_language_prefs.dart';

/// Teal marque (aligné réglages / splash).
const Color kLanguagePickerBrandTeal = Color(0xFF1EB48A);

String languageLabelForCode(AppLocalizations l10n, String code) {
  switch (code) {
    case ReglageLanguagePrefs.codeFrench:
      return l10n.langFrench;
    case ReglageLanguagePrefs.codeEnglish:
      return l10n.langEnglish;
    case ReglageLanguagePrefs.codeSpanish:
      return l10n.langSpanish;
    case ReglageLanguagePrefs.codePortuguese:
      return l10n.langPortuguese;
    case ReglageLanguagePrefs.codeGerman:
      return l10n.langGerman;
    case ReglageLanguagePrefs.codeKorean:
      return l10n.langKorean;
    default:
      return l10n.langEnglish;
  }
}

/// Drapeau (séquence régionale Unicode) par code langue de l’app.
String languageFlagEmoji(String code) {
  switch (code) {
    case ReglageLanguagePrefs.codeFrench:
      return '🇫🇷';
    case ReglageLanguagePrefs.codeEnglish:
      return '🇬🇧';
    case ReglageLanguagePrefs.codeSpanish:
      return '🇪🇸';
    case ReglageLanguagePrefs.codePortuguese:
      return '🇵🇹';
    case ReglageLanguagePrefs.codeGerman:
      return '🇩🇪';
    case ReglageLanguagePrefs.codeKorean:
      return '🇰🇷';
    default:
      return '🇬🇧';
  }
}

/// Ordre d’affichage commun (réglages, onboarding) — anglais en premier.
const List<String> kAppLanguageCodesDisplayOrder = <String>[
  ReglageLanguagePrefs.codeEnglish,
  ReglageLanguagePrefs.codeFrench,
  ReglageLanguagePrefs.codeSpanish,
  ReglageLanguagePrefs.codePortuguese,
  ReglageLanguagePrefs.codeGerman,
  ReglageLanguagePrefs.codeKorean,
];

class LanguagePickerRow extends StatelessWidget {
  const LanguagePickerRow({
    super.key,
    required this.flagEmoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flagEmoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF121214),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? kLanguagePickerBrandTeal.withValues(alpha: 0.55)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                flagEmoji,
                style: const TextStyle(fontSize: 22, height: 1),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: DashboardTokens.onMatteEmphasis,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected
                  ? kLanguagePickerBrandTeal
                  : DashboardTokens.navInactive,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
