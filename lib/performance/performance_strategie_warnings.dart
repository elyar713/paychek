import 'dart:ui' show Locale;

import 'performance_locale_copy.dart';
import '../strategie/strategie_gestion_risque_storage.dart';
import '../strategie/strategie_horaires_sessions_storage.dart';
import '../strategie/strategie_session_locale_format.dart';
import 'performance_trade_model.dart';

int? _tradeEntryMinutes(Trade t) {
  final tod = t.timeOfDay;
  if (tod == null || tod.isEmpty) return null;
  final p = tod.split(':');
  if (p.length < 2) return null;
  final h = int.tryParse(p[0].trim()) ?? 0;
  final m = int.tryParse(p[1].trim()) ?? 0;
  return h * 60 + m;
}

String _dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _monthKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}';

/// `true` si [mins] tombe dans la fenêtre (début inclus ; fin inclusive si fournie ; sinon ouvert après le début).
bool _minutesInSessionWindow(int mins, StrategieSessionPersisted s) {
  final start = s.startHour * 60 + s.startMinute;
  if (s.endHour == null || s.endMinute == null) {
    return mins >= start;
  }
  final end = s.endHour! * 60 + s.endMinute!;
  if (end >= start) {
    return mins >= start && mins <= end;
  }
  return mins >= start || mins <= end;
}

class _SessionAgg {
  _SessionAgg();
  int tradeCount = 0;
  final Set<String> days = {};
  final Set<String> months = {};
}

class _StrategieSessionScanResult {
  _StrategieSessionScanResult({
    required this.sansHeureEntree,
    required this.noTradeAggs,
    required this.horsSessionAgg,
    required this.noTrade,
    required this.tradeZones,
    required this.tradesPendantNoTrade,
  });

  final int sansHeureEntree;
  final Map<String, _SessionAgg> noTradeAggs;
  final _SessionAgg horsSessionAgg;
  final List<StrategieSessionPersisted> noTrade;
  final List<StrategieSessionPersisted> tradeZones;

  /// Trades avec heure d’entrée dans au moins une session No Trade.
  final int tradesPendantNoTrade;
}

_StrategieSessionScanResult _scanStrategieSessions(
  List<Trade> trades,
  List<StrategieSessionPersisted> sessions,
) {
  final noTrade = sessions.where((s) => s.isNoTradeZone).toList();
  final tradeZones = sessions.where((s) => !s.isNoTradeZone).toList();

  var sansHeure = 0;
  var tradesPendantNoTrade = 0;
  final noTradeAggs = <String, _SessionAgg>{};
  final horsSessionAgg = _SessionAgg();

  for (final t in trades) {
    final mins = _tradeEntryMinutes(t);
    if (mins == null) {
      sansHeure++;
      continue;
    }

    var inNoTrade = false;
    for (final s in noTrade) {
      if (_minutesInSessionWindow(mins, s)) {
        inNoTrade = true;
        final agg = noTradeAggs.putIfAbsent(s.title, () => _SessionAgg());
        agg.tradeCount++;
        agg.days.add(_dayKey(t.date));
        agg.months.add(_monthKey(t.date));
      }
    }

    if (inNoTrade) {
      tradesPendantNoTrade++;
      continue;
    }

    if (tradeZones.isNotEmpty) {
      var inTrade = false;
      for (final s in tradeZones) {
        if (_minutesInSessionWindow(mins, s)) {
          inTrade = true;
          break;
        }
      }
      if (!inTrade) {
        horsSessionAgg.tradeCount++;
        horsSessionAgg.days.add(_dayKey(t.date));
        horsSessionAgg.months.add(_monthKey(t.date));
      }
    }
  }

  return _StrategieSessionScanResult(
    sansHeureEntree: sansHeure,
    noTradeAggs: noTradeAggs,
    horsSessionAgg: horsSessionAgg,
    noTrade: noTrade,
    tradeZones: tradeZones,
    tradesPendantNoTrade: tradesPendantNoTrade,
  );
}

/// Agrégats pour la carte Performance « Horaires » (non-respect des sessions Stratégie).
class HoraireTradingViolationStats {
  const HoraireTradingViolationStats({
    required this.sansHeureEntree,
    required this.horsCreaneauxAutorises,
    required this.pendantFenetreNoTrade,
    required this.sessionsConfigurees,
  });

  final int sansHeureEntree;
  final int horsCreaneauxAutorises;
  final int pendantFenetreNoTrade;
  final bool sessionsConfigurees;
}

/// Compte les trades hors créneaux autorisés / en session No Trade (même logique que Paychek Lens).
HoraireTradingViolationStats computeHoraireTradingViolationStats({
  required List<Trade> trades,
  required List<StrategieSessionPersisted> sessions,
}) {
  if (trades.isEmpty) {
    final configured = sessions.isNotEmpty;
    return HoraireTradingViolationStats(
      sansHeureEntree: 0,
      horsCreaneauxAutorises: 0,
      pendantFenetreNoTrade: 0,
      sessionsConfigurees: configured,
    );
  }
  final scan = _scanStrategieSessions(trades, sessions);
  final configured = scan.tradeZones.isNotEmpty || scan.noTrade.isNotEmpty;
  return HoraireTradingViolationStats(
    sansHeureEntree: scan.sansHeureEntree,
    horsCreaneauxAutorises: scan.horsSessionAgg.tradeCount,
    pendantFenetreNoTrade: scan.tradesPendantNoTrade,
    sessionsConfigurees: configured,
  );
}

/// Avertissements Paychek Lens : seuils Stratégie + sessions (no trade, hors session autorisée).
List<String> paychekStrategieWarnings({
  required List<Trade> trades,
  required StrategieGestionRisqueParams params,
  required List<StrategieSessionPersisted> sessions,
  required Locale locale,
  double? capitalAmount,
}) {
  String t(String fr, String en, String es, String de, String pt, String ko) =>
      performancePickLocale(locale, fr, en, es, de, pt, ko);
  String tradeWord(int n) => performanceTradeWordPlural(locale.languageCode, n);

  String dayAggSuffix(int dj) {
    final c = locale.languageCode.toLowerCase();
    if (c.startsWith('fr')) return '×$dj j';
    if (c.startsWith('es')) return '×$dj d';
    if (c.startsWith('de')) return '×$dj T';
    if (c.startsWith('pt')) return '×$dj d';
    if (c.startsWith('ko')) return '×$dj일';
    return '×$dj d';
  }

  String monthAggSuffix(int mj) {
    final c = locale.languageCode.toLowerCase();
    if (c.startsWith('fr')) return '×$mj mois';
    if (c.startsWith('es')) return '×$mj mes';
    if (c.startsWith('de')) return '×$mj Mo';
    if (c.startsWith('pt')) return '×$mj meses';
    if (c.startsWith('ko')) return '×$mj개월';
    return '×$mj mo';
  }

  final out = <String>[];
  if (trades.isEmpty) return out;

  final scan = _scanStrategieSessions(trades, sessions);
  final sansHeure = scan.sansHeureEntree;
  final noTradeAggs = scan.noTradeAggs;
  final horsSessionAgg = scan.horsSessionAgg;
  final noTrade = scan.noTrade;
  final tradeZones = scan.tradeZones;

  if (sansHeure > 0) {
    out.add(
      t(
        '$sansHeure ${tradeWord(sansHeure)} sans heure d’entrée — les contrôles de session ne s’appliquent pas à ces lignes.',
        '$sansHeure ${tradeWord(sansHeure)} without entry time — session checks do not apply to these rows.',
        '$sansHeure ${tradeWord(sansHeure)} sin hora de entrada — los controles de sesión no se aplican a estas filas.',
        '$sansHeure ${tradeWord(sansHeure)} ohne Eintrittszeit — Session-Prüfungen gelten für diese Zeilen nicht.',
        '$sansHeure ${tradeWord(sansHeure)} sem hora de entrada — as verificações de sessão não se aplicam a essas linhas.',
        '진입 시각 없음 $sansHeure${tradeWord(sansHeure)} — 세션 검사가 적용되지 않습니다.',
      ),
    );
  }

  for (final e in noTradeAggs.entries) {
    final title = e.key;
    StrategieSessionPersisted? sess;
    for (final x in noTrade) {
      if (x.title == title) {
        sess = x;
        break;
      }
    }
    final a = e.value;
    final dj = a.days.length;
    final mj = a.months.length;
    final parts = <String>['×${a.tradeCount}', dayAggSuffix(dj)];
    if (mj >= 2) parts.add(monthAggSuffix(mj));
    final suffix = ' — ${parts.join(' ')}';
    final displayTitle = sess != null
        ? strategieSessionTitleForLocale(sess, locale)
        : title;
    final displayTime = sess != null
        ? formatStrategieSessionWindow(sess, locale)
        : '—';
    out.add(
      t(
        'Session No Trade « $displayTitle » ($displayTime) : ${a.tradeCount} ${tradeWord(a.tradeCount)} pendant la fenêtre interdite$suffix',
        'No trade zone "$displayTitle" ($displayTime): ${a.tradeCount} ${tradeWord(a.tradeCount)} during forbidden window$suffix',
        'Zona sin operación "$displayTitle" ($displayTime): ${a.tradeCount} ${tradeWord(a.tradeCount)} durante la ventana prohibida$suffix',
        'No-Trade-Fenster „$displayTitle“ ($displayTime): ${a.tradeCount} ${tradeWord(a.tradeCount)} im verbotenen Zeitfenster$suffix',
        'Área sem trade "$displayTitle" ($displayTime): ${a.tradeCount} ${tradeWord(a.tradeCount)} na janela proibida$suffix',
        '노 트레이드 세션 «$displayTitle» ($displayTime): 금지 구간 중 ${a.tradeCount}${tradeWord(a.tradeCount)}$suffix',
      ),
    );
  }

  if (tradeZones.isNotEmpty && horsSessionAgg.tradeCount > 0) {
    final a = horsSessionAgg;
    final dj = a.days.length;
    final mj = a.months.length;
    final parts = <String>['×${a.tradeCount}', dayAggSuffix(dj)];
    if (mj >= 2) parts.add(monthAggSuffix(mj));
    final suffix = ' — ${parts.join(' ')}';
    out.add(
      t(
        'Hors session de trading autorisée (horaires Stratégie) : ${a.tradeCount} ${tradeWord(a.tradeCount)} en dehors des créneaux définis$suffix',
        'Outside allowed trading session (Strategy hours): ${a.tradeCount} ${tradeWord(a.tradeCount)} outside defined windows$suffix',
        'Fuera de sesión de trading permitida (horarios de Estrategia): ${a.tradeCount} ${tradeWord(a.tradeCount)} fuera de las ventanas definidas$suffix',
        'Außerhalb der erlaubten Handelssession (Strategie-Zeiten): ${a.tradeCount} ${tradeWord(a.tradeCount)} außerhalb der definierten Fenster$suffix',
        'Fora da sessão permitida (horários Estratégia): ${a.tradeCount} ${tradeWord(a.tradeCount)} fora das janelas$suffix',
        '허용 세션 외(전략 시간): 정의된 구간 밖 ${a.tradeCount}${tradeWord(a.tradeCount)}$suffix',
      ),
    );
  }

  final byDay = <String, List<Trade>>{};
  for (final t in trades) {
    final k = _dayKey(t.date);
    byDay.putIfAbsent(k, () => []).add(t);
  }

  var maxTradesOneDay = 0;
  for (final list in byDay.values) {
    if (list.length > maxTradesOneDay) maxTradesOneDay = list.length;
  }
  if (maxTradesOneDay > params.tradesPerDay) {
    out.add(
      t(
        'Jusqu’à $maxTradesOneDay trades sur une même journée — au-dessus de votre limite Stratégie (${params.tradesPerDay} trades / jour).',
        'Up to $maxTradesOneDay trades on one day — above your Strategy limit (${params.tradesPerDay} trades/day).',
        'Hasta $maxTradesOneDay trades en un mismo día — por encima de tu límite de Estrategia (${params.tradesPerDay} trades/día).',
        'Bis zu $maxTradesOneDay Trades an einem Tag — über Ihrem Strategie-Limit (${params.tradesPerDay} Trades/Tag).',
        'Até $maxTradesOneDay trades em um dia — acima do limite de Estratégia (${params.tradesPerDay} trades/dia).',
        '하루 최대 $maxTradesOneDay회 — 전략 한도(${params.tradesPerDay}/일) 초과.',
      ),
    );
  }

  final cap = capitalAmount;
  if (cap == null || cap <= 0) {
    out.add(
      t(
        'Définissez un capital dans le questionnaire pour vérifier perte max / jour et risque max / trade (%).',
        'Set a capital amount in the questionnaire to validate max daily loss and max trade risk (%).',
        'Define un capital en el cuestionario para validar pérdida máxima por día y riesgo máximo por trade (%).',
        'Legen Sie im Fragebogen ein Kapital fest, um max. Tagesverlust und max. Trade-Risiko (%) zu prüfen.',
        'Defina capital no questionário para validar perda máx./dia e risco máx./trade (%).',
        '설문에서 자본을 설정하면 일일 최대 손실·트레이드당 최대 리스크(%)를 검증합니다.',
      ),
    );
    return out;
  }

  var maxDailyLossPct = 0.0;
  for (final list in byDay.values) {
    var dayPnl = 0.0;
    for (final t in list) {
      dayPnl += t.profit + t.commission;
    }
    if (dayPnl < 0) {
      final lp = (-dayPnl) / cap * 100;
      if (lp > maxDailyLossPct) maxDailyLossPct = lp;
    }
  }
  if (maxDailyLossPct > params.lossPct + 1e-9) {
    out.add(
      t(
        'Perte journalière max observée : ${maxDailyLossPct.toStringAsFixed(1)} % du capital — au-dessus de votre perte max / jour (${params.lossPct} %).',
        'Max observed daily loss: ${maxDailyLossPct.toStringAsFixed(1)}% of capital — above your max daily loss (${params.lossPct}%).',
        'Pérdida diaria máxima observada: ${maxDailyLossPct.toStringAsFixed(1)}% del capital — por encima de tu pérdida diaria máxima (${params.lossPct}%).',
        'Max. beobachteter Tagesverlust: ${maxDailyLossPct.toStringAsFixed(1)} % des Kapitals — über Ihrem max. Tagesverlust (${params.lossPct} %).',
        'Perda diária máx. observada: ${maxDailyLossPct.toStringAsFixed(1)}% do capital — acima da perda máx./dia (${params.lossPct}%).',
        '관측 일일 최대 손실: 자본의 ${maxDailyLossPct.toStringAsFixed(1)}% — 일일 최대 손실(${params.lossPct}%) 초과.',
      ),
    );
  }

  var maxTradeLossPct = 0.0;
  for (final t in trades) {
    final net = t.profit + t.commission;
    if (net < 0) {
      final lp = (-net) / cap * 100;
      if (lp > maxTradeLossPct) maxTradeLossPct = lp;
    }
  }
  if (maxTradeLossPct > params.riskPct + 1e-9) {
    out.add(
      t(
        'Perte max sur un trade : ${maxTradeLossPct.toStringAsFixed(1)} % du capital — au-dessus du risque max / trade défini (${params.riskPct} %).',
        'Max loss on one trade: ${maxTradeLossPct.toStringAsFixed(1)}% of capital — above configured max trade risk (${params.riskPct}%).',
        'Pérdida máxima en un trade: ${maxTradeLossPct.toStringAsFixed(1)}% del capital — por encima del riesgo máximo configurado por trade (${params.riskPct}%).',
        'Max. Verlust je Trade: ${maxTradeLossPct.toStringAsFixed(1)} % des Kapitals — über dem festgelegten max. Trade-Risiko (${params.riskPct} %).',
        'Perda máx. em um trade: ${maxTradeLossPct.toStringAsFixed(1)}% do capital — acima do risco máx./trade (${params.riskPct}%).',
        '단일 트레이드 최대 손실: 자본의 ${maxTradeLossPct.toStringAsFixed(1)}% — 설정 리스크(${params.riskPct}%) 초과.',
      ),
    );
  }

  return out;
}
