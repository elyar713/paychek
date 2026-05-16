import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';

/// Insère [SizedBox] + [Divider] entre chaque widget (sections discipline visibles).
List<Widget> ajouterTradeDisciplineSectionsWithSeparators(
  List<Widget> sections,
) {
  final out = <Widget>[];
  for (final w in sections) {
    if (out.isNotEmpty) {
      out.add(const SizedBox(height: 14));
      out.add(const Divider(
        height: 20,
        color: DashboardTokens.cardBoxBorder,
      ));
    }
    out.add(w);
  }
  return out;
}
