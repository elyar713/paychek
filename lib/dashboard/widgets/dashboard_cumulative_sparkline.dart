import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../calendrier/calendrier_constants.dart';
import '../../calendrier/calendrier_utils.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard_tokens.dart';
import '../evolution_spot.dart';
import '../evolution_spot_context.dart';

const double _kSparkHInset = 3;

double _sparkScreenXFromSpotValue(double spotX, int pointCount, double width) {
  final inner = width - 2 * _kSparkHInset;
  if (inner <= 0) return width * 0.5;
  if (pointCount <= 1) return _kSparkHInset + inner * 0.5;
  return _kSparkHInset + (spotX - 1) / (pointCount - 1) * inner;
}

double _sparkScreenY(double yVal, Size size, double minY, double maxY) {
  final yRange = (maxY - minY).abs() < 1e-10 ? 1.0 : (maxY - minY);
  return size.height - ((yVal - minY) / yRange * size.height);
}

/// Abscisse du vertex le plus proche du curseur (index dans [spots]).
int nearestSparkSpotIndex(double localDx, double width, int pointCount) {
  if (pointCount <= 0) return 0;
  if (pointCount == 1) return 0;
  final inner = width - 2 * _kSparkHInset;
  if (inner <= 0) return 0;
  final t =
      ((localDx - _kSparkHInset) / inner).clamp(0.0, 1.0) * (pointCount - 1);
  return t.round().clamp(0, pointCount - 1);
}

Offset sparkPointScreen(
  EvolutionSpot spot,
  Size size,
  double minY,
  double maxY,
  int pointCount,
) {
  final x = _sparkScreenXFromSpotValue(spot.x, pointCount, size.width);
  final y = _sparkScreenY(spot.y, size, minY, maxY);
  return Offset(x, y);
}

/// Courbe PnL cumulé avec survol (trade / jour du palier).
class DashboardCumulativeSparkline extends StatefulWidget {
  const DashboardCumulativeSparkline({
    super.key,
    required this.spots,
    required this.spotContexts,
    required this.minY,
    required this.maxY,
    this.height,
    this.currencySymbol = r'$',
    this.onOpenTradeById,
  });

  final List<EvolutionSpot> spots;

  /// Même taille que [spots].
  final List<EvolutionSpotContext> spotContexts;
  final double minY;
  final double maxY;
  final String currencySymbol;

  /// Hauteur du graph ; défaut ~120 ([_defaultHeight]). Pas de [LayoutBuilder] ici : compatible avec un parent [IntrinsicHeight].
  final double? height;

  final ValueChanged<String>? onOpenTradeById;

  static const double _defaultHeight = 120;

  @override
  State<DashboardCumulativeSparkline> createState() =>
      _DashboardCumulativeSparklineState();
}

class _DashboardCumulativeSparklineState extends State<DashboardCumulativeSparkline> {
  int? _hoverIndex;

  /// Mesure sans [LayoutBuilder] (nécessaire pour un ascendant [IntrinsicHeight]).
  final GlobalKey _paintStackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  double _chartHeightPx() =>
      widget.height ?? DashboardCumulativeSparkline._defaultHeight;

  Size _chartSizePx() {
    final hPx = _chartHeightPx();
    final rb =
        _paintStackKey.currentContext?.findRenderObject() as RenderBox?;
    final w = (rb != null && rb.hasSize) ? rb.size.width : 0.0;
    return Size(w, hPx);
  }

  void _setHoverFromLocal(Offset local, double width, double height) {
    if (widget.spots.isEmpty) return;
    assert(widget.spots.length == widget.spotContexts.length);
    final idx =
        nearestSparkSpotIndex(local.dx, width, widget.spots.length);
    setState(() => _hoverIndex = idx);
  }

  void _hoverAtLocalPosition(Offset local) {
    final sz = _chartSizePx();
    final w = sz.width;
    if (w <= 0) return;
    _setHoverFromLocal(local, w, sz.height);
  }

  void _clearHover() {
    if (_hoverIndex == null) return;
    setState(() => _hoverIndex = null);
  }

  void _maybeOpenTrade(int? idx) {
    if (idx == null ||
        widget.onOpenTradeById == null ||
        widget.spots.isEmpty) {
      return;
    }
    final trades = widget.spotContexts[idx].tradesOnSlice;
    if (trades.isEmpty) return;
    widget.onOpenTradeById!(trades.first.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    assert(widget.spots.length == widget.spotContexts.length);

    final hPx = _chartHeightPx();
    final chartSize = _chartSizePx();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ColoredBox(
        color: DashboardTokens.cardBoxBg,
        child: SizedBox(
          height: hPx,
          child: Stack(
            key: _paintStackKey,
            clipBehavior: Clip.hardEdge,
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _DashboardSparklinePainter(
                  spots: widget.spots,
                  minY: widget.minY,
                  maxY: widget.maxY,
                ),
              ),
              if (_hoverIndex != null &&
                  _hoverIndex! < widget.spots.length &&
                  chartSize.width > 0)
                CustomPaint(
                  painter: _SparkHoverMarkerPainter(
                    center: sparkPointScreen(
                      widget.spots[_hoverIndex!],
                      chartSize,
                      widget.minY,
                      widget.maxY,
                      widget.spots.length,
                    ),
                    cumulativeY: widget.spots[_hoverIndex!].y,
                  ),
                ),
              Positioned.fill(
                child: MouseRegion(
                  onExit: (_) => _clearHover(),
                  onHover: (e) => _hoverAtLocalPosition(e.localPosition),
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerMove: (e) =>
                        _hoverAtLocalPosition(e.localPosition),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (d) => _hoverAtLocalPosition(d.localPosition),
                      onTapCancel: () => _clearHover(),
                      onTap: () => _maybeOpenTrade(_hoverIndex),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              if (_hoverIndex != null &&
                  _hoverIndex! < widget.spots.length &&
                  chartSize.width > 0)
                _HoverReadout(
                  spots: widget.spots,
                  index: _hoverIndex!,
                  spotContexts: widget.spotContexts,
                  currencySymbol: widget.currencySymbol,
                  showOpenHint: widget.onOpenTradeById != null,
                  l: l,
                  chartSize: chartSize,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SparkHoverMarkerPainter extends CustomPainter {
  _SparkHoverMarkerPainter({
    required this.center,
    required this.cumulativeY,
  });

  final Offset center;
  final double cumulativeY;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      linePaint,
    );

    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final dotColor = cumulativeY >= 0 ? kGainText : kLossText;
    final fill = Paint()
      ..color = dotColor.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 5, fill);
    canvas.drawCircle(center, 5, ring);
  }

  @override
  bool shouldRepaint(covariant _SparkHoverMarkerPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.cumulativeY != cumulativeY;
  }
}

class _HoverReadout extends StatelessWidget {
  const _HoverReadout({
    required this.spots,
    required this.index,
    required this.spotContexts,
    required this.currencySymbol,
    required this.showOpenHint,
    required this.l,
    required this.chartSize,
  });

  final List<EvolutionSpot> spots;
  final int index;
  final List<EvolutionSpotContext> spotContexts;
  final String currencySymbol;
  final bool showOpenHint;
  final AppLocalizations l;
  final Size chartSize;

  @override
  Widget build(BuildContext context) {
    final ctx = spotContexts[index];
    final mat = MaterialLocalizations.of(context);
    final dayLabel = mat.formatCompactDate(ctx.referenceDayLocalMidnight);
    final trades = ctx.tradesOnSlice;

    String bodyLine;
    if (index == 0 && trades.isEmpty) {
      bodyLine = l.dashboardEvolutionSparklineHoverOrigin;
    } else if (trades.isEmpty) {
      bodyLine = l.dashboardEvolutionSparklineHoverNoTrade;
    } else {
      final t = trades.first;
      final sub = trades.length > 1
          ? '\n${l.dashboardEvolutionSparklineHoverMore(trades.length - 1)}'
          : '';
      bodyLine =
          '${t.pair} · ${formatMoneyWithCurrencySymbol(t.gainAmount, currencySymbol)}$sub';
    }

    const maxW = 220.0;
    const pad = 8.0;
    final n = spots.length;
    final anchorX =
        _sparkScreenXFromSpotValue(spots[index].x, n, chartSize.width);
    final topPad = chartSize.height * 0.08;

    final left =
        (anchorX - maxW * 0.45).clamp(pad, chartSize.width - maxW - pad);

    return Positioned(
      left: left,
      top: topPad,
      width: maxW,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xE6181820),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bodyLine,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (trades.isNotEmpty && showOpenHint) ...[
                    const SizedBox(height: 6),
                    Text(
                      l.dashboardEvolutionSparklineTapHint,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: kGainText.withValues(alpha: 0.95),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardSparklinePainter extends CustomPainter {
  _DashboardSparklinePainter({
    required this.spots,
    required this.minY,
    required this.maxY,
  });

  final List<EvolutionSpot> spots;
  final double minY;
  final double maxY;

  int get _pointCount => spots.length;

  @override
  void paint(Canvas canvas, Size size) {
    if (spots.isEmpty) return;
    if (size.width <= 0 || size.height <= 0) return;

    /// Évite division par zéro et l'absence de dessin si minY ≈ maxY (float).
    final yRange = (maxY - minY).abs() < 1e-10 ? 1.0 : (maxY - minY);

    final zeroY = size.height - ((0 - minY) / yRange * size.height);

    _drawZeroLine(canvas, size, zeroY);
    _drawGradients(canvas, size, zeroY, yRange);
    _drawPerformanceLine(canvas, size, zeroY, yRange);
  }

  double _spotX(double spotX, double width) =>
      _sparkScreenXFromSpotValue(spotX, _pointCount, width);

  void _drawZeroLine(Canvas canvas, Size size, double zeroY) {
    final paint = Paint()
      ..color = kWeekdayColor.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    var startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, zeroY),
        Offset(startX + dashWidth, zeroY),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  /// Même cubiques que [_drawPerformanceLine] : courbe continue pour le nuage.
  void _appendContinuousSmoothCurve(
    Path p,
    List<Offset> screenPoints,
    double zeroY,
  ) {
    for (var i = 1; i < screenPoints.length; i++) {
      final point = screenPoints[i];
      final prevPoint = screenPoints[i - 1];
      final isAboveZero = point.dy <= zeroY;
      final wasAboveZero = prevPoint.dy <= zeroY;

      final controlPoint1 = Offset(
        prevPoint.dx + (point.dx - prevPoint.dx) / 3,
        prevPoint.dy,
      );
      final controlPoint2 = Offset(
        prevPoint.dx + 2 * (point.dx - prevPoint.dx) / 3,
        point.dy,
      );

      if (wasAboveZero && isAboveZero) {
        p.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          point.dx,
          point.dy,
        );
      } else if (!wasAboveZero && !isAboveZero) {
        p.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          point.dx,
          point.dy,
        );
      } else {
        final crossX = prevPoint.dx +
            (point.dx - prevPoint.dx) *
                ((zeroY - prevPoint.dy) / (point.dy - prevPoint.dy));

        final crossControlPoint1 = Offset(
          prevPoint.dx + (crossX - prevPoint.dx) / 3,
          prevPoint.dy,
        );
        final crossControlPoint2 = Offset(
          prevPoint.dx + 2 * (crossX - prevPoint.dx) / 3,
          zeroY,
        );

        if (wasAboveZero) {
          p.cubicTo(
            crossControlPoint1.dx,
            crossControlPoint1.dy,
            crossControlPoint2.dx,
            crossControlPoint2.dy,
            crossX,
            zeroY,
          );
          final afterCrossControl1 = Offset(crossX, zeroY);
          final afterCrossControl2 = Offset(
            crossX + (point.dx - crossX) / 2,
            point.dy,
          );
          p.cubicTo(
            afterCrossControl1.dx,
            afterCrossControl1.dy,
            afterCrossControl2.dx,
            afterCrossControl2.dy,
            point.dx,
            point.dy,
          );
        } else {
          p.cubicTo(
            crossControlPoint1.dx,
            crossControlPoint1.dy,
            crossControlPoint2.dx,
            crossControlPoint2.dy,
            crossX,
            zeroY,
          );
          final afterCrossControl1 = Offset(crossX, zeroY);
          final afterCrossControl2 = Offset(
            crossX + (point.dx - crossX) / 2,
            point.dy,
          );
          p.cubicTo(
            afterCrossControl1.dx,
            afterCrossControl1.dy,
            afterCrossControl2.dx,
            afterCrossControl2.dy,
            point.dx,
            point.dy,
          );
        }
      }
    }
  }

  void _drawGradients(Canvas canvas, Size size, double zeroY, double yRange) {
    final screenPoints = spots.map((spot) {
      final x = _spotX(spot.x, size.width);
      final y = size.height - ((spot.y - minY) / yRange * size.height);
      return Offset(x, y);
    }).toList();

    final fill = Path();
    if (screenPoints.length == 1) {
      final p0 = screenPoints[0];
      fill.moveTo(p0.dx, zeroY);
      fill.lineTo(p0.dx, p0.dy);
      fill.lineTo(p0.dx, zeroY);
      fill.close();
    } else {
      fill.moveTo(screenPoints[0].dx, zeroY);
      fill.lineTo(screenPoints[0].dx, screenPoints[0].dy);
      _appendContinuousSmoothCurve(fill, screenPoints, zeroY);
      fill.lineTo(screenPoints.last.dx, zeroY);
      fill.close();
    }

    final greenGradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, zeroY),
      [
        kGainText.withValues(alpha: 0.35),
        kGainText.withValues(alpha: 0.1),
      ],
      [0.0, 1.0],
    );

    final greenPaint = Paint()
      ..shader = greenGradient
      ..style = PaintingStyle.fill;

    final redGradient = ui.Gradient.linear(
      Offset(0, zeroY),
      Offset(0, size.height),
      [
        kLossText.withValues(alpha: 0.1),
        kLossText.withValues(alpha: 0.35),
      ],
      [0.0, 1.0],
    );

    final redPaint = Paint()
      ..shader = redGradient
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, zeroY.clamp(0, size.height)));
    canvas.drawPath(fill, greenPaint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, zeroY, size.width, (size.height - zeroY).clamp(0, size.height)),
    );
    canvas.drawPath(fill, redPaint);
    canvas.restore();
  }

  void _drawPerformanceLine(
    Canvas canvas,
    Size size,
    double zeroY,
    double yRange,
  ) {
    if (spots.isEmpty) return;

    final screenPoints = spots.map((spot) {
      final x = _spotX(spot.x, size.width);
      final y = size.height - ((spot.y - minY) / yRange * size.height);
      return Offset(x, y);
    }).toList();

    final greenPath = Path();
    final redPath = Path();
    var greenStarted = false;
    var redStarted = false;

    for (var i = 0; i < screenPoints.length; i++) {
      final point = screenPoints[i];
      final isAboveZero = point.dy <= zeroY;

      if (i == 0) {
        if (isAboveZero) {
          greenPath.moveTo(point.dx, point.dy);
          greenStarted = true;
        } else {
          redPath.moveTo(point.dx, point.dy);
          redStarted = true;
        }
      } else {
        final prevPoint = screenPoints[i - 1];
        final wasAboveZero = prevPoint.dy <= zeroY;

        final controlPoint1 = Offset(
          prevPoint.dx + (point.dx - prevPoint.dx) / 3,
          prevPoint.dy,
        );
        final controlPoint2 = Offset(
          prevPoint.dx + 2 * (point.dx - prevPoint.dx) / 3,
          point.dy,
        );

        if (wasAboveZero && isAboveZero) {
          greenPath.cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            point.dx,
            point.dy,
          );
        } else if (!wasAboveZero && !isAboveZero) {
          redPath.cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            point.dx,
            point.dy,
          );
        } else {
          final crossX = prevPoint.dx +
              (point.dx - prevPoint.dx) *
                  ((zeroY - prevPoint.dy) / (point.dy - prevPoint.dy));

          final crossControlPoint1 = Offset(
            prevPoint.dx + (crossX - prevPoint.dx) / 3,
            prevPoint.dy,
          );
          final crossControlPoint2 = Offset(
            prevPoint.dx + 2 * (crossX - prevPoint.dx) / 3,
            zeroY,
          );

          if (wasAboveZero) {
            greenPath.cubicTo(
              crossControlPoint1.dx,
              crossControlPoint1.dy,
              crossControlPoint2.dx,
              crossControlPoint2.dy,
              crossX,
              zeroY,
            );
            redPath.moveTo(crossX, zeroY);
            redStarted = true;

            final afterCrossControl1 = Offset(crossX, zeroY);
            final afterCrossControl2 = Offset(
              crossX + (point.dx - crossX) / 2,
              point.dy,
            );
            redPath.cubicTo(
              afterCrossControl1.dx,
              afterCrossControl1.dy,
              afterCrossControl2.dx,
              afterCrossControl2.dy,
              point.dx,
              point.dy,
            );
          } else {
            redPath.cubicTo(
              crossControlPoint1.dx,
              crossControlPoint1.dy,
              crossControlPoint2.dx,
              crossControlPoint2.dy,
              crossX,
              zeroY,
            );
            greenPath.moveTo(crossX, zeroY);
            greenStarted = true;

            final afterCrossControl1 = Offset(crossX, zeroY);
            final afterCrossControl2 = Offset(
              crossX + (point.dx - crossX) / 2,
              point.dy,
            );
            greenPath.cubicTo(
              afterCrossControl1.dx,
              afterCrossControl1.dy,
              afterCrossControl2.dx,
              afterCrossControl2.dy,
              point.dx,
              point.dy,
            );
          }
        }
      }
    }

    final greenPaint = Paint()
      ..color = kGainText
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final redPaint = Paint()
      ..color = kLossText
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (greenStarted) {
      canvas.drawPath(greenPath, greenPaint);
    }
    if (redStarted) {
      canvas.drawPath(redPath, redPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardSparklinePainter oldDelegate) {
    return oldDelegate.spots != spots ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY;
  }
}
