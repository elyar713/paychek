import 'analyse_default_demo_seed.dart';
import 'analyse_report_snapshot.dart';
import '../shared/paychek_demo_graduation_prefs.dart';

/// Rapports Mon analyse visibles (stockage + écran).
Future<List<AnalyseReportSnapshot>> analyseReportsForDisplay(
  List<AnalyseReportSnapshot> stored,
) async {
  final eurGraduated = await PaychekDemoGraduationPrefs.isAnalyseEurGraduated();
  if (!eurGraduated) {
    return List<AnalyseReportSnapshot>.from(stored);
  }
  return stored
      .where((s) => !isAnalyseEuroUsdDemoSnapshot(s))
      .toList(growable: false);
}

List<AnalyseReportSnapshot> analyseReportsWithoutEurDemo(
  List<AnalyseReportSnapshot> reports,
) =>
    reports
        .where((s) => !isAnalyseEuroUsdDemoSnapshot(s))
        .toList(growable: false);

bool analyseSnapshotCountsAsUserValidated(AnalyseReportSnapshot snap) =>
    !isAnalyseEuroUsdDemoSnapshot(snap);
