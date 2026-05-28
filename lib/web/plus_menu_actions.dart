import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_localizations.dart';

/// [allowedInLite: false] sur un **onglet** (ex. Trade) → paywall sans navigation.
/// Les pages Pro (stratégie, mental, etc.) ne passent **pas** par ce gate : navigation
/// directe + [LiteFreemiumPageLock] sur la page.
typedef PlusMenuLiteGate = void Function(
  VoidCallback action, {
  required bool allowedInLite,
});

/// Entrées du menu Plus (même ordre partout : popup mobile, rail Web).
class PlusMenuActions {
  PlusMenuActions._();

  static List<({IconData icon, String label, VoidCallback onTap})> buildEntries(
    AppLocalizations l10n, {
    required ValueChanged<int> onOpenMainTab,
    required VoidCallback onOpenMental,
    required VoidCallback onOpenStrategie,
    required VoidCallback onOpenAnalyse,
    required VoidCallback onOpenPerformance,
    required VoidCallback onOpenCoachAi,
    required VoidCallback onOpenChecklist,
    required VoidCallback onOpenCalculatrice,
    required VoidCallback onOpenReglage,
    bool includeHelpCenter = true,
    VoidCallback? onOpenHelpCenter,
    VoidCallback? onOpenSupportFeedback,
    PlusMenuLiteGate? liteGate,
  }) {
    void runLite(VoidCallback inner, {required bool allowedInLite}) {
      final g = liteGate;
      if (g != null) {
        g(inner, allowedInLite: allowedInLite);
      } else {
        inner();
      }
    }

    final entries = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.dashboard_outlined,
        label: l10n.plusDashboard,
        onTap: () => runLite(() => onOpenMainTab(0), allowedInLite: true),
      ),
      (
        icon: Icons.candlestick_chart_outlined,
        label: l10n.plusTrade,
        onTap: () => runLite(() => onOpenMainTab(1), allowedInLite: false),
      ),
      (
        icon: Icons.add_circle_outline,
        label: l10n.plusAdd,
        onTap: () => runLite(() => onOpenMainTab(2), allowedInLite: true),
      ),
      (
        icon: Icons.calendar_today_outlined,
        label: l10n.plusCalendar,
        onTap: () => runLite(() => onOpenMainTab(3), allowedInLite: true),
      ),
      (
        icon: Icons.psychology_outlined,
        label: l10n.plusMentalState,
        onTap: onOpenMental,
      ),
      (
        icon: Icons.fact_check_outlined,
        label: l10n.plusChecklist,
        onTap: onOpenChecklist,
      ),
      // track_changes Material : glyphe vide possible en web release → Lucide (cf. teaser stratégie).
      (
        icon: LucideIcons.target,
        label: l10n.plusMyStrategy,
        onTap: onOpenStrategie,
      ),
      (
        icon: Icons.analytics_outlined,
        label: l10n.plusMyAnalysis,
        onTap: onOpenAnalyse,
      ),
      (
        icon: Icons.query_stats_outlined,
        label: l10n.plusPerformance,
        onTap: onOpenPerformance,
      ),
      (
        icon: Icons.auto_awesome_outlined,
        label: 'AI Coach',
        onTap: () => runLite(onOpenCoachAi, allowedInLite: false),
      ),
      (
        icon: Icons.calculate_outlined,
        label: l10n.plusCalculator,
        onTap: onOpenCalculatrice,
      ),
      (
        icon: Icons.settings_outlined,
        label: l10n.plusSettings,
        onTap: () => runLite(onOpenReglage, allowedInLite: true),
      ),
    ];

    final support = onOpenSupportFeedback;
    if (support != null) {
      entries.insert(
        entries.length - 1,
        (
          icon: Icons.chat_bubble_outline_rounded,
          label: l10n.settingsSupportCardTitle,
          onTap: () => runLite(support, allowedInLite: true),
        ),
      );
    }
    final help = onOpenHelpCenter;
    if (includeHelpCenter && help != null) {
      entries.insert(
        entries.length - 1,
        (
          icon: Icons.help_outline_rounded,
          label: l10n.helpCenterTitle,
          onTap: () => runLite(help, allowedInLite: true),
        ),
      );
    }

    return entries;
  }
}
