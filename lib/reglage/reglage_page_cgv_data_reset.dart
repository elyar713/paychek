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

class _DataResetSection extends StatefulWidget {
  const _DataResetSection({
    required this.capitalStore,
    required this.portfolioStore,
    required this.profileStore,
    required this.journalStore,
    required this.layoutStore,
    required this.localeController,
    required this.tradingWeek,
    required this.onResetComplete,
  });

  final UserCapitalStore capitalStore;
  final UserPortfolioStore portfolioStore;
  final UserProfileStore profileStore;
  final TradeJournalStore journalStore;
  final DashboardHomeLayoutStore layoutStore;
  final AppLocaleController localeController;
  final TradingWeekController tradingWeek;
  final VoidCallback onResetComplete;

  @override
  State<_DataResetSection> createState() => _DataResetSectionState();
}

class _DataResetSectionState extends State<_DataResetSection> {
  static const Color _kEraseRed = Color(0xFFFF5252);

  bool _busy = false;

  Future<void> _confirmAndReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text(
          l10n.settingsDataResetDialogTitle,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            l10n.settingsDataResetDialogBody,
            style: GoogleFonts.plusJakartaSans(
              color: DashboardTokens.labelGrey,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.settingsDataResetDialogCancel,
              style: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.settingsDataResetDialogConfirm,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await applyAppLocalDataReset(
        capital: widget.capitalStore,
        portfolio: widget.portfolioStore,
        profileStore: widget.profileStore,
        journal: widget.journalStore,
        layoutStore: widget.layoutStore,
        localeController: widget.localeController,
        tradingWeek: widget.tradingWeek,
      );
      if (!context.mounted) return;
      widget.onResetComplete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsDataResetSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A2A2A),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
              reglageSectionHeadingText(l10n.settingsDataResetSection),
              style: reglageSectionHeaderRowStyle(),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _busy ? null : () => _confirmAndReset(context),
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
                        Icons.delete_forever_outlined,
                        size: 20,
                        color: _kEraseRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.settingsDataResetButton,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kEraseRed,
                        ),
                      ),
                    ),
                    if (_busy)
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _kEraseRed.withValues(alpha: 0.85),
                        ),
                      )
                    else
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

