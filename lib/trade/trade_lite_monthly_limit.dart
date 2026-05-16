import 'trade_models.dart';

/// Plafond d’enregistrements de trades pour les comptes **non Pro** (Lite + essai sans Pro).
///
/// Les comptes [isPro] côté UI ne passent pas par ces garde-fous (illimité).
abstract final class TradeLiteMonthlyLimit {
  TradeLiteMonthlyLimit._();

  static const int maxTradesPerCalendarMonthNonPro = 30;

  static bool _sameLocalMonth(DateTime a, DateTime b) {
    final al = a.toLocal();
    final bl = b.toLocal();
    return al.year == bl.year && al.month == bl.month;
  }

  /// Nombre de trades dont [TradeListItem.entreeAt] tombe dans le **mois civil local**
  /// de [monthReference] (généralement [DateTime.now]).
  static int countTradesInLocalMonth(
    List<TradeListItem> items,
    DateTime monthReference,
  ) {
    final ref = monthReference.toLocal();
    var n = 0;
    for (final t in items) {
      if (_sameLocalMonth(t.entreeAt, ref)) n++;
    }
    return n;
  }

  static int countInCurrentLocalMonth(List<TradeListItem> items) =>
      countTradesInLocalMonth(items, DateTime.now());

  /// [delta] : nombre de **nouveaux** trades à ajouter (souvent 1).
  static bool canAddNonPro(List<TradeListItem> items, {int delta = 1}) {
    if (delta < 1) return true;
    return countInCurrentLocalMonth(items) + delta <=
        maxTradesPerCalendarMonthNonPro;
  }
}
