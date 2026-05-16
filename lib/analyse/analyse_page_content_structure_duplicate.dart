import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_page_widgets.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_dashed_button.dart';
import 'widgets/analyse_extra_structure_line.dart';
import 'widgets/analyse_inline_pill_and_add_row.dart';
import 'widgets/analyse_text_field.dart';
import 'widgets/analyse_structure_tf_picker.dart';

/// Bloc copie dupliquÃ©e : TF, dernier point, rajouts support/rÃ©sistance Ã©ditables sur le snapshot.
class AnalyseStructureDuplicateBlock extends StatelessWidget {
  const AnalyseStructureDuplicateBlock({
    super.key,
    required this.controller,
    required this.snapshotIndex,
    required this.indexLabel,
    required this.extrasEditMode,
    this.onRemoveDuplicate,
  });

  final AnalyseController controller;
  final int snapshotIndex;
  final int indexLabel;
  /// Crayon : X sur les lignes rajoutÃ©es + suppression du bloc Â« Copie Â».
  final bool extrasEditMode;
  final VoidCallback? onRemoveDuplicate;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final idx = snapshotIndex;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        if (idx < 0 || idx >= c.structureSnapshots.length) {
          return const SizedBox.shrink();
        }
        final s = c.structureSnapshots[idx];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AnalyseTokens.structureDuplicateBg,
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
                  if (onRemoveDuplicate != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onRemoveDuplicate,
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
                height: AnalyseTextField.compactRowHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 88,
                      child: AnalyseInlinePill(
                        label: s.structureTf,
                        icon: Icons.keyboard_arrow_down,
                        compact: true,
                        height: AnalyseTextField.compactRowHeight,
                        onPressed: (ctx) => showAnalyseStructureTfPicker(
                          ctx,
                          c,
                          structureSnapshotIndex: idx,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AnalyseTextField(
                        hintText: l.analyseLastPointHint,
                        value: s.dernierPoint,
                        onChanged: (v) => c.setStructureSnapshotDernierPoint(idx, v),
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnalysePriceBox(
                          label: l.analyseSupportLower,
                          accent: AnalyseTokens.accentGreen,
                          value: s.structureSupportMaj,
                          onChanged: (v) =>
                              c.setStructureSnapshotSupportMaj(idx, v),
                          tested: s.structureSupportTested,
                          onTestedChanged: (v) =>
                              c.setStructureSnapshotSupportTested(idx, v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnalysePriceBox(
                          label: l.analyseResistLower,
                          accent: AnalyseTokens.accentRed,
                          value: s.structureResistanceMaj,
                          onChanged: (v) =>
                              c.setStructureSnapshotResistanceMaj(idx, v),
                          tested: s.structureResistanceTested,
                          onTestedChanged: (v) =>
                              c.setStructureSnapshotResistanceTested(idx, v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AnalyseDashedButton(
                          label: l.analyseAddSupport,
                          compact: true,
                          fillExpandedSlot: true,
                          onTap: () => c.addStructureSnapshotExtraSupport(idx),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnalyseDashedButton(
                          label: l.analyseAddResist,
                          compact: true,
                          fillExpandedSlot: true,
                          onTap: () =>
                              c.addStructureSnapshotExtraResistance(idx),
                        ),
                      ),
                    ],
                  ),
                  if (s.extraSupports.isNotEmpty ||
                      s.extraResistances.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final i in List.generate(
                            s.extraSupports.length,
                            (k) => k,
                          ))
                            AnalyseExtraStructureLine(
                              key: ValueKey<String>(
                                  'snap_${idx}_support_$i'),
                              label: '${l.analyseSupportLower} ${i + 1}',
                              labelAccent: AnalyseTokens.accentGreen,
                              price: s.extraSupports[i].price,
                              tenue: s.extraSupports[i].tenue,
                              onPriceChanged: (v) =>
                                  c.updateStructureSnapshotExtraSupport(
                                      idx, i, v),
                              onTenueChanged: (t) =>
                                  c.updateStructureSnapshotExtraSupportTenue(
                                    idx,
                                    i,
                                    t,
                                  ),
                              onRemove: extrasEditMode
                                  ? () => c
                                      .removeStructureSnapshotExtraSupport(
                                      idx,
                                      i,
                                    )
                                  : null,
                            ),
                          for (final i in List.generate(
                            s.extraResistances.length,
                            (k) => k,
                          ))
                            AnalyseExtraStructureLine(
                              key: ValueKey<String>(
                                  'snap_${idx}_resistance_$i'),
                              label: '${l.analyseResistLower} ${i + 1}',
                              labelAccent: AnalyseTokens.accentRed,
                              price: s.extraResistances[i].price,
                              tenue: s.extraResistances[i].tenue,
                              onPriceChanged: (v) =>
                                  c.updateStructureSnapshotExtraResistance(
                                    idx,
                                    i,
                                    v,
                                  ),
                              onTenueChanged: (t) =>
                                  c
                                      .updateStructureSnapshotExtraResistanceTenue(
                                    idx,
                                    i,
                                    t,
                                  ),
                              onRemove: extrasEditMode
                                  ? () => c
                                      .removeStructureSnapshotExtraResistance(
                                      idx,
                                      i,
                                    )
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}



