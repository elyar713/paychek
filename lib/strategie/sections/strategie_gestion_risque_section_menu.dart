import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../checklist/checklist_tokens.dart';
import '../strategie_more_menu.dart';
import '../strategie_tokens.dart';

const _grValueModify = 'gr_modify';
const _grValueDisable = 'gr_disable';

/// Menu ⋮ « Gestion du risque » — même présentation que la checklist section.
///
/// En **fonction** pour limiter les échecs de hot reload quand les paramètres changent.
Widget buildStrategieGestionRisquePopupMenu({
  required VoidCallback onModify,
  required VoidCallback onDisableFactors,
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
      if (value == _grValueModify) {
        onModify();
      } else if (value == _grValueDisable) {
        onDisableFactors();
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        padding: ChecklistTokens.sectionPopupMenuItemPadding,
        value: _grValueModify,
        child: Row(
          children: [
            Icon(
              LucideIcons.slidersHorizontal,
              size: 18,
              color: ChecklistTokens.sectionPopupMenuItemStyle.color,
            ),
            const SizedBox(width: 8),
            Text(
              StrategieMoreMenuPrompts.grEditValues(context),
              style: ChecklistTokens.sectionPopupMenuItemStyle,
            ),
          ],
        ),
      ),
      PopupMenuItem(
        padding: ChecklistTokens.sectionPopupMenuItemPadding,
        value: _grValueDisable,
        child: Row(
          children: [
            Icon(
              LucideIcons.power,
              size: 18,
              color: ChecklistTokens.sectionPopupMenuItemStyle.color,
            ),
            const SizedBox(width: 8),
            Text(
              StrategieMoreMenuPrompts.grDisableFactors(context),
              style: ChecklistTokens.sectionPopupMenuItemStyle,
            ),
          ],
        ),
      ),
    ],
  );
}

/// Interrupteur compact par case — facteur actif / inactif.
class StrategieGestionRisqueFactorToggle extends StatelessWidget {
  const StrategieGestionRisqueFactorToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.82,
      alignment: Alignment.center,
      child: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: StrategieTokens.emerald,
        activeTrackColor: StrategieTokens.emerald.withValues(alpha: 0.38),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
