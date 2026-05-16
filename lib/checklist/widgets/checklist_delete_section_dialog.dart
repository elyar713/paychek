import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../checklist_tokens.dart';

/// Confirmation de suppression de section â€” mÃªme style visuel que le menu â‹¯.
class ChecklistDeleteSectionDialog extends StatelessWidget {
  const ChecklistDeleteSectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: ChecklistTokens.sectionPopupMenuBg,
      elevation: 2,
      shadowColor: Colors.black45,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(ChecklistTokens.sectionPopupMenuRadius),
        side: BorderSide(
          color: ChecklistTokens.sectionCardBorder,
          width: ChecklistTokens.sectionCardBorderWidth,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.checklistDeleteSectionTitle,
                style: ChecklistTokens.sectionPopupMenuItemStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFCFCFCF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.checklistDeleteSectionBody,
                style: ChecklistTokens.sectionPopupMenuItemStyle,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            ChecklistTokens.sectionPopupMenuItemStyle.color,
                        side: BorderSide(
                          color: ChecklistTokens.sectionCardBorder,
                          width: ChecklistTokens.sectionCardBorderWidth,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        l.cancel,
                        style: ChecklistTokens.sectionPopupMenuItemStyle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: const Color(0xFFECECEC),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        l.delete,
                        style: ChecklistTokens.sectionPopupMenuItemStyle
                            .copyWith(color: const Color(0xFFECECEC)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



