import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_models.dart';
import 'analyse_feuille_contexte_card_body_lower.dart';
import 'analyse_page_content_contexte_options.dart';
import 'analyse_page_widgets.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_contexte_draft_pill.dart';
import 'widgets/analyse_equal_chips_row.dart';
import 'widgets/analyse_inline_pill_and_add_row.dart';
import 'widgets/analyse_collapsible_section_body.dart';
import 'widgets/analyse_section_title_row.dart';

class AnalyseFeuilleContexteCardBody extends StatelessWidget {
  const AnalyseFeuilleContexteCardBody({
    super.key,
    required this.controller,
    required this.pillsEditMode,
    required this.htfDraftOpen,
    required this.trendDraftOpen,
    required this.phaseDraftOpen,
    required this.contexteDateLayerLink,
    required this.templateMenuAnchorKey,
    required this.onTapContexteDate,
    required this.onTapTemplateMenu,
    required this.onSaveTemplate,
    required this.onTogglePillsEdit,
    required this.onOpenHtfAdd,
    required this.onOpenTrendAdd,
    required this.onOpenPhaseAdd,
    required this.onHtfDraftCommit,
    required this.onHtfDraftCancel,
    required this.onTrendDraftCommit,
    required this.onTrendDraftCancel,
    required this.onPhaseDraftCommit,
    required this.onPhaseDraftCancel,
  });

  final AnalyseController controller;
  final bool pillsEditMode;
  final bool htfDraftOpen;
  final bool trendDraftOpen;
  final bool phaseDraftOpen;
  final LayerLink contexteDateLayerLink;
  final GlobalKey templateMenuAnchorKey;
  final VoidCallback onTapContexteDate;
  final VoidCallback onTapTemplateMenu;
  final VoidCallback onSaveTemplate;
  final VoidCallback onTogglePillsEdit;
  final VoidCallback onOpenHtfAdd;
  final VoidCallback onOpenTrendAdd;
  final VoidCallback onOpenPhaseAdd;
  final void Function(String raw) onHtfDraftCommit;
  final VoidCallback onHtfDraftCancel;
  final void Function(String raw) onTrendDraftCommit;
  final VoidCallback onTrendDraftCancel;
  final void Function(String raw) onPhaseDraftCommit;
  final VoidCallback onPhaseDraftCancel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.analyseFeuillePlanTitle,
                style: AnalyseTokens.labelStyle.copyWith(
                  color: AnalyseEditorSection.feuillePlan.sectionAccent,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: l.analyseTooltipPickTemplate,
                  child: KeyedSubtree(
                    key: templateMenuAnchorKey,
                    child: AnalyseSquareIconButton(
                      icon: LucideIcons.chevronDown,
                      onTap: onTapTemplateMenu,
                      boxSize: 30,
                      iconSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: l.analyseTooltipSaveTemplatePills,
                  child: AnalyseSquareIconButton(
                    icon: LucideIcons.save,
                    iconColor: AnalyseTokens.accentGreen,
                    onTap: onSaveTemplate,
                    boxSize: 30,
                    iconSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnalyseAddInlineFieldRow(
                label: l.labelActif,
                value: c.analyseActif,
                hint: l.analyseHintActifExamples,
                onCommitted: (v) => c.analyseActif = v,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AnalyseAddInlineFieldRow(
                label: l.analyseNameFieldLabel,
                value: c.nomAnalyse,
                hint: l.analyseNameFieldHint,
                onCommitted: (v) => c.nomAnalyse = v,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnalyseSectionTitleRow(
          title: l.analyseTrendLabel,
          icon: LucideIcons.globe,
          iconColor: const Color(0xFFFF9F45),
          enabled: c.contextEnabled,
          onEnabledChanged: (v) => c.contextEnabled = v,
          trailing: Row(
            children: [
              AnalyseSquareIconButton(
                icon: Icons.copy_all_outlined,
                onTap: c.duplicateContexteTendance,
              ),
              const SizedBox(width: 8),
              AnalyseSquareIconButton(
                icon: Icons.edit_outlined,
                iconColor: pillsEditMode
                    ? AnalyseTokens.accentGreen
                    : const Color(0xFF9A9A9A),
                onTap: onTogglePillsEdit,
              ),
            ],
          ),
        ),
        AnalyseCollapsibleSectionBody(
          expanded: c.contextEnabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              CompositedTransformTarget(
                link: contexteDateLayerLink,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onTapContexteDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AnalyseTokens.muted2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.contexteAnalyseDateLabel,
                            style: AnalyseTokens.inlineMutedStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >=
                      AnalyseTokens.layoutBreakpointFeuilleGrid;
                  final directionCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.analyseDirectionLabel,
                        style: AnalyseTokens.labelStyle,
                      ),
                      const SizedBox(height: 10),
                      AnalyseEqualChipsRow<AnalyseDirectionBias>(
                        value: c.bias,
                        onChanged: (v) {
                          if (v != null) c.bias = v;
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
                      ),
                    ],
                  );
                  final trendCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.analyseCurrentTrend,
                        style: AnalyseTokens.labelStyle,
                      ),
                      const SizedBox(height: 10),
                      AnalyseEqualChipsRow<ContextePick<AnalyseLocalTrend>>(
                        value: c.localTrendPick,
                        onChanged: (v) {
                          if (v != null) c.localTrendPick = v;
                        },
                        options: buildTrendChipOptions(c, l),
                        pillEditing: pillsEditMode,
                        onRemoveOption: (pick) {
                          if (pick.isEnum) {
                            c.toggleTrendPill(pick.enumVal!);
                          } else {
                            c.removeTrendCustomLabel(pick.custom!);
                          }
                        },
                        onAddOption: pillsEditMode ? onOpenTrendAdd : null,
                        pillEditingWrapSuffix: [
                          if (pillsEditMode && trendDraftOpen)
                            AnalyseContexteDraftPill(
                              hint: l.analyseDraftLabelHint,
                              accent: AnalyseTokens.accentAmber,
                              onCommit: onTrendDraftCommit,
                              onCancel: onTrendDraftCancel,
                            ),
                        ],
                      ),
                    ],
                  );
                  final tfCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.analyseTimeframeLabelShort,
                        style: AnalyseTokens.labelStyle,
                      ),
                      const SizedBox(height: 10),
                      AnalyseEqualChipsRow<ContextePick<AnalyseTimeframe>>(
                        value: c.htfPick,
                        onChanged: (v) {
                          if (v != null) c.htfPick = v;
                        },
                        options: buildHtfChipOptions(c),
                        pillEditing: pillsEditMode,
                        onRemoveOption: (pick) {
                          if (pick.isEnum) {
                            c.toggleHtfPill(pick.enumVal!);
                          } else {
                            c.removeHtfCustomLabel(pick.custom!);
                          }
                        },
                        onAddOption: pillsEditMode ? onOpenHtfAdd : null,
                        pillEditingWrapSuffix: [
                          if (pillsEditMode && htfDraftOpen)
                            AnalyseContexteDraftPill(
                              hint: l.analyseHintHtfChipExample,
                              accent: AnalyseTokens.chipHtfSelected,
                              onCommit: onHtfDraftCommit,
                              onCancel: onHtfDraftCancel,
                            ),
                        ],
                      ),
                    ],
                  );
                  final phaseCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.analyseCurrentMarketPhase,
                        style: AnalyseTokens.labelStyle,
                      ),
                      const SizedBox(height: 10),
                      AnalyseEqualChipsRow<ContextePick<AnalysePhase>>(
                        value: c.phasePick,
                        onChanged: (v) {
                          if (v != null) c.phasePick = v;
                        },
                        options: buildPhaseChipOptions(
                          c,
                          Localizations.localeOf(context),
                        ),
                        pillEditing: pillsEditMode,
                        onRemoveOption: (pick) {
                          if (pick.isEnum) {
                            c.togglePhasePill(pick.enumVal!);
                          } else {
                            c.removePhaseCustomLabel(pick.custom!);
                          }
                        },
                        onAddOption: pillsEditMode ? onOpenPhaseAdd : null,
                        pillEditingWrapSuffix: [
                          if (pillsEditMode && phaseDraftOpen)
                            AnalyseContexteDraftPill(
                              hint: l.analyseDraftLabelHint,
                              accent: AnalyseTokens.chipPhaseSelected,
                              onCommit: onPhaseDraftCommit,
                              onCancel: onPhaseDraftCancel,
                            ),
                        ],
                      ),
                    ],
                  );

                  Widget framed(Widget child) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1118),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF263042)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: child,
                      ),
                    );
                  }

                  final directionTf = wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: directionCol),
                            const SizedBox(width: 14),
                            Expanded(child: tfCol),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            directionCol,
                            const SizedBox(height: 14),
                            tfCol,
                          ],
                        );

                  final trendPhase = wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: trendCol),
                            const SizedBox(width: 14),
                            Expanded(child: phaseCol),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            trendCol,
                            const SizedBox(height: 14),
                            phaseCol,
                          ],
                        );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      framed(directionTf),
                      const SizedBox(height: 12),
                      framed(trendPhase),
                    ],
                  );
                },
              ),
              AnalyseFeuilleContexteCardBodyLower(
                controller: c,
                pillsEditMode: pillsEditMode,
              ),
            ],
          ),
        ),
      ],
    );
  }
}



