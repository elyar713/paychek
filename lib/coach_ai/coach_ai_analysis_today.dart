import '../analyse/analyse_report_snapshot.dart';
import '../analyse/analyse_reports_storage.dart';
import '../analyse/analyse_starred_report_storage.dart';
import 'coach_ai_response_format.dart';

class AnalysisTodaySnapshot {
  const AnalysisTodaySnapshot({
    required this.hasData,
    this.isToday = false,
    this.source = 'none',
    this.actif = '',
    this.sousTitre = '',
    this.biasLabel = '',
    this.trendLabel = '',
    this.phaseLabel = '',
    this.contexteDateLabel = '',
    this.contexteTfLine = '',
    this.globalConfidencePercent = 0,
    this.confluenceScore = 0,
    this.support = '',
    this.resistance = '',
    this.chartisme = '',
    this.indicateursOutils = '',
    this.smcSummary = '',
    this.noteContexte = '',
  });

  final bool hasData;
  final bool isToday;
  final String source;
  final String actif;
  final String sousTitre;
  final String biasLabel;
  final String trendLabel;
  final String phaseLabel;
  final String contexteDateLabel;
  final String contexteTfLine;
  final int globalConfidencePercent;
  final int confluenceScore;
  final String support;
  final String resistance;
  final String chartisme;
  final String indicateursOutils;
  final String smcSummary;
  final String noteContexte;

  factory AnalysisTodaySnapshot.fromReport(
    AnalyseReportSnapshot report, {
    required String source,
    required bool isToday,
  }) {
    final smcParts = <String>[
      if (report.smcOb.trim().isNotEmpty) report.smcOb.trim(),
      if (report.smcFvg.trim().isNotEmpty) report.smcFvg.trim(),
      if (report.smcLiq.trim().isNotEmpty) report.smcLiq.trim(),
    ];
    return AnalysisTodaySnapshot(
      hasData: true,
      isToday: isToday,
      source: source,
      actif: report.actif,
      sousTitre: report.sousTitre,
      biasLabel: report.biasLabel,
      trendLabel: report.trendLabel,
      phaseLabel: report.phaseLabel,
      contexteDateLabel: report.contexteDateLabel ?? '',
      contexteTfLine: report.contexteTfLine,
      globalConfidencePercent: report.globalConfidencePercent,
      confluenceScore: report.confluenceScore,
      support: report.support,
      resistance: report.resistance,
      chartisme: report.chartisme,
      indicateursOutils: report.indicateursOutils,
      smcSummary: smcParts.join(' · '),
      noteContexte: report.noteContexte,
    );
  }
}

/// Analyse du jour (page Analyse PAYCHEK), pas l’audit discipline des trades.
abstract final class CoachAiAnalysisToday {
  static String todayDateLabel(DateTime day) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(day.day)}/${two(day.month)}/${day.year}';
  }

  static bool isReportForToday(AnalyseReportSnapshot report) {
    final label = report.contexteDateLabel?.trim();
    if (label == null || label.isEmpty) return false;
    return label == todayDateLabel(DateTime.now());
  }

  static bool isTodayAnalysisQuestion(String question) {
    final q = question.toLowerCase();
    if (!RegExp(
      r'\banalyse\b|\banalysis\b|plan d.?analyse|mon analyse|ma analyse|my analysis',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r'prix d.?entr|prix de sortie|entry price|exit price|take profit|stop loss|\btp\b|\bsl\b|lot\b',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r'performance|winrate|pnl|bilan|non.?respect|enregistr|audit|combien|sur mes trades|discipline',
    ).hasMatch(q)) {
      return false;
    }
    if (RegExp(
      r"aujourd'hui|aujourdhui|today|du jour|ce matin|this morning|this evening",
    ).hasMatch(q)) {
      return true;
    }
    return RegExp(
      r"dis.?moi|montre|quelle est|quel est|what is|show me|mon analyse|ma analyse|my analysis|l'analyse",
    ).hasMatch(q);
  }

  static Future<AnalysisTodaySnapshot> buildTodaySnapshot() async {
    final starred = await AnalyseStarredReportStorage.load();
    final reports = await AnalyseReportsStorage.loadAll();

    AnalyseReportSnapshot? picked;
    var source = 'none';
    var isToday = false;

    if (starred != null && isReportForToday(starred)) {
      picked = starred;
      source = 'starred_today';
      isToday = true;
    } else {
      for (final report in reports) {
        if (isReportForToday(report)) {
          picked = report;
          source = 'report_today';
          isToday = true;
          break;
        }
      }
    }

    if (picked == null && starred != null) {
      picked = starred;
      source = 'starred';
      isToday = isReportForToday(starred);
    }

    if (picked == null && reports.isNotEmpty) {
      picked = reports.first;
      source = 'report_latest';
      isToday = isReportForToday(picked);
    }

    if (picked == null) {
      return const AnalysisTodaySnapshot(hasData: false);
    }

    return AnalysisTodaySnapshot.fromReport(
      picked,
      source: source,
      isToday: isToday,
    );
  }

  static String todayCardTitle(String languageCode) {
    return switch (languageCode) {
      'en' => 'Analysis · today',
      'de' => 'Analyse · heute',
      'es' => 'Análisis · hoy',
      _ => 'Analyse · aujourd’hui',
    };
  }

  static Future<Map<String, dynamic>> todayContextToJson(
    String languageCode, {
    bool briefFollowUp = false,
  }) async {
    final snap = await buildTodaySnapshot();
    return <String, dynamic>{
      'coachInstructions': briefFollowUp
          ? CoachAiResponseFormat.analysisTodayFollowUpInstructions(languageCode)
          : CoachAiResponseFormat.analysisTodayInstructions(languageCode),
      'hasDataToday': snap.hasData,
      'isAnalysisDateToday': snap.isToday,
      'source': snap.source,
      if (snap.hasData) ...<String, dynamic>{
        'actif': snap.actif,
        if (snap.sousTitre.isNotEmpty) 'sousTitre': snap.sousTitre,
        'bias': snap.biasLabel,
        'trend': snap.trendLabel,
        'phase': snap.phaseLabel,
        if (snap.contexteDateLabel.isNotEmpty) 'analysisDate': snap.contexteDateLabel,
        if (snap.contexteTfLine.isNotEmpty) 'timeframes': snap.contexteTfLine,
        'confidencePercent': snap.globalConfidencePercent,
        'confluenceScore': snap.confluenceScore,
        if (snap.support.isNotEmpty) 'support': snap.support,
        if (snap.resistance.isNotEmpty) 'resistance': snap.resistance,
        if (snap.chartisme.isNotEmpty) 'chartPattern': snap.chartisme,
        if (snap.indicateursOutils.isNotEmpty) 'indicators': snap.indicateursOutils,
        if (snap.smcSummary.isNotEmpty) 'smc': snap.smcSummary,
        if (snap.noteContexte.isNotEmpty) 'noteContexte': snap.noteContexte,
      },
      'fillHintPath': languageCode == 'fr'
          ? 'Accueil → carte Mon Analyse, ou Plus → Analyse → Valider l’analyse'
          : 'Home → My Analysis card, or More → Analysis → Validate analysis',
    };
  }
}
