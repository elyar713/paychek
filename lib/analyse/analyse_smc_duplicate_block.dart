import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_dashed_button.dart';
import 'widgets/analyse_smc_fib_chips.dart';
import 'widgets/analyse_text_field.dart';
import 'widgets/analyse_inline_pill_and_add_row.dart';
import 'widgets/analyse_structure_tf_picker.dart';

/// Copie SMC : mÃªmes champs + notes (pas confiance / impact).
class AnalyseSmcDuplicateBlock extends StatelessWidget {
  const AnalyseSmcDuplicateBlock({
    super.key,
    required this.controller,
    required this.snapshotIndex,
    required this.indexLabel,
    required this.editMode,
    this.onRemove,
  });

  final AnalyseController controller;
  final int snapshotIndex;
  final int indexLabel;
  final bool editMode;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final idx = snapshotIndex;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        if (idx < 0 || idx >= c.smcSnapshots.length) {
          return const SizedBox.shrink();
        }
        final s = c.smcSnapshots[idx];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AnalyseTokens.smcDuplicateBg,
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
                        label: s.smcTf,
                        icon: Icons.keyboard_arrow_down,
                        compact: true,
                        height: AnalyseTextField.compactRowHeight,
                        onPressed: (ctx) => showAnalyseStructureTfPicker(
                          ctx,
                          c,
                          forSmcSection: true,
                          smcSnapshotIndex: idx,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AnalyseTextField(
                        key: ValueKey<String>('smc_dup_${idx}_zone'),
                        hintText: l.analyseHintZoneHtf,
                        value: s.smcZone,
                        onChanged: (v) => c.setSmcSnapshotZone(idx, v),
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
                key: ValueKey<String>('smc_dup_${idx}_fvg'),
                hintText: l.analyseHintImbalance,
                value: s.smcFvg,
                onChanged: (v) => c.setSmcSnapshotFvg(idx, v),
                compact: true,
              ),
              const SizedBox(height: 12),
              Text(l.analyseLiquidityPools, style: AnalyseTokens.labelStyle),
              const SizedBox(height: 8),
              AnalyseTextField(
                key: ValueKey<String>('smc_dup_${idx}_liq'),
                hintText: l.analyseHintStops,
                value: s.smcLiquidityPools,
                onChanged: (v) => c.setSmcSnapshotLiquidityPools(idx, v),
                compact: true,
              ),
              const SizedBox(height: 12),
              Text(l.analyseFibLevel, style: AnalyseTokens.labelStyle),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: AnalyseSmcFibLevelChips(
                      levels: AnalyseSmcFibLevelChips.defaultLevels,
                      selected: s.smcFibLevel,
                      onChanged: (v) => c.setSmcSnapshotFibLevel(idx, v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: AnalyseTextField(
                      key: ValueKey<String>('smc_dup_${idx}_fibp'),
                      hintText: l.analyseHintPriceDots,
                      value: s.smcFibPrice,
                      onChanged: (v) => c.setSmcSnapshotFibPrice(idx, v),
                      compact: true,
                    ),
                  ),
                ],
              ),
              if (editMode) ...[
                const SizedBox(height: 12),
                Text(l.analyseSmcAdds, style: AnalyseTokens.labelStyle),
                const SizedBox(height: 8),
                for (var i = 0; i < s.extraFields.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AnalyseTextField(
                          key: ValueKey<String>('smc_dup_${idx}_extra_$i'),
                          hintText: l.analyseHintTextDots,
                          value: s.extraFields[i],
                          minLines: 2,
                          maxLines: 4,
                          onChanged: (v) =>
                              c.updateSmcSnapshotExtraField(idx, i, v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                c.removeSmcSnapshotExtraField(idx, i),
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
                  onTap: () => c.addSmcSnapshotExtraField(idx),
                ),
              ] else if (s.extraFields.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l.analyseSmcAdds, style: AnalyseTokens.labelStyle),
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
              Text(l.analyseNotesSmcLiq, style: AnalyseTokens.labelStyle),
              const SizedBox(height: 6),
              AnalyseTextField(
                key: ValueKey<String>('smc_dup_${idx}_notes'),
                hintText: l.analyseHintDetailsDots,
                value: s.notesSmc,
                minLines: 2,
                maxLines: 4,
                onChanged: (v) => c.setSmcSnapshotNotes(idx, v),
              ),
            ],
          ),
        );
      },
    );
  }
}



