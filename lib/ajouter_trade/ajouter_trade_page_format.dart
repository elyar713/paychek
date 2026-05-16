/// Format d’affichage date/heure (entrée / sortie) sur la page Ajouter trade.
///
/// Utilisé sous les champs **Entrée** / **Sortie** (ligne unique type `jj/mm/aaaa · hh:mm`).
/// Reste indépendant du [Widget] pour réutilisation et tests simples.
/// Voir aussi [AjouterTradeInstrumentCard] pour le contexte d’usage.
String formatAjouterTradeEntreeSortieDateTime(DateTime d) {
  final l = d.toLocal();
  String p2(int n) => n.toString().padLeft(2, '0');
  return '${p2(l.day)}/${p2(l.month)}/${l.year} · ${p2(l.hour)}:${p2(l.minute)}';
}
