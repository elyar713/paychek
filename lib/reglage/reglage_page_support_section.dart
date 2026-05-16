part of 'reglage_page.dart';

/// Carte « Support & Feedback » → page dédiée (formulaire + actions).
class _SupportFeedbackReglageCard extends StatelessWidget {
  const _SupportFeedbackReglageCard({
    required this.onOpenHelpCenterInShell,
  });

  final VoidCallback? onOpenHelpCenterInShell;

  void _openPage(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SupportFeedbackPage(
          onOpenHelpCenterInShell: onOpenHelpCenterInShell,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _ReglageSurface(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPage(context),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: kIsWeb
                        ? PaychekWebTokens.pillTrackBg
                        : const Color(0xFF121214),
                    border: Border.all(
                      color: kIsWeb
                          ? PaychekWebTokens.borderGray800
                          : const Color(0xFF232326),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: kIsWeb
                        ? PaychekWebTokens.accentEmerald
                        : _kBrandTeal,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsSupportCardTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: DashboardTokens.onMatteEmphasis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsSupportCardSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: DashboardTokens.labelGrey,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: DashboardTokens.navInactive,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte Centre d’aide — distincte du support (contenu aide in-app).
class _HelpCenterReglageCard extends StatelessWidget {
  const _HelpCenterReglageCard({this.onOpenHelpCenter});

  final VoidCallback? onOpenHelpCenter;

  void _openHelpCenter(BuildContext context) {
    if (onOpenHelpCenter != null) {
      onOpenHelpCenter!();
      return;
    }
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const HelpCenterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _ReglageSurface(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openHelpCenter(context),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: kIsWeb
                        ? PaychekWebTokens.pillTrackBg
                        : const Color(0xFF121214),
                    border: Border.all(
                      color: kIsWeb
                          ? PaychekWebTokens.borderGray800
                          : const Color(0xFF232326),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: kIsWeb
                        ? PaychekWebTokens.accentEmerald
                        : _kBrandTeal,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.helpCenterTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: DashboardTokens.onMatteEmphasis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.helpCenterSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: DashboardTokens.labelGrey,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: DashboardTokens.navInactive,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
