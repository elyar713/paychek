import 'package:flutter/foundation.dart';

import '../ajouter_trade/ajouter_trade_asset_class.dart';
import '../analyse/analyse_report_snapshot.dart';
import '../reglage/user_portfolio_models.dart';

enum TradeSide { vente, achat }

enum TradeMindset { principe, feeling }

@immutable
class TradeListItem {
  const TradeListItem({
    required this.id,
    required this.pair,
    required this.side,
    required this.amountLabel,

    /// Gain / perte signé (même unité que le capital utilisateur).
    required this.gainAmount,
    this.commissionAmount = 0,
    required this.dateLine,
    required this.entreeAt,
    this.sortieAt,
    this.breakeven = false,
    this.avantNews = false,
    this.apresNews = false,
    this.quantiteLabel,
    this.screenshotPath,
    this.screenshotBytes,
    this.prixEntreeLabel,
    this.prixSortieLabel,
    required this.checklistPct,
    required this.planPct,
    required this.strategiePct,
    required this.etatPct,
    required this.mindset,
    required this.strategieTitle,
    this.planReport,
    this.strategieNonRespectIds = const <String>{},
    this.planNonRespectIds = const <String>{},
    this.checklistNonRespectIds = const <String>{},
    this.etatNonRespectIds = const <String>{},
    this.isProfit = true,
    this.assetClass,
    this.performanceLite = false,

    /// Compte / broker (journal séparé par portefeuille).
    this.portfolioId = kDefaultPortfolioId,

    /// Tags psychologiques (FOMO, TILT, …) depuis la section TAG d’Ajouter trade.
    this.psychTags = const <String>[],

    /// Horodatage client pour fusion multi-appareils (web / mobile) ; incrémenté à chaque enregistrement.
    this.syncRev = 0,
  });

  final String id;
  final String pair;
  final TradeSide side;
  final String amountLabel;
  final double gainAmount;
  final double commissionAmount;
  final String dateLine;
  final DateTime entreeAt;
  final DateTime? sortieAt;
  final bool breakeven;
  final bool avantNews;
  final bool apresNews;
  final String? quantiteLabel;
  final String? screenshotPath;
  final Uint8List? screenshotBytes;
  final String? prixEntreeLabel;
  final String? prixSortieLabel;
  final double checklistPct;
  final double planPct;
  final double strategiePct;
  final double etatPct;
  final TradeMindset mindset;

  /// Stratégie choisie (pour résoudre les libellés non respectés).
  final String strategieTitle;

  /// Snapshot de plan d'analyse (pour résoudre les ids).
  final AnalyseReportSnapshot? planReport;

  /// Ids non respectés (selon les menus Ajouter trade).
  final Set<String> strategieNonRespectIds;
  final Set<String> planNonRespectIds;
  final Set<String> checklistNonRespectIds;
  final Set<String> etatNonRespectIds;
  final bool isProfit;

  /// Marché choisi à l’enregistrement (Performance, buckets volume par marché).
  final AjouterTradeAssetClass? assetClass;

  /// Saisie minimale (actif / entrée / sortie / qty) sans discipline : masque Lens, horaires, durée, etc. sur Performance.
  final bool performanceLite;

  final String portfolioId;

  /// Libellés des tags cochés (ordre d’insertion approximatif).
  final List<String> psychTags;

  /// Fusion Firestore / prefs : plus récent gagne (à égalité, priorité au cloud).
  final int syncRev;

  bool get isClosed => sortieAt != null;

  /// Gagnant **fermé** uniquement (pas une position ouverte).
  bool get countsAsClosedWin => isClosed && !breakeven && gainAmount > 0;

  /// Perdant **fermé** uniquement.
  bool get countsAsClosedLoss => isClosed && !breakeven && gainAmount < 0;

  /// Breakeven / flat **après clôture** uniquement — une position ouverte avec PnL à 0 n’est pas du breakeven.
  bool get countsAsClosedBreakevenOrFlat =>
      isClosed && (breakeven || gainAmount == 0);

  TradeListItem copyWith({
    int? syncRev,
    Uint8List? screenshotBytes,
    String? screenshotPath,
  }) {
    return TradeListItem(
      id: id,
      pair: pair,
      side: side,
      amountLabel: amountLabel,
      gainAmount: gainAmount,
      commissionAmount: commissionAmount,
      dateLine: dateLine,
      entreeAt: entreeAt,
      sortieAt: sortieAt,
      breakeven: breakeven,
      avantNews: avantNews,
      apresNews: apresNews,
      quantiteLabel: quantiteLabel,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      screenshotBytes: screenshotBytes ?? this.screenshotBytes,
      prixEntreeLabel: prixEntreeLabel,
      prixSortieLabel: prixSortieLabel,
      checklistPct: checklistPct,
      planPct: planPct,
      strategiePct: strategiePct,
      etatPct: etatPct,
      mindset: mindset,
      strategieTitle: strategieTitle,
      planReport: planReport,
      strategieNonRespectIds: strategieNonRespectIds,
      planNonRespectIds: planNonRespectIds,
      checklistNonRespectIds: checklistNonRespectIds,
      etatNonRespectIds: etatNonRespectIds,
      isProfit: isProfit,
      assetClass: assetClass,
      performanceLite: performanceLite,
      portfolioId: portfolioId,
      psychTags: psychTags,
      syncRev: syncRev ?? this.syncRev,
    );
  }
}
