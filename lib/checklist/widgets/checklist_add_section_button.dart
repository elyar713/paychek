import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../checklist_tokens.dart';

/// Bouton pleine largeur, bordure **pointillÃ©e**, + Â« Ajouter une section Â».
class ChecklistAddSectionButton extends StatelessWidget {
  const ChecklistAddSectionButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedRoundedRectPainter(
            color: ChecklistTokens.addSectionStrokeColor,
            radius: 16,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 15,
                    color: ChecklistTokens.addSectionContentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l.checklistAddSection,
                  style: ChecklistTokens.addSectionTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(r);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      const dash = 6.0;
      const gap = 4.0;
      while (d < metric.length) {
        final next = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, next), paint);
        d = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}



