import 'package:flutter/material.dart';

/// Interrupteur compact (sans libellé) pour titres de section OLED.
class AnalyseOledFunnelToolbar extends StatelessWidget {
  const AnalyseOledFunnelToolbar({
    super.key,
    required this.enabled,
    required this.onEnabledChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 22,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: enabled,
          onChanged: onEnabledChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
