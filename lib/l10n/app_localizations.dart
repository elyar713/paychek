import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ko'),
    Locale('pt'),
  ];

  /// No description provided for @actionAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get actionAdd;

  /// No description provided for @addPortfolio.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un portefeuille'**
  String get addPortfolio;

  /// No description provided for @ajouterTradeCapitalRequiredHint.
  ///
  /// In fr, this message translates to:
  /// **'Définis un capital (questionnaire) pour activer le calcul.'**
  String get ajouterTradeCapitalRequiredHint;

  /// No description provided for @ajouterTradeCapitalGainEnterExitToShowPnl.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne le prix de sortie pour afficher le gain.'**
  String get ajouterTradeCapitalGainEnterExitToShowPnl;

  /// No description provided for @ajouterTradeCapitalGainOpenPositionNote.
  ///
  /// In fr, this message translates to:
  /// **'Position ouverte : le gain estimé sera affiché à la clôture.'**
  String get ajouterTradeCapitalGainOpenPositionNote;

  /// No description provided for @ajouterTradeCommissionFeesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Frais (commission)'**
  String get ajouterTradeCommissionFeesLabel;

  /// No description provided for @ajouterTradeFillSuggestedLot.
  ///
  /// In fr, this message translates to:
  /// **'Remplir le lot'**
  String get ajouterTradeFillSuggestedLot;

  /// No description provided for @ajouterTradeSizingEstimationFootnote.
  ///
  /// In fr, this message translates to:
  /// **'* Estimation selon le capital enregistré ; valeurs contrat / CFD approximatives.'**
  String get ajouterTradeSizingEstimationFootnote;

  /// No description provided for @ajouterTradeScreenshotHelp.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute une capture du graphique ou du setup (optionnel).'**
  String get ajouterTradeScreenshotHelp;

  /// No description provided for @ajouterTradeCsvChooseSoftware.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un logiciel'**
  String get ajouterTradeCsvChooseSoftware;

  /// No description provided for @ajouterTradeAnalyseCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'ANALYSE'**
  String get ajouterTradeAnalyseCardTitle;

  /// No description provided for @ajouterTradeAnalyseCardHelp.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un rapport depuis Mon analyse — son PDF sera joint à ce trade à l’enregistrement.'**
  String get ajouterTradeAnalyseCardHelp;

  /// No description provided for @ajouterTradeAnalyseChooseReport.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une analyse'**
  String get ajouterTradeAnalyseChooseReport;

  /// No description provided for @ajouterTradeAnalysePdfGenerating.
  ///
  /// In fr, this message translates to:
  /// **'Génération du PDF…'**
  String get ajouterTradeAnalysePdfGenerating;

  /// No description provided for @ajouterTradeAnalysePdfAttached.
  ///
  /// In fr, this message translates to:
  /// **'PDF joint : {fileName}'**
  String ajouterTradeAnalysePdfAttached(String fileName);

  /// No description provided for @ajouterTradeAnalyseClear.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get ajouterTradeAnalyseClear;

  /// No description provided for @ajouterTradeAnalysePdfError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de générer le PDF d’analyse.'**
  String get ajouterTradeAnalysePdfError;

  /// No description provided for @ajouterTradeAnalysePdfNotReady.
  ///
  /// In fr, this message translates to:
  /// **'Attendez la fin de la génération du PDF, ou retirez la sélection.'**
  String get ajouterTradeAnalysePdfNotReady;

  /// No description provided for @ajouterTradeNoteCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'NOTE'**
  String get ajouterTradeNoteCardTitle;

  /// No description provided for @ajouterTradeNoteCardHelp.
  ///
  /// In fr, this message translates to:
  /// **'Vos notes personnelles sur ce trade (facultatif).'**
  String get ajouterTradeNoteCardHelp;

  /// No description provided for @ajouterTradeNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Contexte, leçons, émotions…'**
  String get ajouterTradeNoteHint;

  /// No description provided for @ajouterTradeSessionAutoTagTitle.
  ///
  /// In fr, this message translates to:
  /// **'Session du jour'**
  String get ajouterTradeSessionAutoTagTitle;

  /// No description provided for @ajouterTradeSessionAutoTagSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Classe Principe / Feeling selon l’ordre d’entrée. Import CSV inclus.'**
  String get ajouterTradeSessionAutoTagSubtitle;

  /// No description provided for @ajouterTradeSessionPlannedCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Trades encore « selon le plan » par jour : {count}'**
  String ajouterTradeSessionPlannedCountLabel(int count);

  /// No description provided for @ajouterTradeSessionAutoTagHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : 2 → trades 1–2 en Principe, à partir du 3ᵉ en Feeling (tilt / revenge).'**
  String get ajouterTradeSessionAutoTagHint;

  /// No description provided for @ajouterTradeSessionHint.
  ///
  /// In fr, this message translates to:
  /// **'Trade n°{rank} aujourd’hui → auto : {tag}'**
  String ajouterTradeSessionHint(int rank, String tag);

  /// No description provided for @tradeNoteSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get tradeNoteSectionTitle;

  /// No description provided for @ajouterTradePageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un trade'**
  String get ajouterTradePageTitle;

  /// No description provided for @ajouterTradeErrorQtyPositive.
  ///
  /// In fr, this message translates to:
  /// **'Indique une quantité (lot) supérieure à 0.'**
  String get ajouterTradeErrorQtyPositive;

  /// No description provided for @ajouterTradeErrorEntryPrice.
  ///
  /// In fr, this message translates to:
  /// **'Indique un prix d’entrée valide (supérieur à 0).'**
  String get ajouterTradeErrorEntryPrice;

  /// No description provided for @ajouterTradeErrorExitOrFlags.
  ///
  /// In fr, this message translates to:
  /// **'Indique un prix de sortie valide, ou coche « Breakeven » / « Position » si la sortie n’est pas encore connue.'**
  String get ajouterTradeErrorExitOrFlags;

  /// No description provided for @ajouterTradePsychTagBlind.
  ///
  /// In fr, this message translates to:
  /// **'À l’aveugle'**
  String get ajouterTradePsychTagBlind;

  /// No description provided for @ajouterTradeCapitalGainHeading.
  ///
  /// In fr, this message translates to:
  /// **'CAPITAL & GAIN'**
  String get ajouterTradeCapitalGainHeading;

  /// No description provided for @ajouterTradeMindsetPrompt.
  ///
  /// In fr, this message translates to:
  /// **'T’as fait ce trade avec :'**
  String get ajouterTradeMindsetPrompt;

  /// No description provided for @ajouterTradeDisciplineSettingsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Réglages : Feeling et sections actives.'**
  String get ajouterTradeDisciplineSettingsTooltip;

  /// No description provided for @ajouterTradeSaveAndNext.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer & Suivant'**
  String get ajouterTradeSaveAndNext;

  /// No description provided for @ajouterTradeLiteMonthlyLimitReached.
  ///
  /// In fr, this message translates to:
  /// **'Lite : tu peux enregistrer au plus {max} trades par mois civil. Passe en Pro pour un nombre illimité.'**
  String ajouterTradeLiteMonthlyLimitReached(int max);

  /// No description provided for @ajouterTradeLiteMonthlyLimitImportSkipped.
  ///
  /// In fr, this message translates to:
  /// **'{skipped} trade(s) non importé(s) : le plan Lite autorise au plus {max} trades par mois civil.'**
  String ajouterTradeLiteMonthlyLimitImportSkipped(int skipped, int max);

  /// No description provided for @tradeImportPickSoftwareFirst.
  ///
  /// In fr, this message translates to:
  /// **'Choisis un logiciel avant l\'import.'**
  String get tradeImportPickSoftwareFirst;

  /// No description provided for @tradeImportEmptyFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier vide ou illisible.'**
  String get tradeImportEmptyFile;

  /// No description provided for @tradeImportMt4HtmlOnly.
  ///
  /// In fr, this message translates to:
  /// **'MT4 : utilise un export HTML/HTM.'**
  String get tradeImportMt4HtmlOnly;

  /// No description provided for @tradeImportTradingViewCsvOnly.
  ///
  /// In fr, this message translates to:
  /// **'TradingView : utilise un export CSV.'**
  String get tradeImportTradingViewCsvOnly;

  /// No description provided for @tradeImportCtraderHtmlOnly.
  ///
  /// In fr, this message translates to:
  /// **'cTrader : utilise un relevé HTML/HTM (compte).'**
  String get tradeImportCtraderHtmlOnly;

  /// No description provided for @tradeImportTradovateOrdersCsv.
  ///
  /// In fr, this message translates to:
  /// **'Tradovate : exporte Orders.csv (remplissages).'**
  String get tradeImportTradovateOrdersCsv;

  /// No description provided for @tradeImportTradovatePickOrdersCsv.
  ///
  /// In fr, this message translates to:
  /// **'Tradovate : choisis un fichier Orders.csv.'**
  String get tradeImportTradovatePickOrdersCsv;

  /// No description provided for @tradeImportNinjaGridCsv.
  ///
  /// In fr, this message translates to:
  /// **'NinjaTrader : exporte une grille CSV (Ordres ou exécutions).'**
  String get tradeImportNinjaGridCsv;

  /// No description provided for @tradeImportNinjaPickCsv.
  ///
  /// In fr, this message translates to:
  /// **'NinjaTrader : choisis un fichier CSV (grille).'**
  String get tradeImportNinjaPickCsv;

  /// No description provided for @tradeImportRithmicCsv.
  ///
  /// In fr, this message translates to:
  /// **'Rithmic : utilise un export CSV (Recent Orders).'**
  String get tradeImportRithmicCsv;

  /// No description provided for @tradeImportRithmicPickCsv.
  ///
  /// In fr, this message translates to:
  /// **'Rithmic : choisis un fichier CSV.'**
  String get tradeImportRithmicPickCsv;

  /// No description provided for @tradeImportQuantowerCsv.
  ///
  /// In fr, this message translates to:
  /// **'Quantower : utilise un export CSV (Orders history).'**
  String get tradeImportQuantowerCsv;

  /// No description provided for @tradeImportQuantowerPickCsv.
  ///
  /// In fr, this message translates to:
  /// **'Quantower : choisis un fichier CSV (Orders history).'**
  String get tradeImportQuantowerPickCsv;

  /// No description provided for @tradeImportAtasXlsxReadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire le .xlsx (fichier vide ou trop gros pour le navigateur). Réessaie ou rouvre le fichier.'**
  String get tradeImportAtasXlsxReadFailed;

  /// No description provided for @tradeImportAtasPickCsvXlsx.
  ///
  /// In fr, this message translates to:
  /// **'ATAS : choisis un fichier CSV ou .xlsx (Statistiques).'**
  String get tradeImportAtasPickCsvXlsx;

  /// No description provided for @tradeImportAtasXlsxEmptyFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier vide.'**
  String get tradeImportAtasXlsxEmptyFile;

  /// No description provided for @tradeImportAtasXlsxInvalidFormat.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas un .xlsx Excel valide (en-tête manquant). Réexporte depuis ATAS.'**
  String get tradeImportAtasXlsxInvalidFormat;

  /// No description provided for @tradeImportAtasXlsxJournalMissing.
  ///
  /// In fr, this message translates to:
  /// **'Feuille « Journal » introuvable ou classeur illisible. Vérifie l\'export Statistiques .xlsx.'**
  String get tradeImportAtasXlsxJournalMissing;

  /// No description provided for @tradeImportAtasXlsxNoRows.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ligne de trade reconnue. Ouvre la feuille Journal : colonnes Instrument, Open time, Open/Close volume.'**
  String get tradeImportAtasXlsxNoRows;

  /// No description provided for @tradeImportNotImplemented.
  ///
  /// In fr, this message translates to:
  /// **'Import {source} pas encore branché.'**
  String tradeImportNotImplemented(String source);

  /// No description provided for @tradeImportEmptyMt5.
  ///
  /// In fr, this message translates to:
  /// **'MT5 {extension} : aucune ligne Position détectée.'**
  String tradeImportEmptyMt5(String extension);

  /// No description provided for @tradeImportEmptyTradingView.
  ///
  /// In fr, this message translates to:
  /// **'TradingView CSV : aucune position fermée détectée.'**
  String get tradeImportEmptyTradingView;

  /// No description provided for @tradeImportEmptyCtrader.
  ///
  /// In fr, this message translates to:
  /// **'cTrader HTML : aucune ligne Historique détectée.'**
  String get tradeImportEmptyCtrader;

  /// No description provided for @tradeImportEmptyTradovate.
  ///
  /// In fr, this message translates to:
  /// **'Tradovate CSV : aucun round-trip (entrée/sortie) détecté.'**
  String get tradeImportEmptyTradovate;

  /// No description provided for @tradeImportEmptyNinjaTrader.
  ///
  /// In fr, this message translates to:
  /// **'NinjaTrader CSV : aucun round-trip (entrée/sortie) détecté.'**
  String get tradeImportEmptyNinjaTrader;

  /// No description provided for @tradeImportEmptyAtas.
  ///
  /// In fr, this message translates to:
  /// **'ATAS : aucune ligne reconnue (feuille Journal uniquement).'**
  String get tradeImportEmptyAtas;

  /// No description provided for @tradeImportEmptyGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Aucune position reconnue pour ce logiciel/fichier.'**
  String get tradeImportEmptyGeneric;

  /// No description provided for @tradeImportNoneNew.
  ///
  /// In fr, this message translates to:
  /// **'Aucun nouveau trade importé depuis {source}{duplicates}.'**
  String tradeImportNoneNew(String source, String duplicates);

  /// No description provided for @tradeImportSummary.
  ///
  /// In fr, this message translates to:
  /// **'{count} trade(s) importé(s) depuis {source}{duplicates}.'**
  String tradeImportSummary(int count, String source, String duplicates);

  /// No description provided for @tradeImportDuplicatesSuffix.
  ///
  /// In fr, this message translates to:
  /// **' · {count} doublon(s) ignoré(s)'**
  String tradeImportDuplicatesSuffix(int count);

  /// No description provided for @tradeImportDuplicatesOnlySuffix.
  ///
  /// In fr, this message translates to:
  /// **' · {count} doublon(s)'**
  String tradeImportDuplicatesOnlySuffix(int count);

  /// No description provided for @tradeImportFailed.
  ///
  /// In fr, this message translates to:
  /// **'Import échoué : {error}'**
  String tradeImportFailed(String error);

  /// No description provided for @ajouterTradeSectionEtatMoment.
  ///
  /// In fr, this message translates to:
  /// **'ÉTAT DU MOMENT'**
  String get ajouterTradeSectionEtatMoment;

  /// No description provided for @ajouterTradeImagePickerClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get ajouterTradeImagePickerClose;

  /// No description provided for @ajouterTradeImagePickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Source de l’image'**
  String get ajouterTradeImagePickerTitle;

  /// No description provided for @ajouterTradeGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get ajouterTradeGallery;

  /// No description provided for @ajouterTradeCamera.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get ajouterTradeCamera;

  /// No description provided for @ajouterTradeFeedbackAlmost100.
  ///
  /// In fr, this message translates to:
  /// **'Tu es proche du 100 % : continue à appliquer chaque point.'**
  String get ajouterTradeFeedbackAlmost100;

  /// No description provided for @ajouterTradeFeedbackTickEach.
  ///
  /// In fr, this message translates to:
  /// **'Coche chaque point concerné (plusieurs choix possibles).'**
  String get ajouterTradeFeedbackTickEach;

  /// No description provided for @ajouterTradeChoicesSaved.
  ///
  /// In fr, this message translates to:
  /// **'Choix enregistrés :'**
  String get ajouterTradeChoicesSaved;

  /// No description provided for @ajouterTradeNonRespectedSemantic.
  ///
  /// In fr, this message translates to:
  /// **'Non respecté : {label}'**
  String ajouterTradeNonRespectedSemantic(Object label);

  /// No description provided for @ajouterTradeDisciplineRespectBase.
  ///
  /// In fr, this message translates to:
  /// **'Respect {pct} %'**
  String ajouterTradeDisciplineRespectBase(int pct);

  /// No description provided for @ajouterTradeDisciplineRespectNonList.
  ///
  /// In fr, this message translates to:
  /// **' · Non respectés : {items}{more}'**
  String ajouterTradeDisciplineRespectNonList(Object items, Object more);

  /// No description provided for @ajouterTradeFieldActif.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get ajouterTradeFieldActif;

  /// No description provided for @ajouterTradeFieldEntree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get ajouterTradeFieldEntree;

  /// No description provided for @ajouterTradeFieldSortie.
  ///
  /// In fr, this message translates to:
  /// **'Sortie'**
  String get ajouterTradeFieldSortie;

  /// No description provided for @ajouterTradeCheckboxBreakeven.
  ///
  /// In fr, this message translates to:
  /// **'Breakeven'**
  String get ajouterTradeCheckboxBreakeven;

  /// No description provided for @ajouterTradeCheckboxPositionOpen.
  ///
  /// In fr, this message translates to:
  /// **'Position'**
  String get ajouterTradeCheckboxPositionOpen;

  /// No description provided for @ajouterTradeCheckboxAvantNews.
  ///
  /// In fr, this message translates to:
  /// **'Avant news'**
  String get ajouterTradeCheckboxAvantNews;

  /// No description provided for @ajouterTradeCheckboxApresNews.
  ///
  /// In fr, this message translates to:
  /// **'Après news'**
  String get ajouterTradeCheckboxApresNews;

  /// No description provided for @ajouterTradeDirectionBuyLong.
  ///
  /// In fr, this message translates to:
  /// **'Achat · Long'**
  String get ajouterTradeDirectionBuyLong;

  /// No description provided for @ajouterTradeDirectionSellShort.
  ///
  /// In fr, this message translates to:
  /// **'Vente · Short'**
  String get ajouterTradeDirectionSellShort;

  /// No description provided for @ajouterTradeEntryExitDateHint.
  ///
  /// In fr, this message translates to:
  /// **'Conseil : indique la date et l’heure en Entrée et en Sortie. Pour la page Performance, cela servira à relier la durée de position à ton gain ou à ta perte.'**
  String get ajouterTradeEntryExitDateHint;

  /// No description provided for @ajouterTradeQtyLots.
  ///
  /// In fr, this message translates to:
  /// **'Quantité (lots)'**
  String get ajouterTradeQtyLots;

  /// No description provided for @ajouterTradeQtyContracts.
  ///
  /// In fr, this message translates to:
  /// **'Quantité (contrats)'**
  String get ajouterTradeQtyContracts;

  /// No description provided for @ajouterTradeQtyUnits.
  ///
  /// In fr, this message translates to:
  /// **'Quantité (unités)'**
  String get ajouterTradeQtyUnits;

  /// No description provided for @ajouterTradeQtyShares.
  ///
  /// In fr, this message translates to:
  /// **'Quantité (actions)'**
  String get ajouterTradeQtyShares;

  /// No description provided for @ajouterTradeShortcutsLots.
  ///
  /// In fr, this message translates to:
  /// **'Raccourcis lots'**
  String get ajouterTradeShortcutsLots;

  /// No description provided for @ajouterTradeShortcutsContracts.
  ///
  /// In fr, this message translates to:
  /// **'Raccourcis contrats'**
  String get ajouterTradeShortcutsContracts;

  /// No description provided for @ajouterTradeShortcutsQty.
  ///
  /// In fr, this message translates to:
  /// **'Raccourcis quantité'**
  String get ajouterTradeShortcutsQty;

  /// No description provided for @ajouterTradeShortcutsCommonSizes.
  ///
  /// In fr, this message translates to:
  /// **'Raccourcis (tailles courantes)'**
  String get ajouterTradeShortcutsCommonSizes;

  /// No description provided for @ajouterTradeLotHintMini.
  ///
  /// In fr, this message translates to:
  /// **'Ex. 0,1 = mini-lot courant.'**
  String get ajouterTradeLotHintMini;

  /// No description provided for @ajouterTradeLotFieldHintForex.
  ///
  /// In fr, this message translates to:
  /// **'ex. 0,1'**
  String get ajouterTradeLotFieldHintForex;

  /// No description provided for @ajouterTradeLotFieldHintContracts.
  ///
  /// In fr, this message translates to:
  /// **'ex. 2'**
  String get ajouterTradeLotFieldHintContracts;

  /// No description provided for @ajouterTradeLotFieldHintUnits.
  ///
  /// In fr, this message translates to:
  /// **'ex. 1'**
  String get ajouterTradeLotFieldHintUnits;

  /// No description provided for @ajouterTradeLotFieldHintShares.
  ///
  /// In fr, this message translates to:
  /// **'ex. 10'**
  String get ajouterTradeLotFieldHintShares;

  /// No description provided for @ajouterTradeDisciplineSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages discipline'**
  String get ajouterTradeDisciplineSettingsTitle;

  /// No description provided for @ajouterTradeDisciplineSettingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisis quelles sections sont actives pour ce trade.'**
  String get ajouterTradeDisciplineSettingsSubtitle;

  /// No description provided for @ajouterTradeDisciplineFeelingModeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode Feeling'**
  String get ajouterTradeDisciplineFeelingModeTitle;

  /// No description provided for @ajouterTradeDisciplineFeelingAllowSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser le remplissage des sections ci-dessous.'**
  String get ajouterTradeDisciplineFeelingAllowSubtitle;

  /// No description provided for @ajouterTradeDisciplineSectionsHeading.
  ///
  /// In fr, this message translates to:
  /// **'SECTIONS'**
  String get ajouterTradeDisciplineSectionsHeading;

  /// No description provided for @ajouterTradeDisciplineStrategieTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stratégie'**
  String get ajouterTradeDisciplineStrategieTitle;

  /// No description provided for @ajouterTradeDisciplineStrategieSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Setup, rétroaction'**
  String get ajouterTradeDisciplineStrategieSubtitle;

  /// No description provided for @ajouterTradeDisciplinePlanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan d’analyse'**
  String get ajouterTradeDisciplinePlanTitle;

  /// No description provided for @ajouterTradeDisciplineConfidencePlanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan de confiance'**
  String get ajouterTradeDisciplineConfidencePlanTitle;

  /// No description provided for @ajouterTradeDisciplinePlanSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport, rétroaction'**
  String get ajouterTradeDisciplinePlanSubtitle;

  /// No description provided for @ajouterTradeDisciplineChecklistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get ajouterTradeDisciplineChecklistTitle;

  /// No description provided for @ajouterTradeDisciplineChecklistSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Points à respecter'**
  String get ajouterTradeDisciplineChecklistSubtitle;

  /// No description provided for @ajouterTradeDisciplineEtatTitle.
  ///
  /// In fr, this message translates to:
  /// **'État du moment'**
  String get ajouterTradeDisciplineEtatTitle;

  /// No description provided for @ajouterTradeDisciplineEtatSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Moments et émotions'**
  String get ajouterTradeDisciplineEtatSubtitle;

  /// No description provided for @ajouterTradeDisciplineSliderStrategieRespected.
  ///
  /// In fr, this message translates to:
  /// **'Stratégie respectée'**
  String get ajouterTradeDisciplineSliderStrategieRespected;

  /// No description provided for @ajouterTradePositionSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages position'**
  String get ajouterTradePositionSettingsTitle;

  /// No description provided for @ajouterTradeStrategieFeedbackBravo.
  ///
  /// In fr, this message translates to:
  /// **'Bravo ! Tu as tout respecté ta stratégie.'**
  String get ajouterTradeStrategieFeedbackBravo;

  /// No description provided for @ajouterTradeStrategieFeedbackWhichMissed.
  ///
  /// In fr, this message translates to:
  /// **'Tu n’as pas respecté quel(s) élément(s) de ta stratégie ?'**
  String get ajouterTradeStrategieFeedbackWhichMissed;

  /// No description provided for @ajouterTradeStrategieGoldRules.
  ///
  /// In fr, this message translates to:
  /// **'MES RÈGLES D’OR'**
  String get ajouterTradeStrategieGoldRules;

  /// No description provided for @ajouterTradeStrategieRuleN.
  ///
  /// In fr, this message translates to:
  /// **'Règle {n}'**
  String ajouterTradeStrategieRuleN(int n);

  /// No description provided for @ajouterTradeStrategieSetupTimeframesRow.
  ///
  /// In fr, this message translates to:
  /// **'Timeframes : {value}'**
  String ajouterTradeStrategieSetupTimeframesRow(Object value);

  /// No description provided for @ajouterTradeStrategieSetupIndicatorsRow.
  ///
  /// In fr, this message translates to:
  /// **'Indicateurs : {value}'**
  String ajouterTradeStrategieSetupIndicatorsRow(Object value);

  /// No description provided for @ajouterTradeStrategieSetupPatternRow.
  ///
  /// In fr, this message translates to:
  /// **'Pattern : {value}'**
  String ajouterTradeStrategieSetupPatternRow(Object value);

  /// No description provided for @ajouterTradeStrategieSetupSignalRow.
  ///
  /// In fr, this message translates to:
  /// **'Signal : {value}'**
  String ajouterTradeStrategieSetupSignalRow(Object value);

  /// No description provided for @ajouterTradeStrategieRiskManagement.
  ///
  /// In fr, this message translates to:
  /// **'GESTION DU RISQUE'**
  String get ajouterTradeStrategieRiskManagement;

  /// No description provided for @ajouterTradeStrategieHoursSessions.
  ///
  /// In fr, this message translates to:
  /// **'HORAIRES & SESSIONS'**
  String get ajouterTradeStrategieHoursSessions;

  /// No description provided for @ajouterTradeStrategieSetupModels.
  ///
  /// In fr, this message translates to:
  /// **'SETUP & MODÈLES'**
  String get ajouterTradeStrategieSetupModels;

  /// No description provided for @ajouterTradeStrategieSetupModelsWithTitle.
  ///
  /// In fr, this message translates to:
  /// **'SETUP & MODÈLES — {title}'**
  String ajouterTradeStrategieSetupModelsWithTitle(Object title);

  /// No description provided for @ajouterTradeStrategiePickStrategyHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisis une stratégie dans la liste au-dessus pour afficher les détails du setup (entrée, stop, cible, gestion du trade, etc.).'**
  String get ajouterTradeStrategiePickStrategyHint;

  /// No description provided for @ajouterTradeStrategieRowPattern.
  ///
  /// In fr, this message translates to:
  /// **'Pattern'**
  String get ajouterTradeStrategieRowPattern;

  /// No description provided for @ajouterTradeStrategieRowSignal.
  ///
  /// In fr, this message translates to:
  /// **'Signal'**
  String get ajouterTradeStrategieRowSignal;

  /// No description provided for @ajouterTradeStrategieClosedLabel100.
  ///
  /// In fr, this message translates to:
  /// **'Bravo, stratégie respectée'**
  String get ajouterTradeStrategieClosedLabel100;

  /// No description provided for @ajouterTradeStrategieClosedLabel95.
  ///
  /// In fr, this message translates to:
  /// **'Presque tout respecté'**
  String get ajouterTradeStrategieClosedLabel95;

  /// No description provided for @ajouterTradeStrategieClosedLabelLow.
  ///
  /// In fr, this message translates to:
  /// **'Points à revoir'**
  String get ajouterTradeStrategieClosedLabelLow;

  /// No description provided for @ajouterTradePlanPickReportAbove.
  ///
  /// In fr, this message translates to:
  /// **'Choisis un rapport dans le champ au-dessus.'**
  String get ajouterTradePlanPickReportAbove;

  /// No description provided for @ajouterTradePlanFeedbackAlmost100.
  ///
  /// In fr, this message translates to:
  /// **'Tu es proche du 100 % : continue à appliquer chaque point de ton plan d’analyse.'**
  String get ajouterTradePlanFeedbackAlmost100;

  /// No description provided for @ajouterTradePlanFeedbackBravo.
  ///
  /// In fr, this message translates to:
  /// **'Bravo ! Tu as tout respecté ton plan d’analyse.'**
  String get ajouterTradePlanFeedbackBravo;

  /// No description provided for @ajouterTradePlanFeedbackWhichMissed.
  ///
  /// In fr, this message translates to:
  /// **'Tu n’as pas respecté quel(s) élément(s) de ton plan d’analyse ?'**
  String get ajouterTradePlanFeedbackWhichMissed;

  /// No description provided for @ajouterTradePlanClosedLabel100.
  ///
  /// In fr, this message translates to:
  /// **'Bravo, plan respecté'**
  String get ajouterTradePlanClosedLabel100;

  /// No description provided for @ajouterTradePlanClosedLabelLow.
  ///
  /// In fr, this message translates to:
  /// **'Rétroaction'**
  String get ajouterTradePlanClosedLabelLow;

  /// No description provided for @ajouterTradeChecklistFeedbackAlmost100.
  ///
  /// In fr, this message translates to:
  /// **'Tu es proche du 100 % : continue à appliquer chaque point de ta checklist.'**
  String get ajouterTradeChecklistFeedbackAlmost100;

  /// No description provided for @ajouterTradeChecklistFeedbackBravo.
  ///
  /// In fr, this message translates to:
  /// **'Bravo ! Tu as tout respecté ta checklist.'**
  String get ajouterTradeChecklistFeedbackBravo;

  /// No description provided for @ajouterTradeChecklistFeedbackWhichMissed.
  ///
  /// In fr, this message translates to:
  /// **'Tu n’as pas respecté quel(s) élément(s) de ta checklist ?'**
  String get ajouterTradeChecklistFeedbackWhichMissed;

  /// No description provided for @ajouterTradeChecklistClosedLabel100.
  ///
  /// In fr, this message translates to:
  /// **'Bravo, checklist respectée'**
  String get ajouterTradeChecklistClosedLabel100;

  /// No description provided for @ajouterTradeChecklistClosedLabelLow.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get ajouterTradeChecklistClosedLabelLow;

  /// No description provided for @ajouterTradeEtatFeelingPrompt.
  ///
  /// In fr, this message translates to:
  /// **'T’as eu quoi comme sentiment ?'**
  String get ajouterTradeEtatFeelingPrompt;

  /// No description provided for @ajouterTradeEtatFeedbackAlmost100.
  ///
  /// In fr, this message translates to:
  /// **'Tu es proche du 100 % : continue à appliquer chaque point.'**
  String get ajouterTradeEtatFeedbackAlmost100;

  /// No description provided for @ajouterTradeEtatClosedLabel100.
  ///
  /// In fr, this message translates to:
  /// **'Oui, c’est difficile. Bravo !'**
  String get ajouterTradeEtatClosedLabel100;

  /// No description provided for @ajouterTradeEtatClosedLabelLow.
  ///
  /// In fr, this message translates to:
  /// **'État du moment'**
  String get ajouterTradeEtatClosedLabelLow;

  /// No description provided for @ajouterTradeEtatHeaderMoment.
  ///
  /// In fr, this message translates to:
  /// **'ÉTAT DU MOMENT'**
  String get ajouterTradeEtatHeaderMoment;

  /// No description provided for @ajouterTradeEtatHeaderEmotions.
  ///
  /// In fr, this message translates to:
  /// **'ÉMOTIONS'**
  String get ajouterTradeEtatHeaderEmotions;

  /// No description provided for @ajouterTradeScreenshotLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’afficher l’image'**
  String get ajouterTradeScreenshotLoadError;

  /// No description provided for @ajouterTradeScreenshotChangeImage.
  ///
  /// In fr, this message translates to:
  /// **'Changer l’image'**
  String get ajouterTradeScreenshotChangeImage;

  /// No description provided for @ajouterTradeScreenshotTapToAdd.
  ///
  /// In fr, this message translates to:
  /// **'Appuie pour ajouter une image'**
  String get ajouterTradeScreenshotTapToAdd;

  /// No description provided for @ajouterTradeScreenshotRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get ajouterTradeScreenshotRemove;

  /// No description provided for @ajouterTradePlanRowBias.
  ///
  /// In fr, this message translates to:
  /// **'Biais'**
  String get ajouterTradePlanRowBias;

  /// No description provided for @ajouterTradePlanRowTimeframeHtf.
  ///
  /// In fr, this message translates to:
  /// **'Timeframe HTF'**
  String get ajouterTradePlanRowTimeframeHtf;

  /// No description provided for @ajouterTradePlanRowPhase.
  ///
  /// In fr, this message translates to:
  /// **'Phase'**
  String get ajouterTradePlanRowPhase;

  /// No description provided for @ajouterTradePlanRowNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get ajouterTradePlanRowNotes;

  /// No description provided for @ajouterTradePlanRowLastPoint.
  ///
  /// In fr, this message translates to:
  /// **'Dernier point'**
  String get ajouterTradePlanRowLastPoint;

  /// No description provided for @ajouterTradePlanRowExtraSupport.
  ///
  /// In fr, this message translates to:
  /// **'Support suppl. {n}'**
  String ajouterTradePlanRowExtraSupport(int n);

  /// No description provided for @ajouterTradePlanRowExtraResistance.
  ///
  /// In fr, this message translates to:
  /// **'Résistance suppl. {n}'**
  String ajouterTradePlanRowExtraResistance(int n);

  /// No description provided for @ajouterTradePlanRowOutils.
  ///
  /// In fr, this message translates to:
  /// **'Outils'**
  String get ajouterTradePlanRowOutils;

  /// No description provided for @ajouterTradePlanRowLiquidity.
  ///
  /// In fr, this message translates to:
  /// **'Liquidité'**
  String get ajouterTradePlanRowLiquidity;

  /// No description provided for @ajouterTradePlanRowFibPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix Fib'**
  String get ajouterTradePlanRowFibPrice;

  /// No description provided for @ajouterTradePlanSectionVolume.
  ///
  /// In fr, this message translates to:
  /// **'VOLUME'**
  String get ajouterTradePlanSectionVolume;

  /// No description provided for @analyseAddField.
  ///
  /// In fr, this message translates to:
  /// **'+ Ajouter un champ'**
  String get analyseAddField;

  /// No description provided for @analyseAddPhaseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une phase'**
  String get analyseAddPhaseTitle;

  /// No description provided for @analyseAddResist.
  ///
  /// In fr, this message translates to:
  /// **'+ Ajouter Résistance'**
  String get analyseAddResist;

  /// No description provided for @analyseAddShort.
  ///
  /// In fr, this message translates to:
  /// **'+ Ajouter'**
  String get analyseAddShort;

  /// No description provided for @analyseAddSupport.
  ///
  /// In fr, this message translates to:
  /// **'+ Ajouter Support'**
  String get analyseAddSupport;

  /// No description provided for @analyseAddTimeframeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un timeframe'**
  String get analyseAddTimeframeTitle;

  /// No description provided for @analyseAddTimeframeCustomEntry.
  ///
  /// In fr, this message translates to:
  /// **'Autre (saisie libre)'**
  String get analyseAddTimeframeCustomEntry;

  /// No description provided for @analyseAddTimeframeSectionRestore.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver'**
  String get analyseAddTimeframeSectionRestore;

  /// No description provided for @analyseAddTimeframeSectionIntraday.
  ///
  /// In fr, this message translates to:
  /// **'Intraday'**
  String get analyseAddTimeframeSectionIntraday;

  /// No description provided for @analyseAddTimeframeSectionSwing.
  ///
  /// In fr, this message translates to:
  /// **'Swing & position'**
  String get analyseAddTimeframeSectionSwing;

  /// No description provided for @analyseAddTrendTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une tendance'**
  String get analyseAddTrendTitle;

  /// No description provided for @analyseReportScreenshotSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'CAPTURE'**
  String get analyseReportScreenshotSectionTitle;

  /// No description provided for @analyseReportScreenshotAddCapture.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une capture'**
  String get analyseReportScreenshotAddCapture;

  /// No description provided for @analyseReportScreenshotChooseImage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une image'**
  String get analyseReportScreenshotChooseImage;

  /// No description provided for @analyseReportScreenshotSubtitleWeb.
  ///
  /// In fr, this message translates to:
  /// **'Fichier image'**
  String get analyseReportScreenshotSubtitleWeb;

  /// No description provided for @analyseReportScreenshotSubtitleFilePicker.
  ///
  /// In fr, this message translates to:
  /// **'Galerie ou explorateur de fichiers'**
  String get analyseReportScreenshotSubtitleFilePicker;

  /// No description provided for @analyseReportScreenshotCamera.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get analyseReportScreenshotCamera;

  /// No description provided for @analyseReportScreenshotHintWithCamera.
  ///
  /// In fr, this message translates to:
  /// **'Fichier, galerie ou appareil photo'**
  String get analyseReportScreenshotHintWithCamera;

  /// No description provided for @analyseReportScreenshotHintNoCamera.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une image sur cet appareil'**
  String get analyseReportScreenshotHintNoCamera;

  /// No description provided for @analyseReportScreenshotErrorPlugin.
  ///
  /// In fr, this message translates to:
  /// **'Sélection d’image indisponible sur cette cible. Utilisez « Choisir une image » ou reconstruisez l’app (flutter clean / run).'**
  String get analyseReportScreenshotErrorPlugin;

  /// No description provided for @analyseReportScreenshotErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’ajouter la capture.'**
  String get analyseReportScreenshotErrorGeneric;

  /// No description provided for @analyseCardIndicators.
  ///
  /// In fr, this message translates to:
  /// **'Indicateurs'**
  String get analyseCardIndicators;

  /// No description provided for @analyseCardSmcLiquidity.
  ///
  /// In fr, this message translates to:
  /// **'SMC & Liquidité'**
  String get analyseCardSmcLiquidity;

  /// No description provided for @analyseCardVolumeProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil de Volume'**
  String get analyseCardVolumeProfile;

  /// No description provided for @analysePageHeroTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon analyse'**
  String get analysePageHeroTitle;

  /// No description provided for @analysePageHeroSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos analyses et stratégies en temps réel.'**
  String get analysePageHeroSubtitle;

  /// No description provided for @analyseSidebarConfidenceSummary.
  ///
  /// In fr, this message translates to:
  /// **'SYNTHÈSE'**
  String get analyseSidebarConfidenceSummary;

  /// No description provided for @analyseSidebarConfidenceLabel.
  ///
  /// In fr, this message translates to:
  /// **'confiance globale'**
  String get analyseSidebarConfidenceLabel;

  /// No description provided for @analyseSidebarReportHint.
  ///
  /// In fr, this message translates to:
  /// **'Le rapport sera enregistré dans votre historique avec l’actif associé.'**
  String get analyseSidebarReportHint;

  /// No description provided for @analyseSidebarPreviewStyle.
  ///
  /// In fr, this message translates to:
  /// **'APERÇU DU STYLE'**
  String get analyseSidebarPreviewStyle;

  /// No description provided for @analyseConfidenceHigh.
  ///
  /// In fr, this message translates to:
  /// **'Élevé'**
  String get analyseConfidenceHigh;

  /// No description provided for @analyseConfidenceLevelTitle.
  ///
  /// In fr, this message translates to:
  /// **'NIVEAU DE CONFIANCE'**
  String get analyseConfidenceLevelTitle;

  /// No description provided for @analyseConfidenceLow.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get analyseConfidenceLow;

  /// No description provided for @analyseCopyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Copie {label}'**
  String analyseCopyLabel(String label);

  /// No description provided for @analyseCopyNumber.
  ///
  /// In fr, this message translates to:
  /// **'Copie {n}'**
  String analyseCopyNumber(int n);

  /// No description provided for @analyseCurrentMarketPhase.
  ///
  /// In fr, this message translates to:
  /// **'PHASE ACTUELLE DU MARCHÉ'**
  String get analyseCurrentMarketPhase;

  /// No description provided for @analyseCurrentTrend.
  ///
  /// In fr, this message translates to:
  /// **'TENDANCE ACTUELLE'**
  String get analyseCurrentTrend;

  /// No description provided for @analyseDeleteTemplateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce modèle ?'**
  String get analyseDeleteTemplateTitle;

  /// No description provided for @analyseDirectionLabel.
  ///
  /// In fr, this message translates to:
  /// **'DIRECTION'**
  String get analyseDirectionLabel;

  /// No description provided for @analyseDraftLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Libellé…'**
  String get analyseDraftLabelHint;

  /// No description provided for @analyseExtraBroken.
  ///
  /// In fr, this message translates to:
  /// **'Cassé'**
  String get analyseExtraBroken;

  /// No description provided for @analyseExtraHeld.
  ///
  /// In fr, this message translates to:
  /// **'Tenu'**
  String get analyseExtraHeld;

  /// No description provided for @analyseExtraPriceHint.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get analyseExtraPriceHint;

  /// No description provided for @analyseFeuillePlanTitle.
  ///
  /// In fr, this message translates to:
  /// **'FEUILLE DE PLAN'**
  String get analyseFeuillePlanTitle;

  /// No description provided for @analyseFibLevel.
  ///
  /// In fr, this message translates to:
  /// **'NIVEAU FIBONACCI'**
  String get analyseFibLevel;

  /// No description provided for @analyseFibShort.
  ///
  /// In fr, this message translates to:
  /// **'FIBONACCI'**
  String get analyseFibShort;

  /// No description provided for @analyseFreeFields.
  ///
  /// In fr, this message translates to:
  /// **'CHAMPS LIBRES'**
  String get analyseFreeFields;

  /// No description provided for @analyseFvg.
  ///
  /// In fr, this message translates to:
  /// **'FAIR VALUE GAP (FVG)'**
  String get analyseFvg;

  /// No description provided for @analyseHintActifExamples.
  ///
  /// In fr, this message translates to:
  /// **'ex : NASDAQ, EUR/USD…'**
  String get analyseHintActifExamples;

  /// No description provided for @analyseHintDetailsDots.
  ///
  /// In fr, this message translates to:
  /// **'Détails…'**
  String get analyseHintDetailsDots;

  /// No description provided for @analyseHintHtfChipExample.
  ///
  /// In fr, this message translates to:
  /// **'ex. Weekly'**
  String get analyseHintHtfChipExample;

  /// No description provided for @analyseHintImbalance.
  ///
  /// In fr, this message translates to:
  /// **'Imbalance…'**
  String get analyseHintImbalance;

  /// No description provided for @analyseHintNotesDots.
  ///
  /// In fr, this message translates to:
  /// **'Notes…'**
  String get analyseHintNotesDots;

  /// No description provided for @analyseHintPriceDots.
  ///
  /// In fr, this message translates to:
  /// **'Prix…'**
  String get analyseHintPriceDots;

  /// No description provided for @analyseHintStops.
  ///
  /// In fr, this message translates to:
  /// **'Où sont les stops ? (ex: Buy Side)'**
  String get analyseHintStops;

  /// No description provided for @analyseHintTextDots.
  ///
  /// In fr, this message translates to:
  /// **'Texte…'**
  String get analyseHintTextDots;

  /// No description provided for @analyseHintTfExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. MN, 3D…'**
  String get analyseHintTfExamples;

  /// No description provided for @analyseHintZoneHtf.
  ///
  /// In fr, this message translates to:
  /// **'Zone HTF…'**
  String get analyseHintZoneHtf;

  /// No description provided for @analyseHtfTimeframe.
  ///
  /// In fr, this message translates to:
  /// **'TIMEFRAME D\'ANALYSE (HTF)'**
  String get analyseHtfTimeframe;

  /// No description provided for @analyseImpactFeuille.
  ///
  /// In fr, this message translates to:
  /// **'Impact Feuille'**
  String get analyseImpactFeuille;

  /// No description provided for @analyseImpactIndicators.
  ///
  /// In fr, this message translates to:
  /// **'Impact Indicateurs'**
  String get analyseImpactIndicators;

  /// No description provided for @analyseImpactLine.
  ///
  /// In fr, this message translates to:
  /// **'Impact : {percent} %'**
  String analyseImpactLine(int percent);

  /// No description provided for @analyseImpactModalBlurb.
  ///
  /// In fr, this message translates to:
  /// **'Les 4 impacts se partagent 100 % au total. Déplacer ce curseur réduit ou augmente les autres de façon proportionnelle.'**
  String get analyseImpactModalBlurb;

  /// No description provided for @analyseImpactModalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Régler l\'impact'**
  String get analyseImpactModalTitle;

  /// No description provided for @analyseImpactShort.
  ///
  /// In fr, this message translates to:
  /// **'Impact'**
  String get analyseImpactShort;

  /// No description provided for @analyseImpactSmc.
  ///
  /// In fr, this message translates to:
  /// **'Impact SMC'**
  String get analyseImpactSmc;

  /// No description provided for @analyseLastPointHint.
  ///
  /// In fr, this message translates to:
  /// **'Dernier point…'**
  String get analyseLastPointHint;

  /// No description provided for @analyseLiquidityPools.
  ///
  /// In fr, this message translates to:
  /// **'LIQUIDITY POOLS'**
  String get analyseLiquidityPools;

  /// No description provided for @analyseMovementDetailsHint.
  ///
  /// In fr, this message translates to:
  /// **'Détails du mouvement…'**
  String get analyseMovementDetailsHint;

  /// No description provided for @analyseNameFieldHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'analyse…'**
  String get analyseNameFieldHint;

  /// No description provided for @analyseNameFieldLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'analyse'**
  String get analyseNameFieldLabel;

  /// No description provided for @analyseNoTemplatesSaved.
  ///
  /// In fr, this message translates to:
  /// **'Aucun modèle enregistré'**
  String get analyseNoTemplatesSaved;

  /// No description provided for @analyseNote.
  ///
  /// In fr, this message translates to:
  /// **'NOTE'**
  String get analyseNote;

  /// No description provided for @analyseNotesIndicators.
  ///
  /// In fr, this message translates to:
  /// **'NOTES (INDICATEURS)'**
  String get analyseNotesIndicators;

  /// No description provided for @analyseNotesSmcExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Prise de liquidité avant FVG…'**
  String get analyseNotesSmcExample;

  /// No description provided for @analyseNotesSmcLiq.
  ///
  /// In fr, this message translates to:
  /// **'NOTES (SMC & LIQUIDITÉ)'**
  String get analyseNotesSmcLiq;

  /// No description provided for @analyseNotesVolumeProfile.
  ///
  /// In fr, this message translates to:
  /// **'NOTES (PROFIL DE VOLUME)'**
  String get analyseNotesVolumeProfile;

  /// No description provided for @analyseOrderBlock.
  ///
  /// In fr, this message translates to:
  /// **'ORDER BLOCK (OB)'**
  String get analyseOrderBlock;

  /// No description provided for @analysePhase.
  ///
  /// In fr, this message translates to:
  /// **'PHASE'**
  String get analysePhase;

  /// No description provided for @analyseReportCellFvg.
  ///
  /// In fr, this message translates to:
  /// **'FVG'**
  String get analyseReportCellFvg;

  /// No description provided for @analyseReportCellLiqPools.
  ///
  /// In fr, this message translates to:
  /// **'LIQ. POOLS'**
  String get analyseReportCellLiqPools;

  /// No description provided for @analyseReportCellOrderBlock.
  ///
  /// In fr, this message translates to:
  /// **'ORDER BLOCK'**
  String get analyseReportCellOrderBlock;

  /// No description provided for @analyseResistLower.
  ///
  /// In fr, this message translates to:
  /// **'Résistance'**
  String get analyseResistLower;

  /// No description provided for @analyseResistShort.
  ///
  /// In fr, this message translates to:
  /// **'RÉSIST.'**
  String get analyseResistShort;

  /// No description provided for @analyseSetup.
  ///
  /// In fr, this message translates to:
  /// **'SETUP'**
  String get analyseSetup;

  /// No description provided for @analyseSideBuy.
  ///
  /// In fr, this message translates to:
  /// **'Achat'**
  String get analyseSideBuy;

  /// No description provided for @analyseSideSell.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get analyseSideSell;

  /// No description provided for @analyseSideWatch.
  ///
  /// In fr, this message translates to:
  /// **'À surveiller'**
  String get analyseSideWatch;

  /// No description provided for @analyseSmcAdds.
  ///
  /// In fr, this message translates to:
  /// **'AJOUTS SMC'**
  String get analyseSmcAdds;

  /// No description provided for @analyseStructTagResist.
  ///
  /// In fr, this message translates to:
  /// **'R'**
  String get analyseStructTagResist;

  /// No description provided for @analyseStructTagSupport.
  ///
  /// In fr, this message translates to:
  /// **'S'**
  String get analyseStructTagSupport;

  /// No description provided for @analyseStructure.
  ///
  /// In fr, this message translates to:
  /// **'STRUCTURE'**
  String get analyseStructure;

  /// No description provided for @analyseStructureSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Structure'**
  String get analyseStructureSectionTitle;

  /// No description provided for @analyseSupport.
  ///
  /// In fr, this message translates to:
  /// **'SUPPORT'**
  String get analyseSupport;

  /// No description provided for @analyseSupportLower.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get analyseSupportLower;

  /// No description provided for @analyseTemplateApplied.
  ///
  /// In fr, this message translates to:
  /// **'Modèle « {name} » appliqué'**
  String analyseTemplateApplied(String name);

  /// No description provided for @analyseTemplateNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau nom…'**
  String get analyseTemplateNameHint;

  /// No description provided for @analyseTemplateRenameDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renommer le modèle'**
  String get analyseTemplateRenameDialogTitle;

  /// No description provided for @analyseTemplateSaveDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nom du modèle'**
  String get analyseTemplateSaveDialogTitle;

  /// No description provided for @analyseTemplateStyleHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. Swing, Scalping…'**
  String get analyseTemplateStyleHint;

  /// No description provided for @analyseTestedTwice.
  ///
  /// In fr, this message translates to:
  /// **'Testé x 2'**
  String get analyseTestedTwice;

  /// No description provided for @analyseTimeframeLabelShort.
  ///
  /// In fr, this message translates to:
  /// **'TIMEFRAME'**
  String get analyseTimeframeLabelShort;

  /// No description provided for @analyseTooltipPickTemplate.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un modèle enregistré'**
  String get analyseTooltipPickTemplate;

  /// No description provided for @analyseTooltipSaveTemplatePills.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les puces sous un nom (votre habitude)'**
  String get analyseTooltipSaveTemplatePills;

  /// No description provided for @analyseTrend.
  ///
  /// In fr, this message translates to:
  /// **'TENDANCE'**
  String get analyseTrend;

  /// No description provided for @analyseTrendLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tendance'**
  String get analyseTrendLabel;

  /// No description provided for @analyseVolumePoc.
  ///
  /// In fr, this message translates to:
  /// **'POC'**
  String get analyseVolumePoc;

  /// No description provided for @analyseVolumeProfile.
  ///
  /// In fr, this message translates to:
  /// **'PROFIL DE VOLUME'**
  String get analyseVolumeProfile;

  /// No description provided for @analyseVolumeProfileDefaultLabel.
  ///
  /// In fr, this message translates to:
  /// **'Profil volume'**
  String get analyseVolumeProfileDefaultLabel;

  /// No description provided for @analyseVolumeVah.
  ///
  /// In fr, this message translates to:
  /// **'VAH'**
  String get analyseVolumeVah;

  /// No description provided for @analyseVolumeVal.
  ///
  /// In fr, this message translates to:
  /// **'VAL'**
  String get analyseVolumeVal;

  /// No description provided for @analyseVolumeZoneFrom.
  ///
  /// In fr, this message translates to:
  /// **'De'**
  String get analyseVolumeZoneFrom;

  /// No description provided for @analyseVolumeZoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get analyseVolumeZoneLabel;

  /// No description provided for @analyseVolumeZoneTo.
  ///
  /// In fr, this message translates to:
  /// **'À'**
  String get analyseVolumeZoneTo;

  /// No description provided for @appBrandName.
  ///
  /// In fr, this message translates to:
  /// **'PAYCHEK'**
  String get appBrandName;

  /// No description provided for @buttonCalculate.
  ///
  /// In fr, this message translates to:
  /// **'Calculer'**
  String get buttonCalculate;

  /// No description provided for @calAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get calAmountLabel;

  /// No description provided for @calMonthlyObjectiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Objectif mensuel'**
  String get calMonthlyObjectiveTitle;

  /// No description provided for @calPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get calPageTitle;

  /// No description provided for @calObjectiveLabel.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get calObjectiveLabel;

  /// No description provided for @calCumulativePerformanceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Performance cumulée'**
  String get calCumulativePerformanceTitle;

  /// No description provided for @calBestDay.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur jour'**
  String get calBestDay;

  /// No description provided for @calTradingDays.
  ///
  /// In fr, this message translates to:
  /// **'Jours tradés'**
  String get calTradingDays;

  /// No description provided for @calAverageShort.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get calAverageShort;

  /// No description provided for @calPnlShort.
  ///
  /// In fr, this message translates to:
  /// **'P&L'**
  String get calPnlShort;

  /// No description provided for @calCapitalChangePct.
  ///
  /// In fr, this message translates to:
  /// **'Variation capital'**
  String get calCapitalChangePct;

  /// No description provided for @calAveragePerDay.
  ///
  /// In fr, this message translates to:
  /// **'Moy./jour'**
  String get calAveragePerDay;

  /// No description provided for @calObjectiveShort.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get calObjectiveShort;

  /// No description provided for @calChartError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {message}'**
  String calChartError(String message);

  /// Nombre de trades sur un jour (infobulle ou cellule).
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun trade} =1{1 trade} other{{count} trades}}'**
  String calDayTradesCount(int count);

  /// No description provided for @monthJanuary.
  ///
  /// In fr, this message translates to:
  /// **'Janvier'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In fr, this message translates to:
  /// **'Février'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In fr, this message translates to:
  /// **'Mars'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In fr, this message translates to:
  /// **'Avril'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In fr, this message translates to:
  /// **'Mai'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In fr, this message translates to:
  /// **'Juin'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In fr, this message translates to:
  /// **'Juillet'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In fr, this message translates to:
  /// **'Août'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In fr, this message translates to:
  /// **'Septembre'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In fr, this message translates to:
  /// **'Octobre'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In fr, this message translates to:
  /// **'Novembre'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In fr, this message translates to:
  /// **'Décembre'**
  String get monthDecember;

  /// No description provided for @monthAbbrJanuary.
  ///
  /// In fr, this message translates to:
  /// **'janv.'**
  String get monthAbbrJanuary;

  /// No description provided for @monthAbbrFebruary.
  ///
  /// In fr, this message translates to:
  /// **'févr.'**
  String get monthAbbrFebruary;

  /// No description provided for @monthAbbrMarch.
  ///
  /// In fr, this message translates to:
  /// **'mars'**
  String get monthAbbrMarch;

  /// No description provided for @monthAbbrApril.
  ///
  /// In fr, this message translates to:
  /// **'avr.'**
  String get monthAbbrApril;

  /// No description provided for @monthAbbrMay.
  ///
  /// In fr, this message translates to:
  /// **'mai'**
  String get monthAbbrMay;

  /// No description provided for @monthAbbrJune.
  ///
  /// In fr, this message translates to:
  /// **'juin'**
  String get monthAbbrJune;

  /// No description provided for @monthAbbrJuly.
  ///
  /// In fr, this message translates to:
  /// **'juil.'**
  String get monthAbbrJuly;

  /// No description provided for @monthAbbrAugust.
  ///
  /// In fr, this message translates to:
  /// **'août'**
  String get monthAbbrAugust;

  /// No description provided for @monthAbbrSeptember.
  ///
  /// In fr, this message translates to:
  /// **'sept.'**
  String get monthAbbrSeptember;

  /// No description provided for @monthAbbrOctober.
  ///
  /// In fr, this message translates to:
  /// **'oct.'**
  String get monthAbbrOctober;

  /// No description provided for @monthAbbrNovember.
  ///
  /// In fr, this message translates to:
  /// **'nov.'**
  String get monthAbbrNovember;

  /// No description provided for @monthAbbrDecember.
  ///
  /// In fr, this message translates to:
  /// **'déc.'**
  String get monthAbbrDecember;

  /// No description provided for @calcBestBalance.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur solde'**
  String get calcBestBalance;

  /// No description provided for @calcEndBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde final'**
  String get calcEndBalance;

  /// No description provided for @calcEquityCurveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Courbe de capital (trade return)'**
  String get calcEquityCurveTitle;

  /// No description provided for @calcLabelEntry.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'entrée'**
  String get calcLabelEntry;

  /// No description provided for @calcLabelRiskShort.
  ///
  /// In fr, this message translates to:
  /// **'Risque'**
  String get calcLabelRiskShort;

  /// No description provided for @calcLabelSl.
  ///
  /// In fr, this message translates to:
  /// **'Stop loss'**
  String get calcLabelSl;

  /// No description provided for @calcLabelStartBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial'**
  String get calcLabelStartBalance;

  /// No description provided for @calcLabelTp.
  ///
  /// In fr, this message translates to:
  /// **'Take profit'**
  String get calcLabelTp;

  /// No description provided for @calcLabelTradesShort.
  ///
  /// In fr, this message translates to:
  /// **'Trades'**
  String get calcLabelTradesShort;

  /// No description provided for @calcLabelWinRateShort.
  ///
  /// In fr, this message translates to:
  /// **'Win rate'**
  String get calcLabelWinRateShort;

  /// No description provided for @calcLoss.
  ///
  /// In fr, this message translates to:
  /// **'Perte'**
  String get calcLoss;

  /// No description provided for @calcMaxDrawdown.
  ///
  /// In fr, this message translates to:
  /// **'Drawdown max'**
  String get calcMaxDrawdown;

  /// No description provided for @calcProfitFactor.
  ///
  /// In fr, this message translates to:
  /// **'Profit factor'**
  String get calcProfitFactor;

  /// No description provided for @calcRatioSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ratio'**
  String get calcRatioSectionTitle;

  /// No description provided for @calcResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat'**
  String get calcResult;

  /// No description provided for @calcResultOfCalculation.
  ///
  /// In fr, this message translates to:
  /// **'Résultat du calcul'**
  String get calcResultOfCalculation;

  /// No description provided for @calcRowGain.
  ///
  /// In fr, this message translates to:
  /// **'Gain :'**
  String get calcRowGain;

  /// No description provided for @calcRowSl.
  ///
  /// In fr, this message translates to:
  /// **'SL :'**
  String get calcRowSl;

  /// No description provided for @calcRowVsCapital.
  ///
  /// In fr, this message translates to:
  /// **'Vs capital'**
  String get calcRowVsCapital;

  /// No description provided for @calcSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get calcSettingsTitle;

  /// No description provided for @calcTotalGainLabel.
  ///
  /// In fr, this message translates to:
  /// **'Gain total'**
  String get calcTotalGainLabel;

  /// No description provided for @calcTradeReturnTableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résultats trade return'**
  String get calcTradeReturnTableTitle;

  /// No description provided for @calcWin.
  ///
  /// In fr, this message translates to:
  /// **'Gain'**
  String get calcWin;

  /// No description provided for @calcWinsLosses.
  ///
  /// In fr, this message translates to:
  /// **'Gains / Pertes'**
  String get calcWinsLosses;

  /// No description provided for @calcErrorInvalidBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial invalide.'**
  String get calcErrorInvalidBalance;

  /// No description provided for @calcErrorTradesRange.
  ///
  /// In fr, this message translates to:
  /// **'Le nombre de trades doit être entre 1 et 2000.'**
  String get calcErrorTradesRange;

  /// No description provided for @calcErrorWinRateRange.
  ///
  /// In fr, this message translates to:
  /// **'Le win rate doit être entre 0 et 100.'**
  String get calcErrorWinRateRange;

  /// No description provided for @calcErrorRiskRange.
  ///
  /// In fr, this message translates to:
  /// **'Le risque (%) doit être entre 0 et 100.'**
  String get calcErrorRiskRange;

  /// No description provided for @calcErrorInvalidRiskReward.
  ///
  /// In fr, this message translates to:
  /// **'Risk:Reward invalide.'**
  String get calcErrorInvalidRiskReward;

  /// No description provided for @calcErrorInvalidLot.
  ///
  /// In fr, this message translates to:
  /// **'Lot invalide.'**
  String get calcErrorInvalidLot;

  /// No description provided for @calcErrorInvalidEntry.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'entrée invalide.'**
  String get calcErrorInvalidEntry;

  /// No description provided for @calcErrorInvalidSl.
  ///
  /// In fr, this message translates to:
  /// **'Stop loss invalide.'**
  String get calcErrorInvalidSl;

  /// No description provided for @calcErrorInvalidTp.
  ///
  /// In fr, this message translates to:
  /// **'Take profit invalide.'**
  String get calcErrorInvalidTp;

  /// No description provided for @calcErrorEntrySlIdentical.
  ///
  /// In fr, this message translates to:
  /// **'Entrée et SL ne peuvent pas être identiques.'**
  String get calcErrorEntrySlIdentical;

  /// No description provided for @calcDisclaimerEstimates.
  ///
  /// In fr, this message translates to:
  /// **'Attention : ces calculs ne sont pas des chiffres contractuels. Ils servent uniquement à donner une idée.'**
  String get calcDisclaimerEstimates;

  /// No description provided for @calcHeaderSubtitleEstimates.
  ///
  /// In fr, this message translates to:
  /// **'Simulations rendement et ratio — valeurs indicatives.'**
  String get calcHeaderSubtitleEstimates;

  /// No description provided for @calcMarketIndex.
  ///
  /// In fr, this message translates to:
  /// **'Indice'**
  String get calcMarketIndex;

  /// No description provided for @calcMarketFutures.
  ///
  /// In fr, this message translates to:
  /// **'Future'**
  String get calcMarketFutures;

  /// No description provided for @calcMarketStock.
  ///
  /// In fr, this message translates to:
  /// **'Action'**
  String get calcMarketStock;

  /// No description provided for @calcMarketCommodities.
  ///
  /// In fr, this message translates to:
  /// **'Matières premières'**
  String get calcMarketCommodities;

  /// No description provided for @calcWorstBalance.
  ///
  /// In fr, this message translates to:
  /// **'Pire solde'**
  String get calcWorstBalance;

  /// No description provided for @calculateRatio.
  ///
  /// In fr, this message translates to:
  /// **'Calculer le ratio'**
  String get calculateRatio;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @capitalAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant du capital'**
  String get capitalAmountLabel;

  /// No description provided for @capitalCurrencyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get capitalCurrencyTitle;

  /// No description provided for @capitalEllipsis.
  ///
  /// In fr, this message translates to:
  /// **'…'**
  String get capitalEllipsis;

  /// No description provided for @capitalHintAmount.
  ///
  /// In fr, this message translates to:
  /// **'ex. 10 450'**
  String get capitalHintAmount;

  /// No description provided for @capitalInitialTitle.
  ///
  /// In fr, this message translates to:
  /// **'Capital initial'**
  String get capitalInitialTitle;

  /// No description provided for @capitalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Capital'**
  String get capitalLabel;

  /// No description provided for @capitalOther.
  ///
  /// In fr, this message translates to:
  /// **'autre'**
  String get capitalOther;

  /// No description provided for @capitalTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Capital et devise (compte principal)'**
  String get capitalTooltip;

  /// No description provided for @checklistAddSection.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une section'**
  String get checklistAddSection;

  /// No description provided for @checklistDefaultNewSection.
  ///
  /// In fr, this message translates to:
  /// **'NOUVELLE SECTION'**
  String get checklistDefaultNewSection;

  /// No description provided for @checklistDeleteSectionBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est définitive pour cette section.'**
  String get checklistDeleteSectionBody;

  /// No description provided for @checklistDeleteSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la section ?'**
  String get checklistDeleteSectionTitle;

  /// No description provided for @checklistEditSectionHint.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get checklistEditSectionHint;

  /// No description provided for @checklistIntroBody.
  ///
  /// In fr, this message translates to:
  /// **'Avant de prendre position, assurez-vous de valider tous les critères de votre plan de trading.'**
  String get checklistIntroBody;

  /// No description provided for @checklistDailyCalendarTitle.
  ///
  /// In fr, this message translates to:
  /// **'CHECKLIST PAR JOUR'**
  String get checklistDailyCalendarTitle;

  /// No description provided for @checklistDailyUncheckedTitle.
  ///
  /// In fr, this message translates to:
  /// **'NON COCHÉS'**
  String get checklistDailyUncheckedTitle;

  /// No description provided for @checklistDailyUncheckedNoActivity.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité ce jour-là.'**
  String get checklistDailyUncheckedNoActivity;

  /// No description provided for @checklistDailyUncheckedNoDue.
  ///
  /// In fr, this message translates to:
  /// **'Aucun critère prévu ce jour-là.'**
  String get checklistDailyUncheckedNoDue;

  /// No description provided for @checklistDailyUncheckedAllDone.
  ///
  /// In fr, this message translates to:
  /// **'Tous les critères du jour sont cochés.'**
  String get checklistDailyUncheckedAllDone;

  /// No description provided for @checklistDailyUncheckedNoHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun détail checklist enregistré pour ce jour. Le suivi des critères non cochés est disponible à partir d’aujourd’hui.'**
  String get checklistDailyUncheckedNoHistory;

  /// No description provided for @checklistItemNews1.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier économique consulté (FED, CPI, NFP, PIB…).'**
  String get checklistItemNews1;

  /// No description provided for @checklistItemNews2.
  ///
  /// In fr, this message translates to:
  /// **'FOMC / FED : pas de trade pendant l’annonce.'**
  String get checklistItemNews2;

  /// No description provided for @checklistItemNews3.
  ///
  /// In fr, this message translates to:
  /// **'CPI (inflation) : horaire et impact anticipés.'**
  String get checklistItemNews3;

  /// No description provided for @checklistItemNews4.
  ///
  /// In fr, this message translates to:
  /// **'NFP (emplois US) : fenêtre à risque identifiée.'**
  String get checklistItemNews4;

  /// No description provided for @checklistItemAnalyse1.
  ///
  /// In fr, this message translates to:
  /// **'La tendance de fond (HTF) est alignée avec mon idée.'**
  String get checklistItemAnalyse1;

  /// No description provided for @checklistItemAnalyse2.
  ///
  /// In fr, this message translates to:
  /// **'Le prix est sur une zone clé (Support/Résistance, Order Block).'**
  String get checklistItemAnalyse2;

  /// No description provided for @checklistItemAnalyse3.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai une confirmation d\'entrée claire (Pattern, Divergence).'**
  String get checklistItemAnalyse3;

  /// No description provided for @checklistItemHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le critère'**
  String get checklistItemHint;

  /// No description provided for @checklistItemPsy1.
  ///
  /// In fr, this message translates to:
  /// **'Je trade dans un état d\'esprit neutre (pas de revanche).'**
  String get checklistItemPsy1;

  /// No description provided for @checklistItemPsy2.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte la perte potentielle avant d\'entrer.'**
  String get checklistItemPsy2;

  /// No description provided for @checklistItemPsy3.
  ///
  /// In fr, this message translates to:
  /// **'Je respecte mon plan même après une série de pertes.'**
  String get checklistItemPsy3;

  /// No description provided for @checklistItemRisque1.
  ///
  /// In fr, this message translates to:
  /// **'Mon Stop Loss est défini techniquement (pas au hasard).'**
  String get checklistItemRisque1;

  /// No description provided for @checklistItemRisque2.
  ///
  /// In fr, this message translates to:
  /// **'Le risque ne dépasse pas 1% de mon capital.'**
  String get checklistItemRisque2;

  /// No description provided for @checklistItemRisque3.
  ///
  /// In fr, this message translates to:
  /// **'Le Ratio Risk/Reward est d\'au moins 1:2.'**
  String get checklistItemRisque3;

  /// No description provided for @checklistMenuEdit.
  ///
  /// In fr, this message translates to:
  /// **'Éditer'**
  String get checklistMenuEdit;

  /// No description provided for @checklistSectionToggleOn.
  ///
  /// In fr, this message translates to:
  /// **'Activer la section'**
  String get checklistSectionToggleOn;

  /// No description provided for @checklistSectionToggleOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver la section'**
  String get checklistSectionToggleOff;

  /// No description provided for @checklistPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get checklistPageTitle;

  /// No description provided for @checklistProgressCl.
  ///
  /// In fr, this message translates to:
  /// **'CL'**
  String get checklistProgressCl;

  /// No description provided for @checklistSectionNews.
  ///
  /// In fr, this message translates to:
  /// **'NEWS · CALENDRIER ÉCONOMIQUE'**
  String get checklistSectionNews;

  /// No description provided for @checklistSectionAnalyse.
  ///
  /// In fr, this message translates to:
  /// **'ANALYSE TECHNIQUE'**
  String get checklistSectionAnalyse;

  /// No description provided for @checklistSectionPsy.
  ///
  /// In fr, this message translates to:
  /// **'PSYCHOLOGIE'**
  String get checklistSectionPsy;

  /// No description provided for @checklistSectionRisque.
  ///
  /// In fr, this message translates to:
  /// **'GESTION DU RISQUE'**
  String get checklistSectionRisque;

  /// No description provided for @checklistScheduleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappel de l’élément'**
  String get checklistScheduleTitle;

  /// No description provided for @checklistScheduleDefaultHeading.
  ///
  /// In fr, this message translates to:
  /// **'1 · Règle par défaut'**
  String get checklistScheduleDefaultHeading;

  /// No description provided for @checklistScheduleModeDaily.
  ///
  /// In fr, this message translates to:
  /// **'Tous les jours'**
  String get checklistScheduleModeDaily;

  /// No description provided for @checklistScheduleModeWeekly.
  ///
  /// In fr, this message translates to:
  /// **'1× / semaine'**
  String get checklistScheduleModeWeekly;

  /// No description provided for @checklistScheduleModeSpecificDate.
  ///
  /// In fr, this message translates to:
  /// **'Date précise'**
  String get checklistScheduleModeSpecificDate;

  /// No description provided for @checklistScheduleUserDateHeading.
  ///
  /// In fr, this message translates to:
  /// **'2 · Date choisie'**
  String get checklistScheduleUserDateHeading;

  /// No description provided for @checklistSchedulePickDate.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une date'**
  String get checklistSchedulePickDate;

  /// No description provided for @checklistScheduleWeekHeading.
  ///
  /// In fr, this message translates to:
  /// **'3 · Jour de la semaine'**
  String get checklistScheduleWeekHeading;

  /// No description provided for @checklistScheduleNextOccurrence.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine date : {date}'**
  String checklistScheduleNextOccurrence(String date);

  /// No description provided for @checklistScheduleWarningHeading.
  ///
  /// In fr, this message translates to:
  /// **'4 · Heure d’avertissement'**
  String get checklistScheduleWarningHeading;

  /// No description provided for @checklistSchedulePickTime.
  ///
  /// In fr, this message translates to:
  /// **'Choisir l’heure'**
  String get checklistSchedulePickTime;

  /// No description provided for @checklistScheduleCalendarTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Règlage date et rappel'**
  String get checklistScheduleCalendarTooltip;

  /// No description provided for @clearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get clearAll;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @currencyNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. CHF, XOF'**
  String get currencyNameHint;

  /// No description provided for @currencyNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la devise'**
  String get currencyNameLabel;

  /// No description provided for @customCurrencyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Autre devise'**
  String get customCurrencyTitle;

  /// No description provided for @dashboardAiAnalyze.
  ///
  /// In fr, this message translates to:
  /// **'Analyser'**
  String get dashboardAiAnalyze;

  /// No description provided for @dashboardAiCoachBody.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur « Analyser » pour que l\'IA étudie vos statistiques de la semaine (Winrate, Horaires, Facteurs) et génère un conseil psychologique sur-mesure.'**
  String get dashboardAiCoachBody;

  /// No description provided for @dashboardAiCoachTitle.
  ///
  /// In fr, this message translates to:
  /// **'COACH IA PAYCHEK'**
  String get dashboardAiCoachTitle;

  /// No description provided for @dashboardAnalyseShortcutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Analyse'**
  String get dashboardAnalyseShortcutTitle;

  /// No description provided for @dashboardBestTradeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur trade'**
  String get dashboardBestTradeLabel;

  /// No description provided for @dashboardCapitalBalanceHeader.
  ///
  /// In fr, this message translates to:
  /// **'CAPITAL / SOLDE'**
  String get dashboardCapitalBalanceHeader;

  /// No description provided for @dashboardCapitalEvolutionTitle.
  ///
  /// In fr, this message translates to:
  /// **'ÉVOLUTION DU CAPITAL'**
  String get dashboardCapitalEvolutionTitle;

  /// No description provided for @dashboardChecklistHeading.
  ///
  /// In fr, this message translates to:
  /// **'CHECKLIST'**
  String get dashboardChecklistHeading;

  /// No description provided for @dashboardChecklistSeeRest.
  ///
  /// In fr, this message translates to:
  /// **'Plus >'**
  String get dashboardChecklistSeeRest;

  /// No description provided for @dashboardChecklistAllDoneBravo.
  ///
  /// In fr, this message translates to:
  /// **'Bon trade.'**
  String get dashboardChecklistAllDoneBravo;

  /// No description provided for @dashboardMyStateSection.
  ///
  /// In fr, this message translates to:
  /// **'Mon état'**
  String get dashboardMyStateSection;

  /// No description provided for @dashboardOpenStrategyTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir Ma stratégie'**
  String get dashboardOpenStrategyTooltip;

  /// No description provided for @dashboardPerfHourWinRate.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% WR'**
  String dashboardPerfHourWinRate(int percent);

  /// No description provided for @dashboardPerfHoursRow1.
  ///
  /// In fr, this message translates to:
  /// **'09h00 - 11h30 (Début)'**
  String get dashboardPerfHoursRow1;

  /// No description provided for @dashboardPerfHoursRow2.
  ///
  /// In fr, this message translates to:
  /// **'14h30 - 16h30 (US Open)'**
  String get dashboardPerfHoursRow2;

  /// No description provided for @dashboardPerfHoursRow3.
  ///
  /// In fr, this message translates to:
  /// **'19h00 et + (Soir)'**
  String get dashboardPerfHoursRow3;

  /// No description provided for @dashboardPerfHoursTitle.
  ///
  /// In fr, this message translates to:
  /// **'HORAIRES DE PERFORMANCE'**
  String get dashboardPerfHoursTitle;

  /// No description provided for @dashboardRingState.
  ///
  /// In fr, this message translates to:
  /// **'ÉTAT'**
  String get dashboardRingState;

  /// No description provided for @dashboardRingWin.
  ///
  /// In fr, this message translates to:
  /// **'GAGNÉ'**
  String get dashboardRingWin;

  /// No description provided for @dashboardSuccessFactorSample.
  ///
  /// In fr, this message translates to:
  /// **'Sport avant session'**
  String get dashboardSuccessFactorSample;

  /// No description provided for @dashboardSuccessFactorsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez l\'impact de vos habitudes sur votre Winrate.'**
  String get dashboardSuccessFactorsSubtitle;

  /// No description provided for @dashboardSuccessFactorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'FACTEURS DE RÉUSSITE'**
  String get dashboardSuccessFactorsTitle;

  /// No description provided for @dashboardTfAll.
  ///
  /// In fr, this message translates to:
  /// **'TOUS'**
  String get dashboardTfAll;

  /// No description provided for @dashboardTfDay.
  ///
  /// In fr, this message translates to:
  /// **'1J'**
  String get dashboardTfDay;

  /// No description provided for @dashboardTfMonth.
  ///
  /// In fr, this message translates to:
  /// **'1M'**
  String get dashboardTfMonth;

  /// No description provided for @dashboardTfWeek.
  ///
  /// In fr, this message translates to:
  /// **'1S'**
  String get dashboardTfWeek;

  /// No description provided for @dashboardTradeCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} trades'**
  String dashboardTradeCount(int count);

  /// No description provided for @dashboardTradeOne.
  ///
  /// In fr, this message translates to:
  /// **'1 trade'**
  String get dashboardTradeOne;

  /// No description provided for @dashboardEvolutionTradesThisPeriod.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 trades cette période} =1{1 trade cette période} other{{count} trades cette période}}'**
  String dashboardEvolutionTradesThisPeriod(int count);

  /// No description provided for @dashboardEvolutionSparklineHoverOrigin.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture du cumul'**
  String get dashboardEvolutionSparklineHoverOrigin;

  /// No description provided for @dashboardEvolutionSparklineHoverNoTrade.
  ///
  /// In fr, this message translates to:
  /// **'Aucun trade à ce palier'**
  String get dashboardEvolutionSparklineHoverNoTrade;

  /// No description provided for @dashboardEvolutionSparklineHoverMore.
  ///
  /// In fr, this message translates to:
  /// **'+{count} autres'**
  String dashboardEvolutionSparklineHoverMore(int count);

  /// No description provided for @dashboardEvolutionSparklineTapHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyer pour ouvrir'**
  String get dashboardEvolutionSparklineTapHint;

  /// No description provided for @dashboardWeekResultPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Résultat : '**
  String get dashboardWeekResultPrefix;

  /// No description provided for @dashboardWeekThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'CETTE SEMAINE'**
  String get dashboardWeekThisWeek;

  /// No description provided for @dashboardWeekdayShortFri.
  ///
  /// In fr, this message translates to:
  /// **'VEN'**
  String get dashboardWeekdayShortFri;

  /// No description provided for @dashboardWeekdayShortMon.
  ///
  /// In fr, this message translates to:
  /// **'LUN'**
  String get dashboardWeekdayShortMon;

  /// No description provided for @dashboardWeekdayShortSat.
  ///
  /// In fr, this message translates to:
  /// **'SAM'**
  String get dashboardWeekdayShortSat;

  /// No description provided for @dashboardWeekdayShortSun.
  ///
  /// In fr, this message translates to:
  /// **'DIM'**
  String get dashboardWeekdayShortSun;

  /// No description provided for @dashboardWeekdayShortThu.
  ///
  /// In fr, this message translates to:
  /// **'JEU'**
  String get dashboardWeekdayShortThu;

  /// No description provided for @dashboardWeekdayShortTue.
  ///
  /// In fr, this message translates to:
  /// **'MAR'**
  String get dashboardWeekdayShortTue;

  /// No description provided for @dashboardWeekdayShortWed.
  ///
  /// In fr, this message translates to:
  /// **'MER'**
  String get dashboardWeekdayShortWed;

  /// No description provided for @dashboardWorstLossLabel.
  ///
  /// In fr, this message translates to:
  /// **'Plus grosse perte'**
  String get dashboardWorstLossLabel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @deletePortfolioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » ?'**
  String deletePortfolioTitle(String name);

  /// No description provided for @deleteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteTooltip;

  /// No description provided for @editPortfolioTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Modifier nom, capital, devise'**
  String get editPortfolioTooltip;

  /// No description provided for @errorAmount.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un montant valide (≥ 0).'**
  String get errorAmount;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant ou devise invalide.'**
  String get errorInvalidAmount;

  /// No description provided for @errorNameOrSymbol.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez au moins le nom ou le symbole.'**
  String get errorNameOrSymbol;

  /// No description provided for @exportPdfFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’exporter le PDF.'**
  String get exportPdfFailed;

  /// No description provided for @exportPdfFailedWithError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’exporter le PDF : {error}'**
  String exportPdfFailedWithError(String error);

  /// No description provided for @exportPdfUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Export PDF annulé ou indisponible.'**
  String get exportPdfUnavailable;

  /// No description provided for @homePerformance.
  ///
  /// In fr, this message translates to:
  /// **'Performance'**
  String get homePerformance;

  /// No description provided for @webHomeHeroSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue, voici votre performance hebdomadaire'**
  String get webHomeHeroSubtitle;

  /// No description provided for @webHomeHeroWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue, {fullName}'**
  String webHomeHeroWelcome(Object fullName);

  /// No description provided for @webHomeLiveTerminal.
  ///
  /// In fr, this message translates to:
  /// **'Terminal en direct'**
  String get webHomeLiveTerminal;

  /// No description provided for @webHomeWelcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour,'**
  String get webHomeWelcomeBack;

  /// No description provided for @webHomeUpgradeUnlockSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Débloquez les données institutionnelles en temps réel'**
  String get webHomeUpgradeUnlockSubtitle;

  /// No description provided for @webRailMenuHeading.
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get webRailMenuHeading;

  /// No description provided for @labelActif.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get labelActif;

  /// No description provided for @labelGain.
  ///
  /// In fr, this message translates to:
  /// **'Gain'**
  String get labelGain;

  /// No description provided for @labelLot.
  ///
  /// In fr, this message translates to:
  /// **'LOT'**
  String get labelLot;

  /// No description provided for @labelMarket.
  ///
  /// In fr, this message translates to:
  /// **'MARCHÉ'**
  String get labelMarket;

  /// No description provided for @labelPrice.
  ///
  /// In fr, this message translates to:
  /// **'PRIX'**
  String get labelPrice;

  /// No description provided for @labelRiskPct.
  ///
  /// In fr, this message translates to:
  /// **'RISQUE %'**
  String get labelRiskPct;

  /// No description provided for @labelSuggestedSize.
  ///
  /// In fr, this message translates to:
  /// **'TAILLE SUGGÉRÉE'**
  String get labelSuggestedSize;

  /// No description provided for @langChineseTraditional.
  ///
  /// In fr, this message translates to:
  /// **'中文 (繁體)'**
  String get langChineseTraditional;

  /// No description provided for @langEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get langFrench;

  /// No description provided for @langGerman.
  ///
  /// In fr, this message translates to:
  /// **'Allemand'**
  String get langGerman;

  /// No description provided for @langItalian.
  ///
  /// In fr, this message translates to:
  /// **'Italien'**
  String get langItalian;

  /// No description provided for @langKorean.
  ///
  /// In fr, this message translates to:
  /// **'한국어'**
  String get langKorean;

  /// No description provided for @langPortuguese.
  ///
  /// In fr, this message translates to:
  /// **'Português'**
  String get langPortuguese;

  /// No description provided for @langSpanish.
  ///
  /// In fr, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// No description provided for @languageDialogSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l’interface'**
  String get languageDialogSubtitle;

  /// No description provided for @languageDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get languageDialogTitle;

  /// No description provided for @languageSection.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageSection;

  /// No description provided for @onboardingLanguageContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get onboardingLanguageContinue;

  /// No description provided for @mentalBad.
  ///
  /// In fr, this message translates to:
  /// **'Mauvais'**
  String get mentalBad;

  /// No description provided for @mentalConfidence.
  ///
  /// In fr, this message translates to:
  /// **'Confiance'**
  String get mentalConfidence;

  /// No description provided for @mentalEmotionFieldLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'émotion (ex : Serein, Apeuré)'**
  String get mentalEmotionFieldLabel;

  /// No description provided for @mentalEmotional.
  ///
  /// In fr, this message translates to:
  /// **'Émotionnel'**
  String get mentalEmotional;

  /// No description provided for @mentalEnergy.
  ///
  /// In fr, this message translates to:
  /// **'Énergie'**
  String get mentalEnergy;

  /// No description provided for @mentalExcited.
  ///
  /// In fr, this message translates to:
  /// **'Excité(e)'**
  String get mentalExcited;

  /// No description provided for @mentalFocus.
  ///
  /// In fr, this message translates to:
  /// **'Focus'**
  String get mentalFocus;

  /// No description provided for @mentalFrustrated.
  ///
  /// In fr, this message translates to:
  /// **'Frustré(e)'**
  String get mentalFrustrated;

  /// No description provided for @mentalHappy.
  ///
  /// In fr, this message translates to:
  /// **'Content(e)'**
  String get mentalHappy;

  /// No description provided for @mentalHintEmotion.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Serein, Apeuré'**
  String get mentalHintEmotion;

  /// No description provided for @mentalHintMetric.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Patience, Stress'**
  String get mentalHintMetric;

  /// No description provided for @mentalHintRoutine.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Sport, Lecture'**
  String get mentalHintRoutine;

  /// No description provided for @mentalMarketStudy.
  ///
  /// In fr, this message translates to:
  /// **'Étude marché'**
  String get mentalMarketStudy;

  /// No description provided for @mentalMeditation.
  ///
  /// In fr, this message translates to:
  /// **'Méditation (10 min)'**
  String get mentalMeditation;

  /// No description provided for @mentalMetricFieldLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la métrique (ex : Patience, Stress)'**
  String get mentalMetricFieldLabel;

  /// No description provided for @mentalNegative.
  ///
  /// In fr, this message translates to:
  /// **'Négatif (-)'**
  String get mentalNegative;

  /// No description provided for @mentalNeutral.
  ///
  /// In fr, this message translates to:
  /// **'Neutre'**
  String get mentalNeutral;

  /// No description provided for @mentalNewEmotion.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle émotion'**
  String get mentalNewEmotion;

  /// No description provided for @mentalNewMetric.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle métrique'**
  String get mentalNewMetric;

  /// No description provided for @mentalNewRoutine.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle routine'**
  String get mentalNewRoutine;

  /// No description provided for @mentalPeakForm.
  ///
  /// In fr, this message translates to:
  /// **'En pleine forme'**
  String get mentalPeakForm;

  /// No description provided for @mentalPositive.
  ///
  /// In fr, this message translates to:
  /// **'Positif (+)'**
  String get mentalPositive;

  /// No description provided for @mentalRestTitle.
  ///
  /// In fr, this message translates to:
  /// **'REPOS'**
  String get mentalRestTitle;

  /// No description provided for @mentalRiskAppetite.
  ///
  /// In fr, this message translates to:
  /// **'Peur'**
  String get mentalRiskAppetite;

  /// No description provided for @mentalRoutineFieldLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la routine (ex : Sport, Lecture)'**
  String get mentalRoutineFieldLabel;

  /// No description provided for @mentalDayDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'CRITÈRES DU JOUR'**
  String get mentalDayDetailTitle;

  /// No description provided for @mentalDayDetailNoData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée enregistrée pour ce jour. Modifiez votre état mental pour l’enregistrer.'**
  String get mentalDayDetailNoData;

  /// No description provided for @mentalDayDetailGlobalScore.
  ///
  /// In fr, this message translates to:
  /// **'SCORE GLOBAL'**
  String get mentalDayDetailGlobalScore;

  /// No description provided for @mentalGlobalScoreCalendarTitle.
  ///
  /// In fr, this message translates to:
  /// **'SCORE GLOBAL PAR JOUR'**
  String get mentalGlobalScoreCalendarTitle;

  /// No description provided for @mentalCalendarDayStartDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get mentalCalendarDayStartDialogTitle;

  /// No description provided for @mentalCalendarDayWindowStartLabel.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get mentalCalendarDayWindowStartLabel;

  /// No description provided for @mentalCalendarDayWindowEndLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get mentalCalendarDayWindowEndLabel;

  /// No description provided for @mentalCalendarDayWindowSettingsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Plage 24 h'**
  String get mentalCalendarDayWindowSettingsTooltip;

  /// No description provided for @mentalCalendarDayWindowDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plage horaire du score'**
  String get mentalCalendarDayWindowDialogTitle;

  /// No description provided for @mentalCalendarDayEndDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fin de la plage'**
  String get mentalCalendarDayEndDialogTitle;

  /// No description provided for @mentalSleepEnough.
  ///
  /// In fr, this message translates to:
  /// **'Suffisamment dormi'**
  String get mentalSleepEnough;

  /// No description provided for @mentalSleepImpact.
  ///
  /// In fr, this message translates to:
  /// **'Impact : {percent} %'**
  String mentalSleepImpact(int percent);

  /// No description provided for @mentalSport.
  ///
  /// In fr, this message translates to:
  /// **'Sport / jogging'**
  String get mentalSport;

  /// No description provided for @mentalTired.
  ///
  /// In fr, this message translates to:
  /// **'Fatigué'**
  String get mentalTired;

  /// No description provided for @mentalWeightGlobalImpact.
  ///
  /// In fr, this message translates to:
  /// **'Impact global'**
  String get mentalWeightGlobalImpact;

  /// No description provided for @mentalWeightModalBlurb.
  ///
  /// In fr, this message translates to:
  /// **'Ajustez l\'importance de ce critère. Utilisez le multiplicateur ou définissez directement le pourcentage souhaité.'**
  String get mentalWeightModalBlurb;

  /// No description provided for @mentalWeightModalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Régler l\'impact'**
  String get mentalWeightModalTitle;

  /// No description provided for @mentalWeightNatureLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nature de l\'impact'**
  String get mentalWeightNatureLabel;

  /// No description provided for @mentalWeightPolarityHelpNegative.
  ///
  /// In fr, this message translates to:
  /// **'Une valeur élevée de ce critère DIMINUERA votre score global.'**
  String get mentalWeightPolarityHelpNegative;

  /// No description provided for @mentalWeightPolarityHelpPositive.
  ///
  /// In fr, this message translates to:
  /// **'Une valeur élevée de ce critère AUGMENTERA votre score global.'**
  String get mentalWeightPolarityHelpPositive;

  /// No description provided for @mentalPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'État mental'**
  String get mentalPageTitle;

  /// No description provided for @mentalPageIntro.
  ///
  /// In fr, this message translates to:
  /// **'Évaluez votre état mental. Personnalisez l\'impact (poids) de chaque critère selon votre profil.'**
  String get mentalPageIntro;

  /// No description provided for @mentalGaugeStateLabel.
  ///
  /// In fr, this message translates to:
  /// **'ÉTAT'**
  String get mentalGaugeStateLabel;

  /// No description provided for @mentalGaugeBasedOnIndicators.
  ///
  /// In fr, this message translates to:
  /// **'Basé sur {count} indicateurs'**
  String mentalGaugeBasedOnIndicators(int count);

  /// No description provided for @mentalGaugeStatusStable.
  ///
  /// In fr, this message translates to:
  /// **'Équilibre correct'**
  String get mentalGaugeStatusStable;

  /// No description provided for @mentalGaugeStatusFragile.
  ///
  /// In fr, this message translates to:
  /// **'À surveiller'**
  String get mentalGaugeStatusFragile;

  /// No description provided for @mentalSectionRoutinesHeading.
  ///
  /// In fr, this message translates to:
  /// **'MES ROUTINES'**
  String get mentalSectionRoutinesHeading;

  /// No description provided for @mentalSectionMomentHeading.
  ///
  /// In fr, this message translates to:
  /// **'ÉTAT DU MOMENT'**
  String get mentalSectionMomentHeading;

  /// No description provided for @mentalSectionEmotionHeading.
  ///
  /// In fr, this message translates to:
  /// **'ÉMOTIONS'**
  String get mentalSectionEmotionHeading;

  /// No description provided for @modelSavedSnackbar.
  ///
  /// In fr, this message translates to:
  /// **'Modèle « {name} » enregistré'**
  String modelSavedSnackbar(String name);

  /// No description provided for @navAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get navAdd;

  /// No description provided for @navCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get navCalendar;

  /// No description provided for @navDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navMore;

  /// No description provided for @navTrade.
  ///
  /// In fr, this message translates to:
  /// **'Trade'**
  String get navTrade;

  /// No description provided for @tradePageIntro.
  ///
  /// In fr, this message translates to:
  /// **'Journal, filtres et fiches trades.'**
  String get tradePageIntro;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @perf0Sub.
  ///
  /// In fr, this message translates to:
  /// **'Impact du stress et de la fatigue sur le Winrate'**
  String get perf0Sub;

  /// No description provided for @perf0Title.
  ///
  /// In fr, this message translates to:
  /// **'Psychologie : Émotions & sommeil'**
  String get perf0Title;

  /// No description provided for @perf1Sub.
  ///
  /// In fr, this message translates to:
  /// **'Analyse de la rentabilité (Lundi à Dimanche)'**
  String get perf1Sub;

  /// No description provided for @perf1Title.
  ///
  /// In fr, this message translates to:
  /// **'Jours de la semaine'**
  String get perf1Title;

  /// No description provided for @perf2Sub.
  ///
  /// In fr, this message translates to:
  /// **'Identifier vos heures les plus rentables'**
  String get perf2Sub;

  /// No description provided for @perf2Title.
  ///
  /// In fr, this message translates to:
  /// **'Horaires de session'**
  String get perf2Title;

  /// No description provided for @perf3Sub.
  ///
  /// In fr, this message translates to:
  /// **'Taux de réussite de cette figure graphique'**
  String get perf3Sub;

  /// No description provided for @perf3Title.
  ///
  /// In fr, this message translates to:
  /// **'Pattern : Double Top / Bottom'**
  String get perf3Title;

  /// No description provided for @perf4Sub.
  ///
  /// In fr, this message translates to:
  /// **'Analyse des retournements majeurs'**
  String get perf4Sub;

  /// No description provided for @perf4Title.
  ///
  /// In fr, this message translates to:
  /// **'Pattern : Épaule-Tête-Épaule'**
  String get perf4Title;

  /// No description provided for @perf5Sub.
  ///
  /// In fr, this message translates to:
  /// **'Validation des signaux de surachat/survente'**
  String get perf5Sub;

  /// No description provided for @perf5Title.
  ///
  /// In fr, this message translates to:
  /// **'Indicateur : RSI Divergence'**
  String get perf5Title;

  /// No description provided for @perf6Sub.
  ///
  /// In fr, this message translates to:
  /// **'Efficacité des croisements de moyennes'**
  String get perf6Sub;

  /// No description provided for @perf6Title.
  ///
  /// In fr, this message translates to:
  /// **'Indicateur : MACD Croisement'**
  String get perf6Title;

  /// No description provided for @perf7Sub.
  ///
  /// In fr, this message translates to:
  /// **'Rebonds sur les niveaux 0.618 et 0.5'**
  String get perf7Sub;

  /// No description provided for @perf7Title.
  ///
  /// In fr, this message translates to:
  /// **'Indicateur : Fibonacci Retracement'**
  String get perf7Title;

  /// No description provided for @perf8Sub.
  ///
  /// In fr, this message translates to:
  /// **'Analyse des Order Blocks et Liquidités'**
  String get perf8Sub;

  /// No description provided for @perf8Title.
  ///
  /// In fr, this message translates to:
  /// **'Stratégie : Smart Money Concept (SMC)'**
  String get perf8Title;

  /// No description provided for @perf9Sub.
  ///
  /// In fr, this message translates to:
  /// **'Impact du risque financier sur le Winrate'**
  String get perf9Sub;

  /// No description provided for @perf9Title.
  ///
  /// In fr, this message translates to:
  /// **'Volume & taille de lot'**
  String get perf9Title;

  /// No description provided for @perfAddWidgetButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le Widget'**
  String get perfAddWidgetButton;

  /// No description provided for @perfChartBar.
  ///
  /// In fr, this message translates to:
  /// **'Diagramme à barres'**
  String get perfChartBar;

  /// No description provided for @perfChartHBar.
  ///
  /// In fr, this message translates to:
  /// **'Barres horizontales'**
  String get perfChartHBar;

  /// No description provided for @perfChartHintBar.
  ///
  /// In fr, this message translates to:
  /// **'Idéal pour comparer (ex. jours)'**
  String get perfChartHintBar;

  /// No description provided for @perfChartHintHBar.
  ///
  /// In fr, this message translates to:
  /// **'Format liste, simple et épuré'**
  String get perfChartHintHBar;

  /// No description provided for @perfChartHintLine.
  ///
  /// In fr, this message translates to:
  /// **'Pour observer une évolution'**
  String get perfChartHintLine;

  /// No description provided for @perfChartHintPie.
  ///
  /// In fr, this message translates to:
  /// **'Pour un pourcentage global'**
  String get perfChartHintPie;

  /// No description provided for @perfChartLine.
  ///
  /// In fr, this message translates to:
  /// **'Courbe (ligne)'**
  String get perfChartLine;

  /// No description provided for @perfChartPie.
  ///
  /// In fr, this message translates to:
  /// **'Cercle / jauge'**
  String get perfChartPie;

  /// No description provided for @perfCustomizeIntro.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisez votre page Performance.'**
  String get perfCustomizeIntro;

  /// No description provided for @perfDataFootnoteDuration.
  ///
  /// In fr, this message translates to:
  /// **'Données : répartition par durée de position (CSV).'**
  String get perfDataFootnoteDuration;

  /// No description provided for @perfDataFootnoteVolume.
  ///
  /// In fr, this message translates to:
  /// **'Proxy volume : classes selon |profit| (CSV).'**
  String get perfDataFootnoteVolume;

  /// No description provided for @perfEmptyChart.
  ///
  /// In fr, this message translates to:
  /// **'Importez ou chargez des trades (CSV) pour afficher le graphique.'**
  String get perfEmptyChart;

  /// No description provided for @perfLineChartCaption.
  ///
  /// In fr, this message translates to:
  /// **'Courbe : profit cumulé (ordre chronologique, CSV).'**
  String get perfLineChartCaption;

  /// No description provided for @perfNewWidgetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Widget'**
  String get perfNewWidgetTitle;

  /// No description provided for @perfNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucune option trouvée.'**
  String get perfNoResults;

  /// No description provided for @perfPieChartCaption.
  ///
  /// In fr, this message translates to:
  /// **'Parts = volume de trades par catégorie ; % dans le disque = part du total.'**
  String get perfPieChartCaption;

  /// No description provided for @perfRemoveWidgetTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le widget'**
  String get perfRemoveWidgetTooltip;

  /// No description provided for @perfSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher (ex: Pattern, Psycho...)'**
  String get perfSearchHint;

  /// No description provided for @perfStep1Title.
  ///
  /// In fr, this message translates to:
  /// **'1. Que voulez-vous analyser ?'**
  String get perfStep1Title;

  /// No description provided for @perfStep2Title.
  ///
  /// In fr, this message translates to:
  /// **'2. Type de graphique'**
  String get perfStep2Title;

  /// No description provided for @plusAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get plusAdd;

  /// No description provided for @plusCalculator.
  ///
  /// In fr, this message translates to:
  /// **'Calculatrice'**
  String get plusCalculator;

  /// No description provided for @plusCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get plusCalendar;

  /// No description provided for @plusChecklist.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get plusChecklist;

  /// No description provided for @plusDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Dashboard'**
  String get plusDashboard;

  /// No description provided for @plusMentalState.
  ///
  /// In fr, this message translates to:
  /// **'État mental'**
  String get plusMentalState;

  /// No description provided for @plusMyAnalysis.
  ///
  /// In fr, this message translates to:
  /// **'Mon analyse'**
  String get plusMyAnalysis;

  /// No description provided for @plusMyStrategy.
  ///
  /// In fr, this message translates to:
  /// **'Ma stratégie'**
  String get plusMyStrategy;

  /// No description provided for @plusPerformance.
  ///
  /// In fr, this message translates to:
  /// **'Performance'**
  String get plusPerformance;

  /// No description provided for @plusSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get plusSettings;

  /// No description provided for @plusTrade.
  ///
  /// In fr, this message translates to:
  /// **'Trade'**
  String get plusTrade;

  /// No description provided for @paychekAccessDeniedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès restreint'**
  String get paychekAccessDeniedTitle;

  /// No description provided for @paychekAccessDeniedWeb.
  ///
  /// In fr, this message translates to:
  /// **'L’accès Paychek depuis le navigateur web a été désactivé pour ce compte. Contacte le support si besoin.'**
  String get paychekAccessDeniedWeb;

  /// No description provided for @paychekAccessDeniedMobile.
  ///
  /// In fr, this message translates to:
  /// **'L’accès depuis l’application mobile a été désactivé pour ce compte. Contacte le support si besoin.'**
  String get paychekAccessDeniedMobile;

  /// No description provided for @portfolioNameMissing.
  ///
  /// In fr, this message translates to:
  /// **'Donnez un nom au portefeuille (ex. broker).'**
  String get portfolioNameMissing;

  /// No description provided for @portfoliosLabel.
  ///
  /// In fr, this message translates to:
  /// **'Portfolios'**
  String get portfoliosLabel;

  /// No description provided for @q1Slogan.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre approche'**
  String get q1Slogan;

  /// No description provided for @q1Title.
  ///
  /// In fr, this message translates to:
  /// **'Quel type de trader ?'**
  String get q1Title;

  /// No description provided for @q1o1s.
  ///
  /// In fr, this message translates to:
  /// **'Positions de quelques secondes à quelques minutes'**
  String get q1o1s;

  /// No description provided for @q1o1t.
  ///
  /// In fr, this message translates to:
  /// **'Scalping'**
  String get q1o1t;

  /// No description provided for @q1o2s.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les positions sont fermées avant la fin de la séance'**
  String get q1o2s;

  /// No description provided for @q1o2t.
  ///
  /// In fr, this message translates to:
  /// **'Day trading'**
  String get q1o2t;

  /// No description provided for @q1o3s.
  ///
  /// In fr, this message translates to:
  /// **'Positions maintenues entre 1 et 3 jours'**
  String get q1o3s;

  /// No description provided for @q1o3t.
  ///
  /// In fr, this message translates to:
  /// **'Intraday'**
  String get q1o3t;

  /// No description provided for @q1o4s.
  ///
  /// In fr, this message translates to:
  /// **'Positions maintenues sur plusieurs jours ou semaines'**
  String get q1o4s;

  /// No description provided for @q1o4t.
  ///
  /// In fr, this message translates to:
  /// **'Swing'**
  String get q1o4t;

  /// No description provided for @q2Slogan.
  ///
  /// In fr, this message translates to:
  /// **'Où en es-tu dans ton parcours ?'**
  String get q2Slogan;

  /// No description provided for @q2Title.
  ///
  /// In fr, this message translates to:
  /// **'Profil d\'Expérience'**
  String get q2Title;

  /// No description provided for @q2o1s.
  ///
  /// In fr, this message translates to:
  /// **'Tu n\'es pas seul'**
  String get q2o1s;

  /// No description provided for @q2o1s2.
  ///
  /// In fr, this message translates to:
  /// **'Pour les traders qui débutent et cherchent encore leur méthode'**
  String get q2o1s2;

  /// No description provided for @q2o1t.
  ///
  /// In fr, this message translates to:
  /// **'Je n\'ai pas de stratégie'**
  String get q2o1t;

  /// No description provided for @q2o2s.
  ///
  /// In fr, this message translates to:
  /// **'La lumière au bout du tunnel'**
  String get q2o2s;

  /// No description provided for @q2o2s2.
  ///
  /// In fr, this message translates to:
  /// **'Pour ceux qui ont les bases mais cherchent la régularité'**
  String get q2o2s2;

  /// No description provided for @q2o2t.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai ma stratégie'**
  String get q2o2t;

  /// No description provided for @q2o3s.
  ///
  /// In fr, this message translates to:
  /// **'Le plus dur est derrière toi'**
  String get q2o3s;

  /// No description provided for @q2o3s2.
  ///
  /// In fr, this message translates to:
  /// **'Pour les traders expérimentés qui maîtrisent leur statistique'**
  String get q2o3s2;

  /// No description provided for @q2o3t.
  ///
  /// In fr, this message translates to:
  /// **'Performant'**
  String get q2o3t;

  /// No description provided for @q3Slogan.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton objectif prioritaire'**
  String get q3Slogan;

  /// No description provided for @q3Title.
  ///
  /// In fr, this message translates to:
  /// **'Que veux-tu améliorer ?'**
  String get q3Title;

  /// No description provided for @q3o1s.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter de gagner un jour pour tout perdre le lendemain.'**
  String get q3o1s;

  /// No description provided for @q3o1s2.
  ///
  /// In fr, this message translates to:
  /// **'Pour stabiliser sa courbe de capital et éviter l\'ascenseur émotionnel.'**
  String get q3o1s2;

  /// No description provided for @q3o1t.
  ///
  /// In fr, this message translates to:
  /// **'SORTIR DES MONTAGNES RUSSES'**
  String get q3o1t;

  /// No description provided for @q3o2s.
  ///
  /// In fr, this message translates to:
  /// **'Améliorer mon taux de réussite et la précision de mes entrées.'**
  String get q3o2s;

  /// No description provided for @q3o2s2.
  ///
  /// In fr, this message translates to:
  /// **'Pour ceux qui veulent gagner plus souvent en sélectionnant mieux leurs trades.'**
  String get q3o2s2;

  /// No description provided for @q3o2t.
  ///
  /// In fr, this message translates to:
  /// **'DEVENIR UN SNIPER'**
  String get q3o2t;

  /// No description provided for @q3o3s.
  ///
  /// In fr, this message translates to:
  /// **'Maîtriser ma discipline et stopper les décisions sous le coup de l\'émotion.'**
  String get q3o3s;

  /// No description provided for @q3o3s2.
  ///
  /// In fr, this message translates to:
  /// **'Pour éliminer le trading impulsif et respecter son plan à 100%.'**
  String get q3o3s2;

  /// No description provided for @q3o3t.
  ///
  /// In fr, this message translates to:
  /// **'RESTER DE MARBRE'**
  String get q3o3t;

  /// No description provided for @q3o4s.
  ///
  /// In fr, this message translates to:
  /// **'Comprendre les schémas graphiques qui fonctionnent réellement pour moi.'**
  String get q3o4s;

  /// No description provided for @q3o4s2.
  ///
  /// In fr, this message translates to:
  /// **'Pour identifier ses propres modèles de réussite et devenir un spécialiste.'**
  String get q3o4s2;

  /// No description provided for @q3o4t.
  ///
  /// In fr, this message translates to:
  /// **'TROUVER MA SIGNATURE'**
  String get q3o4t;

  /// No description provided for @q4Slogan.
  ///
  /// In fr, this message translates to:
  /// **'Identifie ce qui te bloque le plus'**
  String get q4Slogan;

  /// No description provided for @q4Title.
  ///
  /// In fr, this message translates to:
  /// **'Quel est ton plus grand défi ?'**
  String get q4Title;

  /// No description provided for @q4o1s.
  ///
  /// In fr, this message translates to:
  /// **'Peur de rater quelque chose.'**
  String get q4o1s;

  /// No description provided for @q4o1s2.
  ///
  /// In fr, this message translates to:
  /// **'Vite, je vais rater l\'occasion de gagner !'**
  String get q4o1s2;

  /// No description provided for @q4o1t.
  ///
  /// In fr, this message translates to:
  /// **'FOMO'**
  String get q4o1t;

  /// No description provided for @q4o2s.
  ///
  /// In fr, this message translates to:
  /// **'Ton cœur a remplacé ton cerveau.'**
  String get q4o2s;

  /// No description provided for @q4o2s2.
  ///
  /// In fr, this message translates to:
  /// **'C\'est pas possible, je DOIS récupérer mon argent !'**
  String get q4o2s2;

  /// No description provided for @q4o2t.
  ///
  /// In fr, this message translates to:
  /// **'TILT'**
  String get q4o2t;

  /// No description provided for @q4o3s.
  ///
  /// In fr, this message translates to:
  /// **'Pas de stratégie claire ni de plan.'**
  String get q4o3s;

  /// No description provided for @q4o3s2.
  ///
  /// In fr, this message translates to:
  /// **'Je ne sais pas trop, mais je le sens bien… on tente le coup.'**
  String get q4o3s2;

  /// No description provided for @q4o3t.
  ///
  /// In fr, this message translates to:
  /// **'TRADER À L\'AVEUGLETTE'**
  String get q4o3t;

  /// No description provided for @q4o4s.
  ///
  /// In fr, this message translates to:
  /// **'L\'agitation permanente.'**
  String get q4o4s;

  /// No description provided for @q4o4s2.
  ///
  /// In fr, this message translates to:
  /// **'Si je ne clique pas, j\'ai l\'impression de ne pas travailler.'**
  String get q4o4s2;

  /// No description provided for @q4o4t.
  ///
  /// In fr, this message translates to:
  /// **'OVERTRADING'**
  String get q4o4t;

  /// No description provided for @q4o5s.
  ///
  /// In fr, this message translates to:
  /// **'Se croire invincible.'**
  String get q4o5s;

  /// No description provided for @q4o5s2.
  ///
  /// In fr, this message translates to:
  /// **'Je suis trop fort, c\'est de l\'argent facile ! Je mise le double.'**
  String get q4o5s2;

  /// No description provided for @q4o5t.
  ///
  /// In fr, this message translates to:
  /// **'EXCÈS DE CONFIANCE'**
  String get q4o5t;

  /// No description provided for @q4o6s.
  ///
  /// In fr, this message translates to:
  /// **'Peur de tout.'**
  String get q4o6s;

  /// No description provided for @q4o6s2.
  ///
  /// In fr, this message translates to:
  /// **'Je ne suis pas sûr, j\'ai peur de perdre encore.'**
  String get q4o6s2;

  /// No description provided for @q4o6t.
  ///
  /// In fr, this message translates to:
  /// **'LA PARALYSIE'**
  String get q4o6t;

  /// No description provided for @q4o7s.
  ///
  /// In fr, this message translates to:
  /// **'Jouer à la roulette russe.'**
  String get q4o7s;

  /// No description provided for @q4o7s2.
  ///
  /// In fr, this message translates to:
  /// **'Je mets tout sur ce trade, ça passe ou ça casse !'**
  String get q4o7s2;

  /// No description provided for @q4o7t.
  ///
  /// In fr, this message translates to:
  /// **'SANS MONEY MANAGEMENT'**
  String get q4o7t;

  /// No description provided for @reglagePortfolioSheetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Montant du capital et devise du compte'**
  String get reglagePortfolioSheetSubtitle;

  /// No description provided for @reglagePortfolioSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Capital et Portfolios'**
  String get reglagePortfolioSheetTitle;

  /// No description provided for @resultDontWorry.
  ///
  /// In fr, this message translates to:
  /// **'T\'inquiète'**
  String get resultDontWorry;

  /// No description provided for @resultHeaderSub.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas ton profil , c\'est juste un calcul , rien n\'est encore réel. Tout commence maintenant.'**
  String get resultHeaderSub;

  /// No description provided for @resultLabelGlobal.
  ///
  /// In fr, this message translates to:
  /// **'Global'**
  String get resultLabelGlobal;

  /// No description provided for @resultLabelProfil.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get resultLabelProfil;

  /// No description provided for @resultLabelPsychology.
  ///
  /// In fr, this message translates to:
  /// **'Psychologie'**
  String get resultLabelPsychology;

  /// No description provided for @resultLabelStrategy.
  ///
  /// In fr, this message translates to:
  /// **'Stratégie'**
  String get resultLabelStrategy;

  /// No description provided for @resultStatBullet1.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% des traders de ce niveau stagnent ou perdent par manque de rigueur mathématique.'**
  String resultStatBullet1(int percent);

  /// No description provided for @resultStatBullet2.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% des traders sont dans la même situation.'**
  String resultStatBullet2(int percent);

  /// No description provided for @resultStatBullet3.
  ///
  /// In fr, this message translates to:
  /// **'Un trader avec une bonne psychologie trade mieux qu\'un trader qui connaît 100 stratégies.'**
  String get resultStatBullet3;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @screenshot.
  ///
  /// In fr, this message translates to:
  /// **'SCREENSHOT'**
  String get screenshot;

  /// No description provided for @accountPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get accountPageTitle;

  /// No description provided for @mobileReconnectAfterLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tu es déconnecté'**
  String get mobileReconnectAfterLogoutTitle;

  /// No description provided for @mobileReconnectAfterLogoutBody.
  ///
  /// In fr, this message translates to:
  /// **'Reconnecte-toi pour retrouver ton profil cloud et ton abonnement. Tu peux aussi continuer sur cet appareil sans compte.'**
  String get mobileReconnectAfterLogoutBody;

  /// No description provided for @mobileReconnectContinueWithoutAccount.
  ///
  /// In fr, this message translates to:
  /// **'Continuer sans compte'**
  String get mobileReconnectContinueWithoutAccount;

  /// No description provided for @profileViewDetailsSection.
  ///
  /// In fr, this message translates to:
  /// **'Détails du profil'**
  String get profileViewDetailsSection;

  /// No description provided for @profileAccountStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statut du compte'**
  String get profileAccountStatusTitle;

  /// No description provided for @profileAccountStatusPro.
  ///
  /// In fr, this message translates to:
  /// **'Pro'**
  String get profileAccountStatusPro;

  /// No description provided for @profileAccountStatusLite.
  ///
  /// In fr, this message translates to:
  /// **'Lite'**
  String get profileAccountStatusLite;

  /// No description provided for @profileTrialBadge.
  ///
  /// In fr, this message translates to:
  /// **'ESSAI'**
  String get profileTrialBadge;

  /// No description provided for @profileTrialDaysLeft.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 jour restant (essai)} other{{count} jours restants (essai)}}'**
  String profileTrialDaysLeft(int count);

  /// No description provided for @profileTrialEndsOn.
  ///
  /// In fr, this message translates to:
  /// **'Fin de l\'essai le {date}'**
  String profileTrialEndsOn(String date);

  /// No description provided for @profileTrialEndedOn.
  ///
  /// In fr, this message translates to:
  /// **'Essai terminé le {date}'**
  String profileTrialEndedOn(String date);

  /// No description provided for @profileProPeriodEndsOn.
  ///
  /// In fr, this message translates to:
  /// **'Renouvellement le {date}'**
  String profileProPeriodEndsOn(String date);

  /// No description provided for @profileSubscribeButton.
  ///
  /// In fr, this message translates to:
  /// **'Passer au Pro (dès 8,99 \$ / mois)'**
  String get profileSubscribeButton;

  /// No description provided for @profileManageSubscriptionButton.
  ///
  /// In fr, this message translates to:
  /// **'Gérer l\'abonnement'**
  String get profileManageSubscriptionButton;

  /// No description provided for @profileUpgradeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Upgrade'**
  String get profileUpgradeLabel;

  /// No description provided for @profileEditSavedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour'**
  String get profileEditSavedSnack;

  /// No description provided for @profileEditIncompleteFieldsSnack.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez le prénom, le nom et l’e-mail'**
  String get profileEditIncompleteFieldsSnack;

  /// No description provided for @profileEditInvalidEmailSnack.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez une adresse e-mail valide'**
  String get profileEditInvalidEmailSnack;

  /// No description provided for @accountChangePasswordButton.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le mot de passe'**
  String get accountChangePasswordButton;

  /// No description provided for @accountChangePasswordDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le mot de passe'**
  String get accountChangePasswordDialogTitle;

  /// No description provided for @accountChangePasswordCurrentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get accountChangePasswordCurrentLabel;

  /// No description provided for @accountChangePasswordNewLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get accountChangePasswordNewLabel;

  /// No description provided for @accountChangePasswordConfirmLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le nouveau mot de passe'**
  String get accountChangePasswordConfirmLabel;

  /// No description provided for @accountChangePasswordCta.
  ///
  /// In fr, this message translates to:
  /// **'ENREGISTRER'**
  String get accountChangePasswordCta;

  /// No description provided for @accountChangePasswordSuccessSnack.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe mis à jour'**
  String get accountChangePasswordSuccessSnack;

  /// No description provided for @accountChangePasswordCurrentMissing.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton mot de passe actuel'**
  String get accountChangePasswordCurrentMissing;

  /// No description provided for @accountChangePasswordRequiresRecentLogin.
  ///
  /// In fr, this message translates to:
  /// **'Pour des raisons de sécurité, reconnecte-toi puis réessaie.'**
  String get accountChangePasswordRequiresRecentLogin;

  /// No description provided for @accountChangePasswordForgotLink.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get accountChangePasswordForgotLink;

  /// No description provided for @accountAuthSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get accountAuthSectionTitle;

  /// No description provided for @accountContinueWith.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec :'**
  String get accountContinueWith;

  /// No description provided for @accountTabLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get accountTabLogin;

  /// No description provided for @accountTabSignup.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get accountTabSignup;

  /// No description provided for @accountFieldEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get accountFieldEmail;

  /// No description provided for @accountFieldPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get accountFieldPassword;

  /// No description provided for @accountFieldConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get accountFieldConfirmPassword;

  /// No description provided for @accountFieldBirthDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get accountFieldBirthDate;

  /// No description provided for @accountFieldFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get accountFieldFirstName;

  /// No description provided for @accountFieldLastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de famille'**
  String get accountFieldLastName;

  /// No description provided for @accountLoginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get accountLoginButton;

  /// No description provided for @accountSignupButton.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get accountSignupButton;

  /// No description provided for @authTerminalTagline.
  ///
  /// In fr, this message translates to:
  /// **'Maîtrise l\'esprit, maîtrise le trade'**
  String get authTerminalTagline;

  /// No description provided for @authTerminalCtaLogin.
  ///
  /// In fr, this message translates to:
  /// **'Lancer le terminal'**
  String get authTerminalCtaLogin;

  /// No description provided for @authTerminalCtaSignup.
  ///
  /// In fr, this message translates to:
  /// **'Créer ton identité'**
  String get authTerminalCtaSignup;

  /// No description provided for @webLandingLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour sur Paychek.'**
  String get webLandingLoginSubtitle;

  /// No description provided for @webLandingSignupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins l\'élite des traders.'**
  String get webLandingSignupSubtitle;

  /// No description provided for @webLandingLoginCta.
  ///
  /// In fr, this message translates to:
  /// **'SE CONNECTER'**
  String get webLandingLoginCta;

  /// No description provided for @webLandingSignupCta.
  ///
  /// In fr, this message translates to:
  /// **'ESSAYER GRATUITEMENT'**
  String get webLandingSignupCta;

  /// No description provided for @webLandingNoAccountLabel.
  ///
  /// In fr, this message translates to:
  /// **'PAS DE COMPTE ?'**
  String get webLandingNoAccountLabel;

  /// No description provided for @webLandingRegisterLink.
  ///
  /// In fr, this message translates to:
  /// **'S\'INSCRIRE'**
  String get webLandingRegisterLink;

  /// No description provided for @webLandingAlreadyMemberLabel.
  ///
  /// In fr, this message translates to:
  /// **'DÉJÀ MEMBRE ?'**
  String get webLandingAlreadyMemberLabel;

  /// No description provided for @webLandingLoginLink.
  ///
  /// In fr, this message translates to:
  /// **'CONNEXION'**
  String get webLandingLoginLink;

  /// No description provided for @authTerminalEncryptedPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Nœud chiffré :'**
  String get authTerminalEncryptedPrefix;

  /// No description provided for @authTerminalEncryptedStatus.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get authTerminalEncryptedStatus;

  /// No description provided for @authTerminalHintEmail.
  ///
  /// In fr, this message translates to:
  /// **'nom@terminal.com'**
  String get authTerminalHintEmail;

  /// No description provided for @authTerminalHintPassword.
  ///
  /// In fr, this message translates to:
  /// **'••••••••'**
  String get authTerminalHintPassword;

  /// No description provided for @accountLoginSnackEmailMissing.
  ///
  /// In fr, this message translates to:
  /// **'Connexion : saisir email'**
  String get accountLoginSnackEmailMissing;

  /// No description provided for @accountLoginSnackEmailReady.
  ///
  /// In fr, this message translates to:
  /// **'Connexion : email renseigné'**
  String get accountLoginSnackEmailReady;

  /// No description provided for @accountSignupSnackEmailMissing.
  ///
  /// In fr, this message translates to:
  /// **'Inscription : saisir email'**
  String get accountSignupSnackEmailMissing;

  /// No description provided for @accountSignupSnackFirstNameMissing.
  ///
  /// In fr, this message translates to:
  /// **'Inscription : saisir le prénom'**
  String get accountSignupSnackFirstNameMissing;

  /// No description provided for @accountSignupSnackLastNameMissing.
  ///
  /// In fr, this message translates to:
  /// **'Inscription : saisir le nom'**
  String get accountSignupSnackLastNameMissing;

  /// No description provided for @accountSignupSnackBirthDateMissing.
  ///
  /// In fr, this message translates to:
  /// **'Inscription : indiquer la date de naissance'**
  String get accountSignupSnackBirthDateMissing;

  /// No description provided for @accountSignupSnackReady.
  ///
  /// In fr, this message translates to:
  /// **'Inscription : formulaire prêt'**
  String get accountSignupSnackReady;

  /// No description provided for @accountSignupSnackPasswordMissing.
  ///
  /// In fr, this message translates to:
  /// **'Inscription : saisir le mot de passe'**
  String get accountSignupSnackPasswordMissing;

  /// No description provided for @accountSignupSnackPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Inscription : les mots de passe ne correspondent pas'**
  String get accountSignupSnackPasswordMismatch;

  /// No description provided for @accountSignupSnackPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 6 caractères'**
  String get accountSignupSnackPasswordTooShort;

  /// No description provided for @accountLoginSnackPasswordMissing.
  ///
  /// In fr, this message translates to:
  /// **'Connexion : saisir le mot de passe'**
  String get accountLoginSnackPasswordMissing;

  /// No description provided for @accountForgotPasswordLink.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get accountForgotPasswordLink;

  /// No description provided for @accountForgotPasswordSnackEmailMissing.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton adresse e-mail ci-dessus pour recevoir le lien.'**
  String get accountForgotPasswordSnackEmailMissing;

  /// No description provided for @accountForgotPasswordSnackSent.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe pour cet e-mail, tu recevras un lien pour en définir un nouveau.'**
  String get accountForgotPasswordSnackSent;

  /// No description provided for @accountForgotPasswordSnackTooManyRequests.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes. Réessaie dans quelques minutes.'**
  String get accountForgotPasswordSnackTooManyRequests;

  /// No description provided for @accountPasswordResetDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialisation du mot de passe'**
  String get accountPasswordResetDialogTitle;

  /// No description provided for @accountPasswordResetDialogSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisis l’e-mail de ton compte Paychek : tu recevras un lien pour en définir un nouveau.'**
  String get accountPasswordResetDialogSubtitle;

  /// No description provided for @accountPasswordResetCta.
  ///
  /// In fr, this message translates to:
  /// **'ENVOYER LE LIEN'**
  String get accountPasswordResetCta;

  /// No description provided for @accountPasswordResetBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'RETOUR À LA CONNEXION'**
  String get accountPasswordResetBackToLogin;

  /// No description provided for @accountPasswordResetSnackEmailMissing.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton adresse e-mail.'**
  String get accountPasswordResetSnackEmailMissing;

  /// No description provided for @accountPasswordResetSentDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifie ta boîte mail'**
  String get accountPasswordResetSentDialogTitle;

  /// No description provided for @accountPasswordResetSentDialogMessage.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe pour cette adresse, tu recevras un e-mail avec un lien pour choisir un nouveau mot de passe. Pense à regarder les courriers indésirables.'**
  String get accountPasswordResetSentDialogMessage;

  /// No description provided for @accountPasswordResetSentDialogCta.
  ///
  /// In fr, this message translates to:
  /// **'COMPRIS'**
  String get accountPasswordResetSentDialogCta;

  /// No description provided for @accountAuthSignupSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé'**
  String get accountAuthSignupSuccess;

  /// No description provided for @accountAuthLoginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie'**
  String get accountAuthLoginSuccess;

  /// No description provided for @accountAuthErrorWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop fragile'**
  String get accountAuthErrorWeakPassword;

  /// No description provided for @accountAuthErrorEmailInUse.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse e-mail est déjà utilisée'**
  String get accountAuthErrorEmailInUse;

  /// No description provided for @accountAuthErrorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide'**
  String get accountAuthErrorInvalidEmail;

  /// No description provided for @accountAuthErrorWrongCredentials.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect'**
  String get accountAuthErrorWrongCredentials;

  /// No description provided for @accountAuthErrorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Erreur réseau. Réessayez.'**
  String get accountAuthErrorNetwork;

  /// No description provided for @accountAuthErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite'**
  String get accountAuthErrorGeneric;

  /// No description provided for @accountAuthErrorRestartOrReload.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à l’authentification perdue. Arrête complètement l’app puis relance (sur le Web, évite le hot reload).'**
  String get accountAuthErrorRestartOrReload;

  /// No description provided for @accountAuthErrorDifferentSignInMethod.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse e-mail est déjà utilisée avec une autre méthode de connexion.'**
  String get accountAuthErrorDifferentSignInMethod;

  /// No description provided for @accountAuthErrorWithFirebaseCode.
  ///
  /// In fr, this message translates to:
  /// **'Un problème est survenu ({code}).'**
  String accountAuthErrorWithFirebaseCode(String code);

  /// No description provided for @accountAuthErrorUnknownFirebaseAuth.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible (erreur inconnue). Vérifie ta connexion, réessaie ou ouvre Paychek dans Chrome. Dans la console Firebase → Authentication, active E-mail / mot de passe et les fournisseurs que tu utilises.'**
  String get accountAuthErrorUnknownFirebaseAuth;

  /// No description provided for @accountAuthErrorSignInServerMessage.
  ///
  /// In fr, this message translates to:
  /// **'{message}'**
  String accountAuthErrorSignInServerMessage(String message);

  /// No description provided for @accountAuthWindowsSignInNotice.
  ///
  /// In fr, this message translates to:
  /// **'Sur l’application Windows, la connexion Firebase est souvent peu fiable (limitation connue Flutter / Firebase). Utilise l’app mobile Paychek ou connecte-toi depuis ton navigateur.'**
  String get accountAuthWindowsSignInNotice;

  /// No description provided for @accountAuthWindowsOpenWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir paychek.pro dans le navigateur'**
  String get accountAuthWindowsOpenWebsite;

  /// No description provided for @accountSocialAppleAndroidUseGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Apple non configurée sur Android dans cette version. Utilise Google ou l’e-mail, ou connecte-toi depuis le site web.'**
  String get accountSocialAppleAndroidUseGoogle;

  /// No description provided for @accountSocialAppleUnavailableDesktop.
  ///
  /// In fr, this message translates to:
  /// **'La connexion Apple n’est pas disponible dans l’app bureau Windows/Linux. Utilise l’app Web (Chrome), un iPhone, un iPad ou un Mac.'**
  String get accountSocialAppleUnavailableDesktop;

  /// No description provided for @accountSocialGoogleUnavailableDesktop.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Google indisponible sur cette cible (Windows/Linux). Utilise Chrome, Android ou iOS.'**
  String get accountSocialGoogleUnavailableDesktop;

  /// No description provided for @accountSocialFacebookUnavailableDesktop.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Facebook indisponible dans l’app bureau Windows/Linux. Utilise l’app Web (Chrome), Android, iOS ou macOS.'**
  String get accountSocialFacebookUnavailableDesktop;

  /// No description provided for @accountSocialGoogleWebClientMissing.
  ///
  /// In fr, this message translates to:
  /// **'Pour Google sur téléphone ou tablette : renseigne l’ID client OAuth Web dans lib/reglage/social_auth_config.dart. Sur Android, ajoute l’empreinte SHA-1 de l’app dans Firebase (Paramètres du projet → ton appli Android).'**
  String get accountSocialGoogleWebClientMissing;

  /// No description provided for @paywallTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ta période d’essai est terminée'**
  String get paywallTitle;

  /// No description provided for @paywallHeadlineBefore.
  ///
  /// In fr, this message translates to:
  /// **'Ton essai gratuit '**
  String get paywallHeadlineBefore;

  /// No description provided for @paywallHeadlineAccent.
  ///
  /// In fr, this message translates to:
  /// **'est terminé'**
  String get paywallHeadlineAccent;

  /// No description provided for @paywallUpgradeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Passe à Pro pour débloquer tout ton potentiel de trading et garder ton avantage.'**
  String get paywallUpgradeSubtitle;

  /// No description provided for @paywallEndedOn.
  ///
  /// In fr, this message translates to:
  /// **'Essai terminé le {date}.'**
  String paywallEndedOn(String date);

  /// No description provided for @paywallCompareCurrentPlan.
  ///
  /// In fr, this message translates to:
  /// **'PLAN ACTUEL'**
  String get paywallCompareCurrentPlan;

  /// No description provided for @paywallCompareRecommended.
  ///
  /// In fr, this message translates to:
  /// **'RECOMMANDÉ'**
  String get paywallCompareRecommended;

  /// No description provided for @paywallPlanLiteName.
  ///
  /// In fr, this message translates to:
  /// **'Lite'**
  String get paywallPlanLiteName;

  /// No description provided for @paywallPlanProName.
  ///
  /// In fr, this message translates to:
  /// **'Pro'**
  String get paywallPlanProName;

  /// No description provided for @paywallLiteFeature1.
  ///
  /// In fr, this message translates to:
  /// **'30 Trades / mois'**
  String get paywallLiteFeature1;

  /// No description provided for @paywallLiteFeature2.
  ///
  /// In fr, this message translates to:
  /// **'Saisie manuelle uniquement'**
  String get paywallLiteFeature2;

  /// No description provided for @paywallLiteFeature3.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier standard'**
  String get paywallLiteFeature3;

  /// No description provided for @paywallProFeature1.
  ///
  /// In fr, this message translates to:
  /// **'Illimité'**
  String get paywallProFeature1;

  /// No description provided for @paywallProFeature2.
  ///
  /// In fr, this message translates to:
  /// **'Import CSV + saisie manuelle'**
  String get paywallProFeature2;

  /// No description provided for @paywallProFeature3.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier Pro'**
  String get paywallProFeature3;

  /// No description provided for @paywallProFeature4.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get paywallProFeature4;

  /// No description provided for @paywallProFeature5.
  ///
  /// In fr, this message translates to:
  /// **'Générateur d\'analyse'**
  String get paywallProFeature5;

  /// No description provided for @paywallProFeature6.
  ///
  /// In fr, this message translates to:
  /// **'Page Stratégie'**
  String get paywallProFeature6;

  /// No description provided for @paywallProFeature7.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques performance'**
  String get paywallProFeature7;

  /// No description provided for @paywallProFeature8.
  ///
  /// In fr, this message translates to:
  /// **'État mental'**
  String get paywallProFeature8;

  /// No description provided for @paywallProFeature9.
  ///
  /// In fr, this message translates to:
  /// **'Export PDF'**
  String get paywallProFeature9;

  /// No description provided for @paywallMobilePlanAnnualTitle.
  ///
  /// In fr, this message translates to:
  /// **'1 An (12 Mois)'**
  String get paywallMobilePlanAnnualTitle;

  /// No description provided for @paywallMobilePlanQuarterlyTitle.
  ///
  /// In fr, this message translates to:
  /// **'3 Mois'**
  String get paywallMobilePlanQuarterlyTitle;

  /// No description provided for @paywallMobilePlanMonthlyTitle.
  ///
  /// In fr, this message translates to:
  /// **'1 Mois'**
  String get paywallMobilePlanMonthlyTitle;

  /// No description provided for @paywallMobilePlanPerMonthLine.
  ///
  /// In fr, this message translates to:
  /// **'Soit {price} \$ US / mois'**
  String paywallMobilePlanPerMonthLine(String price);

  /// No description provided for @paywallMobilePlanPerMonthPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Soit '**
  String get paywallMobilePlanPerMonthPrefix;

  /// No description provided for @paywallMobilePlanPerMonthPriceSuffix.
  ///
  /// In fr, this message translates to:
  /// **' \$ US'**
  String get paywallMobilePlanPerMonthPriceSuffix;

  /// No description provided for @paywallMobilePlanPerMonthEnd.
  ///
  /// In fr, this message translates to:
  /// **' / mois'**
  String get paywallMobilePlanPerMonthEnd;

  /// No description provided for @paywallMobilePlanTotalLine.
  ///
  /// In fr, this message translates to:
  /// **'{total} \$'**
  String paywallMobilePlanTotalLine(String total);

  /// No description provided for @paywallMobilePlanAnnualBilling.
  ///
  /// In fr, this message translates to:
  /// **'Facturé à l\'année'**
  String get paywallMobilePlanAnnualBilling;

  /// No description provided for @paywallMobilePlanQuarterlyBilling.
  ///
  /// In fr, this message translates to:
  /// **'Tous les 3 mois'**
  String get paywallMobilePlanQuarterlyBilling;

  /// No description provided for @paywallMobilePlanMonthlyBilling.
  ///
  /// In fr, this message translates to:
  /// **'Facturé au mois'**
  String get paywallMobilePlanMonthlyBilling;

  /// No description provided for @paywallMobilePlanMonthlyCommitment.
  ///
  /// In fr, this message translates to:
  /// **'Engagement mensuel'**
  String get paywallMobilePlanMonthlyCommitment;

  /// No description provided for @paywallMobilePlanSavings44.
  ///
  /// In fr, this message translates to:
  /// **'Économisez 44%'**
  String get paywallMobilePlanSavings44;

  /// No description provided for @paywallMobilePlanPopular.
  ///
  /// In fr, this message translates to:
  /// **'Populaire'**
  String get paywallMobilePlanPopular;

  /// No description provided for @paywallMobileCompareFeatureCol.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité'**
  String get paywallMobileCompareFeatureCol;

  /// No description provided for @paywallMobileRowTrades.
  ///
  /// In fr, this message translates to:
  /// **'Trades / mois'**
  String get paywallMobileRowTrades;

  /// No description provided for @paywallMobileRowEntry.
  ///
  /// In fr, this message translates to:
  /// **'Saisie des données'**
  String get paywallMobileRowEntry;

  /// No description provided for @paywallMobileRowCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get paywallMobileRowCalendar;

  /// No description provided for @paywallMobileRowChecklist.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get paywallMobileRowChecklist;

  /// No description provided for @paywallMobileRowAnalysis.
  ///
  /// In fr, this message translates to:
  /// **'Générateur d\'analyse'**
  String get paywallMobileRowAnalysis;

  /// No description provided for @paywallMobileRowStrategy.
  ///
  /// In fr, this message translates to:
  /// **'Page Stratégie'**
  String get paywallMobileRowStrategy;

  /// No description provided for @paywallMobileRowStats.
  ///
  /// In fr, this message translates to:
  /// **'Stats de performance'**
  String get paywallMobileRowStats;

  /// No description provided for @paywallMobileRowMental.
  ///
  /// In fr, this message translates to:
  /// **'État mental'**
  String get paywallMobileRowMental;

  /// No description provided for @paywallMobileRowExport.
  ///
  /// In fr, this message translates to:
  /// **'Export PDF'**
  String get paywallMobileRowExport;

  /// No description provided for @paywallPriceAnnualHighlight.
  ///
  /// In fr, this message translates to:
  /// **'59,99 \$ US / an'**
  String get paywallPriceAnnualHighlight;

  /// No description provided for @paywallPriceApproxPerMonth.
  ///
  /// In fr, this message translates to:
  /// **'Soit environ 4,99 \$ US / mois'**
  String get paywallPriceApproxPerMonth;

  /// No description provided for @paywallTrialEndedBody.
  ///
  /// In fr, this message translates to:
  /// **'Ton essai gratuit de 7 jours (nouvelle inscription) s’est terminé le {date}. Sans abonnement Pro, tu passes en version Lite.'**
  String paywallTrialEndedBody(String date);

  /// No description provided for @paywallLiteLimitedHint.
  ///
  /// In fr, this message translates to:
  /// **'En Lite, seuls l’ajout d’un trade et le calendrier restent disponibles. Le reste est réservé aux abonnés Pro.'**
  String get paywallLiteLimitedHint;

  /// No description provided for @paywallContinueFreemium.
  ///
  /// In fr, this message translates to:
  /// **'Continuer en Lite (accès limité)'**
  String get paywallContinueFreemium;

  /// No description provided for @paywallSubscribeButton.
  ///
  /// In fr, this message translates to:
  /// **'S’abonner maintenant'**
  String get paywallSubscribeButton;

  /// No description provided for @paywallRestoreButton.
  ///
  /// In fr, this message translates to:
  /// **'J’ai déjà un abonnement'**
  String get paywallRestoreButton;

  /// No description provided for @paywallStoreNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Lien Stripe introuvable. Console admin → Config → URL Payment Link (https://…), interrupteur activé, puis réessaie (compte connecté).'**
  String get paywallStoreNotConfigured;

  /// No description provided for @paywallRestoreNothingFound.
  ///
  /// In fr, this message translates to:
  /// **'Toujours bloqué : aucun abonnement détecté. Termine l’achat ou réessaie.'**
  String get paywallRestoreNothingFound;

  /// No description provided for @paywallLegalFooter.
  ///
  /// In fr, this message translates to:
  /// **'Paiement sécurisé par Stripe • Annulable à tout moment • Conditions d’utilisation'**
  String get paywallLegalFooter;

  /// No description provided for @paywallGoldPremiumPill.
  ///
  /// In fr, this message translates to:
  /// **'Accès Premium'**
  String get paywallGoldPremiumPill;

  /// No description provided for @paywallGoldMarketingHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Upgrade vers PRO'**
  String get paywallGoldMarketingHeadline;

  /// No description provided for @paywallGoldTagline.
  ///
  /// In fr, this message translates to:
  /// **'L’outil des traders rentables.'**
  String get paywallGoldTagline;

  /// No description provided for @paywallGoldYourPlanLabel.
  ///
  /// In fr, this message translates to:
  /// **'Actuel'**
  String get paywallGoldYourPlanLabel;

  /// No description provided for @paywallGoldLiteColumnCaption.
  ///
  /// In fr, this message translates to:
  /// **'Standard'**
  String get paywallGoldLiteColumnCaption;

  /// No description provided for @paywallGoldProColumnCaption.
  ///
  /// In fr, this message translates to:
  /// **'Illimité'**
  String get paywallGoldProColumnCaption;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsSupportSection.
  ///
  /// In fr, this message translates to:
  /// **'Aide et support'**
  String get settingsSupportSection;

  /// No description provided for @settingsSupportCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Support & retours'**
  String get settingsSupportCardTitle;

  /// No description provided for @settingsSupportCardSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nous écrire et consulter les guides.'**
  String get settingsSupportCardSubtitle;

  /// No description provided for @supportFeedbackTitleLead.
  ///
  /// In fr, this message translates to:
  /// **'Support & '**
  String get supportFeedbackTitleLead;

  /// No description provided for @supportFeedbackTitleAccent.
  ///
  /// In fr, this message translates to:
  /// **'Feedback'**
  String get supportFeedbackTitleAccent;

  /// No description provided for @supportFeedbackSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Une question ou une idée ? Nous sommes à ton écoute.'**
  String get supportFeedbackSubtitle;

  /// No description provided for @supportActionEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get supportActionEmailLabel;

  /// No description provided for @supportActionEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'Réponse sous 24 h'**
  String get supportActionEmailHint;

  /// No description provided for @supportActionDocsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Docs'**
  String get supportActionDocsLabel;

  /// No description provided for @supportActionDocsHint.
  ///
  /// In fr, this message translates to:
  /// **'Guides d’utilisation'**
  String get supportActionDocsHint;

  /// No description provided for @supportActionTwitterLabel.
  ///
  /// In fr, this message translates to:
  /// **'X'**
  String get supportActionTwitterLabel;

  /// No description provided for @supportActionTwitterHint.
  ///
  /// In fr, this message translates to:
  /// **'Communauté'**
  String get supportActionTwitterHint;

  /// No description provided for @supportFormNewMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau message'**
  String get supportFormNewMessage;

  /// No description provided for @supportFormKindLabel.
  ///
  /// In fr, this message translates to:
  /// **'Type de demande'**
  String get supportFormKindLabel;

  /// No description provided for @supportFormKindAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get supportFormKindAccount;

  /// No description provided for @supportFormKindBilling.
  ///
  /// In fr, this message translates to:
  /// **'Facturation'**
  String get supportFormKindBilling;

  /// No description provided for @supportFormKindFeature.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité'**
  String get supportFormKindFeature;

  /// No description provided for @supportFormKindOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get supportFormKindOther;

  /// No description provided for @supportFormEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre e-mail'**
  String get supportFormEmailLabel;

  /// No description provided for @supportFormEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'nom@exemple.com'**
  String get supportFormEmailHint;

  /// No description provided for @supportFormDescriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get supportFormDescriptionLabel;

  /// No description provided for @supportFormDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Détails du message…'**
  String get supportFormDescriptionHint;

  /// No description provided for @supportFormSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer maintenant'**
  String get supportFormSubmit;

  /// No description provided for @supportFormSubmitSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Merci — votre message a bien été envoyé.'**
  String get supportFormSubmitSuccess;

  /// No description provided for @supportFormSubmitSuccessPartial.
  ///
  /// In fr, this message translates to:
  /// **'Merci — votre message a bien été envoyé (pièce jointe non envoyée).'**
  String get supportFormSubmitSuccessPartial;

  /// No description provided for @supportFormSubmitDone.
  ///
  /// In fr, this message translates to:
  /// **'Si ton application mail ne s’est pas ouverte, réessaie ou écris-nous directement.'**
  String get supportFormSubmitDone;

  /// No description provided for @supportFormErrorEmail.
  ///
  /// In fr, this message translates to:
  /// **'Indique une adresse e-mail.'**
  String get supportFormErrorEmail;

  /// No description provided for @supportFormErrorDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute une description.'**
  String get supportFormErrorDescription;

  /// No description provided for @supportFormMailSubjectPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Paychek support'**
  String get supportFormMailSubjectPrefix;

  /// No description provided for @supportFormMailBodyIntro.
  ///
  /// In fr, this message translates to:
  /// **'Message envoyé depuis l’application Paychek :'**
  String get supportFormMailBodyIntro;

  /// No description provided for @supportFormAttachmentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pièce jointe (facultatif)'**
  String get supportFormAttachmentLabel;

  /// No description provided for @supportFormAttachmentPick.
  ///
  /// In fr, this message translates to:
  /// **'Photo ou PDF'**
  String get supportFormAttachmentPick;

  /// No description provided for @supportFormAttachmentHint.
  ///
  /// In fr, this message translates to:
  /// **'PDF ou image — max 10 Mo'**
  String get supportFormAttachmentHint;

  /// No description provided for @supportFormAttachmentRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le fichier'**
  String get supportFormAttachmentRemove;

  /// No description provided for @supportFormAttachmentSignInHint.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi pour joindre un fichier, ou utilise la carte E-mail sans pièce jointe.'**
  String get supportFormAttachmentSignInHint;

  /// No description provided for @supportFormAttachmentTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier dépasse 10 Mo.'**
  String get supportFormAttachmentTooLarge;

  /// No description provided for @supportFormAttachmentInvalidExtension.
  ///
  /// In fr, this message translates to:
  /// **'Formats acceptés : PDF, JPG, PNG, WebP.'**
  String get supportFormAttachmentInvalidExtension;

  /// No description provided for @supportFormAttachmentReadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire ce fichier. Réessaie.'**
  String get supportFormAttachmentReadFailed;

  /// No description provided for @supportFormSubmitFirestoreDone.
  ///
  /// In fr, this message translates to:
  /// **'Merci — ta demande est enregistrée. L’équipe peut la consulter avec la pièce jointe dans le back-office.'**
  String get supportFormSubmitFirestoreDone;

  /// No description provided for @supportFormSubmitSending.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours…'**
  String get supportFormSubmitSending;

  /// No description provided for @supportFormSubmitError.
  ///
  /// In fr, this message translates to:
  /// **'Envoi impossible. Vérifie la connexion puis réessaie.'**
  String get supportFormSubmitError;

  /// No description provided for @supportErrorEmailOpenFailed.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture e-mail impossible : {error}'**
  String supportErrorEmailOpenFailed(String error);

  /// No description provided for @supportErrorEmailAppUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'app e-mail. Vérifie qu\'une messagerie est installée.'**
  String get supportErrorEmailAppUnavailable;

  /// No description provided for @supportFormSubmitSavedPartialAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Ton message est enregistré, mais la pièce jointe n’a pas été envoyée (réseau, délai dépassé ou Storage non activé dans Firebase). Vérifie la console projet ou réessaie plus tard.'**
  String get supportFormSubmitSavedPartialAttachment;

  /// No description provided for @supportQuickHelpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide rapide'**
  String get supportQuickHelpTitle;

  /// No description provided for @supportFaqWhereDataQ.
  ///
  /// In fr, this message translates to:
  /// **'Où sont mes données ?'**
  String get supportFaqWhereDataQ;

  /// No description provided for @supportFaqWhereDataA.
  ///
  /// In fr, this message translates to:
  /// **'Tes données sont stockées sur cet appareil (préférences, journal, portfolios) et synchronisées avec ton compte si tu es connecté. Pour des archives, exporte en PDF depuis l’app. La déconnexion ne supprime pas le cloud : reconnecte-toi pour retrouver tes données.'**
  String get supportFaqWhereDataA;

  /// No description provided for @supportFaqFeatureQ.
  ///
  /// In fr, this message translates to:
  /// **'Besoin d’une nouvelle fonctionnalité ?'**
  String get supportFaqFeatureQ;

  /// No description provided for @supportFaqFeatureA.
  ///
  /// In fr, this message translates to:
  /// **'Décrit ce que tu souhaites dans le formulaire ci-dessous (catégorie « Proposer une idée »). Nous lisons tous les messages.'**
  String get supportFaqFeatureA;

  /// No description provided for @supportStatusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statut technique'**
  String get supportStatusLabel;

  /// No description provided for @supportStatusOperational.
  ///
  /// In fr, this message translates to:
  /// **'Services opérationnels'**
  String get supportStatusOperational;

  /// No description provided for @helpCenterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Centre d’aide'**
  String get helpCenterTitle;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Réponses rapides et explications pour utiliser l’app.'**
  String get helpCenterSubtitle;

  /// No description provided for @helpCenterSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher…'**
  String get helpCenterSearchHint;

  /// No description provided for @helpCenterVersionMobile.
  ///
  /// In fr, this message translates to:
  /// **'Version mobile'**
  String get helpCenterVersionMobile;

  /// No description provided for @helpCenterVersionWeb.
  ///
  /// In fr, this message translates to:
  /// **'Version Web'**
  String get helpCenterVersionWeb;

  /// No description provided for @helpCenterEmptyResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat.'**
  String get helpCenterEmptyResults;

  /// No description provided for @helpCenterArticleAddTradeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un trade'**
  String get helpCenterArticleAddTradeTitle;

  /// No description provided for @helpCenterArticleAddTradeBody.
  ///
  /// In fr, this message translates to:
  /// **'Va dans l’onglet Ajouter, remplis les champs (actif, entrée, stop, objectif…), puis enregistre. Tu peux joindre une capture si besoin.'**
  String get helpCenterArticleAddTradeBody;

  /// No description provided for @helpCenterArticleEditTradeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trade page'**
  String get helpCenterArticleEditTradeTitle;

  /// No description provided for @helpCenterArticleEditTradeBody.
  ///
  /// In fr, this message translates to:
  /// **'Guide : Maîtriser votre Journal de Trading (Page Trade)\nLa page Trade est le centre d\'archivage intelligent de Paychek. Elle ne se contente pas de lister vos opérations ; elle les organise pour vous offrir une vision claire de votre progression, du trade individuel à la performance mensuelle.\n\n[img:assets/help_center/trade_page_header_filters.png]\n\n1. Tableau de Bord de Période (Header)\nEn haut de votre journal, vous disposez d\'un résumé instantané de la période sélectionnée :\n\nProfit Net : Votre résultat financier net en dollars et son impact en pourcentage sur votre capital (ex: +1070,00\$ / +53,50%).\n\nLe Win Rate Ring : L\'anneau central affiche votre pourcentage de réussite global. C\'est l\'indicateur visuel immédiat de la santé de votre trading.\n\nCompteur de Trades : Le détail précis du nombre de positions Gagnantes (G), Perdantes (P) et à l\'équilibre (Br).\n\n2. Navigation et Filtres Temporels\nPersonnalisez votre vue selon votre besoin d\'analyse grâce aux sélecteurs rapides :\n\nSélecteur 1D / 1S / 1M / ALL : Basculez instantanément entre une vue journalière, hebdomadaire, mensuelle ou l\'historique complet.\n\nFiltres de statut : Isolez vos trades Gagnants, Perdants ou Breakeven d\'un seul clic pour étudier des comportements spécifiques.\n\nActifs les plus tradés : Visualisez rapidement vos statistiques sur vos instruments préférés (ex: XAUUSD, EURUSD).\n\n[img:assets/help_center/trade_page_period_pdf_report.png]\n\n3. Structure en Accordéons et Rapports PDF\nL\'interface utilise un système de \"replier/déplier\" pour une lecture fluide et des options d\'exportation à tous les niveaux :\n\nRapports de Période (Jour/Semaine/Mois) : Chaque bloc de date (ex: \"14 Mars\") affiche un résumé de la performance du jour.\n\nEn cliquant sur l\'icône PDF à côté de la date, vous téléchargez un rapport complet de cette période spécifique. Idéal pour vos bilans de fin de semaine ou de mois.\n\nRapports de Trade Individuel : Cliquez sur un trade pour le déplier et voir ses détails (Heures, Session, Entry/Exit).\n\nChaque trade possède son propre bouton PDF. Ce document génère une fiche technique pro avec votre graphique et vos scores de discipline.\n\n[img:assets/help_center/trade_page_rings_week_view.png]\n\n4. Analyse visuelle par Ring\nChaque ligne (journée ou trade) est accompagnée d\'un Ring (anneau) :\n\nPour une journée, le ring représente le Win Rate global du jour.\n\nCela vous permet d\'identifier en une seconde vos journées \"rouges\" ou \"vertes\" sans avoir à lire chaque ligne de trade.\n\n[img:assets/help_center/trade_page_options_menu.png]\n\n5. Options de Gestion et Correction (Les 3 points)\nParce qu\'une erreur de saisie peut arriver, Paychek vous donne un contrôle total sur vos archives. À côté de l\'icône PDF de chaque fiche trade, vous trouverez un menu \"Options\" (représenté par 3 points verticaux) :\n\nModifier le Trade : Vous permet de réouvrir le formulaire de saisie pour corriger un prix, changer l\'heure, ajouter un screenshot oublié ou ajuster vos scores de discipline.\n\nSupprimer le Trade : Efface définitivement l\'enregistrement de votre journal.\n\nAttention : La suppression d\'un trade mettra à jour instantanément vos statistiques globales, votre Win Rate et votre capital dans les pages Trade et Performance.'**
  String get helpCenterArticleEditTradeBody;

  /// No description provided for @helpCenterArticleChecklistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get helpCenterArticleChecklistTitle;

  /// No description provided for @helpCenterArticleChecklistBody.
  ///
  /// In fr, this message translates to:
  /// **'📋 Checklist\n\n[img:assets/help_center/checklist_routine_discipline.png]\n\n1. Comprendre le « Ring » de progression\nLe cercle coloré en haut de votre écran est votre indicateur de préparation au combat.\n\n- Progression en temps réel : chaque case cochée fait progresser le pourcentage.\n- Le « Ring » de votre checklist n’est pas seulement présent dans votre section Routine : il est aussi synchronisé en temps réel sur votre Dashboard principal.\n- Le Standard Or : nous recommandons de ne jamais ouvrir une position si votre « Ring » n’est pas à 100 %. Un trade pris avec une checklist incomplète est souvent un trade émotionnel.\n\n2. Personnaliser votre routine\nChaque trader est unique. Paychek vous permet de construire votre propre système de vérification.\n\n- Ajouter une section : utilisez le bouton « + Add a section » en bas de la page pour créer une nouvelle catégorie (ex. « Routine matinale », « News économiques », « Post-session »).\n- Gérer les éléments (menu trois points ⋯) :\n  - Ajouter une tâche : ouvrez le menu à droite du titre de section pour insérer un nouveau point de contrôle.\n  - Supprimer / modifier : si une règle ne correspond plus à votre stratégie, supprimez-la pour garder une interface propre.\n\n3. Les sections par défaut\nPour vous aider à démarrer, nous avons intégré les trois piliers du succès :\n\n- Technical Analysis : validez vos confluences (trend, S/R, indicateurs).\n- Risk Management : vérifiez que votre stop-loss est en place et que votre risque par trade est respecté.\n- Psychology : un check rapide pour vous assurer que vous n’êtes pas dans un état de revanche ou d’euphorie.'**
  String get helpCenterArticleChecklistBody;

  /// No description provided for @helpCenterArticleCalendarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get helpCenterArticleCalendarTitle;

  /// No description provided for @helpCenterArticleCalendarBody.
  ///
  /// In fr, this message translates to:
  /// **'📅 Guide : Calendrier & Analyse de Performance\n\nLe Calendrier Paychek est votre outil de pilotage principal. Il transforme vos données brutes en une carte visuelle de votre succès et de votre discipline.\n\n[img:assets/help_center/calendar_overview.png]\n\n1. Vue d\'ensemble du mois\nCode Couleur : Les cases Vertes indiquent un profit net, les Rouges une perte, et les Grises les jours sans activité.\n\nRésumé Rapide : En haut du calendrier, visualisez immédiatement votre Win Rate, le nombre de trades, et votre P&L Total du mois.\n\nObjectif Mensuel (Monthly Objective) : Suivez la barre de progression pour voir à quelle distance vous êtes de votre but financier. Cliquez sur l\'icône « réglages » pour modifier votre objectif.\n\n[img:assets/help_center/calendar_monthly_objective.png]\n\n2. Le Menu Déployable (Analyse Profonde)\nCliquez sur l\'en-tête de n\'importe quel mois pour ouvrir l\'analyse détaillée.\n\n[img:assets/help_center/calendar_deep_analysis.png]\n\nRings de Discipline : Visualisez vos scores moyens de rigueur sur le mois (Plan respecté, Checklist remplie, État mental).\n\nRépartition par Sessions : Analysez vos performances par fuseau horaire : Asia, Europe, et US. Idéal pour savoir quel moment de la journée est le plus rentable pour vous.\n\nSparkline Interactive (Courbe de performance) :\n- Survolez la ligne pour identifier un trade précis (sur mobile, faites-la défiler au doigt).\n- Cliquez sur un point de la courbe pour être redirigé instantanément vers la fiche complète de ce trade.\n\n3. Statistiques de Session (Sidebar)\nÀ droite de votre calendrier, retrouvez vos statistiques de régularité :\n\nPerformance Cumulative : L\'évolution de votre capital jour après jour.\n\nBest Day : Votre plus gros gain quotidien du mois.\n\nAverage Day : Ce que vous gagnez (ou perdez) en moyenne par jour.\n\n[img:assets/help_center/calendar_trades_month_report.png]\n\n4. Exportation PDF 📄\nEn haut à droite de la page Calendar, l\'icône PDF vous permet de générer un rapport professionnel en un clic.\n\nLe contenu : Le rapport inclut le calendrier visuel, la courbe de performance, et le récapitulatif de vos moyennes de discipline.'**
  String get helpCenterArticleCalendarBody;

  /// No description provided for @helpCenterArticleMentalStateTitle.
  ///
  /// In fr, this message translates to:
  /// **'État mental'**
  String get helpCenterArticleMentalStateTitle;

  /// No description provided for @helpCenterArticleMentalStateBody.
  ///
  /// In fr, this message translates to:
  /// **'Guide : État mental — Personnalisez votre psychologie\n\nVotre succès en trading dépend à 80 % de votre psychologie. La page État mental vous permet de mesurer votre état interne et de comprendre comment vos émotions influencent vos résultats.\n\n[img:assets/help_center/mental_state_dashboard.png]\n\n1. Le score global (The Ring)\nLe Ring central affiche votre « Solid Balance ». Ce score est le résultat dynamique de tous vos indicateurs (émotions, repos, routines). Plus le score est élevé, plus vous êtes dans une zone mentale propice au trading.\n\n2. Le système d\'impact personnalisé (engrenage ⚙️)\nChaque trader réagit différemment. Paychek vous permet de définir la « loi » de votre propre esprit :\n\n[img:assets/help_center/mental_state_adjust_impact.png]\n\n- Nature de l\'impact : ouvrez l\'engrenage d\'un critère pour définir s\'il est positif (+) ou négatif (−). Exemple : si pour vous l\'excitation est un danger, réglez-la sur « Négatif ».\n\n- Impact global (%) : le curseur définit l\'importance du critère sur votre score global. Si l\'énergie est cruciale pour vous, donnez-lui un poids élevé ; si un critère est secondaire, réduisez son pourcentage.\n\n3. Gestion des sections et émotions\n\n[img:assets/help_center/mental_state_section_controls.png]\n\n- Modifier / supprimer : icône crayon pour renommer une émotion ou un indicateur ; icône poubelle pour le supprimer.\n\n- Bouton d\'activation (ON / OFF 100 %) : vous pouvez désactiver une section entière (ex. « My Routines »). Si elle est désactivée, elle n\'est plus comptabilisée dans votre score global du jour.\n\n- Ajouter (+) : créez vos propres indicateurs pour coller à votre routine personnelle.\n\n4. Calendrier des scores et réglages horaires\nLe mini-calendrier affiche votre score mental pour chaque jour passé.\n\n- Réglage de la session (⚙️) : vous pouvez définir une heure de début et une heure de fin.\n\n- Mode journée : pour suivre votre état du matin au soir (fenêtre type journée).\n\n- Mode session : pour vous concentrer uniquement sur votre état mental durant vos heures de trading (ex. 15:30 – 22:00).'**
  String get helpCenterArticleMentalStateBody;

  /// No description provided for @helpCenterArticleExportPdfTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter un PDF'**
  String get helpCenterArticleExportPdfTitle;

  /// No description provided for @helpCenterArticleExportPdfBody.
  ///
  /// In fr, this message translates to:
  /// **'Depuis Trade ou Performance, utilise Exporter en PDF. En cas d’échec, vérifie les autorisations et réessaie.'**
  String get helpCenterArticleExportPdfBody;

  /// No description provided for @helpCenterArticleResetDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les données locales'**
  String get helpCenterArticleResetDataTitle;

  /// No description provided for @helpCenterArticleResetDataBody.
  ///
  /// In fr, this message translates to:
  /// **'Dans Réglages > Données, tu peux effacer les données stockées sur cet appareil. C’est irréversible ; un redémarrage de l’app est recommandé ensuite.'**
  String get helpCenterArticleResetDataBody;

  /// No description provided for @helpCenterArticleMyStrategyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ma stratégie — Playbook'**
  String get helpCenterArticleMyStrategyTitle;

  /// No description provided for @helpCenterArticleMyAnalysisTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon analyse — Plans de trading'**
  String get helpCenterArticleMyAnalysisTitle;

  /// No description provided for @helpCenterArticleMyAnalysisBody.
  ///
  /// In fr, this message translates to:
  /// **'🔬 Mon analyse : Préparez vos Plans de Trading\n\nLa page « Mon analyse » vous permet de construire une feuille de route complète avant d\'entrer sur le marché. En quantifiant chaque élément technique, Paychek calcule pour vous un indice de confiance global pour valider votre setup.\n\n[img:assets/help_center/analyse_trend_sheet.png]\n\n1. La Carte Trend (Tendance & Contexte)\nDéfinissez le cadre de votre opportunité :\n\nActif & Nom : Utilisez le bouton (+) pour nommer votre analyse et l\'actif concerné (ex : EUR/USD — Weekly Swing Plan).\n\nDirection & Phase : Choisissez votre biais (Achat, Vente ou À surveiller) et identifiez la phase actuelle du marché (Accumulation, Impulse, Distribution).\n\nSlider de Confiance : Ajustez votre niveau de certitude pour cette section. Grâce à l\'engrenage (⚙️), réglez l\'impact (poids %) de cette carte sur le score de confiance final du rapport.\n\n[img:assets/help_center/analyse_card_controls.png]\n\nPersonnalisation : Utilisez le crayon pour modifier les timeframes ou les phases disponibles, et le bouton dupliquer pour comparer plusieurs analyses sur différents timeframes dans la même section.\n\n2. Sections Techniques (Structure, SMC, Indicateurs, Volume)\nChaque trader a sa propre méthode. Activez ou désactivez les cartes selon vos besoins avec le bouton ON/OFF :\n\n[img:assets/help_center/analyse_technical_cards.png]\n\nStructure : Notez vos supports et résistances. Cochez si un niveau a été testé plus de 2 fois pour renforcer sa pertinence.\n\nSMC & Liquidité : Identifiez vos Order Blocks, Fair Value Gaps (FVG) et niveaux de Fibonacci.\n\nIndicateurs & Profil de Volume : Détaillez vos signaux RSI/MACD ou vos zones de Point of Control (POC).\n\nScreenshot : Importez une capture d\'écran de votre graphique pour illustrer visuellement votre plan.\n\n3. Génération du Rapport (The Report)\nUne fois votre analyse terminée, cliquez sur le bouton « Rapport ».\n\n[img:assets/help_center/analyse_summary_report.png]\n\nIndice de confiance global : Le cercle de confiance final est calculé automatiquement en fonction de vos différents sliders et de leurs impacts respectifs.\n\nCode couleur dynamique : Votre rapport s\'affiche en bas de page avec une couleur spécifique selon votre direction : vert (Achat), rouge (Vente) ou jaune (À surveiller).\n\n[img:assets/help_center/analyse_report_embedded.png]\n\n4. Gestion des Rapports\nHistorique : Vos rapports sont sauvegardés et liés à vos actifs.\n\nActions : Vous pouvez à tout moment modifier (crayon), supprimer (poubelle) ou générer un PDF professionnel de votre analyse pour l\'archiver ou le partager.\n\n[img:assets/help_center/analyse_report_pdf.png]'**
  String get helpCenterArticleMyAnalysisBody;

  /// No description provided for @helpCenterArticlePerformanceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Performance — Scanner de trading'**
  String get helpCenterArticlePerformanceTitle;

  /// No description provided for @settingsLogoutButton.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get settingsLogoutButton;

  /// No description provided for @settingsLogoutSnack.
  ///
  /// In fr, this message translates to:
  /// **'Tu es déconnecté.'**
  String get settingsLogoutSnack;

  /// No description provided for @settingsLogoutSnackPartial.
  ///
  /// In fr, this message translates to:
  /// **'Profil effacé sur l’appareil. Si ton compte apparaît encore, vérifie le réseau ou redémarre l’application.'**
  String get settingsLogoutSnackPartial;

  /// No description provided for @splashTagline.
  ///
  /// In fr, this message translates to:
  /// **'Maîtrise l\'esprit, maîtrise le trade'**
  String get splashTagline;

  /// No description provided for @statsAvgGain.
  ///
  /// In fr, this message translates to:
  /// **'Gain moyen'**
  String get statsAvgGain;

  /// No description provided for @statsPsychSub.
  ///
  /// In fr, this message translates to:
  /// **'Plan respecté'**
  String get statsPsychSub;

  /// No description provided for @statsPsychology.
  ///
  /// In fr, this message translates to:
  /// **'Psychologie'**
  String get statsPsychology;

  /// No description provided for @statsRR.
  ///
  /// In fr, this message translates to:
  /// **'Ratio R/R'**
  String get statsRR;

  /// No description provided for @statsSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'STATISTIQUES'**
  String get statsSectionTitle;

  /// No description provided for @statsStrategy.
  ///
  /// In fr, this message translates to:
  /// **'Stratégie'**
  String get statsStrategy;

  /// No description provided for @statsStrategySub.
  ///
  /// In fr, this message translates to:
  /// **'Critères validés'**
  String get statsStrategySub;

  /// No description provided for @strategieAlertSignal.
  ///
  /// In fr, this message translates to:
  /// **'SIGNAL D\'ALERTE'**
  String get strategieAlertSignal;

  /// No description provided for @strategieDescription.
  ///
  /// In fr, this message translates to:
  /// **'DESCRIPTION'**
  String get strategieDescription;

  /// No description provided for @strategieDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : faible volatilité'**
  String get strategieDescriptionHint;

  /// No description provided for @strategieEditSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la session'**
  String get strategieEditSessionTitle;

  /// No description provided for @strategieHintEntry.
  ///
  /// In fr, this message translates to:
  /// **'Où cliquer sur ACHAT/VENTE ?'**
  String get strategieHintEntry;

  /// No description provided for @strategieHintIndicatorTag.
  ///
  /// In fr, this message translates to:
  /// **'Ex : RSI'**
  String get strategieHintIndicatorTag;

  /// No description provided for @strategieHintInvalidation.
  ///
  /// In fr, this message translates to:
  /// **'Où le scénario est-il faux ?'**
  String get strategieHintInvalidation;

  /// No description provided for @strategieHintManagement.
  ///
  /// In fr, this message translates to:
  /// **'Comment sécuriser la position ?'**
  String get strategieHintManagement;

  /// No description provided for @strategieHintPattern.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Double Bottom'**
  String get strategieHintPattern;

  /// No description provided for @strategieHintSignal.
  ///
  /// In fr, this message translates to:
  /// **'Déclencheur…'**
  String get strategieHintSignal;

  /// No description provided for @strategieHintTarget.
  ///
  /// In fr, this message translates to:
  /// **'Cible finale ou zones de liquidité'**
  String get strategieHintTarget;

  /// No description provided for @strategieHintTimeframeTag.
  ///
  /// In fr, this message translates to:
  /// **'Ex : M15'**
  String get strategieHintTimeframeTag;

  /// No description provided for @strategieIndicators.
  ///
  /// In fr, this message translates to:
  /// **'INDICATEURS'**
  String get strategieIndicators;

  /// No description provided for @strategieModelName.
  ///
  /// In fr, this message translates to:
  /// **'NOM DU MODÈLE'**
  String get strategieModelName;

  /// No description provided for @strategieNewSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle session'**
  String get strategieNewSessionTitle;

  /// No description provided for @strategiePatternFigure.
  ///
  /// In fr, this message translates to:
  /// **'PATTERN / FIGURE'**
  String get strategiePatternFigure;

  /// No description provided for @strategieRuleEntryPrecise.
  ///
  /// In fr, this message translates to:
  /// **'ENTRÉE PRÉCISE'**
  String get strategieRuleEntryPrecise;

  /// No description provided for @strategieRuleInvalidation.
  ///
  /// In fr, this message translates to:
  /// **'INVALIDATION (STOP LOSS)'**
  String get strategieRuleInvalidation;

  /// No description provided for @strategieRuleManagement.
  ///
  /// In fr, this message translates to:
  /// **'GESTION (BREAKEVEN / PARTIELS)'**
  String get strategieRuleManagement;

  /// No description provided for @strategieRuleTarget.
  ///
  /// In fr, this message translates to:
  /// **'CIBLE (TAKE PROFIT)'**
  String get strategieRuleTarget;

  /// No description provided for @strategieSessionName.
  ///
  /// In fr, this message translates to:
  /// **'NOM DE LA SESSION'**
  String get strategieSessionName;

  /// No description provided for @strategieSetupColor.
  ///
  /// In fr, this message translates to:
  /// **'COULEUR'**
  String get strategieSetupColor;

  /// No description provided for @strategieSetupEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier setup'**
  String get strategieSetupEditTitle;

  /// No description provided for @strategieSetupNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau setup'**
  String get strategieSetupNewTitle;

  /// No description provided for @strategieTimeEndOptionalLabel.
  ///
  /// In fr, this message translates to:
  /// **'FIN (OPTIONNEL)'**
  String get strategieTimeEndOptionalLabel;

  /// No description provided for @strategieTimeStartLabel.
  ///
  /// In fr, this message translates to:
  /// **'DÉBUT'**
  String get strategieTimeStartLabel;

  /// No description provided for @strategieTimeframes.
  ///
  /// In fr, this message translates to:
  /// **'TIMEFRAMES'**
  String get strategieTimeframes;

  /// No description provided for @strategieZoneNoTrade.
  ///
  /// In fr, this message translates to:
  /// **'No trade'**
  String get strategieZoneNoTrade;

  /// No description provided for @strategieZoneTrade.
  ///
  /// In fr, this message translates to:
  /// **'Trade'**
  String get strategieZoneTrade;

  /// No description provided for @strategieZoneType.
  ///
  /// In fr, this message translates to:
  /// **'TYPE DE ZONE'**
  String get strategieZoneType;

  /// No description provided for @strategiePagePlaybookIntro.
  ///
  /// In fr, this message translates to:
  /// **'Votre plan de trading (Playbook). Relisez ces règles avant chaque session pour rester discipliné et concentré.'**
  String get strategiePagePlaybookIntro;

  /// No description provided for @analyseReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport'**
  String get analyseReportTitle;

  /// No description provided for @strategieGestionCaptionMaximum.
  ///
  /// In fr, this message translates to:
  /// **'Maximum'**
  String get strategieGestionCaptionMaximum;

  /// No description provided for @strategieGestionCaptionMinimum.
  ///
  /// In fr, this message translates to:
  /// **'Minimum'**
  String get strategieGestionCaptionMinimum;

  /// No description provided for @strategieSectionSetupsAndModels.
  ///
  /// In fr, this message translates to:
  /// **'SETUPS & MODÈLES'**
  String get strategieSectionSetupsAndModels;

  /// No description provided for @strategieSectionTradeCalendar.
  ///
  /// In fr, this message translates to:
  /// **'CALENDRIER DES TRADES'**
  String get strategieSectionTradeCalendar;

  /// No description provided for @strategieCalendarNeedSetupForUsage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un setup ci-dessus pour suivre vos jours d\'utilisation.'**
  String get strategieCalendarNeedSetupForUsage;

  /// No description provided for @strategieCalendarUsageForSetup.
  ///
  /// In fr, this message translates to:
  /// **'Usage — {name}'**
  String strategieCalendarUsageForSetup(String name);

  /// No description provided for @strategieCalendarUsageTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Marquer ou retirer ce jour pour ce setup (même nom que dans Ajouter trade).'**
  String get strategieCalendarUsageTooltip;

  /// No description provided for @strategieCalendarDotsExplain.
  ///
  /// In fr, this message translates to:
  /// **'Un point par stratégie utilisée ce jour, d’après vos trades (Ajouter trade, date d’entrée).'**
  String get strategieCalendarDotsExplain;

  /// No description provided for @strategieSetupNavPrevious.
  ///
  /// In fr, this message translates to:
  /// **'PRÉCÉDENT'**
  String get strategieSetupNavPrevious;

  /// No description provided for @strategieSetupNavNext.
  ///
  /// In fr, this message translates to:
  /// **'SETUP SUIVANT >'**
  String get strategieSetupNavNext;

  /// No description provided for @strategieSheetSetupsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Setups & modèles'**
  String get strategieSheetSetupsTitle;

  /// No description provided for @strategieMenuDisableFactors.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get strategieMenuDisableFactors;

  /// No description provided for @strategieManageTemplates.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les modèles'**
  String get strategieManageTemplates;

  /// No description provided for @strategieDuplicateSetup.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer un setup'**
  String get strategieDuplicateSetup;

  /// No description provided for @strategieMesReglesDraftHint.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle règle...'**
  String get strategieMesReglesDraftHint;

  /// No description provided for @strategieSetupRemoveFromDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de l\'accueil'**
  String get strategieSetupRemoveFromDashboard;

  /// No description provided for @strategieSetupShowOnDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Afficher sur l\'accueil'**
  String get strategieSetupShowOnDashboard;

  /// No description provided for @strategiePdfPlaybookBlurbShort.
  ///
  /// In fr, this message translates to:
  /// **'Votre plan de trading (Playbook). Relisez ces règles avant chaque session.'**
  String get strategiePdfPlaybookBlurbShort;

  /// No description provided for @strategiePdfFooterNote.
  ///
  /// In fr, this message translates to:
  /// **'Règles d\'or : textes de référence (non persistés). Gestion, horaires et setups : données enregistrées.'**
  String get strategiePdfFooterNote;

  /// No description provided for @strategiePdfTableSession.
  ///
  /// In fr, this message translates to:
  /// **'Session'**
  String get strategiePdfTableSession;

  /// No description provided for @strategiePdfTableDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get strategiePdfTableDescription;

  /// No description provided for @strategiePdfTableSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Horaires'**
  String get strategiePdfTableSchedule;

  /// No description provided for @strategiePdfTechnicalContext.
  ///
  /// In fr, this message translates to:
  /// **'Contexte technique'**
  String get strategiePdfTechnicalContext;

  /// No description provided for @strategiePdfAlertSignal.
  ///
  /// In fr, this message translates to:
  /// **'Signal d\'alerte'**
  String get strategiePdfAlertSignal;

  /// No description provided for @strategiePdfFileNamePrefix.
  ///
  /// In fr, this message translates to:
  /// **'ma_strategie'**
  String get strategiePdfFileNamePrefix;

  /// No description provided for @strategiePdfExportError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer le PDF : {error}'**
  String strategiePdfExportError(String error);

  /// No description provided for @symbolHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. Fr, ₣'**
  String get symbolHint;

  /// No description provided for @symbolLabel.
  ///
  /// In fr, this message translates to:
  /// **'Symbole'**
  String get symbolLabel;

  /// No description provided for @tradeColEndingBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde final'**
  String get tradeColEndingBalance;

  /// No description provided for @tradeColPnl.
  ///
  /// In fr, this message translates to:
  /// **'PnL'**
  String get tradeColPnl;

  /// No description provided for @tradeColResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat'**
  String get tradeColResult;

  /// No description provided for @tradeColStartingBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial'**
  String get tradeColStartingBalance;

  /// No description provided for @tradeColTotalGain.
  ///
  /// In fr, this message translates to:
  /// **'Gain total'**
  String get tradeColTotalGain;

  /// No description provided for @tradeColTotalGainPct.
  ///
  /// In fr, this message translates to:
  /// **'Gain total %'**
  String get tradeColTotalGainPct;

  /// No description provided for @tradeColTrade.
  ///
  /// In fr, this message translates to:
  /// **'Trade n°'**
  String get tradeColTrade;

  /// No description provided for @tradeDeleteConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est définitive.'**
  String get tradeDeleteConfirmBody;

  /// No description provided for @tradeDeleteConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce trade ?'**
  String get tradeDeleteConfirmTitle;

  /// No description provided for @tradeReturn.
  ///
  /// In fr, this message translates to:
  /// **'Trade return'**
  String get tradeReturn;

  /// No description provided for @tradeActionsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get tradeActionsTooltip;

  /// No description provided for @tradeAverageShort.
  ///
  /// In fr, this message translates to:
  /// **'MOYENNE'**
  String get tradeAverageShort;

  /// No description provided for @tradeDayTradeNumber.
  ///
  /// In fr, this message translates to:
  /// **'Trade n°{n} du jour'**
  String tradeDayTradeNumber(int n);

  /// No description provided for @tradeDurationHoursMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{hours}h {minutes}'**
  String tradeDurationHoursMinutes(int hours, String minutes);

  /// No description provided for @tradeDurationMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min'**
  String tradeDurationMinutes(int minutes);

  /// No description provided for @tradeEditMenu.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get tradeEditMenu;

  /// No description provided for @tradeLinkedAnalyseOpenPdf.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le PDF d’analyse'**
  String get tradeLinkedAnalyseOpenPdf;

  /// No description provided for @tradeExportPdfTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Exporter PDF'**
  String get tradeExportPdfTooltip;

  /// No description provided for @tradeFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get tradeFilterAll;

  /// No description provided for @tradeFilterBreakeven.
  ///
  /// In fr, this message translates to:
  /// **'Breakeven'**
  String get tradeFilterBreakeven;

  /// No description provided for @tradeFilterLoser.
  ///
  /// In fr, this message translates to:
  /// **'Perdant'**
  String get tradeFilterLoser;

  /// No description provided for @tradeFilterOpenPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position en cours'**
  String get tradeFilterOpenPosition;

  /// No description provided for @tradeFilterWinner.
  ///
  /// In fr, this message translates to:
  /// **'Gagnant'**
  String get tradeFilterWinner;

  /// No description provided for @tradeSummaryBreakdownShort.
  ///
  /// In fr, this message translates to:
  /// **'G:{w}  P:{l}  Br:{b}'**
  String tradeSummaryBreakdownShort(int w, int l, int b);

  /// No description provided for @tradeSummaryBreakdownWithOpen.
  ///
  /// In fr, this message translates to:
  /// **'G:{w}  P:{l}  Br:{b}  Ouv:{o}'**
  String tradeSummaryBreakdownWithOpen(int w, int l, int b, int o);

  /// No description provided for @tradeGainShort.
  ///
  /// In fr, this message translates to:
  /// **'GAIN'**
  String get tradeGainShort;

  /// No description provided for @tradeLabelChecklist.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get tradeLabelChecklist;

  /// No description provided for @tradeLabelDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get tradeLabelDuration;

  /// No description provided for @tradeLabelEntry.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get tradeLabelEntry;

  /// No description provided for @tradeLabelEtat.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get tradeLabelEtat;

  /// No description provided for @tradeLabelExit.
  ///
  /// In fr, this message translates to:
  /// **'Sortie'**
  String get tradeLabelExit;

  /// No description provided for @tradeLabelHours.
  ///
  /// In fr, this message translates to:
  /// **'Heures'**
  String get tradeLabelHours;

  /// No description provided for @tradeLabelPlan.
  ///
  /// In fr, this message translates to:
  /// **'Plan'**
  String get tradeLabelPlan;

  /// No description provided for @tradeLabelSession.
  ///
  /// In fr, this message translates to:
  /// **'Session'**
  String get tradeLabelSession;

  /// No description provided for @tradeLabelStrategie.
  ///
  /// In fr, this message translates to:
  /// **'Stratégie'**
  String get tradeLabelStrategie;

  /// No description provided for @tradeLabelNews.
  ///
  /// In fr, this message translates to:
  /// **'News'**
  String get tradeLabelNews;

  /// No description provided for @tradeMindsetFeeling.
  ///
  /// In fr, this message translates to:
  /// **'Feeling'**
  String get tradeMindsetFeeling;

  /// No description provided for @tradeMindsetPrinciple.
  ///
  /// In fr, this message translates to:
  /// **'Principe'**
  String get tradeMindsetPrinciple;

  /// No description provided for @tradeMindsetTalent.
  ///
  /// In fr, this message translates to:
  /// **'Talent'**
  String get tradeMindsetTalent;

  /// No description provided for @tradeMonthTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get tradeMonthTitle;

  /// No description provided for @tradeMostTradedHeading.
  ///
  /// In fr, this message translates to:
  /// **'Actifs les plus tradés'**
  String get tradeMostTradedHeading;

  /// No description provided for @tradeNotRespected.
  ///
  /// In fr, this message translates to:
  /// **'Non respecté'**
  String get tradeNotRespected;

  /// No description provided for @tradeOpenPositionLine.
  ///
  /// In fr, this message translates to:
  /// **'Position en cours • Entrée {when}'**
  String tradeOpenPositionLine(String when);

  /// No description provided for @tradePdfAnalysePostTrade.
  ///
  /// In fr, this message translates to:
  /// **'Analyse post-trade'**
  String get tradePdfAnalysePostTrade;

  /// No description provided for @tradePdfBarresSemaine.
  ///
  /// In fr, this message translates to:
  /// **'Barres (semaine)'**
  String get tradePdfBarresSemaine;

  /// No description provided for @tradePdfCloture.
  ///
  /// In fr, this message translates to:
  /// **'Clôture'**
  String get tradePdfCloture;

  /// No description provided for @tradePdfPositionOpen.
  ///
  /// In fr, this message translates to:
  /// **'Position en cours'**
  String get tradePdfPositionOpen;

  /// No description provided for @tradePdfDatePrefix.
  ///
  /// In fr, this message translates to:
  /// **'Date : {when}'**
  String tradePdfDatePrefix(String when);

  /// No description provided for @tradePdfDetailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détails du trade ({pair})'**
  String tradePdfDetailsTitle(String pair);

  /// No description provided for @tradePdfEtatPsychologique.
  ///
  /// In fr, this message translates to:
  /// **'État psychologique'**
  String get tradePdfEtatPsychologique;

  /// No description provided for @tradePdfTags.
  ///
  /// In fr, this message translates to:
  /// **'Tags'**
  String get tradePdfTags;

  /// No description provided for @tradeTagsSection.
  ///
  /// In fr, this message translates to:
  /// **'TAG'**
  String get tradeTagsSection;

  /// No description provided for @tradePdfExportDayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trades (jour)'**
  String get tradePdfExportDayTitle;

  /// No description provided for @tradePdfExportMonthTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trades (mois)'**
  String get tradePdfExportMonthTitle;

  /// No description provided for @tradePdfExportWeekTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trades (semaine)'**
  String get tradePdfExportWeekTitle;

  /// No description provided for @tradePdfGainNet.
  ///
  /// In fr, this message translates to:
  /// **'Gain net'**
  String get tradePdfGainNet;

  /// No description provided for @tradePdfImpactCapital.
  ///
  /// In fr, this message translates to:
  /// **'Impact capital'**
  String get tradePdfImpactCapital;

  /// No description provided for @tradePdfMoyenne.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get tradePdfMoyenne;

  /// No description provided for @tradePdfNonRespecte.
  ///
  /// In fr, this message translates to:
  /// **'Non respecté'**
  String get tradePdfNonRespecte;

  /// No description provided for @tradePdfPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get tradePdfPeriode;

  /// No description provided for @tradePdfQualiteMoyennes.
  ///
  /// In fr, this message translates to:
  /// **'Qualité (moyennes)'**
  String get tradePdfQualiteMoyennes;

  /// No description provided for @tradePdfScreenshotTitle.
  ///
  /// In fr, this message translates to:
  /// **'Capture — {pair}'**
  String tradePdfScreenshotTitle(String pair);

  /// No description provided for @tradePdfSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions'**
  String get tradePdfSessions;

  /// No description provided for @tradePdfSparklineMois.
  ///
  /// In fr, this message translates to:
  /// **'Courbe (mois)'**
  String get tradePdfSparklineMois;

  /// No description provided for @tradePdfTrades.
  ///
  /// In fr, this message translates to:
  /// **'Trades'**
  String get tradePdfTrades;

  /// No description provided for @tradePdfWinRate.
  ///
  /// In fr, this message translates to:
  /// **'Win rate'**
  String get tradePdfWinRate;

  /// No description provided for @tradePctOfCapital.
  ///
  /// In fr, this message translates to:
  /// **'{percent} % du capital'**
  String tradePctOfCapital(String percent);

  /// No description provided for @tradeScreenshotLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'afficher l\'image'**
  String get tradeScreenshotLoadError;

  /// No description provided for @tradeScreenshotUnavailableWeb.
  ///
  /// In fr, this message translates to:
  /// **'Capture indisponible (web)'**
  String get tradeScreenshotUnavailableWeb;

  /// No description provided for @tradeSectionChecklist.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get tradeSectionChecklist;

  /// No description provided for @tradeSectionEtat.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get tradeSectionEtat;

  /// No description provided for @tradeSectionPlan.
  ///
  /// In fr, this message translates to:
  /// **'Plan'**
  String get tradeSectionPlan;

  /// No description provided for @tradeSectionStrategie.
  ///
  /// In fr, this message translates to:
  /// **'Stratégie'**
  String get tradeSectionStrategie;

  /// No description provided for @tradeStrategieNonRespectUnmapped.
  ///
  /// In fr, this message translates to:
  /// **'Détail stratégie ({id})'**
  String tradeStrategieNonRespectUnmapped(String id);

  /// No description provided for @tradeSessionAsia.
  ///
  /// In fr, this message translates to:
  /// **'Asie'**
  String get tradeSessionAsia;

  /// No description provided for @tradeSessionEurope.
  ///
  /// In fr, this message translates to:
  /// **'Europe'**
  String get tradeSessionEurope;

  /// No description provided for @tradeSessionLate.
  ///
  /// In fr, this message translates to:
  /// **'Fin de journée'**
  String get tradeSessionLate;

  /// No description provided for @tradeSessionUs.
  ///
  /// In fr, this message translates to:
  /// **'US'**
  String get tradeSessionUs;

  /// No description provided for @tradeSideBreakevenShort.
  ///
  /// In fr, this message translates to:
  /// **'BREAKEVEN'**
  String get tradeSideBreakevenShort;

  /// No description provided for @tradeSideBuyLong.
  ///
  /// In fr, this message translates to:
  /// **'Achat'**
  String get tradeSideBuyLong;

  /// No description provided for @tradeSideBuyShort.
  ///
  /// In fr, this message translates to:
  /// **'ACHAT'**
  String get tradeSideBuyShort;

  /// No description provided for @tradeSideSellLong.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get tradeSideSellLong;

  /// No description provided for @tradeSideSellShort.
  ///
  /// In fr, this message translates to:
  /// **'VENTE'**
  String get tradeSideSellShort;

  /// No description provided for @tradeSummaryProfitNet.
  ///
  /// In fr, this message translates to:
  /// **'PROFIT NET'**
  String get tradeSummaryProfitNet;

  /// No description provided for @tradeSummaryTrades.
  ///
  /// In fr, this message translates to:
  /// **'TRADES'**
  String get tradeSummaryTrades;

  /// No description provided for @tradeSummaryWinRate.
  ///
  /// In fr, this message translates to:
  /// **'WIN RATE'**
  String get tradeSummaryWinRate;

  /// No description provided for @tradeTotalUpper.
  ///
  /// In fr, this message translates to:
  /// **'TOTAL'**
  String get tradeTotalUpper;

  /// No description provided for @tradeTradesListHeading.
  ///
  /// In fr, this message translates to:
  /// **'Trades'**
  String get tradeTradesListHeading;

  /// No description provided for @tradeTradesMonthHeading.
  ///
  /// In fr, this message translates to:
  /// **'Trades (mois)'**
  String get tradeTradesMonthHeading;

  /// No description provided for @tradeTradesWeekHeading.
  ///
  /// In fr, this message translates to:
  /// **'Trades (semaine)'**
  String get tradeTradesWeekHeading;

  /// No description provided for @tradeWeekTitle.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get tradeWeekTitle;

  /// No description provided for @tradeWinDayRingSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'WIN (jour)'**
  String get tradeWinDayRingSubtitle;

  /// No description provided for @tradeWinrateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Winrate'**
  String get tradeWinrateLabel;

  /// No description provided for @settingsTradingWeek5.
  ///
  /// In fr, this message translates to:
  /// **'5 jours (lun–ven)'**
  String get settingsTradingWeek5;

  /// No description provided for @settingsTradingWeek7.
  ///
  /// In fr, this message translates to:
  /// **'7 jours (lun–dim)'**
  String get settingsTradingWeek7;

  /// No description provided for @settingsTradingWeekSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'5 jours pour les marchés classiques (lun–ven), 7 jours pour une semaine complète (ex. crypto).'**
  String get settingsTradingWeekSubtitle;

  /// No description provided for @settingsTradingWeekTitle.
  ///
  /// In fr, this message translates to:
  /// **'Semaine affichée'**
  String get settingsTradingWeekTitle;

  /// No description provided for @settingsDashboardCardSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Personnaliser l’accueil : sections et ordre'**
  String get settingsDashboardCardSubtitle;

  /// No description provided for @settingsDashLayoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sections de l’accueil'**
  String get settingsDashLayoutTitle;

  /// No description provided for @settingsDashLayoutReorderHint.
  ///
  /// In fr, this message translates to:
  /// **'Glissez les poignées pour réorganiser. Désactivez une section pour la masquer sur l’accueil.'**
  String get settingsDashLayoutReorderHint;

  /// No description provided for @settingsDashOpenHomeButton.
  ///
  /// In fr, this message translates to:
  /// **'Voir l’accueil'**
  String get settingsDashOpenHomeButton;

  /// No description provided for @settingsDashSectionCapital.
  ///
  /// In fr, this message translates to:
  /// **'Capital et winrate'**
  String get settingsDashSectionCapital;

  /// No description provided for @settingsDashSectionChecklist.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get settingsDashSectionChecklist;

  /// No description provided for @settingsDashSectionAnalyse.
  ///
  /// In fr, this message translates to:
  /// **'Analyse'**
  String get settingsDashSectionAnalyse;

  /// No description provided for @settingsDashSectionEtat.
  ///
  /// In fr, this message translates to:
  /// **'État mental'**
  String get settingsDashSectionEtat;

  /// No description provided for @settingsDashSectionStrategie.
  ///
  /// In fr, this message translates to:
  /// **'Stratégie'**
  String get settingsDashSectionStrategie;

  /// No description provided for @settingsDashSectionWeekly.
  ///
  /// In fr, this message translates to:
  /// **'Performance hebdomadaire'**
  String get settingsDashSectionWeekly;

  /// No description provided for @settingsDashSectionEvolution.
  ///
  /// In fr, this message translates to:
  /// **'Évolution du capital'**
  String get settingsDashSectionEvolution;

  /// No description provided for @settingsDashSectionLens.
  ///
  /// In fr, this message translates to:
  /// **'Paychek Lens'**
  String get settingsDashSectionLens;

  /// No description provided for @tradingSection.
  ///
  /// In fr, this message translates to:
  /// **'Trading'**
  String get tradingSection;

  /// No description provided for @settingsCgvSection.
  ///
  /// In fr, this message translates to:
  /// **'CGV'**
  String get settingsCgvSection;

  /// No description provided for @settingsCgvPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions générales de vente'**
  String get settingsCgvPageTitle;

  /// No description provided for @settingsCgvRowTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions générales de vente'**
  String get settingsCgvRowTitle;

  /// No description provided for @settingsCgvRowSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Consulter le texte dans l’application'**
  String get settingsCgvRowSubtitle;

  /// No description provided for @settingsCgvDocHeading.
  ///
  /// In fr, this message translates to:
  /// **'CONDITIONS GÉNÉRALES DE VENTE (CGV) - PAYCHEK'**
  String get settingsCgvDocHeading;

  /// No description provided for @settingsCgv1Title.
  ///
  /// In fr, this message translates to:
  /// **'1. Objet'**
  String get settingsCgv1Title;

  /// No description provided for @settingsCgv1Body.
  ///
  /// In fr, this message translates to:
  /// **'Les présentes CGV régissent l\'abonnement donnant accès à l\'offre « Pro » (Premium) de l\'application Paychek, un outil de journal de trading et de gestion de risque. L\'accès est fourni par abonnement mensuel, trimestriel ou annuel, tacitement reconduit à chaque échéance jusqu\'à résiliation.'**
  String get settingsCgv1Body;

  /// No description provided for @settingsCgv2Title.
  ///
  /// In fr, this message translates to:
  /// **'2. Services Fournis'**
  String get settingsCgv2Title;

  /// No description provided for @settingsCgv2Body.
  ///
  /// In fr, this message translates to:
  /// **'L\'accès Premium débloque l\'intégralité des fonctionnalités de l\'application (Statistiques avancées, calcul automatique de risque, export de données). L\'accès est lié au compte utilisateur créé lors de l\'inscription.'**
  String get settingsCgv2Body;

  /// No description provided for @settingsCgv3Title.
  ///
  /// In fr, this message translates to:
  /// **'3. Tarifs et Paiement'**
  String get settingsCgv3Title;

  /// No description provided for @settingsCgv3Body.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement direct : les formules Pro sont facturées en dollars américains (US\$), via Stripe, avec renouvellement automatique jusqu\'à résiliation :\n• 8,99 \$ US / mois\n• 20,97 \$ US / 3 mois\n• 59,99 \$ US / an\n\nOffre Partenaire : L\'accès peut être offert gratuitement si l\'utilisateur remplit les conditions de parrainage auprès d\'un de nos partenaires (Prop Firm ou Broker).\n\nPaychek se réserve le droit de modifier ses prix à tout moment pour les nouveaux clients.'**
  String get settingsCgv3Body;

  /// No description provided for @settingsCgv4Title.
  ///
  /// In fr, this message translates to:
  /// **'4. Droit de Rétractation et Remboursement'**
  String get settingsCgv4Title;

  /// No description provided for @settingsCgv4Body.
  ///
  /// In fr, this message translates to:
  /// **'Conformément à la loi sur les produits numériques :\n\nEn raison de la nature numérique du service et de l\'accès immédiat au contenu dès le paiement, l\'utilisateur accepte que le service commence immédiatement et renonce expressément à son droit de rétractation de 14 jours.\n\nAucun remboursement ne sera effectué une fois l\'accès Premium activé, sauf en cas de défaut technique majeur rendant l\'application inutilisable.'**
  String get settingsCgv4Body;

  /// No description provided for @settingsCgv5Title.
  ///
  /// In fr, this message translates to:
  /// **'5. Clause Spécifique \"Offre Partenaire\"'**
  String get settingsCgv5Title;

  /// No description provided for @settingsCgv5Body.
  ///
  /// In fr, this message translates to:
  /// **'L\'accès offert via un partenaire est conditionné par la validation de l\'affiliation par ledit partenaire.\n\nSi le partenaire refuse l\'affiliation (pour non-respect des règles de dépôt ou de trade), Paychek se réserve le droit de révoquer l\'accès Premium ou de demander le paiement des tarifs Pro en vigueur.'**
  String get settingsCgv5Body;

  /// No description provided for @settingsCgv6Title.
  ///
  /// In fr, this message translates to:
  /// **'6. Avertissement sur les Risques (Trading)'**
  String get settingsCgv6Title;

  /// No description provided for @settingsCgv6Body.
  ///
  /// In fr, this message translates to:
  /// **'Paychek n\'est pas un conseiller financier. L\'application est un outil technique de gestion et d\'analyse.\n\nLe trading comporte des risques élevés de perte de capital. L\'utilisateur est seul responsable de ses décisions de trading.\n\nPaychek ne pourra être tenu responsable des pertes financières subies par l\'utilisateur sur les marchés financiers.'**
  String get settingsCgv6Body;

  /// No description provided for @settingsCgv7Title.
  ///
  /// In fr, this message translates to:
  /// **'7. Disponibilité du Service'**
  String get settingsCgv7Title;

  /// No description provided for @settingsCgv7Body.
  ///
  /// In fr, this message translates to:
  /// **'Paychek s\'efforce de maintenir l\'accès 24h/24. Toutefois, nous ne sommes pas responsables des interruptions dues à la maintenance ou aux pannes de serveurs tiers (Firebase, Google Cloud).'**
  String get settingsCgv7Body;

  /// No description provided for @settingsCgv8Title.
  ///
  /// In fr, this message translates to:
  /// **'8. Protection des Données'**
  String get settingsCgv8Title;

  /// No description provided for @settingsCgv8Body.
  ///
  /// In fr, this message translates to:
  /// **'Les données de trading des utilisateurs sont strictement confidentielles et ne sont jamais revendues. Elles sont stockées de manière sécurisée via nos prestataires techniques.'**
  String get settingsCgv8Body;

  /// No description provided for @settingsPrivacyRowTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get settingsPrivacyRowTitle;

  /// No description provided for @settingsPrivacyRowSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Données personnelles, cookies et vos droits'**
  String get settingsPrivacyRowSubtitle;

  /// No description provided for @settingsPrivacyPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get settingsPrivacyPageTitle;

  /// No description provided for @settingsPrivacyDocHeading.
  ///
  /// In fr, this message translates to:
  /// **'POLITIQUE DE CONFIDENTIALITÉ — PAYCHEK'**
  String get settingsPrivacyDocHeading;

  /// No description provided for @settingsDataResetSection.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get settingsDataResetSection;

  /// No description provided for @settingsDataResetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes les données locales'**
  String get settingsDataResetTitle;

  /// No description provided for @settingsDataResetDescription.
  ///
  /// In fr, this message translates to:
  /// **'Si tu as utilisé Paychek pendant un moment et que tu veux repartir à zéro (comme après une réinstallation), tu peux tout effacer sur cet appareil : trades, analyses, journal, mise en page du tableau de bord, profil local, ancrage d’essai sur l’appareil, etc.\n\nTa langue et le réglage « semaine affichée » sont conservés.\n\nPour être sûr que la mémoire temporaire se vide (checklist, etc.), ferme complètement l’application puis rouvre-la.'**
  String get settingsDataResetDescription;

  /// No description provided for @settingsDataResetButton.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer sur cet appareil'**
  String get settingsDataResetButton;

  /// No description provided for @settingsDataResetDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer toutes les données locales ?'**
  String get settingsDataResetDialogTitle;

  /// No description provided for @settingsDataResetDialogBody.
  ///
  /// In fr, this message translates to:
  /// **'Action irréversible. Les données Paychek stockées localement seront supprimées. Ta session Firebase peut rester connectée ; seules les copies locales sont effacées.\n\nRedémarrer l’app ensuite si quelque chose semble encore en cache.'**
  String get settingsDataResetDialogBody;

  /// No description provided for @settingsDataResetDialogCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get settingsDataResetDialogCancel;

  /// No description provided for @settingsDataResetDialogConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get settingsDataResetDialogConfirm;

  /// No description provided for @settingsDataResetSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Données locales effacées. Redémarrage de l’app recommandé.'**
  String get settingsDataResetSuccess;

  /// No description provided for @validate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// No description provided for @winrate.
  ///
  /// In fr, this message translates to:
  /// **'Winrate'**
  String get winrate;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ko',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
