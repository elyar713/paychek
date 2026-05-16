import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_page_widgets.dart';
import 'analyse_smc_expanded_body.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_card.dart';
import 'widgets/analyse_collapsible_section_body.dart';
import 'widgets/analyse_section_title_row.dart';

/// Carte Â« SMC & LiquiditÃ© Â».
class AnalyseSmcCard extends StatefulWidget {
  const AnalyseSmcCard({
    super.key,
    required this.controller,
  });

  final AnalyseController controller;

  @override
  State<AnalyseSmcCard> createState() => _AnalyseSmcCardState();
}

class _AnalyseSmcCardState extends State<AnalyseSmcCard>
    with WidgetsBindingObserver {
  bool _smcEditMode = false;

  final TextEditingController _smcDraftCtrl = TextEditingController();
  final FocusNode _smcDraftFocus = FocusNode();
  bool _smcDraftOpen = false;
  double _lastViewInsetBottom = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _smcDraftFocus.addListener(_onSmcDraftFocusChanged);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bottom = MediaQuery.viewInsetsOf(context).bottom;
      if (_smcDraftOpen && _lastViewInsetBottom > 0 && bottom == 0) {
        _smcDraftFocus.unfocus();
      }
      _lastViewInsetBottom = bottom;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _smcDraftFocus.removeListener(_onSmcDraftFocusChanged);
    _smcDraftFocus.dispose();
    _smcDraftCtrl.dispose();
    super.dispose();
  }

  void _onSmcDraftFocusChanged() {
    if (_smcDraftFocus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_smcDraftFocus.hasFocus) return;
      if (!_smcDraftOpen) return;
      _finishSmcDraftFromOutsideDismiss();
    });
  }

  void _finishSmcDraftFromOutsideDismiss() {
    if (!_smcDraftOpen) return;
    final t = _smcDraftCtrl.text.trim();
    _smcDraftOpen = false;
    if (t.isNotEmpty) {
      widget.controller.addSmcExtraLine(t);
    }
    _smcDraftCtrl.clear();
    if (mounted) setState(() {});
  }

  void _openSmcDraft() {
    _lastViewInsetBottom = MediaQuery.viewInsetsOf(context).bottom;
    setState(() => _smcDraftOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _smcDraftFocus.requestFocus();
    });
  }

  void _onSmcAjouterTap() {
    if (!_smcDraftOpen) {
      _openSmcDraft();
      return;
    }
    final t = _smcDraftCtrl.text.trim();
    if (t.isEmpty) {
      _smcDraftOpen = false;
      _smcDraftCtrl.clear();
      if (mounted) setState(() {});
      _smcDraftFocus.unfocus();
      return;
    }
    _smcDraftOpen = false;
    widget.controller.addSmcExtraLine(t);
    _smcDraftCtrl.clear();
    if (mounted) setState(() {});
    _smcDraftFocus.unfocus();
  }

  void _onSmcDraftSubmitted() {
    final t = _smcDraftCtrl.text.trim();
    if (t.isEmpty) {
      _smcDraftFocus.unfocus();
      return;
    }
    _smcDraftOpen = false;
    widget.controller.addSmcExtraLine(t);
    _smcDraftCtrl.clear();
    if (mounted) setState(() {});
    _smcDraftFocus.unfocus();
  }

  void _toggleSmcEditMode() {
    setState(() => _smcEditMode = !_smcEditMode);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = widget.controller;
    return AnalyseCard(
      editorSection: AnalyseEditorSection.smcLiquidite,
      child: ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnalyseSectionTitleRow(
                title: l.analyseCardSmcLiquidity,
                icon: Icons.blur_on_outlined,
                iconColor: AnalyseEditorSection.smcLiquidite.sectionAccent,
                enabled: c.smcEnabled,
                onEnabledChanged: (v) => c.smcEnabled = v,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnalyseSquareIconButton(
                      icon: Icons.copy_all_outlined,
                      onTap: c.duplicateSmc,
                    ),
                    const SizedBox(width: 8),
                    AnalyseSquareIconButton(
                      icon: Icons.edit_outlined,
                      iconColor: _smcEditMode
                          ? AnalyseTokens.accentGreen
                          : const Color(0xFF9A9A9A),
                      onTap: _toggleSmcEditMode,
                    ),
                  ],
                ),
              ),
              AnalyseCollapsibleSectionBody(
                expanded: c.smcEnabled,
                child: AnalyseSmcExpandedBody(
                  controller: c,
                  smcEditMode: _smcEditMode,
                  smcDraftOpen: _smcDraftOpen,
                  smcDraftCtrl: _smcDraftCtrl,
                  smcDraftFocus: _smcDraftFocus,
                  onSmcAjouterTap: _onSmcAjouterTap,
                  onSmcDraftSubmitted: _onSmcDraftSubmitted,
                  onFinishSmcDraftFromOutsideDismiss:
                      _finishSmcDraftFromOutsideDismiss,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



