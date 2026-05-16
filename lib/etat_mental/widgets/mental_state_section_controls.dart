import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../mental_state_tokens.dart';

/// « 100 % » + switch partage.
class MentalStateShare100Switch extends StatelessWidget {
  const MentalStateShare100Switch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.plusJakartaSans(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF888888),
      height: 1.0,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '100%',
          style: labelStyle,
          strutStyle: const StrutStyle(forceStrutHeight: true, height: 1, fontSize: 9, leading: 0),
        ),
        const SizedBox(width: MentalStateTokens.titleBarCtrlGap),
        SizedBox(
          width: 34,
          height: 20,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            child: Switch(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class MentalStateSlidersEditButton extends StatelessWidget {
  const MentalStateSlidersEditButton({
    super.key,
    required this.editActive,
    required this.onEditToggle,
    this.iconSize = 16,
  });

  final bool editActive;
  final VoidCallback onEditToggle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 24, height: 24),
      visualDensity: VisualDensity.compact,
      tooltip: '',
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(
        LucideIcons.sliders,
        size: iconSize,
        color: editActive ? Colors.white : const Color(0xFF555555),
      ),
      onPressed: onEditToggle,
    );
  }
}

class MentalStateSectionAddButton extends StatelessWidget {
  const MentalStateSectionAddButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 24, height: 24),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(LucideIcons.plus, size: 16, color: Color(0xFF555555)),
      onPressed: onPressed,
    );
  }
}
