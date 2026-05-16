import 'package:flutter/material.dart';

import '../reglage/reglage_profile_auth_panel.dart';
import '../reglage/reglage_profile_connect_constants.dart';
import '../reglage/reglage_profile_connect_terminal_chrome.dart';
import '../reglage/reglage_profile_connect_tokens.dart';

/// Mobile : connexion / inscription **obligatoires** avant d’entrer dans l’app (pas d’invité).
class MobileMandatoryAuthScreen extends StatelessWidget {
  const MobileMandatoryAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kReglageProfileMonoBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const TerminalAuthBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: ReglageProfileAuthPanel(
                initialTab: ReglageAuthInitialTab.connexion,
                mode: ReglageAuthPanelMode.tabbed,
                showNavbarLogo: true,
                showContinueHeading: false,
                showAuthEyebrow: false,
                dense: false,
                premiumTerminalChrome: true,
                onAuthSuccess: () {
                  // [MobileRootGate] reconstruit sur session Firebase.
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
