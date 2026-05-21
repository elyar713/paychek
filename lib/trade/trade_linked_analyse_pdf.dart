import 'package:flutter/material.dart';

import '../analyse/analyse_report_pdf_platform.dart' as pdf_platform;
import 'trade_models.dart';

/// Ouvre / partage le PDF Mon Analyse joint au trade.
Future<void> openTradeLinkedAnalysePdf(
  BuildContext context,
  TradeListItem item,
) async {
  final bytes = item.linkedAnalysePdfBytes;
  if (bytes == null || bytes.isEmpty) return;
  final name = (item.linkedAnalysePdfFileName ?? 'analyse_rapport.pdf').trim();
  await pdf_platform.trySaveReportPdfOnPlatform(
    bytes,
    name.isEmpty ? 'analyse_rapport.pdf' : name,
    shareContext: context,
  );
}
