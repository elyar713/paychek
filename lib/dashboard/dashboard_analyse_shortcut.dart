import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../analyse/analyse_report_snapshot.dart';
import '../checklist/checklist_tokens.dart';
import '../l10n/app_localizations.dart';
import '../web/web_dashboard_analyse_preview.dart';
import 'dashboard_analyse_oled_preview.dart';
import 'widgets/dashboard_section_shell.dart';

/// Raccourci sous la checklist : rapport OLED figé, chevron → page Analyse.
class DashboardAnalyseShortcut extends StatelessWidget {
  const DashboardAnalyseShortcut({
    super.key,
    required this.snapshot,
    required this.onOpenAnalyse,
    this.cardBackgroundColor,
  });

  /// `null` : titre « Mon analyse » + chevron uniquement (comme checklist vide).
  final AnalyseReportSnapshot? snapshot;
  final VoidCallback onOpenAnalyse;

  final Color? cardBackgroundColor;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebDashboardAnalysePreview(
        snapshot: snapshot,
        onOpenAnalyse: onOpenAnalyse,
        cardBackgroundColor: cardBackgroundColor,
      );
    }
    final l = AppLocalizations.of(context)!;
    final s = snapshot;

    return DashboardSectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardAnalyseShortcutHeader(
            title: l.dashboardAnalyseShortcutTitle,
            onOpenAnalyse: onOpenAnalyse,
          ),
          if (s != null) ...[
            const SizedBox(height: ChecklistTokens.sectionHeaderToItemsGap),
            DashboardAnalyseOledPreviewContent(snapshot: s),
          ],
        ],
      ),
    );
  }
}

/// En-tête partagé mobile / web (titre + chevron).
class DashboardAnalyseShortcutHeader extends StatelessWidget {
  const DashboardAnalyseShortcutHeader({
    super.key,
    required this.title,
    required this.onOpenAnalyse,
    this.leadingIcon = Icons.auto_graph_outlined,
    this.titleUppercase = false,
    this.iconSize = 18,
    this.chevronSize = 24,
    this.titleStyle,
    this.iconColor,
  });

  final String title;
  final VoidCallback onOpenAnalyse;
  final IconData leadingIcon;
  final bool titleUppercase;
  final double iconSize;
  final double chevronSize;
  final TextStyle? titleStyle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final displayTitle = titleUppercase ? title.toUpperCase() : title;
    final style = titleStyle ??
        ChecklistTokens.sectionTitleOnCardStyle.copyWith(
          fontSize: 10,
          letterSpacing: titleUppercase ? 1.2 : 0.4,
          fontWeight: titleUppercase ? FontWeight.w800 : FontWeight.w700,
        );
    final ic = iconColor ?? style.color ?? ChecklistTokens.sectionTitleOnCardStyle.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(leadingIcon, size: iconSize, color: ic),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayTitle,
            style: style,
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpenAnalyse,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.chevron_right_rounded,
                size: chevronSize,
                color: ic,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
