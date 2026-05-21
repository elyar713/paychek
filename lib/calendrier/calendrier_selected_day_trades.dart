import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../trade/trade_models.dart';
import 'calendrier_constants.dart';
import 'calendrier_utils.dart';

/// Trades du jour sélectionné sur la grille (au-dessus de la performance cumulée), repliable.
class CalendrierSelectedDayTradesPanel extends StatefulWidget {
  const CalendrierSelectedDayTradesPanel({
    super.key,
    required this.selectedDay,
    required this.allTrades,
    required this.capSymbol,
    this.onTradeSelected,
    this.onExpandHeaderLockedTap,
  });

  final DateTime selectedDay;
  final List<TradeListItem> allTrades;
  final String capSymbol;
  final void Function(TradeListItem)? onTradeSelected;

  /// Lite : tap sur l’en-tête repli/dépli déclenche le paywall au lieu d’ouvrir la liste.
  final VoidCallback? onExpandHeaderLockedTap;

  @override
  State<CalendrierSelectedDayTradesPanel> createState() =>
      _CalendrierSelectedDayTradesPanelState();
}

class _CalendrierSelectedDayTradesPanelState
    extends State<CalendrierSelectedDayTradesPanel> {
  bool _expanded = true;

  @override
  void didUpdateWidget(CalendrierSelectedDayTradesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldDay = DateTime(
      oldWidget.selectedDay.year,
      oldWidget.selectedDay.month,
      oldWidget.selectedDay.day,
    );
    final newDay = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
    );
    if (oldDay != newDay) {
      _expanded = true;
    }
  }

  void _onHeaderTap() {
    if (widget.onExpandHeaderLockedTap != null) {
      widget.onExpandHeaderLockedTap!();
      return;
    }
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final loc = MaterialLocalizations.of(context);
    final day = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
    );
    final dateTitle = loc.formatFullDate(day);
    final dayTrades = tradesOnCalendarDay(widget.allTrades, day);

    var dayNet = 0.0;
    for (final t in dayTrades) {
      dayNet += t.gainAmount;
    }
    final netColor =
        dayNet > 0 ? kGainText : (dayNet < 0 ? kLossText : kWeekdayColor);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: kCalCardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kCalCardBorderResolved),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onHeaderTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateTitle,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.calDayTradesCount(dayTrades.length),
                            style: GoogleFonts.inter(
                              color: kWeekdayColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (dayTrades.isNotEmpty) ...[
                      Text(
                        formatMoneyWithCurrencySymbol(dayNet, widget.capSymbol),
                        style: GoogleFonts.inter(
                          color: netColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: kWeekdayColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: kCalCardBorderResolved.withValues(alpha: 0.85),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: dayTrades.isEmpty
                  ? Text(
                      l.dashboardEvolutionSparklineHoverNoTrade,
                      style: GoogleFonts.inter(
                        color: kWeekdayColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dayTrades.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: kCalCardBorderResolved.withValues(alpha: 0.85),
                      ),
                      itemBuilder: (context, i) {
                        final t = dayTrades[i];
                        final gain = t.gainAmount;
                        final gainColor = gain > 0
                            ? kGainText
                            : (gain < 0 ? kLossText : kWeekdayColor);
                        final open = widget.onTradeSelected != null
                            ? () => widget.onTradeSelected!(t)
                            : null;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: open,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.pair,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatMoneyWithCurrencySymbol(
                                      gain,
                                      widget.capSymbol,
                                    ),
                                    style: GoogleFonts.inter(
                                      color: gainColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (open != null) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: kWeekdayColor.withValues(alpha: 0.7),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
