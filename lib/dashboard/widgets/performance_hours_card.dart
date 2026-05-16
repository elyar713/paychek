import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard_tokens.dart';

class PerformanceHoursCard extends StatelessWidget {
  const PerformanceHoursCard({super.key});

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
              Icon(Icons.wb_sunny_outlined, color: DashboardTokens.muted, size: 18),
              const SizedBox(width: 8),
              Text(
                l.dashboardPerfHoursTitle,
                style: const TextStyle(
                  color: DashboardTokens.labelGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HourRow(
            icon: Icons.wb_twilight,
            label: l.dashboardPerfHoursRow1,
            wr: 0.81,
            barColor: DashboardTokens.accent,
            valueColor: DashboardTokens.accent,
            winRateLabel: l.dashboardPerfHourWinRate,
          ),
          const SizedBox(height: 14),
          _HourRow(
            icon: Icons.wb_sunny_outlined,
            label: l.dashboardPerfHoursRow2,
            wr: 0.65,
            barColor: Colors.white70,
            valueColor: Colors.white,
            winRateLabel: l.dashboardPerfHourWinRate,
          ),
          const SizedBox(height: 14),
          _HourRow(
            icon: Icons.nightlight_round,
            label: l.dashboardPerfHoursRow3,
            wr: 0.22,
            barColor: DashboardTokens.negative,
            valueColor: DashboardTokens.negative,
            winRateLabel: l.dashboardPerfHourWinRate,
          ),
        ],
      ),
    );
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.icon,
    required this.label,
    required this.wr,
    required this.barColor,
    required this.valueColor,
    required this.winRateLabel,
  });

  final IconData icon;
  final String label;
  final double wr;
  final Color barColor;
  final Color valueColor;
  final String Function(int percent) winRateLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: DashboardTokens.muted),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            Text(
              winRateLabel((wr * 100).round()),
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: wr,
            minHeight: 6,
            backgroundColor: const Color(0xFF222222),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}



