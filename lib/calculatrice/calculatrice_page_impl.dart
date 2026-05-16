import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ajouter_trade/ajouter_trade_actifs.dart';
import '../ajouter_trade/ajouter_trade_asset_class.dart';
import '../dashboard/dashboard_tokens.dart';
import '../performance/performance_locale_copy.dart';
import '../widgets/paychek_page_header.dart';
import '../l10n/app_localizations.dart';
import '../questionnaire/user_capital_scope.dart';
import '../questionnaire/user_capital_store.dart';
import '../reglage/user_portfolio_scope.dart';
import '../reglage/user_portfolio_store.dart';
import 'calculatrice_models.dart';
import 'ratio_calculator.dart';
import 'trade_return_simulation.dart';
import 'widgets/calculatrice_section_toggle.dart';
import 'widgets/ratio_widgets.dart';
import 'widgets/trade_return_widgets.dart';

class CalculatricePage extends StatefulWidget {
  const CalculatricePage({
    super.key,
    this.onNavigateToDashboard,
    this.onCloseAsTab,
  });

  final VoidCallback? onNavigateToDashboard;
  final VoidCallback? onCloseAsTab;

  @override
  State<CalculatricePage> createState() => _CalculatricePageState();
}

class _CalculatricePageState extends State<CalculatricePage> {
  CalculatriceSection _section = CalculatriceSection.tradeReturn;

  final TextEditingController _startBalance = TextEditingController(text: '1000');
  final TextEditingController _trades = TextEditingController(text: '100');
  final TextEditingController _winRatePct = TextEditingController(text: '55');
  final TextEditingController _riskPct = TextEditingController(text: '1');
  final TextEditingController _riskReward = TextEditingController(text: '2');

  final TextEditingController _ratioLot = TextEditingController(text: '1');
  final TextEditingController _ratioEntry = TextEditingController(text: '1.1000');
  final TextEditingController _ratioSl = TextEditingController(text: '1.0950');
  final TextEditingController _ratioTp = TextEditingController(text: '1.1100');

  AjouterTradeAssetClass _ratioMarket = AjouterTradeAssetClass.forex;
  String _ratioAsset = 'EUR/USD';

  TradeSimulationResult? _sim;
  String? _tradeReturnError;
  RatioResult? _ratioResult;
  String? _ratioError;

  UserCapitalStore? _capitalStore;
  UserPortfolioStore? _portfolioStore;
  String _currencySymbol = r'$';
  bool _startBalanceDirty = false;
  bool _settingStartBalanceFromStore = false;

  bool get _embeddedInTabShell => widget.onCloseAsTab != null;
  bool get _isFrench => Localizations.localeOf(context).languageCode == 'fr';

  void _handleLeadingBack() {
    if (_embeddedInTabShell) {
      widget.onCloseAsTab!.call();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  String _calculatriceHeaderSubtitle() {
    final code = Localizations.localeOf(context).languageCode;
    return perf6(
      code,
      'Simulations rendement et ratio — valeurs indicatives.',
      'Return and ratio simulations — indicative values only.',
      'Simulaciones de retorno y ratio — valores orientativos.',
      'Rendite- und Ratio-Simulationen — unverbindliche Werte.',
      'Simulações de retorno e ratio — valores indicativos.',
      '수익·비율 시뮬레이션 — 참고 수치.',
    );
  }

  @override
  void initState() {
    super.initState();
    _startBalance.addListener(() {
      if (_settingStartBalanceFromStore) return;
      _startBalanceDirty = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = UserCapitalScope.of(context);
    if (!identical(_capitalStore, store)) {
      _capitalStore?.removeListener(_onCapitalChanged);
      _capitalStore = store;
      _capitalStore?.addListener(_onCapitalChanged);
    }
    final pf = UserPortfolioScope.of(context);
    if (!identical(_portfolioStore, pf)) {
      _portfolioStore?.removeListener(_onCapitalChanged);
      _portfolioStore = pf;
      _portfolioStore?.addListener(_onCapitalChanged);
    }
    _onCapitalChanged();
  }

  void _onCapitalChanged() {
    final store = _capitalStore;
    final pf = _portfolioStore;
    if (store == null || pf == null) return;
    _currencySymbol = pf.effectiveCurrencySymbol(store);
    final amount = pf.effectiveCapitalAmount(store);

    if (!_startBalanceDirty && amount != null) {
      _settingStartBalanceFromStore = true;
      _startBalance.text = _formatNumber(amount);
      _settingStartBalanceFromStore = false;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _capitalStore?.removeListener(_onCapitalChanged);
    _portfolioStore?.removeListener(_onCapitalChanged);
    _startBalance.dispose();
    _trades.dispose();
    _winRatePct.dispose();
    _riskPct.dispose();
    _riskReward.dispose();
    _ratioLot.dispose();
    _ratioEntry.dispose();
    _ratioSl.dispose();
    _ratioTp.dispose();
    super.dispose();
  }

  String _formatNumber(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(2).replaceAll('.', ',');
  }

  double? _parseNum(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));
  int? _parseInt(TextEditingController c) =>
      int.tryParse(c.text.trim().replaceAll(',', '.'));

  void _calculateTradeReturn() {
    final isFr = _isFrench;
    final start = _parseNum(_startBalance);
    final trades = _parseInt(_trades);
    final winRate = _parseNum(_winRatePct);
    final riskPct = _parseNum(_riskPct);
    final rr = _parseNum(_riskReward);

    String? err;
    if (start == null || start <= 0) {
      err = isFr ? 'Solde initial invalide.' : 'Invalid start balance.';
    }
    if (err == null && (trades == null || trades <= 0 || trades > 2000)) {
      err = isFr
          ? 'Le nombre de trades doit être entre 1 et 2000.'
          : 'Trades must be between 1 and 2000.';
    }
    if (err == null && (winRate == null || winRate < 0 || winRate > 100)) {
      err = isFr
          ? 'Le win rate doit être entre 0 et 100.'
          : 'Win rate must be between 0 and 100.';
    }
    if (err == null && (riskPct == null || riskPct <= 0 || riskPct > 100)) {
      err = isFr
          ? 'Le risque (%) doit être entre 0 et 100.'
          : 'Risk % must be between 0 and 100.';
    }
    if (err == null && (rr == null || rr <= 0 || rr > 1000)) {
      err = isFr ? 'Risk:Reward invalide.' : 'Invalid risk:reward.';
    }

    if (err != null) {
      setState(() {
        _tradeReturnError = err;
        _sim = null;
      });
      return;
    }

    final seed = DateTime.now().microsecondsSinceEpoch;
    final result = simulateTrades(
      startBalance: start!,
      trades: trades!,
      winRate: winRate! / 100.0,
      riskPct: riskPct! / 100.0,
      riskReward: rr!,
      seed: seed,
    );

    setState(() {
      _tradeReturnError = null;
      _sim = result;
    });
  }

  void _clearTradeReturn() {
    setState(() {
      _startBalance.text = '1000';
      _trades.text = '100';
      _winRatePct.text = '55';
      _riskPct.text = '1';
      _riskReward.text = '2';
      _tradeReturnError = null;
      _sim = null;
    });
  }

  void _calculateRatio() {
    final isFr = _isFrench;
    final lot = _parseNum(_ratioLot);
    final entry = _parseNum(_ratioEntry);
    final sl = _parseNum(_ratioSl);
    final tp = _parseNum(_ratioTp);

    String? err;
    if (lot == null || lot <= 0) err = isFr ? 'Lot invalide.' : 'Invalid lot size.';
    if (err == null && (entry == null || entry <= 0)) {
      err = isFr ? 'Prix d’entrée invalide.' : 'Invalid entry price.';
    }
    if (err == null && (sl == null || sl <= 0)) {
      err = isFr ? 'Stop loss invalide.' : 'Invalid stop loss.';
    }
    if (err == null && (tp == null || tp <= 0)) {
      err = isFr ? 'Take profit invalide.' : 'Invalid take profit.';
    }
    if (err == null && entry == sl) {
      err = isFr
          ? 'Entrée et SL ne peuvent pas être identiques.'
          : 'Entry and SL cannot be identical.';
    }

    if (err != null) {
      setState(() {
        _ratioError = err;
        _ratioResult = null;
      });
      return;
    }

    final result = computeRatio(
      market: _ratioMarket,
      asset: _ratioAsset,
      lot: lot!,
      entry: entry!,
      sl: sl!,
      tp: tp!,
      capital: _capitalStore != null && _portfolioStore != null
          ? _portfolioStore!.effectiveCapitalAmount(_capitalStore!)
          : _capitalStore?.capitalAmount,
    );

    setState(() {
      _ratioError = null;
      _ratioResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    return PopScope(
      canPop: !_embeddedInTabShell,
      onPopInvokedWithResult: (didPop, result) {
        if (_embeddedInTabShell) {
          if (!didPop) widget.onCloseAsTab!.call();
          return;
        }
        if (didPop) widget.onNavigateToDashboard?.call();
      },
      child: ColoredBox(
        color: DashboardTokens.scaffoldMatte,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaychekPageHeader(
                onBack: _handleLeadingBack,
                title: l.plusCalculator,
                subtitle: _calculatriceHeaderSubtitle(),
                maxContentWidth: 1180,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 760;
                    final hPad = PaychekPageHeader.horizontalPad(constraints.maxWidth);
                    final maxW = math.min(1180.0, math.max(0.0, constraints.maxWidth - 2 * hPad));
                    return ListView(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxW),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                  SectionToggle(
                    value: _section,
                    onChanged: (v) => setState(() => _section = v),
                  ),
                  const SizedBox(height: 16),
                  if (_section == CalculatriceSection.ratio)
                    RatioSection(
                      market: _ratioMarket,
                      asset: _ratioAsset,
                      currencySymbol: _currencySymbol,
                      lot: _ratioLot,
                      entry: _ratioEntry,
                      sl: _ratioSl,
                      tp: _ratioTp,
                      error: _ratioError,
                      result: _ratioResult,
                      onChangedMarket: (v) {
                        setState(() {
                          _ratioMarket = v;
                          _ratioAsset = ajouterTradeActifsPour(
                            v,
                            locale: Localizations.localeOf(context),
                          ).first;
                        });
                        _calculateRatio();
                      },
                      onChangedAsset: (v) {
                        setState(() => _ratioAsset = v);
                        _calculateRatio();
                      },
                      onCalculate: _calculateRatio,
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: DashboardTokens.muted.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isFrench
                                  ? "Attention : ces calculs ne sont pas des chiffres contractuels. Ils servent uniquement à donner une idée."
                                  : "Warning: these calculations are not contractual figures. They are only estimates.",
                              style: t.bodySmall?.copyWith(
                                color: DashboardTokens.muted.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TradeReturnSection(
                      isWide: isWide,
                      currencySymbol: _currencySymbol,
                      startBalance: _startBalance,
                      trades: _trades,
                      winRatePct: _winRatePct,
                      riskPct: _riskPct,
                      riskReward: _riskReward,
                      sim: _sim,
                      error: _tradeReturnError,
                      onCalculate: _calculateTradeReturn,
                      onClear: _clearTradeReturn,
                    ),
                  ],
                ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

