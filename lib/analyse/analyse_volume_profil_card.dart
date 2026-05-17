import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'analyse_controller.dart';
import 'analyse_page_widgets.dart';
import 'analyse_tokens.dart';
import 'widgets/analyse_card.dart';
import 'widgets/analyse_collapsible_section_body.dart';
import 'widgets/analyse_inline_pill_and_add_row.dart';
import 'widgets/analyse_section_title_row.dart';
import 'widgets/analyse_structure_tf_picker.dart';
import 'widgets/analyse_text_field.dart';

/// Carte « Profil de Volume ».
class AnalyseVolumeProfilCard extends StatelessWidget {
  const AnalyseVolumeProfilCard({
    super.key,
    required this.controller,
  });

  final AnalyseController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = controller;
    return AnalyseCard(
      editorSection: AnalyseEditorSection.profilVolume,
      child: ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnalyseSectionTitleRow(
                title: l.analyseCardVolumeProfile,
                icon: Icons.bar_chart,
                iconColor: AnalyseEditorSection.profilVolume.sectionAccent,
                enabled: c.volumeProfileEnabled,
                onEnabledChanged: (v) => c.volumeProfileEnabled = v,
              ),
              AnalyseCollapsibleSectionBody(
                expanded: c.volumeProfileEnabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      height: AnalyseTextField.compactRowHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 88,
                            height: AnalyseTextField.compactRowHeight,
                            child: AnalyseInlinePill(
                              label: c.volumeProfileTf,
                              icon: Icons.keyboard_arrow_down,
                              compact: true,
                              height: AnalyseTextField.compactRowHeight,
                              onPressed: (ctx) => showAnalyseStructureTfPicker(
                                ctx,
                                c,
                                forVolumeProfileSection: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnalyseSoftChip(
                            compact: true,
                            label: l.analyseVolumeZoneLabel,
                            selected: c.volumeProfileZoneActive,
                            onTap: () => c.volumeProfileZoneActive =
                                !c.volumeProfileZoneActive,
                          ),
                        ],
                      ),
                    ),
                    if (c.volumeProfileZoneActive) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l.analyseVolumeZoneFrom,
                                  style: AnalyseTokens.volumeProfileLabelStyle,
                                ),
                                const SizedBox(height: 8),
                                AnalyseTextField(
                                  hintText: l.analyseHintPriceDots,
                                  value: c.volumeProfileZoneFrom,
                                  onChanged: (v) => c.volumeProfileZoneFrom = v,
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l.analyseVolumeZoneTo,
                                  style: AnalyseTokens.volumeProfileLabelStyle,
                                ),
                                const SizedBox(height: 8),
                                AnalyseTextField(
                                  hintText: l.analyseHintPriceDots,
                                  value: c.volumeProfileZoneTo,
                                  onChanged: (v) => c.volumeProfileZoneTo = v,
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'POC',
                                style: AnalyseTokens.volumeProfileLabelStyle,
                              ),
                              const SizedBox(height: 8),
                              AnalyseTextField(
                                hintText: l.analyseHintPriceDots,
                                value: c.volumeProfilePoc,
                                onChanged: (v) => c.volumeProfilePoc = v,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'VAH',
                                style: AnalyseTokens.volumeProfileLabelStyle,
                              ),
                              const SizedBox(height: 8),
                              AnalyseTextField(
                                hintText: l.analyseHintPriceDots,
                                value: c.volumeProfileVah,
                                onChanged: (v) => c.volumeProfileVah = v,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'VAL',
                                style: AnalyseTokens.volumeProfileLabelStyle,
                              ),
                              const SizedBox(height: 8),
                              AnalyseTextField(
                                hintText: l.analyseHintPriceDots,
                                value: c.volumeProfileVal,
                                onChanged: (v) => c.volumeProfileVal = v,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(l.analyseNotesVolumeProfile, style: AnalyseTokens.labelStyle),
                    const SizedBox(height: 8),
                    AnalyseTextField(
                      hintText: l.analyseHintNotesDots,
                      value: c.notesVolumeProfile,
                      minLines: 3,
                      maxLines: 4,
                      onChanged: (v) => c.notesVolumeProfile = v,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
