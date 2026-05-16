import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import 'analyse_tokens.dart';

Future<void> showAnalyseImpactModal(
  BuildContext context, {
  required String label,
  required int initialImpact,
  required ValueChanged<int> onApply,
  required VoidCallback onCancelRestore,
}) async {
  double w = initialImpact.clamp(0, 100).toDouble();

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModal) {
          final l = AppLocalizations.of(context)!;
          final pct = w.round().clamp(0, 100);

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.settings, size: 16, color: Color(0xFF666666)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              l.analyseImpactModalTitle,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: '',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                          icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF555555)),
                          onPressed: () {
                            onCancelRestore();
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.analyseImpactModalBlurb,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF888888),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$pct%',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AnalyseTokens.matteText),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        activeTrackColor: const Color(0xFF333333),
                        inactiveTrackColor: const Color(0xFF141414),
                        thumbColor: Colors.white,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: w.clamp(0, 100),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (v) => setModal(() {
                          w = v;
                          onApply(w.round().clamp(0, 100));
                        }),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              onCancelRestore();
                              Navigator.pop(ctx);
                            },
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
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l.confirm),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}




