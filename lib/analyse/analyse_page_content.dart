import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'analyse_controller.dart';
import 'analyse_indicateurs_card.dart';
import 'analyse_page_content_contexte_card.dart';
import 'analyse_page_content_structure.dart';
import 'analyse_page_sidebar.dart';
import 'analyse_smc_card.dart';
import 'analyse_tokens.dart';
import 'analyse_valider_analyse_footer.dart';
import 'analyse_volume_profil_card.dart';
import 'analyse_report_snapshot.dart';
import 'analyse_report_screenshot_section.dart';
import 'analyse_report_widgets.dart';

/// Un rapport validé dans la liste défilante (snapshot + capture PDF + clé d’embed).
@immutable
class AnalyseStackedReportEntry {
  const AnalyseStackedReportEntry({
    required this.snapshot,
    required this.embedKey,
    this.screenshotBytes,
  });

  final AnalyseReportSnapshot snapshot;
  final int embedKey;
  final Uint8List? screenshotBytes;
}

/// Corps défilant : grille tableau de bord + screenshot + rapports.
class AnalysePageScrollContent extends StatefulWidget {
  const AnalysePageScrollContent({
    super.key,
    required this.controller,
    required this.strategieVisibleSetupIndex,
    this.reportEntries = const [],
    this.initialScrollToReports = false,
    this.scrollTargetReportIndex = 0,
    required this.onReportValidated,
    required this.onEditReport,
    required this.onExportPdf,
    required this.onDeleteReport,
    required this.reportStarred,
    required this.onToggleReportStar,
  });

  final AnalyseController controller;
  final ValueNotifier<int> strategieVisibleSetupIndex;
  final List<AnalyseStackedReportEntry> reportEntries;
  final bool initialScrollToReports;

  /// Bloc rapport à faire défiler en vue (depuis l’aperçu accueil).
  final int scrollTargetReportIndex;
  final ValueChanged<AnalyseReportSnapshot> onReportValidated;
  final void Function(int index) onEditReport;
  final void Function(int index) onExportPdf;
  final void Function(int index) onDeleteReport;
  final bool Function(int index) reportStarred;
  final void Function(int index) onToggleReportStar;

  @override
  State<AnalysePageScrollContent> createState() =>
      _AnalysePageScrollContentState();
}

class _AnalysePageScrollContentState extends State<AnalysePageScrollContent> {
  final GlobalKey _firstReportKey = GlobalKey();
  bool _didScrollToReports = false;

  @override
  void initState() {
    super.initState();
    _scheduleScrollToReportsIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AnalysePageScrollContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.initialScrollToReports) {
      _didScrollToReports = false;
      return;
    }
    if (oldWidget.scrollTargetReportIndex != widget.scrollTargetReportIndex) {
      _didScrollToReports = false;
    }
    if (oldWidget.reportEntries.isEmpty && widget.reportEntries.isNotEmpty) {
      _didScrollToReports = false;
    }
    if (widget.initialScrollToReports && widget.reportEntries.isNotEmpty) {
      _scheduleScrollToReportsIfNeeded();
    }
  }

  void _scheduleScrollToReportsIfNeeded() {
    if (!widget.initialScrollToReports || widget.reportEntries.isEmpty) return;
    if (_didScrollToReports) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final ctx = _firstReportKey.currentContext;
        if (ctx == null) return;
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.06,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
        _didScrollToReports = true;
      });
    });
  }

  void _onValidated(AnalyseReportSnapshot s) {
    widget.onReportValidated(s);
    widget.controller.resetAfterReportValidation();
  }

  Widget _analysisDraftScreenshotSection() {
    final c = widget.controller;
    return AnalyseReportScreenshotSection(
      bytes: c.draftReportScreenshotBytes,
      onBytesChanged: c.setDraftReportScreenshot,
    );
  }

  Widget _editors(bool wide) {
    final c = widget.controller;
    if (wide) {
      // Deux colonnes indépendantes : évite le vide sous « Indicateurs » quand
      // « Structure » est plus haute (ancienne grille 2×2 alignée en haut).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnalyseFeuilleContexteCard(controller: c),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnalyseStructureCard(controller: c),
                    const SizedBox(height: 18),
                    AnalyseSmcCard(controller: c),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnalyseIndicateursCard(controller: c),
                    const SizedBox(height: 18),
                    AnalyseVolumeProfilCard(controller: c),
                    const SizedBox(height: 14),
                    _analysisDraftScreenshotSection(),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnalyseFeuilleContexteCard(controller: c),
        const SizedBox(height: 14),
        AnalyseStructureCard(controller: c),
        const SizedBox(height: 14),
        AnalyseIndicateursCard(controller: c),
        const SizedBox(height: 14),
        AnalyseSmcCard(controller: c),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 340),
          child: AnalyseVolumeProfilCard(controller: c),
        ),
        const SizedBox(height: 14),
        _analysisDraftScreenshotSection(),
      ],
    );
  }

  List<Widget> _reportBlocks(int targetIdx) {
    return [
      for (final entry in widget.reportEntries.asMap().entries) ...[
        SizedBox(height: entry.key == 0 ? 20 : 24),
        AnalyseReportEmbeddedSection(
          key: entry.key == targetIdx
              ? _firstReportKey
              : ValueKey(entry.value.embedKey),
          snapshot: entry.value.snapshot,
          screenshotBytes: entry.value.screenshotBytes,
          isDashboardStarred: widget.reportStarred(entry.key),
          onToggleDashboardStar: () => widget.onToggleReportStar(entry.key),
          onEdit: () => widget.onEditReport(entry.key),
          onExportPdf: () => widget.onExportPdf(entry.key),
          onDeleteReport: () => widget.onDeleteReport(entry.key),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final targetIdx = widget.reportEntries.isEmpty
        ? 0
        : widget.scrollTargetReportIndex
            .clamp(0, widget.reportEntries.length - 1);

    return LayoutBuilder(
      builder: (context, lc) {
        final wide =
            lc.maxWidth >= AnalyseTokens.layoutBreakpointWide;
        final editors = _editors(wide);
        final reports = _reportBlocks(targetIdx);

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                  children: [
                    editors,
                    ...reports,
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 300,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 32),
                  children: [
                    AnalysePageEditorSidebar(
                      controller: widget.controller,
                      onGenerateReport: _onValidated,
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          children: [
            editors,
            AnalyseValiderAnalyseFooter(
              controller: widget.controller,
              onValidated: _onValidated,
            ),
            ...reports,
          ],
        );
      },
    );
  }
}
