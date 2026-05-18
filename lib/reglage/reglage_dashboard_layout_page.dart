import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_home_layout_keys.dart';
import '../dashboard/dashboard_home_layout_scope.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../widgets/paychek_page_header.dart';

/// Réglages des sections de l’accueil : ordre (glisser) + activation.
class ReglageDashboardLayoutPage extends StatelessWidget {
  const ReglageDashboardLayoutPage({super.key, this.onOpenHomeTab});

  /// Après retour : aller à l’onglet accueil (optionnel).
  final VoidCallback? onOpenHomeTab;

  static String _sectionTitle(AppLocalizations l, String id) {
    switch (id) {
      case DashboardHomeLayoutKeys.capitalBalance:
        return l.settingsDashSectionCapital;
      case DashboardHomeLayoutKeys.checklist:
        return l.settingsDashSectionChecklist;
      case DashboardHomeLayoutKeys.analyse:
        return l.settingsDashSectionAnalyse;
      case DashboardHomeLayoutKeys.etatMental:
        return l.settingsDashSectionEtat;
      case DashboardHomeLayoutKeys.strategie:
        return l.settingsDashSectionStrategie;
      case DashboardHomeLayoutKeys.paychekLens:
        return l.settingsDashSectionLens;
      case DashboardHomeLayoutKeys.capitalEvolution:
        return l.settingsDashSectionEvolution;
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final store = DashboardHomeLayoutScope.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PaychekPageHeader(
            onBack: () => Navigator.of(context).pop(),
            title: l10n.settingsDashLayoutTitle,
            subtitle: l10n.settingsDashLayoutReorderHint,
            subtitleMaxLines: 2,
            maxContentWidth: 720,
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: store,
              builder: (context, _) {
                final order = store.sectionOrder;
                return ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: order.length,
                  onReorder: store.reorder,
                  // Sinon Flutter superpose un handle par défaut à droite (desktop) :
                  // il recouvre le Switch. La poignée explicite est à gauche.
                  buildDefaultDragHandles: false,
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        final t = Curves.easeInOut.transform(animation.value);
                        return Transform.scale(
                          scale: 1.0 + 0.02 * t,
                          child: Opacity(
                            opacity: 0.94 + 0.06 * t,
                            child: Material(
                              color: Colors.transparent,
                              elevation: 4 * t,
                              borderRadius: BorderRadius.circular(14),
                              child: child,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  itemBuilder: (context, index) {
                    final id = order[index];
                    final enabled = store.isEnabled(id);
                    return Material(
                      key: ValueKey<String>(id),
                      color: Colors.transparent,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E0E10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                child: Icon(
                                  Icons.drag_handle_rounded,
                                  color: DashboardTokens.navInactive,
                                  size: 26,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  _sectionTitle(l10n, id),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: DashboardTokens.onMatteEmphasis,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Switch.adaptive(
                                value: enabled,
                                activeThumbColor: const Color(0xFF1EB48A),
                                onChanged: (v) =>
                                    store.setSectionEnabled(id, v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (onOpenHomeTab != null)
            SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onOpenHomeTab!();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1EB48A),
                  side: const BorderSide(color: Color(0xFF1EB48A)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  l10n.settingsDashOpenHomeButton,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }
}
