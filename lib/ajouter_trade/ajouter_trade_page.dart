/// Page **Ajouter un trade** : saisie instrument, gain estimé, discipline, stratégie.
///
/// Découpage : `part` (overlays, UI shell / discipline / web, état, extensions CSV…)
/// dans `ajouter_trade_page_*.dart` (cible ≈ 300 lignes par fichier ; discipline ~680).
library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../checklist/checklist_page_controller.dart';
import '../dashboard/dashboard_tokens.dart';
import '../questionnaire/user_capital_scope.dart';
import '../reglage/user_portfolio_scope.dart';
import '../reglage/paychek_csv_import_log.dart';
import '../reglage/paychek_user_firestore.dart';
import '../analyse/analyse_default_demo_seed.dart';
import '../analyse/analyse_realtime_notifier.dart';
import '../analyse/analyse_report_snapshot.dart';
import '../analyse/analyse_reports_storage.dart';
import '../etat_mental/mental_state_controller.dart';
import '../strategie/strategie_setups_store.dart';
import '../strategie/widgets/strategie_setup_card.dart';
import '../strategie/widgets/strategie_setup_cards_content.dart';
import '../reglage/trial_access_prefs.dart' show AccountEntitlementSnapshot;
import '../trade/trade_discipline_day_snapshot.dart';
import '../trade/trade_journal_scope.dart';
import '../trade/trade_journal_store.dart';
import '../trade/trade_lite_monthly_limit.dart';
import '../trade/trade_models.dart';
import '../web/paychek_web_tokens.dart';
import 'ajouter_trade_web_top_bar.dart';
import 'ajouter_trade_mt_statement_import.dart';
import 'ajouter_trade_actifs.dart';
import 'ajouter_trade_custom_actifs_storage.dart';
import 'ajouter_trade_favorite_actif_storage.dart';
import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_import_asset_class.dart';
import '../performance/performance_locale_copy.dart';
import '../widgets/paychek_page_header.dart';
import 'ajouter_trade_page_capital_gain_panel.dart';
import 'ajouter_trade_page_gain_math.dart';
import 'ajouter_trade_page_instrument_card.dart';
import 'ajouter_trade_page_non_respect_choix_list.dart';
import 'ajouter_trade_non_respect_generic_list.dart';
import 'ajouter_trade_page_strategie_section.dart';
import 'ajouter_trade_psych_tags_card.dart';
import 'ajouter_trade_screenshot_section.dart';
import 'ajouter_trade_csv_section.dart';
import 'ajouter_trade_discipline_mindset_summary.dart';
import 'ajouter_trade_discipline_sections_separators.dart';
import 'ajouter_trade_discipline_settings_sheet.dart';
import 'ajouter_trade_discipline_respect_line.dart';
import 'ajouter_trade_page_non_respect_labels.dart';
import 'ajouter_trade_checklist_feedback_menu.dart';
import 'ajouter_trade_etat_moment_feedback_menu.dart';
import 'ajouter_trade_plan_analyse_feedback_menu.dart';
import 'ajouter_trade_plan_analyse_feedback_items.dart';
import 'ajouter_trade_plan_analyse_menu.dart';
import 'ajouter_trade_plan_analyse_section.dart';
import 'ajouter_trade_strategie_feedback_panel.dart';
import 'ajouter_trade_strategie_picker_mobile.dart';
import 'ajouter_trade_shell_scope.dart';
import 'ajouter_trade_side.dart';
import 'ajouter_trade_widgets.dart';

part 'ajouter_trade_page_overlay_funcs.dart';
part 'ajouter_trade_page_ui_shell.dart';
part 'ajouter_trade_page_ui_discipline.dart';
part 'ajouter_trade_page_ui_wide_web.dart';
part 'ajouter_trade_page_state_psych.dart';
part 'ajouter_trade_page_state_csv.dart';
part 'ajouter_trade_page_state_edit.dart';
part 'ajouter_trade_page_state_save.dart';
part 'ajouter_trade_page_state_dialogs.dart';
part 'ajouter_trade_page_discipline_pct.dart';
part 'ajouter_trade_page_state.dart';

/// Onglet central **Ajouter** : saisie d’un trade (structure prête à être branchée).
///
/// [onBack] : retour explicite vers l’accueil (même idée que [ChecklistPage]).
class AjouterTradePage extends StatefulWidget {
  const AjouterTradePage({
    super.key,
    required this.checklistController,
    required this.shellBodyIndex,
    this.onBack,
    this.onNavigateToTrade,
    this.editTrade,
    this.liteFreemiumRestricted = false,
    this.onLiteFreemiumRestrictedTap,
    this.accountEntitlement,
  });

  final ChecklistPageController checklistController;

  /// Index d’onglet du dashboard (0–4) — ferme les overlays quand ≠ 2.
  final ValueNotifier<int> shellBodyIndex;
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToTrade;
  final ValueNotifier<TradeListItem?>? editTrade;

  /// Après essai **Lite** : pas d’accès CSV, screenshot, ni blocs principe / feeling / stratégie / plan.
  final bool liteFreemiumRestricted;

  /// Affiche le paywall Pro (obligatoire si [liteFreemiumRestricted] est vrai).
  final VoidCallback? onLiteFreemiumRestrictedTap;

  /// Statut Pro (abonnement) — plafond mensuel trades hors Pro ; `null` = pas encore chargé (on applique le plafond).
  final AccountEntitlementSnapshot? accountEntitlement;

  @override
  State<AjouterTradePage> createState() => _AjouterTradePageState();

  /// Réinitialise le formulaire lorsque l’onglet Ajouter est quitté ([DashboardPage]).
  /// Ne peut pas passer par une extension + `dynamic` : l’appel dynamique ne résout pas les extensions.
  static void resetDraft(GlobalKey<State<AjouterTradePage>> key) {
    final s = key.currentState;
    if (s is _AjouterTradePageState) {
      s._resetForNextTrade();
    }
  }
}
