import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';

/// Marqueurs locaux : une fois « diplômé », les contenus démo ne réapparaissent plus.
abstract final class PaychekDemoGraduationPrefs {
  PaychekDemoGraduationPrefs._();

  static const _goldenRules = 'paychek_demo_golden_rules_graduated_v1';
  static const _setups = 'paychek_demo_setups_graduated_v1';
  static const _checklist = 'paychek_demo_checklist_graduated_v1';
  static const _analyseEur = 'paychek_demo_analyse_eur_graduated_v1';

  static Future<bool> isGoldenRulesGraduated() => _read(_goldenRules);
  static Future<void> markGoldenRulesGraduated() => _write(_goldenRules);

  static Future<bool> isSetupsGraduated() => _read(_setups);
  static Future<void> markSetupsGraduated() => _write(_setups);

  static Future<bool> isChecklistGraduated() => _read(_checklist);
  static Future<void> markChecklistGraduated() => _write(_checklist);

  static Future<bool> isAnalyseEurGraduated() => _read(_analyseEur);
  static Future<void> markAnalyseEurGraduated() => _write(_analyseEur);

  static Future<bool> _read(String base) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(paychekScopedPrefsKey(base)) ?? false;
  }

  static Future<void> _write(String base) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(paychekScopedPrefsKey(base), true);
  }
}
