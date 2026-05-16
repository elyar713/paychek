import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import 'performance_analysis.dart';
import 'performance_locale_copy.dart';
import 'performance_widget_model.dart';
import 'performance_widget_series.dart';

const Color _kGreen = Color(0xFF1eb48a);
const Color _kRed = Color(0xFFFF4D4D);
const Color _kGrey = Color(0xFF555555);

/// Graphique selon le type enregistrÃ© + donnÃ©es CSV.
class PerformanceWidgetChart extends StatelessWidget {
  const PerformanceWidgetChart({
    super.key,
    required this.chartTypeIndex,
    required this.series,
    required this.tradesEmpty,
  });

  final int chartTypeIndex;
  final MetricSeriesBundle series;
  final bool tradesEmpty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (tradesEmpty) {
      return _empty(l.perfEmptyChart);
    }

    switch (chartTypeIndex) {
      case PerformanceWidgetChartType.bar:
        return _barChart(context, series.named);
      case PerformanceWidgetChartType.pie:
        return _pieChart(context, series.named);
      case PerformanceWidgetChartType.line:
        return _lineChart(context, series.cumulativeProfit);
      case PerformanceWidgetChartType.horizontalBar:
        return _horizontalBars(context, series.named);
      default:
        return _barChart(context, series.named);
    }
  }

  Widget _empty(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _kGrey, height: 1.4),
      ),
    );
  }

  String _chartEmptyLine(BuildContext context) => performancePickLocale(
        Localizations.localeOf(context),
        'Aucune donnée.',
        'No data.',
        'Sin datos.',
        'Keine Daten.',
        'Sem dados.',
        '데이터 없음.',
      );

  String _chartNotEnoughTradesPie(BuildContext context) => performancePickLocale(
        Localizations.localeOf(context),
        'Pas assez de trades pour ce graphique.',
        'Not enough trades for this chart.',
        'No hay suficientes trades para este gráfico.',
        'Nicht genug Trades für dieses Diagramm.',
        'Trades insuficientes para este gráfico.',
        '이 차트를 만들 트레이드가 부족합니다.',
      );

  Widget _barChart(BuildContext context, List<NamedWinRate> named) {
    if (named.isEmpty) {
      return _empty(_chartEmptyLine(context));
    }
    final maxY = 100.0;
    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 8),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= named.length) return const SizedBox.shrink();
                    final t = named[i].label;
                    final short = t.length > 5 ? '${t.substring(0, 4)}…' : t;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        short,
                        style: GoogleFonts.plusJakartaSans(fontSize: 8, color: _kGrey),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 25,
                  getTitlesWidget: (v, m) => Text(
                    '${v.toInt()}%',
                    style: GoogleFonts.plusJakartaSans(fontSize: 9, color: _kGrey),
                  ),
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFF1A1A1A), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < named.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: named[i].winRate * 100,
                      color: _kGreen,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pieChart(BuildContext context, List<NamedWinRate> named) {
    final total = named.fold<int>(0, (a, b) => a + b.count);
    if (total == 0) {
      return _empty(_chartNotEnoughTradesPie(context));
    }
    final colors = [
      _kGreen,
      Colors.white,
      const Color(0xFF444444),
      _kRed,
      const Color(0xFF888888),
      const Color(0xFF2A5A4A),
      const Color(0xFF5C4033),
    ];
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 36,
          sections: [
            for (var i = 0; i < named.length; i++)
              PieChartSectionData(
                color: colors[i % colors.length],
                value: named[i].count.toDouble(),
                title: '${(named[i].count / total * 100).round()}%',
                radius: 52,
                titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _lineChart(BuildContext context, List<double> cumulative) {
    if (cumulative.isEmpty) {
      return _empty(_chartEmptyLine(context));
    }
    var minY = cumulative.first;
    var maxY = cumulative.first;
    for (final v in cumulative) {
      if (v < minY) minY = v;
      if (v > maxY) maxY = v;
    }
    if (minY == maxY) {
      minY -= 10;
      maxY += 10;
    } else {
      final pad = (maxY - minY) * 0.1;
      minY -= pad;
      maxY += pad;
    }
    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8, left: 4),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFF1A1A1A), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  getTitlesWidget: (v, m) => Text(
                    v.toStringAsFixed(0),
                    style: GoogleFonts.plusJakartaSans(fontSize: 9, color: _kGrey),
                  ),
                ),
              ),
              bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < cumulative.length; i++) FlSpot(i.toDouble(), cumulative[i]),
                ],
                isCurved: true,
                color: _kGreen,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: _kGreen.withValues(alpha: 0.12),
                ),
              ),
            ],
            lineTouchData: LineTouchData(enabled: true),
          ),
        ),
      ),
    );
  }

  Widget _horizontalBars(BuildContext context, List<NamedWinRate> named) {
    if (named.isEmpty) {
      return _empty(_chartEmptyLine(context));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final n in named) ...[
          Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  n.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFFAAAAAA)),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: n.winRate.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: const Color(0xFF111111),
                    color: _kGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(n.winRate * 100).round()}%',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Carte complÃ¨te (titre + graphique + lÃ©gende optionnelle).
class SavedWidgetInsightCard extends StatelessWidget {
  const SavedWidgetInsightCard({
    super.key,
    required this.config,
    required this.series,
    required this.tradesEmpty,
    this.onRemove,
  });

  final SavedPerformanceWidget config;
  final MetricSeriesBundle series;
  final bool tradesEmpty;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final m = PerformanceWidgetMetric.at(config.metricIndex, l);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF161616)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widgetCardSubtitle(config, l),
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _kGrey),
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: _kGrey),
                  onPressed: onRemove,
                  tooltip: l.perfRemoveWidgetTooltip,
                ),
            ],
          ),
          if (series.dataFootnote != null && series.dataFootnote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              series.dataFootnote!,
              style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF666666), fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 12),
          PerformanceWidgetChart(
            chartTypeIndex: config.chartTypeIndex,
            series: series,
            tradesEmpty: tradesEmpty,
          ),
          if (config.chartTypeIndex == PerformanceWidgetChartType.line && !tradesEmpty) ...[
            const SizedBox(height: 6),
            Text(
              l.perfLineChartCaption,
              style: GoogleFonts.plusJakartaSans(fontSize: 9, color: _kGrey),
            ),
          ],
          if (config.chartTypeIndex == PerformanceWidgetChartType.pie && !tradesEmpty) ...[
            const SizedBox(height: 6),
            Text(
              l.perfPieChartCaption,
              style: GoogleFonts.plusJakartaSans(fontSize: 9, color: _kGrey),
            ),
          ],
        ],
      ),
    );
  }
}



