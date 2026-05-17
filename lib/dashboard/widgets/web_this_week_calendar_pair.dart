import 'package:flutter/material.dart';

import '../../web/web_dashboard_checklist_analyse_pair.dart';
import 'dashboard_calendrier_card.dart';

/// Bas de page web : carte **Calendrier** (pleine largeur ou empilée si étroit).
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
    return WebDashboardPairedCard(
      child: SizedBox(
        width: double.infinity,
        child: DashboardCalendrierCard(
          onOpenTradeById: liteInteractionLocked ? null : onOpenTradeById,
          liteInteractionLocked: liteInteractionLocked,
          onLiteInteractionLockedTap: onLiteInteractionLockedTap,
        ),
      ),
    );
  }
}
