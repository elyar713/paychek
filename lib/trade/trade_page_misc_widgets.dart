part of 'trade_page.dart';

extension _TradePageMiscWidgets on _TradePageState {
  List<({String pair, int count})> _mostTradedPairs(List<TradeListItem> all) {
    final map = <String, int>{};
    for (final t in all) {
      final p = t.pair.trim();
      if (p.isEmpty) continue;
      map[p] = (map[p] ?? 0) + 1;
    }
    final list = map.entries
        .map((e) => (pair: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  Widget _mostTradedPill(
    BuildContext context,
    String pair,
    int count, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: TradeTokens.pillInactiveBg,
        borderRadius: BorderRadius.circular(TradeTokens.radiusFilter),
        border: Border.all(
          color: selected ? TradeTokens.profitNeon : TradeTokens.cardBorder,
          width: selected ? 1.2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TradeTokens.radiusFilter),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pair,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  _tradesLabel(context, count),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TradeTokens.textDate,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 1.1,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tradesLabel(BuildContext context, int n) {
    final l = AppLocalizations.of(context)!;
    if (n == 0) return l.dashboardTradeCount(0);
    if (n == 1) return l.dashboardTradeOne;
    return l.dashboardTradeCount(n);
  }

  ({double net, int w, int l, int b, int count}) _stats(List<TradeListItem> all) {
    var net = 0.0;
    var w = 0;
    var l = 0;
    var b = 0;
    for (final t in all) {
      net += t.gainAmount;
      if (t.countsAsClosedBreakevenOrFlat) {
        b++;
      } else if (t.countsAsClosedWin) {
        w++;
      } else if (t.countsAsClosedLoss) {
        l++;
      }
    }
    return (net: net, w: w, l: l, b: b, count: all.length);
  }

  Widget _openPositionPill(
    BuildContext context,
    TradeListItem t, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    final loc = AppLocalizations.of(context)!;
    final sideLabel = t.side == TradeSide.achat
        ? loc.tradeSideBuyShort
        : loc.tradeSideSellShort;
    final sideColor =
        t.side == TradeSide.achat ? TradeTokens.profitNeon : TradeTokens.lossNeon;
    final price = (t.prixEntreeLabel ?? '').trim();
    final priceText = price.isEmpty ? '—' : price;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: TradeTokens.pillInactiveBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? TradeTokens.profitNeon : TradeTokens.cardBorder,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.pair,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: sideColor.withValues(alpha: 0.18),
                  borderRadius:
                      BorderRadius.circular(TradeTokens.radiusSideBadge),
                ),
                child: Text(
                  sideLabel,
                  style: TextStyle(
                    color: sideColor.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                priceText,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: TradeTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

