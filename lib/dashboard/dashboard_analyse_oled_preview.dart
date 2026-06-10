import 'package:flutter/material.dart';

import '../analyse/analyse_report_snapshot.dart';
import '../analyse/report_widgets/analyse_report_body_embedded.dart';

/// Corps du rapport OLED pour l’aperçu « Mon analyse » sur le dashboard (tests).
class DashboardAnalyseOledPreviewContent extends StatelessWidget {
  const DashboardAnalyseOledPreviewContent({
    super.key,
    required this.snapshot,
    required this.onPrepToggle,
    this.topBar,
  });

  final AnalyseReportSnapshot snapshot;
  final ValueChanged<String> onPrepToggle;
  final Widget? topBar;

  @override
  Widget build(BuildContext context) {
    return AnalyseReportBody(
      snapshot: snapshot,
      onPrepToggle: onPrepToggle,
      topBar: topBar,
    );
  }
}
