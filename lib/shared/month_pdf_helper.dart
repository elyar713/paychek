import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../trade/trade_models.dart';
import '../trade/trade_session.dart';
import '../trade/trade_stats.dart';
import '../trade/trade_export_pdf.dart';

/// Génère et exporte un PDF pour un mois donné
Future<void> exportMonthPdf({
  required BuildContext context,
  required DateTime monthStart,
  required List<TradeListItem> monthTrades,
  required double? initialCapital,
  String filenamePrefix = 'trades_month',
}) async {
  // Calculer les statistiques du mois
  double avgPct(List<double> xs) =>
      xs.isEmpty ? 0.0 : (xs.fold<double>(0.0, (a, b) => a + b) / xs.length);

  final avgChecklist = avgPct(monthTrades.map((e) => e.checklistPct).toList());
  final avgPlan = avgPct(monthTrades.map((e) => e.planPct).toList());
  final avgStrategie = avgPct(monthTrades.map((e) => e.strategiePct).toList());
  final avgEtat = avgPct(monthTrades.map((e) => e.etatPct).toList());
  final winMonth = computeTradeStats(monthTrades).winRatePctDisplay;
  final principeCount =
      monthTrades.where((e) => e.mindset == TradeMindset.principe).length;
  final feelingCount =
      monthTrades.where((e) => e.mindset == TradeMindset.feeling).length;

  final counts = tradeSessionCountsEmpty();
  for (final t in monthTrades) {
    final id = tradeSessionBucketId(t.entreeAt);
    counts[id] = (counts[id] ?? 0) + 1;
  }

  final count = monthTrades.length;
  final net = monthTrades.fold<double>(0.0, (sum, t) => sum + t.gainAmount);
  final avg = count <= 0 ? 0.0 : (net / count);
  final pct = (initialCapital != null && initialCapital > 0)
      ? (net / initialCapital) * 100.0
      : null;

  final nextMonth = (monthStart.month == 12)
      ? DateTime(monthStart.year + 1, 1, 1)
      : DateTime(monthStart.year, monthStart.month + 1, 1);

  // Calculer le sparkline cumulatif
  final daysInMonth = nextMonth.difference(monthStart).inDays;
  final dailySums = List.filled(daysInMonth > 0 ? daysInMonth : 1, 0.0);
  for (final t in monthTrades) {
    final dayIndex = t.entreeAt.toLocal().difference(monthStart).inDays;
    if (dayIndex >= 0 && dayIndex < dailySums.length) {
      dailySums[dayIndex] += t.gainAmount;
    }
  }
  final cumulative = <double>[];
  var acc = 0.0;
  for (final v in dailySums) {
    acc += v;
    cumulative.add(acc);
  }

  // Formater la range
  String formatDayLabel(DateTime d) {
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${p2(d.day)}/${p2(d.month)}';
  }
  final rangeLabel = '${formatDayLabel(monthStart)} - ${formatDayLabel(
    nextMonth.subtract(const Duration(days: 1)),
  )}';

  if (!context.mounted) return;
  final l = AppLocalizations.of(context)!;
  final bytes = await buildTradeTimeframePdf(
    l: l,
    title: l.tradePdfExportMonthTitle,
    rangeLabel: rangeLabel,
    count: count,
    net: net,
    avg: avg,
    pct: pct,
    winRatePct: winMonth,
    avgChecklist: avgChecklist,
    avgPlan: avgPlan,
    avgStrategie: avgStrategie,
    avgEtat: avgEtat,
    principeCount: principeCount,
    feelingCount: feelingCount,
    sessionCounts: counts,
    monthSparklineCumulative: cumulative,
    trades: monthTrades,
  );

  final ym = '${monthStart.year.toString().padLeft(4, '0')}-${monthStart.month.toString().padLeft(2, '0')}';
  final filename = '${filenamePrefix}_$ym.pdf';
  
  if (!context.mounted) return;
  await exportTradeTimeframePdf(
    context,
    bytes: bytes,
    filename: filename,
  );
}
