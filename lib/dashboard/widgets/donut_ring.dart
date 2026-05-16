import 'package:flutter/material.dart';

import '../dashboard_tokens.dart';

/// Anneau type « donut » pour winrate / objectif / stats.
class DonutRing extends StatelessWidget {
  const DonutRing({
    super.key,
    required this.progress,
    required this.centerPrimary,
    this.centerSecondary,
    this.size = 72,
    this.strokeWidth = 6,
    this.ringColor,
    this.trackColor,
    this.onTap,
    this.showInnerSecondary = true,
  });

  final double progress;
  final String centerPrimary;
  final String? centerSecondary;
  final double size;
  final double strokeWidth;

  /// Arc de progression ; si `null`, [DashboardTokens.accent] (ex. WIN).
  final Color? ringColor;

  /// Piste de l’anneau (ex. gris sombre type maquette web).
  final Color? trackColor;

  /// Si false, le libellé [centerSecondary] n’est pas affiché dans l’anneau.
  final bool showInnerSecondary;

  /// Si non null, l’anneau entier est cliquable (ex. EM → État mental).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: trackColor ?? const Color(0xFF2A2A2A),
              valueColor: AlwaysStoppedAnimation<Color>(
                ringColor ?? DashboardTokens.accent,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerPrimary,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: size > 56 ? 13 : 11,
                    ),
              ),
              if (showInnerSecondary && centerSecondary != null)
                Text(
                  centerSecondary!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: DashboardTokens.muted,
                        fontSize: size > 56 ? 9 : 8,
                      ),
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
      label: centerSecondary ?? centerPrimary,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tap,
          borderRadius: BorderRadius.circular(size / 2),
          child: child,
        ),
      ),
    );
  }
}
