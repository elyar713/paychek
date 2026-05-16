part of 'reglage_page.dart';


class _ReglageSurface extends StatelessWidget {
  const _ReglageSurface({required this.child, this.compact = false});

  final Widget child;

  /// Carte plus lÃ©gÃ¨re (section Trading) : moins de contraste et dâ€™ombre.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final web = kIsWeb;
    final radius = web
        ? PaychekWebTokens.radiusCard
        : (compact ? 16.0 : 22.0);
    return Container(
      decoration: BoxDecoration(
        color: web
            ? PaychekWebTokens.cardBg
            : (compact
                ? const Color(0xFF0E0E10).withValues(alpha: 0.72)
                : const Color(0xFF0E0E10)),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: web
              ? PaychekWebTokens.borderGray800
              : (compact
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.55)
                  : const Color(0xFF1A1A1A)),
        ),
        boxShadow: web
            ? const []
            : [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: compact ? 0.28 : 0.45),
                  blurRadius: compact ? 12 : 24,
                  offset: Offset(0, compact ? 6 : 12),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

/// Carte unique : semaine affichée + langue (deux blocs repliables).
class _LanguageAndTradingWeekSection extends StatelessWidget {
  const _LanguageAndTradingWeekSection({
    required this.tradingWeek,
    required this.localeController,
  });

  final TradingWeekController tradingWeek;
  final AppLocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: Listenable.merge([tradingWeek, localeController]),
      builder: (context, _) {
        final d = tradingWeek.tradingDaysPerWeek;
        final weekLabel = d == 5
            ? l10n.settingsTradingWeek5
            : l10n.settingsTradingWeek7;
        final code = ReglageLanguagePrefs.codeFromLocale(
          localeController.locale,
        );
        final langLabel = languageLabelForCode(l10n, code);

        return _ReglageSurface(
          compact: true,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.white.withValues(alpha: 0.06),
              highlightColor: Colors.white.withValues(alpha: 0.04),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExpansionTile(
                  initiallyExpanded: false,
                  tilePadding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
                  childrenPadding: const EdgeInsets.only(bottom: 6),
                  collapsedShape: const RoundedRectangleBorder(),
                  shape: const RoundedRectangleBorder(),
                  iconColor: kIsWeb
                      ? PaychekWebTokens.accentEmerald
                      : _kBrandTeal,
                  collapsedIconColor: kIsWeb
                      ? PaychekWebTokens.textGray500
                      : DashboardTokens.labelGrey,
                  title: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kIsWeb
                              ? PaychekWebTokens.pillTrackBg
                              : const Color(0xFF121214),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: kIsWeb
                                ? PaychekWebTokens.borderGray800
                                : _kBrandTeal.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.calendar_view_week_rounded,
                          color: DashboardTokens.onMatteEmphasis,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reglageSectionHeadingText(
                                l10n.settingsTradingWeekTitle,
                              ),
                              style: reglageSectionHeaderRowStyle(),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              weekLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: DashboardTokens.onMatteEmphasis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      child: Text(
                        l10n.settingsTradingWeekSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: DashboardTokens.muted,
                          height: 1.35,
                        ),
                      ),
                    ),
                    _TradingWeekOptionRow(
                      label: '5',
                      title: l10n.settingsTradingWeek5,
                      selected: d == 5,
                      onTap: () => tradingWeek.select(5),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 64, right: 12),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: kIsWeb
                            ? PaychekWebTokens.borderGray800
                                .withValues(alpha: 0.75)
                            : DashboardTokens.border,
                      ),
                    ),
                    _TradingWeekOptionRow(
                      label: '7',
                      title: l10n.settingsTradingWeek7,
                      selected: d == 7,
                      onTap: () => tradingWeek.select(7),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: kIsWeb
                        ? PaychekWebTokens.borderGray800
                            .withValues(alpha: 0.75)
                        : DashboardTokens.border,
                  ),
                ),
                ExpansionTile(
                  initiallyExpanded: false,
                  tilePadding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
                  childrenPadding: const EdgeInsets.only(bottom: 6),
                  collapsedShape: const RoundedRectangleBorder(),
                  shape: const RoundedRectangleBorder(),
                  iconColor: kIsWeb
                      ? PaychekWebTokens.accentEmerald
                      : _kBrandTeal,
                  collapsedIconColor: kIsWeb
                      ? PaychekWebTokens.textGray500
                      : DashboardTokens.labelGrey,
                  title: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kIsWeb
                              ? PaychekWebTokens.pillTrackBg
                              : const Color(0xFF121214),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: kIsWeb
                                ? PaychekWebTokens.borderGray800
                                : _kBrandTeal.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          languageFlagEmoji(code),
                          style: const TextStyle(fontSize: 22, height: 1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reglageSectionHeadingText(l10n.languageSection),
                              style: reglageSectionHeaderRowStyle(),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              langLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: DashboardTokens.onMatteEmphasis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: [
                    for (
                      var i = 0;
                      i < kAppLanguageCodesDisplayOrder.length;
                      i++
                    ) ...[
                      if (i > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 64, right: 12),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: kIsWeb
                                ? PaychekWebTokens.borderGray800
                                    .withValues(alpha: 0.75)
                                : DashboardTokens.border,
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
                        onTap: () => localeController.selectCode(
                          kAppLanguageCodesDisplayOrder[i],
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TradingWeekOptionRow extends StatelessWidget {
  const _TradingWeekOptionRow({
    required this.label,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String title;
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
                      ? (kIsWeb
                          ? PaychekWebTokens.accentEmerald
                              .withValues(alpha: 0.65)
                          : _kBrandTeal.withValues(alpha: 0.55))
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DashboardTokens.onMatteEmphasis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
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
                  ? (kIsWeb
                      ? PaychekWebTokens.accentEmerald
                      : _kBrandTeal)
                  : DashboardTokens.navInactive,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

