import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../ajouter_trade/ajouter_trade_page_non_respect_labels.dart';
import '../l10n/app_localizations.dart';
import '../analyse/analyse_report_pdf_platform.dart' as pdf_platform;
import '../strategie/strategie_gestion_risque_storage.dart';
import '../strategie/strategie_horaires_sessions_storage.dart';
import '../strategie/strategie_setups_store.dart';
import 'performance_discipline_metrics.dart';
import 'performance_locale_copy.dart';
import 'performance_period_filter.dart';
import 'performance_strategie_warnings.dart';
import 'performance_trade_metrics.dart';
import 'performance_trade_model.dart';

part 'performance_export_pdf_text.dart';
part 'performance_export_pdf_widgets_core.dart';
part 'performance_export_pdf_widgets_rows.dart';
part 'performance_export_pdf_document.dart';

/// Libellés PDF Performance (FR / EN / ES / DE / PT / KO), alignés sur [performancePickLocale].
String _p(Locale locale, String fr, String en, String es, String de, String pt, String ko) =>
    performancePickLocale(locale, fr, en, es, de, pt, ko);

/// True pendant [buildPerformancePdf] si locale coréenne et chargement Noto Sans KR OK.
bool _pdfHangulMode = false;

Future<void> exportPerformancePdf({
  required List<Trade> disciplineTrades,
  required List<Trade> visibleTradesForAssets,
  required PerformancePeriodFilter periodFilter,
  required DateTime anchor,
  DateTime? customStart,
  required List<StrategieSessionPersisted> sessions,
  required StrategieGestionRisqueParams gestionParams,
  double? capitalAmount,
  required int journalItemCount,
  required AppLocalizations l,
  required Locale uiLocale,
}) async {
  try {
    final bytes = await buildPerformancePdf(
      disciplineTrades: disciplineTrades,
      visibleTradesForAssets: visibleTradesForAssets,
      periodFilter: periodFilter,
      anchor: anchor,
      customStart: customStart,
      sessions: sessions,
      gestionParams: gestionParams,
      capitalAmount: capitalAmount,
      journalItemCount: journalItemCount,
      l: l,
      uiLocale: uiLocale,
    );
    final stamp = DateTime.now().toIso8601String().split('T').first;
    final name = 'performance_journal_$stamp.pdf';
    final ok = await pdf_platform.trySaveReportPdfOnPlatform(bytes, name);
    if (!ok && kDebugMode) {
      debugPrint('exportPerformancePdf: enregistrement annule ou echoue');
    }
  } catch (e, st) {
    debugPrint('exportPerformancePdf: $e\n$st');
  }
}
