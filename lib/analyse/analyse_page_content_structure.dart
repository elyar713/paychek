import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_impact_modal.dart';
import 'analyse_models.dart';
import 'analyse_page_content_structure_duplicate.dart';
import 'analyse_page_widgets.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_card.dart';
import 'widgets/analyse_confidence_slider.dart';
import 'widgets/analyse_dashed_button.dart';
import 'widgets/analyse_extra_structure_line.dart';
import 'widgets/analyse_inline_pill_and_add_row.dart';
import 'widgets/analyse_text_field.dart';
import 'widgets/analyse_collapsible_section_body.dart';
import 'widgets/analyse_section_title_row.dart';
import 'widgets/analyse_structure_tf_picker.dart';

/// Carte Â« Structure Â».
class AnalyseStructureCard extends StatefulWidget {
  const AnalyseStructureCard({
    super.key,
    required this.controller,
  });

  final AnalyseController controller;

  @override
  State<AnalyseStructureCard> createState() => _AnalyseStructureCardState();
}

class _AnalyseStructureCardState extends State<AnalyseStructureCard> {
  /// Crayon : suppression des supports / rÃ©sistances **rajoutÃ©s** (X sur chaque ligne).
  bool _extrasEditMode = false;

  void _toggleExtrasEdit() {
    setState(() => _extrasEditMode = !_extrasEditMode);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AnalyseCard(
      editorSection: AnalyseEditorSection.structure,
      child: ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          final l = AppLocalizations.of(context)!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnalyseSectionTitleRow(
                title: l.analyseStructureSectionTitle,
                icon: Icons.polyline,
                iconColor: AnalyseEditorSection.structure.sectionAccent,
                enabled: c.structureEnabled,
                onEnabledChanged: (v) => c.structureEnabled = v,
                trailing: Row(
                  children: [
                    AnalyseSquareIconButton(
                      icon: Icons.copy_all_outlined,
                      onTap: c.duplicateStructure,
                    ),
                    const SizedBox(width: 8),
                    AnalyseSquareIconButton(
                      icon: Icons.edit_outlined,
                      iconColor: _extrasEditMode
                          ? AnalyseTokens.accentGreen
                          : const Color(0xFF9A9A9A),
                      onTap: _toggleExtrasEdit,
                    ),
                  ],
                ),
              ),
              AnalyseCollapsibleSectionBody(
                expanded: c.structureEnabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    ListenableBuilder(
            listenable: c,
            builder: (context, _) {
              return SizedBox(
                height: AnalyseTextField.compactRowHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 88,
                      child: AnalyseInlinePill(
                        label: c.structureTf,
                        icon: Icons.keyboard_arrow_down,
                        compact: true,
                        height: AnalyseTextField.compactRowHeight,
                        onPressed: (ctx) =>
                            showAnalyseStructureTfPicker(ctx, c),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AnalyseTextField(
                        hintText: l.analyseLastPointHint,
                        value: c.structureDernierPoint,
                        onChanged: (v) => c.structureDernierPoint = v,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          ListenableBuilder(
            listenable: c,
            builder: (context, _) {
              final priceRow = Row(
                children: [
                  Expanded(
                    child: AnalysePriceBox(
                      label: l.analyseSupportLower,
                      accent: AnalyseTokens.accentGreen,
                      value: c.structureSupportMaj,
                      onChanged: (v) => c.structureSupportMaj = v,
                      tested: c.structureSupportTested,
                      onTestedChanged: (v) =>
                          c.structureSupportTested = v,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnalysePriceBox(
                      label: l.analyseResistLower,
                      accent: AnalyseTokens.accentRed,
                      value: c.structureResistanceMaj,
                      onChanged: (v) => c.structureResistanceMaj = v,
                      tested: c.structureResistanceTested,
                      onTestedChanged: (v) =>
                          c.structureResistanceTested = v,
                    ),
                  ),
                ],
              );

              final Widget extrasBlock =
                  c.extraSupports.isEmpty && c.extraResistances.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            for (final i in List.generate(
                              c.extraSupports.length,
                              (k) => k,
                            ))
                              AnalyseExtraStructureLine(
                                key: ValueKey<String>('extra_support_$i'),
                                label: '${l.analyseSupportLower} ${i + 1}',
                                labelAccent: AnalyseTokens.accentGreen,
                                price: c.extraSupports[i].price,
                                tenue: c.extraSupports[i].tenue,
                                onPriceChanged: (v) =>
                                    c.updateExtraSupport(i, v),
                                onTenueChanged: (t) =>
                                    c.updateExtraSupportTenue(i, t),
                                onRemove: _extrasEditMode
                                    ? () => c.removeExtraSupport(i)
                                    : null,
                              ),
                            for (final i in List.generate(
                              c.extraResistances.length,
                              (k) => k,
                            ))
                              AnalyseExtraStructureLine(
                                key: ValueKey<String>('extra_resistance_$i'),
                                label: '${l.analyseResistLower} ${i + 1}',
                                labelAccent: AnalyseTokens.accentRed,
                                price: c.extraResistances[i].price,
                                tenue: c.extraResistances[i].tenue,
                                onPriceChanged: (v) =>
                                    c.updateExtraResistance(i, v),
                                onTenueChanged: (t) =>
                                    c.updateExtraResistanceTenue(i, t),
                                onRemove: _extrasEditMode
                                    ? () => c.removeExtraResistance(i)
                                    : null,
                              ),
                          ],
                        );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  priceRow,
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AnalyseDashedButton(
                          label: l.analyseAddSupport,
                          compact: true,
                          fillExpandedSlot: true,
                          onTap: () {
                            c.addExtraSupport(
                                AnalyseStructureExtraLevel(price: ''));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnalyseDashedButton(
                          label: l.analyseAddResist,
                          compact: true,
                          fillExpandedSlot: true,
                          onTap: () {
                            c.addExtraResistance(
                                AnalyseStructureExtraLevel(price: ''));
                          },
                        ),
                      ),
                    ],
                  ),
                  extrasBlock,
                ],
              );
            },
          ),
          ListenableBuilder(
            listenable: c,
            builder: (context, _) {
              if (c.structureSnapshots.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),
                  for (final i
                      in List.generate(c.structureSnapshots.length, (k) => k)) ...[
                    if (i > 0) const SizedBox(height: 12),
                    AnalyseStructureDuplicateBlock(
                      key: ValueKey<String>('struct_dup_$i'),
                      controller: c,
                      snapshotIndex: i,
                      indexLabel: i + 1,
                      extrasEditMode: _extrasEditMode,
                      onRemoveDuplicate: _extrasEditMode
                          ? () => c.removeStructureSnapshot(i)
                          : null,
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(l.analyseNote, style: AnalyseTokens.labelStyle),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: c,
            builder: (context, _) {
              return AnalyseTextField(
                hintText: l.analyseHintNotesDots,
                value: c.notesStructure,
                minLines: 3,
                maxLines: 4,
                onChanged: (v) => c.notesStructure = v,
              );
            },
          ),
          const SizedBox(height: 14),
          AnalyseConfidenceSlider(
            value: c.confidenceStructure,
            onChanged: (v) => c.confidenceStructure = v,
            impactPercent: c.impactStructureDisplay,
            onImpactTap: () {
              final f = c.impactFeuille;
              final s = c.impactStructure;
              final i = c.impactIndicators;
              final m = c.impactSmc;
              showAnalyseImpactModal(
                context,
                label: l.analyseImpactShort,
                initialImpact: s,
                onApply: (w) => c.impactStructure = w,
                onCancelRestore: () => c.restoreImpactsSnapshot(f, s, i, m),
              );
            },
          ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



