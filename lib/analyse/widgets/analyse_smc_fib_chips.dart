import 'package:flutter/material.dart';

import '../analyse_tokens.dart';

/// Puces retracement Fibonacci (sélection unique).
class AnalyseSmcFibLevelChips extends StatelessWidget {
  const AnalyseSmcFibLevelChips({
    super.key,
    required this.levels,
    required this.selected,
    required this.onChanged,
  });

  static const List<String> defaultLevels = [
    '0.236',
    '0.382',
    '0.5',
    '0.618',
    '0.786',
  ];

  final List<String> levels;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final level in levels)
          _FibPill(
            label: level,
            selected: selected == level,
            onTap: () {
              if (selected == level) {
                onChanged(null);
              } else {
                onChanged(level);
              }
            },
          ),
      ],
    );
  }
}

class _FibPill extends StatelessWidget {
  const _FibPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AnalyseTokens.chipBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AnalyseTokens.oledIndigo : AnalyseTokens.inputBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? Colors.transparent : AnalyseTokens.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : AnalyseTokens.zinc400,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
