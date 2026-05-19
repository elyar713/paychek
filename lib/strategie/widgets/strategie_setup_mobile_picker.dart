import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../strategie_tokens.dart';
import 'strategie_setup_card.dart';

bool strategieUseMobileSetupPicker(BuildContext context) =>
    MediaQuery.sizeOf(context).width < 520;

/// Liste de boutons — un par setup, sur place (mobile uniquement, pas de feuille).
class StrategieSetupMobilePickerList extends StatelessWidget {
  const StrategieSetupMobilePickerList({
    super.key,
    required this.setups,
    required this.selectedIndex,
    required this.onSelected,
    this.onDeleteAt,
  });

  final List<StrategieSetupCardData> setups;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int>? onDeleteAt;

  @override
  Widget build(BuildContext context) {
    if (setups.isEmpty) return const SizedBox.shrink();

    final selected = selectedIndex.clamp(0, setups.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < setups.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _StrategieSetupInlineButton(
            setup: setups[i],
            selected: i == selected,
            onTap: () => onSelected(i),
            onDelete: onDeleteAt != null ? () => onDeleteAt!(i) : null,
          ),
        ],
      ],
    );
  }
}

class _StrategieSetupInlineButton extends StatelessWidget {
  const _StrategieSetupInlineButton({
    required this.setup,
    required this.selected,
    required this.onTap,
    this.onDelete,
  });

  final StrategieSetupCardData setup;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StrategieTokens.radiusSm),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? StrategieTokens.emerald.withValues(alpha: 0.12)
                : StrategieTokens.innerCardBg,
            borderRadius: BorderRadius.circular(StrategieTokens.radiusSm),
            border: Border.all(
              color: selected
                  ? StrategieTokens.emerald
                  : setup.dotColor.withValues(alpha: 0.45),
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: setup.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    setup.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? StrategieTokens.emerald
                          : Colors.white.withValues(alpha: 0.92),
                      height: 1.3,
                    ),
                  ),
                ),
                if (onDelete != null)
                  StrategieSetupDeleteIconButton(onPressed: onDelete!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
