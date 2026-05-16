import 'package:flutter/material.dart';

import '../../dashboard/dashboard_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../calculatrice_format.dart';
import '../calculatrice_models.dart';
import 'calculatrice_common_widgets.dart';
import 'equity_curve_graph.dart';

class TradeReturnSection extends StatelessWidget {
  const TradeReturnSection({
    super.key,
    required this.isWide,
    required this.currencySymbol,
    required this.startBalance,
    required this.trades,
    required this.winRatePct,
    required this.riskPct,
    required this.riskReward,
    required this.sim,
    required this.error,
    required this.onCalculate,
    required this.onClear,
  });

  final bool isWide;
  final String currencySymbol;
  final TextEditingController startBalance;
  final TextEditingController trades;
  final TextEditingController winRatePct;
  final TextEditingController riskPct;
  final TextEditingController riskReward;
  final TradeSimulationResult? sim;
  final String? error;
  final VoidCallback onCalculate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SettingsCard(
                  currencySymbol: currencySymbol,
                  startBalance: startBalance,
                  trades: trades,
                  winRatePct: winRatePct,
                  riskPct: riskPct,
                  riskReward: riskReward,
                  onCalculate: onCalculate,
                  onClear: onClear,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _ResultsCard(sim: sim, error: error)),
            ],
          )
        else ...[
          _SettingsCard(
            currencySymbol: currencySymbol,
            startBalance: startBalance,
            trades: trades,
            winRatePct: winRatePct,
            riskPct: riskPct,
            riskReward: riskReward,
            onCalculate: onCalculate,
            onClear: onClear,
          ),
          const SizedBox(height: 16),
          _ResultsCard(sim: sim, error: error),
        ],
        const SizedBox(height: 16),
        SectionTitle(title: l.calcEquityCurveTitle),
        const SizedBox(height: 10),
        EquityCurveGraphCard(points: sim?.equityCurve ?? const []),
        const SizedBox(height: 16),
        SectionTitle(title: l.calcTradeReturnTableTitle),
        const SizedBox(height: 10),
        _TradesTableCard(rows: sim?.rows ?? const []),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.currencySymbol,
    required this.startBalance,
    required this.trades,
    required this.winRatePct,
    required this.riskPct,
    required this.riskReward,
    required this.onCalculate,
    required this.onClear,
  });

  final String currencySymbol;
  final TextEditingController startBalance;
  final TextEditingController trades;
  final TextEditingController winRatePct;
  final TextEditingController riskPct;
  final TextEditingController riskReward;
  final VoidCallback onCalculate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.calcSettingsTitle,
                style: t.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(l.tradeReturn, style: t.labelMedium?.copyWith(color: DashboardTokens.muted)),
            ],
          ),
          const SizedBox(height: 12),
          NumberField(
            controller: startBalance,
            label: l.calcLabelStartBalance,
            suffix: currencySymbol,
            onSubmitted: (_) => onCalculate(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: NumberField(
                  controller: riskPct,
                  label: l.calcLabelRiskShort,
                  suffix: '%',
                  onSubmitted: (_) => onCalculate(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RiskRewardField(
                  controller: riskReward,
                  onSubmitted: (_) => onCalculate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: NumberField(
                  controller: winRatePct,
                  label: l.calcLabelWinRateShort,
                  suffix: '%',
                  onSubmitted: (_) => onCalculate(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NumberField(
                  controller: trades,
                  label: l.calcLabelTradesShort,
                  onSubmitted: (_) => onCalculate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton(onPressed: onCalculate, child: Text(l.buttonCalculate)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: DashboardTokens.muted.withValues(alpha: 0.6)),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l.clearAll),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.sim, required this.error});
  final TradeSimulationResult? sim;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.calcResultOfCalculation,
            style: t.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (error != null)
            Text(error!, style: t.bodyMedium?.copyWith(color: Colors.redAccent))
          else if (sim == null)
            Text('—', style: t.bodyMedium?.copyWith(color: DashboardTokens.muted))
          else ...[
            ResultRow(label: l.calcEndBalance, value: r'$ ' + fmtMoney(sim!.endBalance)),
            ResultRow(label: l.calcTotalGainLabel, value: r'$ ' + fmtMoney(sim!.totalGain)),
            ResultRow(label: l.tradeColTotalGainPct, value: '${sim!.totalGainPct.toStringAsFixed(2)}%'),
            ResultRow(label: l.calcWinsLosses, value: '${sim!.wins} / ${sim!.losses}'),
            ResultRow(
              label: l.calcProfitFactor,
              value: sim!.profitFactor.isFinite ? sim!.profitFactor.toStringAsFixed(2) : '—',
            ),
            ResultRow(label: l.calcMaxDrawdown, value: '${sim!.maxDrawdownPct.toStringAsFixed(2)}%'),
            ResultRow(label: l.calcBestBalance, value: r'$ ' + fmtMoney(sim!.maxBalance)),
            ResultRow(label: l.calcWorstBalance, value: r'$ ' + fmtMoney(sim!.minBalance)),
          ],
        ],
      ),
    );
  }
}

class _TradesTableCard extends StatelessWidget {
  const _TradesTableCard({required this.rows});
  final List<TradeRow> rows;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return CardShell(
      child: rows.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  '—',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: DashboardTokens.muted),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.25)),
                columns: [
                  DataColumn(label: Text(l.tradeColTrade)),
                  DataColumn(label: Text(l.tradeColStartingBalance)),
                  DataColumn(label: Text(l.tradeColResult)),
                  DataColumn(label: Text(l.tradeColPnl)),
                  DataColumn(label: Text(l.tradeColEndingBalance)),
                  DataColumn(label: Text(l.tradeColTotalGain)),
                  DataColumn(label: Text(l.tradeColTotalGainPct)),
                ],
                rows: rows.map((r) {
                  final c = r.isWin ? DashboardTokens.accentDeep : Colors.redAccent;
                  return DataRow(
                    cells: [
                      DataCell(Text('${r.index}')),
                      DataCell(Text(r'$ ' + fmtMoney(r.startBalance))),
                      DataCell(Text(r.isWin ? l.calcWin : l.calcLoss, style: TextStyle(color: c))),
                      DataCell(Text(
                        '${r.isWin ? '+' : '-'}${r'$'} ${fmtMoney(r.pnl.abs())}',
                        style: TextStyle(color: c),
                      )),
                      DataCell(Text(r'$ ' + fmtMoney(r.endBalance))),
                      DataCell(Text(r'$ ' + fmtMoney(r.totalGain))),
                      DataCell(Text('${r.totalGainPct.toStringAsFixed(2)}%')),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}




