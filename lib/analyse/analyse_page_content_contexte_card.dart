import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_models.dart';
import 'analyse_page_content_contexte_options.dart';
import 'analyse_feuille_contexte_card_body.dart';
import 'analyse_feuille_contexte_date_overlay.dart';
import 'analyse_feuille_contexte_template_dialogs.dart';
import 'analyse_feuille_contexte_template_overlay.dart';
import 'analyse_firestore_sync.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_card.dart';

/// Carte Â« Feuille de plan Â» + Tendance (puces, copies, note, confiance feuille).
class AnalyseFeuilleContexteCard extends StatefulWidget {
  const AnalyseFeuilleContexteCard({
    super.key,
    required this.controller,
  });

  final AnalyseController controller;

  @override
  State<AnalyseFeuilleContexteCard> createState() =>
      _AnalyseFeuilleContexteCardState();
}

class _AnalyseFeuilleContexteCardState extends State<AnalyseFeuilleContexteCard> {
  bool _pillsEditMode = false;
  bool _htfDraftOpen = false;
  bool _trendDraftOpen = false;
  bool _phaseDraftOpen = false;

  final LayerLink _contexteDateLayerLink = LayerLink();
  OverlayEntry? _contexteDateOverlay;
  final GlobalKey _templateMenuAnchorKey = GlobalKey();
  OverlayEntry? _templateModelsOverlay;
  /// Annule une ouverture planifiÃ©e si lâ€™utilisateur retape le chevron avant la frame.
  Object? _templateMenuOpenScheduleToken;

  AnalyseController get _c => widget.controller;

  @override
  void deactivate() {
    _hideContexteDateOverlay();
    _hideTemplateModelsOverlay();
    super.deactivate();
  }

  @override
  void dispose() {
    _hideContexteDateOverlay();
    _hideTemplateModelsOverlay();
    super.dispose();
  }

  /// Retrait diffÃ©rÃ© : Ã©vite [OverlayEntry.remove] pendant un layout verrouillÃ©
  /// (hot reload, warm-up frame â†’ `_debugMutationsLocked`).
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
      controller: _c,
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

  void _hideTemplateModelsOverlay() {
    final entry = _templateModelsOverlay;
    if (entry == null) return;
    _templateModelsOverlay = null;
    try {
      entry.remove();
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          entry.remove();
        } catch (_) {}
      });
    }
  }

  void _openTemplateNameMenu() {
    if (_templateModelsOverlay != null) {
      _hideTemplateModelsOverlay();
      _templateMenuOpenScheduleToken = null;
      return;
    }
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    if (_templateMenuOpenScheduleToken != null) {
      _templateMenuOpenScheduleToken = null;
      return;
    }

    final token = Object();
    _templateMenuOpenScheduleToken = token;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _templateMenuOpenScheduleToken != token) return;
      _templateMenuOpenScheduleToken = null;
      if (_templateModelsOverlay != null) return;

      final box = _templateMenuAnchorKey.currentContext?.findRenderObject()
          as RenderBox?;
      if (box == null || !box.hasSize) return;

      const panelW = 136.0;
      final topLeft = box.localToGlobal(Offset.zero);
      final sz = box.size;
      final mq = MediaQuery.of(context);
      final maxLeft = mq.size.width - panelW - 8.0;
      final left = (topLeft.dx + sz.width - panelW).clamp(8.0, maxLeft);
      final top = topLeft.dy + sz.height + 4.0;
      final panelTopLeft = Offset(left.toDouble(), top);

      final entry = buildFeuilleContexteTemplateModelsOverlayEntry(
        hostContext: context,
        panelTopLeft: panelTopLeft,
        controller: _c,
        onDismiss: _hideTemplateModelsOverlay,
        isMounted: () => mounted,
      );
      _templateModelsOverlay = entry;
      try {
        overlayState.insert(entry);
      } catch (_) {}
    });
  }

  void _togglePillsEditMode() {
    setState(() {
      _pillsEditMode = !_pillsEditMode;
      if (!_pillsEditMode) {
        _htfDraftOpen = false;
        _trendDraftOpen = false;
        _phaseDraftOpen = false;
      }
    });
  }

  Future<void> _onSaveTemplateWithNamePrompt() async {
    final name = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => const SaveFeuilleContexteTemplateNameDialog(),
    );
    if (name == null || name.isEmpty || !mounted) return;
    await _c.saveFeuilleContextePillsTemplateNamed(name);
    AnalyseFirestoreSync.pushIfSignedIn();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.modelSavedSnackbar(name))),
    );
  }

  Future<void> _openHtfAdd() async {
    final hidden =
        AnalyseTimeframe.values.where((e) => !_c.isHtfPillVisible(e)).toList();
    final visible = htfVisibleLabelSet(
      visibleEnums: _c.htfPillsVisibleOrdered,
      customLabels: _c.htfCustomLabels,
    );
    if (hidden.isEmpty && htfExtraPresetsNotVisible(visible).isEmpty) {
      setState(() => _htfDraftOpen = true);
      return;
    }
    final choice = await showAnalyseContexteAddHtfSheet(
      context,
      hiddenEnums: hidden,
      visibleLabels: visible,
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case AnalyseHtfAddChoiceEnum(:final timeframe):
        _c.toggleHtfPill(timeframe);
      case AnalyseHtfAddChoiceLabel(:final label):
        _c.addHtfCustomLabel(label);
      case AnalyseHtfAddChoiceDraft():
        setState(() => _htfDraftOpen = true);
    }
  }

  void _openTrendAdd() {
    final hidden = AnalyseLocalTrend.values
        .where((e) => !_c.isTrendPillVisible(e))
        .toList();
    if (hidden.isEmpty) {
      setState(() => _trendDraftOpen = true);
      return;
    }
    if (hidden.length == 1) {
      _c.toggleTrendPill(hidden.single);
      return;
    }
    _sheetPickHiddenTrend(hidden);
  }

  Future<void> _sheetPickHiddenTrend(List<AnalyseLocalTrend> hidden) async {
    final t = await showAnalyseContexteHiddenTrendSheet(context, hidden);
    if (!mounted || t == null) return;
    _c.toggleTrendPill(t);
  }

  void _openPhaseAdd() {
    final hidden =
        AnalysePhase.values.where((e) => !_c.isPhasePillVisible(e)).toList();
    if (hidden.isEmpty) {
      setState(() => _phaseDraftOpen = true);
      return;
    }
    if (hidden.length == 1) {
      _c.togglePhasePill(hidden.single);
      return;
    }
    _sheetPickHiddenPhase(hidden);
  }

  Future<void> _sheetPickHiddenPhase(List<AnalysePhase> hidden) async {
    final t = await showAnalyseContexteHiddenPhaseSheet(context, hidden);
    if (!mounted || t == null) return;
    _c.togglePhasePill(t);
  }

  void _onHtfDraftCommit(String raw) {
    final t = raw.trim();
    setState(() => _htfDraftOpen = false);
    if (t.isEmpty) return;
    _c.addHtfCustomLabel(t);
  }

  void _onTrendDraftCommit(String raw) {
    final t = raw.trim();
    setState(() => _trendDraftOpen = false);
    if (t.isEmpty) return;
    _c.addTrendCustomLabel(t);
  }

  void _onPhaseDraftCommit(String raw) {
    final t = raw.trim();
    setState(() => _phaseDraftOpen = false);
    if (t.isEmpty) return;
    _c.addPhaseCustomLabel(t);
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final body = ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        return AnalyseFeuilleContexteCardBody(
          controller: c,
          pillsEditMode: _pillsEditMode,
            htfDraftOpen: _htfDraftOpen,
            trendDraftOpen: _trendDraftOpen,
            phaseDraftOpen: _phaseDraftOpen,
            contexteDateLayerLink: _contexteDateLayerLink,
            templateMenuAnchorKey: _templateMenuAnchorKey,
            onTapContexteDate: () => _toggleContexteDateOverlay(context),
            onTapTemplateMenu: _openTemplateNameMenu,
            onSaveTemplate: _onSaveTemplateWithNamePrompt,
            onTogglePillsEdit: _togglePillsEditMode,
            onOpenHtfAdd: _openHtfAdd,
            onOpenTrendAdd: _openTrendAdd,
            onOpenPhaseAdd: _openPhaseAdd,
            onHtfDraftCommit: _onHtfDraftCommit,
            onHtfDraftCancel: () => setState(() => _htfDraftOpen = false),
            onTrendDraftCommit: _onTrendDraftCommit,
            onTrendDraftCancel: () => setState(() => _trendDraftOpen = false),
            onPhaseDraftCommit: _onPhaseDraftCommit,
            onPhaseDraftCancel: () => setState(() => _phaseDraftOpen = false),
        );
      },
    );
    return AnalyseCard(
      editorSection: AnalyseEditorSection.feuillePlan,
      child: body,
    );
  }
}



