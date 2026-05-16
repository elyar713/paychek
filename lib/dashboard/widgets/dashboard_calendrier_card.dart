import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../calendrier/calendrier_constants.dart';
import '../../calendrier/calendrier_grid.dart';
import '../../calendrier/calendrier_month_info.dart';
import '../../calendrier/calendrier_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../questionnaire/user_capital_scope.dart';
import '../../reglage/paychek_prefs_scope.dart';
import '../../reglage/user_portfolio_scope.dart';
import '../../trade/trade_journal_scope.dart';
import '../capital_evolution_computed.dart';
import 'dashboard_cumulative_sparkline.dart';

/// Même calendrier que [CalendrierPage] : navigation mois, stats du mois, courbe cumulée (comme tableau de bord), [CalendrierGrid].
class DashboardCalendrierCard extends StatefulWidget {
  const DashboardCalendrierCard({
    super.key,
    this.onOpenTradeById,
    this.liteInteractionLocked = false,
    this.onLiteInteractionLockedTap,
  });

  final ValueChanged<String>? onOpenTradeById;
  final bool liteInteractionLocked;
  final VoidCallback? onLiteInteractionLockedTap;

  @override
  State<DashboardCalendrierCard> createState() => _DashboardCalendrierCardState();
}

class _DashboardCalendrierCardState extends State<DashboardCalendrierCard> {
  late DateTime _focusedMonth;
  DateTime? _selected;
  double? _monthlyObjective;

  static const _kMonthlyObjectiveBase = 'calendrier_monthly_objective';
  static String get _kMonthlyObjective =>
      paychekScopedPrefsKey(_kMonthlyObjectiveBase);

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _focusedMonth = DateTime(n.year, n.month);
    _selected = DateTime(n.year, n.month, n.day);
    _loadObjective();
  }

  Future<void> _loadObjective() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getDouble(_kMonthlyObjective);
    if (mounted) {
      setState(() => _monthlyObjective = val);
    }
  }

  Future<void> _showObjectiveDialog(String capSymbol) async {
    final controller = TextEditingController(
      text: _monthlyObjective?.toStringAsFixed(2) ?? '',
    );
    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: const Color(0xFF0F0F0F),
          title: Text(
            l.calMonthlyObjectiveTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '${l.calAmountLabel} ($capSymbol)',
              labelStyle: const TextStyle(color: kWeekdayColor),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kWeekdayColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.cancel, style: const TextStyle(color: kWeekdayColor)),
            ),
            TextButton(
              onPressed: () {
                final val = double.tryParse(controller.text);
                Navigator.of(context).pop(val);
              },
              child: Text(l.ok, style: const TextStyle(color: kGainText)),
            ),
          ],
        );
      },
    );
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kMonthlyObjective, result);
      setState(() => _monthlyObjective = result);
    }
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  int _leadingBlankDays(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final firstColDart =
        loc.firstDayOfWeekIndex == 0 ? 7 : loc.firstDayOfWeekIndex;
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    return ((first.weekday - firstColDart) % 7 + 7) % 7;
  }

  @override
  Widget build(BuildContext context) {
    final store = TradeJournalScope.of(context);
    final pf = UserPortfolioScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([store, pf]),
      builder: (context, _) {
        final trades = store.itemsForPortfolio(pf.activePortfolioId);
        final loc = MaterialLocalizations.of(context);
        final daysInMonth =
            DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
        final leading = _leadingBlankDays(context);
        final today = DateTime.now();
        final pnlByDay = netPnlByEntryDay(trades);
        final tradeCountByDay = countTradesByEntryDay(trades);

        final titleStyle = GoogleFonts.inter(
          color: kTitleColor,
          fontSize: kTitleFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          height: 1,
        );

        final monthTradesList = trades
            .where((t) =>
                t.entreeAt.year == _focusedMonth.year &&
                t.entreeAt.month == _focusedMonth.month)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    color: kWeekdayColor,
                    size: kNavIconSize,
                  ),
                  onPressed: _prevMonth,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
                Expanded(
                  child: Text(
                    loc.formatMonthYear(_focusedMonth).toUpperCase(),
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chevron_right,
                    color: kWeekdayColor,
                    size: kNavIconSize,
                  ),
                  onPressed: _nextMonth,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final capStore = UserCapitalScope.of(context);
                final capSymbol = capStore.currencySymbol;
                return CalendrierMonthInfo(
                  monthTradesList: monthTradesList,
                  monthlyObjective: _monthlyObjective,
                  onShowObjectiveDialog: widget.liteInteractionLocked
                      ? () => widget.onLiteInteractionLockedTap?.call()
                      : () => _showObjectiveDialog(capSymbol),
                );
              },
            ),
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final capStore = UserCapitalScope.of(context);
                final sym = pf.effectiveCurrencySymbol(capStore);
                final curve = CapitalEvolutionComputed.forFocusedCalendarMonth(
                  trades,
                  _focusedMonth,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.calCumulativePerformanceTitle,
                      style: GoogleFonts.inter(
                        color: kWeekdayColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DashboardCumulativeSparkline(
                      spots: curve.spots,
                      spotContexts: curve.spotContexts,
                      minY: curve.minY,
                      maxY: curve.maxY,
                      height: 96,
                      currencySymbol: sym,
                      onOpenTradeById: widget.onOpenTradeById,
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
            CalendrierGrid(
              focusedMonth: _focusedMonth,
              selected: _selected,
              today: today,
              pnlByDay: pnlByDay,
              tradeCountByDay: tradeCountByDay,
              leadingBlankDays: leading,
              daysInMonth: daysInMonth,
              languageCode: Localizations.localeOf(context).languageCode,
              firstDayOfWeekIndex: loc.firstDayOfWeekIndex,
              onDaySelected: (date) => setState(() => _selected = date),
            ),
          ],
        );
      },
    );
  }
}
