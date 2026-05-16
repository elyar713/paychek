import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard_tokens.dart';

class AiCoachCard extends StatelessWidget {
  const AiCoachCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: DashboardTokens.cardPadding,
      decoration: DashboardTokens.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined, color: DashboardTokens.accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.dashboardAiCoachTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: DashboardTokens.accent,
                  side: const BorderSide(color: DashboardTokens.accent),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(Icons.auto_awesome, size: 14, color: DashboardTokens.accent),
                label: Text(l.dashboardAiAnalyze, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.dashboardAiCoachBody,
            style: TextStyle(color: DashboardTokens.muted, fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }
}



