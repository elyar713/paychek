import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../trade/trade_models.dart';
import 'calendrier_constants.dart';
import 'calendrier_utils.dart';

/// Liste compacte des trades dont l’entrée est le [selectedDay] (à afficher à côté du calendrier).
class CalendrierSelectedDayTradesPanel extends StatelessWidget {
  const CalendrierSelectedDayTradesPanel({
    super.key,
    required this.selectedDay,
    required this.allTrades,
    required this.capSymbol,
    this.onTradeSelected,
  });

  final DateTime selectedDay;
  final List<TradeListItem> allTrades;
  final String capSymbol;
  final void Function(TradeListItem)? onTradeSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final loc = MaterialLocalizations.of(context);
    final day =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final dateTitle = loc.formatFullDate(day);
    final dayTrades = tradesOnCalendarDay(allTrades, day);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: kCalCardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kCalCardBorderResolved),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 10),
          if (dayTrades.isNotEmpty)
            ListView.separated(
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
                final gainColor =
                    gain > 0 ? kGainText : (gain < 0 ? kLossText : kWeekdayColor);
                final open =
                    onTradeSelected != null
                        ? () => onTradeSelected!(t)
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
                            formatMoneyWithCurrencySymbol(gain, capSymbol),
                            style: GoogleFonts.inter(
                              color: gainColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
