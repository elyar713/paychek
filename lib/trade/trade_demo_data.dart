import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../ajouter_trade/ajouter_trade_asset_class.dart';
import '../analyse/analyse_controller.dart';
import '../analyse/analyse_default_demo_seed.dart';
import '../analyse/analyse_report_snapshot.dart';
import '../reglage/user_portfolio_models.dart';
import 'trade_models.dart';

String _demoDateLine(DateTime d, Locale loc) {
  return DateFormat("dd MMMM yyyy '•' HH:mm", loc.toString()).format(d.toLocal());
}

AnalyseReportSnapshot _buildGoldPlan(Locale loc) {
  final c = AnalyseController();
  applyAnalyseDefaultGoldBreakoutDemo(c, locale: loc);
  final s = AnalyseReportSnapshot.fromController(c, locale: loc);
  c.dispose();
  return s;
}

AnalyseReportSnapshot _buildEurPlan(Locale loc) {
  final c = AnalyseController();
  applyAnalyseDefaultEuroUsdWeeklySwingDemo(c, locale: loc);
  final s = AnalyseReportSnapshot.fromController(c, locale: loc);
  c.dispose();
  return s;
}

/// Données de démo lorsque le journal du portefeuille par défaut est vide.
///
/// Couvre : plan d’analyse (snapshots), Principle / Feeling, tags psychologiques,
/// cases discipline partielles, news avant/après, commission, classes d’actifs,
/// breakeven, position ouverte, entrée [performanceLite] façon import CSV.
List<TradeListItem> tradeDemoItems({Locale? locale}) {
  final loc = locale ?? WidgetsBinding.instance.platformDispatcher.locale;
  final goldPlan = _buildGoldPlan(loc);
  final eurPlan = _buildEurPlan(loc);

  // Dates glissantes (calendrier + filtres Mois/Semaine) : visibles dès la vue mois courant.
  final clock = DateTime.now().toLocal();
  final today = DateTime(clock.year, clock.month, clock.day);
  DateTime entry(int daysBack, int h, int m) {
    final d = today.subtract(Duration(days: daysBack));
    return DateTime(d.year, d.month, d.day, h, m);
  }

  final dBtcOpen = entry(0, 8, 45);
  final dXauOpen = entry(1, 14, 20);
  final dXauClose = entry(1, 15, 5);
  final dEurOpen = entry(2, 9, 45);
  final dEurClose = entry(2, 10, 8);
  final dUs30Open = entry(3, 15, 30);
  final dUs30Close = entry(3, 16, 10);
  final dGbpOpen = entry(4, 16, 10);
  final dGbpClose = entry(4, 16, 32);
  final dNasOpen = entry(5, 11, 0);
  final dNasClose = entry(5, 11, 42);

  return [
    // Position ouverte — filtre « Position ouverte », pas de sortie.
    TradeListItem(
      id: 'demo_btc_open',
      pair: 'BTCUSD',
      side: TradeSide.achat,
      amountLabel: r'+0,00$',
      gainAmount: 0,
      commissionAmount: 0,
      dateLine: _demoDateLine(dBtcOpen, loc),
      entreeAt: dBtcOpen,
      sortieAt: null,
      breakeven: false,
      avantNews: false,
      apresNews: false,
      quantiteLabel: '0.15',
      prixEntreeLabel: '97240',
      prixSortieLabel: null,
      checklistPct: 85,
      planPct: 70,
      strategiePct: 75,
      etatPct: 65,
      mindset: TradeMindset.principe,
      strategieTitle: 'Breakout with Volume',
      planReport: goldPlan,
      planNonRespectIds: const {'ctx_phase'},
      strategieNonRespectIds: const {},
      checklistNonRespectIds: const {},
      etatNonRespectIds: const {'moment:focus'},
      isProfit: true,
      assetClass: AjouterTradeAssetClass.crypto,
      portfolioId: kDefaultPortfolioId,
    ),
    // Gagnant matières premières + commission + news avant la sortie.
    TradeListItem(
      id: 'demo_xau_win',
      pair: 'XAUUSD',
      side: TradeSide.vente,
      amountLabel: r'+1,200.00$',
      gainAmount: 1200,
      commissionAmount: 8.5,
      dateLine: _demoDateLine(dXauOpen, loc),
      entreeAt: dXauOpen,
      sortieAt: dXauClose,
      breakeven: false,
      avantNews: true,
      apresNews: false,
      quantiteLabel: '1',
      prixEntreeLabel: '2187.50',
      prixSortieLabel: '2173.90',
      checklistPct: 100,
      planPct: 92,
      strategiePct: 88,
      etatPct: 75,
      mindset: TradeMindset.principe,
      strategieTitle: 'Breakout with Volume',
      planReport: goldPlan,
      planNonRespectIds: {'ctx_phase', 'struct_support'},
      strategieNonRespectIds: {'mes_regles_0', 'setup_signal'},
      checklistNonRespectIds: {'analyse:a2'},
      etatNonRespectIds: {'moment:focus', 'moment:confidence', 'moment:risk'},
      isProfit: true,
      assetClass: AjouterTradeAssetClass.matieresPremieres,
      portfolioId: kDefaultPortfolioId,
    ),
    // Perdant Forex + Feeling + tags + news après l’entrée + plan swing complet.
    TradeListItem(
      id: 'demo_eur_loss',
      pair: 'EURUSD',
      side: TradeSide.achat,
      amountLabel: r'-450.00$',
      gainAmount: -450,
      commissionAmount: 4,
      dateLine: _demoDateLine(dEurOpen, loc),
      entreeAt: dEurOpen,
      sortieAt: dEurClose,
      breakeven: false,
      avantNews: false,
      apresNews: true,
      quantiteLabel: '1',
      prixEntreeLabel: '1.08350',
      prixSortieLabel: '1.08210',
      checklistPct: 60,
      planPct: 55,
      strategiePct: 70,
      etatPct: 40,
      mindset: TradeMindset.feeling,
      strategieTitle: 'Breakout with Volume',
      planReport: eurPlan,
      psychTags: const ['FOMO', 'TILT'],
      planNonRespectIds: {'ctx_trend'},
      checklistNonRespectIds: {'risque:r1', 'risque:r2'},
      strategieNonRespectIds: const {},
      etatNonRespectIds: {'moment:risk', 'moment:emotion', 'emotion:e5'},
      isProfit: false,
      assetClass: AjouterTradeAssetClass.forex,
      portfolioId: kDefaultPortfolioId,
    ),
    // Breakeven indice — filtre Breakeven.
    TradeListItem(
      id: 'demo_us30_be',
      pair: 'US30',
      side: TradeSide.achat,
      amountLabel: r'+0.00$',
      gainAmount: 0,
      commissionAmount: 2,
      dateLine: _demoDateLine(dUs30Open, loc),
      entreeAt: dUs30Open,
      sortieAt: dUs30Close,
      breakeven: true,
      avantNews: false,
      apresNews: false,
      quantiteLabel: '0.5',
      prixEntreeLabel: '43120',
      prixSortieLabel: '43118',
      checklistPct: 78,
      planPct: 82,
      strategiePct: 80,
      etatPct: 70,
      mindset: TradeMindset.principe,
      strategieTitle: 'Breakout with Volume',
      planReport: goldPlan,
      planNonRespectIds: const {},
      strategieNonRespectIds: const {},
      checklistNonRespectIds: const {},
      etatNonRespectIds: const {},
      isProfit: true,
      assetClass: AjouterTradeAssetClass.indice,
      portfolioId: kDefaultPortfolioId,
    ),
    // Gagnant JPY — discipline serrée.
    TradeListItem(
      id: 'demo_gbpjpy_win',
      pair: 'GBPJPY',
      side: TradeSide.vente,
      amountLabel: r'+320.00$',
      gainAmount: 320,
      commissionAmount: 3,
      dateLine: _demoDateLine(dGbpOpen, loc),
      entreeAt: dGbpOpen,
      sortieAt: dGbpClose,
      breakeven: false,
      avantNews: false,
      apresNews: false,
      quantiteLabel: '1',
      prixEntreeLabel: '189.220',
      prixSortieLabel: '189.010',
      checklistPct: 90,
      planPct: 100,
      strategiePct: 95,
      etatPct: 80,
      mindset: TradeMindset.principe,
      strategieTitle: 'Breakout with Volume',
      planReport: eurPlan,
      planNonRespectIds: const {},
      checklistNonRespectIds: const {},
      strategieNonRespectIds: const {},
      etatNonRespectIds: const {},
      isProfit: true,
      assetClass: AjouterTradeAssetClass.forex,
      portfolioId: kDefaultPortfolioId,
    ),
    // Import « léger » (CSV) : P&L conservé, champs discipline masqués côté Performance.
    TradeListItem(
      id: 'demo_nas_lite',
      pair: 'NAS100',
      side: TradeSide.achat,
      amountLabel: r'+185.00$',
      gainAmount: 185,
      commissionAmount: 0,
      dateLine: _demoDateLine(dNasOpen, loc),
      entreeAt: dNasOpen,
      sortieAt: dNasClose,
      breakeven: false,
      quantiteLabel: '2',
      prixEntreeLabel: '21340',
      prixSortieLabel: '21412',
      checklistPct: 0,
      planPct: 0,
      strategiePct: 0,
      etatPct: 0,
      mindset: TradeMindset.principe,
      strategieTitle: 'CSV import',
      planReport: null,
      isProfit: true,
      assetClass: AjouterTradeAssetClass.indice,
      performanceLite: true,
      portfolioId: kDefaultPortfolioId,
    ),
  ];
}
