import 'package:flutter/material.dart';

import '../dashboard_tokens.dart';

/// Cadre section accueil mobile — aligné sur [PerformanceTokens.sectionDecoration].
class DashboardSectionShell extends StatelessWidget {
  const DashboardSectionShell({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? DashboardTokens.cardPadding,
      decoration: DashboardTokens.cardBoxDecoration(),
      child: child,
    );
  }
}
