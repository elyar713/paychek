import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../mental_state_add_item_dialog.dart';
import '../mental_state_controller.dart';
import '../mental_state_tokens.dart';
import '../mental_state_weight_modal.dart';
import 'mental_state_card_title_row.dart';
import 'mental_state_inline_editable_name.dart';
import 'mental_state_global_impact_rows.dart';
import 'mental_state_metric_slider_block.dart';
import 'mental_state_section_controls.dart';

class MentalStateMomentSection extends StatelessWidget {
  const MentalStateMomentSection({
    super.key,
    required this.controller,
    required this.titleStyle,
    required this.editMoment,
    required this.onToggleEditMoment,
    required this.keyForMetricRow,
    this.onGlobalMomentModal,
    this.compactForDashboard = false,
    this.wrapGap,
    this.thinMetricBars = false,
  });

  final MentalStateController controller;
  final TextStyle titleStyle;
  final bool editMoment;
  final VoidCallback onToggleEditMoment;
  final GlobalKey<MentalStateInlineEditableNameState> Function(String id) keyForMetricRow;
  final Future<void> Function()? onGlobalMomentModal;

  /// Aperçu accueil : pas d’en-tête dans la carte, pas de ligne « Impact » sous les curseurs.
  final bool compactForDashboard;

  /// Espacement entre curseurs en grille ; défaut 24.
  final double? wrapGap;

  /// Barres fines (aperçu web dashboard).
  final bool thinMetricBars;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    final embedDashboard = compactForDashboard;
    final showEditGrid = embedDashboard ? false : editMoment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!embedDashboard)
          MentalStateCardTitleRow(
            left: Row(
              children: [
                const Icon(LucideIcons.waves, size: 16, color: Color(0xFF6B6B6B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.mentalSectionMomentHeading,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            right: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MentalStateShare100Switch(
                  value: c.momentShare100,
                  onChanged: (v) => c.setMomentShare100(v),
                ),
                const SizedBox(width: MentalStateTokens.titleBarCtrlGap),
                MentalStateSlidersEditButton(
                  editActive: editMoment,
                  onEditToggle: onToggleEditMoment,
                ),
                const SizedBox(width: MentalStateTokens.titleBarCtrlGap),
                MentalStateSectionAddButton(
                  onPressed: () => showMentalAddItemDialog(context, MentalAddKind.metric, c),
                ),
              ],
            ),
          ),
        if (!embedDashboard && onGlobalMomentModal != null)
          MentalStateMomentBlockImpactRow(
            controller: c,
            onOpenModal: () => onGlobalMomentModal!(),
          ),
        if (!embedDashboard) const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = wrapGap ?? 24.0;
            final maxW = constraints.maxWidth;
            // Colonne très étroite (split / fenêtre min) : `maxW - gap` peut être <= 0 → largeur négative,
            // puis BoxConstraints invalides, LayoutBuilder (intrinsics), overlay en cascade.
            final pairBudget = maxW - gap;
            final w = pairBudget > 0
                ? math.max(1.0, pairBudget / 2)
                : math.max(1.0, maxW);
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(c.moment.length, (i) {
                final row = c.moment[i];
                return SizedBox(
                  width: w,
                  child: MentalStateMetricSliderBlock(
                    row: row,
                    grid: true,
                    thinBar: thinMetricBars,
                    showImpactRow: !embedDashboard,
                    showEdit: showEditGrid,
                    onDelete: () {
                      c.moment.removeAt(i);
                      if (c.momentShare100) {
                        c.equalizeMomentWeights();
                      }
                      c.touch();
                    },
                    onWeight: () async {
                      final wSnap = List<double>.from(c.moment.map((m) => m.weight));
                      final invSnap = row.inverse;
                      await showMentalWeightModal(
                        context,
                        showPolarity: true,
                        initialWeight: row.weight,
                        initialInverse: row.inverse,
                        onCancelRestore: () {
                          for (var j = 0; j < wSnap.length; j++) {
                            c.moment[j].weight = wSnap[j];
                          }
                          row.inverse = invSnap;
                          row.barColor = invSnap ? MentalStateTokens.matteRed : MentalStateTokens.matteGreen;
                          c.touch();
                        },
                        onApply: (nw, inv) {
                          if (c.momentShare100) {
                            c.setMomentShare(i, nw);
                          } else {
                            row.weight = nw.clamp(0.0, 100.0);
                          }
                          row.inverse = inv;
                          row.barColor = inv ? MentalStateTokens.matteRed : MentalStateTokens.matteGreen;
                          c.touch();
                        },
                      );
                    },
                    rowKey: keyForMetricRow(row.id),
                    onValueChanged: (v) {
                      row.value = v;
                      c.touch();
                    },
                    onRowChanged: () => c.touch(),
                    impactText: l.mentalSleepImpact(c.weightPercent(row.weight)),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
