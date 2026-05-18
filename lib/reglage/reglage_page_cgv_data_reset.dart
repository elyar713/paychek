part of 'reglage_page.dart';


class _CgvSection extends StatelessWidget {
  const _CgvSection({this.onOpenCgv, this.onOpenPrivacy});

  final VoidCallback? onOpenCgv;
  final VoidCallback? onOpenPrivacy;

  void _openPage(BuildContext context) {
    if (onOpenCgv != null) {
      onOpenCgv!();
      return;
    }
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const ReglageCgvTermsPage(),
      ),
    );
  }

  void _openPrivacyPage(BuildContext context) {
    if (onOpenPrivacy != null) {
      onOpenPrivacy!();
      return;
    }
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const ReglagePrivacyPolicyPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _ReglageSurface(
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Text(
              reglageSectionHeadingText(l10n.settingsCgvSection),
              style: reglageSectionHeaderRowStyle(),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openPage(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kIsWeb
                            ? PaychekWebTokens.pillTrackBg
                            : const Color(0xFF121214),
                        borderRadius: BorderRadius.circular(10),
                        border: kIsWeb
                            ? Border.all(
                                color: PaychekWebTokens.borderGray800,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.article_outlined,
                        size: 20,
                        color: DashboardTokens.onMatteEmphasis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsCgvRowTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: DashboardTokens.onMatteEmphasis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.settingsCgvRowSubtitle,
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openPrivacyPage(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kIsWeb
                            ? PaychekWebTokens.pillTrackBg
                            : const Color(0xFF121214),
                        borderRadius: BorderRadius.circular(10),
                        border: kIsWeb
                            ? Border.all(
                                color: PaychekWebTokens.borderGray800,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: DashboardTokens.onMatteEmphasis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsPrivacyRowTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: DashboardTokens.onMatteEmphasis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.settingsPrivacyRowSubtitle,
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
        ],
      ),
    );
  }
}

