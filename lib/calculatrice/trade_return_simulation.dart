import 'dart:math' as math;

import 'calculatrice_models.dart';

TradeSimulationResult simulateTrades({
  required double startBalance,
  required int trades,
  required double winRate,
  required double riskPct,
  required double riskReward,
  required int seed,
}) {
  final rng = math.Random(seed);
  var balance = startBalance;
  var peak = startBalance;
  var maxDd = 0.0;

  var wins = 0;
  var losses = 0;
  var grossProfit = 0.0;
  var grossLoss = 0.0;
  var maxBalance = startBalance;
  var minBalance = startBalance;

  final rows = <TradeRow>[];
  final curve = <double>[startBalance];

  for (var i = 1; i <= trades; i++) {
    final start = balance;
    final isWin = rng.nextDouble() < winRate;
    final riskAmount = start * riskPct;
    final pnl = isWin ? (riskAmount * riskReward) : -riskAmount;
    final end = start + pnl;

    balance = end;
    curve.add(balance);

    if (isWin) {
      wins++;
      grossProfit += pnl;
    } else {
      losses++;
      grossLoss += pnl.abs();
    }

    if (balance > peak) peak = balance;
    final dd = (peak - balance) / peak;
    if (dd > maxDd) maxDd = dd;

    if (balance > maxBalance) maxBalance = balance;
    if (balance < minBalance) minBalance = balance;

    final totalGain = balance - startBalance;
    final totalGainPct = (totalGain / startBalance) * 100.0;

    rows.add(
      TradeRow(
        index: i,
        startBalance: start,
        endBalance: balance,
        isWin: isWin,
        pnl: pnl,
        totalGain: totalGain,
        totalGainPct: totalGainPct,
      ),
    );
  }

  final endBalance = balance;
  final totalGain = endBalance - startBalance;
  final totalGainPct = (totalGain / startBalance) * 100.0;
  final profitFactor = grossLoss == 0 ? double.infinity : grossProfit / grossLoss;

  return TradeSimulationResult(
    rows: rows,
    equityCurve: curve,
    endBalance: endBalance,
    totalGain: totalGain,
    totalGainPct: totalGainPct,
    wins: wins,
    losses: losses,
    profitFactor: profitFactor,
    maxDrawdownPct: maxDd * 100.0,
    maxBalance: maxBalance,
    minBalance: minBalance,
  );
}

