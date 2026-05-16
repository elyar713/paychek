import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../mental_state_add_item_dialog.dart';
import '../mental_state_controller.dart';
import '../mental_state_tokens.dart';
import '../mental_state_weight_modal.dart';
import 'mental_state_card_title_row.dart';
import 'mental_state_global_impact_rows.dart';
import 'mental_state_inline_editable_name.dart';
import 'mental_state_metric_slider_block.dart';
import 'mental_state_section_controls.dart';

class MentalStateRoutinesSection extends StatelessWidget {
  const MentalStateRoutinesSection({
    super.key,
    required this.controller,
    required this.titleStyle,
    required this.editFactors,
    required this.onToggleEditFactors,
    required this.keyForMetricRow,
    required this.onGlobalRoutinesModal,
  });

  final MentalStateController controller;
  final TextStyle titleStyle;
  final bool editFactors;
  final VoidCallback onToggleEditFactors;
  final GlobalKey<MentalStateInlineEditableNameState> Function(String id) keyForMetricRow;
  final Future<void> Function() onGlobalRoutinesModal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MentalStateCardTitleRow(
          left: Row(
            children: [
              const Icon(LucideIcons.zap, size: 16, color: Color(0xFF6B6B6B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.mentalSectionRoutinesHeading,
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
                value: c.factorsShare100,
                onChanged: (v) => c.setFactorsShare100(v),
              ),
              const SizedBox(width: MentalStateTokens.titleBarCtrlGap),
              MentalStateSlidersEditButton(
                editActive: editFactors,
                onEditToggle: onToggleEditFactors,
              ),
              const SizedBox(width: MentalStateTokens.titleBarCtrlGap),
              MentalStateSectionAddButton(
                onPressed: () => showMentalAddItemDialog(context, MentalAddKind.routine, c),
              ),
            ],
          ),
        ),
        MentalStateRoutinesGlobalImpactRow(
          controller: c,
          onOpenModal: () => onGlobalRoutinesModal(),
        ),
        ...List.generate(c.factors.length, (i) {
          final row = c.factors[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < c.factors.length - 1 ? 24 : 0),
            child: MentalStateMetricSliderBlock(
              row: row,
              grid: false,
              showEdit: editFactors,
              onDelete: () {
                c.factors.removeAt(i);
                if (c.factorsShare100) {
                  c.equalizeFactorWeights();
                }
                c.touch();
              },
              onWeight: () async {
                final wSnap = List<double>.from(c.factors.map((f) => f.weight));
                final invSnap = row.inverse;
                await showMentalWeightModal(
                  context,
                  showPolarity: true,
                  initialWeight: row.weight,
                  initialInverse: row.inverse,
                  onCancelRestore: () {
                    for (var j = 0; j < wSnap.length; j++) {
                      c.factors[j].weight = wSnap[j];
                    }
                    row.inverse = invSnap;
                    row.barColor = invSnap ? MentalStateTokens.matteRed : MentalStateTokens.matteGreen;
                    c.touch();
                  },
                  onApply: (nw, inv) {
                    if (c.factorsShare100) {
                      c.setFactorShare(i, nw);
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
      ],
    );
  }
}
