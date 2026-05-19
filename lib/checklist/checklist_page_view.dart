import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../l10n/checklist_localizations.dart';
import '../widgets/paychek_page_header.dart';
import 'checklist_export_pdf.dart';
import 'checklist_item_schedule.dart';
import 'checklist_page_controller.dart';
import 'checklist_tokens.dart';
import 'widgets/checklist_add_section_button.dart';
import 'widgets/checklist_item_row.dart';
import 'widgets/checklist_pdf_export_chip.dart';
import 'widgets/checklist_daily_calendar_section.dart';
import 'widgets/checklist_section_card.dart';
import 'checklist_progress_ring.dart';

/// Page checklist : en-tête + PDF à droite, anneau centré sous le texte, grille large ou colonne.
class ChecklistPageView extends StatelessWidget {
  const ChecklistPageView({
    super.key,
    required this.controller,
    required this.onBack,
    this.liteFreemiumRestricted = false,
    this.onLiteFreemiumRestrictedTap,
  });

  final ChecklistPageController controller;
  final VoidCallback onBack;
  final bool liteFreemiumRestricted;
  final VoidCallback? onLiteFreemiumRestrictedTap;

  static const double _wideBreakpoint = 960;

  /// Sur web / large : maximum de cartes par rangée (évite une seule colonne très longue).
  static const int _wideSectionsPerRow = 3;

  /// Anneau sous le titre : plus grand que la pastille header (56), bien visible au centre.
  static const double _heroRingSize = 104;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final displaySections = c.sectionsSortedBySchedule;
    final n = displaySections.length;
    final l = AppLocalizations.of(context)!;

    Widget sectionCard(int i, {required bool inlineRowLayout}) {
      final section = displaySections[i];
      final sectionDisplayTitle =
          checklistSectionTitle(l, section.id, section.title);

      Widget itemRow(int j, {required bool editing}) {
        final item = section.items[j];
        final rowChecked = item.isCompletedForCurrentPeriod();
        final expired = item.isExpiredMissed();
        return ChecklistItemRow(
          label: checklistItemLabel(l, item.id, item.label),
          checked: rowChecked,
          expiredMissed: expired,
          onChanged: (v) => c.toggleItem(section.id, item.id, v),
          schedule: item.schedule ?? const ChecklistItemSchedule(),
          onScheduleChanged: editing
              ? (sched) => c.updateItemSchedule(section.id, item.id, sched)
              : null,
          onSectionEditInteract:
              editing ? c.markSectionEditInteraction : null,
          onLineDelete: editing
              ? () => c.removeItemFromSection(section.id, item.id)
              : null,
          editingLabel: c.editingItemId == item.id,
          labelEditController: c.itemLabelEditController,
          labelFocusNode: c.itemLabelFocusNode,
          onLabelSubmitted: c.commitItemLabelEdit,
          onTapEditLabel: c.editingItemId == item.id
              ? null
              : () => c.startEditItemLabel(section.id, item.id),
          showDividerBelow: j < section.items.length - 1,
        );
      }

      return c.editingSectionId == section.id
          ? ChecklistSectionCard(
                key: c.sectionEditCardKey,
                inlineRowLayout: inlineRowLayout,
                sectionTitle: sectionDisplayTitle,
                titleEditing: true,
                titleEditController: c.sectionTitleEditController,
                titleFocusNode: c.sectionTitleFocusNode,
                onTitleSubmitted: c.commitSectionTitleEdit,
                onTitleInteraction: c.markSectionEditInteraction,
                onMenuSelected: (v) =>
                    c.onSectionMenu(section.id, v, context),
                children: [
                  for (var j = 0; j < section.items.length; j++)
                    itemRow(j, editing: true),
                  _sectionAddLineRow(
                    onInteract: c.markSectionEditInteraction,
                    onTap: () => c.addLineToSection(section.id),
                  ),
                ],
              )
          : ChecklistSectionCard(
              inlineRowLayout: inlineRowLayout,
              sectionTitle: sectionDisplayTitle,
              titleEditing: false,
              titleEditController: c.sectionTitleEditController,
              titleFocusNode: c.sectionTitleFocusNode,
              onTitleSubmitted: c.commitSectionTitleEdit,
              onMenuSelected: (v) =>
                  c.onSectionMenu(section.id, v, context),
              children: [
                for (var j = 0; j < section.items.length; j++)
                  itemRow(j, editing: false),
              ],
            );
    }

    return ColoredBox(
      color: DashboardTokens.scaffoldMatte,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hPad = PaychekPageHeader.horizontalPad(constraints.maxWidth);
            final maxBody = math.min(
              1180.0,
              math.max(0.0, constraints.maxWidth - 2 * hPad),
            );
            final wide = constraints.maxWidth >= _wideBreakpoint;

            Widget sectionBlock() {
              if (wide && n > 0) {
                final rows = <Widget>[];
                for (var start = 0; start < n; start += _wideSectionsPerRow) {
                  final end = math.min(start + _wideSectionsPerRow, n);
                  rows.add(
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = start; i < end; i++) ...[
                            if (i > start) const SizedBox(width: 12),
                            Expanded(
                              child: sectionCard(i, inlineRowLayout: true),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                  if (end < n) {
                    rows.add(const SizedBox(height: ChecklistTokens.sectionGap));
                  }
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rows,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < n; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i < n - 1 ? ChecklistTokens.sectionGap : 0,
                      ),
                      child: RepaintBoundary(
                        child: sectionCard(i, inlineRowLayout: false),
                      ),
                    ),
                ],
              );
            }

            final scroll = CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PaychekPageHeader(
                        onBack: onBack,
                        title: l.checklistPageTitle,
                        subtitle: l.checklistIntroBody,
                        subtitleMaxLines: 2,
                        maxContentWidth: 1180,
                        trailing: ChecklistPdfExportChip(
                          onTap: liteFreemiumRestricted
                              ? () =>
                                  onLiteFreemiumRestrictedTap?.call()
                              : () => exportChecklistPdf(context, c),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 20),
                        child: Center(
                          child: ChecklistProgressRing(
                            percent: c.checklistCompletionPercent,
                            size: _heroRingSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxBody),
                        child: sectionBlock(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      ChecklistTokens.sectionToAddButtonGap,
                      hPad,
                      0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxBody),
                        child: ChecklistAddSectionButton(
                          onPressed: () =>
                              c.addSection(l.checklistDefaultNewSection),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxBody),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: ChecklistTokens.cardBg,
                            borderRadius: BorderRadius.circular(
                              ChecklistTokens.cardRadius,
                            ),
                            border: Border.all(
                              color: ChecklistTokens.sectionCardBorder,
                              width: ChecklistTokens.sectionCardBorderWidth,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                            child: ChecklistDailyCalendarSection(
                              controller: c,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );

            if (c.editingSectionId == null) return scroll;

            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (e) {
                if (c.isPointerOnEditingSectionCard(e.position)) return;
                c.finishSectionEditFromOutsideTap();
              },
              child: scroll,
            );
          },
        ),
      ),
    );
  }
}

/// Ligne « + » fixe en bas d’une section en mode Modifier.
Widget _sectionAddLineRow({
  required VoidCallback onTap,
  VoidCallback? onInteract,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: ChecklistTokens.itemRowVerticalPadding,
    ),
    child: Row(
      children: [
        const SizedBox(width: 22),
        const SizedBox(width: ChecklistTokens.itemRowCheckGap),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: (_) => onInteract?.call(),
            onTap: onTap,
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
    ),
  );
}
