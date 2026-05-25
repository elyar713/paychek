/// Définition d’un article du centre d’aide (ordre d’affichage = ordre de la liste).
class HelpCenterArticleDef {
  const HelpCenterArticleDef({
    required this.slug,
    required this.frenchTitle,
    this.mobileHeroImages = const <String>[],
    this.webHeroImages = const <String>[],
  });

  /// Dossier sous `assets/help_center/guides/{slug}/fr.txt`.
  final String slug;

  /// Titre de la carte (français uniquement pendant la refonte).
  final String frenchTitle;

  /// Images en tête de carte (mode mobile), en plus du corps.
  final List<String> mobileHeroImages;

  /// Images en tête de carte (mode web).
  final List<String> webHeroImages;
}

/// Articles affichés dans le centre d’aide, dans l’ordre produit.
const List<HelpCenterArticleDef> helpCenterArticles = <HelpCenterArticleDef>[
  HelpCenterArticleDef(
    slug: 'dashboard',
    frenchTitle: 'Dashboard — Centre de contrôle',
  ),
  HelpCenterArticleDef(
    slug: 'add_trade',
    frenchTitle: 'Ajouter un trade',
  ),
  HelpCenterArticleDef(
    slug: 'trade_page',
    frenchTitle: 'Page Trade — Journal',
  ),
  HelpCenterArticleDef(
    slug: 'checklist',
    frenchTitle: 'Checklist',
  ),
  HelpCenterArticleDef(
    slug: 'calendar',
    frenchTitle: 'Calendrier',
  ),
  HelpCenterArticleDef(
    slug: 'mental_state',
    frenchTitle: 'État mental',
  ),
  HelpCenterArticleDef(
    slug: 'my_strategy',
    frenchTitle: 'Ma stratégie — Playbook',
  ),
  HelpCenterArticleDef(
    slug: 'my_analysis',
    frenchTitle: 'Mon analyse — Plans de trading',
  ),
  HelpCenterArticleDef(
    slug: 'performance',
    frenchTitle: 'Performance — Scanner de trading',
  ),
  HelpCenterArticleDef(
    slug: 'export_pdf',
    frenchTitle: 'Exporter un PDF',
  ),
  HelpCenterArticleDef(
    slug: 'reset_data',
    frenchTitle: 'Effacer les données locales',
  ),
];
