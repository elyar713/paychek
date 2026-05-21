import 'trade_models.dart';

/// Normalise Principe / Feeling / Talent sur le journal (tous portefeuilles).
///
/// - **Feeling** : conservé (choix explicite historique ou actuel).
/// - **Principe** : conservé seulement si [TradeListItem.mindsetExplicit].
/// - Sinon (import CSV, lite, ancien Principe par défaut) → **Talent** ([TradeMindset.none]).
List<TradeListItem> applyJournalMindsetTalentMigration(
  List<TradeListItem> items,
) {
  var changed = false;
  final out = <TradeListItem>[];
  for (final t in items) {
    final n = normalizeTradeMindsetForTalent(t);
    if (n.mindset != t.mindset || n.mindsetExplicit != t.mindsetExplicit) {
      changed = true;
    }
    out.add(n);
  }
  return changed ? out : items;
}

bool journalMindsetMigrationWouldChange(List<TradeListItem> items) {
  for (final t in items) {
    final n = normalizeTradeMindsetForTalent(t);
    if (n.mindset != t.mindset || n.mindsetExplicit != t.mindsetExplicit) {
      return true;
    }
  }
  return false;
}

TradeListItem normalizeTradeMindsetForTalent(TradeListItem t) {
  final now = DateTime.now().millisecondsSinceEpoch;
  if (t.mindset == TradeMindset.feeling) {
    return t.mindsetExplicit
        ? t
        : t.copyWith(mindsetExplicit: true, syncRev: now);
  }
  if (t.mindsetExplicit &&
      (t.mindset == TradeMindset.principe ||
          t.mindset == TradeMindset.feeling)) {
    return t;
  }
  if (t.mindset == TradeMindset.none && !t.mindsetExplicit) {
    return t;
  }
  return t.copyWith(
    mindset: TradeMindset.none,
    mindsetExplicit: false,
    syncRev: now,
  );
}

/// Infère [TradeListItem.mindsetExplicit] pour les entrées JSON antérieures à la clé.
bool legacyMindsetExplicitFromMap({
  required String? mindsetRaw,
  required bool performanceLite,
}) {
  final explicit = mindsetRaw == 'feeling';
  if (performanceLite) return false;
  return explicit;
}
