import 'dart:ui' show Locale;

import '../l10n/app_localizations.dart';
import 'performance_analysis.dart' hide Trade;
import 'performance_trade_model.dart';
import 'performance_widget_model.dart';

/// Données agrégées depuis [Performance (1).csv] selon la métrique choisie.
class MetricSeriesBundle {
  const MetricSeriesBundle({
    required this.named,
    required this.cumulativeProfit,
    this.dataFootnote,
  });

  final List<NamedWinRate> named;
  final List<double> cumulativeProfit;
  final String? dataFootnote;

  static MetricSeriesBundle forMetric(
    int metricIndex,
    List<Trade> trades,
    AppLocalizations l, {
    required Locale locale,
  }) {
    switch (metricIndex) {
      case 0:
      case 1:
        return MetricSeriesBundle(
          named: weekdayWinRates(trades, locale: locale),
          cumulativeProfit: cumulativeProfitSeries(trades),
        );
      case 2:
        return MetricSeriesBundle(
          named: timeSlotWinRatesNamed(trades, locale: locale),
          cumulativeProfit: cumulativeProfitSeries(trades),
        );
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
        return MetricSeriesBundle(
          named: durationBucketWinRatesNamed(trades),
          cumulativeProfit: cumulativeProfitSeries(trades),
          dataFootnote: l.perfDataFootnoteDuration,
        );
      case 9:
        return MetricSeriesBundle(
          named: profitAmplitudeBuckets(trades),
          cumulativeProfit: cumulativeProfitSeries(trades),
          dataFootnote: l.perfDataFootnoteVolume,
        );
      default:
        return MetricSeriesBundle(
          named: durationBucketWinRatesNamed(trades),
          cumulativeProfit: cumulativeProfitSeries(trades),
        );
    }
  }
}

String widgetCardSubtitle(SavedPerformanceWidget w, AppLocalizations l) {
  final chart = PerformanceWidgetChartType.title(w.chartTypeIndex, l);
  final m = PerformanceWidgetMetric.at(w.metricIndex, l);
  return '${m.subtitle} · $chart';
}
