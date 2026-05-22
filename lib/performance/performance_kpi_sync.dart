import 'performance_tokens.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'performance_analysis.dart' hide Trade;
import 'performance_trade_model.dart';
import 'performance_period_filter.dart';

/// Même vert que la page Performance (`_kGreen`).
const Color kWinrateRingGreen = PerformanceTokens.green;

/// Épaisseur de trait identique pour les anneaux KPI sous le capital (winrate, état mental).
const double kDashboardRingStrokeWidth = 2.5;

/// Diamètre des petits anneaux KPI (ligne sous le solde capital).
const double kDashboardKpiRingSize = 48.0;

/// Données KPI partagées : même liste de trades, même filtre de période et même
/// [aggregateTrades] que [PerformancePage] → winrate identique sur Dashboard et Performance.
class PerformanceKpiSync extends ChangeNotifier {
  PerformanceKpiSync._();
  static final PerformanceKpiSync instance = PerformanceKpiSync._();

  List<Trade> _trades = [];
  PerformancePeriodFilter _periodFilter = PerformancePeriodFilter.all;
  DateTime? _customStartDate;

  void mirrorFromPerformance({
    required List<Trade> trades,
    required PerformancePeriodFilter periodFilter,
    DateTime? customStartDate,
  }) {
    _trades = List<Trade>.from(trades);
    _periodFilter = periodFilter;
    _customStartDate = customStartDate;
    notifyListeners();
  }

  /// Chargement CSV depuis le Dashboard : met à jour les trades sans réinitialiser le filtre choisi sur Performance.
  void mirrorTrades(List<Trade> trades) {
    _trades = List<Trade>.from(trades);
    notifyListeners();
  }

  /// Tous les trades importés / synchronisés (sans filtre de période).
  List<Trade> get allTrades => List<Trade>.unmodifiable(_trades);

  /// Test / démo : ajoute un trade en mémoire à la date du jour (n’écrit pas le CSV).
  void appendSimulatedTradeForToday({required double profit}) {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    _trades = [
      ..._trades,
      Trade(
        date: day,
        timeOfDay: null,
        durationMinutes: 0,
        profit: profit,
        win: profit >= 0,
        commission: 0,
        checklistPct: null,
        planPct: null,
        strategiePct: null,
        etatPct: null,
        mindsetPrincipe: null,
        lotSize: null,
        strategieTitle: null,
        strategieNonRespectIds: null,
        assetClass: null,
        pair: null,
        performanceLite: false,
      ),
    ];
    notifyListeners();
  }

  List<Trade> get visibleTrades {
    if (_trades.isEmpty) return [];
    final anchor = anchorDateForTrades(_trades);
    final range = rangeForPeriod(
      period: _periodFilter,
      anchor: anchor,
      customStart: _customStartDate,
    );
    return filterTradesByRange(_trades, range);
  }

  TradeAggregates get aggregates {
    final v = visibleTrades;
    if (v.isEmpty) {
      return const TradeAggregates(wins: 0, losses: 0, breakeven: 0);
    }
    return aggregateTrades(v);
  }

  double get winrate => aggregates.winrate;
}

/// Anneau winrate (même rendu que l’ancien `_WinrateRingPainter` de la page Performance).
class WinrateRingPainter extends CustomPainter {
  WinrateRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final sw = kDashboardRingStrokeWidth;
    final r = size.shortestSide / 2 - sw / 2;
    final c = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: r,
    );
    final bg = Paint()
      ..color = PerformanceTokens.innerBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw;
    canvas.drawArc(c, -math.pi / 2, math.pi * 2, false, bg);
    final fg = Paint()
      ..color = kWinrateRingGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      c,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant WinrateRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Anneau de progression (ex. état mental sur le dashboard) — même géométrie que [WinrateRingPainter], couleur paramétrable.
class ClDisciplineRingPainter extends CustomPainter {
  ClDisciplineRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final sw = kDashboardRingStrokeWidth;
    final r = size.shortestSide / 2 - sw / 2;
    final c = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: r,
    );
    final bg = Paint()
      ..color = PerformanceTokens.innerBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw;
    canvas.drawArc(c, -math.pi / 2, math.pi * 2, false, bg);
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      c,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant ClDisciplineRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
