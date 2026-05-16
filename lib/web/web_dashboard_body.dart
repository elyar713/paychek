import 'package:flutter/material.dart';

import 'web_dashboard_config.dart';

/// Corps du [Scaffold] dashboard : sur Web, [leftRail] + onglets ; sinon uniquement les onglets.
class WebDashboardBody extends StatelessWidget {
  const WebDashboardBody({
    super.key,
    required this.useWebRail,
    required this.navTotal,
    required this.bodyIndex,
    required this.tabChildren,
    required this.leftRail,
  });

  final bool useWebRail;
  final double navTotal;
  final int bodyIndex;
  final List<Widget> tabChildren;
  final Widget leftRail;

  @override
  Widget build(BuildContext context) {
    final stack = Padding(
      padding: EdgeInsets.only(bottom: navTotal),
      child: IndexedStack(
        index: bodyIndex,
        sizing: StackFit.expand,
        children: tabChildren,
      ),
    );
    if (!useWebRail) {
      return stack;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        leftRail,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: WebDashboardConfig.mainContentHorizontalPaddingPx,
            ),
            child: stack,
          ),
        ),
      ],
    );
  }
}
