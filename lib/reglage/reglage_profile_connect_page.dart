import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
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
    final t = Theme.of(context).textTheme;

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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.chevron_left,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.accountPageTitle,
                                    style: t.labelMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
