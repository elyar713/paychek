import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'checklist_prompts.dart';
import 'checklist_tokens.dart';

/// Anneau 0â€“100 % sur **toute** la checklist (rouge â†’ vert), Â« CL Â» sous le %.
///
/// Par dÃ©faut [size] = [ChecklistTokens.sectionProgressRingSize] (page checklist).
/// Une taille plus petite (ex. mÃªme que [DonutRing] sur la carte solde) conserve les mÃªmes proportions.
class ChecklistProgressRing extends StatelessWidget {
  const ChecklistProgressRing({
    super.key,
    required this.percent,
    this.size,
    this.strokeWidth,
    this.onTap,
    this.hideInnerClLabel = false,
  });

  /// 0â€“100.
  final int percent;

  /// Masque le « CL » sous le pourcentage (libellé affiché à l’extérieur du widget).
  final bool hideInnerClLabel;

  /// Largeur / hauteur du widget. DÃ©faut : taille Â« pleine page Â» checklist.
  final double? size;

  /// Ã‰paisseur du trait. Si `null`, proportionnelle Ã  [size] (comme le design 88 px).
  /// Sur la carte solde, utiliser la mÃªme valeur que [DonutRing.strokeWidth] (ex. `4`).
  final double? strokeWidth;

  /// Si non null, lâ€™anneau entier est cliquable (ex. CL â†’ Checklist).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = percent.clamp(0, 100);
    final d = size ?? ChecklistTokens.sectionProgressRingSize;
    final scale = d / ChecklistTokens.sectionProgressRingSize;
    final stroke =
        strokeWidth ?? ChecklistTokens.sectionProgressRingStroke * scale;
    final gap = 2.0 * scale;

    /// MÃªme typo que [DonutRing] (carte Capital : WIN / EM) quand lâ€™anneau est petit.
    final useDonutTypography = d <= 56;
    final TextStyle pctStyle;
    final TextStyle clStyle;
    final double labelGap;
    if (useDonutTypography) {
      // AlignÃ© sur [DonutRing] pour tailles â‰¤ 56 (ex. carte Capital Ã  45 px).
      pctStyle = (Theme.of(context).textTheme.labelLarge ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            decoration: TextDecoration.none,
          );
      clStyle = (Theme.of(context).textTheme.labelSmall ?? const TextStyle()).copyWith(
            color: DashboardTokens.muted,
            fontSize: 8,
            decoration: TextDecoration.none,
          );
      labelGap = 0;
    } else {
      pctStyle = ChecklistTokens.sectionProgressPercentStyle.copyWith(
        fontSize: ChecklistTokens.sectionProgressPercentStyle.fontSize! * scale,
        decoration: TextDecoration.none,
      );
      clStyle = ChecklistTokens.sectionProgressClStyle.copyWith(
        fontSize: ChecklistTokens.sectionProgressClStyle.fontSize! * scale,
        decoration: TextDecoration.none,
      );
      labelGap = gap;
    }

    final child = SizedBox(
      width: d,
      height: d,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(d),
            painter: _ChecklistProgressRingPainter(
              percent: p,
              ringStrokeWidth: stroke,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ChecklistPrompts.progressRingPercentLabel(p),
                style: pctStyle,
              ),
              if (!hideInnerClLabel) SizedBox(height: labelGap),
              if (!hideInnerClLabel)
                Text(
                  l.checklistProgressCl,
                  style: clStyle,
                ),
            ],
          ),
        ],
      ),
    );

    final tap = onTap;
    if (tap == null) return child;

    return Semantics(
      button: true,
      label: '${l.checklistPageTitle} ${ChecklistPrompts.progressRingPercentLabel(p)}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tap,
          borderRadius: BorderRadius.circular(d / 2),
          child: child,
        ),
      ),
    );
  }
}

class _ChecklistProgressRingPainter extends CustomPainter {
  _ChecklistProgressRingPainter({
    required this.percent,
    required this.ringStrokeWidth,
  });

  final int percent;
  final double ringStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = ringStrokeWidth;
    // MÃªme gÃ©omÃ©trie que [CircularProgressIndicator] (trait centrÃ© sur le cercle
    // inscrit au carrÃ©), pour aligner avec [DonutRing] sur la carte Capital.
    final r = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    final track = Paint()
      ..color = ChecklistTokens.sectionProgressRingTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = s
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    final t = percent / 100.0;
    if (t <= 0) return;

    final arcColor = Color.lerp(
      ChecklistTokens.sectionProgressRingRed,
      ChecklistTokens.sectionProgressRingGreen,
      t,
    )!;

    final progress = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = s
      ..strokeCap = StrokeCap.round;

    const start = -math.pi / 2;
    final sweep = 2 * math.pi * t;
    canvas.drawArc(rect, start, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant _ChecklistProgressRingPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.ringStrokeWidth != ringStrokeWidth;
  }
}



