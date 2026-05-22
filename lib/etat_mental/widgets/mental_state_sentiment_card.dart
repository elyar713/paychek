import 'package:flutter/material.dart';

import '../../analyse/analyse_tokens.dart';
import '../mental_state_tokens.dart';

/// Conteneur carte sombre (bordure) pour une section « sentiment ».
class MentalStateSentimentCard extends StatelessWidget {
  const MentalStateSentimentCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20),
    this.borderless = false,
  });

  final Widget child;

  /// Par défaut [MentalStateTokens.cardBg] ; facteurs : [MentalStateTokens.factorSectionBg].
  final Color? backgroundColor;

  final EdgeInsetsGeometry padding;

  /// Contenu seul (cadre fourni par le parent, ex. [DashboardSectionShell]).
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    if (borderless) {
      return Padding(
        padding: padding,
        child: child,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? MentalStateTokens.cardBg,
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusCard),
        border: Border.all(color: MentalStateTokens.cardBorder),
      ),
      padding: padding,
      child: child,
    );
  }
}
