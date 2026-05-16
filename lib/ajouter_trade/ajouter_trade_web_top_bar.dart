import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../web/paychek_web_tokens.dart';

/// En-tête web : marque + « Enregistrer » + « Enregistrer et suivant » (maquette desktop).
class AjouterTradeWebTopBar extends StatelessWidget {
  const AjouterTradeWebTopBar({
    super.key,
    required this.onSave,
    required this.onSaveAndNext,
    this.onBack,
  });

  final VoidCallback onSave;
  final VoidCallback onSaveAndNext;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final titleSmall = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: 0.6,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 18),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          Icon(
            Icons.candlestick_chart_rounded,
            color: PaychekWebTokens.accentEmerald,
            size: 26,
          ),
          const SizedBox(width: 10),
          Text(l.ajouterTradePageTitle, style: titleSmall),
          const Spacer(),
          FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: PaychekWebTokens.accentEmerald,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PaychekWebTokens.radiusButton),
              ),
            ),
            child: Text(
              l.save,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onSaveAndNext,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: PaychekWebTokens.borderGray800.withValues(alpha: 0.9),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PaychekWebTokens.radiusButton),
              ),
            ),
            child: Text(
              l.ajouterTradeSaveAndNext,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
