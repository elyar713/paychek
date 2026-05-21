import 'package:flutter/material.dart';

import '../../dashboard/dashboard_tokens.dart';

/// Interrupteur on/off compact — à côté du menu ⋯ d’une section checklist.
class ChecklistSectionEnableToggle extends StatelessWidget {
  const ChecklistSectionEnableToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.tooltip,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Transform.scale(
        scale: 0.82,
        alignment: Alignment.center,
        child: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: DashboardTokens.accent,
          activeTrackColor: DashboardTokens.accent.withValues(alpha: 0.38),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
