part of 'trade_page.dart';

extension _TradePageWeekPerformance on _TradePageState {
  Widget _weeklyPerformanceWidget(
    BuildContext context, {
    required List<double> values,
    required List<int> counts,
    required double net,
    required int winPct,
    required int? selectedDayIndex,
    required ValueChanged<int> onDaySelected,
  }) {
    final l = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toString();
    final weekDays = tradeCurrentWeekDaysLocal(
      tradingDaysPerWeek: TradingWeekScope.of(context).tradingDaysPerWeek,
    );
    final days = weekDays
        .map((d) => DateFormat.E(localeTag).format(d).toUpperCase())
        .toList();
    final todayIdx = tradeTodayIndexInWeekDays(weekDays);
    final sel = selectedDayIndex;
    final safeSelected =
        sel != null && sel < values.length ? sel : null;
    final maxAbs = values
        .map((e) => e.abs())
        .fold<double>(0.0, (a, b) => a > b ? a : b);
    final denom = maxAbs <= 0 ? 1.0 : maxAbs;
    const maxBar = 56.0;

    Color fillFor(double v, bool traded) {
      if (!traded) return const Color(0xFF2A2A2A);
      if (v < 0) return TradeTokens.lossNeon;
      if (v > 0) return TradeTokens.profitNeon;
      return Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: TradeTokens.cardBg,
        borderRadius: BorderRadius.circular(TradeTokens.radiusLg),
        border: Border.all(color: TradeTokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.dashboardWeekThisWeek,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: TradeTokens.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: l.dashboardWeekResultPrefix,
                            style: TextStyle(
                              color: TradeTokens.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: '${_formatMoney(net)}\$',
                            style: TextStyle(
                              color: net < 0
                                  ? TradeTokens.lossNeon
                                  : (net == 0
                                      ? Colors.white
                                      : TradeTokens.profitNeon),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l.tradeWinrateLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TradeTokens.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    '$winPct%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: maxBar + 22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (i) {
                final v = i < values.length ? values[i] : 0.0;
                final barH = (maxBar * (v.abs() / denom)).clamp(6.0, maxBar);
                final isToday = todayIdx >= 0 && i == todayIdx;
                final isSelected = safeSelected == i;
                final traded = i < counts.length ? counts[i] > 0 : false;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: maxBar,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onDaySelected(i),
                              borderRadius: BorderRadius.circular(8),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  height: barH,
                                  decoration: BoxDecoration(
                                    color: fillFor(v, traded)
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: isSelected
                                        ? Border.all(
                                            color: TradeTokens.mustard,
                                            width: 2,
                                          )
                                        : (isToday
                                            ? Border.all(
                                                color: TradeTokens.mustard
                                                    .withValues(alpha: 0.6),
                                                width: 1.2,
                                              )
                                            : null),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          days[i],
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isSelected
                                        ? TradeTokens.mustard
                                        : (isToday
                                            ? TradeTokens.mustard
                                            : TradeTokens.textSecondary),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
