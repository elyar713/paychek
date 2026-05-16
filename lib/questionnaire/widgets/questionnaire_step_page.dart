import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

import 'questionnaire_option_card.dart';

/// Titre + slogan optionnel + liste de cartes.
class QuestionnaireStepPage extends StatelessWidget {
  const QuestionnaireStepPage({
    super.key,
    required this.title,
    this.slogan,
    this.useMPlus2ForSlogan = false,
    required this.options,
    this.multiSelect = false,
    this.selectedIndex,
    this.selectedIndices = const {},
    required this.onSelect,
  });

  final String title;
  final String? slogan;
  /// Questionnaire 1 : slogan sous-titre en M PLUS 2.
  final bool useMPlus2ForSlogan;
  final List<QuestionnaireOptionData> options;
  /// Sélection unique : index choisi (ignoré si [multiSelect]).
  final int? selectedIndex;
  /// Sélection multiple : indices choisis.
  final Set<int> selectedIndices;
  final bool multiSelect;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWideWeb = kIsWeb && w >= 900;
    final contentMaxWidth = isWideWeb ? 720.0 : double.infinity;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isWideWeb ? 20 : 24, 8, isWideWeb ? 20 : 24, isWideWeb ? 20 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      fontSize: isWideWeb ? 34 : null,
                      color: Colors.white,
                    ),
              ),
              if (slogan != null) ...[
                const SizedBox(height: 4),
                Text(
                  slogan!,
                  style: useMPlus2ForSlogan
                      ? GoogleFonts.mPlus2(
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                          fontSize: isWideWeb ? 11 : 12,
                          height: 1.3,
                        )
                      : Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                            fontSize: isWideWeb ? 11 : 12,
                            height: 1.3,
                          ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: isWideWeb ? 46 : 54,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ],
              SizedBox(height: isWideWeb ? 16 : 22),
              for (var i = 0; i < options.length; i++)
                QuestionnaireOptionCard(
                  data: options[i],
                  selected: multiSelect ? selectedIndices.contains(i) : selectedIndex == i,
                  onTap: () => onSelect(i),
                  compact: isWideWeb,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
