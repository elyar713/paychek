import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/paychek_page_header.dart';
export 'reglage_profile_connect_constants.dart';
import 'reglage_profile_auth_panel.dart';
import 'reglage_profile_connect_constants.dart';
import 'reglage_profile_connect_terminal_chrome.dart';
import 'reglage_profile_connect_tokens.dart';

/// Compte plein écran depuis Réglages — délègue le contenu à [ReglageProfileAuthPanel].
class ReglageProfileConnectPage extends StatelessWidget {
  const ReglageProfileConnectPage({
    super.key,
    this.initialTab = ReglageAuthInitialTab.connexion,
    this.showBackButton = true,
    this.onAuthSuccess,
  });

  final ReglageAuthInitialTab initialTab;
  final bool showBackButton;
  final VoidCallback? onAuthSuccess;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kReglageProfileMonoBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const TerminalAuthBackdrop(),
          Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBackButton)
                    PaychekPageHeader(
                      onBack: () => Navigator.of(context).pop(),
                      title: l10n.accountPageTitle,
                      subtitle: l10n.profileViewDetailsSection,
                      maxContentWidth: 520,
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: ReglageProfileAuthPanel(
                        initialTab: initialTab,
                        mode: ReglageAuthPanelMode.tabbed,
                        showNavbarLogo: true,
                        showContinueHeading: false,
                        showAuthEyebrow: false,
                        dense: false,
                        premiumTerminalChrome: true,
                        onAuthSuccess: () {
                          final cb = onAuthSuccess;
                          if (cb != null) {
                            cb();
                          } else {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(kReglageAuthSuccessPopResult);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
