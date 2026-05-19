import 'package:flutter/material.dart';

import '../../dashboard/dashboard_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../checklist_item_schedule.dart';
import '../checklist_item_schedule_summary.dart';
import '../checklist_tokens.dart';
import 'checklist_schedule_calendar_button.dart';

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
    this.onSectionEditInteract,
    this.schedule,
    this.onScheduleChanged,
    this.expiredMissed = false,
  });

  final String label;
  final bool checked;

  /// Échéance passée sans coche (hebdo / date) — ligne grisée, non cliquable.
  final bool expiredMissed;
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

  /// En mode Â« Modifier Â» : avant tap poubelle / libellÃ© (évite sortie d’édition).
  final VoidCallback? onSectionEditInteract;

  final ChecklistItemSchedule? schedule;
  final ValueChanged<ChecklistItemSchedule>? onScheduleChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final baseLabelStyle = expiredMissed
        ? ChecklistTokens.itemLabelExpiredStyle
        : ChecklistTokens.itemLabelOnCardStyle;
    final lineStyle = onLineDelete != null
        ? baseLabelStyle
        : (checked
            ? baseLabelStyle.copyWith(
                decoration: TextDecoration.lineThrough,
                decorationColor: baseLabelStyle.color,
                decorationThickness:
                    ChecklistTokens.itemLabelStrikethroughThickness,
              )
            : baseLabelStyle);

    Widget mainTapTarget = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onLineDelete != null)
          _LineDeleteButton(
            onTap: onLineDelete!,
            onTapDown: onSectionEditInteract,
          )
        else
          _SquareCheck(checked: checked, muted: expiredMissed),
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
      ],
    );

    if (onLineDelete == null && !editingLabel && !expiredMissed) {
      mainTapTarget = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!checked),
          child: mainTapTarget,
        ),
      );
    }

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: ChecklistTokens.itemRowVerticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: mainTapTarget),
          if (onScheduleChanged != null) ...[
            const SizedBox(width: 2),
            ChecklistScheduleCalendarButton(
              schedule: schedule ?? const ChecklistItemSchedule(),
              onScheduleChanged: onScheduleChanged!,
            ),
          ],
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

    final sched = schedule ?? const ChecklistItemSchedule();
    final summary = checklistItemScheduleSummaryLine(context, sched);
    final summaryColor = sched.isNonDailyDisplay
        ? ChecklistTokens.scheduleCustomSummary
        : DashboardTokens.accent.withValues(alpha: 0.92);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 18 + ChecklistTokens.itemRowCheckGap,
            right: 4,
            top: ChecklistTokens.scheduleSummaryPaddingTop,
            bottom: ChecklistTokens.scheduleSummaryPaddingBottom,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ChecklistTokens.scheduleSummaryFontSize,
                height: 1.15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.15,
                color: summaryColor,
              ),
            ),
          ),
        ),
        row,
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
          onTapDown: (_) => onSectionEditInteract?.call(),
          onTap: onTapEditLabel,
          child: content,
        ),
      );
    }
    return content;
  }
}

class _LineDeleteButton extends StatelessWidget {
  const _LineDeleteButton({
    required this.onTap,
    this.onTapDown,
  });

  final VoidCallback onTap;
  final VoidCallback? onTapDown;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: (_) => onTapDown?.call(),
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
            color: ChecklistTokens.sectionProgressRingRed,
          ),
        ),
      ),
    );
  }
}

class _SquareCheck extends StatelessWidget {
  const _SquareCheck({required this.checked, this.muted = false});

  final bool checked;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final borderIdle = muted ? const Color(0xFF2A2A2A) : const Color(0xFF3A3A3A);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked && !muted
            ? ChecklistTokens.checkboxCheckedFill
            : Colors.transparent,
        border: Border.all(
          color: checked && !muted
              ? ChecklistTokens.checkboxCheckedFill
              : borderIdle,
          width: 1.5,
        ),
      ),
      child: checked && !muted
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



