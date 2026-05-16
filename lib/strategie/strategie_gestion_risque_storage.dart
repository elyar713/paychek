import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';

/// Paramètres « Gestion du risque » (page Stratégie) — alignés sur [StrategieGestionRisqueSection].
class StrategieGestionRisqueParams {
  const StrategieGestionRisqueParams({
    required this.riskPct,
    required this.lossPct,
    required this.tradesPerDay,
    required this.rrRatio,
  });

  final double riskPct;
  final double lossPct;
  final int tradesPerDay;
  final double rrRatio;

  static const StrategieGestionRisqueParams defaults = StrategieGestionRisqueParams(
    riskPct: 1,
    lossPct: 3,
    tradesPerDay: 3,
    rrRatio: 2,
  );
}

/// Persistance locale des seuils définis par l’utilisateur (page Stratégie).
abstract final class StrategieGestionRisqueStorage {
  StrategieGestionRisqueStorage._();

  static const _kRiskBase = 'strategie_gestion_risk_pct_v1';
  static const _kLossBase = 'strategie_gestion_loss_pct_v1';
  static const _kTradesBase = 'strategie_gestion_trades_per_day_v1';
  static const _kRrBase = 'strategie_gestion_rr_ratio_v1';

  static String get _kRisk => paychekScopedPrefsKey(_kRiskBase);
  static String get _kLoss => paychekScopedPrefsKey(_kLossBase);
  static String get _kTrades => paychekScopedPrefsKey(_kTradesBase);
  static String get _kRr => paychekScopedPrefsKey(_kRrBase);

  static Future<StrategieGestionRisqueParams> load() async {
    final p = await SharedPreferences.getInstance();
    final r = p.getDouble(_kRisk);
    final l = p.getDouble(_kLoss);
    final t = p.getInt(_kTrades);
    final rr = p.getDouble(_kRr);
    if (r == null && l == null && t == null && rr == null) {
      return StrategieGestionRisqueParams.defaults;
    }
    final d = StrategieGestionRisqueParams.defaults;
    final risk = r ?? d.riskPct;
    final loss = l ?? d.lossPct;
    final td = t ?? d.tradesPerDay;
    final rrVal = rr ?? d.rrRatio;
    return StrategieGestionRisqueParams(
      riskPct: risk > 0 ? risk : d.riskPct,
      lossPct: loss > 0 ? loss : d.lossPct,
      tradesPerDay: td > 0 ? td : d.tradesPerDay,
      rrRatio: rrVal > 0 ? rrVal : d.rrRatio,
    );
  }

  static Future<void> save(StrategieGestionRisqueParams params) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kRisk, params.riskPct);
    await p.setDouble(_kLoss, params.lossPct);
    await p.setInt(_kTrades, params.tradesPerDay);
    await p.setDouble(_kRr, params.rrRatio);
  }
}
