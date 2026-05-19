import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../mental_state_add_item_dialog.dart';
import '../mental_state_controller.dart';
import '../mental_state_tokens.dart';
import '../mental_state_weight_modal.dart';
import 'mental_state_card_title_row.dart';
import 'mental_state_dashed_add_button.dart';
import 'mental_state_emotion_chip.dart';
import 'mental_state_global_impact_rows.dart';
import 'mental_state_inline_editable_name.dart';
import 'mental_state_section_controls.dart';

class MentalStateEmotionSection extends StatelessWidget {
  const MentalStateEmotionSection({
    super.key,
    required this.controller,
    required this.titleStyle,
    required this.editEmotions,
    required this.onToggleEditEmotions,
    required this.keyForEmotionLabel,
    required this.onGlobalEmotionModal,
    required this.onDeleteEmotionAt,
  });

  final MentalStateController controller;
  final TextStyle titleStyle;
  final bool editEmotions;
  final VoidCallback onToggleEditEmotions;
  final GlobalKey<MentalStateInlineEditableNameState> Function(String id) keyForEmotionLabel;
  final Future<void> Function() onGlobalEmotionModal;
  final void Function(int index) onDeleteEmotionAt;

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
              const Icon(LucideIcons.smile, size: 16, color: Color(0xFF6B6B6B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.mentalSectionEmotionHeading,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          right: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MentalStateShare100Switch(
                value: c.emotionsShare100,
                onChanged: (v) => c.setEmotionsShare100(v),
              ),
              const SizedBox(width: MentalStateTokens.titleBarCtrlGap),
              MentalStateSlidersEditButton(
                editActive: editEmotions,
                onEditToggle: onToggleEditEmotions,
              ),
            ],
          ),
        ),
        MentalStateEmotionBlockImpactRow(
          controller: c,
          onOpenModal: () => onGlobalEmotionModal(),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...List.generate(
              c.emotions.length,
              (i) => MentalStateEmotionChip(
                controller: c,
                emotion: c.emotions[i],
                index: i,
                editEmotions: editEmotions,
                labelKey: keyForEmotionLabel(c.emotions[i].id),
                onOpenWeightModal: () async {
                  final e = c.emotions[i];
                  final wSnap = List<double>.from(c.emotions.map((x) => x.weight));
                  final invSnap = e.inverse;
                  final initialW = e.weight;
                  await showMentalWeightModal(
                    context,
                    showPolarity: true,
                    initialWeight: initialW,
                    initialInverse: e.inverse,
                    onCancelRestore: () {
                      for (var j = 0; j < wSnap.length; j++) {
                        c.emotions[j].weight = wSnap[j];
                      }
                      e.inverse = invSnap;
                      c.touch();
                    },
                    onApply: (nw, inv) {
                      if (c.emotionsShare100) {
                        c.setEmotionShare(i, nw);
                      } else {
                        e.weight = nw.clamp(0.0, 100.0);
                      }
                      e.inverse = inv;
                      c.touch();
                    },
                  );
                },
                onDelete: () => onDeleteEmotionAt(i),
              ),
            ),
            MentalStateDashedAddButton(
              onTap: () => showMentalAddItemDialog(context, MentalAddKind.emotion, c),
            ),
          ],
        ),
      ],
    );
  }
}
