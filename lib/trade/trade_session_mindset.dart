import 'trade_discipline_day_snapshot.dart';
import 'trade_models.dart';

/// Règle « session du jour » : les N premiers trades (ordre d’entrée) = principe, le reste = feeling.
class TradeSessionMindsetRules {
  const TradeSessionMindsetRules({
    this.autoTagEnabled = false,
    this.plannedTradesPerDay = 2,
  });

  final bool autoTagEnabled;
  final int plannedTradesPerDay;

  int get clampedPlanned => plannedTradesPerDay.clamp(1, 10);
}

/// Rang 1-based du trade sur le jour d’entrée (parmi [existing] + entrée considérée).
int tradeSessionRankOnDay({
  required DateTime entreeAt,
  required List<TradeListItem> existing,
  String? portfolioId,
  String? excludeTradeId,
}) {
  final day = tradeEntryDateOnly(entreeAt);
  final onDay = <TradeListItem>[
    for (final t in existing)
      if (t.id != excludeTradeId &&
          (portfolioId == null || t.portfolioId == portfolioId) &&
          tradeEntryDateOnly(t.entreeAt) == day)
        t,
  ];
  onDay.sort((a, b) => a.entreeAt.compareTo(b.entreeAt));
  var rank = 1;
  for (final t in onDay) {
    if (t.entreeAt.isBefore(entreeAt)) {
      rank++;
    } else if (t.entreeAt.isAtSameMomentAs(entreeAt)) {
      rank++;
    }
  }
  return rank;
}

TradeMindset tradeSessionMindsetForRank(int rank1Based, TradeSessionMindsetRules rules) {
  if (!rules.autoTagEnabled) return TradeMindset.principe;
  return rank1Based <= rules.clampedPlanned
      ? TradeMindset.principe
      : TradeMindset.feeling;
}

TradeMindset resolveTradeSessionMindset({
  required DateTime entreeAt,
  required List<TradeListItem> existing,
  required TradeSessionMindsetRules rules,
  String? portfolioId,
  String? excludeTradeId,
}) {
  final rank = tradeSessionRankOnDay(
    entreeAt: entreeAt,
    existing: existing,
    portfolioId: portfolioId,
    excludeTradeId: excludeTradeId,
  );
  return tradeSessionMindsetForRank(rank, rules);
}

/// Ré-applique la règle sur une journée (import CSV : fusion existant + nouveaux).
List<TradeListItem> applySessionMindsetToIncomingTrades({
  required List<TradeListItem> existing,
  required List<TradeListItem> incoming,
  required TradeSessionMindsetRules rules,
  required String portfolioId,
}) {
  if (!rules.autoTagEnabled || incoming.isEmpty) return incoming;

  final incomingIds = incoming.map((e) => e.id).toSet();
  final byDay = <DateTime, List<TradeListItem>>{};

  void bucket(TradeListItem t) {
    if (t.portfolioId != portfolioId) return;
    final d = tradeEntryDateOnly(t.entreeAt);
    byDay.putIfAbsent(d, () => []).add(t);
  }

  for (final t in existing) {
    bucket(t);
  }
  for (final t in incoming) {
    bucket(t);
  }

  final mindsetById = <String, TradeMindset>{};
  for (final dayTrades in byDay.values) {
    dayTrades.sort((a, b) => a.entreeAt.compareTo(b.entreeAt));
    for (var i = 0; i < dayTrades.length; i++) {
      final m = i < rules.clampedPlanned
          ? TradeMindset.principe
          : TradeMindset.feeling;
      mindsetById[dayTrades[i].id] = m;
    }
  }

  return [
    for (final t in incoming)
      if (incomingIds.contains(t.id))
        _tradeWithMindset(t, mindsetById[t.id] ?? t.mindset)
      else
        t,
  ];
}

TradeListItem _tradeWithMindset(TradeListItem t, TradeMindset mindset) {
  return TradeListItem(
    id: t.id,
    pair: t.pair,
    side: t.side,
    amountLabel: t.amountLabel,
    gainAmount: t.gainAmount,
    commissionAmount: t.commissionAmount,
    dateLine: t.dateLine,
    entreeAt: t.entreeAt,
    sortieAt: t.sortieAt,
    breakeven: t.breakeven,
    avantNews: t.avantNews,
    apresNews: t.apresNews,
    quantiteLabel: t.quantiteLabel,
    screenshotPath: t.screenshotPath,
    screenshotBytes: t.screenshotBytes,
    prixEntreeLabel: t.prixEntreeLabel,
    prixSortieLabel: t.prixSortieLabel,
    checklistPct: t.checklistPct,
    planPct: t.planPct,
    strategiePct: t.strategiePct,
    etatPct: t.etatPct,
    mindset: mindset,
    mindsetExplicit: true,
    strategieTitle: t.strategieTitle,
    planReport: t.planReport,
    linkedAnalyseReport: t.linkedAnalyseReport,
    linkedAnalysePdfBytes: t.linkedAnalysePdfBytes,
    linkedAnalysePdfFileName: t.linkedAnalysePdfFileName,
    strategieNonRespectIds: t.strategieNonRespectIds,
    planNonRespectIds: t.planNonRespectIds,
    checklistNonRespectIds: t.checklistNonRespectIds,
    etatNonRespectIds: t.etatNonRespectIds,
    isProfit: t.isProfit,
    assetClass: t.assetClass,
    performanceLite: t.performanceLite,
    portfolioId: t.portfolioId,
    psychTags: t.psychTags,
    userNote: t.userNote,
    syncRev: t.syncRev,
  );
}

String tradeMindsetToAjouterTradeKey(TradeMindset m) => switch (m) {
      TradeMindset.feeling => 'feeling',
      TradeMindset.principe => 'principe',
      TradeMindset.none => 'none',
    };
