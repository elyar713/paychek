import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_impact_modal.dart';
import 'analyse_page_content_contexte_duplicate.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_confidence_slider.dart';
import 'widgets/analyse_text_field.dart';

/// Suite du bloc « Tendance » : copies, note, confiance feuille (grille direction / tendance / TF / phase dans le corps au-dessus).
class AnalyseFeuilleContexteCardBodyLower extends StatelessWidget {
  const AnalyseFeuilleContexteCardBodyLower({
    super.key,
    required this.controller,
    required this.pillsEditMode,
  });

  final AnalyseController controller;
  final bool pillsEditMode;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (c.contexteSnapshots.isNotEmpty) ...[
          const SizedBox(height: 14),
          for (var i = 0; i < c.contexteSnapshots.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            AnalyseContexteDuplicateBlock(
              key: ValueKey<String>('ctx_dup_$i'),
              controller: c,
              snapshotIndex: i,
              indexLabel: i + 1,
              pillsEditMode: pillsEditMode,
              onRemoveDuplicate: pillsEditMode
                  ? () => c.removeContexteSnapshot(i)
                  : null,
            ),
          ],
        ],
        const SizedBox(height: 14),
        Text(
          l.analyseNote,
          style: AnalyseTokens.labelStyle,
        ),
        const SizedBox(height: 8),
        AnalyseTextField(
          hintText: l.analyseMovementDetailsHint,
          value: c.notesTimeframe,
          minLines: 3,
          maxLines: 4,
          onChanged: (v) => c.notesTimeframe = v,
        ),
        const SizedBox(height: 14),
        AnalyseConfidenceSlider(
          value: c.confidenceFeuille,
          onChanged: (v) => c.confidenceFeuille = v,
          impactPercent: c.impactFeuilleDisplay,
          onImpactTap: () {
            final f = c.impactFeuille;
            final s = c.impactStructure;
            final i = c.impactIndicators;
            final m = c.impactSmc;
            showAnalyseImpactModal(
              context,
              label: l.analyseImpactFeuille,
              initialImpact: f,
              onApply: (w) => c.impactFeuille = w,
              onCancelRestore: () => c.restoreImpactsSnapshot(f, s, i, m),
            );
          },
        ),
      ],
    );
  }
}



