import 'package:flutter/material.dart';

import '../analyse/analyse_report_snapshot.dart';
import '../dashboard/dashboard_analyse_oled_preview.dart';
import '../dashboard/dashboard_analyse_shortcut.dart';
import '../l10n/app_localizations.dart';
import 'paychek_web_tokens.dart';

/// Aperçu « Mon analyse » web : en-tête maquette + rapport OLED (test).
class WebDashboardAnalysePreview extends StatelessWidget {
  const WebDashboardAnalysePreview({
    super.key,
    required this.snapshot,
    required this.onOpenAnalyse,
    this.cardBackgroundColor,
  });

  final AnalyseReportSnapshot? snapshot;
  final VoidCallback onOpenAnalyse;

  /// Transparent si la carte est dans [WebDashboardPairedCard].
  final Color? cardBackgroundColor;

  static const double _innerContentWidthFactor = 0.92;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = snapshot;
    final bg = cardBackgroundColor ?? Colors.transparent;

    return ColoredBox(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final innerW =
                (constraints.maxWidth * _innerContentWidthFactor).clamp(0.0, double.infinity);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: innerW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardAnalyseShortcutHeader(
                      title: l.dashboardAnalyseShortcutTitle,
                      onOpenAnalyse: onOpenAnalyse,
                      leadingIcon: Icons.show_chart_rounded,
                      titleUppercase: true,
                      iconSize: 16,
                      chevronSize: 20,
                      iconColor: PaychekWebTokens.textGray500,
                      titleStyle: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: PaychekWebTokens.textGray500,
                      ),
                    ),
                    if (s != null) ...[
                      const SizedBox(height: 14),
                      DashboardAnalyseOledPreviewContent(snapshot: s),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
