import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../ajouter_trade/ajouter_trade_asset_class.dart';
import '../ajouter_trade/ajouter_trade_page_non_respect_labels.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../questionnaire/user_capital_scope.dart';
import '../reglage/user_portfolio_scope.dart';
import '../reglage/user_portfolio_store.dart';
import '../reglage/user_portfolio_models.dart';
import '../strategie/strategie_gestion_risque_storage.dart';
import '../strategie/strategie_horaires_sessions_storage.dart';
import '../strategie/strategie_realtime_notifier.dart';
import '../checklist/checklist_models.dart';
import '../checklist/checklist_sections_storage.dart';
import 'performance_custom_lens_storage.dart';
import '../strategie/strategie_mes_regles_storage.dart';
import '../strategie/strategie_setups_store.dart';
import '../trade/trade_discipline_day_snapshot.dart';
import '../trade/trade_models.dart';
import '../trade/trade_plan_analysis.dart';
import '../trade/trade_journal_helper.dart';
import '../trade/trade_journal_scope.dart';
import '../trade/trade_journal_store.dart';
import 'performance_locale_copy.dart';
import 'performance_analysis.dart' hide Trade;
import 'performance_export_pdf.dart';
import 'performance_trade_model.dart';
import 'performance_journal_adapter.dart';
import 'performance_kpi_sync.dart';
import 'performance_period_filter.dart';
import 'performance_widget_chart.dart';
import 'performance_widget_model.dart';
import 'performance_widget_series.dart';
import 'performance_strategie_warnings.dart';
import 'performance_widget_storage.dart';
import 'performance_custom_lens_card.dart';
import 'performance_custom_lens_model.dart';
import 'performance_paychek_lens_section.dart';
import 'performance_tokens.dart';

part 'performance_page_state.dart';
part 'performance_page_ui_header_global.dart';
part 'performance_page_ui_lens_discipline.dart';
part 'performance_page_ui_daily_journal.dart';
part 'performance_page_ui_duration.dart';
part 'performance_page_ui_horaires.dart';
part 'performance_page_ui_news.dart';
part 'performance_page_ui_bottom.dart';
part 'performance_page_ui_custom_lens.dart';

/// Cartes / sections — style OLED ([PerformanceTokens]).
BoxDecoration _performanceSectionDecoration() =>
    PerformanceTokens.sectionDecoration();

/// Page « Performance » — mise en page responsive + cartes unifiées.
class PerformancePage extends StatefulWidget {
  const PerformancePage({
    super.key,
    this.onNavigateToDashboard,
    this.onCloseAsTab,
    this.onEditTrade,
    this.liteFreemiumRestricted = false,
    this.onLiteFreemiumRestrictedTap,
  });

  final VoidCallback? onNavigateToDashboard;
  final VoidCallback? onCloseAsTab;

  /// Ouvre le trade dans Ajouter trade (fourni par le shell dashboard).
  final ValueChanged<TradeListItem>? onEditTrade;
  final bool liteFreemiumRestricted;
  final VoidCallback? onLiteFreemiumRestrictedTap;

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}
