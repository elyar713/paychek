part of 'trade_page.dart';

extension _TradePageCore on _TradePageState {
  List<String> _tradeFilterLabels(AppLocalizations l) => <String>[
        l.tradeFilterAll,
        l.tradeFilterWinner,
        l.tradeFilterLoser,
        l.tradeFilterBreakeven,
        l.tradeFilterOpenPosition,
      ];

  List<String> _tradeTimeframePillLabels(AppLocalizations l) => <String>[
        l.dashboardTfDay,
        l.dashboardTfWeek,
        l.dashboardTfMonth,
        l.dashboardTfAll,
      ];

  List<TradeListItem> _applyTimeframe(List<TradeListItem> items) {
    // ALL: liste complète.
    if (_timeframeIndex == 3) return items;

    // D: vue "Jour" uniquement (via le dépli). La liste du bas est désactivée,
    // quel que soit la date saisie sur les trades (évite les doublons).
    if (_timeframeIndex == 0) {
      return const <TradeListItem>[];
    }

    // W: vue "Semaines" uniquement (via les déplis). La liste du bas est désactivée,
    // quel que soit l'historique (évite les doublons).
    if (_timeframeIndex == 1) {
      return const <TradeListItem>[];
    }

    // M: la liste reste "ALL" MAIS on enlève les trades du mois courant
    // (ils sont déjà affichés dans le dépli Mois).
    final now = DateTime.now().toLocal();
    final monthStart = DateTime(now.year, now.month, 1);
    return items.where((t) => t.entreeAt.toLocal().isBefore(monthStart)).toList();
  }

  void _scrollToTrade(String tradeId, Map<String, GlobalKey> keys) {
    final k = keys[tradeId];
    final ctx = k?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      alignment: 0.15,
    );
  }

  List<TradeListItem> get _visibleItems {
    final all = activeJournalTradesOrDemo(context);
    List<TradeListItem> out;
    switch (_filterIndex) {
      case 1:
        out = all.where((e) => e.countsAsClosedWin).toList();
        break;
      case 2:
        out = all.where((e) => e.countsAsClosedLoss).toList();
        break;
      case 3:
        out = all.where((e) => e.countsAsClosedBreakevenOrFlat).toList();
        break;
      case 4:
        out = all.where((e) => e.sortieAt == null).toList();
        break;
      default:
        out = all;
    }

    final p = _pairFilter;
    if (p != null) {
      out = out.where((e) => e.pair == p).toList();
    }
    // Le timeframe ne filtre QUE la liste.
    return _applyTimeframe(out);
  }

  int _tradeNumberOfDay(TradeListItem item, List<TradeListItem> items) {
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    final same = items.where((e) => sameDay(e.entreeAt, item.entreeAt)).toList()
      ..sort((a, b) => a.entreeAt.compareTo(b.entreeAt));
    final idx = same.indexWhere((e) => e.id == item.id);
    return idx < 0 ? 1 : idx + 1;
  }

  String _formatMoney(double v) {
    final abs = v.abs();
    final s = abs.toStringAsFixed(2).replaceAll('.', ',');
    final sign = v >= 0 ? '+' : '-';
    return '$sign$s';
  }

  String _formatDateTime(DateTime dt) {
    String p2(int v) => v.toString().padLeft(2, '0');
    final d = p2(dt.day);
    final m = p2(dt.month);
    final y = dt.year.toString().padLeft(4, '0');
    final hh = p2(dt.hour);
    final mm = p2(dt.minute);
    return '$d/$m/$y $hh:$mm';
  }
}

