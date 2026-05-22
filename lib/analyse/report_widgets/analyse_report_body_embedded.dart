import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../performance/performance_locale_copy.dart';
import '../analyse_report_snapshot.dart';
import '../analyse_tokens.dart';
import 'analyse_report_oled_body.dart';

/// Corps du rapport OLED (remplace l’ancien empilement de cartes colorées par biais).
class AnalyseReportBody extends StatelessWidget {
  const AnalyseReportBody({
    super.key,
    required this.snapshot,
    this.topBar,
  });

  final AnalyseReportSnapshot snapshot;
  final Widget? topBar;

  @override
  Widget build(BuildContext context) {
    return AnalyseReportOledBody(
      snapshot: snapshot,
      topBar: topBar,
    );
  }
}

/// Bloc sous le bouton « Rapport » : titre, actions, rapport figé style générateur.
class AnalyseReportEmbeddedSection extends StatelessWidget {
  const AnalyseReportEmbeddedSection({
    super.key,
    required this.snapshot,
    required this.isDashboardStarred,
    required this.onToggleDashboardStar,
    required this.onEdit,
    required this.onExportPdf,
    required this.onDeleteReport,
  });

  final AnalyseReportSnapshot snapshot;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnalyseReportBody(
          snapshot: snapshot,
          topBar: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  txt('Rapport', 'Report', 'Informe', 'Bericht'),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: AnalyseTokens.oledSectionLabel.copyWith(
                    fontSize: 11,
                    color: AnalyseTokens.zinc300,
                  ),
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
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  isDashboardStarred ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isDashboardStarred ? _starActive : AnalyseTokens.zinc500,
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
                icon: const Icon(Icons.edit_outlined, color: AnalyseTokens.zinc500),
              ),
              IconButton(
                onPressed: onExportPdf,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                tooltip: txt('Exporter en PDF', 'Export as PDF', 'Exportar en PDF', 'Als PDF exportieren'),
                icon: const Icon(Icons.picture_as_pdf_outlined, color: AnalyseTokens.zinc500),
              ),
              IconButton(
                onPressed: onDeleteReport,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                tooltip: txt('Supprimer le rapport', 'Delete report', 'Eliminar informe', 'Bericht löschen'),
                icon: const Icon(Icons.delete_outline, color: AnalyseTokens.zinc500),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.viewPaddingOf(context).bottom + 16),
      ],
    );
  }
}
