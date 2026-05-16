import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../checklist_tokens.dart';

/// Ligne : case Ã  cocher **carrÃ©e** + libellÃ© (carte gris foncÃ©).
/// En mode Ã©dition section ([onLineDelete] non null), la case devient une icÃ´ne supprimer.
class ChecklistItemRow extends StatelessWidget {
  const ChecklistItemRow({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
    this.showDividerBelow = true,
    this.onLineDelete,
    this.editingLabel = false,
    this.labelEditController,
    this.labelFocusNode,
    this.onLabelSubmitted,
    this.onAddLineAfter,
    this.onTapEditLabel,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final bool showDividerBelow;

  /// Si dÃ©fini : mode Â« Modifier Â» â€” carrÃ© remplacÃ© par supprimer la ligne.
  final VoidCallback? onLineDelete;

  /// Saisie du libellÃ© (ex. nouvelle ligne).
  final bool editingLabel;
  final TextEditingController? labelEditController;
  final FocusNode? labelFocusNode;
  final VoidCallback? onLabelSubmitted;

  /// En mode Â« Modifier Â» : bouton + sur la **derniÃ¨re** ligne pour ajouter une ligne.
  final VoidCallback? onAddLineAfter;

  /// En mode Â« Modifier Â» : tap sur le libellÃ© pour le modifier.
  final VoidCallback? onTapEditLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final lineStyle = onLineDelete != null
        ? ChecklistTokens.itemLabelOnCardStyle
        : (checked
            ? ChecklistTokens.itemLabelOnCardStyle.copyWith(
                decoration: TextDecoration.lineThrough,
                decorationColor: ChecklistTokens.itemLabelOnCardStyle.color,
                decorationThickness:
                    ChecklistTokens.itemLabelStrikethroughThickness,
              )
            : ChecklistTokens.itemLabelOnCardStyle);

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: ChecklistTokens.itemRowVerticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onLineDelete != null)
            _LineDeleteButton(onTap: onLineDelete!)
          else
            _SquareCheck(checked: checked),
          const SizedBox(width: ChecklistTokens.itemRowCheckGap),
          Expanded(
            child: editingLabel &&
                    labelEditController != null &&
                    labelFocusNode != null
                ? TextField(
                      controller: labelEditController,
                      focusNode: labelFocusNode,
                      style: ChecklistTokens.itemLabelOnCardStyle,
                      cursorColor: ChecklistTokens.itemLabelOnCardStyle.color,
                      maxLines: null,
                      minLines: 1,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: l.checklistItemHint,
                        hintStyle: ChecklistTokens.itemLabelOnCardStyle.copyWith(
                          color: const Color(0xFF6A6A6A),
                        ),
                      ),
                      onSubmitted: (_) => onLabelSubmitted?.call(),
                    )
                : _buildStaticLabel(lineStyle),
          ),
          if (onAddLineAfter != null) ...[
            const SizedBox(width: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddLineAfter,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.add_rounded,
                    size: 22,
                    color: ChecklistTokens.sectionMenuIconColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        onLineDelete != null
            ? row
            : editingLabel
                ? row
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onChanged(!checked),
                      child: row,
                    ),
                  ),
        if (showDividerBelow)
          Divider(height: 1, thickness: 1, color: ChecklistTokens.dividerOnCard),
      ],
    );
  }

  Widget _buildStaticLabel(TextStyle lineStyle) {
    final content = label.isEmpty
        ? Text(
            '-',
            style: lineStyle.copyWith(color: const Color(0xFF6A6A6A)),
          )
        : Text(label, style: lineStyle);
    if (onTapEditLabel != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapEditLabel,
          child: content,
        ),
      );
    }
    return content;
  }
}

class _LineDeleteButton extends StatelessWidget {
  const _LineDeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 15,
            color: Color(0xFF9A9A9A),
          ),
        ),
      ),
    );
  }
}

class _SquareCheck extends StatelessWidget {
  const _SquareCheck({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked
            ? ChecklistTokens.checkboxCheckedFill
            : Colors.transparent,
        border: Border.all(
          color: checked
              ? ChecklistTokens.checkboxCheckedFill
              : const Color(0xFF3A3A3A),
          width: 1.5,
        ),
      ),
      child: checked
          ? Icon(
              Icons.check,
              size: 12,
              color: ChecklistTokens.checkboxCheckOnFill,
              weight: 900,
            )
          : null,
    );
  }
}



