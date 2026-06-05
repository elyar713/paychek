import 'package:flutter/material.dart';

import '../analyse_controller.dart';
import '../analyse_tokens.dart';

/// Petit carré de routine (hors PDF) sur un rapport figé.
class AnalyseReportPrepCheckBox extends StatelessWidget {
  const AnalyseReportPrepCheckBox({
    super.key,
    required this.checked,
    required this.onToggle,
  });

  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: AnalysePrepCheckBox.size,
            height: AnalysePrepCheckBox.size,
            decoration: BoxDecoration(
              color: checked
                  ? AnalyseTokens.accentGreen.withValues(alpha: 0.18)
                  : AnalyseTokens.inputBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: checked
                    ? AnalyseTokens.accentGreen
                    : AnalyseTokens.cardBorder,
                width: checked ? 1.5 : 1,
              ),
            ),
            child: checked
                ? Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: AnalyseTokens.accentGreen,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// Petit carré de préparation (hors PDF) devant un bloc du générateur.
class AnalysePrepCheckBox extends StatelessWidget {
  const AnalysePrepCheckBox({
    super.key,
    required this.controller,
    required this.prepId,
  });

  final AnalyseController controller;
  final String prepId;

  static const double size = 18;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final on = controller.isPrepChecked(prepId);
        return Semantics(
          checked: on,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.togglePrepCheck(prepId),
              borderRadius: BorderRadius.circular(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: on
                      ? AnalyseTokens.accentGreen.withValues(alpha: 0.18)
                      : AnalyseTokens.inputBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: on
                        ? AnalyseTokens.accentGreen
                        : AnalyseTokens.cardBorder,
                    width: on ? 1.5 : 1,
                  ),
                ),
                child: on
                    ? Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: AnalyseTokens.accentGreen,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Ligne : case + libellé (+ contenu optionnel en dessous).
class AnalysePrepFieldRow extends StatelessWidget {
  const AnalysePrepFieldRow({
    super.key,
    required this.controller,
    required this.prepId,
    required this.label,
    this.child,
  });

  final AnalyseController controller;
  final String prepId;
  final String label;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnalysePrepCheckBox(controller: controller, prepId: prepId),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AnalyseTokens.oledMicroLabel.copyWith(
                  color: AnalyseTokens.zinc400,
                ),
              ),
            ),
          ],
        ),
        if (child != null) ...[
          const SizedBox(height: 8),
          child!,
        ],
      ],
    );
  }
}
