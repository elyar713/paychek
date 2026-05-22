import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'analyse_controller.dart';
import 'analyse_feuille_contexte_date_overlay.dart';
import 'analyse_oled_plan_ui.dart';
import 'analyse_report_snapshot.dart';
import 'analyse_report_widgets.dart';
import 'analyse_tokens.dart';

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

/// Corps défilant : maquette OLED (métadonnées + workflow 3 colonnes + rapports).
class AnalysePageScrollContent extends StatefulWidget {
  const AnalysePageScrollContent({
    super.key,
    required this.controller,
    this.generatorContentEpoch = 0,
    this.editingReportIndex,
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
    this.showSaveBanner = false,
    this.onDismissSaveBanner,
  });

  final AnalyseController controller;
  final int generatorContentEpoch;
  final int? editingReportIndex;
  final ValueNotifier<int> strategieVisibleSetupIndex;
  final List<AnalyseStackedReportEntry> reportEntries;
  final bool initialScrollToReports;
  final int scrollTargetReportIndex;
  final ValueChanged<AnalyseReportSnapshot> onReportValidated;
  final void Function(int index) onEditReport;
  final void Function(int index) onExportPdf;
  final void Function(int index) onDeleteReport;
  final bool Function(int index) reportStarred;
  final void Function(int index) onToggleReportStar;
  final bool showSaveBanner;
  final VoidCallback? onDismissSaveBanner;

  @override
  State<AnalysePageScrollContent> createState() =>
      _AnalysePageScrollContentState();
}

class _AnalysePageScrollContentState extends State<AnalysePageScrollContent> {
  final GlobalKey _firstReportKey = GlobalKey();
  bool _didScrollToReports = false;

  final LayerLink _contexteDateLayerLink = LayerLink();
  OverlayEntry? _contexteDateOverlay;

  @override
  void deactivate() {
    _hideContexteDateOverlay();
    super.deactivate();
  }

  @override
  void dispose() {
    _hideContexteDateOverlay();
    super.dispose();
  }

  void _hideContexteDateOverlay() {
    final entry = _contexteDateOverlay;
    if (entry == null) return;
    _contexteDateOverlay = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        entry.remove();
      } catch (_) {}
    });
  }

  void _toggleContexteDateOverlay(BuildContext context) {
    if (_contexteDateOverlay != null) {
      _hideContexteDateOverlay();
      return;
    }
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    final entry = buildFeuilleContexteDatePickerOverlayEntry(
      layerLink: _contexteDateLayerLink,
      controller: widget.controller,
      onDismiss: _hideContexteDateOverlay,
    );
    _contexteDateOverlay = entry;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _contexteDateOverlay != entry) return;
      try {
        overlayState.insert(entry);
      } catch (_) {}
    });
  }

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

  bool get _hasVisibleReports => widget.reportEntries
      .asMap()
      .entries
      .any((e) => e.key != widget.editingReportIndex);

  List<Widget> _reportBlocks(int targetIdx, {required bool narrow}) {
    return [
      for (final entry in widget.reportEntries.asMap().entries)
        if (entry.key != widget.editingReportIndex) ...[
        SizedBox(height: entry.key == 0 ? (narrow ? 0 : 32) : 24),
        AnalyseReportEmbeddedSection(
          key: entry.key == targetIdx
              ? _firstReportKey
              : ValueKey(entry.value.embedKey),
          snapshot: entry.value.snapshot,
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
            lc.maxWidth >= AnalyseTokens.pageLayoutWideBreakpoint;

        return ListView(
          padding: AnalyseTokens.pageScrollPadding(wide: wide),
          children: [
            if (widget.showSaveBanner)
              AnalyseOledSaveBanner(
                onDismiss: widget.onDismissSaveBanner ?? () {},
              ),
            SizedBox(height: widget.showSaveBanner ? 8 : 24),
            AnalyseOledMetadataSection(
              key: ValueKey('meta-${widget.generatorContentEpoch}'),
              controller: widget.controller,
              contexteDateLayerLink: _contexteDateLayerLink,
              onTapDate: () => _toggleContexteDateOverlay(context),
            ),
            SizedBox(height: wide ? 24 : 16),
            AnalyseOledPlanGrid(
              key: ValueKey('plan-${widget.generatorContentEpoch}'),
              controller: widget.controller,
              wide: wide,
            ),
            if (!wide && _hasVisibleReports) ...[
              const SizedBox(height: 24),
              const Divider(
                height: 1,
                thickness: 1,
                color: AnalyseTokens.cardBorder,
              ),
              const SizedBox(height: 20),
            ] else
              const SizedBox(height: 32),
            ..._reportBlocks(targetIdx, narrow: !wide),
          ],
        );
      },
    );
  }
}
