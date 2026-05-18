import 'package:flutter/material.dart';

import '../calendrier/calendrier_constants.dart';
import '../calendrier/calendrier_utils.dart' as cal;

/// Style d’une case jour : contour + texte selon P&L.
class ChecklistCalendarDayStyle {
  const ChecklistCalendarDayStyle({
    this.isEmpty = false,
    required this.borderColor,
    this.fillColor,
    required this.labelColor,
  });

  /// Aucun trade ni case cochée : pas de contour.
  final bool isEmpty;
  final Color borderColor;
  final Color? fillColor;
  final Color labelColor;

  static ChecklistCalendarDayStyle inactive({required bool isFuture}) =>
      ChecklistCalendarDayStyle(
        isEmpty: true,
        borderColor: Colors.transparent,
        labelColor: isFuture ? const Color(0xFF3D3D3D) : const Color(0xFF6B6B6B),
      );
}

/// Contour + libellé : vert (gain), rouge (perte), anthracite (sans P&L / checklist seule).
/// Sans trade **et** sans checklist cochée → case vide (pas de contour).
ChecklistCalendarDayStyle checklistCalendarDayStyle({
  required DateTime date,
  required Map<int, double> pnlByDay,
  required Map<int, int> tradeCountByDay,
  required bool hasChecklistChecked,
  bool isFuture = false,
}) {
  if (isFuture) {
    return ChecklistCalendarDayStyle.inactive(isFuture: true);
  }

  const eps = 1e-9;
  const anthraciteLabel = Color(0xFF6E6E6E);
  /// Contour anthracite discret (50 % d’opacité).
  const anthraciteBorder = Color(0x806E6E6E);
  final k = cal.dayKey(date);
  final count = tradeCountByDay[k] ?? 0;
  if (count == 0 && !hasChecklistChecked) {
    return ChecklistCalendarDayStyle.inactive(isFuture: false);
  }
  if (count == 0) {
    return const ChecklistCalendarDayStyle(
      borderColor: anthraciteBorder,
      fillColor: Color(0xFF121212),
      labelColor: anthraciteLabel,
    );
  }
  final net = pnlByDay[k];
  if (net == null || net.abs() < eps) {
    return const ChecklistCalendarDayStyle(
      borderColor: anthraciteBorder,
      fillColor: Color(0xFF121212),
      labelColor: anthraciteLabel,
    );
  }
  if (net > 0) {
    return ChecklistCalendarDayStyle(
      borderColor: kGainText,
      fillColor: kGainFill,
      labelColor: kGainText,
    );
  }
  return ChecklistCalendarDayStyle(
    borderColor: kLossText,
    fillColor: kLossFill,
    labelColor: kLossText,
  );
}
