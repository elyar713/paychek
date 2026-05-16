import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../calendrier/calendrier_utils.dart';
import '../../questionnaire/user_capital_scope.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../../trade/trade_journal_helper.dart';
import '../../trade/trade_journal_scope.dart';
import '../../l10n/app_localizations.dart';
import '../../web/paychek_web_tokens.dart';
import '../capital_evolution_computed.dart';
import '../dashboard_tokens.dart';

/// Meilleur trade / plus grosse perte sur **tout** le journal (indépendant de la période du graphique).
class DashboardTradeExtremesRow extends StatelessWidget {
  const DashboardTradeExtremesRow({
    super.key,
    required this.onOpenTradeById,
    this.compact = false,
    this.spacing = 12,
  });

  final ValueChanged<String> onOpenTradeById;

  /// Blocs meilleur/pire plus compacts (carte évolution capitale avec sparkline élargie).
  final bool compact;

  /// Entre les deux tuiles (`compact` utilise souvent 8).
  final double spacing;

  static String _fmt(double? v, String sym) {
    if (v == null) return '\u2014';
    return formatMoneyWithCurrencySymbol(v, sym);
  }

  @override
  Widget build(BuildContext context) {
    final store = TradeJournalScope.of(context);
    final cap = UserCapitalScope.of(context);
    final pf = UserPortfolioScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([store, cap, pf]),
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        final allRaw = activeJournalTradesOrDemo(context);
        final ext = tradeBestAndWorst(allRaw);
        final sym = pf.effectiveCurrencySymbol(cap);

        final positive =
            kIsWeb ? PaychekWebTokens.accentMint : DashboardTokens.accent;
        return Row(
          children: [
            Expanded(
              child: _cell(
                context,
                label: l.dashboardBestTradeLabel,
                value: _fmt(ext.best, sym),
                valueColor: positive,
                subtitle: ext.bestTrade?.pair,
                enabled: ext.bestTrade != null,
                onTap: ext.bestTrade == null
                    ? null
                    : () => onOpenTradeById(ext.bestTrade!.id),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _cell(
                context,
                label: l.dashboardWorstLossLabel,
                value: _fmt(ext.worst, sym),
                valueColor: ext.worstTrade != null
                    ? DashboardTokens.negative
                    : DashboardTokens.muted,
                subtitle: ext.worstTrade?.pair,
                enabled: ext.worstTrade != null,
                onTap: ext.worstTrade == null
                    ? null
                    : () => onOpenTradeById(ext.worstTrade!.id),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cell(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
    String? subtitle,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    final double labelPx = compact
        ? (kIsWeb ? 7.5 : 7.0)
        : 9.0;
    final double valuePx =
        compact ? (kIsWeb ? 11.5 : 11.0) : 14.0;
    final double subPx =
        compact ? (kIsWeb ? 9.0 : 8.0) : 11.0;
    final padH = compact ? (kIsWeb ? 8.0 : 7.0) : 12.0;
    final padV = compact ? (kIsWeb ? 6.0 : 6.0) : 12.0;
    final gapLabel = compact ? (kIsWeb ? 4.0 : 3.0) : 6.0;
    final gapSub = compact ? 3.0 : 4.0;
    final radius = compact ? (kIsWeb ? 8.0 : 9.0) : 12.0;

    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: kIsWeb
                ? PaychekWebTokens.textGray500
                : DashboardTokens.labelGrey,
            fontSize: labelPx,
            fontWeight: FontWeight.w700,
            letterSpacing: kIsWeb ? (compact ? 0.75 : 1.0) : 0.6,
          ),
        ),
        SizedBox(height: gapLabel),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: valuePx,
            height: 1.05,
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          SizedBox(height: gapSub),
          Text(
            subtitle.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: kIsWeb
                  ? PaychekWebTokens.textGray500
                  : DashboardTokens.muted,
              fontSize: subPx,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    return Material(
      color: kIsWeb ? const Color(0xFF0D0D0D) : DashboardTokens.cardBoxBg,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: kIsWeb
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: PaychekWebTokens.cardBorder.withValues(alpha: 0.85),
                ),
              )
            : null,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: padH, vertical: padV),
            child: child,
          ),
        ),
      ),
    );
  }
}
