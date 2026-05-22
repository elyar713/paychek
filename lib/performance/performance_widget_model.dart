import '../l10n/app_localizations.dart';

/// Métriques et types de graphique — partagés entre personnalisation et page Performance.
class PerformanceWidgetMetric {
  const PerformanceWidgetMetric({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  static const int count = 10;

  static PerformanceWidgetMetric at(int index, AppLocalizations l) {
    switch (index) {
      case 0:
        return PerformanceWidgetMetric(
          title: l.perf0Title,
          subtitle: l.perf0Sub,
        );
      case 1:
        return PerformanceWidgetMetric(
          title: l.perf1Title,
          subtitle: l.perf1Sub,
        );
      case 2:
        return PerformanceWidgetMetric(
          title: l.perf2Title,
          subtitle: l.perf2Sub,
        );
      case 3:
        return PerformanceWidgetMetric(
          title: l.perf3Title,
          subtitle: l.perf3Sub,
        );
      case 4:
        return PerformanceWidgetMetric(
          title: l.perf4Title,
          subtitle: l.perf4Sub,
        );
      case 5:
        return PerformanceWidgetMetric(
          title: l.perf5Title,
          subtitle: l.perf5Sub,
        );
      case 6:
        return PerformanceWidgetMetric(
          title: l.perf6Title,
          subtitle: l.perf6Sub,
        );
      case 7:
        return PerformanceWidgetMetric(
          title: l.perf7Title,
          subtitle: l.perf7Sub,
        );
      case 8:
        return PerformanceWidgetMetric(
          title: l.perf8Title,
          subtitle: l.perf8Sub,
        );
      case 9:
        return PerformanceWidgetMetric(
          title: l.perf9Title,
          subtitle: l.perf9Sub,
        );
      default:
        throw RangeError.index(index, count);
    }
  }

  static List<PerformanceWidgetMetric> list(AppLocalizations l) =>
      List.generate(count, (i) => at(i, l));
}

/// 0 = barres verticales, 1 = cercle, 2 = ligne, 3 = barres horizontales
class PerformanceWidgetChartType {
  static const int bar = 0;
  static const int pie = 1;
  static const int line = 2;
  static const int horizontalBar = 3;

  static const int count = 4;

  static String title(int index, AppLocalizations l) {
    switch (index) {
      case bar:
        return l.perfChartBar;
      case pie:
        return l.perfChartPie;
      case line:
        return l.perfChartLine;
      case horizontalBar:
        return l.perfChartHBar;
      default:
        return l.perfChartBar;
    }
  }

  static String hint(int index, AppLocalizations l) {
    switch (index) {
      case bar:
        return l.perfChartHintBar;
      case pie:
        return l.perfChartHintPie;
      case line:
        return l.perfChartHintLine;
      case horizontalBar:
        return l.perfChartHintHBar;
      default:
        return l.perfChartHintBar;
    }
  }

  static List<String> titles(AppLocalizations l) =>
      List.generate(count, (i) => title(i, l));
}

class SavedPerformanceWidget {
  const SavedPerformanceWidget({
    required this.metricIndex,
    required this.chartTypeIndex,
    required this.savedAtMillis,
  });

  final int metricIndex;
  final int chartTypeIndex;
  final int savedAtMillis;

  bool get isValid =>
      metricIndex >= 0 &&
      metricIndex < PerformanceWidgetMetric.count &&
      chartTypeIndex >= 0 &&
      chartTypeIndex < PerformanceWidgetChartType.count;
}
