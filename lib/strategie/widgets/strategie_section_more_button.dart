import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../strategie_tokens.dart';

/// Icône **trois points** (⋮) pour modifier une section « Ma Stratégie »
/// (feuille du bas, actions à brancher).
class StrategieSectionMoreButton extends StatelessWidget {
  const StrategieSectionMoreButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(
        LucideIcons.moreVertical,
        size: 16,
        color: StrategieTokens.labelMuted,
      ),
      onPressed: onPressed,
    );
  }
}
