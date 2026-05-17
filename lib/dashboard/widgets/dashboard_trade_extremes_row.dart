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
    this.mini = false,
    this.vertical = false,
    this.spacing = 12,
  });

  final ValueChanged<String> onOpenTradeById;

  /// Blocs meilleur/pire plus compacts (carte évolution capitale avec sparkline élargie).
  final bool compact;

  /// Encore plus petit (mini-carte semaine, colonne à droite des barres).
  final bool mini;

  /// Meilleur trade au-dessus, grosse perte en dessous (au lieu de côte à côte).
  final bool vertical;

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
        final hideSubtitle = mini && vertical;
        final best = _cell(
          context,
          label: l.dashboardBestTradeLabel,
          value: _fmt(ext.best, sym),
          valueColor: positive,
          subtitle: ext.bestTrade?.pair,
          hideSubtitle: hideSubtitle,
          enabled: ext.bestTrade != null,
          onTap: ext.bestTrade == null
              ? null
              : () => onOpenTradeById(ext.bestTrade!.id),
        );
        final worst = _cell(
          context,
          label: l.dashboardWorstLossLabel,
          value: _fmt(ext.worst, sym),
          valueColor: ext.worstTrade != null
              ? DashboardTokens.negative
              : DashboardTokens.muted,
          subtitle: ext.worstTrade?.pair,
          hideSubtitle: hideSubtitle,
          enabled: ext.worstTrade != null,
          onTap: ext.worstTrade == null
              ? null
              : () => onOpenTradeById(ext.worstTrade!.id),
        );

        if (vertical) {
          if (mini) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                best,
                SizedBox(height: spacing),
                worst,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: best),
              SizedBox(height: spacing),
              Expanded(child: worst),
            ],
          );
        }

        if (mini) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: 112, child: best),
              SizedBox(width: spacing),
              SizedBox(width: 112, child: worst),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: best),
            SizedBox(width: spacing),
            Expanded(child: worst),
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
    bool hideSubtitle = false,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    final miniTile = mini && !vertical;
    /// Mini web ou compact mobile (50 % largeur) : tuile bordée.
    final borderedTile = miniTile || (compact && !kIsWeb && !vertical);
    final double labelPx = borderedTile
        ? 7.0
        : mini
            ? 6.0
            : compact
                ? (kIsWeb ? 7.5 : 7.0)
                : 9.0;
    final double valuePx = borderedTile
        ? 12.0
        : mini
            ? 9.5
            : compact
                ? (kIsWeb ? 11.5 : 11.0)
                : 14.0;
    final double subPx = borderedTile
        ? 8.0
        : mini
            ? 7.0
            : compact
                ? (kIsWeb ? 9.0 : 8.0)
                : 11.0;
    final padH =
        borderedTile ? 10.0 : mini ? 5.0 : compact ? (kIsWeb ? 8.0 : 7.0) : 12.0;
    final padV =
        borderedTile ? 10.0 : mini ? 2.0 : compact ? (kIsWeb ? 6.0 : 6.0) : 12.0;
    final gapLabel =
        borderedTile ? 5.0 : mini ? 2.0 : compact ? (kIsWeb ? 4.0 : 3.0) : 6.0;
    final gapSub = borderedTile ? 4.0 : mini ? 2.0 : compact ? 3.0 : 4.0;
    final radius =
        borderedTile ? 10.0 : mini ? 6.0 : compact ? (kIsWeb ? 8.0 : 9.0) : 12.0;

    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: (mini && vertical) ? 1 : (compact ? 2 : 1),
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
        if (!hideSubtitle && subtitle != null && subtitle.isNotEmpty) ...[
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

    if (borderedTile) {
      final borderColor = kIsWeb
          ? PaychekWebTokens.cardBorder.withValues(alpha: 0.75)
          : DashboardTokens.muted.withValues(alpha: 0.45);
      return Material(
        color: const Color(0xFF0D0D0D),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: InkWell(
            onTap: enabled ? onTap : null,
            hoverColor: Colors.white.withValues(alpha: 0.04),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
              child: child,
            ),
          ),
        ),
      );
    }

    if (mini) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: child,
        ),
      );
    }

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
