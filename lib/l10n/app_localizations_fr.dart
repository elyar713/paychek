// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get addPortfolio => 'Ajouter un portefeuille';

  @override
  String get ajouterTradeCapitalRequiredHint =>
      'Définis un capital (questionnaire) pour activer le calcul.';

  @override
  String get ajouterTradeCapitalGainEnterExitToShowPnl =>
      'Renseigne le prix de sortie pour afficher le gain.';

  @override
  String get ajouterTradeCapitalGainOpenPositionNote =>
      'Position ouverte : le gain estimé sera affiché à la clôture.';

  @override
  String get ajouterTradeCommissionFeesLabel => 'Frais (commission)';

  @override
  String get ajouterTradeFillSuggestedLot => 'Remplir le lot';

  @override
  String get ajouterTradeSizingEstimationFootnote =>
      '* Estimation selon le capital enregistré ; valeurs contrat / CFD approximatives.';

  @override
  String get ajouterTradeScreenshotHelp =>
      'Ajoute une capture du graphique ou du setup (optionnel).';

  @override
  String get ajouterTradeCsvChooseSoftware => 'Choisir un logiciel';

  @override
  String get ajouterTradePageTitle => 'Ajouter un trade';

  @override
  String get ajouterTradeErrorQtyPositive =>
      'Indique une quantité (lot) supérieure à 0.';

  @override
  String get ajouterTradeErrorEntryPrice =>
      'Indique un prix d’entrée valide (supérieur à 0).';

  @override
  String get ajouterTradeErrorExitOrFlags =>
      'Indique un prix de sortie valide, ou coche « Breakeven » / « Position » si la sortie n’est pas encore connue.';

  @override
  String get ajouterTradePsychTagBlind => 'À l’aveugle';

  @override
  String get ajouterTradeCapitalGainHeading => 'CAPITAL & GAIN';

  @override
  String get ajouterTradeMindsetPrompt => 'T’as fait ce trade avec :';

  @override
  String get ajouterTradeDisciplineSettingsTooltip =>
      'Réglages : Feeling et sections actives.';

  @override
  String get ajouterTradeSaveAndNext => 'Enregistrer & Suivant';

  @override
  String ajouterTradeLiteMonthlyLimitReached(int max) {
    return 'Lite : tu peux enregistrer au plus $max trades par mois civil. Passe en Pro pour un nombre illimité.';
  }

  @override
  String ajouterTradeLiteMonthlyLimitImportSkipped(int skipped, int max) {
    return '$skipped trade(s) non importé(s) : le plan Lite autorise au plus $max trades par mois civil.';
  }

  @override
  String get ajouterTradeSectionEtatMoment => 'ÉTAT DU MOMENT';

  @override
  String get ajouterTradeImagePickerClose => 'Fermer';

  @override
  String get ajouterTradeImagePickerTitle => 'Source de l’image';

  @override
  String get ajouterTradeGallery => 'Galerie';

  @override
  String get ajouterTradeCamera => 'Appareil photo';

  @override
  String get ajouterTradeFeedbackAlmost100 =>
      'Tu es proche du 100 % : continue à appliquer chaque point.';

  @override
  String get ajouterTradeFeedbackTickEach =>
      'Coche chaque point concerné (plusieurs choix possibles).';

  @override
  String get ajouterTradeChoicesSaved => 'Choix enregistrés :';

  @override
  String ajouterTradeNonRespectedSemantic(Object label) {
    return 'Non respecté : $label';
  }

  @override
  String ajouterTradeDisciplineRespectBase(int pct) {
    return 'Respect $pct %';
  }

  @override
  String ajouterTradeDisciplineRespectNonList(Object items, Object more) {
    return ' · Non respectés : $items$more';
  }

  @override
  String get ajouterTradeFieldActif => 'Actif';

  @override
  String get ajouterTradeFieldEntree => 'Entrée';

  @override
  String get ajouterTradeFieldSortie => 'Sortie';

  @override
  String get ajouterTradeCheckboxBreakeven => 'Breakeven';

  @override
  String get ajouterTradeCheckboxPositionOpen => 'Position';

  @override
  String get ajouterTradeCheckboxAvantNews => 'Avant news';

  @override
  String get ajouterTradeCheckboxApresNews => 'Après news';

  @override
  String get ajouterTradeDirectionBuyLong => 'Achat · Long';

  @override
  String get ajouterTradeDirectionSellShort => 'Vente · Short';

  @override
  String get ajouterTradeEntryExitDateHint =>
      'Conseil : indique la date et l’heure en Entrée et en Sortie. Pour la page Performance, cela servira à relier la durée de position à ton gain ou à ta perte.';

  @override
  String get ajouterTradeQtyLots => 'Quantité (lots)';

  @override
  String get ajouterTradeQtyContracts => 'Quantité (contrats)';

  @override
  String get ajouterTradeQtyUnits => 'Quantité (unités)';

  @override
  String get ajouterTradeQtyShares => 'Quantité (actions)';

  @override
  String get ajouterTradeShortcutsLots => 'Raccourcis lots';

  @override
  String get ajouterTradeShortcutsContracts => 'Raccourcis contrats';

  @override
  String get ajouterTradeShortcutsQty => 'Raccourcis quantité';

  @override
  String get ajouterTradeShortcutsCommonSizes =>
      'Raccourcis (tailles courantes)';

  @override
  String get ajouterTradeLotHintMini => 'Ex. 0,1 = mini-lot courant.';

  @override
  String get ajouterTradeLotFieldHintForex => 'ex. 0,1';

  @override
  String get ajouterTradeLotFieldHintContracts => 'ex. 2';

  @override
  String get ajouterTradeLotFieldHintUnits => 'ex. 1';

  @override
  String get ajouterTradeLotFieldHintShares => 'ex. 10';

  @override
  String get ajouterTradeDisciplineSettingsTitle => 'Réglages discipline';

  @override
  String get ajouterTradeDisciplineSettingsSubtitle =>
      'Choisis quelles sections sont actives pour ce trade.';

  @override
  String get ajouterTradeDisciplineFeelingModeTitle => 'Mode Feeling';

  @override
  String get ajouterTradeDisciplineFeelingAllowSubtitle =>
      'Autoriser le remplissage des sections ci-dessous.';

  @override
  String get ajouterTradeDisciplineSectionsHeading => 'SECTIONS';

  @override
  String get ajouterTradeDisciplineStrategieTitle => 'Stratégie';

  @override
  String get ajouterTradeDisciplineStrategieSubtitle => 'Setup, rétroaction';

  @override
  String get ajouterTradeDisciplinePlanTitle => 'Plan d’analyse';

  @override
  String get ajouterTradeDisciplinePlanSubtitle => 'Rapport, rétroaction';

  @override
  String get ajouterTradeDisciplineChecklistTitle => 'Checklist';

  @override
  String get ajouterTradeDisciplineChecklistSubtitle => 'Points à respecter';

  @override
  String get ajouterTradeDisciplineEtatTitle => 'État du moment';

  @override
  String get ajouterTradeDisciplineEtatSubtitle => 'Moments et émotions';

  @override
  String get ajouterTradeDisciplineSliderStrategieRespected =>
      'Stratégie respectée';

  @override
  String get ajouterTradePositionSettingsTitle => 'Réglages position';

  @override
  String get ajouterTradeStrategieFeedbackBravo =>
      'Bravo ! Tu as tout respecté ta stratégie.';

  @override
  String get ajouterTradeStrategieFeedbackWhichMissed =>
      'Tu n’as pas respecté quel(s) élément(s) de ta stratégie ?';

  @override
  String get ajouterTradeStrategieGoldRules => 'MES RÈGLES D’OR';

  @override
  String ajouterTradeStrategieRuleN(int n) {
    return 'Règle $n';
  }

  @override
  String ajouterTradeStrategieSetupTimeframesRow(Object value) {
    return 'Timeframes : $value';
  }

  @override
  String ajouterTradeStrategieSetupIndicatorsRow(Object value) {
    return 'Indicateurs : $value';
  }

  @override
  String ajouterTradeStrategieSetupPatternRow(Object value) {
    return 'Pattern : $value';
  }

  @override
  String ajouterTradeStrategieSetupSignalRow(Object value) {
    return 'Signal : $value';
  }

  @override
  String get ajouterTradeStrategieRiskManagement => 'GESTION DU RISQUE';

  @override
  String get ajouterTradeStrategieHoursSessions => 'HORAIRES & SESSIONS';

  @override
  String get ajouterTradeStrategieSetupModels => 'SETUP & MODÈLES';

  @override
  String ajouterTradeStrategieSetupModelsWithTitle(Object title) {
    return 'SETUP & MODÈLES — $title';
  }

  @override
  String get ajouterTradeStrategiePickStrategyHint =>
      'Choisis une stratégie dans la liste au-dessus pour afficher les détails du setup (entrée, stop, cible, gestion du trade, etc.).';

  @override
  String get ajouterTradeStrategieRowPattern => 'Pattern';

  @override
  String get ajouterTradeStrategieRowSignal => 'Signal';

  @override
  String get ajouterTradeStrategieClosedLabel100 =>
      'Bravo, stratégie respectée';

  @override
  String get ajouterTradeStrategieClosedLabel95 => 'Presque tout respecté';

  @override
  String get ajouterTradeStrategieClosedLabelLow => 'Points à revoir';

  @override
  String get ajouterTradePlanPickReportAbove =>
      'Choisis un rapport dans le champ au-dessus.';

  @override
  String get ajouterTradePlanFeedbackAlmost100 =>
      'Tu es proche du 100 % : continue à appliquer chaque point de ton plan d’analyse.';

  @override
  String get ajouterTradePlanFeedbackBravo =>
      'Bravo ! Tu as tout respecté ton plan d’analyse.';

  @override
  String get ajouterTradePlanFeedbackWhichMissed =>
      'Tu n’as pas respecté quel(s) élément(s) de ton plan d’analyse ?';

  @override
  String get ajouterTradePlanClosedLabel100 => 'Bravo, plan respecté';

  @override
  String get ajouterTradePlanClosedLabelLow => 'Rétroaction';

  @override
  String get ajouterTradeChecklistFeedbackAlmost100 =>
      'Tu es proche du 100 % : continue à appliquer chaque point de ta checklist.';

  @override
  String get ajouterTradeChecklistFeedbackBravo =>
      'Bravo ! Tu as tout respecté ta checklist.';

  @override
  String get ajouterTradeChecklistFeedbackWhichMissed =>
      'Tu n’as pas respecté quel(s) élément(s) de ta checklist ?';

  @override
  String get ajouterTradeChecklistClosedLabel100 =>
      'Bravo, checklist respectée';

  @override
  String get ajouterTradeChecklistClosedLabelLow => 'Checklist';

  @override
  String get ajouterTradeEtatFeelingPrompt => 'T’as eu quoi comme sentiment ?';

  @override
  String get ajouterTradeEtatFeedbackAlmost100 =>
      'Tu es proche du 100 % : continue à appliquer chaque point.';

  @override
  String get ajouterTradeEtatClosedLabel100 => 'Oui, c’est difficile. Bravo !';

  @override
  String get ajouterTradeEtatClosedLabelLow => 'État du moment';

  @override
  String get ajouterTradeEtatHeaderMoment => 'ÉTAT DU MOMENT';

  @override
  String get ajouterTradeEtatHeaderEmotions => 'ÉMOTIONS';

  @override
  String get ajouterTradeScreenshotLoadError => 'Impossible d’afficher l’image';

  @override
  String get ajouterTradeScreenshotChangeImage => 'Changer l’image';

  @override
  String get ajouterTradeScreenshotTapToAdd => 'Appuie pour ajouter une image';

  @override
  String get ajouterTradeScreenshotRemove => 'Retirer';

  @override
  String get ajouterTradePlanRowBias => 'Biais';

  @override
  String get ajouterTradePlanRowTimeframeHtf => 'Timeframe HTF';

  @override
  String get ajouterTradePlanRowPhase => 'Phase';

  @override
  String get ajouterTradePlanRowNotes => 'Notes';

  @override
  String get ajouterTradePlanRowLastPoint => 'Dernier point';

  @override
  String ajouterTradePlanRowExtraSupport(int n) {
    return 'Support suppl. $n';
  }

  @override
  String ajouterTradePlanRowExtraResistance(int n) {
    return 'Résistance suppl. $n';
  }

  @override
  String get ajouterTradePlanRowOutils => 'Outils';

  @override
  String get ajouterTradePlanRowLiquidity => 'Liquidité';

  @override
  String get ajouterTradePlanRowFibPrice => 'Prix Fib';

  @override
  String get ajouterTradePlanSectionVolume => 'VOLUME';

  @override
  String get analyseAddField => '+ Ajouter un champ';

  @override
  String get analyseAddPhaseTitle => 'Ajouter une phase';

  @override
  String get analyseAddResist => '+ Ajouter Résistance';

  @override
  String get analyseAddShort => '+ Ajouter';

  @override
  String get analyseAddSupport => '+ Ajouter Support';

  @override
  String get analyseAddTimeframeTitle => 'Ajouter un timeframe';

  @override
  String get analyseAddTimeframeCustomEntry => 'Autre (saisie libre)';

  @override
  String get analyseAddTimeframeSectionRestore => 'Réactiver';

  @override
  String get analyseAddTimeframeSectionIntraday => 'Intraday';

  @override
  String get analyseAddTimeframeSectionSwing => 'Swing & position';

  @override
  String get analyseAddTrendTitle => 'Ajouter une tendance';

  @override
  String get analyseReportScreenshotSectionTitle => 'CAPTURE';

  @override
  String get analyseReportScreenshotAddCapture => 'Ajouter une capture';

  @override
  String get analyseReportScreenshotChooseImage => 'Choisir une image';

  @override
  String get analyseReportScreenshotSubtitleWeb => 'Fichier image';

  @override
  String get analyseReportScreenshotSubtitleFilePicker =>
      'Galerie ou explorateur de fichiers';

  @override
  String get analyseReportScreenshotCamera => 'Appareil photo';

  @override
  String get analyseReportScreenshotHintWithCamera =>
      'Fichier, galerie ou appareil photo';

  @override
  String get analyseReportScreenshotHintNoCamera =>
      'Choisir une image sur cet appareil';

  @override
  String get analyseReportScreenshotErrorPlugin =>
      'Sélection d’image indisponible sur cette cible. Utilisez « Choisir une image » ou reconstruisez l’app (flutter clean / run).';

  @override
  String get analyseReportScreenshotErrorGeneric =>
      'Impossible d’ajouter la capture.';

  @override
  String get analyseCardIndicators => 'Indicateurs';

  @override
  String get analyseCardSmcLiquidity => 'SMC & Liquidité';

  @override
  String get analyseCardVolumeProfile => 'Profil de Volume';

  @override
  String get analysePageHeroTitle => 'Mon analyse';

  @override
  String get analysePageHeroSubtitle =>
      'Gérez vos analyses et stratégies en temps réel.';

  @override
  String get analyseSidebarConfidenceSummary => 'SYNTHÈSE';

  @override
  String get analyseSidebarConfidenceLabel => 'confiance globale';

  @override
  String get analyseSidebarReportHint =>
      'Le rapport sera enregistré dans votre historique avec l’actif associé.';

  @override
  String get analyseSidebarPreviewStyle => 'APERÇU DU STYLE';

  @override
  String get analyseConfidenceHigh => 'Élevé';

  @override
  String get analyseConfidenceLevelTitle => 'NIVEAU DE CONFIANCE';

  @override
  String get analyseConfidenceLow => 'Faible';

  @override
  String analyseCopyLabel(String label) {
    return 'Copie $label';
  }

  @override
  String analyseCopyNumber(int n) {
    return 'Copie $n';
  }

  @override
  String get analyseCurrentMarketPhase => 'PHASE ACTUELLE DU MARCHÉ';

  @override
  String get analyseCurrentTrend => 'TENDANCE ACTUELLE';

  @override
  String get analyseDeleteTemplateTitle => 'Supprimer ce modèle ?';

  @override
  String get analyseDirectionLabel => 'DIRECTION';

  @override
  String get analyseDraftLabelHint => 'Libellé…';

  @override
  String get analyseExtraBroken => 'Cassé';

  @override
  String get analyseExtraHeld => 'Tenu';

  @override
  String get analyseExtraPriceHint => 'Prix';

  @override
  String get analyseFeuillePlanTitle => 'FEUILLE DE PLAN';

  @override
  String get analyseFibLevel => 'NIVEAU FIBONACCI';

  @override
  String get analyseFibShort => 'FIBONACCI';

  @override
  String get analyseFreeFields => 'CHAMPS LIBRES';

  @override
  String get analyseFvg => 'FAIR VALUE GAP (FVG)';

  @override
  String get analyseHintActifExamples => 'ex : NASDAQ, EUR/USD…';

  @override
  String get analyseHintDetailsDots => 'Détails…';

  @override
  String get analyseHintHtfChipExample => 'ex. Weekly';

  @override
  String get analyseHintImbalance => 'Imbalance…';

  @override
  String get analyseHintNotesDots => 'Notes…';

  @override
  String get analyseHintPriceDots => 'Prix…';

  @override
  String get analyseHintStops => 'Où sont les stops ? (ex: Buy Side)';

  @override
  String get analyseHintTextDots => 'Texte…';

  @override
  String get analyseHintTfExamples => 'Ex. MN, 3D…';

  @override
  String get analyseHintZoneHtf => 'Zone HTF…';

  @override
  String get analyseHtfTimeframe => 'TIMEFRAME D\'ANALYSE (HTF)';

  @override
  String get analyseImpactFeuille => 'Impact Feuille';

  @override
  String get analyseImpactIndicators => 'Impact Indicateurs';

  @override
  String analyseImpactLine(int percent) {
    return 'Impact : $percent %';
  }

  @override
  String get analyseImpactModalBlurb =>
      'Les 4 impacts se partagent 100 % au total. Déplacer ce curseur réduit ou augmente les autres de façon proportionnelle.';

  @override
  String get analyseImpactModalTitle => 'Régler l\'impact';

  @override
  String get analyseImpactShort => 'Impact';

  @override
  String get analyseImpactSmc => 'Impact SMC';

  @override
  String get analyseLastPointHint => 'Dernier point…';

  @override
  String get analyseLiquidityPools => 'LIQUIDITY POOLS';

  @override
  String get analyseMovementDetailsHint => 'Détails du mouvement…';

  @override
  String get analyseNameFieldHint => 'Nom de l\'analyse…';

  @override
  String get analyseNameFieldLabel => 'Nom de l\'analyse';

  @override
  String get analyseNoTemplatesSaved => 'Aucun modèle enregistré';

  @override
  String get analyseNote => 'NOTE';

  @override
  String get analyseNotesIndicators => 'NOTES (INDICATEURS)';

  @override
  String get analyseNotesSmcExample => 'Ex: Prise de liquidité avant FVG…';

  @override
  String get analyseNotesSmcLiq => 'NOTES (SMC & LIQUIDITÉ)';

  @override
  String get analyseNotesVolumeProfile => 'NOTES (PROFIL DE VOLUME)';

  @override
  String get analyseOrderBlock => 'ORDER BLOCK (OB)';

  @override
  String get analysePhase => 'PHASE';

  @override
  String get analyseReportCellFvg => 'FVG';

  @override
  String get analyseReportCellLiqPools => 'LIQ. POOLS';

  @override
  String get analyseReportCellOrderBlock => 'ORDER BLOCK';

  @override
  String get analyseResistLower => 'Résistance';

  @override
  String get analyseResistShort => 'RÉSIST.';

  @override
  String get analyseSetup => 'SETUP';

  @override
  String get analyseSideBuy => 'Achat';

  @override
  String get analyseSideSell => 'Vente';

  @override
  String get analyseSideWatch => 'À surveiller';

  @override
  String get analyseSmcAdds => 'AJOUTS SMC';

  @override
  String get analyseStructTagResist => 'R';

  @override
  String get analyseStructTagSupport => 'S';

  @override
  String get analyseStructure => 'STRUCTURE';

  @override
  String get analyseStructureSectionTitle => 'Structure';

  @override
  String get analyseSupport => 'SUPPORT';

  @override
  String get analyseSupportLower => 'Support';

  @override
  String analyseTemplateApplied(String name) {
    return 'Modèle « $name » appliqué';
  }

  @override
  String get analyseTemplateNameHint => 'Nouveau nom…';

  @override
  String get analyseTemplateRenameDialogTitle => 'Renommer le modèle';

  @override
  String get analyseTemplateSaveDialogTitle => 'Nom du modèle';

  @override
  String get analyseTemplateStyleHint => 'ex. Swing, Scalping…';

  @override
  String get analyseTestedTwice => 'Testé x 2';

  @override
  String get analyseTimeframeLabelShort => 'TIMEFRAME';

  @override
  String get analyseTooltipPickTemplate => 'Choisir un modèle enregistré';

  @override
  String get analyseTooltipSaveTemplatePills =>
      'Enregistrer les puces sous un nom (votre habitude)';

  @override
  String get analyseTrend => 'TENDANCE';

  @override
  String get analyseTrendLabel => 'Tendance';

  @override
  String get analyseVolumePoc => 'POC';

  @override
  String get analyseVolumeProfile => 'PROFIL DE VOLUME';

  @override
  String get analyseVolumeProfileDefaultLabel => 'Profil volume';

  @override
  String get analyseVolumeVah => 'VAH';

  @override
  String get analyseVolumeVal => 'VAL';

  @override
  String get analyseVolumeZoneFrom => 'De';

  @override
  String get analyseVolumeZoneLabel => 'Zone';

  @override
  String get analyseVolumeZoneTo => 'À';

  @override
  String get appBrandName => 'PAYCHEK';

  @override
  String get buttonCalculate => 'Calculer';

  @override
  String get calAmountLabel => 'Montant';

  @override
  String get calMonthlyObjectiveTitle => 'Objectif mensuel';

  @override
  String get calPageTitle => 'Calendrier';

  @override
  String get calObjectiveLabel => 'Objectif';

  @override
  String get calCumulativePerformanceTitle => 'Performance cumulée';

  @override
  String get calBestDay => 'Meilleur jour';

  @override
  String get calTradingDays => 'Jours tradés';

  @override
  String get calAverageShort => 'Moyenne';

  @override
  String get calPnlShort => 'P&L';

  @override
  String get calCapitalChangePct => 'Variation capital';

  @override
  String get calAveragePerDay => 'Moy./jour';

  @override
  String get calObjectiveShort => 'Objectif';

  @override
  String calChartError(String message) {
    return 'Erreur : $message';
  }

  @override
  String calDayTradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trades',
      one: '1 trade',
      zero: 'Aucun trade',
    );
    return '$_temp0';
  }

  @override
  String get monthJanuary => 'Janvier';

  @override
  String get monthFebruary => 'Février';

  @override
  String get monthMarch => 'Mars';

  @override
  String get monthApril => 'Avril';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Juin';

  @override
  String get monthJuly => 'Juillet';

  @override
  String get monthAugust => 'Août';

  @override
  String get monthSeptember => 'Septembre';

  @override
  String get monthOctober => 'Octobre';

  @override
  String get monthNovember => 'Novembre';

  @override
  String get monthDecember => 'Décembre';

  @override
  String get monthAbbrJanuary => 'janv.';

  @override
  String get monthAbbrFebruary => 'févr.';

  @override
  String get monthAbbrMarch => 'mars';

  @override
  String get monthAbbrApril => 'avr.';

  @override
  String get monthAbbrMay => 'mai';

  @override
  String get monthAbbrJune => 'juin';

  @override
  String get monthAbbrJuly => 'juil.';

  @override
  String get monthAbbrAugust => 'août';

  @override
  String get monthAbbrSeptember => 'sept.';

  @override
  String get monthAbbrOctober => 'oct.';

  @override
  String get monthAbbrNovember => 'nov.';

  @override
  String get monthAbbrDecember => 'déc.';

  @override
  String get calcBestBalance => 'Meilleur solde';

  @override
  String get calcEndBalance => 'Solde final';

  @override
  String get calcEquityCurveTitle => 'Courbe de capital (trade return)';

  @override
  String get calcLabelEntry => 'Prix d\'entrée';

  @override
  String get calcLabelRiskShort => 'Risque';

  @override
  String get calcLabelSl => 'Stop loss';

  @override
  String get calcLabelStartBalance => 'Solde initial';

  @override
  String get calcLabelTp => 'Take profit';

  @override
  String get calcLabelTradesShort => 'Trades';

  @override
  String get calcLabelWinRateShort => 'Win rate';

  @override
  String get calcLoss => 'Perte';

  @override
  String get calcMaxDrawdown => 'Drawdown max';

  @override
  String get calcProfitFactor => 'Profit factor';

  @override
  String get calcRatioSectionTitle => 'Ratio';

  @override
  String get calcResult => 'Résultat';

  @override
  String get calcResultOfCalculation => 'Résultat du calcul';

  @override
  String get calcRowGain => 'Gain :';

  @override
  String get calcRowSl => 'SL :';

  @override
  String get calcRowVsCapital => 'Vs capital';

  @override
  String get calcSettingsTitle => 'Réglages';

  @override
  String get calcTotalGainLabel => 'Gain total';

  @override
  String get calcTradeReturnTableTitle => 'Résultats trade return';

  @override
  String get calcWin => 'Gain';

  @override
  String get calcWinsLosses => 'Gains / Pertes';

  @override
  String get calcWorstBalance => 'Pire solde';

  @override
  String get calculateRatio => 'Calculer le ratio';

  @override
  String get cancel => 'Annuler';

  @override
  String get capitalAmountLabel => 'Montant du capital';

  @override
  String get capitalCurrencyTitle => 'Devise';

  @override
  String get capitalEllipsis => '…';

  @override
  String get capitalHintAmount => 'ex. 10 450';

  @override
  String get capitalInitialTitle => 'Capital initial';

  @override
  String get capitalLabel => 'Capital';

  @override
  String get capitalOther => 'autre';

  @override
  String get capitalTooltip => 'Capital et devise (compte principal)';

  @override
  String get checklistAddSection => 'Ajouter une section';

  @override
  String get checklistDefaultNewSection => 'NOUVELLE SECTION';

  @override
  String get checklistDeleteSectionBody =>
      'Cette action est définitive pour cette section.';

  @override
  String get checklistDeleteSectionTitle => 'Supprimer la section ?';

  @override
  String get checklistEditSectionHint => 'Titre';

  @override
  String get checklistIntroBody =>
      'Avant de prendre position, assurez-vous de valider tous les critères de votre plan de trading.';

  @override
  String get checklistItemAnalyse1 =>
      'La tendance de fond (HTF) est alignée avec mon idée.';

  @override
  String get checklistItemAnalyse2 =>
      'Le prix est sur une zone clé (Support/Résistance, Order Block).';

  @override
  String get checklistItemAnalyse3 =>
      'J\'ai une confirmation d\'entrée claire (Pattern, Divergence).';

  @override
  String get checklistItemHint => 'Saisir le critère';

  @override
  String get checklistItemPsy1 =>
      'Je trade dans un état d\'esprit neutre (pas de revanche).';

  @override
  String get checklistItemPsy2 =>
      'J\'accepte la perte potentielle avant d\'entrer.';

  @override
  String get checklistItemPsy3 =>
      'Je respecte mon plan même après une série de pertes.';

  @override
  String get checklistItemRisque1 =>
      'Mon Stop Loss est défini techniquement (pas au hasard).';

  @override
  String get checklistItemRisque2 =>
      'Le risque ne dépasse pas 1% de mon capital.';

  @override
  String get checklistItemRisque3 =>
      'Le Ratio Risk/Reward est d\'au moins 1:2.';

  @override
  String get checklistMenuEdit => 'Éditer';

  @override
  String get checklistPageTitle => 'Checklist';

  @override
  String get checklistProgressCl => 'CL';

  @override
  String get checklistSectionAnalyse => 'ANALYSE TECHNIQUE';

  @override
  String get checklistSectionPsy => 'PSYCHOLOGIE';

  @override
  String get checklistSectionRisque => 'GESTION DU RISQUE';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get currencyNameHint => 'ex. CHF, XOF';

  @override
  String get currencyNameLabel => 'Nom de la devise';

  @override
  String get customCurrencyTitle => 'Autre devise';

  @override
  String get dashboardAiAnalyze => 'Analyser';

  @override
  String get dashboardAiCoachBody =>
      'Appuyez sur « Analyser » pour que l\'IA étudie vos statistiques de la semaine (Winrate, Horaires, Facteurs) et génère un conseil psychologique sur-mesure.';

  @override
  String get dashboardAiCoachTitle => 'COACH IA PAYCHEK';

  @override
  String get dashboardAnalyseShortcutTitle => 'Mon Analyse';

  @override
  String get dashboardBestTradeLabel => 'Meilleur trade';

  @override
  String get dashboardCapitalBalanceHeader => 'CAPITAL / SOLDE';

  @override
  String get dashboardCapitalEvolutionTitle => 'ÉVOLUTION DU CAPITAL';

  @override
  String get dashboardChecklistHeading => 'CHECKLIST';

  @override
  String get dashboardChecklistSeeRest => 'Plus >';

  @override
  String get dashboardChecklistAllDoneBravo => 'Bon trade.';

  @override
  String get dashboardMyStateSection => 'Mon état';

  @override
  String get dashboardOpenStrategyTooltip => 'Ouvrir Ma stratégie';

  @override
  String dashboardPerfHourWinRate(int percent) {
    return '$percent% WR';
  }

  @override
  String get dashboardPerfHoursRow1 => '09h00 - 11h30 (Début)';

  @override
  String get dashboardPerfHoursRow2 => '14h30 - 16h30 (US Open)';

  @override
  String get dashboardPerfHoursRow3 => '19h00 et + (Soir)';

  @override
  String get dashboardPerfHoursTitle => 'HORAIRES DE PERFORMANCE';

  @override
  String get dashboardRingState => 'ÉTAT';

  @override
  String get dashboardRingWin => 'GAGNÉ';

  @override
  String get dashboardSuccessFactorSample => 'Sport avant session';

  @override
  String get dashboardSuccessFactorsSubtitle =>
      'Suivez l\'impact de vos habitudes sur votre Winrate.';

  @override
  String get dashboardSuccessFactorsTitle => 'FACTEURS DE RÉUSSITE';

  @override
  String get dashboardTfAll => 'TOUS';

  @override
  String get dashboardTfDay => '1J';

  @override
  String get dashboardTfMonth => '1M';

  @override
  String get dashboardTfWeek => '1S';

  @override
  String dashboardTradeCount(int count) {
    return '$count trades';
  }

  @override
  String get dashboardTradeOne => '1 trade';

  @override
  String dashboardEvolutionTradesThisPeriod(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trades cette période',
      one: '1 trade cette période',
      zero: '0 trades cette période',
    );
    return '$_temp0';
  }

  @override
  String get dashboardEvolutionSparklineHoverOrigin => 'Ouverture du cumul';

  @override
  String get dashboardEvolutionSparklineHoverNoTrade =>
      'Aucun trade à ce palier';

  @override
  String dashboardEvolutionSparklineHoverMore(int count) {
    return '+$count autres';
  }

  @override
  String get dashboardEvolutionSparklineTapHint => 'Appuyer pour ouvrir';

  @override
  String get dashboardWeekResultPrefix => 'Résultat : ';

  @override
  String get dashboardWeekThisWeek => 'CETTE SEMAINE';

  @override
  String get dashboardWeekdayShortFri => 'VEN';

  @override
  String get dashboardWeekdayShortMon => 'LUN';

  @override
  String get dashboardWeekdayShortSat => 'SAM';

  @override
  String get dashboardWeekdayShortSun => 'DIM';

  @override
  String get dashboardWeekdayShortThu => 'JEU';

  @override
  String get dashboardWeekdayShortTue => 'MAR';

  @override
  String get dashboardWeekdayShortWed => 'MER';

  @override
  String get dashboardWorstLossLabel => 'Plus grosse perte';

  @override
  String get delete => 'Supprimer';

  @override
  String deletePortfolioTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get deleteTooltip => 'Supprimer';

  @override
  String get editPortfolioTooltip => 'Modifier nom, capital, devise';

  @override
  String get errorAmount => 'Entrez un montant valide (≥ 0).';

  @override
  String get errorInvalidAmount => 'Montant ou devise invalide.';

  @override
  String get errorNameOrSymbol => 'Renseignez au moins le nom ou le symbole.';

  @override
  String get exportPdfFailed => 'Impossible d’exporter le PDF.';

  @override
  String exportPdfFailedWithError(String error) {
    return 'Impossible d’exporter le PDF : $error';
  }

  @override
  String get exportPdfUnavailable => 'Export PDF annulé ou indisponible.';

  @override
  String get homePerformance => 'Performance';

  @override
  String get webHomeHeroSubtitle =>
      'Bienvenue, voici votre performance hebdomadaire';

  @override
  String webHomeHeroWelcome(Object fullName) {
    return 'Bienvenue, $fullName';
  }

  @override
  String get webHomeLiveTerminal => 'Terminal en direct';

  @override
  String get webHomeWelcomeBack => 'Bon retour,';

  @override
  String get webHomeUpgradeUnlockSubtitle =>
      'Débloquez les données institutionnelles en temps réel';

  @override
  String get webRailMenuHeading => 'Menu';

  @override
  String get labelActif => 'Actif';

  @override
  String get labelGain => 'Gain';

  @override
  String get labelLot => 'LOT';

  @override
  String get labelMarket => 'MARCHÉ';

  @override
  String get labelPrice => 'PRIX';

  @override
  String get labelRiskPct => 'RISQUE %';

  @override
  String get labelSuggestedSize => 'TAILLE SUGGÉRÉE';

  @override
  String get langChineseTraditional => '中文 (繁體)';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'Français';

  @override
  String get langGerman => 'Allemand';

  @override
  String get langItalian => 'Italien';

  @override
  String get langKorean => '한국어';

  @override
  String get langPortuguese => 'Português';

  @override
  String get langSpanish => 'Español';

  @override
  String get languageDialogSubtitle => 'Langue de l’interface';

  @override
  String get languageDialogTitle => 'Choisir la langue';

  @override
  String get languageSection => 'Langue';

  @override
  String get onboardingLanguageContinue => 'Continuer';

  @override
  String get mentalBad => 'Mauvais';

  @override
  String get mentalConfidence => 'Confiance';

  @override
  String get mentalEmotionFieldLabel =>
      'Nom de l\'émotion (ex : Serein, Apeuré)';

  @override
  String get mentalEmotional => 'Émotionnel';

  @override
  String get mentalEnergy => 'Énergie';

  @override
  String get mentalExcited => 'Excité(e)';

  @override
  String get mentalFocus => 'Focus';

  @override
  String get mentalFrustrated => 'Frustré(e)';

  @override
  String get mentalHappy => 'Content(e)';

  @override
  String get mentalHintEmotion => 'Ex : Serein, Apeuré';

  @override
  String get mentalHintMetric => 'Ex : Patience, Stress';

  @override
  String get mentalHintRoutine => 'Ex : Sport, Lecture';

  @override
  String get mentalMarketStudy => 'Étude marché';

  @override
  String get mentalMeditation => 'Méditation (10 min)';

  @override
  String get mentalMetricFieldLabel =>
      'Nom de la métrique (ex : Patience, Stress)';

  @override
  String get mentalNegative => 'Négatif (-)';

  @override
  String get mentalNeutral => 'Neutre';

  @override
  String get mentalNewEmotion => 'Nouvelle émotion';

  @override
  String get mentalNewMetric => 'Nouvelle métrique';

  @override
  String get mentalNewRoutine => 'Nouvelle routine';

  @override
  String get mentalPeakForm => 'En pleine forme';

  @override
  String get mentalPositive => 'Positif (+)';

  @override
  String get mentalRestTitle => 'REPOS';

  @override
  String get mentalRiskAppetite => 'Peur';

  @override
  String get mentalRoutineFieldLabel =>
      'Nom de la routine (ex : Sport, Lecture)';

  @override
  String get mentalGlobalScoreCalendarTitle => 'SCORE GLOBAL PAR JOUR';

  @override
  String get mentalCalendarDayStartDialogTitle => 'Début';

  @override
  String get mentalCalendarDayWindowStartLabel => 'Début';

  @override
  String get mentalCalendarDayWindowEndLabel => 'Fin';

  @override
  String get mentalCalendarDayWindowSettingsTooltip => 'Plage 24 h';

  @override
  String get mentalCalendarDayWindowDialogTitle => 'Plage horaire du score';

  @override
  String get mentalCalendarDayEndDialogTitle => 'Fin de la plage';

  @override
  String get mentalSleepEnough => 'Suffisamment dormi';

  @override
  String mentalSleepImpact(int percent) {
    return 'Impact : $percent %';
  }

  @override
  String get mentalSport => 'Sport / jogging';

  @override
  String get mentalTired => 'Fatigué';

  @override
  String get mentalWeightGlobalImpact => 'Impact global';

  @override
  String get mentalWeightModalBlurb =>
      'Ajustez l\'importance de ce critère. Utilisez le multiplicateur ou définissez directement le pourcentage souhaité.';

  @override
  String get mentalWeightModalTitle => 'Régler l\'impact';

  @override
  String get mentalWeightNatureLabel => 'Nature de l\'impact';

  @override
  String get mentalWeightPolarityHelpNegative =>
      'Une valeur élevée de ce critère DIMINUERA votre score global.';

  @override
  String get mentalWeightPolarityHelpPositive =>
      'Une valeur élevée de ce critère AUGMENTERA votre score global.';

  @override
  String get mentalPageTitle => 'État mental';

  @override
  String get mentalPageIntro =>
      'Évaluez votre état mental. Personnalisez l\'impact (poids) de chaque critère selon votre profil.';

  @override
  String get mentalGaugeStateLabel => 'ÉTAT';

  @override
  String mentalGaugeBasedOnIndicators(int count) {
    return 'Basé sur $count indicateurs';
  }

  @override
  String get mentalGaugeStatusStable => 'Équilibre correct';

  @override
  String get mentalGaugeStatusFragile => 'À surveiller';

  @override
  String get mentalSectionRoutinesHeading => 'MES ROUTINES';

  @override
  String get mentalSectionMomentHeading => 'ÉTAT DU MOMENT';

  @override
  String get mentalSectionEmotionHeading => 'ÉMOTIONS';

  @override
  String modelSavedSnackbar(String name) {
    return 'Modèle « $name » enregistré';
  }

  @override
  String get navAdd => 'Ajouter';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMore => 'Plus';

  @override
  String get navTrade => 'Trade';

  @override
  String get ok => 'OK';

  @override
  String get perf0Sub => 'Impact du stress et de la fatigue sur le Winrate';

  @override
  String get perf0Title => 'Psychologie : Émotions & sommeil';

  @override
  String get perf1Sub => 'Analyse de la rentabilité (Lundi à Dimanche)';

  @override
  String get perf1Title => 'Jours de la semaine';

  @override
  String get perf2Sub => 'Identifier vos heures les plus rentables';

  @override
  String get perf2Title => 'Horaires de session';

  @override
  String get perf3Sub => 'Taux de réussite de cette figure graphique';

  @override
  String get perf3Title => 'Pattern : Double Top / Bottom';

  @override
  String get perf4Sub => 'Analyse des retournements majeurs';

  @override
  String get perf4Title => 'Pattern : Épaule-Tête-Épaule';

  @override
  String get perf5Sub => 'Validation des signaux de surachat/survente';

  @override
  String get perf5Title => 'Indicateur : RSI Divergence';

  @override
  String get perf6Sub => 'Efficacité des croisements de moyennes';

  @override
  String get perf6Title => 'Indicateur : MACD Croisement';

  @override
  String get perf7Sub => 'Rebonds sur les niveaux 0.618 et 0.5';

  @override
  String get perf7Title => 'Indicateur : Fibonacci Retracement';

  @override
  String get perf8Sub => 'Analyse des Order Blocks et Liquidités';

  @override
  String get perf8Title => 'Stratégie : Smart Money Concept (SMC)';

  @override
  String get perf9Sub => 'Impact du risque financier sur le Winrate';

  @override
  String get perf9Title => 'Volume & taille de lot';

  @override
  String get perfAddWidgetButton => 'Ajouter le Widget';

  @override
  String get perfChartBar => 'Diagramme à barres';

  @override
  String get perfChartHBar => 'Barres horizontales';

  @override
  String get perfChartHintBar => 'Idéal pour comparer (ex. jours)';

  @override
  String get perfChartHintHBar => 'Format liste, simple et épuré';

  @override
  String get perfChartHintLine => 'Pour observer une évolution';

  @override
  String get perfChartHintPie => 'Pour un pourcentage global';

  @override
  String get perfChartLine => 'Courbe (ligne)';

  @override
  String get perfChartPie => 'Cercle / jauge';

  @override
  String get perfCustomizeIntro => 'Personnalisez votre page Performance.';

  @override
  String get perfDataFootnoteDuration =>
      'Données : répartition par durée de position (CSV).';

  @override
  String get perfDataFootnoteVolume =>
      'Proxy volume : classes selon |profit| (CSV).';

  @override
  String get perfEmptyChart =>
      'Importez ou chargez des trades (CSV) pour afficher le graphique.';

  @override
  String get perfLineChartCaption =>
      'Courbe : profit cumulé (ordre chronologique, CSV).';

  @override
  String get perfNewWidgetTitle => 'Nouveau Widget';

  @override
  String get perfNoResults => 'Aucune option trouvée.';

  @override
  String get perfPieChartCaption =>
      'Parts = volume de trades par catégorie ; % dans le disque = part du total.';

  @override
  String get perfRemoveWidgetTooltip => 'Retirer le widget';

  @override
  String get perfSearchHint => 'Rechercher (ex: Pattern, Psycho...)';

  @override
  String get perfStep1Title => '1. Que voulez-vous analyser ?';

  @override
  String get perfStep2Title => '2. Type de graphique';

  @override
  String get plusAdd => 'Ajouter';

  @override
  String get plusCalculator => 'Calculatrice';

  @override
  String get plusCalendar => 'Calendrier';

  @override
  String get plusChecklist => 'Checklist';

  @override
  String get plusDashboard => 'Dashboard';

  @override
  String get plusMentalState => 'État mental';

  @override
  String get plusMyAnalysis => 'Mon analyse';

  @override
  String get plusMyStrategy => 'Ma stratégie';

  @override
  String get plusPerformance => 'Performance';

  @override
  String get plusSettings => 'Réglages';

  @override
  String get plusTrade => 'Trade';

  @override
  String get paychekAccessDeniedTitle => 'Accès restreint';

  @override
  String get paychekAccessDeniedWeb =>
      'L’accès Paychek depuis le navigateur web a été désactivé pour ce compte. Contacte le support si besoin.';

  @override
  String get paychekAccessDeniedMobile =>
      'L’accès depuis l’application mobile a été désactivé pour ce compte. Contacte le support si besoin.';

  @override
  String get portfolioNameMissing =>
      'Donnez un nom au portefeuille (ex. broker).';

  @override
  String get portfoliosLabel => 'Portfolios';

  @override
  String get q1Slogan => 'Choisissez votre approche';

  @override
  String get q1Title => 'Quel type de trader ?';

  @override
  String get q1o1s => 'Positions de quelques secondes à quelques minutes';

  @override
  String get q1o1t => 'Scalping';

  @override
  String get q1o2s =>
      'Toutes les positions sont fermées avant la fin de la séance';

  @override
  String get q1o2t => 'Day trading';

  @override
  String get q1o3s => 'Positions maintenues entre 1 et 3 jours';

  @override
  String get q1o3t => 'Intraday';

  @override
  String get q1o4s => 'Positions maintenues sur plusieurs jours ou semaines';

  @override
  String get q1o4t => 'Swing';

  @override
  String get q2Slogan => 'Où en es-tu dans ton parcours ?';

  @override
  String get q2Title => 'Profil d\'Expérience';

  @override
  String get q2o1s => 'Tu n\'es pas seul';

  @override
  String get q2o1s2 =>
      'Pour les traders qui débutent et cherchent encore leur méthode';

  @override
  String get q2o1t => 'Je n\'ai pas de stratégie';

  @override
  String get q2o2s => 'La lumière au bout du tunnel';

  @override
  String get q2o2s2 =>
      'Pour ceux qui ont les bases mais cherchent la régularité';

  @override
  String get q2o2t => 'J\'ai ma stratégie';

  @override
  String get q2o3s => 'Le plus dur est derrière toi';

  @override
  String get q2o3s2 =>
      'Pour les traders expérimentés qui maîtrisent leur statistique';

  @override
  String get q2o3t => 'Performant';

  @override
  String get q3Slogan => 'Choisis ton objectif prioritaire';

  @override
  String get q3Title => 'Que veux-tu améliorer ?';

  @override
  String get q3o1s =>
      'Arrêter de gagner un jour pour tout perdre le lendemain.';

  @override
  String get q3o1s2 =>
      'Pour stabiliser sa courbe de capital et éviter l\'ascenseur émotionnel.';

  @override
  String get q3o1t => 'SORTIR DES MONTAGNES RUSSES';

  @override
  String get q3o2s =>
      'Améliorer mon taux de réussite et la précision de mes entrées.';

  @override
  String get q3o2s2 =>
      'Pour ceux qui veulent gagner plus souvent en sélectionnant mieux leurs trades.';

  @override
  String get q3o2t => 'DEVENIR UN SNIPER';

  @override
  String get q3o3s =>
      'Maîtriser ma discipline et stopper les décisions sous le coup de l\'émotion.';

  @override
  String get q3o3s2 =>
      'Pour éliminer le trading impulsif et respecter son plan à 100%.';

  @override
  String get q3o3t => 'RESTER DE MARBRE';

  @override
  String get q3o4s =>
      'Comprendre les schémas graphiques qui fonctionnent réellement pour moi.';

  @override
  String get q3o4s2 =>
      'Pour identifier ses propres modèles de réussite et devenir un spécialiste.';

  @override
  String get q3o4t => 'TROUVER MA SIGNATURE';

  @override
  String get q4Slogan => 'Identifie ce qui te bloque le plus';

  @override
  String get q4Title => 'Quel est ton plus grand défi ?';

  @override
  String get q4o1s => 'Peur de rater quelque chose.';

  @override
  String get q4o1s2 => 'Vite, je vais rater l\'occasion de gagner !';

  @override
  String get q4o1t => 'FOMO';

  @override
  String get q4o2s => 'Ton cœur a remplacé ton cerveau.';

  @override
  String get q4o2s2 => 'C\'est pas possible, je DOIS récupérer mon argent !';

  @override
  String get q4o2t => 'TILT';

  @override
  String get q4o3s => 'Pas de stratégie claire ni de plan.';

  @override
  String get q4o3s2 =>
      'Je ne sais pas trop, mais je le sens bien… on tente le coup.';

  @override
  String get q4o3t => 'TRADER À L\'AVEUGLETTE';

  @override
  String get q4o4s => 'L\'agitation permanente.';

  @override
  String get q4o4s2 =>
      'Si je ne clique pas, j\'ai l\'impression de ne pas travailler.';

  @override
  String get q4o4t => 'OVERTRADING';

  @override
  String get q4o5s => 'Se croire invincible.';

  @override
  String get q4o5s2 =>
      'Je suis trop fort, c\'est de l\'argent facile ! Je mise le double.';

  @override
  String get q4o5t => 'EXCÈS DE CONFIANCE';

  @override
  String get q4o6s => 'Peur de tout.';

  @override
  String get q4o6s2 => 'Je ne suis pas sûr, j\'ai peur de perdre encore.';

  @override
  String get q4o6t => 'LA PARALYSIE';

  @override
  String get q4o7s => 'Jouer à la roulette russe.';

  @override
  String get q4o7s2 => 'Je mets tout sur ce trade, ça passe ou ça casse !';

  @override
  String get q4o7t => 'SANS MONEY MANAGEMENT';

  @override
  String get reglagePortfolioSheetSubtitle =>
      'Montant du capital et devise du compte';

  @override
  String get reglagePortfolioSheetTitle => 'Capital et Portfolios';

  @override
  String get resultDontWorry => 'T\'inquiète';

  @override
  String get resultHeaderSub =>
      'Ce n\'est pas ton profil , c\'est juste un calcul , rien n\'est encore réel. Tout commence maintenant.';

  @override
  String get resultLabelGlobal => 'Global';

  @override
  String get resultLabelProfil => 'Profil';

  @override
  String get resultLabelPsychology => 'Psychologie';

  @override
  String get resultLabelStrategy => 'Stratégie';

  @override
  String resultStatBullet1(int percent) {
    return '$percent% des traders de ce niveau stagnent ou perdent par manque de rigueur mathématique.';
  }

  @override
  String resultStatBullet2(int percent) {
    return '$percent% des traders sont dans la même situation.';
  }

  @override
  String get resultStatBullet3 =>
      'Un trader avec une bonne psychologie trade mieux qu\'un trader qui connaît 100 stratégies.';

  @override
  String get save => 'Enregistrer';

  @override
  String get screenshot => 'SCREENSHOT';

  @override
  String get accountPageTitle => 'Compte';

  @override
  String get mobileReconnectAfterLogoutTitle => 'Tu es déconnecté';

  @override
  String get mobileReconnectAfterLogoutBody =>
      'Reconnecte-toi pour retrouver ton profil cloud et ton abonnement. Tu peux aussi continuer sur cet appareil sans compte.';

  @override
  String get mobileReconnectContinueWithoutAccount => 'Continuer sans compte';

  @override
  String get profileViewDetailsSection => 'Détails du profil';

  @override
  String get profileAccountStatusTitle => 'Statut du compte';

  @override
  String get profileAccountStatusPro => 'Pro';

  @override
  String get profileAccountStatusLite => 'Lite';

  @override
  String get profileTrialBadge => 'ESSAI';

  @override
  String profileTrialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours restants (essai)',
      one: '1 jour restant (essai)',
    );
    return '$_temp0';
  }

  @override
  String profileTrialEndsOn(String date) {
    return 'Fin de l\'essai le $date';
  }

  @override
  String profileTrialEndedOn(String date) {
    return 'Essai terminé le $date';
  }

  @override
  String profileProPeriodEndsOn(String date) {
    return 'Renouvellement le $date';
  }

  @override
  String get profileSubscribeButton =>
      'Passer au Pro (49,90 \$ / an — abonnement)';

  @override
  String get profileManageSubscriptionButton => 'Gérer l\'abonnement';

  @override
  String get profileUpgradeLabel => 'Upgrade';

  @override
  String get profileEditSavedSnack => 'Profil mis à jour';

  @override
  String get profileEditIncompleteFieldsSnack =>
      'Renseignez le prénom, le nom et l’e-mail';

  @override
  String get profileEditInvalidEmailSnack =>
      'Saisissez une adresse e-mail valide';

  @override
  String get accountAuthSectionTitle => 'Connexion';

  @override
  String get accountContinueWith => 'Continuer avec :';

  @override
  String get accountTabLogin => 'Connexion';

  @override
  String get accountTabSignup => 'Inscription';

  @override
  String get accountFieldEmail => 'Email';

  @override
  String get accountFieldPassword => 'Mot de passe';

  @override
  String get accountFieldConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get accountFieldBirthDate => 'Date de naissance';

  @override
  String get accountFieldFirstName => 'Prénom';

  @override
  String get accountFieldLastName => 'Nom de famille';

  @override
  String get accountLoginButton => 'Se connecter';

  @override
  String get accountSignupButton => 'S\'inscrire';

  @override
  String get authTerminalTagline => 'Maîtrise l\'esprit, maîtrise le trade';

  @override
  String get authTerminalCtaLogin => 'Lancer le terminal';

  @override
  String get authTerminalCtaSignup => 'Créer ton identité';

  @override
  String get authTerminalEncryptedPrefix => 'Nœud chiffré :';

  @override
  String get authTerminalEncryptedStatus => 'Actif';

  @override
  String get authTerminalHintEmail => 'nom@terminal.com';

  @override
  String get authTerminalHintPassword => '••••••••';

  @override
  String get accountLoginSnackEmailMissing => 'Connexion : saisir email';

  @override
  String get accountLoginSnackEmailReady => 'Connexion : email renseigné';

  @override
  String get accountSignupSnackEmailMissing => 'Inscription : saisir email';

  @override
  String get accountSignupSnackFirstNameMissing =>
      'Inscription : saisir le prénom';

  @override
  String get accountSignupSnackLastNameMissing => 'Inscription : saisir le nom';

  @override
  String get accountSignupSnackBirthDateMissing =>
      'Inscription : indiquer la date de naissance';

  @override
  String get accountSignupSnackReady => 'Inscription : formulaire prêt';

  @override
  String get accountSignupSnackPasswordMissing =>
      'Inscription : saisir le mot de passe';

  @override
  String get accountSignupSnackPasswordMismatch =>
      'Inscription : les mots de passe ne correspondent pas';

  @override
  String get accountSignupSnackPasswordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get accountLoginSnackPasswordMissing =>
      'Connexion : saisir le mot de passe';

  @override
  String get accountForgotPasswordLink => 'Mot de passe oublié ?';

  @override
  String get accountForgotPasswordSnackEmailMissing =>
      'Saisis ton adresse e-mail ci-dessus pour recevoir le lien.';

  @override
  String get accountForgotPasswordSnackSent =>
      'Si un compte existe pour cet e-mail, tu recevras un lien pour en définir un nouveau.';

  @override
  String get accountForgotPasswordSnackTooManyRequests =>
      'Trop de demandes. Réessaie dans quelques minutes.';

  @override
  String get accountPasswordResetDialogTitle =>
      'Réinitialisation du mot de passe';

  @override
  String get accountPasswordResetDialogSubtitle =>
      'Saisis l’e-mail de ton compte Paychek : tu recevras un lien pour en définir un nouveau.';

  @override
  String get accountPasswordResetCta => 'ENVOYER LE LIEN';

  @override
  String get accountPasswordResetBackToLogin => 'RETOUR À LA CONNEXION';

  @override
  String get accountPasswordResetSnackEmailMissing =>
      'Saisis ton adresse e-mail.';

  @override
  String get accountPasswordResetSentDialogTitle => 'Vérifie ta boîte mail';

  @override
  String get accountPasswordResetSentDialogMessage =>
      'Si un compte existe pour cette adresse, tu recevras un e-mail avec un lien pour choisir un nouveau mot de passe. Pense à regarder les courriers indésirables.';

  @override
  String get accountPasswordResetSentDialogCta => 'COMPRIS';

  @override
  String get accountAuthSignupSuccess => 'Compte créé';

  @override
  String get accountAuthLoginSuccess => 'Connexion réussie';

  @override
  String get accountAuthErrorWeakPassword => 'Mot de passe trop fragile';

  @override
  String get accountAuthErrorEmailInUse =>
      'Cette adresse e-mail est déjà utilisée';

  @override
  String get accountAuthErrorInvalidEmail => 'Adresse e-mail invalide';

  @override
  String get accountAuthErrorWrongCredentials =>
      'E-mail ou mot de passe incorrect';

  @override
  String get accountAuthErrorNetwork => 'Erreur réseau. Réessayez.';

  @override
  String get accountAuthErrorGeneric => 'Une erreur s\'est produite';

  @override
  String get accountAuthErrorRestartOrReload =>
      'Connexion à l’authentification perdue. Arrête complètement l’app puis relance (sur le Web, évite le hot reload).';

  @override
  String get accountAuthErrorDifferentSignInMethod =>
      'Cette adresse e-mail est déjà utilisée avec une autre méthode de connexion.';

  @override
  String accountAuthErrorWithFirebaseCode(String code) {
    return 'Un problème est survenu ($code).';
  }

  @override
  String get accountAuthErrorUnknownFirebaseAuth =>
      'Connexion impossible (erreur inconnue). Vérifie ta connexion, réessaie ou ouvre Paychek dans Chrome. Dans la console Firebase → Authentication, active E-mail / mot de passe et les fournisseurs que tu utilises.';

  @override
  String accountAuthErrorSignInServerMessage(String message) {
    return '$message';
  }

  @override
  String get accountAuthWindowsSignInNotice =>
      'Sur l’application Windows, la connexion Firebase est souvent peu fiable (limitation connue Flutter / Firebase). Utilise l’app mobile Paychek ou connecte-toi depuis ton navigateur.';

  @override
  String get accountAuthWindowsOpenWebsite =>
      'Ouvrir paychek.pro dans le navigateur';

  @override
  String get accountSocialAppleAndroidUseGoogle =>
      'Connexion Apple non configurée sur Android dans cette version. Utilise Google ou l’e-mail, ou connecte-toi depuis le site web.';

  @override
  String get accountSocialAppleUnavailableDesktop =>
      'La connexion Apple n’est pas disponible dans l’app bureau Windows/Linux. Utilise l’app Web (Chrome), un iPhone, un iPad ou un Mac.';

  @override
  String get accountSocialGoogleUnavailableDesktop =>
      'Connexion Google indisponible sur cette cible (Windows/Linux). Utilise Chrome, Android ou iOS.';

  @override
  String get accountSocialFacebookUnavailableDesktop =>
      'Connexion Facebook indisponible dans l’app bureau Windows/Linux. Utilise l’app Web (Chrome), Android, iOS ou macOS.';

  @override
  String get accountSocialGoogleWebClientMissing =>
      'Pour Google sur téléphone ou tablette : renseigne l’ID client OAuth Web dans lib/reglage/social_auth_config.dart. Sur Android, ajoute l’empreinte SHA-1 de l’app dans Firebase (Paramètres du projet → ton appli Android).';

  @override
  String get paywallTitle => 'Ta période d’essai est terminée';

  @override
  String get paywallHeadlineBefore => 'Ton essai gratuit ';

  @override
  String get paywallHeadlineAccent => 'est terminé';

  @override
  String get paywallUpgradeSubtitle =>
      'Passe à Pro pour débloquer tout ton potentiel de trading et garder ton avantage.';

  @override
  String paywallEndedOn(String date) {
    return 'Essai terminé le $date.';
  }

  @override
  String get paywallCompareCurrentPlan => 'PLAN ACTUEL';

  @override
  String get paywallCompareRecommended => 'RECOMMANDÉ';

  @override
  String get paywallPlanLiteName => 'Lite';

  @override
  String get paywallPlanProName => 'Pro';

  @override
  String get paywallLiteFeature1 => '30 Trades / mois';

  @override
  String get paywallLiteFeature2 => 'Saisie manuelle uniquement';

  @override
  String get paywallLiteFeature3 => 'Calendrier standard';

  @override
  String get paywallProFeature1 => 'Illimité';

  @override
  String get paywallProFeature2 => 'Import CSV + saisie manuelle';

  @override
  String get paywallProFeature3 => 'Calendrier Pro';

  @override
  String get paywallProFeature4 => 'Checklist';

  @override
  String get paywallProFeature5 => 'Générateur d\'analyse';

  @override
  String get paywallProFeature6 => 'Page Stratégie';

  @override
  String get paywallProFeature7 => 'Statistiques performance';

  @override
  String get paywallProFeature8 => 'État mental';

  @override
  String get paywallProFeature9 => 'Export PDF';

  @override
  String get paywallPriceAnnualHighlight => '49,90 \$ US / an';

  @override
  String get paywallPriceApproxPerMonth => 'Soit environ 4,15 \$ US / mois';

  @override
  String paywallTrialEndedBody(String date) {
    return 'Ton essai gratuit de 7 jours (nouvelle inscription) s’est terminé le $date. Sans abonnement Pro, tu passes en version Lite.';
  }

  @override
  String get paywallLiteLimitedHint =>
      'En Lite, seuls l’ajout d’un trade et le calendrier restent disponibles. Le reste est réservé aux abonnés Pro.';

  @override
  String get paywallProPriceAnnual => 'Pro : 49,90 \$ US / an';

  @override
  String get paywallContinueFreemium => 'Continuer en Lite (accès limité)';

  @override
  String get paywallSubscribeButton => 'S’abonner maintenant';

  @override
  String get paywallRestoreButton => 'J’ai déjà un abonnement';

  @override
  String get paywallStoreNotConfigured =>
      'Lien Stripe introuvable. Console admin → Config → URL Payment Link (https://…), interrupteur activé, puis réessaie (compte connecté).';

  @override
  String get paywallRestoreNothingFound =>
      'Toujours bloqué : aucun abonnement détecté. Termine l’achat ou réessaie.';

  @override
  String get paywallLegalFooter =>
      'Paiement sécurisé par Stripe • Annulable à tout moment • Conditions d’utilisation';

  @override
  String get paywallGoldPremiumPill => 'Accès Premium';

  @override
  String get paywallGoldMarketingHeadline => 'Upgrade vers PRO';

  @override
  String get paywallGoldTagline => 'L’outil des traders rentables.';

  @override
  String get paywallGoldYourPlanLabel => 'Actuel';

  @override
  String get paywallGoldLiteColumnCaption => 'Standard';

  @override
  String get paywallGoldProColumnCaption => 'Illimité';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSupportSection => 'Aide et support';

  @override
  String get settingsSupportCardTitle => 'Support & retours';

  @override
  String get settingsSupportCardSubtitle =>
      'Nous écrire et consulter les guides.';

  @override
  String get supportFeedbackTitleLead => 'Support & ';

  @override
  String get supportFeedbackTitleAccent => 'Feedback';

  @override
  String get supportFeedbackSubtitle =>
      'Une question ou une idée ? Nous sommes à ton écoute.';

  @override
  String get supportFeedbackBack => 'Retour';

  @override
  String get supportActionEmailLabel => 'E-mail';

  @override
  String get supportActionEmailHint => 'Réponse sous 24 h';

  @override
  String get supportActionDocsLabel => 'Docs';

  @override
  String get supportActionDocsHint => 'Guides d’utilisation';

  @override
  String get supportActionTwitterLabel => 'X';

  @override
  String get supportActionTwitterHint => 'Communauté';

  @override
  String get supportFormNewMessage => 'Nouveau message';

  @override
  String get supportFormKindLabel => 'Type de demande';

  @override
  String get supportFormKindAccount => 'Compte';

  @override
  String get supportFormKindBilling => 'Facturation';

  @override
  String get supportFormKindFeature => 'Fonctionnalité';

  @override
  String get supportFormKindOther => 'Autre';

  @override
  String get supportFormEmailLabel => 'Votre e-mail';

  @override
  String get supportFormEmailHint => 'nom@exemple.com';

  @override
  String get supportFormDescriptionLabel => 'Description';

  @override
  String get supportFormDescriptionHint => 'Détails du message…';

  @override
  String get supportFormSubmit => 'Envoyer maintenant';

  @override
  String get supportFormSubmitSuccess =>
      'Merci — votre message a bien été envoyé.';

  @override
  String get supportFormSubmitSuccessPartial =>
      'Merci — votre message a bien été envoyé (pièce jointe non envoyée).';

  @override
  String get supportFormSubmitDone =>
      'Si ton application mail ne s’est pas ouverte, réessaie ou écris-nous directement.';

  @override
  String get supportFormErrorEmail => 'Indique une adresse e-mail.';

  @override
  String get supportFormErrorDescription => 'Ajoute une description.';

  @override
  String get supportFormMailSubjectPrefix => 'Paychek support';

  @override
  String get supportFormMailBodyIntro =>
      'Message envoyé depuis l’application Paychek :';

  @override
  String get supportFormAttachmentLabel => 'Pièce jointe (facultatif)';

  @override
  String get supportFormAttachmentPick => 'Photo ou PDF';

  @override
  String get supportFormAttachmentHint => 'PDF ou image — max 10 Mo';

  @override
  String get supportFormAttachmentRemove => 'Retirer le fichier';

  @override
  String get supportFormAttachmentSignInHint =>
      'Connecte-toi pour joindre un fichier, ou utilise la carte E-mail sans pièce jointe.';

  @override
  String get supportFormAttachmentTooLarge => 'Le fichier dépasse 10 Mo.';

  @override
  String get supportFormAttachmentInvalidExtension =>
      'Formats acceptés : PDF, JPG, PNG, WebP.';

  @override
  String get supportFormAttachmentReadFailed =>
      'Impossible de lire ce fichier. Réessaie.';

  @override
  String get supportFormSubmitFirestoreDone =>
      'Merci — ta demande est enregistrée. L’équipe peut la consulter avec la pièce jointe dans le back-office.';

  @override
  String get supportFormSubmitSending => 'Envoi en cours…';

  @override
  String get supportFormSubmitError =>
      'Envoi impossible. Vérifie la connexion puis réessaie.';

  @override
  String get supportFormSubmitSavedPartialAttachment =>
      'Ton message est enregistré, mais la pièce jointe n’a pas été envoyée (réseau, délai dépassé ou Storage non activé dans Firebase). Vérifie la console projet ou réessaie plus tard.';

  @override
  String get supportQuickHelpTitle => 'Aide rapide';

  @override
  String get supportFaqWhereDataQ => 'Où sont mes données ?';

  @override
  String get supportFaqWhereDataA =>
      'Tes données sont stockées sur cet appareil (préférences, journal, portfolios). Une déconnexion ou une réinitialisation dans Réglages > Données peut les effacer — pense aux exports PDF si tu veux des archives.';

  @override
  String get supportFaqFeatureQ => 'Besoin d’une nouvelle fonctionnalité ?';

  @override
  String get supportFaqFeatureA =>
      'Décrit ce que tu souhaites dans le formulaire ci-dessous (catégorie « Proposer une idée »). Nous lisons tous les messages.';

  @override
  String get supportStatusLabel => 'Statut technique';

  @override
  String get supportStatusOperational => 'Services opérationnels';

  @override
  String get helpCenterTitle => 'Centre d’aide';

  @override
  String get helpCenterSubtitle =>
      'Réponses rapides et explications pour utiliser l’app.';

  @override
  String get helpCenterSearchHint => 'Rechercher…';

  @override
  String get helpCenterVersionMobile => 'Version mobile';

  @override
  String get helpCenterVersionWeb => 'Version Web';

  @override
  String get helpCenterEmptyResults => 'Aucun résultat.';

  @override
  String get helpCenterArticleAddTradeTitle => 'Ajouter un trade';

  @override
  String get helpCenterArticleAddTradeBody =>
      'Va dans l’onglet Ajouter, remplis les champs (actif, entrée, stop, objectif…), puis enregistre. Tu peux joindre une capture si besoin.';

  @override
  String get helpCenterArticleEditTradeTitle => 'Trade page';

  @override
  String get helpCenterArticleEditTradeBody =>
      'Guide : Maîtriser votre Journal de Trading (Page Trade)\nLa page Trade est le centre d\'archivage intelligent de Paychek. Elle ne se contente pas de lister vos opérations ; elle les organise pour vous offrir une vision claire de votre progression, du trade individuel à la performance mensuelle.\n\n[img:assets/help_center/trade_page_header_filters.png]\n\n1. Tableau de Bord de Période (Header)\nEn haut de votre journal, vous disposez d\'un résumé instantané de la période sélectionnée :\n\nProfit Net : Votre résultat financier net en dollars et son impact en pourcentage sur votre capital (ex: +1070,00\$ / +53,50%).\n\nLe Win Rate Ring : L\'anneau central affiche votre pourcentage de réussite global. C\'est l\'indicateur visuel immédiat de la santé de votre trading.\n\nCompteur de Trades : Le détail précis du nombre de positions Gagnantes (G), Perdantes (P) et à l\'équilibre (Br).\n\n2. Navigation et Filtres Temporels\nPersonnalisez votre vue selon votre besoin d\'analyse grâce aux sélecteurs rapides :\n\nSélecteur 1D / 1S / 1M / ALL : Basculez instantanément entre une vue journalière, hebdomadaire, mensuelle ou l\'historique complet.\n\nFiltres de statut : Isolez vos trades Gagnants, Perdants ou Breakeven d\'un seul clic pour étudier des comportements spécifiques.\n\nActifs les plus tradés : Visualisez rapidement vos statistiques sur vos instruments préférés (ex: XAUUSD, EURUSD).\n\n[img:assets/help_center/trade_page_period_pdf_report.png]\n\n3. Structure en Accordéons et Rapports PDF\nL\'interface utilise un système de \"replier/déplier\" pour une lecture fluide et des options d\'exportation à tous les niveaux :\n\nRapports de Période (Jour/Semaine/Mois) : Chaque bloc de date (ex: \"14 Mars\") affiche un résumé de la performance du jour.\n\nEn cliquant sur l\'icône PDF à côté de la date, vous téléchargez un rapport complet de cette période spécifique. Idéal pour vos bilans de fin de semaine ou de mois.\n\nRapports de Trade Individuel : Cliquez sur un trade pour le déplier et voir ses détails (Heures, Session, Entry/Exit).\n\nChaque trade possède son propre bouton PDF. Ce document génère une fiche technique pro avec votre graphique et vos scores de discipline.\n\n[img:assets/help_center/trade_page_rings_week_view.png]\n\n4. Analyse visuelle par Ring\nChaque ligne (journée ou trade) est accompagnée d\'un Ring (anneau) :\n\nPour une journée, le ring représente le Win Rate global du jour.\n\nCela vous permet d\'identifier en une seconde vos journées \"rouges\" ou \"vertes\" sans avoir à lire chaque ligne de trade.\n\n[img:assets/help_center/trade_page_options_menu.png]\n\n5. Options de Gestion et Correction (Les 3 points)\nParce qu\'une erreur de saisie peut arriver, Paychek vous donne un contrôle total sur vos archives. À côté de l\'icône PDF de chaque fiche trade, vous trouverez un menu \"Options\" (représenté par 3 points verticaux) :\n\nModifier le Trade : Vous permet de réouvrir le formulaire de saisie pour corriger un prix, changer l\'heure, ajouter un screenshot oublié ou ajuster vos scores de discipline.\n\nSupprimer le Trade : Efface définitivement l\'enregistrement de votre journal.\n\nAttention : La suppression d\'un trade mettra à jour instantanément vos statistiques globales, votre Win Rate et votre capital dans les pages Trade et Performance.';

  @override
  String get helpCenterArticleChecklistTitle => 'Checklist';

  @override
  String get helpCenterArticleChecklistBody =>
      '📋 Checklist\n\n[img:assets/help_center/checklist_routine_discipline.png]\n\n1. Comprendre le « Ring » de progression\nLe cercle coloré en haut de votre écran est votre indicateur de préparation au combat.\n\n- Progression en temps réel : chaque case cochée fait progresser le pourcentage.\n- Le « Ring » de votre checklist n’est pas seulement présent dans votre section Routine : il est aussi synchronisé en temps réel sur votre Dashboard principal.\n- Le Standard Or : nous recommandons de ne jamais ouvrir une position si votre « Ring » n’est pas à 100 %. Un trade pris avec une checklist incomplète est souvent un trade émotionnel.\n\n2. Personnaliser votre routine\nChaque trader est unique. Paychek vous permet de construire votre propre système de vérification.\n\n- Ajouter une section : utilisez le bouton « + Add a section » en bas de la page pour créer une nouvelle catégorie (ex. « Routine matinale », « News économiques », « Post-session »).\n- Gérer les éléments (menu trois points ⋯) :\n  - Ajouter une tâche : ouvrez le menu à droite du titre de section pour insérer un nouveau point de contrôle.\n  - Supprimer / modifier : si une règle ne correspond plus à votre stratégie, supprimez-la pour garder une interface propre.\n\n3. Les sections par défaut\nPour vous aider à démarrer, nous avons intégré les trois piliers du succès :\n\n- Technical Analysis : validez vos confluences (trend, S/R, indicateurs).\n- Risk Management : vérifiez que votre stop-loss est en place et que votre risque par trade est respecté.\n- Psychology : un check rapide pour vous assurer que vous n’êtes pas dans un état de revanche ou d’euphorie.';

  @override
  String get helpCenterArticleCalendarTitle => 'Calendrier';

  @override
  String get helpCenterArticleCalendarBody =>
      '📅 Guide : Calendrier & Analyse de Performance\n\nLe Calendrier Paychek est votre outil de pilotage principal. Il transforme vos données brutes en une carte visuelle de votre succès et de votre discipline.\n\n[img:assets/help_center/calendar_overview.png]\n\n1. Vue d\'ensemble du mois\nCode Couleur : Les cases Vertes indiquent un profit net, les Rouges une perte, et les Grises les jours sans activité.\n\nRésumé Rapide : En haut du calendrier, visualisez immédiatement votre Win Rate, le nombre de trades, et votre P&L Total du mois.\n\nObjectif Mensuel (Monthly Objective) : Suivez la barre de progression pour voir à quelle distance vous êtes de votre but financier. Cliquez sur l\'icône « réglages » pour modifier votre objectif.\n\n[img:assets/help_center/calendar_monthly_objective.png]\n\n2. Le Menu Déployable (Analyse Profonde)\nCliquez sur l\'en-tête de n\'importe quel mois pour ouvrir l\'analyse détaillée.\n\n[img:assets/help_center/calendar_deep_analysis.png]\n\nRings de Discipline : Visualisez vos scores moyens de rigueur sur le mois (Plan respecté, Checklist remplie, État mental).\n\nRépartition par Sessions : Analysez vos performances par fuseau horaire : Asia, Europe, et US. Idéal pour savoir quel moment de la journée est le plus rentable pour vous.\n\nSparkline Interactive (Courbe de performance) :\n- Survolez la ligne pour identifier un trade précis (sur mobile, faites-la défiler au doigt).\n- Cliquez sur un point de la courbe pour être redirigé instantanément vers la fiche complète de ce trade.\n\n3. Statistiques de Session (Sidebar)\nÀ droite de votre calendrier, retrouvez vos statistiques de régularité :\n\nPerformance Cumulative : L\'évolution de votre capital jour après jour.\n\nBest Day : Votre plus gros gain quotidien du mois.\n\nAverage Day : Ce que vous gagnez (ou perdez) en moyenne par jour.\n\n[img:assets/help_center/calendar_trades_month_report.png]\n\n4. Exportation PDF 📄\nEn haut à droite de la page Calendar, l\'icône PDF vous permet de générer un rapport professionnel en un clic.\n\nLe contenu : Le rapport inclut le calendrier visuel, la courbe de performance, et le récapitulatif de vos moyennes de discipline.';

  @override
  String get helpCenterArticleMentalStateTitle => 'État mental';

  @override
  String get helpCenterArticleMentalStateBody =>
      'Guide : État mental — Personnalisez votre psychologie\n\nVotre succès en trading dépend à 80 % de votre psychologie. La page État mental vous permet de mesurer votre état interne et de comprendre comment vos émotions influencent vos résultats.\n\n[img:assets/help_center/mental_state_dashboard.png]\n\n1. Le score global (The Ring)\nLe Ring central affiche votre « Solid Balance ». Ce score est le résultat dynamique de tous vos indicateurs (émotions, repos, routines). Plus le score est élevé, plus vous êtes dans une zone mentale propice au trading.\n\n2. Le système d\'impact personnalisé (engrenage ⚙️)\nChaque trader réagit différemment. Paychek vous permet de définir la « loi » de votre propre esprit :\n\n[img:assets/help_center/mental_state_adjust_impact.png]\n\n- Nature de l\'impact : ouvrez l\'engrenage d\'un critère pour définir s\'il est positif (+) ou négatif (−). Exemple : si pour vous l\'excitation est un danger, réglez-la sur « Négatif ».\n\n- Impact global (%) : le curseur définit l\'importance du critère sur votre score global. Si l\'énergie est cruciale pour vous, donnez-lui un poids élevé ; si un critère est secondaire, réduisez son pourcentage.\n\n3. Gestion des sections et émotions\n\n[img:assets/help_center/mental_state_section_controls.png]\n\n- Modifier / supprimer : icône crayon pour renommer une émotion ou un indicateur ; icône poubelle pour le supprimer.\n\n- Bouton d\'activation (ON / OFF 100 %) : vous pouvez désactiver une section entière (ex. « My Routines »). Si elle est désactivée, elle n\'est plus comptabilisée dans votre score global du jour.\n\n- Ajouter (+) : créez vos propres indicateurs pour coller à votre routine personnelle.\n\n4. Calendrier des scores et réglages horaires\nLe mini-calendrier affiche votre score mental pour chaque jour passé.\n\n- Réglage de la session (⚙️) : vous pouvez définir une heure de début et une heure de fin.\n\n- Mode journée : pour suivre votre état du matin au soir (fenêtre type journée).\n\n- Mode session : pour vous concentrer uniquement sur votre état mental durant vos heures de trading (ex. 15:30 – 22:00).';

  @override
  String get helpCenterArticleExportPdfTitle => 'Exporter un PDF';

  @override
  String get helpCenterArticleExportPdfBody =>
      'Depuis Trade ou Performance, utilise Exporter en PDF. En cas d’échec, vérifie les autorisations et réessaie.';

  @override
  String get helpCenterArticleResetDataTitle => 'Effacer les données locales';

  @override
  String get helpCenterArticleResetDataBody =>
      'Dans Réglages > Données, tu peux effacer les données stockées sur cet appareil. C’est irréversible ; un redémarrage de l’app est recommandé ensuite.';

  @override
  String get helpCenterArticleMyStrategyTitle => 'Ma stratégie — Playbook';

  @override
  String get helpCenterArticleMyAnalysisTitle =>
      'Mon analyse — Plans de trading';

  @override
  String get helpCenterArticleMyAnalysisBody =>
      '🔬 Mon analyse : Préparez vos Plans de Trading\n\nLa page « Mon analyse » vous permet de construire une feuille de route complète avant d\'entrer sur le marché. En quantifiant chaque élément technique, Paychek calcule pour vous un indice de confiance global pour valider votre setup.\n\n[img:assets/help_center/analyse_trend_sheet.png]\n\n1. La Carte Trend (Tendance & Contexte)\nDéfinissez le cadre de votre opportunité :\n\nActif & Nom : Utilisez le bouton (+) pour nommer votre analyse et l\'actif concerné (ex : EUR/USD — Weekly Swing Plan).\n\nDirection & Phase : Choisissez votre biais (Achat, Vente ou À surveiller) et identifiez la phase actuelle du marché (Accumulation, Impulse, Distribution).\n\nSlider de Confiance : Ajustez votre niveau de certitude pour cette section. Grâce à l\'engrenage (⚙️), réglez l\'impact (poids %) de cette carte sur le score de confiance final du rapport.\n\n[img:assets/help_center/analyse_card_controls.png]\n\nPersonnalisation : Utilisez le crayon pour modifier les timeframes ou les phases disponibles, et le bouton dupliquer pour comparer plusieurs analyses sur différents timeframes dans la même section.\n\n2. Sections Techniques (Structure, SMC, Indicateurs, Volume)\nChaque trader a sa propre méthode. Activez ou désactivez les cartes selon vos besoins avec le bouton ON/OFF :\n\n[img:assets/help_center/analyse_technical_cards.png]\n\nStructure : Notez vos supports et résistances. Cochez si un niveau a été testé plus de 2 fois pour renforcer sa pertinence.\n\nSMC & Liquidité : Identifiez vos Order Blocks, Fair Value Gaps (FVG) et niveaux de Fibonacci.\n\nIndicateurs & Profil de Volume : Détaillez vos signaux RSI/MACD ou vos zones de Point of Control (POC).\n\nScreenshot : Importez une capture d\'écran de votre graphique pour illustrer visuellement votre plan.\n\n3. Génération du Rapport (The Report)\nUne fois votre analyse terminée, cliquez sur le bouton « Rapport ».\n\n[img:assets/help_center/analyse_summary_report.png]\n\nIndice de confiance global : Le cercle de confiance final est calculé automatiquement en fonction de vos différents sliders et de leurs impacts respectifs.\n\nCode couleur dynamique : Votre rapport s\'affiche en bas de page avec une couleur spécifique selon votre direction : vert (Achat), rouge (Vente) ou jaune (À surveiller).\n\n[img:assets/help_center/analyse_report_embedded.png]\n\n4. Gestion des Rapports\nHistorique : Vos rapports sont sauvegardés et liés à vos actifs.\n\nActions : Vous pouvez à tout moment modifier (crayon), supprimer (poubelle) ou générer un PDF professionnel de votre analyse pour l\'archiver ou le partager.\n\n[img:assets/help_center/analyse_report_pdf.png]';

  @override
  String get helpCenterArticlePerformanceTitle =>
      'Performance — Scanner de trading';

  @override
  String get settingsLogoutButton => 'Déconnexion';

  @override
  String get settingsLogoutSnack => 'Tu es déconnecté.';

  @override
  String get settingsLogoutSnackPartial =>
      'Profil effacé sur l’appareil. Si ton compte apparaît encore, vérifie le réseau ou redémarre l’application.';

  @override
  String get splashTagline => 'Maîtrise l\'esprit, maîtrise le trade';

  @override
  String get statsAvgGain => 'Gain moyen';

  @override
  String get statsPsychSub => 'Plan respecté';

  @override
  String get statsPsychology => 'Psychologie';

  @override
  String get statsRR => 'Ratio R/R';

  @override
  String get statsSectionTitle => 'STATISTIQUES';

  @override
  String get statsStrategy => 'Stratégie';

  @override
  String get statsStrategySub => 'Critères validés';

  @override
  String get strategieAlertSignal => 'SIGNAL D\'ALERTE';

  @override
  String get strategieDescription => 'DESCRIPTION';

  @override
  String get strategieDescriptionHint => 'Ex : faible volatilité';

  @override
  String get strategieEditSessionTitle => 'Modifier la session';

  @override
  String get strategieHintEntry => 'Où cliquer sur ACHAT/VENTE ?';

  @override
  String get strategieHintIndicatorTag => 'Ex : RSI';

  @override
  String get strategieHintInvalidation => 'Où le scénario est-il faux ?';

  @override
  String get strategieHintManagement => 'Comment sécuriser la position ?';

  @override
  String get strategieHintPattern => 'Ex : Double Bottom';

  @override
  String get strategieHintSignal => 'Déclencheur…';

  @override
  String get strategieHintTarget => 'Cible finale ou zones de liquidité';

  @override
  String get strategieHintTimeframeTag => 'Ex : M15';

  @override
  String get strategieIndicators => 'INDICATEURS';

  @override
  String get strategieModelName => 'NOM DU MODÈLE';

  @override
  String get strategieNewSessionTitle => 'Nouvelle session';

  @override
  String get strategiePatternFigure => 'PATTERN / FIGURE';

  @override
  String get strategieRuleEntryPrecise => 'ENTRÉE PRÉCISE';

  @override
  String get strategieRuleInvalidation => 'INVALIDATION (STOP LOSS)';

  @override
  String get strategieRuleManagement => 'GESTION (BREAKEVEN / PARTIELS)';

  @override
  String get strategieRuleTarget => 'CIBLE (TAKE PROFIT)';

  @override
  String get strategieSessionName => 'NOM DE LA SESSION';

  @override
  String get strategieSetupColor => 'COULEUR';

  @override
  String get strategieSetupEditTitle => 'Modifier setup';

  @override
  String get strategieSetupNewTitle => 'Nouveau setup';

  @override
  String get strategieTimeEndOptionalLabel => 'FIN (OPTIONNEL)';

  @override
  String get strategieTimeStartLabel => 'DÉBUT';

  @override
  String get strategieTimeframes => 'TIMEFRAMES';

  @override
  String get strategieZoneNoTrade => 'No trade';

  @override
  String get strategieZoneTrade => 'Trade';

  @override
  String get strategieZoneType => 'TYPE DE ZONE';

  @override
  String get strategiePagePlaybookIntro =>
      'Votre plan de trading (Playbook). Relisez ces règles avant chaque session pour rester discipliné et concentré.';

  @override
  String get analyseReportTitle => 'Rapport';

  @override
  String get strategieGestionCaptionMaximum => 'Maximum';

  @override
  String get strategieGestionCaptionMinimum => 'Minimum';

  @override
  String get strategieSectionSetupsAndModels => 'SETUPS & MODÈLES';

  @override
  String get strategieSectionTradeCalendar => 'CALENDRIER DES TRADES';

  @override
  String get strategieCalendarNeedSetupForUsage =>
      'Ajoutez un setup ci-dessus pour suivre vos jours d\'utilisation.';

  @override
  String strategieCalendarUsageForSetup(String name) {
    return 'Usage — $name';
  }

  @override
  String get strategieCalendarUsageTooltip =>
      'Marquer ou retirer ce jour pour ce setup (même nom que dans Ajouter trade).';

  @override
  String get strategieCalendarDotsExplain =>
      'Un point par stratégie utilisée ce jour, d’après vos trades (Ajouter trade, date d’entrée).';

  @override
  String get strategieSetupNavPrevious => 'PRÉCÉDENT';

  @override
  String get strategieSetupNavNext => 'SETUP SUIVANT >';

  @override
  String get strategieSheetSetupsTitle => 'Setups & modèles';

  @override
  String get strategieMenuDisableFactors => 'Désactivé';

  @override
  String get strategieManageTemplates => 'Gérer les modèles';

  @override
  String get strategieDuplicateSetup => 'Dupliquer un setup';

  @override
  String get strategieMesReglesDraftHint => 'Nouvelle règle...';

  @override
  String get strategieSetupRemoveFromDashboard => 'Retirer de l\'accueil';

  @override
  String get strategieSetupShowOnDashboard => 'Afficher sur l\'accueil';

  @override
  String get strategiePdfPlaybookBlurbShort =>
      'Votre plan de trading (Playbook). Relisez ces règles avant chaque session.';

  @override
  String get strategiePdfFooterNote =>
      'Règles d\'or : textes de référence (non persistés). Gestion, horaires et setups : données enregistrées.';

  @override
  String get strategiePdfTableSession => 'Session';

  @override
  String get strategiePdfTableDescription => 'Description';

  @override
  String get strategiePdfTableSchedule => 'Horaires';

  @override
  String get strategiePdfTechnicalContext => 'Contexte technique';

  @override
  String get strategiePdfAlertSignal => 'Signal d\'alerte';

  @override
  String get strategiePdfFileNamePrefix => 'ma_strategie';

  @override
  String strategiePdfExportError(String error) {
    return 'Impossible de créer le PDF : $error';
  }

  @override
  String get symbolHint => 'ex. Fr, ₣';

  @override
  String get symbolLabel => 'Symbole';

  @override
  String get tradeColEndingBalance => 'Solde final';

  @override
  String get tradeColPnl => 'PnL';

  @override
  String get tradeColResult => 'Résultat';

  @override
  String get tradeColStartingBalance => 'Solde initial';

  @override
  String get tradeColTotalGain => 'Gain total';

  @override
  String get tradeColTotalGainPct => 'Gain total %';

  @override
  String get tradeColTrade => 'Trade n°';

  @override
  String get tradeDeleteConfirmBody => 'Cette action est définitive.';

  @override
  String get tradeDeleteConfirmTitle => 'Supprimer ce trade ?';

  @override
  String get tradeReturn => 'Trade return';

  @override
  String get tradeActionsTooltip => 'Actions';

  @override
  String get tradeAverageShort => 'MOYENNE';

  @override
  String tradeDayTradeNumber(int n) {
    return 'Trade n°$n du jour';
  }

  @override
  String tradeDurationHoursMinutes(int hours, String minutes) {
    return '${hours}h $minutes';
  }

  @override
  String tradeDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get tradeEditMenu => 'Modifier';

  @override
  String get tradeExportPdfTooltip => 'Exporter PDF';

  @override
  String get tradeFilterAll => 'Tous';

  @override
  String get tradeFilterBreakeven => 'Breakeven';

  @override
  String get tradeFilterLoser => 'Perdant';

  @override
  String get tradeFilterOpenPosition => 'Position en cours';

  @override
  String get tradeFilterWinner => 'Gagnant';

  @override
  String tradeSummaryBreakdownShort(int w, int l, int b) {
    return 'G:$w  P:$l  Br:$b';
  }

  @override
  String tradeSummaryBreakdownWithOpen(int w, int l, int b, int o) {
    return 'G:$w  P:$l  Br:$b  Ouv:$o';
  }

  @override
  String get tradeGainShort => 'GAIN';

  @override
  String get tradeLabelChecklist => 'Checklist';

  @override
  String get tradeLabelDuration => 'Durée';

  @override
  String get tradeLabelEntry => 'Entrée';

  @override
  String get tradeLabelEtat => 'État';

  @override
  String get tradeLabelExit => 'Sortie';

  @override
  String get tradeLabelHours => 'Heures';

  @override
  String get tradeLabelPlan => 'Plan';

  @override
  String get tradeLabelSession => 'Session';

  @override
  String get tradeLabelStrategie => 'Stratégie';

  @override
  String get tradeLabelNews => 'News';

  @override
  String get tradeMindsetFeeling => 'Feeling';

  @override
  String get tradeMindsetPrinciple => 'Principe';

  @override
  String get tradeMonthTitle => 'Mois';

  @override
  String get tradeMostTradedHeading => 'Actifs les plus tradés';

  @override
  String get tradeNotRespected => 'Non respecté';

  @override
  String tradeOpenPositionLine(String when) {
    return 'Position en cours • Entrée $when';
  }

  @override
  String get tradePdfAnalysePostTrade => 'Analyse post-trade';

  @override
  String get tradePdfBarresSemaine => 'Barres (semaine)';

  @override
  String get tradePdfCloture => 'Clôture';

  @override
  String get tradePdfPositionOpen => 'Position en cours';

  @override
  String tradePdfDatePrefix(String when) {
    return 'Date : $when';
  }

  @override
  String tradePdfDetailsTitle(String pair) {
    return 'Détails du trade ($pair)';
  }

  @override
  String get tradePdfEtatPsychologique => 'État psychologique';

  @override
  String get tradePdfTags => 'Tags';

  @override
  String get tradeTagsSection => 'TAG';

  @override
  String get tradePdfExportDayTitle => 'Trades (jour)';

  @override
  String get tradePdfExportMonthTitle => 'Trades (mois)';

  @override
  String get tradePdfExportWeekTitle => 'Trades (semaine)';

  @override
  String get tradePdfGainNet => 'Gain net';

  @override
  String get tradePdfImpactCapital => 'Impact capital';

  @override
  String get tradePdfMoyenne => 'Moyenne';

  @override
  String get tradePdfNonRespecte => 'Non respecté';

  @override
  String get tradePdfPeriode => 'Période';

  @override
  String get tradePdfQualiteMoyennes => 'Qualité (moyennes)';

  @override
  String tradePdfScreenshotTitle(String pair) {
    return 'Capture — $pair';
  }

  @override
  String get tradePdfSessions => 'Sessions';

  @override
  String get tradePdfSparklineMois => 'Courbe (mois)';

  @override
  String get tradePdfTrades => 'Trades';

  @override
  String get tradePdfWinRate => 'Win rate';

  @override
  String tradePctOfCapital(String percent) {
    return '$percent % du capital';
  }

  @override
  String get tradeScreenshotLoadError => 'Impossible d\'afficher l\'image';

  @override
  String get tradeScreenshotUnavailableWeb => 'Capture indisponible (web)';

  @override
  String get tradeSectionChecklist => 'Checklist';

  @override
  String get tradeSectionEtat => 'État';

  @override
  String get tradeSectionPlan => 'Plan';

  @override
  String get tradeSectionStrategie => 'Stratégie';

  @override
  String tradeStrategieNonRespectUnmapped(String id) {
    return 'Détail stratégie ($id)';
  }

  @override
  String get tradeSessionAsia => 'Asie';

  @override
  String get tradeSessionEurope => 'Europe';

  @override
  String get tradeSessionLate => 'Fin de journée';

  @override
  String get tradeSessionUs => 'US';

  @override
  String get tradeSideBreakevenShort => 'BREAKEVEN';

  @override
  String get tradeSideBuyLong => 'Achat';

  @override
  String get tradeSideBuyShort => 'ACHAT';

  @override
  String get tradeSideSellLong => 'Vente';

  @override
  String get tradeSideSellShort => 'VENTE';

  @override
  String get tradeSummaryProfitNet => 'PROFIT NET';

  @override
  String get tradeSummaryTrades => 'TRADES';

  @override
  String get tradeSummaryWinRate => 'WIN RATE';

  @override
  String get tradeTotalUpper => 'TOTAL';

  @override
  String get tradeTradesListHeading => 'Trades';

  @override
  String get tradeTradesMonthHeading => 'Trades (mois)';

  @override
  String get tradeTradesWeekHeading => 'Trades (semaine)';

  @override
  String get tradeWeekTitle => 'Semaine';

  @override
  String get tradeWinDayRingSubtitle => 'WIN (jour)';

  @override
  String get tradeWinrateLabel => 'Winrate';

  @override
  String get settingsTradingWeek5 => '5 jours (lun–ven)';

  @override
  String get settingsTradingWeek7 => '7 jours (lun–dim)';

  @override
  String get settingsTradingWeekSubtitle =>
      '5 jours pour les marchés classiques (lun–ven), 7 jours pour une semaine complète (ex. crypto).';

  @override
  String get settingsTradingWeekTitle => 'Semaine affichée';

  @override
  String get settingsDashboardCardSubtitle =>
      'Personnaliser l’accueil : sections et ordre';

  @override
  String get settingsDashLayoutTitle => 'Sections de l’accueil';

  @override
  String get settingsDashLayoutReorderHint =>
      'Glissez les poignées pour réorganiser. Désactivez une section pour la masquer sur l’accueil.';

  @override
  String get settingsDashOpenHomeButton => 'Voir l’accueil';

  @override
  String get settingsDashSectionCapital => 'Capital et winrate';

  @override
  String get settingsDashSectionChecklist => 'Checklist';

  @override
  String get settingsDashSectionAnalyse => 'Analyse';

  @override
  String get settingsDashSectionEtat => 'État mental';

  @override
  String get settingsDashSectionStrategie => 'Stratégie';

  @override
  String get settingsDashSectionWeekly => 'Performance hebdomadaire';

  @override
  String get settingsDashSectionEvolution => 'Évolution du capital';

  @override
  String get tradingSection => 'Trading';

  @override
  String get settingsCgvSection => 'CGV';

  @override
  String get settingsCgvPageTitle => 'Conditions générales de vente';

  @override
  String get settingsCgvRowTitle => 'Conditions générales de vente';

  @override
  String get settingsCgvRowSubtitle => 'Consulter le texte dans l’application';

  @override
  String get settingsCgvDocHeading =>
      'CONDITIONS GÉNÉRALES DE VENTE (CGV) - PAYCHEK';

  @override
  String get settingsCgv1Title => '1. Objet';

  @override
  String get settingsCgv1Body =>
      'Les présentes CGV régissent l\'abonnement donnant accès à l\'offre « Premium » de l\'application Paychek, un outil de journal de trading et de gestion de risque. L\'accès est fourni par abonnement annuel, tacitement reconduit chaque année jusqu\'à résiliation.';

  @override
  String get settingsCgv2Title => '2. Services Fournis';

  @override
  String get settingsCgv2Body =>
      'L\'accès Premium débloque l\'intégralité des fonctionnalités de l\'application (Statistiques avancées, calcul automatique de risque, export de données). L\'accès est lié au compte utilisateur créé lors de l\'inscription.';

  @override
  String get settingsCgv3Title => '3. Tarifs et Paiement';

  @override
  String get settingsCgv3Body =>
      'Abonnement direct : le tarif est fixé à 49,90 \$ US par an (renouvellement automatique jusqu\'à résiliation).\n\nOffre Partenaire : L\'accès peut être offert gratuitement si l\'utilisateur remplit les conditions de parrainage auprès d\'un de nos partenaires (Prop Firm ou Broker).\n\nPaychek se réserve le droit de modifier ses prix à tout moment pour les nouveaux clients.';

  @override
  String get settingsCgv4Title => '4. Droit de Rétractation et Remboursement';

  @override
  String get settingsCgv4Body =>
      'Conformément à la loi sur les produits numériques :\n\nEn raison de la nature numérique du service et de l\'accès immédiat au contenu dès le paiement, l\'utilisateur accepte que le service commence immédiatement et renonce expressément à son droit de rétractation de 14 jours.\n\nAucun remboursement ne sera effectué une fois l\'accès Premium activé, sauf en cas de défaut technique majeur rendant l\'application inutilisable.';

  @override
  String get settingsCgv5Title => '5. Clause Spécifique \"Offre Partenaire\"';

  @override
  String get settingsCgv5Body =>
      'L\'accès offert via un partenaire est conditionné par la validation de l\'affiliation par ledit partenaire.\n\nSi le partenaire refuse l\'affiliation (pour non-respect des règles de dépôt ou de trade), Paychek se réserve le droit de révoquer l\'accès Premium ou de demander le paiement du tarif standard.';

  @override
  String get settingsCgv6Title => '6. Avertissement sur les Risques (Trading)';

  @override
  String get settingsCgv6Body =>
      'Paychek n\'est pas un conseiller financier. L\'application est un outil technique de gestion et d\'analyse.\n\nLe trading comporte des risques élevés de perte de capital. L\'utilisateur est seul responsable de ses décisions de trading.\n\nPaychek ne pourra être tenu responsable des pertes financières subies par l\'utilisateur sur les marchés financiers.';

  @override
  String get settingsCgv7Title => '7. Disponibilité du Service';

  @override
  String get settingsCgv7Body =>
      'Paychek s\'efforce de maintenir l\'accès 24h/24. Toutefois, nous ne sommes pas responsables des interruptions dues à la maintenance ou aux pannes de serveurs tiers (Firebase, Google Cloud).';

  @override
  String get settingsCgv8Title => '8. Protection des Données';

  @override
  String get settingsCgv8Body =>
      'Les données de trading des utilisateurs sont strictement confidentielles et ne sont jamais revendues. Elles sont stockées de manière sécurisée via nos prestataires techniques.';

  @override
  String get settingsPrivacyRowTitle => 'Politique de confidentialité';

  @override
  String get settingsPrivacyRowSubtitle =>
      'Données personnelles, cookies et vos droits';

  @override
  String get settingsPrivacyPageTitle => 'Politique de confidentialité';

  @override
  String get settingsPrivacyDocHeading =>
      'POLITIQUE DE CONFIDENTIALITÉ — PAYCHEK';

  @override
  String get settingsDataResetSection => 'Données';

  @override
  String get settingsDataResetTitle => 'Effacer toutes les données locales';

  @override
  String get settingsDataResetDescription =>
      'Si tu as utilisé Paychek pendant un moment et que tu veux repartir à zéro (comme après une réinstallation), tu peux tout effacer sur cet appareil : trades, analyses, journal, mise en page du tableau de bord, profil local, ancrage d’essai sur l’appareil, etc.\n\nTa langue et le réglage « semaine affichée » sont conservés.\n\nPour être sûr que la mémoire temporaire se vide (checklist, etc.), ferme complètement l’application puis rouvre-la.';

  @override
  String get settingsDataResetButton => 'Tout effacer sur cet appareil';

  @override
  String get settingsDataResetDialogTitle =>
      'Supprimer toutes les données locales ?';

  @override
  String get settingsDataResetDialogBody =>
      'Action irréversible. Les données Paychek stockées localement seront supprimées. Ta session Firebase peut rester connectée ; seules les copies locales sont effacées.\n\nRedémarrer l’app ensuite si quelque chose semble encore en cache.';

  @override
  String get settingsDataResetDialogCancel => 'Annuler';

  @override
  String get settingsDataResetDialogConfirm => 'Tout effacer';

  @override
  String get settingsDataResetSuccess =>
      'Données locales effacées. Redémarrage de l’app recommandé.';

  @override
  String get validate => 'Valider';

  @override
  String get winrate => 'Winrate';
}
