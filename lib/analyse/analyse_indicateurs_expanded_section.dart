import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_impact_modal.dart';
import 'analyse_indicator_draft_pill_row.dart';
import 'analyse_indicators_duplicate_block.dart';
import 'analyse_page_widgets.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_confidence_slider.dart';
import 'widgets/analyse_dashed_button.dart';
import 'widgets/analyse_inline_pill_and_add_row.dart';
import 'widgets/analyse_text_field.dart';
import 'widgets/analyse_structure_tf_picker.dart';

/// Contenu dÃ©pliÃ© de la carte Indicateurs (hors titre / collapse).
class AnalyseIndicateursExpandedSection extends StatelessWidget {
  const AnalyseIndicateursExpandedSection({
    super.key,
    required this.controller,
    required this.indicatorsEditMode,
    required this.indicatorDraftOpen,
    required this.newIndicatorDraft,
    required this.indicatorDraftFocus,
    required this.onFinishDraftFromOutsideDismiss,
    required this.onAddButtonTap,
    required this.onDraftSubmitted,
  });

  final AnalyseController controller;
  final bool indicatorsEditMode;
  final bool indicatorDraftOpen;
  final TextEditingController newIndicatorDraft;
  final FocusNode indicatorDraftFocus;
  final VoidCallback onFinishDraftFromOutsideDismiss;
  final VoidCallback onAddButtonTap;
  final VoidCallback onDraftSubmitted;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: Text(
            l.analyseTimeframeLabelShort,
            style: AnalyseTokens.labelStyle,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            return SizedBox(
              height: AnalyseTextField.compactRowHeight,
              child: Center(
                child: SizedBox(
                  width: 88,
                  child: AnalyseInlinePill(
                    label: c.indicatorsTf,
                    icon: Icons.keyboard_arrow_down,
                    compact: true,
                    height: AnalyseTextField.compactRowHeight,
                    onPressed: (ctx) => showAnalyseStructureTfPicker(
                      ctx,
                      c,
                      forIndicatorsSection: true,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(l.analyseSetup, style: AnalyseTokens.labelStyle),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var j = 0; j < c.indicators.length; j++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnalyseSoftChip(
                        label: c.indicators[j],
                        compact: true,
                        selected: c.indicatorSetupIsSelected(c.indicators[j]),
                        onTap: () =>
                            c.toggleIndicatorsSetupSelection(c.indicators[j]),
                      ),
                      if (indicatorsEditMode)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => c.removeIndicatorAt(j),
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AnalyseTokens.muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                if (indicatorDraftOpen)
                  TapRegion(
                    onTapOutside: (_) => onFinishDraftFromOutsideDismiss(),
                    child: AnalyseIndicatorDraftPillRow(
                      controller: newIndicatorDraft,
                      focusNode: indicatorDraftFocus,
                      onAddTap: onAddButtonTap,
                      onFieldSubmitted: onDraftSubmitted,
                    ),
                  )
                else
                  AnalyseSquareIconButton(
                    icon: Icons.add_rounded,
                    boxSize: 30,
                    iconSize: 20,
                    onTap: onAddButtonTap,
                  ),
              ],
            );
          },
        ),
        ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (indicatorsEditMode) ...[
                  const SizedBox(height: 12),
                  Text(l.analyseFreeFields, style: AnalyseTokens.labelStyle),
                  const SizedBox(height: 8),
                  for (var i = 0; i < c.indicatorExtraFields.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AnalyseTextField(
                            key: ValueKey<String>('ind_extra_$i'),
                            hintText: l.analyseHintTextDots,
                            value: c.indicatorExtraFields[i],
                            minLines: 2,
                            maxLines: 4,
                            onChanged: (v) =>
                                c.updateIndicatorExtraField(i, v),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 2),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  c.removeIndicatorExtraField(i),
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AnalyseTokens.muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  AnalyseDashedButton(
                    label: l.analyseAddField,
                    compact: true,
                    onTap: c.addIndicatorExtraField,
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Text(l.analyseNotesIndicators, style: AnalyseTokens.labelStyle),
        const SizedBox(height: 8),
        AnalyseTextField(
          hintText: l.analyseHintDetailsDots,
          value: c.notesIndicators,
          minLines: 3,
          maxLines: 4,
          onChanged: (v) => c.notesIndicators = v,
        ),
        ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            if (c.indicatorsSnapshots.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),
                for (var i = 0; i < c.indicatorsSnapshots.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  AnalyseIndicatorsDuplicateBlock(
                    key: ValueKey<String>('ind_dup_$i'),
                    controller: c,
                    snapshotIndex: i,
                    indexLabel: i + 1,
                    editMode: indicatorsEditMode,
                    onRemove: indicatorsEditMode
                        ? () => c.removeIndicatorsSnapshot(i)
                        : null,
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        AnalyseConfidenceSlider(
          value: c.confidenceIndicators,
          onChanged: (v) => c.confidenceIndicators = v,
          impactPercent: c.impactIndicatorsDisplay,
          onImpactTap: () {
            final f = c.impactFeuille;
            final s = c.impactStructure;
            final i = c.impactIndicators;
            final m = c.impactSmc;
            showAnalyseImpactModal(
              context,
              label: l.analyseImpactIndicators,
              initialImpact: i,
              onApply: (w) => c.impactIndicators = w,
              onCancelRestore: () => c.restoreImpactsSnapshot(f, s, i, m),
            );
          },
        ),
      ],
    );
  }
}



