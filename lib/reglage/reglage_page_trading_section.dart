part of 'reglage_page.dart';


class _TradingPrefsSection extends StatefulWidget {
  const _TradingPrefsSection({
    required this.capitalStore,
    required this.portfolioStore,
    required this.onClose,
  });

  final UserCapitalStore capitalStore;
  final UserPortfolioStore portfolioStore;

  /// Après choix d'un portefeuille dans la liste : fermer les réglages (dashboard).
  final VoidCallback onClose;

  @override
  State<_TradingPrefsSection> createState() => _TradingPrefsSectionState();
}

class _TradingPrefsSectionState extends State<_TradingPrefsSection> {
  /// Null possible après hot reload (web) — toujours utiliser [_portfoliosOpen].
  bool? _portfoliosExpanded;

  bool get _portfoliosOpen => _portfoliosExpanded ?? false;

  String _capitalLine() {
    final a = widget.capitalStore.capitalAmount;
    if (a == null) return '\u2014';
    final sym = widget.capitalStore.currencySymbol;
    final s = _formatThousands(a);
    return '$s $sym';
  }

  String _portfoliosHeaderValue() {
    final p = widget.portfolioStore.activePortfolio;
    if (p == null) return widget.portfolioStore.summaryForRow();
    final n = p.name.trim();
    return n.isEmpty ? kDefaultPortfolioName : n;
  }

  Future<void> _confirmDelete(BuildContext context, UserPortfolio p) async {
    if (p.id == kDefaultPortfolioId) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text(
          l10n.deletePortfolioTitle(p.name),
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.delete,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await widget.portfolioStore.remove(p.id);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.portfolioStore;
    final portfoliosOpen = _portfoliosOpen;
    return ListenableBuilder(
      listenable: Listenable.merge([widget.capitalStore, store]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        return _ReglageSurface(
          compact: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                child: Text(
                  reglageSectionHeadingText(l10n.tradingSection),
                  style: reglageSectionHeaderRowStyle(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        Icons.account_balance_wallet_outlined,
                        size: 20,
                        color: DashboardTokens.onMatteEmphasis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.capitalLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: DashboardTokens.onMatteEmphasis,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _capitalLine(),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DashboardTokens.onMatteEmphasis,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.capitalTooltip,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: kIsWeb
                            ? PaychekWebTokens.accentEmerald
                            : DashboardTokens.accent,
                        size: 22,
                      ),
                      onPressed: () => showReglagePortfolioSheet(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 64, right: 12),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: kIsWeb
                      ? PaychekWebTokens.borderGray800.withValues(alpha: 0.75)
                      : DashboardTokens.border,
                ),
              ),
              InkWell(
                onTap: () => setState(() {
                  _portfoliosExpanded = !portfoliosOpen;
                }),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
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
                          Icons.pie_chart_outline_rounded,
                          size: 20,
                          color: DashboardTokens.onMatteEmphasis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Text(
                          l10n.portfoliosLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: DashboardTokens.onMatteEmphasis,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _portfoliosHeaderValue(),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DashboardTokens.onMatteEmphasis,
                          ),
                        ),
                      ),
                      Icon(
                        portfoliosOpen
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: DashboardTokens.navInactive,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              if (portfoliosOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Column(
                    children: [
                      for (final p in store.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: kIsWeb
                                ? PaychekWebTokens.pillTrackBg
                                : const Color(0xFF121214),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () async {
                                await store.setActivePortfolioId(p.id);
                                if (!context.mounted) return;
                                widget.onClose();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        top: 4,
                                        right: 4,
                                      ),
                                      child: Icon(
                                        store.activePortfolioId == p.id
                                            ? Icons.check_circle_rounded
                                            : Icons.circle_outlined,
                                        color: store.activePortfolioId == p.id
                                            ? (kIsWeb
                                                ? PaychekWebTokens.accentEmerald
                                                : _kBrandTeal)
                                            : DashboardTokens.navInactive,
                                        size: 22,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name.isEmpty
                                                ? kDefaultPortfolioName
                                                : p.name,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            store.displayLine(p),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: DashboardTokens.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: l10n.editPortfolioTooltip,
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showReglageSinglePortfolioEditor(
                                          context,
                                          store: store,
                                          existing: p,
                                        );
                                      },
                                    ),
                                    if (p.id != kDefaultPortfolioId)
                                      IconButton(
                                        tooltip: l10n.deleteTooltip,
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.white.withValues(
                                            alpha: 0.35,
                                          ),
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _confirmDelete(context, p),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            showReglageSinglePortfolioEditor(
                              context,
                              store: store,
                              existing: null,
                            );
                          },
                          icon: Icon(
                            Icons.add_rounded,
                            color: kIsWeb
                                ? PaychekWebTokens.accentEmerald
                                : _kBrandTeal,
                            size: 20,
                          ),
                          label: Text(
                            l10n.addPortfolio,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: kIsWeb
                                  ? PaychekWebTokens.accentEmerald
                                  : _kBrandTeal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

