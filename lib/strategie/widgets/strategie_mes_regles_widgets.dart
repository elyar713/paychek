import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../checklist/checklist_prompts.dart';
import '../../checklist/checklist_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../strategie_more_menu.dart';
import '../strategie_tokens.dart';

/// Menu â‹® et lignes pour la section Â« Mes rÃ¨gles dâ€™or Â».
/// LibellÃ©s : [StrategieMoreMenuPrompts] dans `strategie_more_menu.dart`.

/// Menu â‹® Â« Mes rÃ¨gles dâ€™or Â» : Ã‰diter, Ajouter, Supprimer.
class StrategieMesReglesPopupMenu extends StatelessWidget {
  const StrategieMesReglesPopupMenu({
    super.key,
    required this.onEdit,
    required this.onAdd,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      icon: Icon(
        LucideIcons.moreVertical,
        size: 16,
        color: StrategieTokens.labelMuted,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      menuPadding: EdgeInsets.zero,
      offset: const Offset(-6, 0),
      color: ChecklistTokens.sectionPopupMenuBg,
      elevation: 2,
      shadowColor: Colors.black45,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(ChecklistTokens.sectionPopupMenuRadius),
        side: BorderSide(
          color: ChecklistTokens.sectionCardBorder,
          width: ChecklistTokens.sectionCardBorderWidth,
        ),
      ),
      onSelected: (value) {
        if (value == ChecklistPrompts.menuActionEdit) {
          onEdit();
        } else if (value == StrategieMoreMenuPrompts.mesReglesPopupValueAdd) {
          onAdd();
        } else {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          padding: ChecklistTokens.sectionPopupMenuItemPadding,
          value: ChecklistPrompts.menuActionEdit,
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: ChecklistTokens.sectionPopupMenuItemStyle.color,
              ),
              const SizedBox(width: 8),
              Text(
                l.checklistMenuEdit,
                style: ChecklistTokens.sectionPopupMenuItemStyle,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          padding: ChecklistTokens.sectionPopupMenuItemPadding,
          value: StrategieMoreMenuPrompts.mesReglesPopupValueAdd,
          child: Row(
            children: [
              Icon(
                Icons.add_rounded,
                size: 18,
                color: ChecklistTokens.sectionPopupMenuItemStyle.color,
              ),
              const SizedBox(width: 8),
              Text(
                StrategieMoreMenuPrompts.mesReglesMenuAjouter(context),
                style: ChecklistTokens.sectionPopupMenuItemStyle,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          padding: ChecklistTokens.sectionPopupMenuItemPadding,
          value: ChecklistPrompts.menuActionDelete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: StrategieTokens.riskRed,
              ),
              const SizedBox(width: 8),
              Text(
                l.delete,
                style: ChecklistTokens.sectionPopupMenuItemStyle.copyWith(
                  color: StrategieTokens.riskRed.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ligne brouillon (nouvelle rÃ¨gle depuis le menu â‹® Â« Ajouter Â»).
class StrategieMesReglesDraftRuleLine extends StatelessWidget {
  const StrategieMesReglesDraftRuleLine({
    super.key,
    required this.index,
    required this.controller,
    required this.focusNode,
    this.hintText,
  });

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StrategieTokens.ruleLineCaseBg,
        borderRadius: BorderRadius.circular(StrategieTokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MesReglesIndexBadge(index: index),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: null,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.35,
              ),
              cursorColor: StrategieTokens.emerald,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: hintText ?? StrategieMoreMenuPrompts.mesReglesDraftHint(context),
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: StrategieTokens.labelMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne en mode Ã©dition menu (texte + poubelle).
class StrategieMesReglesEditableRuleLine extends StatelessWidget {
  const StrategieMesReglesEditableRuleLine({
    super.key,
    required this.index,
    required this.controller,
    required this.onDelete,
  });

  final int index;
  final TextEditingController controller;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StrategieTokens.ruleLineCaseBg,
        borderRadius: BorderRadius.circular(StrategieTokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MesReglesIndexBadge(index: index),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.35,
              ),
              cursorColor: StrategieTokens.emerald,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: StrategieTokens.labelMuted,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// Ligne en lecture seule.
class StrategieMesReglesRuleLine extends StatelessWidget {
  const StrategieMesReglesRuleLine({
    super.key,
    required this.index,
    required this.text,
    this.onTap,
  });

  final int index;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StrategieTokens.radiusMd),
        child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StrategieTokens.ruleLineCaseBg,
        borderRadius: BorderRadius.circular(StrategieTokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MesReglesIndexBadge(index: index),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _MesReglesIndexBadge extends StatelessWidget {
  const _MesReglesIndexBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: StrategieTokens.sessionTradeIconBg,
        borderRadius: BorderRadius.circular(StrategieTokens.radiusSm),
      ),
      child: Text(
        '$index',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: StrategieTokens.emerald,
        ),
      ),
    );
  }
}



