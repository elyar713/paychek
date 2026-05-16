import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../performance/performance_locale_copy.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
import 'analyse_report_card_contexte_structure.dart';
import 'analyse_report_card_indicators.dart';
import 'analyse_report_card_smc.dart';
import 'analyse_report_card_volume.dart';
import 'analyse_report_header.dart';

/// En-tête + cartes du rapport (défilant ou page dédiée).
class AnalyseReportBody extends StatelessWidget {
  const AnalyseReportBody({super.key, required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final s = snapshot;
    final cards = <Widget>[
      if (s.gaugeContextEnabled || s.gaugeStructureEnabled)
        AnalyseReportContexteStructureCard(snapshot: s),
      if (s.gaugeIndicatorsEnabled) AnalyseReportIndicateursCard(snapshot: s),
      if (s.gaugeSmcEnabled) AnalyseReportSmcCard(snapshot: s),
      if (s.gaugeVolumeProfileEnabled) AnalyseReportVolumeCard(snapshot: s),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnalyseReportHeader(snapshot: s),
        const SizedBox(height: 20),
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          cards[i],
        ],
      ],
    );
  }
}

/// Bloc sous le bouton « Rapport » : titre, icône modifier, contenu figé.
class AnalyseReportEmbeddedSection extends StatelessWidget {
  const AnalyseReportEmbeddedSection({
    super.key,
    required this.snapshot,
    this.screenshotBytes,
    required this.isDashboardStarred,
    required this.onToggleDashboardStar,
    required this.onEdit,
    required this.onExportPdf,
    required this.onDeleteReport,
  });

  final AnalyseReportSnapshot snapshot;

  /// Capture figée lors de la validation (même source que le PDF).
  final Uint8List? screenshotBytes;
  final bool isDashboardStarred;
  final VoidCallback onToggleDashboardStar;
  final VoidCallback onEdit;
  final VoidCallback onExportPdf;
  final VoidCallback onDeleteReport;

  static const Color _starActive = Color(0xFFE6C35C);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final code = l.localeName.toLowerCase();
    String txt(String fr, String en, String es, String de) => performancePickLang(code, fr, en, es, de);
    return DecoratedBox(
      decoration: AnalyseTokens.reportPanelDecorationForBiasLabel(
        snapshot.biasLabel,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    txt('Rapport', 'Report', 'Informe', 'Bericht'),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: AnalyseTokens.sectionTitleStyle.copyWith(fontSize: 15),
                  ),
                ),
                IconButton(
                  onPressed: onToggleDashboardStar,
                  tooltip: isDashboardStarred
                      ? txt('Retirer de l’accueil', 'Remove from dashboard', 'Quitar del inicio', 'Vom Dashboard entfernen')
                      : txt('Afficher sur l’accueil', 'Show on dashboard', 'Mostrar en inicio', 'Auf dem Dashboard anzeigen'),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: Icon(
                    isDashboardStarred
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: isDashboardStarred
                        ? _starActive
                        : const Color(0xFF9A9A9A),
                    size: 22,
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  tooltip: txt(
                    'Modifier — recharger la feuille depuis ce rapport',
                    'Edit — reload the sheet from this report',
                    'Editar — recargar la hoja desde este informe',
                    'Bearbeiten — Blatt aus diesem Bericht neu laden',
                  ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF9A9A9A),
                  ),
                ),
                IconButton(
                  onPressed: onExportPdf,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  tooltip: txt('Exporter en PDF', 'Export as PDF', 'Exportar en PDF', 'Als PDF exportieren'),
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: Color(0xFF9A9A9A),
                  ),
                ),
                IconButton(
                  onPressed: onDeleteReport,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  tooltip: txt('Supprimer le rapport', 'Delete report', 'Eliminar informe', 'Bericht löschen'),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnalyseReportBody(snapshot: snapshot),
            if (screenshotBytes != null &&
                screenshotBytes!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                l.analyseReportScreenshotSectionTitle,
                style:
                    AnalyseTokens.sectionTitleStyle.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 280),
                  color: AnalyseTokens.fieldBg,
                  child: Image.memory(
                    screenshotBytes!,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ],
            SizedBox(height: MediaQuery.viewPaddingOf(context).bottom + 16),
          ],
        ),
      ),
    );
  }
}
