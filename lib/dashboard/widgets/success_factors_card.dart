import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard_tokens.dart';

class SuccessFactorsCard extends StatefulWidget {
  const SuccessFactorsCard({super.key});

  @override
  State<SuccessFactorsCard> createState() => _SuccessFactorsCardState();
}

class _SuccessFactorsCardState extends State<SuccessFactorsCard> {
  double _impact = 0.75;

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
              Icon(Icons.tune, color: DashboardTokens.muted, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.dashboardSuccessFactorsTitle,
                  style: TextStyle(
                    color: DashboardTokens.labelGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.dashboardSuccessFactorsSubtitle,
            style: TextStyle(color: DashboardTokens.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: Text(l.dashboardSuccessFactorSample,
                      style: const TextStyle(fontSize: 14))),
              Text(
                '75% WR',
                style: TextStyle(color: DashboardTokens.accent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _impact,
              activeColor: DashboardTokens.accent,
              inactiveColor: const Color(0xFF333333),
              onChanged: (v) => setState(() => _impact = v),
            ),
          ),
        ],
      ),
    );
  }
}



