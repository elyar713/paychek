import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../web/paychek_web_tokens.dart';
import 'dashboard_tokens.dart';

/// Barre de navigation principale — **fixe** sous toutes les pages du [DashboardPage].
///
/// Index alignés sur [IndexedStack] : 0 Dashboard, 1 Trade, 2 Ajouter, 3 Calendrier, 4 Plus.
class DashboardMainBottomNav extends StatelessWidget {
  const DashboardMainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onDestination,
    this.showPlusTab = true,
  });

  /// Hauteur du fond sous les onglets latéraux (sans la protrusion du bouton +).
  static const double sideNavBgHeight = 46;

  /// Hauteur totale des icônes (bouton + compris).
  static const double barHeight = 66;

  /// Espace réservé sous le contenu dans [DashboardPage] — identique sur tous les onglets.
  static double totalHeight(double bottomInset) => barHeight + bottomInset;

  final int currentIndex;
  final ValueChanged<int> onDestination;

  /// Sur le Web le menu Plus est dans le rail gauche : pas d’onglet Plus en bas.
  final bool showPlusTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bgColor =
        kIsWeb ? PaychekWebTokens.scaffoldBg : DashboardTokens.scaffoldMatte;
    final fondHeight = sideNavBgHeight + bottomInset;
    // Pas de [BottomAppBar] ici : la barre est placée hors du [Scaffold] ([Stack] dans
    // [DashboardPage]) pour rester cliquable quand le tiroir Plus est ouvert.
    // [BottomAppBar] appelle [Scaffold.geometryOf] et exige un ancêtre [Scaffold].
    return SizedBox(
      height: totalHeight(bottomInset),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: fondHeight,
            child: ColoredBox(color: bgColor),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _NavBtn(
                      icon: Icons.dashboard_outlined,
                      label: l10n.navDashboard,
                      active: currentIndex == 0,
                      onTap: () => onDestination(0),
                    ),
                  ),
                  Expanded(
                    child: _NavBtn(
                      icon: Icons.candlestick_chart_outlined,
                      label: l10n.navTrade,
                      active: currentIndex == 1,
                      onTap: () => onDestination(1),
                    ),
                  ),
                  Expanded(
                    child: _CenterAddNavBtn(
                      label: l10n.navAdd,
                      active: currentIndex == 2,
                      onTap: () => onDestination(2),
                    ),
                  ),
                  Expanded(
                    child: _NavBtn(
                      icon: Icons.calendar_today_outlined,
                      label: l10n.navCalendar,
                      active: currentIndex == 3,
                      onTap: () => onDestination(3),
                    ),
                  ),
                  if (showPlusTab)
                    Expanded(
                      child: _NavBtn(
                        icon: Icons.menu_rounded,
                        label: l10n.navMore,
                        active: currentIndex == 4,
                        onTap: () => onDestination(4),
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

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (kIsWeb ? PaychekWebTokens.accentMint : DashboardTokens.onMatteEmphasis)
        : DashboardTokens.navInactive;
    final base = Theme.of(context).textTheme.labelSmall ??
        Theme.of(context).textTheme.bodySmall ??
        const TextStyle();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 8, top: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: base.copyWith(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterAddNavBtn extends StatelessWidget {
  const _CenterAddNavBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (kIsWeb ? PaychekWebTokens.accentMint : DashboardTokens.onMatteEmphasis)
        : DashboardTokens.navInactive;
    final base = Theme.of(context).textTheme.labelSmall ??
        Theme.of(context).textTheme.bodySmall ??
        const TextStyle();
    final fabBg =
        kIsWeb ? const Color(0xFF252528) : DashboardTokens.bottomNavFabBg;
    final fabIcon =
        kIsWeb ? PaychekWebTokens.accentMint : DashboardTokens.onMatteEmphasis;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 8, top: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: fabBg,
                    shape: BoxShape.circle,
                    border: kIsWeb
                        ? Border.all(
                            color: PaychekWebTokens.accentMint.withValues(alpha: 0.35),
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add,
                    color: fabIcon,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: base.copyWith(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
