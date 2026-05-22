import '../strategie/widgets/strategie_setup_cards_content.dart';
import 'trade_models.dart';

/// Retire les % stratégie « fantômes » (défaut import CSV) et marque les saisies manuelles.
List<TradeListItem> applyJournalStrategieExplicitMigration(
  List<TradeListItem> items,
) {
  var changed = false;
  final out = <TradeListItem>[];
  for (final t in items) {
    final n = normalizeTradeStrategieExplicitLink(t);
    if (n != t) changed = true;
    out.add(n);
  }
  return changed ? out : items;
}

bool journalStrategieMigrationWouldChange(List<TradeListItem> items) {
  for (final t in items) {
    if (normalizeTradeStrategieExplicitLink(t) != t) return true;
  }
  return false;
}

String _defaultStrategieSetupTitle() =>
    strategieSetupDefaultCardDataList().first.title.trim();

bool _isDefaultStrategieTitle(String title) =>
    title.trim() == _defaultStrategieSetupTitle();

/// Import CSV : slider 50 % (ou 0 après correctif) + titre setup par défaut, sans rétroaction.
bool isLikelyAutoCsvStrategie(TradeListItem t) {
  if (t.strategieLinkedExplicit) return false;
  if (t.strategieNonRespectIds.isNotEmpty) return false;
  if (t.strategiePct == 0 && t.strategieTitle.trim().isEmpty) return false;
  if (!t.mindsetExplicit) {
    if (t.strategiePct == 50) return true;
    if (t.strategiePct == 0 && _isDefaultStrategieTitle(t.strategieTitle)) {
      return true;
    }
  }
  return false;
}

bool legacyInferredStrategieLinkedExplicit(TradeListItem t) {
  if (t.strategieNonRespectIds.isNotEmpty) return true;
  if (t.strategiePct != 50 && t.strategiePct != 0) return true;
  final title = t.strategieTitle.trim();
  if (title.isNotEmpty && !_isDefaultStrategieTitle(title)) return true;
  return false;
}

TradeListItem normalizeTradeStrategieExplicitLink(TradeListItem t) {
  final now = DateTime.now().millisecondsSinceEpoch;

  if (t.strategieLinkedExplicit) return t;

  if (isLikelyAutoCsvStrategie(t)) {
    return _rebuild(
      t,
      strategiePct: 0,
      strategieTitle: '',
      strategieNonRespectIds: const {},
      strategieLinkedExplicit: false,
      syncRev: now,
    );
  }

  if (legacyInferredStrategieLinkedExplicit(t)) {
    return _rebuild(t, strategieLinkedExplicit: true, syncRev: now);
  }

  if (t.strategiePct > 0 || t.strategieTitle.trim().isNotEmpty) {
    return _rebuild(t, strategieLinkedExplicit: true, syncRev: now);
  }

  return t;
}

TradeListItem _rebuild(
  TradeListItem t, {
  double? strategiePct,
  String? strategieTitle,
  Set<String>? strategieNonRespectIds,
  bool? strategieLinkedExplicit,
  int? syncRev,
}) {
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
    strategiePct: strategiePct ?? t.strategiePct,
    etatPct: t.etatPct,
    mindset: t.mindset,
    mindsetExplicit: t.mindsetExplicit,
    planLinkedExplicit: t.planLinkedExplicit,
    strategieLinkedExplicit:
        strategieLinkedExplicit ?? t.strategieLinkedExplicit,
    checklistLinkedExplicit: t.checklistLinkedExplicit,
    etatLinkedExplicit: t.etatLinkedExplicit,
    strategieTitle: strategieTitle ?? t.strategieTitle,
    planReport: t.planReport,
    linkedAnalyseReport: t.linkedAnalyseReport,
    linkedAnalysePdfBytes: t.linkedAnalysePdfBytes,
    linkedAnalysePdfFileName: t.linkedAnalysePdfFileName,
    strategieNonRespectIds:
        strategieNonRespectIds ?? t.strategieNonRespectIds,
    planNonRespectIds: t.planNonRespectIds,
    checklistNonRespectIds: t.checklistNonRespectIds,
    etatNonRespectIds: t.etatNonRespectIds,
    isProfit: t.isProfit,
    assetClass: t.assetClass,
    performanceLite: t.performanceLite,
    portfolioId: t.portfolioId,
    psychTags: t.psychTags,
    userNote: t.userNote,
    syncRev: syncRev ?? t.syncRev,
  );
}
