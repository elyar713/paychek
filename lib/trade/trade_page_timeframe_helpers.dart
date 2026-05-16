part of 'trade_page.dart';

extension _TradePageTimeframeHelpers on _TradePageState {
  List<double> _weekDailyNetForDays(
    List<TradeListItem> items,
    List<DateTime> days,
  ) =>
      tradeDailyNetForDays(items, days);

  List<int> _weekDailyCountForDays(
    List<TradeListItem> items,
    List<DateTime> days,
  ) =>
      tradeDailyCountForDays(items, days);

/// P&L cumulé (fin de chaque jour), un point par jour du mois — pour sparkline.
List<double> _monthCumulativeDailyPnl(
  List<TradeListItem> items,
  DateTime monthStart,
  DateTime nextMonth,
) {
  final n = nextMonth.difference(monthStart).inDays;
  if (n <= 0) return const [];
  final days =
      List<DateTime>.generate(n, (i) => monthStart.add(Duration(days: i)));
  final daily = _weekDailyNetForDays(items, days);
  final out = <double>[];
  var acc = 0.0;
  for (final v in daily) {
    acc += v;
    out.add(acc);
  }
  return out;
}

  DateTime _weekMondayLocal(DateTime dt) => tradeWeekMondayLocal(dt);

String _weekKey(DateTime monday) {
  final d = monday.toLocal();
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Clé stable pour une carte mois (1er jour du mois, local).
String _monthKey(DateTime monthStart) {
  final d = monthStart.toLocal();
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

Widget _weekBars(List<double> values, {List<int>? counts}) {
  final maxAbs = values
      .map((e) => e.abs())
      .fold<double>(0.0, (a, b) => a > b ? a : b);
  final denom = maxAbs <= 0 ? 1.0 : maxAbs;
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      for (var i = 0; i < values.length; i++) ...[
        if (i > 0) const SizedBox(width: 4),
        Builder(
          builder: (context) {
            final traded = (counts != null && i < counts.length)
                ? counts[i] > 0
                : values[i] != 0;
            final c = !traded
                ? const Color(0xFF2A2A2A).withValues(alpha: 0.9)
                : (values[i] < 0
                    ? TradeTokens.lossNeon.withValues(alpha: 0.9)
                    : (values[i] > 0
                        ? TradeTokens.profitNeon.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.9)));
            return Container(
              width: 6,
              height: (10 + 18 * (values[i].abs() / denom)).clamp(10, 28),
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ],
    ],
  );
}

Widget _timeframeWeekRow(BuildContext context, List<TradeListItem> allRaw) {
  // Semaine **actuelle** (lun→…, 5 ou 7 jours selon réglages) : barres + total P&L.
  final days = tradeCurrentWeekDaysLocal(
    tradingDaysPerWeek: TradingWeekScope.of(context).tradingDaysPerWeek,
  );
  final week = _weekDailyNetForDays(allRaw, days);
  final weekCount = _weekDailyCountForDays(allRaw, days);
  final total = week.fold<double>(0.0, (a, b) => a + b);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: TradeTokens.cardBg,
      borderRadius: BorderRadius.circular(TradeTokens.radiusLg),
      border: Border.all(color: TradeTokens.cardBorder),
    ),
    child: Row(
      children: [
        Text(
          AppLocalizations.of(context)!.tradeWeekTitle,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
        ),
        const Spacer(),
        _weekBars(week, counts: weekCount),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppLocalizations.of(context)!.tradeTotalUpper,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TradeTokens.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.6,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              '${_formatMoney(total)}\$',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: total < 0
                        ? TradeTokens.lossNeon
                        : TradeTokens.profitNeon,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1.05,
                  ),
            ),
          ],
        ),
      ],
    ),
  );
}

String _formatDayLabel(BuildContext context, DateTime d) {
  final l = AppLocalizations.of(context)!;
  final local = d.toLocal();
  return '${local.day} ${l.monthName(local.month)}';
}

String _formatMonthLabel(BuildContext context, DateTime d) {
  final l = AppLocalizations.of(context)!;
  return l.monthName(d.toLocal().month);
}

Widget _sessionBar(
  BuildContext context, {
  required String label,
  required int count,
  required int maxCount,
  Color? barColor,
}) {
  final t = Theme.of(context).textTheme;
  final frac = maxCount <= 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
  final c = barColor ?? TradeTokens.profitNeon;
  final track = count <= 0
      ? const Color(0xFF2A2A2A).withValues(alpha: 0.9)
      : c.withValues(alpha: 0.18);
  final fill = c.withValues(alpha: 0.95);
  return Row(
    children: [
      SizedBox(
        width: 74,
        child: Text(
          label,
          style: t.labelSmall?.copyWith(
            color: TradeTokens.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    // Track légèrement teinté pour voir la couleur même à 0.
                    color: track,
                  ),
                ),
                if (frac > 0)
                  FractionallySizedBox(
                    widthFactor: frac,
                    alignment: Alignment.centerLeft,
                    child: ColoredBox(
                      color: fill,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 26,
        child: Text(
          '$count',
          textAlign: TextAlign.right,
          style: t.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ),
    ],
  );
}

Widget _mindsetChip(
  BuildContext context, {
  required IconData icon,
  required String label,
  required int count,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: TradeTokens.pillInactiveBg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: TradeTokens.cardBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.95)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: TradeTokens.textSecondary,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
        ),
      ],
    ),
  );
}

Widget _wlbChip(
  BuildContext context, {
  required String label,
  required int count,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: TradeTokens.pillInactiveBg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: TradeTokens.cardBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.95),
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
        ),
      ],
    ),
  );
}
}
