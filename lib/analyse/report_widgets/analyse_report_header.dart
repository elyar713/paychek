import 'package:flutter/material.dart';

import '../analyse_report_snapshot.dart';

/// En-tête legacy : le hero (confluence + métadonnées) est dans [AnalyseReportOledBody].
class AnalyseReportHeader extends StatelessWidget {
  const AnalyseReportHeader({super.key, required this.snapshot});

  final AnalyseReportSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
