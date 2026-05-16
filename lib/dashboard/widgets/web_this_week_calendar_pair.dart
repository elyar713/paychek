import 'package:flutter/material.dart';

import '../../web/web_dashboard_checklist_analyse_pair.dart';
import 'dashboard_calendrier_card.dart';
import 'weekly_this_week_section.dart';

/// Sous État mental / Stratégie (web) : **Calendrier** | **This week**, 50 % / 50 % en largeur.
class WebThisWeekCalendarPair extends StatelessWidget {
  const WebThisWeekCalendarPair({
    super.key,
    this.onOpenTradeById,
    this.liteInteractionLocked = false,
    this.onLiteInteractionLockedTap,
  });

  final ValueChanged<String>? onOpenTradeById;
  final bool liteInteractionLocked;
  final VoidCallback? onLiteInteractionLockedTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;

        final weekCard = WebDashboardPairedCard(
          child: SizedBox(
            width: double.infinity,
            child: WeeklyThisWeekSection(),
          ),
        );

        final calendarCard = WebDashboardPairedCard(
          child: SizedBox(
            width: double.infinity,
            child: DashboardCalendrierCard(
              onOpenTradeById:
                  liteInteractionLocked ? null : onOpenTradeById,
              liteInteractionLocked: liteInteractionLocked,
              onLiteInteractionLockedTap: onLiteInteractionLockedTap,
            ),
          ),
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: calendarCard,
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: weekCard,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            calendarCard,
            const SizedBox(height: 16),
            weekCard,
          ],
        );
      },
    );
  }
}
