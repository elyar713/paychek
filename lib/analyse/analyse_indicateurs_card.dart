import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_indicateurs_expanded_section.dart';
import 'analyse_page_widgets.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_card.dart';
import 'widgets/analyse_collapsible_section_body.dart';
import 'widgets/analyse_section_title_row.dart';

/// Carte Â« Indicateurs Â».
class AnalyseIndicateursCard extends StatefulWidget {
  const AnalyseIndicateursCard({
    super.key,
    required this.controller,
  });

  final AnalyseController controller;

  @override
  State<AnalyseIndicateursCard> createState() => _AnalyseIndicateursCardState();
}

class _AnalyseIndicateursCardState extends State<AnalyseIndicateursCard>
    with WidgetsBindingObserver {
  final TextEditingController _newIndicatorDraft = TextEditingController();
  final FocusNode _indicatorDraftFocus = FocusNode();

  bool _indicatorDraftOpen = false;
  bool _indicatorsEditMode = false;
  double _lastViewInsetBottom = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _indicatorDraftFocus.addListener(_onIndicatorDraftFocusChanged);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bottom = MediaQuery.viewInsetsOf(context).bottom;
      if (_indicatorDraftOpen &&
          _lastViewInsetBottom > 0 &&
          bottom == 0) {
        _indicatorDraftFocus.unfocus();
      }
      _lastViewInsetBottom = bottom;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _indicatorDraftFocus.removeListener(_onIndicatorDraftFocusChanged);
    _indicatorDraftFocus.dispose();
    _newIndicatorDraft.dispose();
    super.dispose();
  }

  void _onIndicatorDraftFocusChanged() {
    if (_indicatorDraftFocus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_indicatorDraftFocus.hasFocus) return;
      if (!_indicatorDraftOpen) return;
      _finishDraftFromOutsideDismiss();
    });
  }

  void _finishDraftFromOutsideDismiss() {
    if (!_indicatorDraftOpen) return;
    final t = _newIndicatorDraft.text.trim();
    _indicatorDraftOpen = false;
    if (t.isNotEmpty) {
      widget.controller.addCustomIndicator(t);
    }
    _newIndicatorDraft.clear();
    if (mounted) setState(() {});
  }

  void _openIndicatorDraft() {
    _lastViewInsetBottom = MediaQuery.viewInsetsOf(context).bottom;
    setState(() => _indicatorDraftOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _indicatorDraftFocus.requestFocus();
      }
    });
  }

  void _onAddButtonTap() {
    if (!_indicatorDraftOpen) {
      _openIndicatorDraft();
      return;
    }
    final t = _newIndicatorDraft.text.trim();
    if (t.isEmpty) {
      _indicatorDraftOpen = false;
      _newIndicatorDraft.clear();
      if (mounted) setState(() {});
      _indicatorDraftFocus.unfocus();
      return;
    }
    _indicatorDraftOpen = false;
    widget.controller.addCustomIndicator(t);
    _newIndicatorDraft.clear();
    if (mounted) setState(() {});
    _indicatorDraftFocus.unfocus();
  }

  void _onDraftSubmitted() {
    final t = _newIndicatorDraft.text.trim();
    if (t.isEmpty) {
      _indicatorDraftFocus.unfocus();
      return;
    }
    _indicatorDraftOpen = false;
    widget.controller.addCustomIndicator(t);
    _newIndicatorDraft.clear();
    if (mounted) setState(() {});
    _indicatorDraftFocus.unfocus();
  }

  void _toggleIndicatorsEditMode() {
    setState(() => _indicatorsEditMode = !_indicatorsEditMode);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = widget.controller;
    final body = ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnalyseSectionTitleRow(
                title: l.analyseCardIndicators,
                icon: Icons.monitor_heart_outlined,
                iconColor: AnalyseEditorSection.indicateurs.sectionAccent,
                enabled: c.indicatorsEnabled,
                onEnabledChanged: (v) => c.indicatorsEnabled = v,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnalyseSquareIconButton(
                      icon: Icons.copy_all_outlined,
                      onTap: c.duplicateIndicators,
                    ),
                    const SizedBox(width: 8),
                    AnalyseSquareIconButton(
                      icon: Icons.edit_outlined,
                      iconColor: _indicatorsEditMode
                          ? AnalyseTokens.accentGreen
                          : const Color(0xFF9A9A9A),
                      onTap: _toggleIndicatorsEditMode,
                    ),
                  ],
                ),
              ),
            AnalyseCollapsibleSectionBody(
              expanded: c.indicatorsEnabled,
              child: AnalyseIndicateursExpandedSection(
                controller: c,
                indicatorsEditMode: _indicatorsEditMode,
                indicatorDraftOpen: _indicatorDraftOpen,
                newIndicatorDraft: _newIndicatorDraft,
                indicatorDraftFocus: _indicatorDraftFocus,
                onFinishDraftFromOutsideDismiss:
                    _finishDraftFromOutsideDismiss,
                onAddButtonTap: _onAddButtonTap,
                onDraftSubmitted: _onDraftSubmitted,
              ),
            ),
          ],
        );
      },
    );
    return AnalyseCard(
      editorSection: AnalyseEditorSection.indicateurs,
      child: body,
    );
  }
}



