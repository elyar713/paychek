/// Textes par dÃ©faut de la checklist Â« Nouveau Trade Â» (identifiants techniques,
/// libellÃ©s de secours). Lâ€™affichage des sections / items connus passe par
/// [AppLocalizations] via `lib/l10n/checklist_localizations.dart`.
class ChecklistPrompts {
  ChecklistPrompts._();

  // --- En-tÃªte page ---
  static const pageTitle = 'Checklist';

  /// Pastille Â« x / n Â» sous le titre (compteur).
  static String headerPillCountLabel(int checked, int total) =>
      '$checked/$total';

  /// Sous le titre, avant lâ€™anneau.
  static const introBody =
      'Avant de prendre position, assurez-vous de valider tous les critères de votre plan de trading.';

  // --- Anneau global ---
  static String progressRingPercentLabel(int percent) => '$percent%';

  static const progressRingClLabel = 'CL';

  // --- Bouton bas de page ---
  static const addSectionButton = 'Ajouter une section';

  // --- Menu â‹¯ (valeurs [PopupMenuItem.value]) ---
  static const menuActionEdit = 'editer';
  static const menuActionDelete = 'supprimer';

  static const menuLabelEdit = 'Éditer';

  /// LibellÃ©s partagÃ©s (menu â‹¯ Â« Supprimer Â» + dialogue de confirmation).
  static const labelCancel = 'Annuler';
  static const labelDelete = 'Supprimer';

  // --- Champ titre section (Ã©dition inline, pas de dialog) ---
  static const dialogEditSectionHint = 'Titre';

  // --- Dialog : confirmation suppression section ---
  static const dialogDeleteSectionTitle = 'Supprimer la section ?';
  static const dialogDeleteSectionBody =
      'Cette action est définitive pour cette section.';

  // --- LibellÃ©s par dÃ©faut ---
  static const defaultNewSectionTitle = 'NOUVELLE SECTION';

  /// Hint champ ligne (pas de Â« Nouvelle ligne Â» : brouillon vide = ligne non crÃ©Ã©e).
  static const itemLineHint = 'Saisir le critère';

  // --- Sections par dÃ©faut (ids) ---
  static const sectionIdNews = 'news';
  static const sectionIdAnalyse = 'analyse';
  static const sectionIdRisque = 'risque';
  static const sectionIdPsy = 'psy';

  static const sectionTitleNews = 'NEWS · CALENDRIER ÉCONOMIQUE';
  static const sectionTitleAnalyse = 'ANALYSE TECHNIQUE';
  static const sectionTitleRisque = 'GESTION DU RISQUE';
  static const sectionTitlePsy = 'PSYCHOLOGIE';

  // --- Items : ids ---
  static const itemIdNews1 = 'n1';
  static const itemIdNews2 = 'n2';
  static const itemIdNews3 = 'n3';
  static const itemIdNews4 = 'n4';

  static const itemIdAnalyse1 = 'a1';
  static const itemIdAnalyse2 = 'a2';
  static const itemIdAnalyse3 = 'a3';
  static const itemIdRisque1 = 'r1';
  static const itemIdRisque2 = 'r2';
  static const itemIdRisque3 = 'r3';
  static const itemIdPsy1 = 'p1';
  static const itemIdPsy2 = 'p2';
  static const itemIdPsy3 = 'p3';

  // --- Items : libellÃ©s (critÃ¨res) â€” alignÃ©s sur app_en.arb ; affichage via l10n ---
  static const itemLabelNews1 =
      'Calendrier économique consulté (FED, CPI, NFP, PIB…).';
  static const itemLabelNews2 =
      'FOMC / FED : pas de trade pendant l’annonce.';
  static const itemLabelNews3 =
      'CPI (inflation) : horaire et impact anticipés.';
  static const itemLabelNews4 =
      'NFP (emplois US) : fenêtre à risque identifiée.';

  static const itemLabelAnalyse1 =
      'La tendance de fond (HTF) est alignée avec mon idée.';
  static const itemLabelAnalyse2 =
      'Le prix est sur une zone clé (Support/Résistance, Order Block).';
  static const itemLabelAnalyse3 =
      'J\'ai une confirmation d\'entrée claire (Pattern, Divergence).';

  static const itemLabelRisque1 =
      'Mon Stop Loss est défini techniquement (pas au hasard).';
  static const itemLabelRisque2 =
      'Le risque ne dépasse pas 1% de mon capital.';
  static const itemLabelRisque3 =
      'Le Ratio Risk/Reward est d\'au moins 1:2.';

  static const itemLabelPsy1 =
      'Je trade dans un état d\'esprit neutre (pas de revanche).';
  static const itemLabelPsy2 =
      'J\'accepte la perte potentielle avant d\'entrer.';
  static const itemLabelPsy3 =
      'Je respecte mon plan même après une série de pertes.';
}



