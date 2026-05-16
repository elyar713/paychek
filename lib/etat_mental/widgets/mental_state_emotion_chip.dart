import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../mental_state_controller.dart';
import '../mental_state_models.dart';
import '../mental_state_tokens.dart';
import 'mental_state_inline_editable_name.dart';

class MentalStateEmotionChip extends StatelessWidget {
  const MentalStateEmotionChip({
    super.key,
    required this.controller,
    required this.emotion,
    required this.index,
    required this.editEmotions,
    required this.labelKey,
    required this.onOpenWeightModal,
    required this.onDelete,
  });

  final MentalStateController controller;
  final MentalStateEmotion emotion;
  final int index;
  final bool editEmotions;
  final GlobalKey<MentalStateInlineEditableNameState> labelKey;
  final Future<void> Function() onOpenWeightModal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final active = controller.isEmotionSelected(emotion.id);
    final borderColor = active ? Colors.white : const Color(0xFF1c1c1c);
    final nameStyle = GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: active ? Colors.black : Colors.white,
    );
    final pctStyle = GoogleFonts.plusJakartaSans(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      color: emotion.inverse ? MentalStateTokens.matteRed : MentalStateTokens.matteGreen,
    );
    final iconColor = active ? const Color(0xFF555555) : const Color(0xFF888888);
    final dividerColor = active ? const Color(0xFFE0E0E0) : const Color(0xFF333333);

    return Material(
      color: active ? Colors.white : const Color(0xFF0a0a0a),
      shape: StadiumBorder(side: BorderSide(color: borderColor, width: 1)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: editEmotions
            ? null
            : () {
                controller.toggleEmotionSelected(emotion.id);
              },
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MentalStateInlineEditableName(
                key: labelKey,
                text: emotion.label,
                style: nameStyle,
                showEditIcon: false,
                iconSize: 12,
                shrinkWrap: true,
                maxLabelWidth: 80,
                onCommitted: (t) {
                  emotion.label = t;
                  controller.touch();
                },
              ),
              const SizedBox(width: 4),
              Text('${controller.emotionFactorImpactPercent(emotion)}%', style: pctStyle),
              if (editEmotions) ...[
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 14,
                  color: dividerColor,
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => onOpenWeightModal(),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(LucideIcons.settings, size: 12, color: Color(0xFF666666)),
                  ),
                ),
                InkWell(
                  onTap: () => labelKey.currentState?.beginEdit(),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(LucideIcons.pencil, size: 12, color: iconColor),
                  ),
                ),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(LucideIcons.trash2, size: 12, color: iconColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
