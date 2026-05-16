import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_month.dart';
import '../trade/trade_models.dart';
import 'calendrier_constants.dart';
import 'calendrier_utils.dart';

class CalendrierMonthPills extends StatefulWidget {
  const CalendrierMonthPills({
    super.key,
    required this.allTrades,
    required this.currentMonth,
    required this.capSymbol,
    required this.onMonthSelected,
    required this.initialCapital,
    required this.monthlyObjective,
  });

  final List<TradeListItem> allTrades;
  final DateTime currentMonth;
  final String capSymbol;
  final ValueChanged<DateTime> onMonthSelected;
  final double? initialCapital;
  final double? monthlyObjective;

  @override
  State<CalendrierMonthPills> createState() => _CalendrierMonthPillsState();
}

class _CalendrierMonthPillsState extends State<CalendrierMonthPills> {
  final ScrollController _scrollController = ScrollController();

  static const double _scrollStep = 220;

  void _nudgeScroll(double delta) {
    if (!_scrollController.hasClients) return;
    final p = _scrollController.position;
    final target = (p.pixels + delta).clamp(0.0, p.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final currentMonthDate = DateTime(now.year, now.month, 1);
    final months = <DateTime>[];
    
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(currentMonthDate.year, currentMonthDate.month - i, 1);
      months.add(month);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: () => _nudgeScroll(-_scrollStep),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: Icon(Icons.chevron_left, color: kWeekdayColor, size: 28),
            tooltip: MaterialLocalizations.of(context).previousPageTooltip,
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final monthTrades = widget.allTrades
                  .where(
                    (t) =>
                        t.entreeAt.year == month.year &&
                        t.entreeAt.month == month.month,
                  )
                  .toList();

              final isSelected = month.year == widget.currentMonth.year &&
                  month.month == widget.currentMonth.month;

              return Padding(
                padding:
                    EdgeInsets.only(right: index < months.length - 1 ? 12 : 0),
                child: _buildMonthCard(
                  context,
                  l,
                  month,
                  monthTrades,
                  isSelected,
                ),
              );
            },
          ),
        ),
        Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: () => _nudgeScroll(_scrollStep),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: Icon(Icons.chevron_right, color: kWeekdayColor, size: 28),
            tooltip: MaterialLocalizations.of(context).nextPageTooltip,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthCard(
    BuildContext context,
    AppLocalizations l,
    DateTime month,
    List<TradeListItem> trades,
    bool isSelected,
  ) {
    final net = trades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
    final count = trades.length;
    
    final tradingDays = trades.map((t) => t.entreeAt.day).toSet().length;
    final averagePerDay = tradingDays > 0 ? net / tradingDays : 0.0;
    
    final capitalIncrease = (widget.initialCapital != null && widget.initialCapital! > 0)
        ? (net / widget.initialCapital!) * 100.0
        : null;
    
    final objectiveProgress = (widget.monthlyObjective != null && widget.monthlyObjective! > 0)
        ? (net / widget.monthlyObjective!) * 100.0
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onMonthSelected(month),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? kCalMonthPillSelected : kCalCardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? kCalCardBorderResolved
                  : kCalCardBorderResolved.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.monthName(month.month),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                l.calPnlShort,
                formatMoneyWithCurrencySymbol(net, widget.capSymbol),
                net >= 0 ? kGainText : kLossText,
              ),
              const SizedBox(height: 4),
              if (capitalIncrease != null)
                _buildInfoRow(l.calCapitalChangePct, '${capitalIncrease >= 0 ? '+' : ''}${capitalIncrease.toStringAsFixed(1)}%', capitalIncrease >= 0 ? kGainText : kLossText),
              if (capitalIncrease != null) const SizedBox(height: 4),
              _buildInfoRow(
                l.calAveragePerDay,
                formatMoneyWithCurrencySymbol(averagePerDay, widget.capSymbol),
                averagePerDay >= 0 ? kGainText : kLossText,
              ),
              const SizedBox(height: 4),
              if (objectiveProgress != null)
                _buildInfoRow(l.calObjectiveShort, '${objectiveProgress.toStringAsFixed(0)}%', objectiveProgress >= 100 ? kGainText : kWeekdayColor),
              if (objectiveProgress != null) const SizedBox(height: 4),
              _buildInfoRow(l.tradeTradesListHeading, '$count', kWeekdayColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: kWeekdayColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: valueColor,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
