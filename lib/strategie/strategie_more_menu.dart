import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import 'strategie_tokens.dart';

// ---------------------------------------------------------------------------
// Menus « Ma Stratégie » : prompts + feuille du bas (Setups).
// Gestion du risque : menu ⋮ — `strategie_gestion_risque_section_menu.dart`.
// Horaires & sessions : menu ⋮ — `strategie_horaires_sessions_section_menu.dart`.
// Setups & modèles : menu ⋮ — `strategie_setup_modeles_section_menu.dart`.
// Mes règles : `strategie_mes_regles_widgets.dart`.
// ---------------------------------------------------------------------------

/// Libellés des feuilles, entrées et textes partagés (dont Mes règles).
abstract final class StrategieMoreMenuPrompts {
  StrategieMoreMenuPrompts._();

  static String sheetSetups(BuildContext context) =>
      AppLocalizations.of(context)!.strategieSheetSetupsTitle;

  static String grEditValues(BuildContext context) =>
      AppLocalizations.of(context)!.checklistMenuEdit;

  static String grDisableFactors(BuildContext context) =>
      AppLocalizations.of(context)!.strategieMenuDisableFactors;

  /// Menu ⋮ Horaires & sessions.
  static String hoAjouter(BuildContext context) =>
      AppLocalizations.of(context)!.navAdd;

  static String hoModifier(BuildContext context) =>
      AppLocalizations.of(context)!.checklistMenuEdit;

  static String suManageModels(BuildContext context) =>
      AppLocalizations.of(context)!.strategieManageTemplates;

  static String suDuplicate(BuildContext context) =>
      AppLocalizations.of(context)!.strategieDuplicateSetup;

  /// Menu ⋮ Mes règles — entrée « Ajouter » ([PopupMenuItem.value]).
  static const mesReglesPopupValueAdd = 'mes_regles_add';
  static String mesReglesMenuAjouter(BuildContext context) =>
      AppLocalizations.of(context)!.navAdd;

  static String mesReglesDraftHint(BuildContext context) =>
      AppLocalizations.of(context)!.strategieMesReglesDraftHint;
}

/// Feuilles du bas (trois points → [StrategieSectionFrame]).
abstract final class StrategieMoreMenuActions {
  StrategieMoreMenuActions._();

  static Future<void> openSetups(BuildContext context) =>
      _showSheet(context, title: StrategieMoreMenuPrompts.sheetSetups(context), items: [
        _MenuSpec(LucideIcons.layers, StrategieMoreMenuPrompts.suManageModels(context)),
        _MenuSpec(LucideIcons.copy, StrategieMoreMenuPrompts.suDuplicate(context)),
      ]);

  static Future<void> _showSheet(
    BuildContext context, {
    required String title,
    required List<_MenuSpec> items,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: StrategieTokens.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(StrategieTokens.radiusLg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: StrategieTokens.labelMuted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                for (final item in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(item.icon, size: 20, color: StrategieTokens.emerald),
                    title: Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuSpec {
  const _MenuSpec(this.icon, this.label);
  final IconData icon;
  final String label;
}
