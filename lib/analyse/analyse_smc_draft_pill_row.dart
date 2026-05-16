import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_page_widgets.dart';
import 'analyse_tokens.dart';

/// Pilule compacte + Â« + Â» pour saisir un ajout SMC (comme indicateurs, texte libre).
class AnalyseSmcDraftPillRow extends StatelessWidget {
  const AnalyseSmcDraftPillRow({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onAddTap,
    required this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAddTap;
  final VoidCallback onFieldSubmitted;

  static const double _radius = 12;
  static const double _hPad = 10;
  static const double _vPad = 7;
  static const double _fieldWidth = 120;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Material(
          color: AnalyseTokens.chipBg,
          borderRadius: BorderRadius.circular(_radius),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: _hPad, vertical: _vPad),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: SizedBox(
              width: _fieldWidth,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFFDFDFDF),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 1.2,
                ),
                cursorColor: AnalyseTokens.accentGreen,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: l.analyseDraftLabelHint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                onSubmitted: (_) => onFieldSubmitted(),
                onTapOutside: (_) => focusNode.unfocus(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnalyseSquareIconButton(
          icon: Icons.add_rounded,
          boxSize: 30,
          iconSize: 20,
          onTap: onAddTap,
        ),
      ],
    );
  }
}



