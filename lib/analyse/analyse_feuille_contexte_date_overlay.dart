import 'package:flutter/material.dart';

import 'analyse_controller.dart';
import 'analyse_tokens.dart';

OverlayEntry buildFeuilleContexteDatePickerOverlayEntry({
  required LayerLink layerLink,
  required AnalyseController controller,
  required VoidCallback onDismiss,
}) {
  return OverlayEntry(
    builder: (ctx) {
      final c = controller;
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.35)),
            ),
          ),
          CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 4),
            child: Material(
              elevation: 12,
              color: const Color(0xFF141414),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: ThemeData.dark(useMaterial3: true).copyWith(
                  visualDensity: VisualDensity.compact,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AnalyseTokens.accentGreen,
                    brightness: Brightness.dark,
                    surface: const Color(0xFF141414),
                  ),
                  datePickerTheme: DatePickerThemeData(
                    dayStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AnalyseTokens.matteText,
                      height: 1.05,
                    ),
                    weekdayStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AnalyseTokens.muted2,
                      height: 1.0,
                    ),
                    headerHelpStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AnalyseTokens.matteText,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: 204,
                  height: 232,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 300,
                      child: CalendarDatePicker(
                        initialDate: c.contexteAnalyseDate,
                        firstDate: DateTime(2020, 1, 1),
                        lastDate: DateTime(2100, 12, 31),
                        onDateChanged: (d) {
                          c.contexteAnalyseDate = d;
                          onDismiss();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
