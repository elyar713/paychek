import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_impact_modal.dart';
import 'analyse_page_widgets.dart';
import 'analyse_smc_draft_pill_row.dart';
import 'analyse_smc_duplicate_block.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_confidence_slider.dart';
import 'widgets/analyse_dashed_button.dart';
import 'widgets/analyse_inline_pill_and_add_row.dart';
import 'widgets/analyse_smc_fib_chips.dart';
import 'widgets/analyse_text_field.dart';
import 'widgets/analyse_structure_tf_picker.dart';

/// Corps dÃ©pliÃ© de la carte SMC (champs principaux, copies, notes, confiance).
class AnalyseSmcExpandedBody extends StatelessWidget {
  const AnalyseSmcExpandedBody({
    super.key,
    required this.controller,
    required this.smcEditMode,
    required this.smcDraftOpen,
    required this.smcDraftCtrl,
    required this.smcDraftFocus,
    required this.onSmcAjouterTap,
    required this.onSmcDraftSubmitted,
    required this.onFinishSmcDraftFromOutsideDismiss,
  });

  final AnalyseController controller;
  final bool smcEditMode;
  final bool smcDraftOpen;
  final TextEditingController smcDraftCtrl;
  final FocusNode smcDraftFocus;
  final VoidCallback onSmcAjouterTap;
  final VoidCallback onSmcDraftSubmitted;
  final VoidCallback onFinishSmcDraftFromOutsideDismiss;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Text(l.analyseOrderBlock, style: AnalyseTokens.labelStyle),
        const SizedBox(height: 8),
        SizedBox(
          height: AnalyseTextField.compactRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 96,
                height: AnalyseTextField.compactRowHeight,
                child: AnalyseInlinePill(
                  label: c.smcTf,
                  icon: Icons.keyboard_arrow_down,
                  compact: true,
                  height: AnalyseTextField.compactRowHeight,
                  onPressed: (ctx) => showAnalyseStructureTfPicker(
                    ctx,
                    c,
                    forSmcSection: true,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AnalyseTextField(
                  hintText: l.analyseHintZoneHtf,
                  value: c.smcZone,
                  onChanged: (v) => c.smcZone = v,
                  compact: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(l.analyseFvg, style: AnalyseTokens.labelStyle),
        const SizedBox(height: 8),
        AnalyseTextField(
          hintText: l.analyseHintImbalance,
          value: c.smcFvg,
          onChanged: (v) => c.smcFvg = v,
          compact: true,
        ),
        const SizedBox(height: 14),
        Text(l.analyseLiquidityPools, style: AnalyseTokens.labelStyle),
        const SizedBox(height: 8),
        AnalyseTextField(
          hintText: l.analyseHintStops,
          value: c.smcLiquidityPools,
          onChanged: (v) => c.smcLiquidityPools = v,
          compact: true,
        ),
        const SizedBox(height: 14),
        Text(l.analyseFibLevel, style: AnalyseTokens.labelStyle),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AnalyseSmcFibLevelChips(
                levels: AnalyseSmcFibLevelChips.defaultLevels,
                selected: c.smcFibLevel,
                onChanged: (v) => c.smcFibLevel = v,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: AnalyseTextField(
                hintText: l.analyseHintPriceDots,
                value: c.smcFibPrice,
                onChanged: (v) => c.smcFibPrice = v,
                compact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(l.analyseSmcAdds, style: AnalyseTokens.labelStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < c.smcExtraFields.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnalyseSoftChip(
                    label: c.smcExtraFields[i],
                    compact: true,
                    onTap: () {},
                  ),
                  if (smcEditMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => c.removeSmcExtraFieldAt(i),
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
            if (smcDraftOpen)
              TapRegion(
                onTapOutside: (_) => onFinishSmcDraftFromOutsideDismiss(),
                child: AnalyseSmcDraftPillRow(
                  controller: smcDraftCtrl,
                  focusNode: smcDraftFocus,
                  onAddTap: onSmcAjouterTap,
                  onFieldSubmitted: onSmcDraftSubmitted,
                ),
              )
            else
              AnalyseDashedButton(
                label: l.analyseAddShort,
                compact: true,
                onTap: onSmcAjouterTap,
              ),
          ],
        ),
        if (c.smcSnapshots.isNotEmpty) ...[
          const SizedBox(height: 14),
          for (var i = 0; i < c.smcSnapshots.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            AnalyseSmcDuplicateBlock(
              key: ValueKey<String>('smc_dup_$i'),
              controller: c,
              snapshotIndex: i,
              indexLabel: i + 1,
              editMode: smcEditMode,
              onRemove: smcEditMode ? () => c.removeSmcSnapshot(i) : null,
            ),
          ],
        ],
        const SizedBox(height: 14),
        Text(l.analyseNotesSmcLiq, style: AnalyseTokens.labelStyle),
        const SizedBox(height: 8),
        AnalyseTextField(
          hintText: l.analyseNotesSmcExample,
          value: c.notesSmc,
          minLines: 3,
          maxLines: 4,
          onChanged: (v) => c.notesSmc = v,
        ),
        const SizedBox(height: 14),
        AnalyseConfidenceSlider(
          value: c.confidenceSmc,
          onChanged: (v) => c.confidenceSmc = v,
          impactPercent: c.impactSmcDisplay,
          onImpactTap: () {
            final f = c.impactFeuille;
            final s = c.impactStructure;
            final i = c.impactIndicators;
            final m = c.impactSmc;
            showAnalyseImpactModal(
              context,
              label: l.analyseImpactSmc,
              initialImpact: m,
              onApply: (w) => c.impactSmc = w,
              onCancelRestore: () => c.restoreImpactsSnapshot(f, s, i, m),
            );
          },
        ),
      ],
    );
  }
}



