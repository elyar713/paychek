import 'package:flutter/material.dart';

import '../../calendrier/calendrier_constants.dart';
import '../../calendrier/calendrier_utils.dart';

/// Point de couleur = un setup (même style que la barre de noms de stratégie).
@immutable
class StrategieCalendrierDayMark {
  const StrategieCalendrierDayMark({
    required this.title,
    required this.dotColor,
  });

  final String title;
  final Color dotColor;
}

/// Chiffre du jour + petits points colorés ; infobulle au survol = noms des stratégies marquées.
class StrategieCalendrierDayCell extends StatelessWidget {
  const StrategieCalendrierDayCell({
    super.key,
    required this.day,
    required this.date,
    required this.isSelected,
    required this.isFuture,
    required this.isToday,
    required this.marks,
    required this.strategiePct,
    required this.selectedSetupTitle,
    required this.onToggleSelectedUsage,
    required this.onSelectDay,
  });

  final int day;
  final DateTime date;
  final bool isSelected;
  final bool isFuture;
  final bool isToday;

  /// Setups ayant un jour d’usage enregistré pour cette date (points pleins).
  final List<StrategieCalendrierDayMark> marks;

  /// Pourcentage discipline "Stratégie respectée" (moyenne des trades du jour).
  final double? strategiePct;

  final String selectedSetupTitle;
  final VoidCallback onToggleSelectedUsage;
  final VoidCallback onSelectDay;

  static const Map<int, double> _emptyPnl = {};

  static const double _dotSize = 6;

  String get _hoverMessage {
    if (marks.isEmpty) return '';
    return marks.map((m) => m.title).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final digitColor = dayDigitColor(
      date: date,
      pnlByDay: _emptyPnl,
      isSelected: isSelected,
      isFuture: isFuture,
      dayColor: kDayColor,
      selectedColor: kDaySelectedColor,
      futureColor: kDayFutureColor,
      futureSelectedColor: kDayFutureSelectedColor,
    );

    final tileColors = dayTileColors(
      date: date,
      pnlByDay: _emptyPnl,
      isSelected: isSelected,
      isToday: isToday,
    );

    final inner = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$day',
          style: dayDigitsStyle(digitColor),
        ),
        const SizedBox(height: 1),
        if (!isFuture && strategiePct != null)
          Text(
            '${strategiePct!.round()}%',
            style: dayDigitsStyle(digitColor).copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          )
        else if (!isFuture)
          Text(
            '—',
            style: dayDigitsStyle(digitColor).copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        const SizedBox(height: 3),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 3,
          children: [
            for (final m in marks)
              _DotMark(
                mark: m,
                size: _dotSize,
                onTap: m.title == selectedSetupTitle
                    ? onToggleSelectedUsage
                    : null,
              ),
          ],
        ),
      ],
    );

    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: inner,
    );

    final withTooltip = _hoverMessage.isEmpty
        ? padded
        : Tooltip(
            waitDuration: const Duration(milliseconds: 180),
            message: _hoverMessage,
            child: padded,
          );

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDayCellRadius),
      ),
      child: InkWell(
        onTap: isFuture ? null : onSelectDay,
        borderRadius: BorderRadius.circular(kDayCellRadius),
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
          child: withTooltip,
        ),
      ),
    );
  }
}

class _DotMark extends StatelessWidget {
  const _DotMark({
    required this.mark,
    required this.size,
    this.onTap,
  });

  final StrategieCalendrierDayMark mark;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: mark.dotColor,
        shape: BoxShape.circle,
      ),
    );

    if (onTap == null) {
      return Tooltip(
        message: mark.title,
        waitDuration: const Duration(milliseconds: 150),
        child: dot,
      );
    }

    return Tooltip(
      message: mark.title,
      waitDuration: const Duration(milliseconds: 150),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: dot,
        ),
      ),
    );
  }
}
