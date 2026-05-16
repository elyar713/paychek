import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../l10n/checklist_localizations.dart';
import '../checklist/checklist_page_controller.dart';
import '../checklist/checklist_models.dart';
import '../checklist/checklist_tokens.dart';
import '../checklist/widgets/checklist_item_row.dart';
import '../web/paychek_web_tokens.dart';
import 'dashboard_tokens.dart';

typedef _DashboardChecklistPreviewEntry = ({
  String sectionId,
  ChecklistItemData item,
});

/// Limite **mobile / desktop app** : fenêtre glissante sur les lignes non cochées (file globale).
/// Sur **web**, l’aperçu affiche toutes les lignes non cochées (pas de limite).
const int _kDashboardChecklistPreviewMaxUncheckedRowsMobile = 3;

/// Aperçu accueil : hors web, les lignes cochées disparaissent et au plus
/// [_kDashboardChecklistPreviewMaxUncheckedRowsMobile] lignes non cochées.
/// Sur **web** : toutes les lignes (toutes sections), non cochées d’abord puis cochées, pour un
/// aperçu maximal dans la carte ; scroll dans la paire web si besoin.
/// Si la checklist est vide : titre « Checklist » + chevron uniquement.
///
/// [controller] est partagé avec [ChecklistPage] pour que les cases restent synchronisées.
class DashboardChecklistPreview extends StatelessWidget {
  const DashboardChecklistPreview({
    super.key,
    required this.controller,
    required this.onOpenChecklist,
    this.liteInteractionLocked = false,
    this.onLiteInteractionLockedTap,
    this.includeRiskSectionPreview = false,
    this.cardBackgroundColor,
  });

  final ChecklistPageController controller;
  final VoidCallback onOpenChecklist;

  /// En Lite : pas de toggle des cases ; tap → paywall.
  final bool liteInteractionLocked;
  final VoidCallback? onLiteInteractionLockedTap;

  /// Espacements sous l’en-tête « CHECKLIST » (web rail vs mobile compact).
  final bool includeRiskSectionPreview;

  /// Fond derrière le contenu (ex. transparent si la carte est dans un cadre web).
  final Color? cardBackgroundColor;

  /// Toutes les lignes non cochées, dans l’ordre des sections puis des items (liste globale).
  static List<_DashboardChecklistPreviewEntry> _orderedUncheckedEntries(
    List<ChecklistSectionData> sections,
  ) {
    final out = <_DashboardChecklistPreviewEntry>[];
    for (final section in sections) {
      for (final item in section.items) {
        if (!item.checked) {
          out.add((sectionId: section.id, item: item));
        }
      }
    }
    return out;
  }

  /// Web : toutes les lignes (technique, analyse, psy, risque, etc.) — d’abord les non cochées
  /// (même ordre sections/items), puis les cochées, pour remplir l’aperçu au maximum.
  static List<_DashboardChecklistPreviewEntry> _webEntriesUncheckedThenChecked(
    List<ChecklistSectionData> sections,
  ) {
    final unchecked = _orderedUncheckedEntries(sections);
    final checked = <_DashboardChecklistPreviewEntry>[];
    for (final section in sections) {
      for (final item in section.items) {
        if (item.checked) {
          checked.add((sectionId: section.id, item: item));
        }
      }
    }
    return [...unchecked, ...checked];
  }

  static List<_DashboardChecklistPreviewEntry> _previewEntriesSlice(
    List<ChecklistSectionData> sections, {
    required bool limitPreviewRows,
  }) {
    final all = _orderedUncheckedEntries(sections);
    if (!limitPreviewRows) return all;
    if (all.length <= _kDashboardChecklistPreviewMaxUncheckedRowsMobile) return all;
    return all.sublist(0, _kDashboardChecklistPreviewMaxUncheckedRowsMobile);
  }

  static Widget _mobileFlatRows({
    required AppLocalizations l,
    required ChecklistPageController controller,
    required List<ChecklistSectionData> sections,
    required bool liteInteractionLocked,
    required VoidCallback? onLiteInteractionLockedTap,
  }) {
    final entries = _previewEntriesSlice(sections, limitPreviewRows: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var j = 0; j < entries.length; j++)
          ChecklistItemRow(
            label: checklistItemLabel(
              l,
              entries[j].item.id,
              entries[j].item.label,
            ),
            checked: entries[j].item.checked,
            onChanged: liteInteractionLocked
                ? (_) => onLiteInteractionLockedTap?.call()
                : (v) => controller.toggleItem(
                      entries[j].sectionId,
                      entries[j].item.id,
                      v,
                    ),
            showDividerBelow: j < entries.length - 1,
          ),
      ],
    );
  }

  static Widget _webFlatRows({
    required AppLocalizations l,
    required ChecklistPageController controller,
    required List<ChecklistSectionData> sections,
    required bool liteInteractionLocked,
    required VoidCallback? onLiteInteractionLockedTap,
  }) {
    final entries = _webEntriesUncheckedThenChecked(sections);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var j = 0; j < entries.length; j++)
          _WebChecklistCircleRow(
            label: checklistItemLabel(
              l,
              entries[j].item.id,
              entries[j].item.label,
            ),
            checked: entries[j].item.checked,
            onToggle: liteInteractionLocked
                ? () => onLiteInteractionLockedTap?.call()
                : () => controller.toggleItem(
                      entries[j].sectionId,
                      entries[j].item.id,
                      !entries[j].item.checked,
                    ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        final sections = controller.sections;
        final bg = cardBackgroundColor ?? DashboardTokens.scaffoldMatte;
        final headerTap = liteInteractionLocked
            ? () => onLiteInteractionLockedTap?.call()
            : onOpenChecklist;

        if (sections.isEmpty) {
          if (kIsWeb) {
            return ColoredBox(
              color: bg,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      size: 16,
                      color: PaychekWebTokens.textGray500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.dashboardChecklistHeading.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: PaychekWebTokens.textGray500,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: headerTap,
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: PaychekWebTokens.textGray500
                            .withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ColoredBox(
            color: bg,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                    size: 18,
                    color: ChecklistTokens.sectionTitleOnCardStyle.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.dashboardChecklistHeading,
                      style: ChecklistTokens.sectionTitleOnCardStyle,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: headerTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 24,
                          color: ChecklistTokens.sectionTitleOnCardStyle.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final checklistAllDone = controller.totalItems > 0 &&
            controller.checkedItems == controller.totalItems;

        if (checklistAllDone) {
          if (kIsWeb) {
            return ColoredBox(
              color: bg,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist_rounded,
                          size: 16,
                          color: PaychekWebTokens.textGray500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.dashboardChecklistHeading.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: PaychekWebTokens.textGray500,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: headerTap,
                          icon: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: PaychekWebTokens.textGray500
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.dashboardChecklistAllDoneBravo,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: PaychekWebTokens.textGray400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ColoredBox(
            color: bg,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fact_check_outlined,
                        size: 18,
                        color: ChecklistTokens.sectionTitleOnCardStyle.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.dashboardChecklistHeading,
                          style: ChecklistTokens.sectionTitleOnCardStyle,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: headerTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 24,
                              color:
                                  ChecklistTokens.sectionTitleOnCardStyle.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.dashboardChecklistAllDoneBravo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: DashboardTokens.labelGrey.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (kIsWeb) {
          return ColoredBox(
            color: bg,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist_rounded,
                        size: 16,
                        color: PaychekWebTokens.textGray500,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.dashboardChecklistHeading.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: PaychekWebTokens.textGray500,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: headerTap,
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: PaychekWebTokens.textGray500
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: includeRiskSectionPreview ? 12 : 10,
                  ),
                  _webFlatRows(
                    l: l,
                    controller: controller,
                    sections: sections,
                    liteInteractionLocked: liteInteractionLocked,
                    onLiteInteractionLockedTap: onLiteInteractionLockedTap,
                  ),
                ],
              ),
            ),
          );
        }

        return ColoredBox(
          color: bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      size: 18,
                      color: ChecklistTokens.sectionTitleOnCardStyle.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.dashboardChecklistHeading,
                        style: ChecklistTokens.sectionTitleOnCardStyle,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: headerTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 24,
                            color: ChecklistTokens.sectionTitleOnCardStyle.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: includeRiskSectionPreview
                      ? 10
                      : ChecklistTokens.sectionHeaderToItemsGap,
                ),
                _mobileFlatRows(
                  l: l,
                  controller: controller,
                  sections: sections,
                  liteInteractionLocked: liteInteractionLocked,
                  onLiteInteractionLockedTap: onLiteInteractionLockedTap,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pastilles rondes type maquette web : vide gris si faux ; vert + point si coché.
class _WebChecklistCircleRow extends StatelessWidget {
  const _WebChecklistCircleRow({
    required this.label,
    required this.checked,
    required this.onToggle,
  });

  final String label;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _WebCircleMark(checked: checked),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: checked
                          ? PaychekWebTokens.accentMint
                          : PaychekWebTokens.textGray400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebCircleMark extends StatelessWidget {
  const _WebCircleMark({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final outer = checked ? PaychekWebTokens.accentMint : const Color(0xFF6B7280);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: outer, width: 1.5),
        color: Colors.transparent,
      ),
      child: checked
          ? Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PaychekWebTokens.accentMint,
              ),
            )
          : null,
    );
  }
}
