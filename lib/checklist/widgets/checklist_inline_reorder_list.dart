import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/checklist_localizations.dart';
import '../checklist_item_schedule.dart';
import '../checklist_models.dart';
import '../checklist_page_controller.dart';
import '../checklist_reorder_entries.dart';
import '../checklist_tokens.dart';
import 'checklist_item_row.dart';
import 'checklist_section_header_row.dart';

/// Liste aplatie avec poignées, rendue comme les cartes checklist (même page).
class ChecklistInlineReorderList extends StatelessWidget {
  const ChecklistInlineReorderList({
    super.key,
    required this.controller,
    required this.onSectionMenu,
  });

  final ChecklistPageController controller;
  final void Function(String sectionId, String action) onSectionMenu;

  ChecklistSectionData? _sectionById(String id) {
    for (final s in controller.sections) {
      if (s.id == id) return s;
    }
    return null;
  }

  bool _isLastItemInSection(List<ChecklistFlatReorderEntry> flat, int index) {
    if (index < 0 || index >= flat.length) return false;
    if (flat[index] is! ChecklistFlatReorderItem) return false;
    if (index + 1 >= flat.length) return true;
    return flat[index + 1] is ChecklistFlatReorderHeader;
  }

  bool sectionHasToggle(String sectionId) =>
      checklistSectionHasEnableToggle(sectionId);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    final flat = buildChecklistFlatReorderEntries(c.sections);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: flat.length,
          onReorder: (oldIndex, newIndex) {
            final entry = flat[oldIndex];
            if (entry is ChecklistFlatReorderHeader) {
              c.reorderChecklistSectionBlock(
                oldHeaderIndex: oldIndex,
                newIndex: newIndex,
              );
            } else if (entry is ChecklistFlatReorderItem) {
              c.reorderChecklistItem(oldIndex: oldIndex, newIndex: newIndex);
            }
          },
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(animation.value);
                return Transform.scale(
                  scale: 1.0 + 0.015 * t,
                  child: Opacity(
                    opacity: 0.96 + 0.04 * t,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 3 * t,
                      borderRadius:
                          BorderRadius.circular(ChecklistTokens.cardRadius),
                      child: child,
                    ),
                  ),
                );
              },
            );
          },
          itemBuilder: (context, index) {
            final entry = flat[index];
            final child = switch (entry) {
              ChecklistFlatReorderHeader(:final sectionId, :final title) =>
                _HeaderCard(
                  dragIndex: index,
                  title: checklistSectionTitle(l, sectionId, title),
                  section: _sectionById(sectionId),
                  hasItemsBelow: index + 1 < flat.length &&
                      flat[index + 1] is ChecklistFlatReorderItem,
                  onSectionMenu: (a) => onSectionMenu(sectionId, a),
                  onSectionEnabledChanged: sectionHasToggle(sectionId)
                      ? (v) => c.setSectionEnabled(sectionId, v)
                      : null,
                ),
              ChecklistFlatReorderItem(:final sectionId, :final item) =>
                _ItemInCard(
                  dragIndex: index,
                  label: checklistItemLabel(l, item.id, item.label),
                  item: item,
                  sectionActive: checklistSectionIsActive(
                    _sectionById(sectionId) ??
                        ChecklistSectionData(
                          id: sectionId,
                          title: '',
                          items: const [],
                        ),
                  ),
                  isLastInSection: _isLastItemInSection(flat, index),
                ),
            };
            return SizedBox(
              key: switch (entry) {
                ChecklistFlatReorderHeader(:final sectionId) =>
                  ValueKey('hdr_$sectionId'),
                ChecklistFlatReorderItem(:final item) =>
                  ValueKey('itm_${item.id}'),
              },
              width: constraints.maxWidth,
              child: child,
            );
          },
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.dragIndex,
    required this.title,
    required this.section,
    required this.hasItemsBelow,
    required this.onSectionMenu,
    this.onSectionEnabledChanged,
  });

  final int dragIndex;
  final String title;
  final ChecklistSectionData? section;
  final bool hasItemsBelow;
  final ValueChanged<String> onSectionMenu;
  final ValueChanged<bool>? onSectionEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final s = section;
    final sectionActive = s == null || checklistSectionIsActive(s);
    final sectionProtected =
        s != null && checklistSectionIsProtected(s.id);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(ChecklistTokens.cardRadius),
      topRight: const Radius.circular(ChecklistTokens.cardRadius),
      bottomLeft: hasItemsBelow
          ? Radius.zero
          : const Radius.circular(ChecklistTokens.cardRadius),
      bottomRight: hasItemsBelow
          ? Radius.zero
          : const Radius.circular(ChecklistTokens.cardRadius),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: hasItemsBelow ? 0 : 12),
      child: Material(
        color: ChecklistTokens.cardBg,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: ChecklistTokens.sectionCardBorder,
              width: ChecklistTokens.sectionCardBorderWidth,
            ),
          ),
          child: Padding(
            padding: ChecklistTokens.sectionCardPadding.copyWith(
              bottom: hasItemsBelow
                  ? 8
                  : ChecklistTokens.sectionCardPadding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChecklistSectionHeaderRow(
                  title: title,
                  reorderDragIndex: dragIndex,
                  sectionEnabled: sectionActive,
                  onSectionEnabledChanged: onSectionEnabledChanged,
                  allowDelete: !sectionProtected,
                  onMenuSelected: onSectionMenu,
                ),
                if (!hasItemsBelow) ...[
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!
                        .checklistReorderEmptySectionHint,
                    style: ChecklistTokens.itemLabelOnCardStyle.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF6A6A6A),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemInCard extends StatelessWidget {
  const _ItemInCard({
    required this.dragIndex,
    required this.label,
    required this.item,
    required this.sectionActive,
    required this.isLastInSection,
  });

  final int dragIndex;
  final String label;
  final ChecklistItemData item;
  final bool sectionActive;
  final bool isLastInSection;

  @override
  Widget build(BuildContext context) {
    final rowChecked = item.isCompletedForCurrentPeriod();
    final expired = item.isExpiredMissed();

    final radius = isLastInSection
        ? const BorderRadius.only(
            bottomLeft: Radius.circular(ChecklistTokens.cardRadius),
            bottomRight: Radius.circular(ChecklistTokens.cardRadius),
          )
        : BorderRadius.zero;

    return Padding(
      padding: EdgeInsets.only(bottom: isLastInSection ? 12 : 0),
      child: Material(
        color: ChecklistTokens.cardBg,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border(
              left: BorderSide(
                color: ChecklistTokens.sectionCardBorder,
                width: ChecklistTokens.sectionCardBorderWidth,
              ),
              right: BorderSide(
                color: ChecklistTokens.sectionCardBorder,
                width: ChecklistTokens.sectionCardBorderWidth,
              ),
              bottom: isLastInSection
                  ? BorderSide(
                      color: ChecklistTokens.sectionCardBorder,
                      width: ChecklistTokens.sectionCardBorderWidth,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ChecklistTokens.sectionCardPadding.left,
              0,
              ChecklistTokens.sectionCardPadding.right,
              isLastInSection ? 8 : 0,
            ),
            child: ChecklistItemRow(
              label: label,
              checked: rowChecked,
              expiredMissed: expired,
              inactive: !sectionActive,
              reorderDragIndex: dragIndex,
              schedule: item.schedule ?? const ChecklistItemSchedule(),
              showDividerBelow: !isLastInSection,
            ),
          ),
        ),
      ),
    );
  }
}
