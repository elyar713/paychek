import 'package:flutter/material.dart';

import '../analyse_models.dart';
import '../analyse_tokens.dart';
import 'analyse_equal_chips_row.dart';
import 'analyse_text_field.dart';

/// Ligne prix + Tenu / Cassé pour un support ou une résistance ajoutée (sans dialogue).
class AnalyseExtraStructureLine extends StatelessWidget {
  const AnalyseExtraStructureLine({
    super.key,
    required this.label,
    /// Couleur du libellé (ex. vert support / rouge résistance) pour repérage rapide.
    this.labelAccent,
    required this.price,
    required this.tenue,
    required this.onPriceChanged,
    required this.onTenueChanged,
    this.onRemove,
    /// Affichage en colonne étroite (grille 4 : 1ʳᵉ paire de rajouts).
    this.compactGrid = false,
  });

  final String label;
  final Color? labelAccent;
  final String price;
  final AnalyseStructureTenue? tenue;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<AnalyseStructureTenue?> onTenueChanged;
  /// Mode édition (crayon) : retire la ligne rajoutée.
  final VoidCallback? onRemove;
  final bool compactGrid;

  @override
  Widget build(BuildContext context) {
    final baseLabelStyle = compactGrid
        ? AnalyseTokens.inlineMutedStyle.copyWith(fontSize: 9)
        : AnalyseTokens.inlineMutedStyle;
    final labelStyle = labelAccent != null
        ? baseLabelStyle.copyWith(
            color: labelAccent,
            fontWeight: FontWeight.w800,
          )
        : baseLabelStyle;
    final gap1 = compactGrid ? 4.0 : 6.0;
    final gap2 = compactGrid ? 6.0 : 8.0;
    return Padding(
      padding: EdgeInsets.only(bottom: compactGrid ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                SizedBox(height: gap1),
                AnalyseTextField(
                  hintText: 'Prix',
                  value: price,
                  onChanged: onPriceChanged,
                  compact: true,
                ),
                SizedBox(height: gap2),
                AnalyseEqualChipsRow<AnalyseStructureTenue>(
                  allowDeselect: true,
                  value: tenue,
                  onChanged: onTenueChanged,
                  options: [
                    AnalyseEqualChipOption(
                      value: AnalyseStructureTenue.tenu,
                      label: 'Tenu',
                      accent: AnalyseTokens.accentGreen,
                    ),
                    AnalyseEqualChipOption(
                      value: AnalyseStructureTenue.casse,
                      label: 'Cassé',
                      accent: AnalyseTokens.accentRed,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onRemove != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AnalyseTokens.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
