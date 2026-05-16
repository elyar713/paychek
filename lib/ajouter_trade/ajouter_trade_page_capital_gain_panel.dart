import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../strategie/sections/strategie_gestion_risque_section_display.dart';

const String _kEmDash = '\u2014';

/// Bloc **Capital** / **Gain** + ligne solde et % du capital (carte discipline).
class AjouterTradeCapitalGainPanel extends StatelessWidget {
  const AjouterTradeCapitalGainPanel({
    super.key,
    required this.cap,
    required this.sym,
    required this.gain,
    required this.commission,
    required this.sortieVide,
    required this.positionEnCours,
    required this.breakeven,
    required this.commissionLayerLink,
    required this.onOpenCommission,
    required this.titleStyle,
    required this.mutedStyle,
  });

  final double? cap;
  final String sym;
  final double? gain;
  final double commission;
  final bool sortieVide;
  final bool positionEnCours;
  final bool breakeven;
  final LayerLink commissionLayerLink;
  final VoidCallback onOpenCommission;
  final TextStyle? titleStyle;
  final TextStyle? mutedStyle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pctVsCapital = (cap != null && cap! > 0 && gain != null)
        ? (gain! / cap!) * 100.0
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.capitalLabel, style: mutedStyle?.copyWith(fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    cap != null && cap! > 0
                        ? '${StrategieGestionRisqueFormat.formatMoneyTotal(cap!)} $sym'
                        : _kEmDash,
                    style: titleStyle?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.labelGain, style: mutedStyle?.copyWith(fontSize: 11)),
                        const SizedBox(width: 2),
                        CompositedTransformTarget(
                          link: commissionLayerLink,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onOpenCommission,
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  LucideIcons.settings,
                                  size: 13,
                                  color: DashboardTokens.labelGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gain != null
                        ? '${gain! >= 0 ? '+' : '-'}${StrategieGestionRisqueFormat.formatMoneyTwoDecimals(gain!.abs())} $sym'
                        : _kEmDash,
                    style: titleStyle?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: gain == null
                          ? DashboardTokens.muted
                          : gain == 0
                              ? DashboardTokens.onMatteEmphasis
                              : (gain! > 0
                                  ? DashboardTokens.accent
                                  : DashboardTokens.negative),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l.ajouterTradeCommissionFeesLabel}: ${StrategieGestionRisqueFormat.formatMoneyTwoDecimals(commission)} $sym',
                    style: mutedStyle?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: DashboardTokens.labelGrey,
                        ) ??
                        const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: DashboardTokens.labelGrey,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!positionEnCours && !breakeven && sortieVide) ...[
          const SizedBox(height: 6),
          Text(
            l.ajouterTradeCapitalGainEnterExitToShowPnl,
            style: mutedStyle?.copyWith(
              fontSize: 9.5,
              height: 1.25,
            ),
          ),
        ],
        if (cap != null && cap! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    gain != null
                        ? '${StrategieGestionRisqueFormat.formatMoneyTotal(cap! + gain!)} $sym'
                        : _kEmDash,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mutedStyle?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: gain == null
                          ? DashboardTokens.muted
                          : (cap! + gain!) > cap!
                              ? DashboardTokens.accent.withValues(alpha: 0.85)
                              : (cap! + gain!) < cap!
                                  ? DashboardTokens.negative
                                      .withValues(alpha: 0.9)
                                  : DashboardTokens.muted,
                    ),
                  ),
                ),
                if (pctVsCapital != null)
                  Text(
                    l.tradePctOfCapital(
                      '${pctVsCapital >= 0 ? '+' : ''}${pctVsCapital.toStringAsFixed(2).replaceAll('.', ',')}',
                    ),
                    style: mutedStyle?.copyWith(
                      fontSize: 10,
                      color: pctVsCapital == 0
                          ? DashboardTokens.muted
                          : (pctVsCapital > 0
                              ? DashboardTokens.accent.withValues(alpha: 0.85)
                              : DashboardTokens.negative
                                  .withValues(alpha: 0.9)),
                    ),
                  ),
              ],
            ),
          ),
        if (positionEnCours)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l.ajouterTradeCapitalGainOpenPositionNote,
              style: mutedStyle?.copyWith(fontSize: 10),
            ),
          ),
      ],
    );
  }
}



