// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actionAdd => 'Add';

  @override
  String get addPortfolio => 'Add portfolio';

  @override
  String get ajouterTradeCapitalRequiredHint =>
      'Set a capital (questionnaire) to enable calculation.';

  @override
  String get ajouterTradeCapitalGainEnterExitToShowPnl =>
      'Enter the exit price to show P&L.';

  @override
  String get ajouterTradeCapitalGainOpenPositionNote =>
      'Open position: estimated P&L will be shown when you close.';

  @override
  String get ajouterTradeCommissionFeesLabel => 'Fees (commission)';

  @override
  String get ajouterTradeFillSuggestedLot => 'Fill lot';

  @override
  String get ajouterTradeSizingEstimationFootnote =>
      '* Estimates use saved capital; contract/CFD figures are approximate.';

  @override
  String get ajouterTradeScreenshotHelp =>
      'Add a chart or setup screenshot (optional).';

  @override
  String get ajouterTradeCsvChooseSoftware => 'Choose software';

  @override
  String get ajouterTradePageTitle => 'Add trade';

  @override
  String get ajouterTradeErrorQtyPositive =>
      'Enter a position size greater than 0.';

  @override
  String get ajouterTradeErrorEntryPrice =>
      'Enter a valid entry price (greater than 0).';

  @override
  String get ajouterTradeErrorExitOrFlags =>
      'Enter a valid exit price, or check Breakeven / Open position if the exit is not known yet.';

  @override
  String get ajouterTradePsychTagBlind => 'Blind';

  @override
  String get ajouterTradeCapitalGainHeading => 'CAPITAL & GAIN';

  @override
  String get ajouterTradeMindsetPrompt => 'You took this trade with:';

  @override
  String get ajouterTradeDisciplineSettingsTooltip =>
      'Settings: Feeling and active sections.';

  @override
  String get ajouterTradeSaveAndNext => 'Save & next';

  @override
  String ajouterTradeLiteMonthlyLimitReached(int max) {
    return 'Lite: you can record up to $max trades per calendar month. Upgrade to Pro for unlimited entries.';
  }

  @override
  String ajouterTradeLiteMonthlyLimitImportSkipped(int skipped, int max) {
    return '$skipped trade(s) not imported: Lite allows up to $max trades per calendar month.';
  }

  @override
  String get tradeImportPickSoftwareFirst =>
      'Choose a platform before importing.';

  @override
  String get tradeImportEmptyFile => 'Empty or unreadable file.';

  @override
  String get tradeImportMt4HtmlOnly => 'MT4: use an HTML/HTM export.';

  @override
  String get tradeImportTradingViewCsvOnly => 'TradingView: use a CSV export.';

  @override
  String get tradeImportCtraderHtmlOnly =>
      'cTrader: use an HTML/HTM account statement.';

  @override
  String get tradeImportTradovateOrdersCsv =>
      'Tradovate: export Orders.csv (fills).';

  @override
  String get tradeImportTradovatePickOrdersCsv =>
      'Tradovate: choose an Orders.csv file.';

  @override
  String get tradeImportNinjaGridCsv =>
      'NinjaTrader: export a CSV grid (Orders or Executions).';

  @override
  String get tradeImportNinjaPickCsv => 'NinjaTrader: choose a CSV grid file.';

  @override
  String get tradeImportRithmicCsv =>
      'Rithmic: use a CSV export (Recent Orders).';

  @override
  String get tradeImportRithmicPickCsv => 'Rithmic: choose a CSV file.';

  @override
  String get tradeImportQuantowerCsv =>
      'Quantower: use a CSV export (Orders history).';

  @override
  String get tradeImportQuantowerPickCsv =>
      'Quantower: choose a CSV file (Orders history).';

  @override
  String get tradeImportAtasXlsxReadFailed =>
      'Could not read the .xlsx (empty file or too large for the browser). Try again or reopen the file.';

  @override
  String get tradeImportAtasPickCsvXlsx =>
      'ATAS: choose a CSV or .xlsx file (Statistics).';

  @override
  String get tradeImportAtasXlsxEmptyFile => 'Empty file.';

  @override
  String get tradeImportAtasXlsxInvalidFormat =>
      'Not a valid Excel .xlsx file (missing header). Re-export from ATAS.';

  @override
  String get tradeImportAtasXlsxJournalMissing =>
      'Journal sheet not found or workbook unreadable. Check your Statistics .xlsx export.';

  @override
  String get tradeImportAtasXlsxNoRows =>
      'No trade row recognized. Open the Journal sheet: Instrument, Open time, Open/Close volume columns.';

  @override
  String tradeImportNotImplemented(String source) {
    return 'Import for $source is not available yet.';
  }

  @override
  String tradeImportEmptyMt5(String extension) {
    return 'MT5 $extension: no Position row detected.';
  }

  @override
  String get tradeImportEmptyTradingView =>
      'TradingView CSV: no closed position detected.';

  @override
  String get tradeImportEmptyCtrader =>
      'cTrader HTML: no History row detected.';

  @override
  String get tradeImportEmptyTradovate =>
      'Tradovate CSV: no round-trip (entry/exit) detected.';

  @override
  String get tradeImportEmptyNinjaTrader =>
      'NinjaTrader CSV: no round-trip (entry/exit) detected.';

  @override
  String get tradeImportEmptyAtas =>
      'ATAS: no recognized row (Journal sheet only).';

  @override
  String get tradeImportEmptyGeneric =>
      'No position recognized for this platform/file.';

  @override
  String tradeImportNoneNew(String source, String duplicates) {
    return 'No new trades imported from $source$duplicates.';
  }

  @override
  String tradeImportSummary(int count, String source, String duplicates) {
    return '$count trade(s) imported from $source$duplicates.';
  }

  @override
  String tradeImportDuplicatesSuffix(int count) {
    return ' · $count duplicate(s) ignored';
  }

  @override
  String tradeImportDuplicatesOnlySuffix(int count) {
    return ' · $count duplicate(s)';
  }

  @override
  String tradeImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get ajouterTradeSectionEtatMoment => 'CURRENT STATE';

  @override
  String get ajouterTradeImagePickerClose => 'Close';

  @override
  String get ajouterTradeImagePickerTitle => 'Image source';

  @override
  String get ajouterTradeGallery => 'Gallery';

  @override
  String get ajouterTradeCamera => 'Camera';

  @override
  String get ajouterTradeFeedbackAlmost100 =>
      'You\'re close to 100%: keep applying every point.';

  @override
  String get ajouterTradeFeedbackTickEach =>
      'Tick each point that applies (multiple selections).';

  @override
  String get ajouterTradeChoicesSaved => 'Saved choices:';

  @override
  String ajouterTradeNonRespectedSemantic(Object label) {
    return 'Not followed: $label';
  }

  @override
  String ajouterTradeDisciplineRespectBase(int pct) {
    return 'Respect $pct %';
  }

  @override
  String ajouterTradeDisciplineRespectNonList(Object items, Object more) {
    return ' · Not followed: $items$more';
  }

  @override
  String get ajouterTradeFieldActif => 'Asset';

  @override
  String get ajouterTradeFieldEntree => 'Entry';

  @override
  String get ajouterTradeFieldSortie => 'Exit';

  @override
  String get ajouterTradeCheckboxBreakeven => 'Breakeven';

  @override
  String get ajouterTradeCheckboxPositionOpen => 'Open position';

  @override
  String get ajouterTradeCheckboxAvantNews => 'Before news';

  @override
  String get ajouterTradeCheckboxApresNews => 'After news';

  @override
  String get ajouterTradeDirectionBuyLong => 'Buy · Long';

  @override
  String get ajouterTradeDirectionSellShort => 'Sell · Short';

  @override
  String get ajouterTradeEntryExitDateHint =>
      'Tip: set the date and time for Entry and Exit. On the Performance page, this links position duration to your profit or loss.';

  @override
  String get ajouterTradeQtyLots => 'Size (lots)';

  @override
  String get ajouterTradeQtyContracts => 'Size (contracts)';

  @override
  String get ajouterTradeQtyUnits => 'Size (units)';

  @override
  String get ajouterTradeQtyShares => 'Size (shares)';

  @override
  String get ajouterTradeShortcutsLots => 'Lot shortcuts';

  @override
  String get ajouterTradeShortcutsContracts => 'Contract shortcuts';

  @override
  String get ajouterTradeShortcutsQty => 'Size shortcuts';

  @override
  String get ajouterTradeShortcutsCommonSizes => 'Shortcuts (common sizes)';

  @override
  String get ajouterTradeLotHintMini => 'E.g. 0.1 = typical mini lot.';

  @override
  String get ajouterTradeLotFieldHintForex => 'e.g. 0.1';

  @override
  String get ajouterTradeLotFieldHintContracts => 'e.g. 2';

  @override
  String get ajouterTradeLotFieldHintUnits => 'e.g. 1';

  @override
  String get ajouterTradeLotFieldHintShares => 'e.g. 10';

  @override
  String get ajouterTradeDisciplineSettingsTitle => 'Discipline settings';

  @override
  String get ajouterTradeDisciplineSettingsSubtitle =>
      'Choose which sections are active for this trade.';

  @override
  String get ajouterTradeDisciplineFeelingModeTitle => 'Feeling mode';

  @override
  String get ajouterTradeDisciplineFeelingAllowSubtitle =>
      'Allow filling the sections below.';

  @override
  String get ajouterTradeDisciplineSectionsHeading => 'SECTIONS';

  @override
  String get ajouterTradeDisciplineStrategieTitle => 'Strategy';

  @override
  String get ajouterTradeDisciplineStrategieSubtitle => 'Setup, feedback';

  @override
  String get ajouterTradeDisciplinePlanTitle => 'Analysis plan';

  @override
  String get ajouterTradeDisciplineConfidencePlanTitle => 'Confidence plan';

  @override
  String get ajouterTradeDisciplinePlanSubtitle => 'Report, feedback';

  @override
  String get ajouterTradeDisciplineChecklistTitle => 'Checklist';

  @override
  String get ajouterTradeDisciplineChecklistSubtitle => 'Points to follow';

  @override
  String get ajouterTradeDisciplineEtatTitle => 'State of the moment';

  @override
  String get ajouterTradeDisciplineEtatSubtitle => 'Moments and emotions';

  @override
  String get ajouterTradeDisciplineSliderStrategieRespected =>
      'Strategy followed';

  @override
  String get ajouterTradePositionSettingsTitle => 'Position settings';

  @override
  String get ajouterTradeStrategieFeedbackBravo =>
      'Well done! You followed your strategy completely.';

  @override
  String get ajouterTradeStrategieFeedbackWhichMissed =>
      'Which parts of your strategy did you not follow?';

  @override
  String get ajouterTradeStrategieGoldRules => 'GOLDEN RULES';

  @override
  String ajouterTradeStrategieRuleN(int n) {
    return 'Rule $n';
  }

  @override
  String ajouterTradeStrategieSetupTimeframesRow(Object value) {
    return 'Timeframes: $value';
  }

  @override
  String ajouterTradeStrategieSetupIndicatorsRow(Object value) {
    return 'Indicators: $value';
  }

  @override
  String ajouterTradeStrategieSetupPatternRow(Object value) {
    return 'Pattern: $value';
  }

  @override
  String ajouterTradeStrategieSetupSignalRow(Object value) {
    return 'Signal: $value';
  }

  @override
  String get ajouterTradeStrategieRiskManagement => 'RISK MANAGEMENT';

  @override
  String get ajouterTradeStrategieHoursSessions => 'HOURS & SESSIONS';

  @override
  String get ajouterTradeStrategieSetupModels => 'SETUP & MODELS';

  @override
  String ajouterTradeStrategieSetupModelsWithTitle(Object title) {
    return 'SETUP & MODELS — $title';
  }

  @override
  String get ajouterTradeStrategiePickStrategyHint =>
      'Pick a strategy from the list above to show setup details (entry, stop, target, trade management, etc.).';

  @override
  String get ajouterTradeStrategieRowPattern => 'Pattern';

  @override
  String get ajouterTradeStrategieRowSignal => 'Signal';

  @override
  String get ajouterTradeStrategieClosedLabel100 => 'Great, strategy followed';

  @override
  String get ajouterTradeStrategieClosedLabel95 => 'Almost fully followed';

  @override
  String get ajouterTradeStrategieClosedLabelLow => 'Points to review';

  @override
  String get ajouterTradePlanPickReportAbove =>
      'Pick a report in the field above.';

  @override
  String get ajouterTradePlanFeedbackAlmost100 =>
      'You\'re close to 100%: keep applying every point of your analysis plan.';

  @override
  String get ajouterTradePlanFeedbackBravo =>
      'Well done! You followed your analysis plan completely.';

  @override
  String get ajouterTradePlanFeedbackWhichMissed =>
      'Which parts of your analysis plan did you not follow?';

  @override
  String get ajouterTradePlanClosedLabel100 => 'Great, plan followed';

  @override
  String get ajouterTradePlanClosedLabelLow => 'Feedback';

  @override
  String get ajouterTradeChecklistFeedbackAlmost100 =>
      'You\'re close to 100%: keep applying every point on your checklist.';

  @override
  String get ajouterTradeChecklistFeedbackBravo =>
      'Well done! You followed your checklist completely.';

  @override
  String get ajouterTradeChecklistFeedbackWhichMissed =>
      'Which parts of your checklist did you not follow?';

  @override
  String get ajouterTradeChecklistClosedLabel100 => 'Great, checklist followed';

  @override
  String get ajouterTradeChecklistClosedLabelLow => 'Checklist';

  @override
  String get ajouterTradeEtatFeelingPrompt => 'What feelings came up?';

  @override
  String get ajouterTradeEtatFeedbackAlmost100 =>
      'You\'re close to 100%: keep applying every point.';

  @override
  String get ajouterTradeEtatClosedLabel100 => 'Yes, it\'s tough. Well done!';

  @override
  String get ajouterTradeEtatClosedLabelLow => 'State of the moment';

  @override
  String get ajouterTradeEtatHeaderMoment => 'YOUR STATE';

  @override
  String get ajouterTradeEtatHeaderEmotions => 'EMOTIONS';

  @override
  String get ajouterTradeScreenshotLoadError => 'Could not display the image';

  @override
  String get ajouterTradeScreenshotChangeImage => 'Change image';

  @override
  String get ajouterTradeScreenshotTapToAdd => 'Tap to add an image';

  @override
  String get ajouterTradeScreenshotRemove => 'Remove';

  @override
  String get ajouterTradePlanRowBias => 'Bias';

  @override
  String get ajouterTradePlanRowTimeframeHtf => 'HTF timeframe';

  @override
  String get ajouterTradePlanRowPhase => 'Phase';

  @override
  String get ajouterTradePlanRowNotes => 'Notes';

  @override
  String get ajouterTradePlanRowLastPoint => 'Last swing point';

  @override
  String ajouterTradePlanRowExtraSupport(int n) {
    return 'Extra support $n';
  }

  @override
  String ajouterTradePlanRowExtraResistance(int n) {
    return 'Extra resistance $n';
  }

  @override
  String get ajouterTradePlanRowOutils => 'Tools';

  @override
  String get ajouterTradePlanRowLiquidity => 'Liquidity';

  @override
  String get ajouterTradePlanRowFibPrice => 'Fib price';

  @override
  String get ajouterTradePlanSectionVolume => 'VOLUME';

  @override
  String get analyseAddField => '+ Add field';

  @override
  String get analyseAddPhaseTitle => 'Add phase';

  @override
  String get analyseAddResist => '+ Add resistance';

  @override
  String get analyseAddShort => '+ Add';

  @override
  String get analyseAddSupport => '+ Add support';

  @override
  String get analyseAddTimeframeTitle => 'Add timeframe';

  @override
  String get analyseAddTimeframeCustomEntry => 'Other (custom label)';

  @override
  String get analyseAddTimeframeSectionRestore => 'Restore';

  @override
  String get analyseAddTimeframeSectionIntraday => 'Intraday';

  @override
  String get analyseAddTimeframeSectionSwing => 'Swing & position';

  @override
  String get analyseAddTrendTitle => 'Add trend';

  @override
  String get analyseReportScreenshotSectionTitle => 'SCREENSHOT';

  @override
  String get analyseReportScreenshotAddCapture => 'Add screenshot';

  @override
  String get analyseReportScreenshotChooseImage => 'Choose an image';

  @override
  String get analyseReportScreenshotSubtitleWeb => 'Image file';

  @override
  String get analyseReportScreenshotSubtitleFilePicker =>
      'Gallery or file explorer';

  @override
  String get analyseReportScreenshotCamera => 'Camera';

  @override
  String get analyseReportScreenshotHintWithCamera => 'File, gallery or camera';

  @override
  String get analyseReportScreenshotHintNoCamera =>
      'Choose an image on this device';

  @override
  String get analyseReportScreenshotErrorPlugin =>
      'Image selection is unavailable on this target. Use “Choose an image” or rebuild the app (flutter clean / run).';

  @override
  String get analyseReportScreenshotErrorGeneric =>
      'Could not add the screenshot.';

  @override
  String get analyseCardIndicators => 'Indicators';

  @override
  String get analyseCardSmcLiquidity => 'SMC & Liquidity';

  @override
  String get analyseCardVolumeProfile => 'Volume profile';

  @override
  String get analysePageHeroTitle => 'My analysis';

  @override
  String get analysePageHeroSubtitle =>
      'Manage your analyses and strategies in real time.';

  @override
  String get analyseSidebarConfidenceSummary => 'SUMMARY';

  @override
  String get analyseSidebarConfidenceLabel => 'global confidence';

  @override
  String get analyseSidebarReportHint =>
      'The report will be saved to your history with the linked asset.';

  @override
  String get analyseSidebarPreviewStyle => 'STYLE PREVIEW';

  @override
  String get analyseConfidenceHigh => 'High';

  @override
  String get analyseConfidenceLevelTitle => 'CONFIDENCE LEVEL';

  @override
  String get analyseConfidenceLow => 'Low';

  @override
  String analyseCopyLabel(String label) {
    return 'Copy $label';
  }

  @override
  String analyseCopyNumber(int n) {
    return 'Copy $n';
  }

  @override
  String get analyseCurrentMarketPhase => 'CURRENT MARKET PHASE';

  @override
  String get analyseCurrentTrend => 'CURRENT TREND';

  @override
  String get analyseDeleteTemplateTitle => 'Delete this template?';

  @override
  String get analyseDirectionLabel => 'DIRECTION';

  @override
  String get analyseDraftLabelHint => 'Label…';

  @override
  String get analyseExtraBroken => 'Broken';

  @override
  String get analyseExtraHeld => 'Held';

  @override
  String get analyseExtraPriceHint => 'Price';

  @override
  String get analyseFeuillePlanTitle => 'TRADING PLAN SHEET';

  @override
  String get analyseFibLevel => 'FIBONACCI LEVEL';

  @override
  String get analyseFibShort => 'FIBONACCI';

  @override
  String get analyseFreeFields => 'FREE FIELDS';

  @override
  String get analyseFvg => 'FAIR VALUE GAP (FVG)';

  @override
  String get analyseHintActifExamples => 'e.g. NASDAQ, EUR/USD…';

  @override
  String get analyseHintDetailsDots => 'Details…';

  @override
  String get analyseHintHtfChipExample => 'e.g. Weekly';

  @override
  String get analyseHintImbalance => 'Imbalance…';

  @override
  String get analyseHintNotesDots => 'Notes…';

  @override
  String get analyseHintPriceDots => 'Price…';

  @override
  String get analyseHintStops => 'Where are the stops? (e.g. Buy Side)';

  @override
  String get analyseHintTextDots => 'Text…';

  @override
  String get analyseHintTfExamples => 'e.g. MN, 3D…';

  @override
  String get analyseHintZoneHtf => 'HTF zone…';

  @override
  String get analyseHtfTimeframe => 'ANALYSIS TIMEFRAME (HTF)';

  @override
  String get analyseImpactFeuille => 'Sheet impact';

  @override
  String get analyseImpactIndicators => 'Indicators impact';

  @override
  String analyseImpactLine(int percent) {
    return 'Impact: $percent%';
  }

  @override
  String get analyseImpactModalBlurb =>
      'The four impacts share 100% in total. Moving this slider adjusts the others proportionally.';

  @override
  String get analyseImpactModalTitle => 'Adjust impact';

  @override
  String get analyseImpactShort => 'Impact';

  @override
  String get analyseImpactSmc => 'SMC impact';

  @override
  String get analyseLastPointHint => 'Last point…';

  @override
  String get analyseLiquidityPools => 'LIQUIDITY POOLS';

  @override
  String get analyseMovementDetailsHint => 'Movement details…';

  @override
  String get analyseNameFieldHint => 'Analysis name…';

  @override
  String get analyseNameFieldLabel => 'Analysis name';

  @override
  String get analyseNoTemplatesSaved => 'No saved templates';

  @override
  String get analyseNote => 'NOTE';

  @override
  String get analyseNotesIndicators => 'NOTES (INDICATORS)';

  @override
  String get analyseNotesSmcExample => 'e.g. Liquidity grab before FVG…';

  @override
  String get analyseNotesSmcLiq => 'NOTES (SMC & LIQUIDITY)';

  @override
  String get analyseNotesVolumeProfile => 'NOTES (VOLUME PROFILE)';

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
  String get analyseResistLower => 'Resistance';

  @override
  String get analyseResistShort => 'RESIST.';

  @override
  String get analyseSetup => 'SETUP';

  @override
  String get analyseSideBuy => 'Buy';

  @override
  String get analyseSideSell => 'Sell';

  @override
  String get analyseSideWatch => 'Watch';

  @override
  String get analyseSmcAdds => 'SMC ADDS';

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
    return 'Template “$name” applied';
  }

  @override
  String get analyseTemplateNameHint => 'New name…';

  @override
  String get analyseTemplateRenameDialogTitle => 'Rename template';

  @override
  String get analyseTemplateSaveDialogTitle => 'Template name';

  @override
  String get analyseTemplateStyleHint => 'e.g. Swing, scalping…';

  @override
  String get analyseTestedTwice => 'Tested x 2';

  @override
  String get analyseTimeframeLabelShort => 'TIMEFRAME';

  @override
  String get analyseTooltipPickTemplate => 'Choose a saved template';

  @override
  String get analyseTooltipSaveTemplatePills =>
      'Save pills under a name (your habit)';

  @override
  String get analyseTrend => 'TREND';

  @override
  String get analyseTrendLabel => 'Trend';

  @override
  String get analyseVolumePoc => 'POC';

  @override
  String get analyseVolumeProfile => 'VOLUME PROFILE';

  @override
  String get analyseVolumeProfileDefaultLabel => 'Volume profile';

  @override
  String get analyseVolumeVah => 'VAH';

  @override
  String get analyseVolumeVal => 'VAL';

  @override
  String get analyseVolumeZoneFrom => 'From';

  @override
  String get analyseVolumeZoneLabel => 'Zone';

  @override
  String get analyseVolumeZoneTo => 'To';

  @override
  String get appBrandName => 'PAYCHEK';

  @override
  String get buttonCalculate => 'Calculate';

  @override
  String get calAmountLabel => 'Amount';

  @override
  String get calMonthlyObjectiveTitle => 'Monthly objective';

  @override
  String get calPageTitle => 'Calendar';

  @override
  String get calObjectiveLabel => 'Objective';

  @override
  String get calCumulativePerformanceTitle => 'Cumulative performance';

  @override
  String get calBestDay => 'Best day';

  @override
  String get calTradingDays => 'Trading days';

  @override
  String get calAverageShort => 'Average';

  @override
  String get calPnlShort => 'P&L';

  @override
  String get calCapitalChangePct => 'Capital %';

  @override
  String get calAveragePerDay => 'Avg / day';

  @override
  String get calObjectiveShort => 'Objective';

  @override
  String calChartError(String message) {
    return 'Error: $message';
  }

  @override
  String calDayTradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trades',
      one: '1 trade',
      zero: 'No trades',
    );
    return '$_temp0';
  }

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get monthAbbrJanuary => 'Jan';

  @override
  String get monthAbbrFebruary => 'Feb';

  @override
  String get monthAbbrMarch => 'Mar';

  @override
  String get monthAbbrApril => 'Apr';

  @override
  String get monthAbbrMay => 'May';

  @override
  String get monthAbbrJune => 'Jun';

  @override
  String get monthAbbrJuly => 'Jul';

  @override
  String get monthAbbrAugust => 'Aug';

  @override
  String get monthAbbrSeptember => 'Sep';

  @override
  String get monthAbbrOctober => 'Oct';

  @override
  String get monthAbbrNovember => 'Nov';

  @override
  String get monthAbbrDecember => 'Dec';

  @override
  String get calcBestBalance => 'Best balance';

  @override
  String get calcEndBalance => 'End balance';

  @override
  String get calcEquityCurveTitle => 'Trade return curve graph';

  @override
  String get calcLabelEntry => 'Entry price';

  @override
  String get calcLabelRiskShort => 'Risk';

  @override
  String get calcLabelSl => 'Stop loss';

  @override
  String get calcLabelStartBalance => 'Start balance';

  @override
  String get calcLabelTp => 'Take profit';

  @override
  String get calcLabelTradesShort => 'Trades';

  @override
  String get calcLabelWinRateShort => 'Win rate';

  @override
  String get calcLoss => 'Loss';

  @override
  String get calcMaxDrawdown => 'Max drawdown';

  @override
  String get calcProfitFactor => 'Profit factor';

  @override
  String get calcRatioSectionTitle => 'Ratio';

  @override
  String get calcResult => 'Result';

  @override
  String get calcResultOfCalculation => 'Result of calculation';

  @override
  String get calcRowGain => 'Gain:';

  @override
  String get calcRowSl => 'SL:';

  @override
  String get calcRowVsCapital => 'Vs capital';

  @override
  String get calcSettingsTitle => 'Settings';

  @override
  String get calcTotalGainLabel => 'Total gain';

  @override
  String get calcTradeReturnTableTitle => 'Results trade return';

  @override
  String get calcWin => 'Win';

  @override
  String get calcWinsLosses => 'Wins / Losses';

  @override
  String get calcErrorInvalidBalance => 'Invalid start balance.';

  @override
  String get calcErrorTradesRange => 'Trades must be between 1 and 2000.';

  @override
  String get calcErrorWinRateRange => 'Win rate must be between 0 and 100.';

  @override
  String get calcErrorRiskRange => 'Risk % must be between 0 and 100.';

  @override
  String get calcErrorInvalidRiskReward => 'Invalid risk:reward.';

  @override
  String get calcErrorInvalidLot => 'Invalid lot size.';

  @override
  String get calcErrorInvalidEntry => 'Invalid entry price.';

  @override
  String get calcErrorInvalidSl => 'Invalid stop loss.';

  @override
  String get calcErrorInvalidTp => 'Invalid take profit.';

  @override
  String get calcErrorEntrySlIdentical => 'Entry and SL cannot be identical.';

  @override
  String get calcDisclaimerEstimates =>
      'Warning: these calculations are not contractual figures. They are only estimates.';

  @override
  String get calcHeaderSubtitleEstimates =>
      'Return and ratio simulations — indicative values only.';

  @override
  String get calcMarketIndex => 'Index';

  @override
  String get calcMarketFutures => 'Futures';

  @override
  String get calcMarketStock => 'Stock';

  @override
  String get calcMarketCommodities => 'Commodities';

  @override
  String get calcWorstBalance => 'Worst balance';

  @override
  String get calculateRatio => 'Calculate ratio';

  @override
  String get cancel => 'Cancel';

  @override
  String get capitalAmountLabel => 'Capital amount';

  @override
  String get capitalCurrencyTitle => 'Currency';

  @override
  String get capitalEllipsis => '…';

  @override
  String get capitalHintAmount => 'e.g. 10 450';

  @override
  String get capitalInitialTitle => 'Initial capital';

  @override
  String get capitalLabel => 'Capital';

  @override
  String get capitalOther => 'other';

  @override
  String get capitalTooltip => 'Capital and currency (main account)';

  @override
  String get checklistAddSection => 'Add a section';

  @override
  String get checklistDefaultNewSection => 'NEW SECTION';

  @override
  String get checklistDeleteSectionBody =>
      'This action is permanent for this section.';

  @override
  String get checklistDeleteSectionTitle => 'Delete section?';

  @override
  String get checklistEditSectionHint => 'Title';

  @override
  String get checklistIntroBody =>
      'Before taking a position, make sure you validate all the criteria in your trading plan.';

  @override
  String get checklistDailyCalendarTitle => 'DAILY CHECKLIST';

  @override
  String get checklistDailyUncheckedTitle => 'NOT CHECKED';

  @override
  String get checklistDailyUncheckedNoActivity => 'No activity on this day.';

  @override
  String get checklistDailyUncheckedNoDue =>
      'No criteria scheduled for this day.';

  @override
  String get checklistDailyUncheckedAllDone =>
      'All criteria for this day are checked.';

  @override
  String get checklistDailyUncheckedNoHistory =>
      'No checklist details were saved for this day. Unchecked criteria tracking is available from today onward.';

  @override
  String get checklistItemNews1 =>
      'Economic calendar reviewed (FED, CPI, NFP, GDP…).';

  @override
  String get checklistItemNews2 =>
      'FOMC / FED: no trading during the announcement.';

  @override
  String get checklistItemNews3 =>
      'CPI (inflation): time and expected impact noted.';

  @override
  String get checklistItemNews4 =>
      'NFP (US jobs): high-risk window identified.';

  @override
  String get checklistItemAnalyse1 =>
      'The background trend (HTF) aligns with my idea.';

  @override
  String get checklistItemAnalyse2 =>
      'Price is at a key zone (Support/Resistance, Order Block).';

  @override
  String get checklistItemAnalyse3 =>
      'I have a clear entry confirmation (Pattern, Divergence).';

  @override
  String get checklistItemHint => 'Enter criterion';

  @override
  String get checklistItemPsy1 =>
      'I trade in a neutral mindset (no revenge trading).';

  @override
  String get checklistItemPsy2 =>
      'I accept the potential loss before entering.';

  @override
  String get checklistItemPsy3 =>
      'I stick to my plan even after a series of losses.';

  @override
  String get checklistItemRisque1 =>
      'My stop loss is set technically (not random).';

  @override
  String get checklistItemRisque2 => 'Risk does not exceed 1% of my capital.';

  @override
  String get checklistItemRisque3 => 'The risk/reward ratio is at least 1:2.';

  @override
  String get checklistMenuEdit => 'Edit';

  @override
  String get checklistPageTitle => 'Checklist';

  @override
  String get checklistProgressCl => 'CL';

  @override
  String get checklistSectionNews => 'NEWS · ECONOMIC CALENDAR';

  @override
  String get checklistSectionAnalyse => 'TECHNICAL ANALYSIS';

  @override
  String get checklistSectionPsy => 'PSYCHOLOGY';

  @override
  String get checklistSectionRisque => 'RISK MANAGEMENT';

  @override
  String get checklistScheduleTitle => 'Item reminder';

  @override
  String get checklistScheduleDefaultHeading => '1 · Default rule';

  @override
  String get checklistScheduleModeDaily => 'Every day';

  @override
  String get checklistScheduleModeWeekly => 'Once a week';

  @override
  String get checklistScheduleModeSpecificDate => 'Specific date';

  @override
  String get checklistScheduleUserDateHeading => '2 · Chosen date';

  @override
  String get checklistSchedulePickDate => 'Pick a date';

  @override
  String get checklistScheduleWeekHeading => '3 · Day of week';

  @override
  String checklistScheduleNextOccurrence(String date) {
    return 'Next date: $date';
  }

  @override
  String get checklistScheduleWarningHeading => '4 · Alert time';

  @override
  String get checklistSchedulePickTime => 'Pick time';

  @override
  String get checklistScheduleCalendarTooltip => 'Date and reminder settings';

  @override
  String get clearAll => 'Clear all';

  @override
  String get confirm => 'Confirm';

  @override
  String get currencyNameHint => 'e.g. CHF, XOF';

  @override
  String get currencyNameLabel => 'Currency name';

  @override
  String get customCurrencyTitle => 'Other currency';

  @override
  String get dashboardAiAnalyze => 'Analyze';

  @override
  String get dashboardAiCoachBody =>
      'Tap « Analyze » so the AI reviews your weekly stats (Win rate, Hours, Factors) and generates tailored psychological advice.';

  @override
  String get dashboardAiCoachTitle => 'PAYCHEK AI COACH';

  @override
  String get dashboardAnalyseShortcutTitle => 'My Analysis';

  @override
  String get dashboardBestTradeLabel => 'Best trade';

  @override
  String get dashboardCapitalBalanceHeader => 'CAPITAL / BALANCE';

  @override
  String get dashboardCapitalEvolutionTitle => 'CAPITAL EVOLUTION';

  @override
  String get dashboardChecklistHeading => 'CHECKLIST';

  @override
  String get dashboardChecklistSeeRest => 'More >';

  @override
  String get dashboardChecklistAllDoneBravo => 'Good trading.';

  @override
  String get dashboardMyStateSection => 'My state';

  @override
  String get dashboardOpenStrategyTooltip => 'Open My Strategy';

  @override
  String dashboardPerfHourWinRate(int percent) {
    return '$percent% WR';
  }

  @override
  String get dashboardPerfHoursRow1 => '09:00 - 11:30 (Start)';

  @override
  String get dashboardPerfHoursRow2 => '14:30 - 16:30 (US Open)';

  @override
  String get dashboardPerfHoursRow3 => '19:00+ (Evening)';

  @override
  String get dashboardPerfHoursTitle => 'PERFORMANCE HOURS';

  @override
  String get dashboardRingState => 'STATE';

  @override
  String get dashboardRingWin => 'WIN';

  @override
  String get dashboardSuccessFactorSample => 'Sport before session';

  @override
  String get dashboardSuccessFactorsSubtitle =>
      'Track how your habits impact your win rate.';

  @override
  String get dashboardSuccessFactorsTitle => 'SUCCESS FACTORS';

  @override
  String get dashboardTfAll => 'ALL';

  @override
  String get dashboardTfDay => '1D';

  @override
  String get dashboardTfMonth => '1M';

  @override
  String get dashboardTfWeek => '1W';

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
      other: '$count trades this period',
      one: '1 trade this period',
      zero: '0 trades this period',
    );
    return '$_temp0';
  }

  @override
  String get dashboardEvolutionSparklineHoverOrigin =>
      'Start of cumulative P&L';

  @override
  String get dashboardEvolutionSparklineHoverNoTrade =>
      'No trades at this point';

  @override
  String dashboardEvolutionSparklineHoverMore(int count) {
    return '+$count more';
  }

  @override
  String get dashboardEvolutionSparklineTapHint => 'Tap to open';

  @override
  String get dashboardWeekResultPrefix => 'Result: ';

  @override
  String get dashboardWeekThisWeek => 'THIS WEEK';

  @override
  String get dashboardWeekdayShortFri => 'FRI';

  @override
  String get dashboardWeekdayShortMon => 'MON';

  @override
  String get dashboardWeekdayShortSat => 'SAT';

  @override
  String get dashboardWeekdayShortSun => 'SUN';

  @override
  String get dashboardWeekdayShortThu => 'THU';

  @override
  String get dashboardWeekdayShortTue => 'TUE';

  @override
  String get dashboardWeekdayShortWed => 'WED';

  @override
  String get dashboardWorstLossLabel => 'Worst loss';

  @override
  String get delete => 'Delete';

  @override
  String deletePortfolioTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get editPortfolioTooltip => 'Edit name, capital, currency';

  @override
  String get errorAmount => 'Enter a valid amount (≥ 0).';

  @override
  String get errorInvalidAmount => 'Invalid amount or currency.';

  @override
  String get errorNameOrSymbol => 'Enter at least a name or a symbol.';

  @override
  String get exportPdfFailed => 'Could not export PDF.';

  @override
  String exportPdfFailedWithError(String error) {
    return 'Could not export PDF: $error';
  }

  @override
  String get exportPdfUnavailable => 'PDF export cancelled or unavailable.';

  @override
  String get homePerformance => 'Performance';

  @override
  String get webHomeHeroSubtitle => 'Welcome, here is your weekly performance';

  @override
  String webHomeHeroWelcome(Object fullName) {
    return 'Welcome, $fullName';
  }

  @override
  String get webHomeLiveTerminal => 'Live terminal';

  @override
  String get webHomeWelcomeBack => 'Welcome back,';

  @override
  String get webHomeUpgradeUnlockSubtitle =>
      'Unlock real-time institutional data';

  @override
  String get webRailMenuHeading => 'Menu';

  @override
  String get labelActif => 'Asset';

  @override
  String get labelGain => 'P&L';

  @override
  String get labelLot => 'LOT';

  @override
  String get labelMarket => 'MARKET';

  @override
  String get labelPrice => 'PRICE';

  @override
  String get labelRiskPct => 'RISK %';

  @override
  String get labelSuggestedSize => 'SUGGESTED SIZE';

  @override
  String get langChineseTraditional => '中文 (繁體)';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'Français';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langKorean => '한국어';

  @override
  String get langPortuguese => 'Português';

  @override
  String get langSpanish => 'Español';

  @override
  String get languageDialogSubtitle => 'Interface language';

  @override
  String get languageDialogTitle => 'Choose language';

  @override
  String get languageSection => 'Language';

  @override
  String get onboardingLanguageContinue => 'Continue';

  @override
  String get mentalBad => 'Bad';

  @override
  String get mentalConfidence => 'Confidence';

  @override
  String get mentalEmotionFieldLabel => 'Emotion name (e.g. Calm, Fearful)';

  @override
  String get mentalEmotional => 'Emotional';

  @override
  String get mentalEnergy => 'Energy';

  @override
  String get mentalExcited => 'Excited';

  @override
  String get mentalFocus => 'Focus';

  @override
  String get mentalFrustrated => 'Frustrated';

  @override
  String get mentalHappy => 'Happy';

  @override
  String get mentalHintEmotion => 'e.g. Calm, Fearful';

  @override
  String get mentalHintMetric => 'e.g. Patience, Stress';

  @override
  String get mentalHintRoutine => 'e.g. Sport, Reading';

  @override
  String get mentalMarketStudy => 'Market study';

  @override
  String get mentalMeditation => 'Meditation (10 min)';

  @override
  String get mentalMetricFieldLabel => 'Metric name (e.g. Patience, Stress)';

  @override
  String get mentalNegative => 'Negative (-)';

  @override
  String get mentalNeutral => 'Neutral';

  @override
  String get mentalNewEmotion => 'New emotion';

  @override
  String get mentalNewMetric => 'New metric';

  @override
  String get mentalNewRoutine => 'New routine';

  @override
  String get mentalPeakForm => 'Peak form';

  @override
  String get mentalPositive => 'Positive (+)';

  @override
  String get mentalRestTitle => 'REST';

  @override
  String get mentalRiskAppetite => 'Fear';

  @override
  String get mentalRoutineFieldLabel => 'Routine name (e.g. Sport, Reading)';

  @override
  String get mentalDayDetailTitle => 'DAY CRITERIA';

  @override
  String get mentalDayDetailNoData =>
      'No data recorded for this day. Update your mental state to save it.';

  @override
  String get mentalDayDetailGlobalScore => 'GLOBAL SCORE';

  @override
  String get mentalGlobalScoreCalendarTitle => 'GLOBAL SCORE BY DAY';

  @override
  String get mentalCalendarDayStartDialogTitle => 'Start';

  @override
  String get mentalCalendarDayWindowStartLabel => 'Start';

  @override
  String get mentalCalendarDayWindowEndLabel => 'End';

  @override
  String get mentalCalendarDayWindowSettingsTooltip => '24 h window';

  @override
  String get mentalCalendarDayWindowDialogTitle => 'Score time window';

  @override
  String get mentalCalendarDayEndDialogTitle => 'End of window';

  @override
  String get mentalSleepEnough => 'Slept enough';

  @override
  String mentalSleepImpact(int percent) {
    return 'Impact: $percent%';
  }

  @override
  String get mentalSport => 'Sport / jogging';

  @override
  String get mentalTired => 'Tired';

  @override
  String get mentalWeightGlobalImpact => 'Global impact';

  @override
  String get mentalWeightModalBlurb =>
      'Adjust how important this criterion is. Use the multiplier or set the percentage you want directly.';

  @override
  String get mentalWeightModalTitle => 'Adjust impact';

  @override
  String get mentalWeightNatureLabel => 'Nature of impact';

  @override
  String get mentalWeightPolarityHelpNegative =>
      'A high value for this criterion will DECREASE your global score.';

  @override
  String get mentalWeightPolarityHelpPositive =>
      'A high value for this criterion will INCREASE your global score.';

  @override
  String get mentalPageTitle => 'Mental state';

  @override
  String get mentalPageIntro =>
      'Rate your mental state. Customize the impact (weight) of each criterion to match your profile.';

  @override
  String get mentalGaugeStateLabel => 'STATE';

  @override
  String mentalGaugeBasedOnIndicators(int count) {
    return 'Based on $count indicators';
  }

  @override
  String get mentalGaugeStatusStable => 'Solid balance';

  @override
  String get mentalGaugeStatusFragile => 'Needs attention';

  @override
  String get mentalSectionRoutinesHeading => 'MY ROUTINES';

  @override
  String get mentalSectionMomentHeading => 'STATE OF THE MOMENT';

  @override
  String get mentalSectionEmotionHeading => 'EMOTIONS';

  @override
  String modelSavedSnackbar(String name) {
    return 'Template “$name” saved';
  }

  @override
  String get navAdd => 'Add';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMore => 'More';

  @override
  String get navTrade => 'Trade';

  @override
  String get ok => 'OK';

  @override
  String get perf0Sub => 'Impact of stress and fatigue on win rate';

  @override
  String get perf0Title => 'Psychology: Emotions & sleep';

  @override
  String get perf1Sub => 'Profitability analysis (Mon–Sun)';

  @override
  String get perf1Title => 'Weekdays';

  @override
  String get perf2Sub => 'Find your most profitable hours';

  @override
  String get perf2Title => 'Session hours';

  @override
  String get perf3Sub => 'Success rate of this chart pattern';

  @override
  String get perf3Title => 'Pattern: Double top / bottom';

  @override
  String get perf4Sub => 'Major reversal analysis';

  @override
  String get perf4Title => 'Pattern: Head & shoulders';

  @override
  String get perf5Sub => 'Overbought/oversold signal validation';

  @override
  String get perf5Title => 'Indicator: RSI divergence';

  @override
  String get perf6Sub => 'Moving average crossover effectiveness';

  @override
  String get perf6Title => 'Indicator: MACD crossover';

  @override
  String get perf7Sub => 'Bounces at 0.618 and 0.5 levels';

  @override
  String get perf7Title => 'Indicator: Fibonacci retracement';

  @override
  String get perf8Sub => 'Order blocks and liquidity analysis';

  @override
  String get perf8Title => 'Strategy: Smart Money Concept (SMC)';

  @override
  String get perf9Sub => 'Impact of financial risk on win rate';

  @override
  String get perf9Title => 'Volume & lot size';

  @override
  String get perfAddWidgetButton => 'Add widget';

  @override
  String get perfChartBar => 'Bar chart';

  @override
  String get perfChartHBar => 'Horizontal bars';

  @override
  String get perfChartHintBar => 'Ideal for comparing (e.g. weekdays)';

  @override
  String get perfChartHintHBar => 'List format, simple and clean';

  @override
  String get perfChartHintLine => 'To see a trend over time';

  @override
  String get perfChartHintPie => 'For an overall percentage';

  @override
  String get perfChartLine => 'Line chart';

  @override
  String get perfChartPie => 'Circle / gauge';

  @override
  String get perfCustomizeIntro => 'Customize your Performance page.';

  @override
  String get perfDataFootnoteDuration =>
      'Data: breakdown by position duration (CSV).';

  @override
  String get perfDataFootnoteVolume =>
      'Volume proxy: buckets by |profit| (CSV).';

  @override
  String get perfEmptyChart =>
      'Import or load trades (CSV) to display the chart.';

  @override
  String get perfLineChartCaption =>
      'Line: cumulative profit (chronological order, CSV).';

  @override
  String get perfNewWidgetTitle => 'New widget';

  @override
  String get perfNoResults => 'No options found.';

  @override
  String get perfPieChartCaption =>
      'Slices = trade volume by category; % in disk = share of total.';

  @override
  String get perfRemoveWidgetTooltip => 'Remove widget';

  @override
  String get perfSearchHint => 'Search (e.g. pattern, psychology…)';

  @override
  String get perfStep1Title => '1. What do you want to analyze?';

  @override
  String get perfStep2Title => '2. Chart type';

  @override
  String get plusAdd => 'Add';

  @override
  String get plusCalculator => 'Calculator';

  @override
  String get plusCalendar => 'Calendar';

  @override
  String get plusChecklist => 'Checklist';

  @override
  String get plusDashboard => 'Dashboard';

  @override
  String get plusMentalState => 'Mental state';

  @override
  String get plusMyAnalysis => 'My analysis';

  @override
  String get plusMyStrategy => 'My strategy';

  @override
  String get plusPerformance => 'Performance';

  @override
  String get plusSettings => 'Settings';

  @override
  String get plusTrade => 'Trade';

  @override
  String get paychekAccessDeniedTitle => 'Access restricted';

  @override
  String get paychekAccessDeniedWeb =>
      'Web access for this account has been disabled. Contact support if needed.';

  @override
  String get paychekAccessDeniedMobile =>
      'Mobile app access for this account has been disabled. Contact support if needed.';

  @override
  String get portfolioNameMissing => 'Enter a portfolio name (e.g. broker).';

  @override
  String get portfoliosLabel => 'Portfolios';

  @override
  String get q1Slogan => 'Choose your approach';

  @override
  String get q1Title => 'What kind of trader are you?';

  @override
  String get q1o1s => 'Positions from seconds to a few minutes';

  @override
  String get q1o1t => 'Scalping';

  @override
  String get q1o2s => 'All positions are closed before the session ends';

  @override
  String get q1o2t => 'Day trading';

  @override
  String get q1o3s => 'Positions held between 1 and 3 days';

  @override
  String get q1o3t => 'Intraday';

  @override
  String get q1o4s => 'Positions held over several days or weeks';

  @override
  String get q1o4t => 'Swing';

  @override
  String get q2Slogan => 'Where are you on your journey?';

  @override
  String get q2Title => 'Experience profile';

  @override
  String get q2o1s => 'You\'re not alone';

  @override
  String get q2o1s2 =>
      'For traders who are starting and still searching for their method';

  @override
  String get q2o1t => 'I don\'t have a strategy';

  @override
  String get q2o2s => 'Light at the end of the tunnel';

  @override
  String get q2o2s2 => 'For those with the basics who want consistency';

  @override
  String get q2o2t => 'I have my strategy';

  @override
  String get q2o3s => 'The hardest part is behind you';

  @override
  String get q2o3s2 => 'For experienced traders who master their stats';

  @override
  String get q2o3t => 'Performant';

  @override
  String get q3Slogan => 'Pick your top priority';

  @override
  String get q3Title => 'What do you want to improve?';

  @override
  String get q3o1s => 'Stop winning one day to lose it all the next.';

  @override
  String get q3o1s2 =>
      'To stabilize your equity curve and avoid the emotional elevator.';

  @override
  String get q3o1t => 'OFF THE ROLLER COASTER';

  @override
  String get q3o2s => 'Improve win rate and entry precision.';

  @override
  String get q3o2s2 =>
      'For those who want to win more often by choosing better trades.';

  @override
  String get q3o2t => 'BECOME A SNIPER';

  @override
  String get q3o3s => 'Master discipline and stop emotional decisions.';

  @override
  String get q3o3s2 => 'To remove impulsive trading and follow your plan 100%.';

  @override
  String get q3o3t => 'STAY ICE-COLD';

  @override
  String get q3o4s => 'Understand which chart patterns truly work for you.';

  @override
  String get q3o4s2 =>
      'To spot your own winning patterns and become a specialist.';

  @override
  String get q3o4t => 'FIND YOUR SIGNATURE';

  @override
  String get q4Slogan => 'Identify what blocks you most';

  @override
  String get q4Title => 'What is your biggest challenge?';

  @override
  String get q4o1s => 'Fear of missing out.';

  @override
  String get q4o1s2 => 'Quick, I will miss the chance to profit!';

  @override
  String get q4o1t => 'FOMO';

  @override
  String get q4o2s => 'Your heart replaced your brain.';

  @override
  String get q4o2s2 => 'No way—I MUST win my money back!';

  @override
  String get q4o2t => 'TILT';

  @override
  String get q4o3s => 'No clear strategy or plan.';

  @override
  String get q4o3s2 => 'I don\'t really know, but it feels good—let\'s try.';

  @override
  String get q4o3t => 'TRADING BLIND';

  @override
  String get q4o4s => 'Constant restlessness.';

  @override
  String get q4o4s2 => 'If I don\'t click, I feel like I\'m not working.';

  @override
  String get q4o4t => 'OVERTRADING';

  @override
  String get q4o5s => 'Thinking you\'re invincible.';

  @override
  String get q4o5s2 => 'I\'m too good—easy money! I\'ll double the stake.';

  @override
  String get q4o5t => 'OVERCONFIDENCE';

  @override
  String get q4o6s => 'Fear of everything.';

  @override
  String get q4o6s2 => 'I\'m not sure, I\'m afraid to lose again.';

  @override
  String get q4o6t => 'PARALYSIS';

  @override
  String get q4o7s => 'Playing Russian roulette.';

  @override
  String get q4o7s2 => 'I\'m putting everything on this trade—do or die.';

  @override
  String get q4o7t => 'NO MONEY MANAGEMENT';

  @override
  String get reglagePortfolioSheetSubtitle => 'Account capital and currency';

  @override
  String get reglagePortfolioSheetTitle => 'Capital & portfolios';

  @override
  String get resultDontWorry => 'Don\'t worry';

  @override
  String get resultHeaderSub =>
      'This isn\'t your profile—it\'s just a calculation; nothing is real yet. It all starts now.';

  @override
  String get resultLabelGlobal => 'Global';

  @override
  String get resultLabelProfil => 'Profile';

  @override
  String get resultLabelPsychology => 'Psychology';

  @override
  String get resultLabelStrategy => 'Strategy';

  @override
  String resultStatBullet1(int percent) {
    return '$percent% of traders at this level stagnate or lose due to lack of mathematical rigor.';
  }

  @override
  String resultStatBullet2(int percent) {
    return '$percent% of traders are in the same situation.';
  }

  @override
  String get resultStatBullet3 =>
      'A trader with strong psychology trades better than one who knows 100 strategies.';

  @override
  String get save => 'Save';

  @override
  String get screenshot => 'SCREENSHOT';

  @override
  String get accountPageTitle => 'Account';

  @override
  String get mobileReconnectAfterLogoutTitle => 'You are signed out';

  @override
  String get mobileReconnectAfterLogoutBody =>
      'Sign in again to restore your cloud profile and subscription status. You can also keep using the app on this device without an account.';

  @override
  String get mobileReconnectContinueWithoutAccount =>
      'Continue without signing in';

  @override
  String get profileViewDetailsSection => 'Profile details';

  @override
  String get profileAccountStatusTitle => 'Account status';

  @override
  String get profileAccountStatusPro => 'Pro';

  @override
  String get profileAccountStatusLite => 'Lite';

  @override
  String get profileTrialBadge => 'TRIAL';

  @override
  String profileTrialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left in your trial',
      one: '1 day left in your trial',
    );
    return '$_temp0';
  }

  @override
  String profileTrialEndsOn(String date) {
    return 'Trial ends on $date';
  }

  @override
  String profileTrialEndedOn(String date) {
    return 'Trial ended on $date';
  }

  @override
  String profileProPeriodEndsOn(String date) {
    return 'Renews on $date';
  }

  @override
  String get profileSubscribeButton => 'Upgrade to Pro (from \$8.99/month)';

  @override
  String get profileManageSubscriptionButton => 'Manage subscription';

  @override
  String get profileUpgradeLabel => 'Upgrade';

  @override
  String get profileEditSavedSnack => 'Profile updated';

  @override
  String get profileEditIncompleteFieldsSnack =>
      'Please fill first name, last name, and email';

  @override
  String get profileEditInvalidEmailSnack =>
      'Please enter a valid email address';

  @override
  String get accountAuthSectionTitle => 'Login';

  @override
  String get accountContinueWith => 'Continue with:';

  @override
  String get accountTabLogin => 'Login';

  @override
  String get accountTabSignup => 'Sign up';

  @override
  String get accountFieldEmail => 'Email';

  @override
  String get accountFieldPassword => 'Password';

  @override
  String get accountFieldConfirmPassword => 'Confirm password';

  @override
  String get accountFieldBirthDate => 'Date of birth';

  @override
  String get accountFieldFirstName => 'First name';

  @override
  String get accountFieldLastName => 'Last name';

  @override
  String get accountLoginButton => 'Sign in';

  @override
  String get accountSignupButton => 'Create account';

  @override
  String get authTerminalTagline => 'Master the mind, Master the trade';

  @override
  String get authTerminalCtaLogin => 'Launch terminal';

  @override
  String get authTerminalCtaSignup => 'Create identity';

  @override
  String get webLandingLoginSubtitle => 'Welcome back to Paychek.';

  @override
  String get webLandingSignupSubtitle => 'Join the elite traders.';

  @override
  String get webLandingLoginCta => 'SIGN IN';

  @override
  String get webLandingSignupCta => 'TRY FOR FREE';

  @override
  String get webLandingNoAccountLabel => 'NO ACCOUNT?';

  @override
  String get webLandingRegisterLink => 'SIGN UP';

  @override
  String get webLandingAlreadyMemberLabel => 'ALREADY A MEMBER?';

  @override
  String get webLandingLoginLink => 'SIGN IN';

  @override
  String get authTerminalEncryptedPrefix => 'Encrypted node:';

  @override
  String get authTerminalEncryptedStatus => 'Active';

  @override
  String get authTerminalHintEmail => 'name@terminal.com';

  @override
  String get authTerminalHintPassword => '••••••••';

  @override
  String get accountLoginSnackEmailMissing => 'Login: enter email';

  @override
  String get accountLoginSnackEmailReady => 'Login: email provided';

  @override
  String get accountSignupSnackEmailMissing => 'Sign up: enter email';

  @override
  String get accountSignupSnackFirstNameMissing => 'Sign up: enter first name';

  @override
  String get accountSignupSnackLastNameMissing => 'Sign up: enter last name';

  @override
  String get accountSignupSnackBirthDateMissing =>
      'Sign up: select date of birth';

  @override
  String get accountSignupSnackReady => 'Sign up: form ready';

  @override
  String get accountSignupSnackPasswordMissing => 'Sign up: enter password';

  @override
  String get accountSignupSnackPasswordMismatch =>
      'Sign up: passwords do not match';

  @override
  String get accountSignupSnackPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get accountLoginSnackPasswordMissing => 'Login: enter password';

  @override
  String get accountForgotPasswordLink => 'Forgot password?';

  @override
  String get accountForgotPasswordSnackEmailMissing =>
      'Enter your email above to receive the reset link.';

  @override
  String get accountForgotPasswordSnackSent =>
      'If an account exists for this email, you\'ll receive a link to set a new password.';

  @override
  String get accountForgotPasswordSnackTooManyRequests =>
      'Too many requests. Try again in a few minutes.';

  @override
  String get accountPasswordResetDialogTitle => 'Reset password';

  @override
  String get accountPasswordResetDialogSubtitle =>
      'Enter the email for your Paychek account. We\'ll send you a link to set a new password.';

  @override
  String get accountPasswordResetCta => 'SEND RESET LINK';

  @override
  String get accountPasswordResetBackToLogin => 'BACK TO LOGIN';

  @override
  String get accountPasswordResetSnackEmailMissing =>
      'Enter your email address.';

  @override
  String get accountPasswordResetSentDialogTitle => 'Check your inbox';

  @override
  String get accountPasswordResetSentDialogMessage =>
      'If an account exists for this address, you\'ll receive an email with a link to set a new password. Check your spam folder if you don\'t see it.';

  @override
  String get accountPasswordResetSentDialogCta => 'GOT IT';

  @override
  String get accountAuthSignupSuccess => 'Account created';

  @override
  String get accountAuthLoginSuccess => 'Signed in';

  @override
  String get accountAuthErrorWeakPassword => 'Password is too weak';

  @override
  String get accountAuthErrorEmailInUse => 'This email is already in use';

  @override
  String get accountAuthErrorInvalidEmail => 'Invalid email address';

  @override
  String get accountAuthErrorWrongCredentials => 'Incorrect email or password';

  @override
  String get accountAuthErrorNetwork => 'Network error. Try again.';

  @override
  String get accountAuthErrorGeneric => 'Something went wrong';

  @override
  String get accountAuthErrorRestartOrReload =>
      'Authentication connection lost. Fully stop the app and run again (on web, don’t use hot reload).';

  @override
  String get accountAuthErrorDifferentSignInMethod =>
      'This email is already used with another sign-in method.';

  @override
  String accountAuthErrorWithFirebaseCode(String code) {
    return 'Something went wrong ($code).';
  }

  @override
  String get accountAuthErrorUnknownFirebaseAuth =>
      'Sign-in failed (unknown). Check your connection, try again, or use Paychek in Chrome. In Firebase Console → Authentication, enable Email/Password and the providers you use.';

  @override
  String accountAuthErrorSignInServerMessage(String message) {
    return '$message';
  }

  @override
  String get accountAuthWindowsSignInNotice =>
      'On the Windows desktop app, Firebase sign-in is often unreliable (a known Flutter / Firebase limitation). Use the Paychek mobile app or sign in from your browser.';

  @override
  String get accountAuthWindowsOpenWebsite => 'Open paychek.pro in browser';

  @override
  String get accountSocialAppleAndroidUseGoogle =>
      'Sign in with Apple isn’t set up on Android in this build. Use Google or email, or sign in from the web app.';

  @override
  String get accountSocialAppleUnavailableDesktop =>
      'Sign in with Apple is not available in the Windows/Linux desktop app. Use the web app (Chrome), iPhone, iPad, or Mac.';

  @override
  String get accountSocialGoogleUnavailableDesktop =>
      'Google sign-in is not available on this computer target. Use Chrome, Android, or iOS.';

  @override
  String get accountSocialFacebookUnavailableDesktop =>
      'Facebook sign-in is not available in the Windows/Linux desktop app. Use the web app (Chrome), Android, iOS, or macOS.';

  @override
  String get accountSocialGoogleWebClientMissing =>
      'For Google on phone or tablet: set the Web OAuth client ID in lib/reglage/social_auth_config.dart. On Android, add your app’s SHA-1 fingerprint in Firebase (Project settings → your Android app).';

  @override
  String get paywallTitle => 'Your free trial has ended';

  @override
  String get paywallHeadlineBefore => 'Your free trial ';

  @override
  String get paywallHeadlineAccent => 'has ended';

  @override
  String get paywallUpgradeSubtitle =>
      'Upgrade to Pro to unlock your full trading potential and keep your edge.';

  @override
  String paywallEndedOn(String date) {
    return 'Trial ended on $date.';
  }

  @override
  String get paywallCompareCurrentPlan => 'CURRENT PLAN';

  @override
  String get paywallCompareRecommended => 'RECOMMENDED';

  @override
  String get paywallPlanLiteName => 'Lite';

  @override
  String get paywallPlanProName => 'Pro';

  @override
  String get paywallLiteFeature1 => '30 Trades / month';

  @override
  String get paywallLiteFeature2 => 'Manual entry only';

  @override
  String get paywallLiteFeature3 => 'Standard calendar';

  @override
  String get paywallProFeature1 => 'Unlimited';

  @override
  String get paywallProFeature2 => 'CSV import & manual entry';

  @override
  String get paywallProFeature3 => 'Pro calendar';

  @override
  String get paywallProFeature4 => 'Checklist';

  @override
  String get paywallProFeature5 => 'Analysis builder';

  @override
  String get paywallProFeature6 => 'Strategy page';

  @override
  String get paywallProFeature7 => 'Performance statistics';

  @override
  String get paywallProFeature8 => 'Mental state';

  @override
  String get paywallProFeature9 => 'PDF export';

  @override
  String get paywallMobilePlanAnnualTitle => '1 Year (12 Months)';

  @override
  String get paywallMobilePlanQuarterlyTitle => '3 Months';

  @override
  String get paywallMobilePlanMonthlyTitle => '1 Month';

  @override
  String paywallMobilePlanPerMonthLine(String price) {
    return 'That\'s $price US\$ / month';
  }

  @override
  String get paywallMobilePlanPerMonthPrefix => 'That\'s ';

  @override
  String get paywallMobilePlanPerMonthPriceSuffix => ' US\$';

  @override
  String get paywallMobilePlanPerMonthEnd => ' / month';

  @override
  String paywallMobilePlanTotalLine(String total) {
    return '$total US\$';
  }

  @override
  String get paywallMobilePlanAnnualBilling => 'Billed yearly';

  @override
  String get paywallMobilePlanQuarterlyBilling => 'Every 3 months';

  @override
  String get paywallMobilePlanMonthlyBilling => 'Billed monthly';

  @override
  String get paywallMobilePlanMonthlyCommitment => 'Monthly commitment';

  @override
  String get paywallMobilePlanSavings44 => 'Save 44%';

  @override
  String get paywallMobilePlanPopular => 'Popular';

  @override
  String get paywallMobileCompareFeatureCol => 'Feature';

  @override
  String get paywallMobileRowTrades => 'Trades / month';

  @override
  String get paywallMobileRowEntry => 'Trade entry';

  @override
  String get paywallMobileRowCalendar => 'Calendar';

  @override
  String get paywallMobileRowChecklist => 'Checklist';

  @override
  String get paywallMobileRowAnalysis => 'Analysis generator';

  @override
  String get paywallMobileRowStrategy => 'Strategy page';

  @override
  String get paywallMobileRowStats => 'Performance stats';

  @override
  String get paywallMobileRowMental => 'Mental state';

  @override
  String get paywallMobileRowExport => 'PDF export';

  @override
  String get paywallPriceAnnualHighlight => 'US\$59.99 / year';

  @override
  String get paywallPriceApproxPerMonth => 'That’s about US\$4.99 / month';

  @override
  String paywallTrialEndedBody(String date) {
    return 'Your 7-day free trial (new signup) ended on $date. Without Pro, you are on the Lite plan.';
  }

  @override
  String get paywallLiteLimitedHint =>
      'On Lite, only adding a trade and the calendar stay open. Everything else requires a Pro subscription.';

  @override
  String get paywallContinueFreemium => 'Continue with Lite (limited access)';

  @override
  String get paywallSubscribeButton => 'Subscribe now';

  @override
  String get paywallRestoreButton => 'I already subscribed';

  @override
  String get paywallStoreNotConfigured =>
      'Stripe checkout URL missing. Set it in Admin → Config → Stripe payment link (https://…), enable billing, stay signed in, then retry.';

  @override
  String get paywallRestoreNothingFound =>
      'Still locked: no subscription detected yet. Finish purchase or try again.';

  @override
  String get paywallLegalFooter =>
      'Secured by Stripe • Cancel anytime • Terms of Service';

  @override
  String get paywallGoldPremiumPill => 'Premium Access';

  @override
  String get paywallGoldMarketingHeadline => 'Upgrade to PRO';

  @override
  String get paywallGoldTagline => 'The tool for profitable traders.';

  @override
  String get paywallGoldYourPlanLabel => 'Current';

  @override
  String get paywallGoldLiteColumnCaption => 'Standard';

  @override
  String get paywallGoldProColumnCaption => 'Unlimited';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSupportSection => 'Support';

  @override
  String get settingsSupportCardTitle => 'Support & feedback';

  @override
  String get settingsSupportCardSubtitle =>
      'Email us and browse in-app guides.';

  @override
  String get supportFeedbackTitleLead => 'Support & ';

  @override
  String get supportFeedbackTitleAccent => 'Feedback';

  @override
  String get supportFeedbackSubtitle => 'Questions or ideas? We’re listening.';

  @override
  String get supportActionEmailLabel => 'Email';

  @override
  String get supportActionEmailHint => 'Response within 24h';

  @override
  String get supportActionDocsLabel => 'Docs';

  @override
  String get supportActionDocsHint => 'How-to guides';

  @override
  String get supportActionTwitterLabel => 'X';

  @override
  String get supportActionTwitterHint => 'Community';

  @override
  String get supportFormNewMessage => 'New message';

  @override
  String get supportFormKindLabel => 'Request type';

  @override
  String get supportFormKindAccount => 'Account';

  @override
  String get supportFormKindBilling => 'Billing';

  @override
  String get supportFormKindFeature => 'Feature';

  @override
  String get supportFormKindOther => 'Other';

  @override
  String get supportFormEmailLabel => 'Your email';

  @override
  String get supportFormEmailHint => 'name@example.com';

  @override
  String get supportFormDescriptionLabel => 'Description';

  @override
  String get supportFormDescriptionHint => 'Message details…';

  @override
  String get supportFormSubmit => 'Send now';

  @override
  String get supportFormSubmitSuccess =>
      'Thank you — your message was sent successfully.';

  @override
  String get supportFormSubmitSuccessPartial =>
      'Thank you — your message was sent (attachment not uploaded).';

  @override
  String get supportFormSubmitDone =>
      'If your mail app didn’t open, try again or email us directly.';

  @override
  String get supportFormErrorEmail => 'Enter an email address.';

  @override
  String get supportFormErrorDescription => 'Add a description.';

  @override
  String get supportFormMailSubjectPrefix => 'Paychek support';

  @override
  String get supportFormMailBodyIntro => 'Message sent from Paychek app:';

  @override
  String get supportFormAttachmentLabel => 'Attachment (optional)';

  @override
  String get supportFormAttachmentPick => 'Add photo or PDF';

  @override
  String get supportFormAttachmentHint => 'PDF or image, max 10 MB';

  @override
  String get supportFormAttachmentRemove => 'Remove file';

  @override
  String get supportFormAttachmentSignInHint =>
      'Sign in to attach a file — or use the Email card without an attachment.';

  @override
  String get supportFormAttachmentTooLarge => 'File is too large (max 10 MB).';

  @override
  String get supportFormAttachmentInvalidExtension =>
      'Only PDF, JPG, PNG or WebP are allowed.';

  @override
  String get supportFormAttachmentReadFailed =>
      'Could not read this file. Try again.';

  @override
  String get supportFormSubmitFirestoreDone =>
      'Thanks — your message was saved. The team can see it in the admin console.';

  @override
  String get supportFormSubmitSending => 'Sending…';

  @override
  String get supportFormSubmitError =>
      'Could not send. Check your connection or try again.';

  @override
  String supportErrorEmailOpenFailed(String error) {
    return 'Could not open email: $error';
  }

  @override
  String get supportErrorEmailAppUnavailable =>
      'Could not open the email app. Make sure a mail app is installed.';

  @override
  String get supportFormSubmitSavedPartialAttachment =>
      'Your message was saved but the attachment did not upload (network, timeout, or Storage not enabled). Check Firebase or try again later.';

  @override
  String get supportQuickHelpTitle => 'Quick help';

  @override
  String get supportFaqWhereDataQ => 'Where is my data?';

  @override
  String get supportFaqWhereDataA =>
      'Your data is stored on this device (preferences, journal, portfolios). Signing out or using Settings > Erase data removes it locally — export PDFs if you need archives.';

  @override
  String get supportFaqFeatureQ => 'Want a new feature?';

  @override
  String get supportFaqFeatureA =>
      'Use the form above with “Suggest an idea”. We read every submission.';

  @override
  String get supportStatusLabel => 'Technical status';

  @override
  String get supportStatusOperational => 'All systems operational';

  @override
  String get helpCenterTitle => 'Help Center';

  @override
  String get helpCenterSubtitle =>
      'Find quick answers and explanations about using the app.';

  @override
  String get helpCenterSearchHint => 'Search…';

  @override
  String get helpCenterVersionMobile => 'Mobile version';

  @override
  String get helpCenterVersionWeb => 'Web version';

  @override
  String get helpCenterEmptyResults => 'No results.';

  @override
  String get helpCenterArticleAddTradeTitle => 'Add a trade';

  @override
  String get helpCenterArticleAddTradeBody =>
      'Go to the Add tab, fill in the fields (asset, entry, stop, target…), then save. You can attach a screenshot if needed.';

  @override
  String get helpCenterArticleEditTradeTitle => 'Trade page';

  @override
  String get helpCenterArticleEditTradeBody =>
      'Guide : Maîtriser votre Journal de Trading (Page Trade)\nLa page Trade est le centre d\'archivage intelligent de Paychek. Elle ne se contente pas de lister vos opérations ; elle les organise pour vous offrir une vision claire de votre progression, du trade individuel à la performance mensuelle.\n\n[img:assets/help_center/trade_page_header_filters.png]\n\n1. Tableau de Bord de Période (Header)\nEn haut de votre journal, vous disposez d\'un résumé instantané de la période sélectionnée :\n\nProfit Net : Votre résultat financier net en dollars et son impact en pourcentage sur votre capital (ex: +1070,00\$ / +53,50%).\n\nLe Win Rate Ring : L\'anneau central affiche votre pourcentage de réussite global. C\'est l\'indicateur visuel immédiat de la santé de votre trading.\n\nCompteur de Trades : Le détail précis du nombre de positions Gagnantes (G), Perdantes (P) et à l\'équilibre (Br).\n\n2. Navigation et Filtres Temporels\nPersonnalisez votre vue selon votre besoin d\'analyse grâce aux sélecteurs rapides :\n\nSélecteur 1D / 1S / 1M / ALL : Basculez instantanément entre une vue journalière, hebdomadaire, mensuelle ou l\'historique complet.\n\nFiltres de statut : Isolez vos trades Gagnants, Perdants ou Breakeven d\'un seul clic pour étudier des comportements spécifiques.\n\nActifs les plus tradés : Visualisez rapidement vos statistiques sur vos instruments préférés (ex: XAUUSD, EURUSD).\n\n[img:assets/help_center/trade_page_period_pdf_report.png]\n\n3. Structure en Accordéons et Rapports PDF\nL\'interface utilise un système de \"replier/déplier\" pour une lecture fluide et des options d\'exportation à tous les niveaux :\n\nRapports de Période (Jour/Semaine/Mois) : Chaque bloc de date (ex: \"14 Mars\") affiche un résumé de la performance du jour.\n\nEn cliquant sur l\'icône PDF à côté de la date, vous téléchargez un rapport complet de cette période spécifique. Idéal pour vos bilans de fin de semaine ou de mois.\n\nRapports de Trade Individuel : Cliquez sur un trade pour le déplier et voir ses détails (Heures, Session, Entry/Exit).\n\nChaque trade possède son propre bouton PDF. Ce document génère une fiche technique pro avec votre graphique et vos scores de discipline.\n\n[img:assets/help_center/trade_page_rings_week_view.png]\n\n4. Analyse visuelle par Ring\nChaque ligne (journée ou trade) est accompagnée d\'un Ring (anneau) :\n\nPour une journée, le ring représente le Win Rate global du jour.\n\nCela vous permet d\'identifier en une seconde vos journées \"rouges\" ou \"vertes\" sans avoir à lire chaque ligne de trade.\n\n[img:assets/help_center/trade_page_options_menu.png]\n\n5. Options de Gestion et Correction (Les 3 points)\nParce qu\'une erreur de saisie peut arriver, Paychek vous donne un contrôle total sur vos archives. À côté de l\'icône PDF de chaque fiche trade, vous trouverez un menu \"Options\" (représenté par 3 points verticaux) :\n\nModifier le Trade : Vous permet de réouvrir le formulaire de saisie pour corriger un prix, changer l\'heure, ajouter un screenshot oublié ou ajuster vos scores de discipline.\n\nSupprimer le Trade : Efface définitivement l\'enregistrement de votre journal.\n\nAttention : La suppression d\'un trade mettra à jour instantanément vos statistiques globales, votre Win Rate et votre capital dans les pages Trade et Performance.';

  @override
  String get helpCenterArticleChecklistTitle => 'Checklist';

  @override
  String get helpCenterArticleChecklistBody =>
      '📋 Checklist\n\n[img:assets/help_center/checklist_routine_discipline.png]\n\n1. Understanding the progress ring\nThe colored circle at the top of your screen is your readiness indicator.\n\n- Real-time progress: each ticked box moves the percentage forward.\n- Your checklist ring is not only on Routine — it stays in sync on your main Dashboard.\n- The gold standard: we recommend never opening a position unless your ring is at 100%. A trade taken with an incomplete checklist is often an emotional trade.\n\n2. Customize your routine\nEvery trader is unique. Paychek lets you build your own verification system.\n\n- Add a section: tap “+ Add a section” at the bottom to create a category (e.g. morning routine, economic news, post-session).\n- Manage items (⋯ menu):\n  - Add a task: open the three-dot menu next to a section title to insert a new checkpoint.\n  - Delete / edit: if a rule no longer fits your strategy, remove it to keep the UI clean.\n\n3. Default sections\nTo help you get started, we include three pillars:\n\n- Technical Analysis: validate your confluences (trend, S/R, indicators).\n- Risk Management: confirm your stop-loss is set and your risk per trade is respected.\n- Psychology: a quick check that you are not in revenge mode or euphoria.';

  @override
  String get helpCenterArticleCalendarTitle => 'Calendar';

  @override
  String get helpCenterArticleCalendarBody =>
      '📅 Guide: Calendar & performance analysis\n\nThe Paychek Calendar is your main steering tool. It turns raw data into a visual map of your success and discipline.\n\n[img:assets/help_center/calendar_overview.png]\n\n1. Month overview\nColor coding: Green cells show net profit, red cells a loss, and gray cells days with no activity.\n\nQuick summary: Above the calendar, see your win rate, trade count, and total monthly P&L at a glance.\n\nMonthly objective: Watch the progress bar to see how far you are from your financial goal. Tap the settings icon to change your target.\n\n[img:assets/help_center/calendar_monthly_objective.png]\n\n2. Expandable menu (deep analysis)\nTap any month header to open detailed analysis.\n\n[img:assets/help_center/calendar_deep_analysis.png]\n\nDiscipline rings: View your average discipline scores for the month (plan followed, checklist completed, mental state).\n\nSession breakdown: See performance by timezone — Asia, Europe, and US. Great for spotting which part of the day pays best for you.\n\nInteractive sparkline (performance curve):\n- Hover the line to pinpoint a trade (on mobile, drag along the curve with your finger).\n- Tap a point on the curve to open that trade’s full record instantly.\n\n3. Session statistics (sidebar)\nTo the right of your calendar, your consistency stats:\n\nCumulative performance: How your capital evolves day by day.\n\nBest day: Your largest daily gain of the month.\n\nAverage day: What you gain or lose on average per day.\n\n[img:assets/help_center/calendar_trades_month_report.png]\n\n4. PDF export 📄\nAt the top right of the Calendar page, the PDF icon generates a professional report in one tap.\n\nWhat’s inside: The report includes the visual calendar, the performance curve, and a recap of your discipline averages.';

  @override
  String get helpCenterArticleMentalStateTitle => 'Mental state';

  @override
  String get helpCenterArticleMentalStateBody =>
      'Guide: Mental state — tailor your psychology\n\nRoughly 80% of trading success is psychology. The Mental state page lets you measure how you feel and see how emotions affect your results.\n\n[img:assets/help_center/mental_state_dashboard.png]\n\n1. Global score (The Ring)\nThe central ring shows your “Solid Balance”. It updates from all your indicators (emotions, rest, routines). The higher the score, the more you are in a mindset suited to trading.\n\n2. Personalized impact (gear ⚙️)\nEvery trader is different. Paychek lets you define your own rules:\n\n[img:assets/help_center/mental_state_adjust_impact.png]\n\n- Impact nature: open a criterion’s gear to set Positive (+) or Negative (−). Example: if excitement is dangerous for you, set it to Negative.\n\n- Global impact (%): the slider sets how much that criterion weighs on your global score. Crank it up for what matters most; lower it for secondary criteria.\n\n3. Sections & emotions\n\n[img:assets/help_center/mental_state_section_controls.png]\n\n- Edit / delete: pencil to rename an emotion or indicator; trash to remove it.\n\n- Section toggle (ON / OFF 100%): turn off an entire section (e.g. My Routines). When off, it no longer counts toward your daily global score.\n\n- Add (+): create your own indicators to match your routine.\n\n4. Score calendar & time window\nThe mini-calendar shows your mental score for past days.\n\n- Session settings (⚙️): set a start time and an end time.\n\n- Day mode: track from morning to evening (full-day style window).\n\n- Session mode: focus on trading hours only (e.g. 3:30 PM – 10:00 PM).';

  @override
  String get helpCenterArticleExportPdfTitle => 'Export a PDF';

  @override
  String get helpCenterArticleExportPdfBody =>
      'From Trade or Performance, use Export PDF. If it fails, check permissions and try again.';

  @override
  String get helpCenterArticleResetDataTitle => 'Erase local data';

  @override
  String get helpCenterArticleResetDataBody =>
      'In Settings > Data, you can erase data stored on this device. This is irreversible; restarting the app is recommended afterward.';

  @override
  String get helpCenterArticleMyStrategyTitle => 'My Strategy — Playbook';

  @override
  String get helpCenterArticleMyAnalysisTitle => 'My Analysis — Trading plans';

  @override
  String get helpCenterArticleMyAnalysisBody =>
      '🔬 My Analysis: Build Your Trading Plans\n\nThe My Analysis page lets you build a full roadmap before you enter the market. By quantifying each technical element, Paychek calculates a global confidence score to validate your setup.\n\n[img:assets/help_center/analyse_trend_sheet.png]\n\n1. Trend card (context)\nDefine the frame for your opportunity:\n\nAsset & name: Use (+) to name your analysis and the instrument (e.g. EUR/USD — Weekly Swing Plan).\n\nDirection & phase: Choose your bias (Buy, Sell, or Watch) and the current market phase (Accumulation, Impulse, Distribution).\n\nConfidence slider: Set how certain you feel for this section. Open the gear (⚙️) to adjust this card’s impact (weight %) on the final report confidence.\n\n[img:assets/help_center/analyse_card_controls.png]\n\nCustomization: Use the pencil to edit available timeframes or phases, and Duplicate to compare several analyses on different timeframes in the same section.\n\n2. Technical sections (Structure, SMC, Indicators, Volume)\nEveryone trades differently. Turn cards on or off with the ON/OFF switch:\n\n[img:assets/help_center/analyse_technical_cards.png]\n\nStructure: Log support and resistance. Tick if a level was tested more than twice to strengthen relevance.\n\nSMC & Liquidity: Record Order Blocks, Fair Value Gaps (FVG), and Fibonacci levels.\n\nIndicators & Volume profile: Detail RSI/MACD signals or Point of Control (POC) zones.\n\nScreenshot: Attach a chart capture to illustrate your plan visually.\n\n3. Generating the report\nWhen your analysis is ready, tap Report.\n\n[img:assets/help_center/analyse_summary_report.png]\n\nGlobal confidence ring: The final ring is computed from your sliders and their impact weights.\n\nDynamic color coding: The validated report at the bottom uses a color that matches your direction: green (Buy), red (Sell), or yellow (Watch).\n\n[img:assets/help_center/analyse_report_embedded.png]\n\n4. Managing reports\nHistory: Reports are saved and tied to your instruments.\n\nActions: You can edit (pencil), delete (trash), or export a professional PDF of your analysis to archive or share.\n\n[img:assets/help_center/analyse_report_pdf.png]';

  @override
  String get helpCenterArticlePerformanceTitle =>
      'Performance — Trading scanner';

  @override
  String get settingsLogoutButton => 'Sign out';

  @override
  String get settingsLogoutSnack => 'You\'re signed out.';

  @override
  String get settingsLogoutSnackPartial =>
      'Profile cleared on this device. If your account still appears, check your network or restart the app.';

  @override
  String get splashTagline => 'Master the mind, Master the trade';

  @override
  String get statsAvgGain => 'Average gain';

  @override
  String get statsPsychSub => 'Plan followed';

  @override
  String get statsPsychology => 'Psychology';

  @override
  String get statsRR => 'R/R ratio';

  @override
  String get statsSectionTitle => 'STATISTICS';

  @override
  String get statsStrategy => 'Strategy';

  @override
  String get statsStrategySub => 'Criteria validated';

  @override
  String get strategieAlertSignal => 'ALERT SIGNAL';

  @override
  String get strategieDescription => 'DESCRIPTION';

  @override
  String get strategieDescriptionHint => 'e.g. Low volatility';

  @override
  String get strategieEditSessionTitle => 'Edit session';

  @override
  String get strategieHintEntry => 'Where to click BUY/SELL?';

  @override
  String get strategieHintIndicatorTag => 'e.g. RSI';

  @override
  String get strategieHintInvalidation => 'Where is the scenario wrong?';

  @override
  String get strategieHintManagement => 'How to secure the position?';

  @override
  String get strategieHintPattern => 'e.g. Double Bottom';

  @override
  String get strategieHintSignal => 'Trigger…';

  @override
  String get strategieHintTarget => 'Final target or liquidity zones';

  @override
  String get strategieHintTimeframeTag => 'e.g. M15';

  @override
  String get strategieIndicators => 'INDICATORS';

  @override
  String get strategieModelName => 'MODEL NAME';

  @override
  String get strategieNewSessionTitle => 'New session';

  @override
  String get strategiePatternFigure => 'PATTERN / FIGURE';

  @override
  String get strategieRuleEntryPrecise => 'PRECISE ENTRY';

  @override
  String get strategieRuleInvalidation => 'INVALIDATION (STOP LOSS)';

  @override
  String get strategieRuleManagement => 'MANAGEMENT (BREAKEVEN / PARTIALS)';

  @override
  String get strategieRuleTarget => 'TARGET (TAKE PROFIT)';

  @override
  String get strategieSessionName => 'SESSION NAME';

  @override
  String get strategieSetupColor => 'COLOR';

  @override
  String get strategieSetupEditTitle => 'Edit setup';

  @override
  String get strategieSetupNewTitle => 'New setup';

  @override
  String get strategieTimeEndOptionalLabel => 'END (OPTIONAL)';

  @override
  String get strategieTimeStartLabel => 'START';

  @override
  String get strategieTimeframes => 'TIMEFRAMES';

  @override
  String get strategieZoneNoTrade => 'No trade';

  @override
  String get strategieZoneTrade => 'Trade';

  @override
  String get strategieZoneType => 'ZONE TYPE';

  @override
  String get strategiePagePlaybookIntro =>
      'Your trading plan (Playbook). Review these rules before each session to stay disciplined and focused.';

  @override
  String get analyseReportTitle => 'Report';

  @override
  String get strategieGestionCaptionMaximum => 'Maximum';

  @override
  String get strategieGestionCaptionMinimum => 'Minimum';

  @override
  String get strategieSectionSetupsAndModels => 'SETUPS & TEMPLATES';

  @override
  String get strategieSectionTradeCalendar => 'TRADE CALENDAR';

  @override
  String get strategieCalendarNeedSetupForUsage =>
      'Add a setup above to track which days you used it.';

  @override
  String strategieCalendarUsageForSetup(String name) {
    return 'Usage — $name';
  }

  @override
  String get strategieCalendarUsageTooltip =>
      'Mark or clear this day for this setup (same name as in Add trade).';

  @override
  String get strategieCalendarDotsExplain =>
      'One dot per strategy used that day, from your trades (Add trade, entry date).';

  @override
  String get strategieSetupNavPrevious => 'PREVIOUS';

  @override
  String get strategieSetupNavNext => 'NEXT SETUP >';

  @override
  String get strategieSheetSetupsTitle => 'Setups & templates';

  @override
  String get strategieMenuDisableFactors => 'Disabled';

  @override
  String get strategieManageTemplates => 'Manage templates';

  @override
  String get strategieDuplicateSetup => 'Duplicate a setup';

  @override
  String get strategieMesReglesDraftHint => 'New rule...';

  @override
  String get strategieSetupRemoveFromDashboard => 'Remove from dashboard';

  @override
  String get strategieSetupShowOnDashboard => 'Show on dashboard';

  @override
  String get strategiePdfPlaybookBlurbShort =>
      'Your trading plan (Playbook). Review these rules before each session.';

  @override
  String get strategiePdfFooterNote =>
      'Golden rules: reference texts (not persisted). Risk, sessions, and setups: saved data.';

  @override
  String get strategiePdfTableSession => 'Session';

  @override
  String get strategiePdfTableDescription => 'Description';

  @override
  String get strategiePdfTableSchedule => 'Schedule';

  @override
  String get strategiePdfTechnicalContext => 'Technical context';

  @override
  String get strategiePdfAlertSignal => 'Alert signal';

  @override
  String get strategiePdfFileNamePrefix => 'my_strategy';

  @override
  String strategiePdfExportError(String error) {
    return 'Unable to create PDF: $error';
  }

  @override
  String get symbolHint => 'e.g. Fr, ₣';

  @override
  String get symbolLabel => 'Symbol';

  @override
  String get tradeColEndingBalance => 'Ending balance';

  @override
  String get tradeColPnl => 'PnL';

  @override
  String get tradeColResult => 'Result';

  @override
  String get tradeColStartingBalance => 'Starting balance';

  @override
  String get tradeColTotalGain => 'Total gain';

  @override
  String get tradeColTotalGainPct => 'Total gain %';

  @override
  String get tradeColTrade => 'Trade #';

  @override
  String get tradeDeleteConfirmBody => 'This action is permanent.';

  @override
  String get tradeDeleteConfirmTitle => 'Delete this trade?';

  @override
  String get tradeReturn => 'Trade return';

  @override
  String get tradeActionsTooltip => 'Actions';

  @override
  String get tradeAverageShort => 'AVERAGE';

  @override
  String tradeDayTradeNumber(int n) {
    return 'Trade #$n today';
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
  String get tradeEditMenu => 'Edit';

  @override
  String get tradeExportPdfTooltip => 'Export PDF';

  @override
  String get tradeFilterAll => 'All';

  @override
  String get tradeFilterBreakeven => 'Breakeven';

  @override
  String get tradeFilterLoser => 'Losers';

  @override
  String get tradeFilterOpenPosition => 'Open positions';

  @override
  String get tradeFilterWinner => 'Winners';

  @override
  String tradeSummaryBreakdownShort(int w, int l, int b) {
    return 'W:$w  L:$l  B:$b';
  }

  @override
  String tradeSummaryBreakdownWithOpen(int w, int l, int b, int o) {
    return 'W:$w  L:$l  B:$b  O:$o';
  }

  @override
  String get tradeGainShort => 'NET';

  @override
  String get tradeLabelChecklist => 'Checklist';

  @override
  String get tradeLabelDuration => 'Duration';

  @override
  String get tradeLabelEntry => 'Entry';

  @override
  String get tradeLabelEtat => 'State';

  @override
  String get tradeLabelExit => 'Exit';

  @override
  String get tradeLabelHours => 'Hours';

  @override
  String get tradeLabelPlan => 'Plan';

  @override
  String get tradeLabelSession => 'Session';

  @override
  String get tradeLabelStrategie => 'Strategy';

  @override
  String get tradeLabelNews => 'News';

  @override
  String get tradeMindsetFeeling => 'Feeling';

  @override
  String get tradeMindsetPrinciple => 'Principle';

  @override
  String get tradeMonthTitle => 'Month';

  @override
  String get tradeMostTradedHeading => 'Most traded assets';

  @override
  String get tradeNotRespected => 'Not followed';

  @override
  String tradeOpenPositionLine(String when) {
    return 'Open position • Entry $when';
  }

  @override
  String get tradePdfAnalysePostTrade => 'Post-trade review';

  @override
  String get tradePdfBarresSemaine => 'Week bars';

  @override
  String get tradePdfCloture => 'Closed';

  @override
  String get tradePdfPositionOpen => 'Open position';

  @override
  String tradePdfDatePrefix(String when) {
    return 'Date: $when';
  }

  @override
  String tradePdfDetailsTitle(String pair) {
    return 'Trade details ($pair)';
  }

  @override
  String get tradePdfEtatPsychologique => 'Psychological state';

  @override
  String get tradePdfTags => 'Tags';

  @override
  String get tradeTagsSection => 'TAG';

  @override
  String get tradePdfExportDayTitle => 'Trades (day)';

  @override
  String get tradePdfExportMonthTitle => 'Trades (month)';

  @override
  String get tradePdfExportWeekTitle => 'Trades (week)';

  @override
  String get tradePdfGainNet => 'Net P&L';

  @override
  String get tradePdfImpactCapital => 'Capital impact';

  @override
  String get tradePdfMoyenne => 'Average';

  @override
  String get tradePdfNonRespecte => 'Not followed';

  @override
  String get tradePdfPeriode => 'Period';

  @override
  String get tradePdfQualiteMoyennes => 'Quality (averages)';

  @override
  String tradePdfScreenshotTitle(String pair) {
    return 'Screenshot — $pair';
  }

  @override
  String get tradePdfSessions => 'Sessions';

  @override
  String get tradePdfSparklineMois => 'Month sparkline';

  @override
  String get tradePdfTrades => 'Trades';

  @override
  String get tradePdfWinRate => 'Win rate';

  @override
  String tradePctOfCapital(String percent) {
    return '$percent% of capital';
  }

  @override
  String get tradeScreenshotLoadError => 'Could not load image';

  @override
  String get tradeScreenshotUnavailableWeb => 'Screenshot unavailable (web)';

  @override
  String get tradeSectionChecklist => 'Checklist';

  @override
  String get tradeSectionEtat => 'State';

  @override
  String get tradeSectionPlan => 'Plan';

  @override
  String get tradeSectionStrategie => 'Strategy';

  @override
  String tradeStrategieNonRespectUnmapped(String id) {
    return 'Strategy detail ($id)';
  }

  @override
  String get tradeSessionAsia => 'Asia';

  @override
  String get tradeSessionEurope => 'Europe';

  @override
  String get tradeSessionLate => 'After hours';

  @override
  String get tradeSessionUs => 'US';

  @override
  String get tradeSideBreakevenShort => 'BREAKEVEN';

  @override
  String get tradeSideBuyLong => 'Buy';

  @override
  String get tradeSideBuyShort => 'BUY';

  @override
  String get tradeSideSellLong => 'Sell';

  @override
  String get tradeSideSellShort => 'SELL';

  @override
  String get tradeSummaryProfitNet => 'NET P&L';

  @override
  String get tradeSummaryTrades => 'TRADES';

  @override
  String get tradeSummaryWinRate => 'WIN RATE';

  @override
  String get tradeTotalUpper => 'TOTAL';

  @override
  String get tradeTradesListHeading => 'Trades';

  @override
  String get tradeTradesMonthHeading => 'Trades (month)';

  @override
  String get tradeTradesWeekHeading => 'Trades (week)';

  @override
  String get tradeWeekTitle => 'Week';

  @override
  String get tradeWinDayRingSubtitle => 'WIN (day)';

  @override
  String get tradeWinrateLabel => 'Win rate';

  @override
  String get settingsTradingWeek5 => '5 days (Mon–Fri)';

  @override
  String get settingsTradingWeek7 => '7 days (Mon–Sun)';

  @override
  String get settingsTradingWeekSubtitle =>
      '5 days for traditional markets (Mon–Fri), 7 days for a full calendar week (e.g. crypto).';

  @override
  String get settingsTradingWeekTitle => 'Displayed week';

  @override
  String get settingsDashboardCardSubtitle =>
      'Customize home: sections and order';

  @override
  String get settingsDashLayoutTitle => 'Home sections';

  @override
  String get settingsDashLayoutReorderHint =>
      'Drag the handles to reorder. Turn off a section to hide it on the home screen.';

  @override
  String get settingsDashOpenHomeButton => 'View home';

  @override
  String get settingsDashSectionCapital => 'Capital and win rate';

  @override
  String get settingsDashSectionChecklist => 'Checklist';

  @override
  String get settingsDashSectionAnalyse => 'Analysis';

  @override
  String get settingsDashSectionEtat => 'Mental state';

  @override
  String get settingsDashSectionStrategie => 'Strategy';

  @override
  String get settingsDashSectionWeekly => 'Weekly performance';

  @override
  String get settingsDashSectionEvolution => 'Capital evolution';

  @override
  String get settingsDashSectionLens => 'Paychek Lens';

  @override
  String get tradingSection => 'Trading';

  @override
  String get settingsCgvSection => 'Legal';

  @override
  String get settingsCgvPageTitle => 'Terms of sale';

  @override
  String get settingsCgvRowTitle => 'Terms of sale';

  @override
  String get settingsCgvRowSubtitle => 'Read the full terms in the app';

  @override
  String get settingsCgvDocHeading => 'TERMS OF SALE (TOS) - PAYCHEK';

  @override
  String get settingsCgv1Title => '1. Subject matter';

  @override
  String get settingsCgv1Body =>
      'These terms of sale govern the subscription to “Pro” (Premium) access to the Paychek application, a trading journal and risk management tool. Access is provided on a monthly, quarterly, or annual subscription, automatically renewed at each billing period until cancelled.';

  @override
  String get settingsCgv2Title => '2. Services provided';

  @override
  String get settingsCgv2Body =>
      'Premium access unlocks all features of the application (advanced statistics, automatic risk calculation, data export). Access is tied to the user account created at registration.';

  @override
  String get settingsCgv3Title => '3. Pricing and payment';

  @override
  String get settingsCgv3Body =>
      'Direct subscription: Pro plans are billed in US dollars via Stripe, with automatic renewal until cancelled:\n• \$8.99 / month\n• \$20.97 / 3 months\n• \$59.99 / year\n\nPartner offer: Access may be provided free of charge if the user meets the referral conditions with one of our partners (Prop Firm or Broker).\n\nPaychek reserves the right to change its prices at any time for new customers.';

  @override
  String get settingsCgv4Title => '4. Right of withdrawal and refund';

  @override
  String get settingsCgv4Body =>
      'In accordance with the law on digital products:\n\nBecause of the digital nature of the service and immediate access to content upon payment, the user agrees that the service starts immediately and expressly waives the 14-day right of withdrawal.\n\nNo refund will be made once Premium access is activated, except in the event of a major technical failure that makes the application unusable.';

  @override
  String get settingsCgv5Title => '5. Specific clause “Partner offer”';

  @override
  String get settingsCgv5Body =>
      'Access provided through a partner is subject to validation of the affiliation by that partner.\n\nIf the partner refuses the affiliation (for non-compliance with deposit or trading rules), Paychek reserves the right to revoke Premium access or to request payment at the applicable Pro rates.';

  @override
  String get settingsCgv6Title => '6. Risk warning (Trading)';

  @override
  String get settingsCgv6Body =>
      'Paychek is not a financial advisor. The application is a technical tool for management and analysis.\n\nTrading involves a high risk of loss of capital. The user is solely responsible for their trading decisions.\n\nPaychek cannot be held liable for financial losses suffered by the user in the financial markets.';

  @override
  String get settingsCgv7Title => '7. Service availability';

  @override
  String get settingsCgv7Body =>
      'Paychek strives to maintain access 24/7. However, we are not responsible for interruptions due to maintenance or failure of third-party servers (Firebase, Google Cloud).';

  @override
  String get settingsCgv8Title => '8. Data protection';

  @override
  String get settingsCgv8Body =>
      'Users’ trading data is strictly confidential and is never resold. It is stored securely via our technical service providers.';

  @override
  String get settingsPrivacyRowTitle => 'Privacy policy';

  @override
  String get settingsPrivacyRowSubtitle =>
      'Personal data, cookies, and your rights';

  @override
  String get settingsPrivacyPageTitle => 'Privacy policy';

  @override
  String get settingsPrivacyDocHeading => 'PRIVACY POLICY — PAYCHEK';

  @override
  String get settingsDataResetSection => 'Data';

  @override
  String get settingsDataResetTitle => 'Erase all local data';

  @override
  String get settingsDataResetDescription =>
      'If you’ve used Paychek for a while and want to start again from scratch (similar to reinstalling the app), you can wipe everything stored on this device: trades, analyses, journal, local profile, dashboard layout, trial anchor on device, etc.\n\nYour language and “week displayed” setting are kept.\n\nFully closing and reopening the app is recommended so in‑memory items (e.g. checklist) refresh.';

  @override
  String get settingsDataResetButton => 'Erase all local data';

  @override
  String get settingsDataResetDialogTitle => 'Erase all local data?';

  @override
  String get settingsDataResetDialogBody =>
      'This cannot be undone. Local Paychek data on this device will be deleted. Your account session may remain signed in to Firebase; only local copies are removed.\n\nClose and reopen the app afterward if anything still looks cached.';

  @override
  String get settingsDataResetDialogCancel => 'Cancel';

  @override
  String get settingsDataResetDialogConfirm => 'Erase';

  @override
  String get settingsDataResetSuccess =>
      'Local data erased. Close and reopen the app if needed.';

  @override
  String get validate => 'Confirm';

  @override
  String get winrate => 'Win rate';
}
