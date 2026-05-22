import 'package:flutter/material.dart';

import 'analyse_controller.dart';
import 'analyse_models.dart';
import 'analyse_tokens.dart';

/// Score de confluence (logique alignée sur la maquette OLED).
int computeOledConfluenceScore(AnalyseController c) {
  var score = 20;

  if (c.bias == AnalyseDirectionBias.achat &&
      c.localTrendPick.enumVal == AnalyseLocalTrend.haussiere) {
    score += 15;
  }
  if (c.bias == AnalyseDirectionBias.vente &&
      c.localTrendPick.enumVal == AnalyseLocalTrend.baissiere) {
    score += 15;
  }
  if (c.phasePick.enumVal == AnalysePhase.impulsion) score += 10;

  if (c.smcZone.trim().isNotEmpty) score += 10;
  if (c.smcFvg.trim().isNotEmpty) score += 5;
  if (c.smcLiquidityPools.trim().isNotEmpty) score += 5;

  final fib = c.smcFibLevel;
  if (fib == '0.618' || fib == '0.5') score += 10;

  if (c.structureSupportMaj.trim().isNotEmpty || c.extraSupports.isNotEmpty) {
    score += 5;
  }

  final selectedSetups =
      c.indicators.where(c.indicatorSetupIsSelected).length;
  score += selectedSetups * 5;

  return score.clamp(0, 100);
}

Color oledConfluenceColor(int score) {
  if (score > 70) return AnalyseTokens.oledGreen;
  if (score > 40) return AnalyseTokens.oledAmber;
  return AnalyseTokens.oledRed;
}

String oledConfluenceStatusLabel(int score) {
  if (score > 70) return 'Setup Optimal';
  if (score > 40) return 'Setup Valide';
  return 'Risque Élevé';
}
