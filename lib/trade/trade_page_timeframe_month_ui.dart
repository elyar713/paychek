part of 'trade_page.dart';

extension _TradePageTimeframeMonthUi on _TradePageState {
  Widget _monthDetailCardHeader({
    required BuildContext context,
    required AppLocalizations l10n,
    required DateTime monthStart,
    required String rangeLabel,
    required int count,
    required double avg,
    required double net,
    required double? pct,
    required List<double> monthSparklineCumulative,
    required bool monthCardExpanded,
    required VoidCallback onExportPdf,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: _monthHeaderSparkline(monthSparklineCumulative),
        ),
        Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMonthLabel(context, monthStart),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  rangeLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TradeTokens.textDate,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _tradesLabel(context, count),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TradeTokens.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 96,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.tradeAverageShort,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: TradeTokens.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 8,
                          letterSpacing: 0.55,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatMoney(avg)}\$',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: avg < 0
                              ? TradeTokens.lossNeon
                              : TradeTokens.profitNeon,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          height: 1.05,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.tradeGainShort,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: TradeTokens.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 8,
                          letterSpacing: 0.55,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatMoney(net)}\$',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: net < 0
                              ? TradeTokens.lossNeon
                              : (net == 0
                                  ? Colors.white
                                  : TradeTokens.profitNeon),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          height: 1.05,
                        ),
                  ),
                  if (pct != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2).replaceAll('.', ',')}%',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: pct < 0
                                ? TradeTokens.lossNeon
                                : (pct == 0
                                    ? Colors.white
                                    : TradeTokens.profitNeon),
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: l10n.tradeExportPdfTooltip,
              onPressed: onExportPdf,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              color: TradeTokens.textSecondary,
              iconSize: 18,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 2),
            Icon(
              monthCardExpanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: TradeTokens.textSecondary,
              size: 18,
            ),
          ],
        ),
      ],
    );
  }

  Widget _monthHeaderSparkline(List<double> cumulative) {
    return SizedBox(
      width: 88,
      height: 16,
      child: CustomPaint(
        painter: _MonthSparklinePainter(cumulative),
      ),
    );
  }

  Widget _monthDetailCardExpanded({
    required BuildContext context,
    required AppLocalizations l10n,
    required double? avgChecklist,
    required double? avgPlan,
    required int winMonth,
    required double? avgStrategie,
    required double? avgEtat,
    required int wMonth,
    required int lMonth,
    required int bMonth,
    required int principeCount,
    required int feelingCount,
    required Map<String, int> counts,
    required int maxCount,
    required DateTime monthStart,
    required DateTime nextMonth,
    required List<TradeListItem> monthTrades,
    required List<double> monthSparklineCumulative,
    required int daysInMonth,
    required Widget Function({
      required String title,
      required double? pctVal,
      required Color color,
    }) ringCell,
    required Widget Function(TradeListItem t) rowTrade,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final itemW = (w - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: itemW,
                    child: ringCell(
                      title: l10n.tradeLabelChecklist,
                      pctVal: avgChecklist,
                      color: TradeTokens.profitNeon,
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: ringCell(
                      title: l10n.tradeLabelPlan,
                      pctVal: avgPlan,
                      color: TradeTokens.mustard,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: Center(
                      child: DonutRing(
                        progress: (winMonth / 100.0).clamp(0.0, 1.0),
                        centerPrimary: '$winMonth%',
                        centerSecondary: l10n.dashboardRingWin,
                        size: 64,
                        strokeWidth: 6,
                        ringColor: winMonth < 50
                            ? TradeTokens.lossNeon
                            : TradeTokens.profitNeon,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: Center(
                      child: Text(
                        l10n.tradeMonthTitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: TradeTokens.textSecondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.3,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _wlbChip(
                          context,
                          label: 'W',
                          count: wMonth,
                          color: TradeTokens.profitNeon,
                        ),
                        const SizedBox(width: 8),
                        _wlbChip(
                          context,
                          label: 'L',
                          count: lMonth,
                          color: TradeTokens.lossNeon,
                        ),
                        const SizedBox(width: 8),
                        _wlbChip(
                          context,
                          label: 'B',
                          count: bMonth,
                          color: TradeTokens.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: ringCell(
                      title: l10n.tradeLabelStrategie,
                      pctVal: avgStrategie,
                      color: const Color(0xFF6EA8FF),
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: ringCell(
                      title: l10n.tradeLabelEtat,
                      pctVal: avgEtat,
                      color: TradeTokens.lossNeon,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _mindsetChip(
                context,
                icon: Icons.verified_rounded,
                label: l10n.tradeMindsetPrinciple,
                count: principeCount,
                color: TradeTokens.profitNeon,
              ),
              const SizedBox(width: 8),
              _mindsetChip(
                context,
                icon: Icons.psychology_alt_rounded,
                label: l10n.tradeMindsetFeeling,
                count: feelingCount,
                color: TradeTokens.lossNeon,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sessionBar(
            context,
            label: l10n.tradeSessionAsia,
            count: counts[kTradeSessionAsia] ?? 0,
            maxCount: maxCount,
            barColor: const Color(0xFF6EA8FF),
          ),
          const SizedBox(height: 8),
          _sessionBar(
            context,
            label: l10n.tradeSessionEurope,
            count: counts[kTradeSessionEurope] ?? 0,
            maxCount: maxCount,
            barColor: TradeTokens.mustard,
          ),
          const SizedBox(height: 8),
          _sessionBar(
            context,
            label: l10n.tradeSessionUs,
            count: counts[kTradeSessionUs] ?? 0,
            maxCount: maxCount,
            barColor: TradeTokens.profitNeon,
          ),
          const SizedBox(height: 8),
          _sessionBar(
            context,
            label: l10n.tradeSessionLate,
            count: counts[kTradeSessionLate] ?? 0,
            maxCount: maxCount,
            barColor: TradeTokens.textSecondary,
          ),
          const SizedBox(height: 12),
          Container(
            height: 110,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TradeTokens.pillInactiveBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TradeTokens.cardBorder),
            ),
            child: _monthEvolutionChart(
              context,
              monthSparklineCumulative,
              monthTrades: monthTrades,
              monthStart: monthStart,
              nextMonth: nextMonth,
              daysInMonth: daysInMonth,
            ),
          ),
          if (monthTrades.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.tradeTradesMonthHeading,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: TradeTokens.mustard,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: 8),
            for (final t in (List<TradeListItem>.of(monthTrades)
              ..sort((a, b) => b.entreeAt.compareTo(a.entreeAt))))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: rowTrade(t),
              ),
          ],
        ],
      ),
    );
  }

  Widget _monthEvolutionChart(
    BuildContext context,
    List<double> cumulative, {
    required List<TradeListItem> monthTrades,
    required DateTime monthStart,
    required DateTime nextMonth,
    required int daysInMonth,
  }) {
    final safeCumulative = cumulative.isEmpty ? [0.0] : cumulative;

    return _MonthEvolutionInteractiveChart(
      dailyCumulative: safeCumulative,
      monthTrades: monthTrades,
      monthStart: monthStart,
      nextMonth: nextMonth,
      daysInMonth: daysInMonth,
      formatMoney: (v) => '${_formatMoney(v)}\$',
      formatEntree: _formatDateTime,
    );
  }
}

class _MonthEvolutionInteractiveChart extends StatefulWidget {
  const _MonthEvolutionInteractiveChart({
    required this.dailyCumulative,
    required this.monthTrades,
    required this.monthStart,
    required this.nextMonth,
    required this.daysInMonth,
    required this.formatMoney,
    required this.formatEntree,
  });

  final List<double> dailyCumulative;
  final List<TradeListItem> monthTrades;
  final DateTime monthStart;
  final DateTime nextMonth;
  final int daysInMonth;
  final String Function(double) formatMoney;
  final String Function(DateTime) formatEntree;

  @override
  State<_MonthEvolutionInteractiveChart> createState() =>
      _MonthEvolutionInteractiveChartState();
}

class _MonthEvolutionInteractiveChartState
    extends State<_MonthEvolutionInteractiveChart> {
  int? _selectedChronoIndex;

  @override
  Widget build(BuildContext context) {
    final n = widget.daysInMonth <= 0
        ? widget.dailyCumulative.length
        : widget.daysInMonth;
    final labels = <int>{
      1,
      if (n >= 8) 8,
      if (n >= 15) 15,
      if (n >= 22) 22,
      if (n >= 28) 28,
      if (n >= 1) n,
    }.toList()
      ..sort();

    final sorted = List<TradeListItem>.of(widget.monthTrades)
      ..sort((a, b) => a.entreeAt.compareTo(b.entreeAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final layout = _MonthEvolutionLayout.compute(
                size: size,
                dailyCumulative: widget.dailyCumulative,
                trades: widget.monthTrades,
                monthStart: widget.monthStart,
                nextMonth: widget.nextMonth,
                selectedChronoIndex: _selectedChronoIndex,
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  if (layout == null) return;
                  final hit = layout.hitTestNearest(details.localPosition, 16);
                  setState(() {
                    if (hit == null) {
                      _selectedChronoIndex = null;
                    } else if (_selectedChronoIndex == hit) {
                      _selectedChronoIndex = null;
                    } else {
                      _selectedChronoIndex = hit;
                    }
                  });
                },
                child: CustomPaint(
                  painter: _MonthEvolutionLayoutPainter(layout),
                  child: const SizedBox.expand(),
                ),
              );
            },
          ),
        ),
        if (_selectedChronoIndex != null &&
            _selectedChronoIndex! >= 0 &&
            _selectedChronoIndex! < sorted.length) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: TradeTokens.cardBg.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: TradeTokens.mustard.withValues(alpha: 0.35),
                ),
              ),
              child: Builder(
                builder: (context) {
                  final t = sorted[_selectedChronoIndex!];
                  final gainColor = t.gainAmount < 0
                      ? TradeTokens.lossNeon
                      : (t.gainAmount == 0
                          ? Colors.white
                          : TradeTokens.profitNeon);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedChronoIndex! + 1}/${sorted.length} · ${t.pair} · ${widget.formatMoney(t.gainAmount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: gainColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        widget.formatEntree(t.entreeAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TradeTokens.textDate,
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                          height: 1.1,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 6),
        Container(
          height: 1,
          color: TradeTokens.cardBorder.withValues(alpha: 0.65),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final d in labels)
              Text(
                '$d',
                style: const TextStyle(
                  color: TradeTokens.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

const double _kMonthChartCurveTension = 4.5;

double _cubicBezier1D(double t, double v0, double v1, double v2, double v3) {
  final u = 1 - t;
  return u * u * u * v0 +
      3 * u * u * t * v1 +
      3 * u * t * t * v2 +
      t * t * t * v3;
}

/// Ordonnée sur la courbe lisse au même [x] qu’un trade (aligne le point sur la courbe).
double? _yOnSmoothCurveAtX(
  List<Offset> pts,
  double x, {
  double tension = _kMonthChartCurveTension,
}) {
  if (pts.isEmpty) return null;
  if (pts.length == 1) return pts[0].dy;
  if (pts.length == 2) {
    final a = pts[0];
    final b = pts[1];
    if ((b.dx - a.dx).abs() < 1e-6) return a.dy;
    final t = ((x - a.dx) / (b.dx - a.dx)).clamp(0.0, 1.0);
    return a.dy + t * (b.dy - a.dy);
  }

  double? bestY;
  var bestErr = double.infinity;

  for (var i = 0; i < pts.length - 1; i++) {
    final p0 = pts[i == 0 ? 0 : i - 1];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = pts[i + 2 >= pts.length ? pts.length - 1 : i + 2];
    final cp1 = Offset(
      p1.dx + (p2.dx - p0.dx) / tension,
      p1.dy + (p2.dy - p0.dy) / tension,
    );
    final cp2 = Offset(
      p2.dx - (p3.dx - p1.dx) / tension,
      p2.dy - (p3.dy - p1.dy) / tension,
    );

    double xAt(double t) =>
        _cubicBezier1D(t, p1.dx, cp1.dx, cp2.dx, p2.dx);
    double yAt(double t) =>
        _cubicBezier1D(t, p1.dy, cp1.dy, cp2.dy, p2.dy);

    var segT = 0.0;
    var segErr = double.infinity;
    for (var s = 0; s <= 64; s++) {
      final t = s / 64.0;
      final err = (xAt(t) - x).abs();
      if (err < segErr) {
        segErr = err;
        segT = t;
      }
    }
    var lo = (segT - 0.08).clamp(0.0, 1.0);
    var hi = (segT + 0.08).clamp(0.0, 1.0);
    for (var k = 0; k < 18; k++) {
      final m1 = lo + (hi - lo) / 3;
      final m2 = hi - (hi - lo) / 3;
      final e1 = (xAt(m1) - x).abs();
      final e2 = (xAt(m2) - x).abs();
      if (e1 < e2) {
        hi = m2;
      } else {
        lo = m1;
      }
    }
    final tRef = (lo + hi) / 2;
    final errRef = (xAt(tRef) - x).abs();
    if (errRef < segErr) {
      segErr = errRef;
      segT = tRef;
    }

    if (segErr < bestErr) {
      bestErr = segErr;
      bestY = yAt(segT);
    }
  }

  return bestY;
}

/// Courbe lisse passant par les points (approx. Catmull-Rom → cubiques).
/// `tension` plus petit = courbe plus douce (moins « raide »).
Path _smoothStrokePathThroughPoints(
  List<Offset> pts, {
  double tension = _kMonthChartCurveTension,
}) {
  if (pts.isEmpty) return Path();
  if (pts.length == 1) {
    return Path()..moveTo(pts[0].dx, pts[0].dy);
  }
  if (pts.length == 2) {
    return Path()
      ..moveTo(pts[0].dx, pts[0].dy)
      ..lineTo(pts[1].dx, pts[1].dy);
  }
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < pts.length - 1; i++) {
    final p0 = pts[i == 0 ? 0 : i - 1];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = pts[i + 2 >= pts.length ? pts.length - 1 : i + 2];
    final cp1 = Offset(
      p1.dx + (p2.dx - p0.dx) / tension,
      p1.dy + (p2.dy - p0.dy) / tension,
    );
    final cp2 = Offset(
      p2.dx - (p3.dx - p1.dx) / tension,
      p2.dy - (p3.dy - p1.dy) / tension,
    );
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
  }
  return path;
}

class _MonthEvolutionLayout {
  _MonthEvolutionLayout({
    required this.sortedTrades,
    required this.tradeCum,
    required this.tradeOffsets,
    required this.minV,
    required this.maxV,
    required this.pad,
    required this.w,
    required this.h,
    required this.dailyCumulative,
    required this.selectedChronoIndex,
  });

  final List<TradeListItem> sortedTrades;
  final List<double> tradeCum;
  final List<Offset> tradeOffsets;
  /// Bornes d’affichage **symétriques** autour de 0 (P&L cumulé).
  final double minV;
  final double maxV;
  final double pad;
  final double w;
  final double h;
  final List<double> dailyCumulative;
  final int? selectedChronoIndex;

  static _MonthEvolutionLayout? compute({
    required Size size,
    required List<double> dailyCumulative,
    required List<TradeListItem> trades,
    required DateTime monthStart,
    required DateTime nextMonth,
    required int? selectedChronoIndex,
  }) {
    if (dailyCumulative.isEmpty) return null;

    const pad = 2.0;
    final w = size.width;
    final h = (size.height - 2 * pad).clamp(1.0, size.height);

    final sorted = List<TradeListItem>.of(trades)
      ..sort((a, b) => a.entreeAt.compareTo(b.entreeAt));
    final tradeCum = <double>[];
    var acc = 0.0;
    for (final t in sorted) {
      acc += t.gainAmount;
      tradeCum.add(acc);
    }

    var minRaw = dailyCumulative.first;
    var maxRaw = dailyCumulative.first;
    for (final v in dailyCumulative) {
      if (v < minRaw) minRaw = v;
      if (v > maxRaw) maxRaw = v;
    }
    for (final v in tradeCum) {
      if (v < minRaw) minRaw = v;
      if (v > maxRaw) maxRaw = v;
    }
    final maxAbs = math.max(math.max(minRaw.abs(), maxRaw.abs()), 1e-6);
    final displayExtent = maxAbs * 1.15;
    var minV = -displayExtent;
    var maxV = displayExtent;

    double yFor(double v) {
      if (maxV == minV) return pad + h / 2;
      final span = maxV - minV;
      return pad + h - ((v - minV) / span) * h;
    }

    final totalMs = nextMonth.difference(monthStart).inMilliseconds;
    final denom = totalMs <= 0 ? 1 : totalMs;

    final nDays = dailyCumulative.length;
    final linePts = <Offset>[
      for (var i = 0; i < nDays; i++)
        Offset(
          nDays <= 1 ? w / 2 : (i / (nDays - 1)) * w,
          yFor(dailyCumulative[i]),
        ),
    ];

    final tradeOffsets = <Offset>[];
    for (var i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      final dtMs = t.entreeAt.toLocal().difference(monthStart).inMilliseconds;
      final clamped = dtMs.clamp(0, denom).toDouble();
      final x = (clamped / denom) * w;
      final yOnCurve = _yOnSmoothCurveAtX(linePts, x) ?? yFor(tradeCum[i]);
      tradeOffsets.add(Offset(x, yOnCurve));
    }

    return _MonthEvolutionLayout(
      sortedTrades: sorted,
      tradeCum: tradeCum,
      tradeOffsets: tradeOffsets,
      minV: minV,
      maxV: maxV,
      pad: pad,
      w: w,
      h: h,
      dailyCumulative: dailyCumulative,
      selectedChronoIndex: selectedChronoIndex,
    );
  }

  int? hitTestNearest(Offset local, double radius) {
    if (tradeOffsets.isEmpty) return null;
    var bestI = -1;
    var bestD = double.infinity;
    for (var i = 0; i < tradeOffsets.length; i++) {
      final d = (tradeOffsets[i] - local).distance;
      if (d < bestD && d <= radius) {
        bestD = d;
        bestI = i;
      }
    }
    return bestI < 0 ? null : bestI;
  }

  void paint(Canvas canvas) {
    double yFor(double v) {
      if (maxV == minV) return pad + h / 2;
      final span = maxV - minV;
      return pad + h - ((v - minV) / span) * h;
    }

    final gainStroke = Paint()
      ..color = TradeTokens.profitNeon
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final lossStroke = Paint()
      ..color = TradeTokens.lossNeon
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final n = dailyCumulative.length;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          n <= 1 ? w / 2 : (i / (n - 1)) * w,
          yFor(dailyCumulative[i]),
        ),
    ];
    final curvePath =
        _smoothStrokePathThroughPoints(pts, tension: _kMonthChartCurveTension);
    final zeroY = yFor(0);

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, zeroY));
    canvas.drawPath(curvePath, gainStroke);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, zeroY, w, pad + h + 8));
    canvas.drawPath(curvePath, lossStroke);
    canvas.restore();

    if (sortedTrades.isEmpty) return;

    final stroke = Paint()
      ..color = TradeTokens.cardBg.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final selRing = Paint()
      ..color = TradeTokens.mustard.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < tradeOffsets.length; i++) {
      final center = tradeOffsets[i];
      final selected = selectedChronoIndex == i;
      final r = selected ? 4.2 : 2.4;
      final fill = Paint()
        ..color =
            (tradeCum[i] >= 0 ? TradeTokens.profitNeon : TradeTokens.lossNeon)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, r, fill);
      canvas.drawCircle(center, r, stroke);
      if (selected) {
        canvas.drawCircle(center, r + 2.5, selRing);
      }
    }
  }
}

class _MonthEvolutionLayoutPainter extends CustomPainter {
  _MonthEvolutionLayoutPainter(this.layout);

  final _MonthEvolutionLayout? layout;

  @override
  void paint(Canvas canvas, Size size) {
    layout?.paint(canvas);
  }

  @override
  bool shouldRepaint(covariant _MonthEvolutionLayoutPainter oldDelegate) =>
      oldDelegate.layout != layout;
}

class _MonthSparklinePainter extends CustomPainter {
  _MonthSparklinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const pad = 2.0;
    final h = (size.height - 2 * pad).clamp(1.0, size.height);
    final w = size.width;

    if (values.every((v) => v.abs() < 1e-6)) {
      final y = pad + h / 2;
      final p = Paint()
        ..color = TradeTokens.textSecondary.withValues(alpha: 0.75)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, y), Offset(w, y), p);
      return;
    }

    var minRaw = values.first;
    var maxRaw = values.first;
    for (final v in values) {
      if (v < minRaw) minRaw = v;
      if (v > maxRaw) maxRaw = v;
    }
    final extent =
        math.max(math.max(minRaw.abs(), maxRaw.abs()), 1e-6) * 1.18;

    final n = values.length;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          n <= 1 ? w / 2 : (i / (n - 1)) * w,
          pad +
              h -
              ((values[i] + extent) / (2 * extent)).clamp(0.0, 1.0) * h,
        ),
    ];
    final path = _smoothStrokePathThroughPoints(pts);
    final zeroY = pad + h / 2;

    final gainPaint = Paint()
      ..color = TradeTokens.profitNeon
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final lossPaint = Paint()
      ..color = TradeTokens.lossNeon
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, zeroY));
    canvas.drawPath(path, gainPaint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, zeroY, w, size.height));
    canvas.drawPath(path, lossPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MonthSparklinePainter oldDelegate) {
    final a = oldDelegate.values;
    final b = values;
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
  }
}
