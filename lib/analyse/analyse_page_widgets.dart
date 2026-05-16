import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_text_field.dart';

/// No-op pour champs en lecture seule / placeholders.
void analysePageNoop(String _) {}

void analysePageNoopBool(bool _) {}

class AnalyseSquareIconButton extends StatelessWidget {
  const AnalyseSquareIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFF9A9A9A),
    this.boxSize = 31,
    this.iconSize = 14,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final double boxSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final r = (boxSize * 0.33).clamp(8.0, 12.0);
    return Material(
      color: AnalyseTokens.chipBg,
      borderRadius: BorderRadius.circular(r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r),
        child: Container(
          width: boxSize,
          height: boxSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
          ),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}

class AnalyseSoftChip extends StatelessWidget {
  const AnalyseSoftChip({
    super.key,
    required this.label,
    required this.onTap,
    this.compact = false,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  /// Pilule plus petite (ex. section Indicateurs).
  final bool compact;
  /// Setup indicateurs : outil inclus dans le rapport.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 12.0 : 14.0;
    final hPad = compact ? 10.0 : 16.0;
    final vPad = compact ? 7.0 : 12.0;
    final fontSize = compact ? 11.0 : 13.0;

    final bgColor = selected
        ? const Color(0xFF0F2418)
        : AnalyseTokens.chipBg;
    final textColor =
        selected ? AnalyseTokens.accentGreen : const Color(0xFFDFDFDF);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

class AnalysePriceBox extends StatelessWidget {
  const AnalysePriceBox({
    super.key,
    required this.label,
    required this.accent,
    this.value = '',
    required this.onChanged,
    required this.tested,
    required this.onTestedChanged,
    /// Grille 4 colonnes (support / rÃ©sistance + 1Ê³áµ‰ paire de rajouts) : marges rÃ©duites.
    this.narrow = false,
  });

  final String label;
  final Color accent;
  final String value;
  final ValueChanged<String> onChanged;
  final bool tested;
  final ValueChanged<bool> onTestedChanged;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pad = narrow
        ? const EdgeInsets.fromLTRB(6, 6, 6, 6)
        : const EdgeInsets.fromLTRB(10, 8, 10, 8);
    final labelSize = narrow ? 9.0 : 10.0;
    final testedSize = narrow ? 9.0 : 10.0;
    final gapAfterLabel = narrow ? 4.0 : 6.0;
    final boxBg = Color.alphaBlend(
      accent.withValues(alpha: 0.14),
      AnalyseTokens.fieldBg,
    );
    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: accent,
            ),
          ),
          SizedBox(height: gapAfterLabel),
          AnalyseTextField(
            hintText: l.analyseHintPriceDots,
            value: value,
            onChanged: onChanged,
            compact: true,
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => onTestedChanged(!tested),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: tested,
                        onChanged: (v) => onTestedChanged(v ?? false),
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        side: const BorderSide(color: Color(0xFF333333)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: narrow ? 6 : 8),
                if (narrow)
                  Expanded(
                    child: Text(
                      l.analyseTestedTwice,
                      style: TextStyle(
                        color: AnalyseTokens.muted2,
                        fontWeight: FontWeight.w600,
                        fontSize: testedSize,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      softWrap: true,
                    ),
                  )
                else
                  Text(
                    l.analyseTestedTwice,
                    style: TextStyle(
                      color: AnalyseTokens.muted2,
                      fontWeight: FontWeight.w600,
                      fontSize: testedSize,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



