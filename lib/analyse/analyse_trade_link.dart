import 'package:flutter/foundation.dart';

import 'analyse_report_snapshot.dart';

/// Rapport Mon Analyse à lier au prochain onglet « Ajouter un trade ».
final ValueNotifier<AnalyseReportSnapshot?> analysePendingTradePlan =
    ValueNotifier<AnalyseReportSnapshot?>(null);
