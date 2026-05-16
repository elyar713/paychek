import 'dart:ui' show Locale;

/// Libellés FR / EN / ES / DE / PT / KO (pages Performance, métriques, avertissements).
String performancePickLang(
  String langLower,
  String fr,
  String en,
  String es,
  String de, [
  String? pt,
  String? ko,
]) {
  final c = langLower.toLowerCase();
  if (c.startsWith('fr')) return fr;
  if (c.startsWith('es')) return es;
  if (c.startsWith('de')) return de;
  if (c.startsWith('pt')) return pt ?? en;
  if (c.startsWith('ko')) return ko ?? en;
  return en;
}

/// Variante à partir de [Locale] (code langue ISO).
String performancePickLocale(
  Locale locale,
  String fr,
  String en,
  String es,
  String de, [
  String? pt,
  String? ko,
]) =>
    performancePickLang(locale.languageCode, fr, en, es, de, pt, ko);

/// Raccourci explicite 6 langues (évite d’oublier pt/ko sur la page Performance).
String perf6(
  String langCode,
  String fr,
  String en,
  String es,
  String de,
  String pt,
  String ko,
) =>
    performancePickLang(langCode, fr, en, es, de, pt, ko);

/// « trade / trades » (ou équivalent) pour sous-titres et listes Performance.
String performanceTradeWordPlural(String langCode, int n) {
  final c = langCode.toLowerCase();
  if (c.startsWith('fr')) return n > 1 ? 'trades' : 'trade';
  if (c.startsWith('es')) return 'operación${n > 1 ? 'es' : ''}';
  if (c.startsWith('de')) return n > 1 ? 'Trades' : 'Trade';
  if (c.startsWith('pt')) return n > 1 ? 'trades' : 'trade';
  if (c.startsWith('ko')) return '트레이드';
  return n > 1 ? 'trades' : 'trade';
}

/// « jour(s) » / « day(s) » pour cartes volume journalier Performance.
String performanceDayWordPlural(String langCode, int n) {
  final c = langCode.toLowerCase();
  if (c.startsWith('fr')) return 'jour${n > 1 ? 's' : ''}';
  if (c.startsWith('es')) return 'día${n > 1 ? 's' : ''}';
  if (c.startsWith('de')) return 'Tag${n > 1 ? 'e' : ''}';
  if (c.startsWith('pt')) return n > 1 ? 'dias' : 'dia';
  if (c.startsWith('ko')) return '일';
  return 'day${n > 1 ? 's' : ''}';
}
