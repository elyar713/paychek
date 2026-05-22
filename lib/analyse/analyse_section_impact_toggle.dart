import 'package:flutter/foundation.dart';

import 'analyse_controller_impact_confidence.dart';
import 'analyse_section_impact_rebalance.dart';

/// Après on/off d'une section : les % d'impact des sections actives se partagent 100 %.
extension AnalyseSectionImpactToggleX on ChangeNotifier {
  void rebalanceAnalyseSectionImpacts() {
    if (this is! AnalyseControllerImpactConfidence) return;
    final impact = this as AnalyseControllerImpactConfidence;
    final host = this as dynamic;
    final parts = rebalanceImpactsAmongActiveSections(
      feuille: impact.impactFeuille,
      structure: impact.impactStructure,
      indicators: impact.impactIndicators,
      smc: impact.impactSmc,
      contextEnabled: host.contextEnabled as bool,
      structureEnabled: host.structureEnabled as bool,
      indicatorsEnabled: host.indicatorsEnabled as bool,
      smcEnabled: host.smcEnabled as bool,
    );
    impact.setImpactPartsSilent(parts);
  }
}
