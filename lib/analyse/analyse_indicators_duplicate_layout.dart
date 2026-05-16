import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_indicator_draft_pill_row.dart';
import 'analyse_page_widgets.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_dashed_button.dart';
import 'widgets/analyse_inline_pill_and_add_row.dart';
import 'widgets/analyse_text_field.dart';
import 'widgets/analyse_structure_tf_picker.dart';

/// UI du bloc Â« Copie N Â» indicateurs (sans Ã©tat brouillon : fourni par le parent).
class AnalyseIndicatorsDuplicateLayout extends StatelessWidget {
  const AnalyseIndicatorsDuplicateLayout({
    super.key,
    required this.controller,
    required this.snapshotIndex,
    required this.indexLabel,
    required this.editMode,
    this.onRemove,
    required this.dupDraftOpen,
    required this.dupDraftCtrl,
    required this.dupDraftFocus,
    required this.onDupAddTap,
    required this.onDupDraftSubmitted,
    required this.onFinishDupDraft,
  });

  final AnalyseController controller;
  final int snapshotIndex;
  final int indexLabel;
  final bool editMode;
  final VoidCallback? onRemove;
  final bool dupDraftOpen;
  final TextEditingController dupDraftCtrl;
  final FocusNode dupDraftFocus;
  final VoidCallback onDupAddTap;
  final VoidCallback onDupDraftSubmitted;
  final VoidCallback onFinishDupDraft;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final idx = snapshotIndex;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AnalyseTokens.indicatorsDuplicateBg,
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusField),
      ),
      child: ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          final l = AppLocalizations.of(context)!;
          if (idx < 0 || idx >= c.indicatorsSnapshots.length) {
            return const SizedBox.shrink();
          }
          final s = c.indicatorsSnapshots[idx];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      l.analyseCopyLabel('$indexLabel'),
                      style: AnalyseTokens.inlineMutedStyle,
                    ),
                  ),
                  if (onRemove != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onRemove,
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
              SizedBox(
                height: AnalyseTextField.compactRowHeight,
                child: Center(
                  child: SizedBox(
                    width: 88,
                    child: AnalyseInlinePill(
                      label: s.indicatorsTf,
                      icon: Icons.keyboard_arrow_down,
                      compact: true,
                      height: AnalyseTextField.compactRowHeight,
                      onPressed: (ctx) => showAnalyseStructureTfPicker(
                        ctx,
                        c,
                        forIndicatorsSection: true,
                        indicatorsSnapshotIndex: idx,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(l.analyseSetup, style: AnalyseTokens.labelStyle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (var j = 0; j < s.indicatorNames.length; j++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnalyseSoftChip(
                          label: s.indicatorNames[j],
                          compact: true,
                          selected: s.activeIndicatorSetup
                              .contains(s.indicatorNames[j]),
                          onTap: () => c.toggleIndicatorsSnapshotSetupSelection(
                                idx,
                                s.indicatorNames[j],
                              ),
                        ),
                        if (editMode)
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    c.removeIndicatorsSnapshotIndicatorAt(
                                        idx, j),
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
                  if (dupDraftOpen)
                    TapRegion(
                      onTapOutside: (_) => onFinishDupDraft(),
                      child: AnalyseIndicatorDraftPillRow(
                        controller: dupDraftCtrl,
                        focusNode: dupDraftFocus,
                        onAddTap: onDupAddTap,
                        onFieldSubmitted: onDupDraftSubmitted,
                      ),
                    )
                  else
                    AnalyseSquareIconButton(
                      icon: Icons.add_rounded,
                      boxSize: 30,
                      iconSize: 20,
                      onTap: onDupAddTap,
                    ),
                ],
              ),
              if (editMode) ...[
                const SizedBox(height: 12),
                Text(l.analyseFreeFields, style: AnalyseTokens.labelStyle),
                const SizedBox(height: 8),
                for (var i = 0; i < s.extraFields.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AnalyseTextField(
                          key: ValueKey<String>('ind_dup_${idx}_extra_$i'),
                          hintText: l.analyseHintTextDots,
                          value: s.extraFields[i],
                          minLines: 2,
                          maxLines: 4,
                          onChanged: (v) =>
                              c.updateIndicatorsSnapshotExtraField(idx, i, v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                c.removeIndicatorsSnapshotExtraField(idx, i),
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
                if (s.extraFields.isNotEmpty) const SizedBox(height: 8),
                AnalyseDashedButton(
                  label: l.analyseAddField,
                  compact: true,
                  onTap: () => c.addIndicatorsSnapshotExtraField(idx),
                ),
              ] else if (s.extraFields.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l.analyseFreeFields, style: AnalyseTokens.labelStyle),
                const SizedBox(height: 6),
                for (final line in s.extraFields)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line.trim().isEmpty ? 'â€”' : line,
                      style: line.trim().isEmpty
                          ? AnalyseTokens.inputTextStyle.copyWith(
                              color: AnalyseTokens.muted,
                            )
                          : AnalyseTokens.inputTextStyle,
                    ),
                  ),
              ],
              const SizedBox(height: 10),
              Text(l.analyseNotesIndicators, style: AnalyseTokens.labelStyle),
              const SizedBox(height: 6),
              AnalyseTextField(
                key: ValueKey<String>('ind_dup_${idx}_notes'),
                hintText: l.analyseHintDetailsDots,
                value: s.notesIndicators,
                minLines: 2,
                maxLines: 4,
                onChanged: (v) => c.setIndicatorsSnapshotNotes(idx, v),
              ),
            ],
          );
        },
      ),
    );
  }
}



