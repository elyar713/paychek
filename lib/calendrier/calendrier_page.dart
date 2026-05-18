import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard/dashboard_tokens.dart';
import '../reglage/paychek_prefs_scope.dart';
import '../reglage/user_portfolio_scope.dart';
import '../trade/trade_journal_helper.dart';
import '../trade/trade_journal_scope.dart';
import '../trade/trade_models.dart';
import '../shared/month_pdf_helper.dart';
import '../questionnaire/user_capital_scope.dart';
import '../performance/performance_locale_copy.dart';
import '../web/paychek_web_tokens.dart';
import '../widgets/paychek_page_header.dart';
import 'calendrier_constants.dart';
import 'calendrier_utils.dart';
import 'calendrier_month_info.dart';
import 'calendrier_grid.dart';
import 'calendrier_selected_day_trades.dart';
import 'calendrier_sparkline_chart.dart';
import 'calendrier_month_pills.dart';

class CalendrierPage extends StatefulWidget {
  const CalendrierPage({
    super.key,
    this.onNavigateToDashboard,
    this.onNavigateToTrade,
    this.onAddTrade,
    this.liteFreemiumRestricted = false,
    this.onLiteFreemiumRestrictedTap,
  });

  final VoidCallback? onNavigateToDashboard;
  final void Function(TradeListItem)? onNavigateToTrade;
  final VoidCallback? onAddTrade;
  final bool liteFreemiumRestricted;
  final VoidCallback? onLiteFreemiumRestrictedTap;

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

class _CalendrierPageState extends State<CalendrierPage> {
  late DateTime _focusedMonth;
  DateTime? _selected;
  double? _monthlyObjective;

  static const double _wideBreakpoint = 960;

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
          backgroundColor: kCalCardSurface,
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

  Future<void> _exportMonthPdf({
    required BuildContext context,
    required List<TradeListItem> monthTrades,
    required String capSymbol,
    required double? initialCapital,
  }) async {
    await exportMonthPdf(
      context: context,
      monthStart: _focusedMonth,
      monthTrades: monthTrades,
      initialCapital: initialCapital,
      filenamePrefix: 'calendrier_month',
    );
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
        final l = AppLocalizations.of(context)!;
        final trades = activeJournalTradesOrDemo(context);
        final loc = MaterialLocalizations.of(context);
        final daysInMonth =
            DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
        final leading = _leadingBlankDays(context);
        final today = DateTime.now();
        final pnlByDay = netPnlByEntryDay(trades);
        final tradeCountByDay = countTradesByEntryDay(trades);

        final monthTradesList = trades
            .where((t) =>
                t.entreeAt.year == _focusedMonth.year &&
                t.entreeAt.month == _focusedMonth.month)
            .toList();

        final capStore = UserCapitalScope.of(context);
        final capSymbol = pf.effectiveCurrencySymbol(capStore);
        final initialCapital = pf.effectiveCapitalAmount(capStore);

        final grid = CalendrierGrid(
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
        );

        final selectedDayNorm = _selected != null
            ? DateTime(_selected!.year, _selected!.month, _selected!.day)
            : DateTime(today.year, today.month, today.day);

        final dayTradesPanel = CalendrierSelectedDayTradesPanel(
          selectedDay: selectedDayNorm,
          allTrades: trades,
          capSymbol: capSymbol,
          onTradeSelected: widget.onNavigateToTrade,
        );

        final performancePanel = CalendrierPerformancePanel(
          pnlByDay: pnlByDay,
          daysInMonth: daysInMonth,
          capSymbol: capSymbol,
          focusedMonth: _focusedMonth,
          tradeCountByDay: tradeCountByDay,
          allTrades: trades,
          initialCapital: initialCapital,
          monthlyObjective: _monthlyObjective,
          onExportMonthPdf: () => _exportMonthPdf(
            context: context,
            monthTrades: monthTradesList,
            capSymbol: capSymbol,
            initialCapital: initialCapital,
          ),
          onTradeSelected: widget.onNavigateToTrade,
          liteInteractionLocked: widget.liteFreemiumRestricted,
          onLiteInteractionLockedTap: widget.onLiteFreemiumRestrictedTap,
        );

        final monthPillsBar = SizedBox(
          height: 150,
          child: CalendrierMonthPills(
            allTrades: trades,
            currentMonth: _focusedMonth,
            capSymbol: capSymbol,
            initialCapital: initialCapital,
            monthlyObjective: _monthlyObjective,
            onMonthSelected: (m) => setState(() => _focusedMonth = m),
          ),
        );

        final monthTitleStyle = GoogleFonts.plusJakartaSans(
          color: DashboardTokens.onMatteEmphasis,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        );

        final monthChip = DecoratedBox(
          decoration: BoxDecoration(
            color: kCalCardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kCalCardBorderResolved),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: kWeekdayColor, size: 20),
                onPressed: _prevMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  loc.formatMonthYear(_focusedMonth).toUpperCase(),
                  style: monthTitleStyle,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: kWeekdayColor, size: 20),
                onPressed: _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        );

        final calSub = perf6(
          Localizations.localeOf(context).languageCode,
          'Vue mensuelle, objectifs et trades du jour.',
          'Monthly view, goals, and daily trades.',
          'Vista mensual, objetivos y operaciones del día.',
          'Monatsansicht, Ziele und Trades des Tages.',
          'Vista mensal, metas e trades do dia.',
          '월별 보기, 목표, 일별 트레이드.',
        );

        final bg = kIsWeb ? PaychekWebTokens.scaffoldBg : Colors.black;

        return ColoredBox(
          color: bg,
          child: SafeArea(
            minimum: EdgeInsets.zero,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaychekPageHeader(
                    onBack: widget.onNavigateToDashboard,
                    reserveLeadingWidthWhenNoBack:
                        widget.onNavigateToDashboard == null,
                    title: l.calPageTitle,
                    subtitle: calSub,
                    maxContentWidth: 1180,
                    trailing: monthChip,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      PaychekPageHeader.horizontalPad(
                        MediaQuery.sizeOf(context).width,
                      ),
                      0,
                      PaychekPageHeader.horizontalPad(
                        MediaQuery.sizeOf(context).width,
                      ),
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!widget.liteFreemiumRestricted) ...[
                          Builder(
                            builder: (context) {
                              final sym =
                                  UserCapitalScope.of(context).currencySymbol;
                              return CalendrierMonthInfo(
                                monthTradesList: monthTradesList,
                                monthlyObjective: _monthlyObjective,
                                onShowObjectiveDialog: () =>
                                    _showObjectiveDialog(sym),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: widget.liteFreemiumRestricted
                        ? Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: kCalendarBodyMaxWidth,
                              ),
                              child: grid,
                            ),
                          )
                        : LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = kIsWeb &&
                            constraints.maxWidth >= _wideBreakpoint;

                        if (wide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 12,
                                      child: SingleChildScrollView(
                                        physics: const ClampingScrollPhysics(),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 520,
                                            ),
                                            child: grid,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 28),
                                    Expanded(
                                      flex: 11,
                                      child: SingleChildScrollView(
                                        physics: const ClampingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            dayTradesPanel,
                                            const SizedBox(height: 16),
                                            performancePanel,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              monthPillsBar,
                            ],
                          );
                        }

                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: kCalendarBodyMaxWidth,
                                  ),
                                  child: grid,
                                ),
                              ),
                              const SizedBox(height: 20),
                              dayTradesPanel,
                              const SizedBox(height: 16),
                              performancePanel,
                              const SizedBox(height: 16),
                              monthPillsBar,
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
            ),
          ),
        );
      },
    );
  }
}
