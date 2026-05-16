part of 'reglage_page.dart';


class _DashboardShortcutCard extends StatelessWidget {
  const _DashboardShortcutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _ReglageSurface(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
                    Icons.space_dashboard_rounded,
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
                        l10n.navDashboard,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: DashboardTokens.onMatteEmphasis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsDashboardCardSubtitle,
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    this.accountPlanIsPro,
    required this.onTap,
  });

  final ReglageProfileData profile;
  /// `null` : entitlement pas encore chargé (pas de pastille).
  final bool? accountPlanIsPro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isProForUi = accountPlanIsPro == true;
    final showPlanBadge = accountPlanIsPro != null;

    return _ReglageSurface(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _AvatarInitials(initials: profile.initials, isPro: isProForUi),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: DashboardTokens.onMatteEmphasis,
                          ),
                          children: [
                            TextSpan(text: profile.displayName),
                            if (showPlanBadge)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: PaychekPlanMinimalBadge(
                                    key: ValueKey(accountPlanIsPro),
                                    isPro: isProForUi,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (profile.inscrit && profile.hasEmailBelowName) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.emailBelowName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: DashboardTokens.labelGrey,
                            height: 1.2,
                          ),
                        ),
                      ],
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

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.initials, required this.isPro});

  final String initials;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final web = kIsWeb;
    final shadowColor = isPro
        ? DashboardTokens.proBadgeGold.withValues(alpha: 0.35)
        : const Color(0xFF6B6B70).withValues(alpha: 0.28);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color:
            web ? PaychekWebTokens.pillTrackBg : const Color(0xFF121214),
        boxShadow: web
            ? const []
            : [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: isPro ? 18 : 14,
                  spreadRadius: 0,
                ),
              ],
        border: Border.all(
          color: web
              ? PaychekWebTokens.borderGray800
              : const Color(0xFF232326),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: DashboardTokens.onMatteEmphasis,
        ),
      ),
    );
  }
}

