import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

/// En-tête du dialogue « Réglages position » (titre + fermeture).
class AjouterTradeQuantiteSettingsHeader extends StatelessWidget {
  const AjouterTradeQuantiteSettingsHeader({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 4),
      child: Row(
        children: [
          Icon(
            LucideIcons.settings,
            size: 16,
            color: DashboardTokens.accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.ajouterTradePositionSettingsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: DashboardTokens.onMatteEmphasis,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
            ),
          ),
          IconButton(
            tooltip: l.ajouterTradeImagePickerClose,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            onPressed: onClose,
            icon: Icon(
              Icons.close,
              size: 20,
              color: DashboardTokens.muted,
            ),
          ),
        ],
      ),
    );
  }
}
