import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../questionnaire/user_capital_scope.dart';
import 'calendrier_constants.dart';
import 'calendrier_utils.dart';

class CalendrierDayCell extends StatelessWidget {
  const CalendrierDayCell({
    super.key,
    required this.day,
    required this.date,
    required this.isSelected,
    required this.isFuture,
    required this.isToday,
    required this.pnlByDay,
    required this.tradeCountByDay,
    required this.onTap,
  });

  final int day;
  final DateTime date;
  final bool isSelected;
  final bool isFuture;
  final bool isToday;
  final Map<int, double> pnlByDay;
  final Map<int, int> tradeCountByDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final digitColor = dayDigitColor(
      date: date,
      pnlByDay: pnlByDay,
      isSelected: isSelected,
      isFuture: isFuture,
      dayColor: kDayColor,
      selectedColor: kDaySelectedColor,
      futureColor: kDayFutureColor,
      futureSelectedColor: kDayFutureSelectedColor,
    );

    final tileColors = dayTileColors(
      date: date,
      pnlByDay: pnlByDay,
      isSelected: isSelected,
      isToday: isToday,
    );

    final dayKeyValue = dayKey(date);
    final tradeCount = tradeCountByDay[dayKeyValue] ?? 0;
    final pnl = pnlByDay[dayKeyValue];
    final capStore = UserCapitalScope.of(context);
    final capSymbol = capStore.currencySymbol;

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDayCellRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kDayCellRadius),
        splashColor: tileColors.bg != null
            ? Colors.white24
            : const Color(0x1A9A9A9A),
        highlightColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: tileColors.bg,
            borderRadius: BorderRadius.circular(kDayCellRadius),
            border: tileColors.border == null
                ? null
                : Border.all(
                    color: tileColors.border!,
                    width: 0.8,
                  ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$day',
                style: dayDigitsStyle(digitColor),
              ),
              if (tradeCount > 0) ...[
                const SizedBox(height: 1),
                Text(
                  l.calDayTradesCount(tradeCount),
                  style: GoogleFonts.inter(
                    fontSize: kDayCellTradeCountFontSize,
                    color: digitColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
              if (pnl != null) ...[
                const SizedBox(height: 0.5),
                Text(
                  formatMoneyWithCurrencySymbol(pnl, capSymbol),
                  style: GoogleFonts.inter(
                    fontSize: kDayCellPnlFontSize,
                    color: digitColor,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
