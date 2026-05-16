import 'package:flutter/foundation.dart';

import '../trade/trade_models.dart';

/// Métadonnées alignées sur [CapitalEvolutionComputed.spots] (même taille que la liste).
@immutable
class EvolutionSpotContext {
  const EvolutionSpotContext({
    required this.referenceDayLocalMidnight,
    this.tradesOnSlice = const [],
  });

  /// Jour représenté par ce sommet (minuit local).
  final DateTime referenceDayLocalMidnight;

  /// Trades associés au palier cumulatif : même jour (agrégés) ou le trade ayant fait
  /// passer le cumul d’un cran (vue 1J).
  final List<TradeListItem> tradesOnSlice;
}
