import 'package:shared_preferences/shared_preferences.dart';

import 'performance_widget_model.dart';
import '../reglage/paychek_prefs_scope.dart';

/// Persistance locale — sur Flutter Web, [SharedPreferences] utilise le `localStorage` du navigateur.
class PerformanceWidgetStorage {
  PerformanceWidgetStorage._();

  static const _kMetricBase = 'paychek_perf_widget_metric_index';
  static const _kChartBase = 'paychek_perf_widget_chart_type_index';
  static const _kAtBase = 'paychek_perf_widget_saved_at_ms';

  static String get _kMetric => paychekScopedPrefsKey(_kMetricBase);
  static String get _kChart => paychekScopedPrefsKey(_kChartBase);
  static String get _kAt => paychekScopedPrefsKey(_kAtBase);

  static Future<void> save(SavedPerformanceWidget w) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kMetric, w.metricIndex);
    await p.setInt(_kChart, w.chartTypeIndex);
    await p.setInt(_kAt, w.savedAtMillis);
  }

  static Future<SavedPerformanceWidget?> load() async {
    final p = await SharedPreferences.getInstance();
    if (!p.containsKey(_kMetric) || !p.containsKey(_kChart)) return null;
    final m = p.getInt(_kMetric);
    final c = p.getInt(_kChart);
    final at = p.getInt(_kAt) ?? 0;
    if (m == null || c == null) return null;
    final w = SavedPerformanceWidget(
      metricIndex: m,
      chartTypeIndex: c,
      savedAtMillis: at,
    );
    return w.isValid ? w : null;
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kMetric);
    await p.remove(_kChart);
    await p.remove(_kAt);
  }
}
