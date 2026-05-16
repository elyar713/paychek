import 'package:flutter/material.dart';

import 'trade_models.dart';
import 'trade_tokens.dart';

/// Pastilles TAG (FOMO, TILT, …) sous une ligne trade — vues période dépliées.
Widget buildTradePsychTagsRow(TradeListItem t) {
  if (t.psychTags.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final tag in t.psychTags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: TradeTokens.pillInactiveBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TradeTokens.cardBorder),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 0.25,
              ),
            ),
          ),
      ],
    ),
  );
}
