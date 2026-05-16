part of 'trade_page.dart';

extension _TradePageBuildCards on _TradePageState {
  List<Widget> _buildDayCards(
    List<TradeListItem> allRaw,
    Map<String, GlobalKey> tradeKeys,
  ) {
    DateTime dayStartLocal(DateTime d) {
      final l = d.toLocal();
      return DateTime(l.year, l.month, l.day);
    }

    final map = <DateTime, List<TradeListItem>>{};
    for (final t in allRaw) {
      final d = dayStartLocal(t.entreeAt);
      (map[d] ??= <TradeListItem>[]).add(t);
    }
    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    final shown = days.take(10).toList();
    return [
      for (final d in shown) ...[
        _timeframeDayRow(
          context,
          d,
          map[d] ?? const <TradeListItem>[],
          tradeKeys: tradeKeys,
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _buildWeekCards(
    List<TradeListItem> allRaw,
    Map<String, GlobalKey> tradeKeys,
  ) {
    final map = <DateTime, List<TradeListItem>>{};
    for (final t in allRaw) {
      final m = _weekMondayLocal(t.entreeAt);
      (map[m] ??= <TradeListItem>[]).add(t);
    }
    final weeks = map.keys.toList()..sort((a, b) => b.compareTo(a));
    final shown = weeks.take(12).toList();
    return [
      for (final w in shown) ...[
        _timeframeWeekDetailRow(
          context,
          w,
          List<TradeListItem>.of(map[w] ?? const <TradeListItem>[]),
          tradeKeys: tradeKeys,
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _buildMonthCards(
    List<TradeListItem> allRaw,
    Map<String, GlobalKey> tradeKeys,
  ) {
    DateTime monthStartLocal(DateTime d) {
      final l = d.toLocal();
      return DateTime(l.year, l.month, 1);
    }

    final map = <DateTime, List<TradeListItem>>{};
    for (final t in allRaw) {
      final m = monthStartLocal(t.entreeAt);
      (map[m] ??= <TradeListItem>[]).add(t);
    }
    final months = map.keys.toList()..sort((a, b) => b.compareTo(a));
    final shown = months.take(12).toList();
    return [
      for (final m in shown) ...[
        _timeframeMonthDetailRow(
          context,
          m,
          List<TradeListItem>.of(map[m] ?? const <TradeListItem>[]),
          tradeKeys: tradeKeys,
        ),
        const SizedBox(height: 12),
      ],
    ];
  }
}

