import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../dashboard/dashboard_tokens.dart';
import '../calculatrice_format.dart';
import 'calculatrice_common_widgets.dart';

class EquityCurveGraphCard extends StatefulWidget {
  const EquityCurveGraphCard({super.key, required this.points});
  final List<double> points;

  @override
  State<EquityCurveGraphCard> createState() => _EquityCurveGraphCardState();
}

class _EquityCurveGraphCardState extends State<EquityCurveGraphCard> {
  int? _selectedIndex;

  void _clearSelection() => setState(() => _selectedIndex = null);

  void _selectFromLocal(Offset local, Size size) {
    final points = widget.points;
    if (points.length < 2) return;

    const padLeft = 44.0;
    const pad = 10.0;
    final plot = Rect.fromLTWH(
      padLeft,
      pad,
      size.width - padLeft - pad,
      size.height - pad * 2,
    );
    if (!plot.contains(local)) return;

    final t = ((local.dx - plot.left) / plot.width).clamp(0.0, 1.0);
    final idx = (t * (points.length - 1)).round();
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: SizedBox(
        height: 240,
        child: widget.points.isEmpty
            ? Center(
                child: Text(
                  '—',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: DashboardTokens.muted),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _selectFromLocal(d.localPosition, size),
                    onPanStart: (d) => _selectFromLocal(d.localPosition, size),
                    onPanUpdate: (d) => _selectFromLocal(d.localPosition, size),
                    onPanEnd: (_) => _clearSelection(),
                    child: CustomPaint(
                      painter: _EquityCurvePainter(
                        points: widget.points,
                        selectedIndex: _selectedIndex,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EquityCurvePainter extends CustomPainter {
  _EquityCurvePainter({required this.points, required this.selectedIndex});
  final List<double> points;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final minV = points.reduce(math.min);
    final maxV = points.reduce(math.max);
    final span = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);

    const pad = 10.0;
    const padLeft = 44.0;
    final plot = Rect.fromLTWH(
      padLeft,
      pad,
      size.width - padLeft - pad,
      size.height - pad * 2,
    );

    final grid = Paint()
      ..color = DashboardTokens.muted.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = plot.top + plot.height * (i / 4.0);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
    }
    for (var i = 0; i <= 6; i++) {
      final x = plot.left + plot.width * (i / 6.0);
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), grid);
    }

    _drawYLabels(canvas, plot, minV, maxV);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = plot.left + (i / (points.length - 1)) * plot.width;
      final norm = (points[i] - minV) / span;
      final y = plot.bottom - norm * plot.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, stroke);

    final dot = Paint()..color = DashboardTokens.accentDeep;
    canvas.drawCircle(
      Offset(plot.right, plot.bottom - ((points.last - minV) / span) * plot.height),
      3.5,
      dot,
    );

    final si = selectedIndex;
    if (si != null && si >= 0 && si < points.length) {
      final x = plot.left + (si / (points.length - 1)) * plot.width;
      final norm = (points[si] - minV) / span;
      final y = plot.bottom - norm * plot.height;

      final vLine = Paint()
        ..color = DashboardTokens.muted.withValues(alpha: 0.35)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), vLine);
      canvas.drawCircle(Offset(x, y), 4.5, dot);

      _drawTooltip(canvas, plot: plot, anchor: Offset(x, y), tradeIndex: si, value: points[si]);
    }
  }

  void _drawYLabels(Canvas canvas, Rect plot, double minV, double maxV) {
    final style = TextStyle(
      color: DashboardTokens.muted.withValues(alpha: 0.85),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    final tpTop = TextPainter(
      text: TextSpan(text: fmtMoneyCompact(maxV), style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final tpBot = TextPainter(
      text: TextSpan(text: fmtMoneyCompact(minV), style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    tpTop.paint(canvas, Offset(6, plot.top - 2));
    tpBot.paint(canvas, Offset(6, plot.bottom - tpBot.height + 2));
  }

  void _drawTooltip(
    Canvas canvas, {
    required Rect plot,
    required Offset anchor,
    required int tradeIndex,
    required double value,
  }) {
    final labelStyle = const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    );
    final subStyle = TextStyle(
      color: DashboardTokens.muted.withValues(alpha: 0.95),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    final tpTitle = TextPainter(
      text: TextSpan(text: 'Trade $tradeIndex', style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final tpSub = TextPainter(
      text: TextSpan(text: r'$ ' + fmtMoney(value), style: subStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    const pad = 8.0;
    final w = math.max(tpTitle.width, tpSub.width) + pad * 2;
    final h = tpTitle.height + tpSub.height + pad * 2 + 2;

    var left = anchor.dx - w / 2;
    left = left.clamp(plot.left, plot.right - w);

    var top = anchor.dy - h - 10;
    if (top < plot.top) top = anchor.dy + 10;
    if (top + h > plot.bottom) top = plot.bottom - h;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      const Radius.circular(12),
    );

    final bg = Paint()..color = const Color(0xFF0F0F0F).withValues(alpha: 0.92);
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = DashboardTokens.muted.withValues(alpha: 0.25);

    canvas.drawRRect(r, bg);
    canvas.drawRRect(r, border);
    tpTitle.paint(canvas, Offset(left + pad, top + pad));
    tpSub.paint(canvas, Offset(left + pad, top + pad + tpTitle.height + 2));
  }

  @override
  bool shouldRepaint(covariant _EquityCurvePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.selectedIndex != selectedIndex;
}

