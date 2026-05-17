/// Identifiants stables des blocs configurables de l’accueil [DashboardHomeContent].
abstract final class DashboardHomeLayoutKeys {
  DashboardHomeLayoutKeys._();

  static const String capitalBalance = 'capital_balance';
  static const String checklist = 'checklist';
  static const String analyse = 'analyse';
  static const String etatMental = 'etat_mental';
  static const String strategie = 'strategie';
  static const String paychekLens = 'paychek_lens';
  static const String capitalEvolution = 'capital_evolution';

  static const List<String> defaultOrder = [
    capitalBalance,
    checklist,
    analyse,
    etatMental,
    strategie,
    paychekLens,
    capitalEvolution,
  ];
}
