import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import 'analyse_controller_impact_confidence.dart';
import 'analyse_controller_structure_smc.dart';
import 'analyse_models.dart';
import 'analyse_section_impact_toggle.dart';

part 'analyse_controller_contexte_fields.dart';
part 'analyse_controller_contexte_phase_snapshots.dart';
part 'analyse_controller_contexte_templates.dart';

/// État global de l’écran Analyse (assemblage par mixins).
class AnalyseController extends ChangeNotifier
    with
        AnalyseControllerImpactConfidence,
        AnalyseControllerContexteFields,
        AnalyseControllerContextePhaseSnapshots,
        AnalyseControllerContexte,
        AnalyseControllerStructureFields,
        AnalyseControllerStructureSnapshots,
        AnalyseControllerStructureIndicators,
        AnalyseControllerStructureSmcIndicators {
  AnalyseController();

  /// Capture joignable avant de générer le rapport (zone Analyse uniquement ; pas sous le rapport figé).
  Uint8List? _draftReportScreenshotBytes;
  Uint8List? get draftReportScreenshotBytes => _draftReportScreenshotBytes;

  void setDraftReportScreenshot(Uint8List? bytes) {
    _draftReportScreenshotBytes = bytes;
    notifyListeners();
  }

  /// Somme des poids d’impact **bruts** pour les sections dont l’interrupteur est actif.
  int get _activeImpactWeightSum {
    var s = 0;
    if (contextEnabled) s += impactFeuille;
    if (structureEnabled) s += impactStructure;
    if (indicatorsEnabled) s += impactIndicators;
    if (smcEnabled) s += impactSmc;
    return s;
  }

  /// Part affichée (0–100 %) parmi les sections **actives** ; alignée sur la jauge globale.
  int _impactDisplayAmongActive(int rawImpact, bool sectionEnabled) {
    if (!sectionEnabled) return 0;
    final sum = _activeImpactWeightSum;
    if (sum <= 0) return 0;
    return ((rawImpact / sum) * 100).round().clamp(0, 100);
  }

  int get impactFeuilleDisplay =>
      _impactDisplayAmongActive(impactFeuille, contextEnabled);
  int get impactStructureDisplay =>
      _impactDisplayAmongActive(impactStructure, structureEnabled);
  int get impactIndicatorsDisplay =>
      _impactDisplayAmongActive(impactIndicators, indicatorsEnabled);
  int get impactSmcDisplay =>
      _impactDisplayAmongActive(impactSmc, smcEnabled);

  /// Après le bouton « Rapport » : feuille vide (pilules par défaut), copies conservées mais vidées.
  void resetAfterReportValidation() {
    resetContexteMainAfterValidation();
    resetPhaseAndContexteCopiesAfterValidation();
    resetStructureMainAfterValidation();
    resetStructureCopiesAfterValidation();
    resetIndicatorsMainAfterValidation();
    resetIndicatorsCopiesAfterValidation();
    resetSmcVolumeMainAfterValidation();
    resetSmcCopiesAfterValidation();
    restoreImpactsSnapshot(25, 25, 25, 25);
    confidenceFeuille = 45;
    confidenceStructure = 45;
    confidenceIndicators = 45;
    confidenceSmc = 45;
    contextEnabled = true;
    structureEnabled = true;
    indicatorsEnabled = true;
    smcEnabled = true;
    volumeProfileEnabled = true;
    _draftReportScreenshotBytes = null;
  }
}
