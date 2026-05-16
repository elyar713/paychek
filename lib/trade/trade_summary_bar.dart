import 'package:flutter/material.dart';

import '../dashboard/widgets/donut_ring.dart';
import '../l10n/app_localizations.dart';
import 'trade_tokens.dart';

/// Barre du haut : 3 colonnes (profit net, win rate, R/R moyen).
class TradeSummaryBar extends StatelessWidget {
  const TradeSummaryBar({
    super.key,
    required this.profitNetLabel,
    this.profitNetSubLabel,
    this.profitNetColor,
    required this.winRateLabel,
    required this.tradesLabel,
    required this.breakdownLabel,
  });

  final String profitNetLabel;
  final String? profitNetSubLabel;
  final Color? profitNetColor;
  final String winRateLabel;
  final String tradesLabel;
  final String breakdownLabel;

  double? _parsePercent(String label) {
    // Accepte "64.2%", "64,2 %", "64", etc.
    final raw = label.trim().replaceAll('%', '').replaceAll(' ', '');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null) return null;
    if (v.isNaN || v.isInfinite) return null;
    return v.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    final winPct = _parsePercent(winRateLabel);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: TradeTokens.cardBg,
        borderRadius: BorderRadius.circular(TradeTokens.radiusLg),
        border: Border.all(color: TradeTokens.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Col(
              label: l.tradeSummaryProfitNet,
              value: profitNetLabel,
              valueColor: profitNetColor ?? TradeTokens.profitNeon,
              valueStyle: t.titleMedium,
              subLabel: profitNetSubLabel,
            ),
          ),
          Container(width: 1, height: 44, color: TradeTokens.divider),
          Expanded(
            child: winPct == null
                ? _Col(
                    label: l.tradeSummaryWinRate,
                    value: winRateLabel,
                    valueColor: Colors.white,
                    valueStyle: t.titleMedium,
                  )
                : Center(
                    child: DonutRing(
                      progress: (winPct / 100.0).clamp(0.0, 1.0),
                      centerPrimary: winRateLabel.trim().replaceAll(' ', ''),
                      centerSecondary: l.dashboardRingWin,
                      size: 60,
                      strokeWidth: 4,
                      ringColor: winPct < 0 ? TradeTokens.lossNeon : TradeTokens.profitNeon,
                    ),
                  ),
          ),
          Container(width: 1, height: 44, color: TradeTokens.divider),
          Expanded(
            child: _Col(
              label: l.tradeSummaryTrades,
              value: tradesLabel,
              valueColor: Colors.white,
              valueStyle: t.titleMedium,
              subLabel: breakdownLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _Col extends StatelessWidget {
  const _Col({
    required this.label,
    required this.value,
    required this.valueColor,
    this.valueStyle,
    this.subLabel,
  });

  final String label;
  final String value;
  final Color valueColor;
  final TextStyle? valueStyle;
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              color: TradeTokens.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (valueStyle ?? t.titleLarge)?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              height: 1.1,
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              subLabel!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.labelSmall?.copyWith(
                color: TradeTokens.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
