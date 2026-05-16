import 'package:flutter/material.dart';

import '../mental_state_tokens.dart';

/// Conteneur carte sombre (bordure) pour une section « sentiment ».
class MentalStateSentimentCard extends StatelessWidget {
  const MentalStateSentimentCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;

  /// Par défaut [MentalStateTokens.cardBg] ; facteurs : [MentalStateTokens.factorSectionBg].
  final Color? backgroundColor;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? MentalStateTokens.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MentalStateTokens.cardBorder),
      ),
      padding: padding,
      child: child,
    );
  }
}
