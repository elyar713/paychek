import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../checklist/checklist_tokens.dart';
import '../strategie_more_menu.dart';
import '../strategie_tokens.dart';

const _stValueAdd = 'st_add';
const _stValueModify = 'st_modify';

/// Menu ⋮ « Setups & modèles » : Ajouter / Modifier (crayon + poubelle en mode Modifier).
///
/// Même logique que [buildStrategieHorairesSessionsPopupMenu].
Widget buildStrategieSetupModelesPopupMenu({
  required VoidCallback onAdd,
  required VoidCallback onModify,
}) {
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
      if (value == _stValueAdd) {
        onAdd();
      } else if (value == _stValueModify) {
        onModify();
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        padding: ChecklistTokens.sectionPopupMenuItemPadding,
        value: _stValueAdd,
        child: Row(
          children: [
            Icon(
              Icons.add_rounded,
              size: 18,
              color: ChecklistTokens.sectionPopupMenuItemStyle.color,
            ),
            const SizedBox(width: 8),
            Text(
              StrategieMoreMenuPrompts.hoAjouter(context),
              style: ChecklistTokens.sectionPopupMenuItemStyle,
            ),
          ],
        ),
      ),
      PopupMenuItem(
        padding: ChecklistTokens.sectionPopupMenuItemPadding,
        value: _stValueModify,
        child: Row(
          children: [
            Icon(
              LucideIcons.pencil,
              size: 18,
              color: ChecklistTokens.sectionPopupMenuItemStyle.color,
            ),
            const SizedBox(width: 8),
            Text(
              StrategieMoreMenuPrompts.hoModifier(context),
              style: ChecklistTokens.sectionPopupMenuItemStyle,
            ),
          ],
        ),
      ),
    ],
  );
}
