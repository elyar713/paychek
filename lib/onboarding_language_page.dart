import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard/dashboard_tokens.dart';
import 'l10n/app_localizations.dart';
import 'dashboard_page.dart';
import 'reglage/app_locale_scope.dart';
import 'reglage/language_picker_shared.dart';
import 'reglage/reglage_language_prefs.dart';

/// Choix de la langue après le splash (hors session). Le questionnaire s’affiche après **première**
/// inscription une fois connecté ([PostAuthGate]), pas ici.
class OnboardingLanguagePage extends StatelessWidget {
  const OnboardingLanguagePage({super.key, this.onContinueWithoutNavigator});

  /// Si non null (ex. [MobileRootGate]), continue sans [Navigator.pushReplacement] pour garder la racine auth.
  final VoidCallback? onContinueWithoutNavigator;

  @override
  Widget build(BuildContext context) {
    final localeController = AppLocaleScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: localeController,
          builder: (context, _) {
            final code = ReglageLanguagePrefs.codeFromLocale(
              localeController.locale,
            );
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.languageDialogTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: DashboardTokens.onMatteEmphasis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.languageDialogSubtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: DashboardTokens.labelGrey,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (var i = 0; i < kAppLanguageCodesDisplayOrder.length; i++) ...[
                          if (i > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 56, right: 4),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: DashboardTokens.border,
                              ),
                            ),
                          LanguagePickerRow(
                            flagEmoji: languageFlagEmoji(
                              kAppLanguageCodesDisplayOrder[i],
                            ),
                            label: languageLabelForCode(
                              l10n,
                              kAppLanguageCodesDisplayOrder[i],
                            ),
                            selected: code == kAppLanguageCodesDisplayOrder[i],
                            onTap: () async {
                              await localeController.selectCode(
                                kAppLanguageCodesDisplayOrder[i],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      await localeController.selectCode(code);
                      if (!context.mounted) return;
                      if (onContinueWithoutNavigator != null) {
                        onContinueWithoutNavigator!();
                      } else {
                        Navigator.of(context).pushReplacement<void, void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const DashboardPage(),
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.onboardingLanguageContinue,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
