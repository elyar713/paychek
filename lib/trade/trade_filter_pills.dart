import 'package:flutter/material.dart';

import 'trade_tokens.dart';

class TradeFilterPills extends StatelessWidget {
  const TradeFilterPills({
    super.key,
    required this.labels,
    required this.subLabels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final List<String?> subLabels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == subLabels.length);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _Pill(
              label: labels[i],
              subLabel: subLabels[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.subLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? subLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TradeTokens.radiusFilter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : TradeTokens.pillInactiveBg,
            borderRadius: BorderRadius.circular(TradeTokens.radiusFilter),
            border: Border.all(
              color: selected ? Colors.white : TradeTokens.cardBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black : TradeTokens.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (subLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  subLabel!,
                  style: TextStyle(
                    color: selected
                        ? Colors.black.withValues(alpha: 0.65)
                        : TradeTokens.textDate,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1.1,
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
