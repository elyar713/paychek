import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../checklist/checklist_page_controller.dart';
import '../l10n/app_localizations.dart';
import '../performance/performance_locale_copy.dart';
import '../widgets/paychek_page_header.dart';
import '../l10n/app_localizations_month.dart';
import '../dashboard/widgets/timeframe_pills.dart';
import '../dashboard/widgets/donut_ring.dart';
import '../questionnaire/user_capital_scope.dart';
import '../reglage/trading_week_scope.dart';
import '../reglage/user_portfolio_scope.dart';
import '../shared/month_pdf_helper.dart';
import 'trade_journal_helper.dart';
import 'trade_journal_scope.dart';
import 'trade_session.dart';
import 'trade_card.dart';
import 'trade_export_pdf.dart';
import 'trade_filter_pills.dart';
import 'trade_models.dart';
import 'trade_psych_tags_chips.dart';
import 'trade_summary_bar.dart';
import 'trade_stats.dart';
import 'trade_tokens.dart';
import 'trade_week_utils.dart';

part 'trade_page_build.dart';
part 'trade_page_build_cards.dart';
part 'trade_page_core.dart';
part 'trade_page_misc_widgets.dart';
part 'trade_page_timeframe_helpers.dart';
part 'trade_page_timeframe_day_ui.dart';
part 'trade_page_timeframe_day_row.dart';
part 'trade_page_week_performance.dart';
part 'trade_page_timeframe_week_ui.dart';
part 'trade_page_timeframe_week_row.dart';
part 'trade_page_timeframe_month_ui.dart';
part 'trade_page_timeframe_month_row.dart';

/// Onglet **Trade** : rÃ©sumÃ© 3 colonnes, filtres type pilule, liste (dÃ©mo â‰¤ 3).
class TradePage extends StatefulWidget {
  const TradePage({
    super.key,
    required this.checklistController,
    required this.onEditTrade,
    this.openTradeIdNotifier,
  });

  final ChecklistPageController checklistController;
  final ValueChanged<TradeListItem> onEditTrade;

  /// Depuis le dashboard (meilleur / pire trade) : ouvre lâ€™onglet puis dÃ©plie ce trade.
  final ValueNotifier<String?>? openTradeIdNotifier;

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  int _filterIndex = 0;
  /// Comme le dashboard : 0=1D, 1=1W, 2=1M, 3=ALL (filtre liste / vues cartes).
  int _timeframeIndex = 0;
  String? _expandedDayKey; // 'YYYY-MM-DD' (cards en mode D)
  String? _expandedWeekKey; // 'YYYY-MM-DD' (lundi de la semaine)
  final Map<String, int?> _weekSelectedDayIndexByKey = {};
  String? _expandedMonthKey; // 'YYYY-MM-01' (1er jour du mois)
  String? _expandedTradeId;
  String? _expandedOpenPositionId;
  String? _pairFilter;
  final ScrollController _scrollController = ScrollController();

  /// ClÃ©s stables pour [Scrollable.ensureVisible] (Ã©vite des [GlobalKey] recrÃ©Ã©s Ã  chaque build).
  final Map<String, GlobalKey> _tradeKeysById = <String, GlobalKey>{};

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  void _onOpenTradeIdNotifier() {
    final id = widget.openTradeIdNotifier?.value;
    if (id == null || id.isEmpty) return;
    widget.openTradeIdNotifier!.value = null;
    _focusTradeFromExternal(id);
  }

  void _focusTradeFromExternal(String tradeId) {
    _safeSetState(() {
      _expandedTradeId = tradeId;
      _timeframeIndex = 3; // ALL : retrouver le trade dans la liste plate
      _filterIndex = 0;
      _pairFilter = null;
      _expandedDayKey = null;
      _expandedWeekKey = null;
      _expandedMonthKey = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final k = _tradeKeysById[tradeId];
        final ctx = k?.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            alignment: 0.12,
          );
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openTradeIdNotifier?.addListener(_onOpenTradeIdNotifier);
  }

  @override
  void didUpdateWidget(TradePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.openTradeIdNotifier != widget.openTradeIdNotifier) {
      oldWidget.openTradeIdNotifier?.removeListener(_onOpenTradeIdNotifier);
      widget.openTradeIdNotifier?.addListener(_onOpenTradeIdNotifier);
    }
  }

  @override
  void dispose() {
    widget.openTradeIdNotifier?.removeListener(_onOpenTradeIdNotifier);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTradePage(context);
  }
}




