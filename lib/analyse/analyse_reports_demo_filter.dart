import 'analyse_default_demo_seed.dart';
import 'analyse_report_snapshot.dart';
import '../shared/paychek_demo_graduation_prefs.dart';

/// Rapports hors démos GOLD / EUR (Ajouter trade, aperçu dashboard).
List<AnalyseReportSnapshot> analyseReportsWithoutDemoFallbacks(
  List<AnalyseReportSnapshot> reports,
) =>
    reports
        .where((s) => !isAnalyseAjouterTradeDemoFallbackSnapshot(s))
        .toList(growable: false);

List<AnalyseReportSnapshot> analyseReportsWithoutEurDemo(
  List<AnalyseReportSnapshot> reports,
) =>
    reports
        .where((s) => !isAnalyseEuroUsdDemoSnapshot(s))
        .toList(growable: false);

/// Filtre EUR démo + priorise les rapports utilisateur dès qu'il en existe un.
List<AnalyseReportSnapshot> analyseReportsForDisplaySync(
  List<AnalyseReportSnapshot> stored, {
  required bool eurGraduated,
}) {
  var visible = List<AnalyseReportSnapshot>.from(stored);
  if (eurGraduated) {
    visible = analyseReportsWithoutEurDemo(visible);
  }
  final userOnly = analyseReportsWithoutDemoFallbacks(visible);
  if (userOnly.isNotEmpty) return userOnly;
  return visible;
}

/// Rapports Mon analyse visibles (stockage + écran + intégrations app).
Future<List<AnalyseReportSnapshot>> analyseReportsForDisplay(
  List<AnalyseReportSnapshot> stored,
) async {
  final eurGraduated = await PaychekDemoGraduationPrefs.isAnalyseEurGraduated();
  return analyseReportsForDisplaySync(stored, eurGraduated: eurGraduated);
}

bool analyseSnapshotCountsAsUserValidated(AnalyseReportSnapshot snap) =>
    !isAnalyseAjouterTradeDemoFallbackSnapshot(snap);
