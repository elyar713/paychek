import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../checklist_prompts.dart';
import '../checklist_tokens.dart';
import 'checklist_section_enable_toggle.dart';

/// IcÃ´ne + titre + menu â‹¯ (Ã‰diter / Supprimer).
class ChecklistSectionHeaderRow extends StatelessWidget {
  const ChecklistSectionHeaderRow({
    super.key,
    required this.title,
    this.onMenuSelected,
    this.sectionEnabled = true,
    this.onSectionEnabledChanged,
    this.allowDelete = true,
    this.editingTitle = false,
    this.titleEditController,
    this.titleFocusNode,
    this.onTitleSubmitted,
    this.onTitleInteraction,
  });

  final String title;
  final ValueChanged<String>? onMenuSelected;
  final bool sectionEnabled;
  final ValueChanged<bool>? onSectionEnabledChanged;
  final bool allowDelete;

  /// Ã‰dition inline du titre (sans dialog).
  final bool editingTitle;
  final TextEditingController? titleEditController;
  final FocusNode? titleFocusNode;
  final VoidCallback? onTitleSubmitted;

  /// Tap ou saisie sur le champ titre (compte comme Â« interaction Â» pour valider).
  final VoidCallback? onTitleInteraction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.fact_check_outlined,
          size: 18,
          color: ChecklistTokens.sectionTitleOnCardStyle.color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: editingTitle &&
                  titleEditController != null &&
                  titleFocusNode != null
              ? TextField(
                  controller: titleEditController,
                  focusNode: titleFocusNode,
                  style: ChecklistTokens.sectionTitleOnCardStyle,
                  cursorColor: ChecklistTokens.sectionTitleOnCardStyle.color,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: l.checklistEditSectionHint,
                    hintStyle: ChecklistTokens.sectionTitleOnCardStyle.copyWith(
                      color: const Color(0xFF6A6A6A),
                    ),
                  ),
                  onTap: () => onTitleInteraction?.call(),
                  onChanged: (_) => onTitleInteraction?.call(),
                  onSubmitted: (_) => onTitleSubmitted?.call(),
                )
              : Text(
                  title.toUpperCase(),
                  style: ChecklistTokens.sectionTitleOnCardStyle,
                ),
        ),
        if (onSectionEnabledChanged != null)
          ChecklistSectionEnableToggle(
            value: sectionEnabled,
            onChanged: onSectionEnabledChanged!,
            tooltip: sectionEnabled
                ? l.checklistSectionToggleOff
                : l.checklistSectionToggleOn,
          ),
        if (onSectionEnabledChanged != null && onMenuSelected != null)
          const SizedBox(width: 2),
        if (onMenuSelected != null)
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz_rounded,
              size: 22,
              color: ChecklistTokens.sectionMenuIconColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
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
            onSelected: onMenuSelected,
            itemBuilder: (context) => [
              if (!editingTitle)
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
                enabled: allowDelete,
                padding: ChecklistTokens.sectionPopupMenuItemPadding,
                value: ChecklistPrompts.menuActionDelete,
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: allowDelete
                          ? const Color(0xFFE53935)
                          : ChecklistTokens.sectionPopupMenuItemStyle.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.delete,
                      style: ChecklistTokens.sectionPopupMenuItemStyle.copyWith(
                        color: allowDelete
                            ? const Color(0xFFE57373)
                            : const Color(0xFF5A5A5A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}



