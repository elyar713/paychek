import '../trade/trade_models.dart' show TradeListItem, TradeMindset;
import 'performance_trade_model.dart';

/// Extrait un nombre de lot depuis le champ quantité (ex. « 0.5 Lot », « 1 »).
double? parseLotSizeFromQuantiteLabel(String? s) {
  if (s == null || s.trim().isEmpty) return null;
  final normalized = s.trim().replaceAll(',', '.');
  final match = RegExp(r'(\d+\.?\d*)').firstMatch(normalized);
  if (match == null) return null;
  return double.tryParse(match.group(1)!);
}

/// Convertit les enregistrements du journal ([TradeListItem]) vers le modèle analytique [Trade].
List<Trade> performanceTradesFromJournal(List<TradeListItem> items) {
  return items.map(tradeListItemToPerformanceTrade).toList();
}

/// Un trade du journal → ligne pour stats Performance (durée, créneau horaire, P&L…).
Trade tradeListItemToPerformanceTrade(TradeListItem t) {
  final date = DateTime(t.entreeAt.year, t.entreeAt.month, t.entreeAt.day);
  final timeOfDay =
      '${t.entreeAt.hour.toString().padLeft(2, '0')}:${t.entreeAt.minute.toString().padLeft(2, '0')}';

  var durationMinutes = 0;
  if (t.sortieAt != null) {
    final m = t.sortieAt!.difference(t.entreeAt).inMinutes;
    durationMinutes = m < 0 ? 0 : m;
  }

  final profit = t.gainAmount;
  final win = profit > 1e-9;

  return Trade(
    date: date,
    timeOfDay: timeOfDay,
    durationMinutes: durationMinutes,
    profit: profit,
    win: win,
    commission: t.commissionAmount,
    checklistPct: t.checklistPct,
    planPct: t.planPct,
    strategiePct: t.strategiePct,
    etatPct: t.etatPct,
    mindsetPrincipe: t.mindset != TradeMindset.feeling,
    lotSize: parseLotSizeFromQuantiteLabel(t.quantiteLabel),
    strategieTitle: t.strategieTitle,
    strategieNonRespectIds: Set<String>.from(t.strategieNonRespectIds),
    planNonRespectIds: Set<String>.from(t.planNonRespectIds),
    checklistNonRespectIds: Set<String>.from(t.checklistNonRespectIds),
    etatNonRespectIds: Set<String>.from(t.etatNonRespectIds),
    planReport: t.planReport,
    psychTags: List<String>.from(t.psychTags),
    assetClass: t.assetClass,
    pair: t.pair,
    avantNews: t.avantNews,
    apresNews: t.apresNews,
    performanceLite: t.performanceLite,
  );
}
