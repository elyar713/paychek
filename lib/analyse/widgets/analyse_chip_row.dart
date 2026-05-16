import 'package:flutter/material.dart';

import '../analyse_models.dart';
import '../analyse_tokens.dart';

class AnalyseChipRow<T> extends StatelessWidget {
  const AnalyseChipRow({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.compact = false,
  });

  final T value;
  final List<AnalyseChipOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final o in options)
          _Chip(
            label: o.label,
            selected: o.value == value,
            compact: compact,
            onTap: () => onChanged(o.value),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF0F2A20) : AnalyseTokens.chipBg;
    final fg = selected ? AnalyseTokens.accentGreen : const Color(0xFFCFCFCF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusChip),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AnalyseTokens.radiusChip),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

