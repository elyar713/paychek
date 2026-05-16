import 'package:flutter/material.dart';

/// Barre horizontale (Stratégie, Psychologie) : titre, note, progression.
class QuestionnaireLinearStatBar extends StatelessWidget {
  const QuestionnaireLinearStatBar({
    super.key,
    required this.title,
    required this.note,
    required this.value,
    this.barColor,
    this.gradient,
  }) : assert(
          barColor != null || gradient != null,
          'Fournir barColor ou gradient',
        );

  final String title;
  final String note;
  /// 0.0 – 1.0
  final double value;
  final Color? barColor;
  final Gradient? gradient;

  /// Barre blanche (Stratégie).
  factory QuestionnaireLinearStatBar.strategy({
    Key? key,
    required String title,
    required String note,
    required double value,
  }) {
    return QuestionnaireLinearStatBar(
      key: key,
      title: title,
      note: note,
      value: value,
      barColor: Colors.white,
    );
  }

  /// Barre orange en dégradé (Psychologie).
  factory QuestionnaireLinearStatBar.psychology({
    Key? key,
    required String title,
    required String note,
    required double value,
  }) {
    return QuestionnaireLinearStatBar(
      key: key,
      title: title,
      note: note,
      value: value,
      gradient: const LinearGradient(
        colors: [
          Color(0xFFFFB74D),
          Color(0xFFFF9800),
          Color(0xFFFF6D00),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                  height: 1.25,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              note,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 5,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0x22FFFFFF)),
                FractionallySizedBox(
                  widthFactor: v,
                  alignment: Alignment.centerLeft,
                  child: gradient != null
                      ? DecoratedBox(
                          decoration: BoxDecoration(gradient: gradient),
                        )
                      : ColoredBox(color: barColor!),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
