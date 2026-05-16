import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../strategie_tokens.dart';
import 'strategie_section_more_button.dart';

/// Carte section : bordure + en-tête (icône + titre + menu ⋮).
class StrategieSectionFrame extends StatelessWidget {
  const StrategieSectionFrame({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.titleColor = StrategieTokens.titleGrey,
    this.titleSuffix,
    this.onEdit,
    this.trailingMenu,
    this.titleEditing = false,
    this.titleEditController,
    this.titleFocusNode,
    this.onTitleSubmitted,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
    this.backgroundColor,
  });

  final IconData leadingIcon;
  final String title;
  final Color titleColor;
  /// Affiché à droite du titre (ex. jauge confiance sur la page Analyse).
  final Widget? titleSuffix;
  final VoidCallback? onEdit;

  /// Si non null, remplace le bouton ⋮ + [onEdit] (ex. menu dédié « Mes règles »).
  final Widget? trailingMenu;

  /// Édition inline du titre (même idée que la checklist).
  final bool titleEditing;
  final TextEditingController? titleEditController;
  final FocusNode? titleFocusNode;
  final VoidCallback? onTitleSubmitted;

  final Widget child;
  final EdgeInsets padding;

  /// Si non null, remplace le fond [StrategieTokens.cardBg] (ex. « Mes règles d'or »).
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: backgroundColor == null
          ? StrategieTokens.sectionDecoration()
          : BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(StrategieTokens.radiusLg),
              border: Border.all(color: StrategieTokens.cardBorder.withValues(alpha: 0.55)),
            ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(leadingIcon, size: 18, color: titleColor),
                const SizedBox(width: 8),
                Expanded(
                  child: titleEditing &&
                          titleEditController != null &&
                          titleFocusNode != null
                      ? TextField(
                          controller: titleEditController,
                          focusNode: titleFocusNode,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: titleColor,
                          ),
                          cursorColor: titleColor,
                          maxLines: 1,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => onTitleSubmitted?.call(),
                        )
                      : Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: titleColor,
                          ),
                        ),
                ),
                if (titleSuffix != null) ...[
                  const SizedBox(width: 6),
                  titleSuffix!,
                ],
                if (trailingMenu != null)
                  trailingMenu!
                else if (onEdit != null)
                  StrategieSectionMoreButton(onPressed: onEdit!),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
