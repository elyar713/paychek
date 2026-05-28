import '../trade/trade_models.dart';
import '../trade/trade_plan_analysis.dart';

/// Résumé compact du journal Trade pour le contexte JSON du Coach AI.
abstract final class CoachAiTradeJournalContext {
  static const int maxRecentTrades = 20;

  static Map<String, dynamic> build(Iterable<TradeListItem> trades) {
    final all = trades.toList();
    final sorted = List<TradeListItem>.from(all)
      ..sort((a, b) {
        final ad = a.sortieAt ?? a.entreeAt;
        final bd = b.sortieAt ?? b.entreeAt;
        return bd.compareTo(ad);
      });
    final recent = sorted.take(maxRecentTrades).map(_tradeToMap).toList();

    return <String, dynamic>{
      'source': 'trade_journal_items_v1',
      'sameDataAsTradePage': true,
      'totalTrades': all.length,
      'closedTrades': all.where((t) => t.isClosed).length,
      'openTrades': all.where((t) => !t.isClosed).length,
      'recentTradesIncluded': recent.length,
      'recentTrades': recent,
      'note':
          'Même journal que l’onglet Trade / Ajouter trade (prefs + Firestore). '
          'recentTrades = les $maxRecentTrades plus récents par date de sortie ou d’entrée.',
    };
  }

  static Map<String, dynamic> _tradeToMap(TradeListItem t) {
    final strategie = t.strategieTitle.trim();
    final note = t.userNote?.trim();
    return <String, dynamic>{
      'id': t.id,
      'pair': t.pair,
      'side': t.side == TradeSide.vente ? 'vente' : 'achat',
      'entreeAt': t.entreeAt.toIso8601String(),
      if (t.sortieAt != null) 'sortieAt': t.sortieAt!.toIso8601String(),
      'isClosed': t.isClosed,
      'pnl': double.parse(t.gainAmount.toStringAsFixed(2)),
      'breakeven': t.breakeven,
      'performanceLite': t.performanceLite,
      'disciplineFullyRecorded': !tradeHasAnyDisciplineMissing(t),
      'discipline': <String, dynamic>{
        'checklist': t.checklistLinkedExplicit,
        'analysisPlan': t.planLinkedExplicit,
        'strategy': t.strategieLinkedExplicit,
        'mentalState': t.etatLinkedExplicit,
      },
      if (strategie.isNotEmpty)
        'strategie': strategie.length > 48 ? '${strategie.substring(0, 48)}…' : strategie,
      if (t.psychTags.isNotEmpty) 'psychTags': t.psychTags.take(8).toList(),
      'nonRespectItems':
          t.checklistNonRespectIds.length +
          t.planNonRespectIds.length +
          t.strategieNonRespectIds.length +
          t.etatNonRespectIds.length,
      if (note != null && note.isNotEmpty)
        'userNote': note.length > 140 ? '${note.substring(0, 140)}…' : note,
      if (t.avantNews) 'avantNews': true,
      if (t.apresNews) 'apresNews': true,
    };
  }
}
