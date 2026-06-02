import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../shared/paychek_demo_graduation_prefs.dart';
import 'strategie_mes_regles_storage.dart';
import 'strategie_realtime_notifier.dart';

/// 1ère interaction « Mes règles d'or » (pas à la création du compte).
Future<void> strategieGraduateGoldenRulesOnFirstUse({
  required Locale locale,
}) async {
  if (await PaychekDemoGraduationPrefs.isGoldenRulesGraduated()) {
    StrategieMesReglesStore.setGoldenRulesGraduatedCache(true);
    return;
  }
  await PaychekDemoGraduationPrefs.markGoldenRulesGraduated();
  StrategieMesReglesStore.setGoldenRulesGraduatedCache(true);

  if (!StrategieMesReglesStore.notifier.value.isCustom) {
    final title = lookupAppLocalizations(locale)
        .ajouterTradeStrategieGoldRules
        .toUpperCase();
    await StrategieMesReglesStore.save(
      sectionTitle: title,
      rules: const [],
      markGraduated: false,
    );
  } else {
    StrategieRealtimeNotifier.bump();
  }
}
