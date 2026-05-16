import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'paychek_web_tokens.dart';
import 'plus_menu_actions.dart';

/// Rail gauche (Web) — structure proche de la maquette React (Menu, Plus, Paramètres).
class PlusWebLeftRail extends StatelessWidget {
  const PlusWebLeftRail({
    super.key,
    required this.onOpenAjouterTrade,
    required this.onOpenMainTab,
    required this.onOpenMental,
    required this.onOpenStrategie,
    required this.onOpenAnalyse,
    required this.onOpenPerformance,
    required this.onOpenChecklist,
    required this.onOpenCalculatrice,
    required this.onOpenHelpCenter,
    required this.onOpenSupportFeedback,
    required this.onOpenReglage,
    this.width = preferredWidth,
    this.activeMainTabIndex = 0,
    this.showMainTabSelection = true,
    this.liteGate,
  });

  /// `w-64` → 16 rem = 256 px.
  static const double preferredWidth = 256;

  final VoidCallback onOpenAjouterTrade;
  final ValueChanged<int> onOpenMainTab;
  final VoidCallback onOpenMental;
  final VoidCallback onOpenStrategie;
  final VoidCallback onOpenAnalyse;
  final VoidCallback onOpenPerformance;
  final VoidCallback onOpenChecklist;
  final VoidCallback onOpenCalculatrice;
  final VoidCallback onOpenHelpCenter;
  final VoidCallback onOpenSupportFeedback;
  final VoidCallback onOpenReglage;

  final double width;

  final int activeMainTabIndex;
  final bool showMainTabSelection;
  final PlusMenuLiteGate? liteGate;

  static const _kMainCount = 4;

  static final TextStyle _sectionHeading = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.4,
    color: PaychekWebTokens.textGray600,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = PlusMenuActions.buildEntries(
      l10n,
      onOpenMainTab: onOpenMainTab,
      onOpenMental: onOpenMental,
      onOpenStrategie: onOpenStrategie,
      onOpenAnalyse: onOpenAnalyse,
      onOpenPerformance: onOpenPerformance,
      onOpenChecklist: onOpenChecklist,
      onOpenCalculatrice: onOpenCalculatrice,
      onOpenReglage: onOpenReglage,
      onOpenHelpCenter: onOpenHelpCenter,
      onOpenSupportFeedback: onOpenSupportFeedback,
      liteGate: liteGate,
    );

    final mainEntries = entries.sublist(0, _kMainCount);
    /// Dernières entrées : … calculatrice, **Support**, **Centre d’aide**, **Réglages**.
    final toolScrollEntries = entries.sublist(4, entries.length - 3);
    final supportEntry = entries[entries.length - 3];
    final helpEntry = entries[entries.length - 2];
    final settingsEntry = entries[entries.length - 1];

    final tabIndex = activeMainTabIndex.clamp(0, _kMainCount - 1);

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PaychekWebTokens.railBg,
          border: Border(
            right: BorderSide(color: PaychekWebTokens.borderGray800),
          ),
        ),
        child: SafeArea(
          right: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PaychekRailLogo(l10n: l10n),
                const SizedBox(height: 40),
                _PrimaryAddButton(
                  label: l10n.ajouterTradePageTitle,
                  onPressed: onOpenAjouterTrade,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12),
                  child: Text(
                    l10n.webRailMenuHeading,
                    style: _sectionHeading,
                  ),
                ),
                for (var i = 0; i < mainEntries.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _MainNavRow(
                      icon: mainEntries[i].icon,
                      label: mainEntries[i].label,
                      selected: showMainTabSelection && tabIndex == i,
                      onTap: mainEntries[i].onTap,
                    ),
                  ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12),
                  child: Text(
                    l10n.navMore.toUpperCase(),
                    style: _sectionHeading,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: toolScrollEntries.length,
                    itemBuilder: (context, i) {
                      final e = toolScrollEntries[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _ToolNavRow(
                          icon: e.icon,
                          label: e.label,
                          onTap: e.onTap,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 24),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF111827)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ToolNavRow(
                        icon: supportEntry.icon,
                        label: supportEntry.label,
                        onTap: supportEntry.onTap,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _ToolNavRow(
                          icon: helpEntry.icon,
                          label: helpEntry.label,
                          onTap: helpEntry.onTap,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _ToolNavRow(
                          icon: settingsEntry.icon,
                          label: settingsEntry.label,
                          onTap: settingsEntry.onTap,
                          emphasize: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaychekRailLogo extends StatelessWidget {
  const _PaychekRailLogo({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: PaychekWebTokens.accentEmerald,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.trending_up_rounded,
            size: 20,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appBrandName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.splashTagline.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: PaychekWebTokens.textGray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryAddButton extends StatelessWidget {
  const _PrimaryAddButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(PaychekWebTokens.radiusButton),
        child: Ink(
          decoration: PaychekWebTokens.primaryButtonDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_box_rounded, size: 18, color: Colors.black87),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainNavRow extends StatelessWidget {
  const _MainNavRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final emerald = PaychekWebTokens.accentEmerald;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PaychekWebTokens.radiusNavItem),
        hoverColor: Colors.white.withValues(alpha: 0.05),
        splashColor: emerald.withValues(alpha: 0.12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? emerald.withValues(alpha: 0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(PaychekWebTokens.radiusNavItem),
            border: Border.all(
              color: selected ? emerald.withValues(alpha: 0.20) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? emerald : PaychekWebTokens.textGray400,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected ? emerald : PaychekWebTokens.textGray400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolNavRow extends StatelessWidget {
  const _ToolNavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final col =
        emphasize ? DashboardTokens.onMatteEmphasis : PaychekWebTokens.textGray400;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PaychekWebTokens.radiusNavItem),
        hoverColor: Colors.white.withValues(alpha: 0.05),
        splashColor: PaychekWebTokens.accentEmerald.withValues(alpha: 0.1),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: emphasize ? 12 : 10,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: col),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: col,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
