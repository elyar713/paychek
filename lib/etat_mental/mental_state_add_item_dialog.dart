import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import 'mental_state_controller.dart';
import 'mental_state_models.dart';
import 'mental_state_tokens.dart';

enum MentalAddKind { routine, metric, emotion }

Future<void> showMentalAddItemDialog(
  BuildContext context,
  MentalAddKind kind,
  MentalStateController c,
) async {
  final nameC = TextEditingController();
  double addW = 50;
  bool addInverse = false;

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setM) {
          final l = AppLocalizations.of(context)!;
          final pct = addW.round().clamp(0, 100);

          late IconData titleIcon;
          late String title;
          late String fieldLabel;
          late String hint;
          switch (kind) {
            case MentalAddKind.routine:
              titleIcon = LucideIcons.sliders;
              title = l.mentalNewRoutine;
              fieldLabel = l.mentalRoutineFieldLabel;
              hint = l.mentalHintRoutine;
              break;
            case MentalAddKind.metric:
              titleIcon = LucideIcons.activity;
              title = l.mentalNewMetric;
              fieldLabel = l.mentalMetricFieldLabel;
              hint = l.mentalHintMetric;
              break;
            case MentalAddKind.emotion:
              titleIcon = LucideIcons.smile;
              title = l.mentalNewEmotion;
              fieldLabel = l.mentalEmotionFieldLabel;
              hint = l.mentalHintEmotion;
              break;
          }

          return Dialog(
            backgroundColor: const Color(0xFF0a0a0a),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF222222)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(titleIcon, size: 16, color: MentalStateTokens.matteGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                          IconButton(
                            tooltip: '',
                            icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF555555)),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fieldLabel,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameC,
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF666666)),
                          filled: true,
                          fillColor: const Color(0xFF111111),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF222222))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MentalStateTokens.matteGreen)),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: Color(0xFF1a1a1a)),
                      ),
                      Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF222222)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: addInverse ? const Color(0xFF111111) : MentalStateTokens.matteGreen,
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    onTap: () => setM(() => addInverse = false),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Center(
                                        child: Text(
                                          l.mentalPositive,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: addInverse ? const Color(0xFF666666) : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Material(
                                  color: addInverse ? MentalStateTokens.matteRed : const Color(0xFF111111),
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    onTap: () => setM(() => addInverse = true),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Center(
                                        child: Text(
                                          l.mentalNegative,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: addInverse ? Colors.black : const Color(0xFF666666),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            '$pct%',
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: MentalStateTokens.matteGreen),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
                        child: Slider(
                          value: addW.clamp(0, 100),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          activeColor: MentalStateTokens.matteGreen,
                          inactiveColor: MentalStateTokens.trackBg,
                          onChanged: (v) => setM(() => addW = v),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF888888),
                                side: const BorderSide(color: Color(0xFF333333)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(l.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                final name = nameC.text.trim();
                                if (name.isEmpty) {
                                  return;
                                }
                                final id = 'n${DateTime.now().millisecondsSinceEpoch}';
                                if (kind == MentalAddKind.routine) {
                                  c.addFactorWithShare(
                                    MentalStateMetric(
                                      id: id,
                                      label: name,
                                      value: 50,
                                      weight: 0,
                                      inverse: addInverse,
                                      barColor: addInverse ? MentalStateTokens.matteRed : MentalStateTokens.matteGreen,
                                      isMainSlider: true,
                                    ),
                                    addW,
                                  );
                                } else if (kind == MentalAddKind.metric) {
                                  c.addMomentWithShare(
                                    MentalStateMetric(
                                      id: id,
                                      label: name,
                                      value: 50,
                                      weight: 0,
                                      inverse: addInverse,
                                      barColor: addInverse ? MentalStateTokens.matteRed : MentalStateTokens.matteGreen,
                                    ),
                                    addW,
                                  );
                                } else {
                                  c.addEmotionWithShare(
                                    MentalStateEmotion(
                                      id: id,
                                      label: name,
                                      value: 50,
                                      weight: 0,
                                      inverse: addInverse,
                                    ),
                                    addW,
                                  );
                                  c.selectedEmotionIds.add(
                                    c.emotions[c.emotions.length - 1].id,
                                  );
                                }
                                c.touch();
                                Navigator.pop(ctx);
                              },
                              child: Text(l.actionAdd),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}



