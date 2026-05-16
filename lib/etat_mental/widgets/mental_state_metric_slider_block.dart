import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../mental_state_models.dart';
import '../mental_state_tokens.dart';
import 'mental_state_inline_editable_name.dart';
import 'mental_state_value_badge.dart';

class MentalStateMetricSliderBlock extends StatelessWidget {
  const MentalStateMetricSliderBlock({
    super.key,
    required this.row,
    required this.grid,
    this.showImpactRow = true,
    required this.showEdit,
    required this.onDelete,
    required this.onWeight,
    required this.rowKey,
    required this.onValueChanged,
    required this.onRowChanged,
    required this.impactText,
    this.thinBar = false,
  });

  final MentalStateMetric row;
  final bool grid;
  final bool showImpactRow;

  /// Barres basses type aperçu web (dashboard).
  final bool thinBar;
  final bool showEdit;
  final VoidCallback onDelete;
  final VoidCallback onWeight;
  final GlobalKey<MentalStateInlineEditableNameState> rowKey;
  final ValueChanged<double> onValueChanged;
  final VoidCallback onRowChanged;
  final String impactText;

  @override
  Widget build(BuildContext context) {
    final thumb = thinBar
        ? (row.isMainSlider ? 5.5 : 5.0)
        : (row.isMainSlider ? 10.0 : 8.0);
    final trackH = thinBar ? 3.0 : 6.0;
    final labelSize = row.isMainSlider ? 13.0 : (grid ? 11.0 : 13.0);
    final track = row.inverse ? MentalStateTokens.matteRed : MentalStateTokens.matteGreen;

    final labelStyle = GoogleFonts.plusJakartaSans(
      fontSize: labelSize,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    final iconSz = grid ? 12.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: MentalStateInlineEditableName(
                  key: rowKey,
                  text: row.label,
                  style: labelStyle,
                  showEditIcon: false,
                  iconSize: iconSz,
                  onCommitted: (t) {
                    row.label = t;
                    onRowChanged();
                  },
                ),
              ),
            ),
            if (showEdit) ...[
              InkWell(
                onTap: () => rowKey.currentState?.beginEdit(),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: Icon(LucideIcons.pencil, size: iconSz, color: const Color(0xFF555555)),
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: Icon(LucideIcons.trash2, size: iconSz, color: const Color(0xFF555555)),
                ),
              ),
            ],
            const SizedBox(width: 8),
            MentalStateValueBadge('${row.value.round()}%', compact: grid),
          ],
        ),
        SizedBox(height: thinBar ? 6 : 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: trackH,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumb),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: track,
            inactiveTrackColor: MentalStateTokens.trackBg,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: row.value.clamp(0, 100),
            min: 0,
            max: 100,
            onChanged: onValueChanged,
          ),
        ),
        if (showImpactRow)
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: onWeight,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.settings,
                      size: 11,
                      color: Color(0xFF555555),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      impactText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
