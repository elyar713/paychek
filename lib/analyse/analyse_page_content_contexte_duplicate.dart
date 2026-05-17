import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_models.dart';
import 'analyse_page_content_contexte_options.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_contexte_draft_pill.dart';
import 'widgets/analyse_equal_chips_row.dart';

/// Copie dupliquÃ©e sous Contexte : mÃªme logique que la feuille (puces toujours sÃ©lectionnables ; crayon = ajout/retrait de pilules).
class AnalyseContexteDuplicateBlock extends StatefulWidget {
  const AnalyseContexteDuplicateBlock({
    super.key,
    required this.controller,
    required this.snapshotIndex,
    required this.indexLabel,
    required this.pillsEditMode,
    this.onRemoveDuplicate,
  });

  final AnalyseController controller;
  final int snapshotIndex;
  final int indexLabel;
  final bool pillsEditMode;
  /// Mode crayon : supprime ce bloc Â« Copie Â».
  final VoidCallback? onRemoveDuplicate;

  @override
  State<AnalyseContexteDuplicateBlock> createState() =>
      _AnalyseContexteDuplicateBlockState();
}

class _AnalyseContexteDuplicateBlockState
    extends State<AnalyseContexteDuplicateBlock> {
  bool _htfDraftOpen = false;
  bool _trendDraftOpen = false;
  bool _phaseDraftOpen = false;

  int get _i => widget.snapshotIndex;
  AnalyseController get _c => widget.controller;

  @override
  void didUpdateWidget(covariant AnalyseContexteDuplicateBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.pillsEditMode && oldWidget.pillsEditMode) {
      _htfDraftOpen = false;
      _trendDraftOpen = false;
      _phaseDraftOpen = false;
    }
  }

  Future<void> _openHtfAdd() async {
    if (_i >= _c.contexteSnapshots.length) return;
    final s = _c.contexteSnapshots[_i];
    final hidden = AnalyseTimeframe.values
        .where((e) => !s.htfVisibleEnums.contains(e))
        .toList();
    final visible = htfVisibleLabelSet(
      visibleEnums: AnalyseTimeframe.values
          .where((e) => s.htfVisibleEnums.contains(e)),
      customLabels: s.htfCustomLabels,
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
        _c.toggleContexteSnapshotHtfPill(_i, timeframe);
      case AnalyseHtfAddChoiceLabel(:final label):
        _c.addContexteSnapshotHtfCustomLabel(_i, label);
      case AnalyseHtfAddChoiceDraft():
        setState(() => _htfDraftOpen = true);
    }
  }

  void _openTrendAdd() {
    if (_i >= _c.contexteSnapshots.length) return;
    final s = _c.contexteSnapshots[_i];
    final hidden = AnalyseLocalTrend.values
        .where((e) => !s.trendVisibleEnums.contains(e))
        .toList();
    if (hidden.isEmpty) {
      setState(() => _trendDraftOpen = true);
      return;
    }
    if (hidden.length == 1) {
      _c.toggleContexteSnapshotTrendPill(_i, hidden.single);
      return;
    }
    _sheetPickHiddenTrend(hidden);
  }

  Future<void> _sheetPickHiddenTrend(List<AnalyseLocalTrend> hidden) async {
    final t = await showAnalyseContexteHiddenTrendSheet(context, hidden);
    if (!mounted || t == null) return;
    _c.toggleContexteSnapshotTrendPill(_i, t);
  }

  void _openPhaseAdd() {
    if (_i >= _c.contexteSnapshots.length) return;
    final s = _c.contexteSnapshots[_i];
    final hidden =
        AnalysePhase.values.where((e) => !s.phaseVisibleEnums.contains(e)).toList();
    if (hidden.isEmpty) {
      setState(() => _phaseDraftOpen = true);
      return;
    }
    if (hidden.length == 1) {
      _c.toggleContexteSnapshotPhasePill(_i, hidden.single);
      return;
    }
    _sheetPickHiddenPhase(hidden);
  }

  Future<void> _sheetPickHiddenPhase(List<AnalysePhase> hidden) async {
    final t = await showAnalyseContexteHiddenPhaseSheet(context, hidden);
    if (!mounted || t == null) return;
    _c.toggleContexteSnapshotPhasePill(_i, t);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (_i >= _c.contexteSnapshots.length) {
          return const SizedBox.shrink();
        }
        final snapshot = _c.contexteSnapshots[_i];
        final edit = widget.pillsEditMode;
        final l = AppLocalizations.of(context)!;

        Widget biasRow = AnalyseEqualChipsRow<AnalyseDirectionBias>(
          value: snapshot.bias,
          onChanged: (v) {
            if (v != null) _c.setContexteSnapshotBias(_i, v);
          },
          options: [
            AnalyseEqualChipOption(
              value: AnalyseDirectionBias.achat,
              label: l.analyseSideBuy,
              accent: AnalyseTokens.accentGreen,
            ),
            AnalyseEqualChipOption(
              value: AnalyseDirectionBias.vente,
              label: l.analyseSideSell,
              accent: AnalyseTokens.accentRed,
            ),
            AnalyseEqualChipOption(
              value: AnalyseDirectionBias.surveiller,
              label: l.analyseSideWatch,
              accent: AnalyseTokens.accentAmber,
            ),
          ],
        );

        Widget htfRow = AnalyseEqualChipsRow<ContextePick<AnalyseTimeframe>>(
          value: snapshot.htfPick,
          onChanged: (v) {
            if (v != null) _c.setContexteSnapshotHtfPick(_i, v);
          },
          options: snapshotHtfChipOptions(snapshot),
          pillEditing: edit,
          onRemoveOption: edit
              ? (pick) {
                  if (pick.isEnum) {
                    _c.toggleContexteSnapshotHtfPill(_i, pick.enumVal!);
                  } else {
                    _c.removeContexteSnapshotHtfCustomLabel(_i, pick.custom!);
                  }
                }
              : null,
          onAddOption: edit ? _openHtfAdd : null,
          pillEditingWrapSuffix: [
            if (edit && _htfDraftOpen)
              AnalyseContexteDraftPill(
                hint: l.analyseHintHtfChipExample,
                accent: AnalyseTokens.chipHtfSelected,
                onCommit: (raw) {
                  final t = raw.trim();
                  setState(() => _htfDraftOpen = false);
                  if (t.isEmpty) return;
                  _c.addContexteSnapshotHtfCustomLabel(_i, t);
                },
                onCancel: () => setState(() => _htfDraftOpen = false),
              ),
          ],
        );

        Widget trendRow =
            AnalyseEqualChipsRow<ContextePick<AnalyseLocalTrend>>(
          value: snapshot.trendPick,
          onChanged: (v) {
            if (v != null) _c.setContexteSnapshotTrendPick(_i, v);
          },
          options: snapshotTrendChipOptions(snapshot, l),
          pillEditing: edit,
          onRemoveOption: edit
              ? (pick) {
                  if (pick.isEnum) {
                    _c.toggleContexteSnapshotTrendPill(_i, pick.enumVal!);
                  } else {
                    _c.removeContexteSnapshotTrendCustomLabel(_i, pick.custom!);
                  }
                }
              : null,
          onAddOption: edit ? _openTrendAdd : null,
          pillEditingWrapSuffix: [
            if (edit && _trendDraftOpen)
              AnalyseContexteDraftPill(
                hint: l.analyseDraftLabelHint,
                accent: AnalyseTokens.accentAmber,
                onCommit: (raw) {
                  final t = raw.trim();
                  setState(() => _trendDraftOpen = false);
                  if (t.isEmpty) return;
                  _c.addContexteSnapshotTrendCustomLabel(_i, t);
                },
                onCancel: () => setState(() => _trendDraftOpen = false),
              ),
          ],
        );

        Widget phaseRow = AnalyseEqualChipsRow<ContextePick<AnalysePhase>>(
          value: snapshot.phasePick,
          onChanged: (v) {
            if (v != null) _c.setContexteSnapshotPhasePick(_i, v);
          },
          options: snapshotPhaseChipOptions(
            snapshot,
            Localizations.localeOf(context),
          ),
          pillEditing: edit,
          onRemoveOption: edit
              ? (pick) {
                  if (pick.isEnum) {
                    _c.toggleContexteSnapshotPhasePill(_i, pick.enumVal!);
                  } else {
                    _c.removeContexteSnapshotPhaseCustomLabel(_i, pick.custom!);
                  }
                }
              : null,
          onAddOption: edit ? _openPhaseAdd : null,
          pillEditingWrapSuffix: [
            if (edit && _phaseDraftOpen)
              AnalyseContexteDraftPill(
                hint: l.analyseDraftLabelHint,
                accent: AnalyseTokens.chipPhaseSelected,
                onCommit: (raw) {
                  final t = raw.trim();
                  setState(() => _phaseDraftOpen = false);
                  if (t.isEmpty) return;
                  _c.addContexteSnapshotPhaseCustomLabel(_i, t);
                },
                onCancel: () => setState(() => _phaseDraftOpen = false),
              ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AnalyseTokens.contexteDuplicateBg,
            borderRadius: BorderRadius.circular(AnalyseTokens.radiusField),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      l.analyseCopyLabel('${widget.indexLabel}'),
                      style: AnalyseTokens.inlineMutedStyle,
                    ),
                  ),
                  if (widget.onRemoveDuplicate != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onRemoveDuplicate,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: AnalyseTokens.muted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                l.analyseDirectionLabel,
                style: AnalyseTokens.labelStyle,
              ),
              const SizedBox(height: 10),
              biasRow,
              const SizedBox(height: 14),
              Text(l.analyseHtfTimeframe, style: AnalyseTokens.labelStyle),
              const SizedBox(height: 10),
              htfRow,
              const SizedBox(height: 14),
              Text(l.analyseCurrentTrend, style: AnalyseTokens.labelStyle),
              const SizedBox(height: 10),
              trendRow,
              const SizedBox(height: 14),
              Text(
                l.analyseCurrentMarketPhase,
                style: AnalyseTokens.labelStyle,
              ),
              const SizedBox(height: 10),
              phaseRow,
            ],
          ),
        );
      },
    );
  }
}



