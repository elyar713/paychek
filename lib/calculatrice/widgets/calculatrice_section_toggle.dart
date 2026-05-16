import 'package:flutter/material.dart';

import '../../dashboard/dashboard_tokens.dart';
import '../../l10n/app_localizations.dart';

enum CalculatriceSection { tradeReturn, ratio }

class SectionToggle extends StatelessWidget {
  const SectionToggle({super.key, required this.value, required this.onChanged});

  final CalculatriceSection value;
  final ValueChanged<CalculatriceSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final selectedBg = DashboardTokens.cardBoxBg;
    final unselectedBg = Colors.black.withValues(alpha: 0.18);

    Widget button({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? selectedBg : unselectedBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        button(
          label: l.tradeReturn,
          selected: value == CalculatriceSection.tradeReturn,
          onTap: () => onChanged(CalculatriceSection.tradeReturn),
        ),
        const SizedBox(width: 10),
        button(
          label: l.calculateRatio,
          selected: value == CalculatriceSection.ratio,
          onTap: () => onChanged(CalculatriceSection.ratio),
        ),
      ],
    );
  }
}

