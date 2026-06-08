import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../dashboard/dashboard_main_bottom_nav.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';

/// Carte **Note** : commentaire libre sur le trade (optionnel).
class AjouterTradeNoteCard extends StatelessWidget {
  const AjouterTradeNoteCard({
    super.key,
    required this.controller,
    this.focusNode,
    required this.labelStyle,
    required this.mutedStyle,
    this.cardDecoration,
    this.sectionTitleColor,
    this.maxLength = 1500,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextStyle? labelStyle;
  final TextStyle? mutedStyle;
  final BoxDecoration? cardDecoration;
  final Color? sectionTitleColor;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final navClearance = kIsWeb
        ? 24.0
        : DashboardMainBottomNav.totalHeight(mq.padding.bottom);
    final scrollPadding = EdgeInsets.fromLTRB(
      20,
      80,
      20,
      navClearance + mq.viewInsets.bottom + 48,
    );
    final headerStyle = (labelStyle ??
            const TextStyle(
              color: DashboardTokens.onMatteEmphasis,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.35,
            ))
        .copyWith(
          color: sectionTitleColor ?? DashboardTokens.titleGold,
          fontSize: 9,
          letterSpacing: 0.35,
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: cardDecoration ?? DashboardTokens.cardBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.ajouterTradeNoteCardTitle, style: headerStyle),
          const SizedBox(height: 4),
          Text(
            l.ajouterTradeNoteCardHelp,
            style: mutedStyle?.copyWith(fontSize: 10, height: 1.3),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            focusNode: focusNode,
            scrollPadding: scrollPadding,
            maxLines: 4,
            minLines: 3,
            maxLength: maxLength,
            style: const TextStyle(
              color: DashboardTokens.onMatteEmphasis,
              fontSize: 12,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: l.ajouterTradeNoteHint,
              hintStyle: TextStyle(
                color: DashboardTokens.muted.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: DashboardTokens.scaffoldMatte,
              counterStyle: TextStyle(
                color: DashboardTokens.muted,
                fontSize: 10,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: DashboardTokens.cardBoxBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: DashboardTokens.cardBoxBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: DashboardTokens.accent.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
