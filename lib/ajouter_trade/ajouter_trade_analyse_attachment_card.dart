import 'package:flutter/material.dart';

import '../analyse/analyse_report_snapshot.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_plan_analyse_menu.dart';

/// Carte **Analyse** (sous CSV) : choix d’un rapport Mon Analyse + PDF joint au trade.
class AjouterTradeAnalyseAttachmentCard extends StatelessWidget {
  const AjouterTradeAnalyseAttachmentCard({
    super.key,
    required this.labelStyle,
    required this.mutedStyle,
    required this.selectedReport,
    required this.pdfFileName,
    required this.pdfGenerating,
    required this.onReportSelected,
    required this.onClear,
    this.cardDecoration,
    this.sectionTitleColor,
    this.compact = false,
  });

  final TextStyle? labelStyle;
  final TextStyle? mutedStyle;
  final AnalyseReportSnapshot? selectedReport;
  final String? pdfFileName;
  final bool pdfGenerating;
  final ValueChanged<AnalyseReportSnapshot?> onReportSelected;
  final VoidCallback onClear;
  final BoxDecoration? cardDecoration;
  final Color? sectionTitleColor;

  /// Disposition à droite du screenshot, sous la carte CSV.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final headerStyle = (labelStyle ??
            const TextStyle(
              color: DashboardTokens.onMatteEmphasis,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.35,
            ))
        .copyWith(
          color: sectionTitleColor ?? DashboardTokens.titleGold,
          fontSize: 9,
          letterSpacing: 0.35,
        );

    final hasPdf =
        !pdfGenerating &&
        pdfFileName != null &&
        pdfFileName!.trim().isNotEmpty;

    final pad = compact
        ? const EdgeInsets.fromLTRB(10, 8, 10, 8)
        : DashboardTokens.cardPadding;
    final gapTitle = compact ? 4.0 : 8.0;
    final gapPicker = compact ? 6.0 : 12.0;
    final statusSize = compact ? 10.0 : 11.0;

    return Container(
      padding: pad,
      decoration: cardDecoration ?? DashboardTokens.cardBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.ajouterTradeAnalyseCardTitle, style: headerStyle),
          if (!compact) ...[
            SizedBox(height: gapTitle),
            Text(
              l.ajouterTradeAnalyseCardHelp,
              style: mutedStyle?.copyWith(fontSize: 12, height: 1.35),
            ),
          ],
          SizedBox(height: gapPicker),
          AjouterTradePlanAnalyseMenu(
            showDemoReports: true,
            compact: compact,
            explicitSelectionOnly: true,
            selectedSnapshot: selectedReport,
            onSelectedSnapshotChanged: onReportSelected,
          ),
          if (selectedReport != null) ...[
            SizedBox(height: compact ? 6 : 10),
            if (pdfGenerating)
              Row(
                children: [
                  SizedBox(
                    width: compact ? 14 : 16,
                    height: compact ? 14 : 16,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.ajouterTradeAnalysePdfGenerating,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: mutedStyle?.copyWith(
                        fontSize: statusSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            else if (hasPdf)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf_outlined,
                    size: compact ? 15 : 18,
                    color: DashboardTokens.titleGold.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l.ajouterTradeAnalysePdfAttached(pdfFileName!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: mutedStyle?.copyWith(
                        fontSize: statusSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onClear,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 4 : 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l.ajouterTradeAnalyseClear,
                      style: TextStyle(
                        color: DashboardTokens.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 10 : 11,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
