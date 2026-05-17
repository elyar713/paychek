// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get addPortfolio => 'Portfolio hinzufügen';

  @override
  String get ajouterTradeCapitalRequiredHint =>
      'Legen Sie ein Kapital (Fragebogen) fest, um die Berechnung zu ermöglichen.';

  @override
  String get ajouterTradeCapitalGainEnterExitToShowPnl =>
      'Geben Sie den Ausstiegspreis ein, um die Gewinn- und Verlustrechnung anzuzeigen.';

  @override
  String get ajouterTradeCapitalGainOpenPositionNote =>
      'Offene Position: Der geschätzte Gewinn und Verlust wird angezeigt, wenn Sie schließen.';

  @override
  String get ajouterTradeCommissionFeesLabel => 'Gebühren (Provision)';

  @override
  String get ajouterTradeFillSuggestedLot => 'Füllen Sie das Los';

  @override
  String get ajouterTradeSizingEstimationFootnote =>
      '* Schätzungen basieren auf dem gespeicherten Kapital; Kontrakt-/CFD-Werte sind annähernd.';

  @override
  String get ajouterTradeScreenshotHelp =>
      'Fügen Sie ein Diagramm oder einen Setup-Screenshot hinzu (optional).';

  @override
  String get ajouterTradeCsvChooseSoftware => 'Choisir un logiciel';

  @override
  String get ajouterTradePageTitle => 'Handel hinzufügen';

  @override
  String get ajouterTradeErrorQtyPositive =>
      'Geben Sie eine Positionsgröße größer als 0 ein.';

  @override
  String get ajouterTradeErrorEntryPrice =>
      'Geben Sie einen gültigen Eintrittspreis ein (größer als 0).';

  @override
  String get ajouterTradeErrorExitOrFlags =>
      'Geben Sie einen gültigen Ausstiegspreis ein oder überprüfen Sie Breakeven/Offene Position, wenn der Ausstieg noch nicht bekannt ist.';

  @override
  String get ajouterTradePsychTagBlind => 'Blind';

  @override
  String get ajouterTradeCapitalGainHeading => 'KAPITAL & GEWINN';

  @override
  String get ajouterTradeMindsetPrompt =>
      'Sie haben diesen Handel abgeschlossen mit:';

  @override
  String get ajouterTradeDisciplineSettingsTooltip =>
      'Einstellungen: Gefühls- und Aktivabschnitte.';

  @override
  String get ajouterTradeSaveAndNext => 'Speichern und weiter';

  @override
  String ajouterTradeLiteMonthlyLimitReached(int max) {
    return 'Lite: Es können höchstens $max Trades pro Kalendermonat erfasst werden. Upgrade auf Pro für unbegrenzte Einträge.';
  }

  @override
  String ajouterTradeLiteMonthlyLimitImportSkipped(int skipped, int max) {
    return '$skipped Trade(s) nicht importiert: Lite erlaubt höchstens $max Trades pro Kalendermonat.';
  }

  @override
  String get ajouterTradeSectionEtatMoment => 'AKTUELLER STAND';

  @override
  String get ajouterTradeImagePickerClose => 'Schließen';

  @override
  String get ajouterTradeImagePickerTitle => 'Bildquelle';

  @override
  String get ajouterTradeGallery => 'Galerie';

  @override
  String get ajouterTradeCamera => 'Kamera';

  @override
  String get ajouterTradeFeedbackAlmost100 =>
      'Sie sind nahe bei 100 %: Wenden Sie weiterhin jeden Punkt an.';

  @override
  String get ajouterTradeFeedbackTickEach =>
      'Kreuzen Sie jeden zutreffenden Punkt an (Mehrfachauswahl).';

  @override
  String get ajouterTradeChoicesSaved => 'Gespeicherte Auswahl:';

  @override
  String ajouterTradeNonRespectedSemantic(Object label) {
    return 'Nicht gefolgt: $label';
  }

  @override
  String ajouterTradeDisciplineRespectBase(int pct) {
    return 'Respektiere $pct %';
  }

  @override
  String ajouterTradeDisciplineRespectNonList(Object items, Object more) {
    return '· Nicht gefolgt: $items$more';
  }

  @override
  String get ajouterTradeFieldActif => 'Vermögenswert';

  @override
  String get ajouterTradeFieldEntree => 'Eintrag';

  @override
  String get ajouterTradeFieldSortie => 'Ausfahrt';

  @override
  String get ajouterTradeCheckboxBreakeven => 'Die Gewinnzone erreichen';

  @override
  String get ajouterTradeCheckboxPositionOpen => 'Offene Position';

  @override
  String get ajouterTradeCheckboxAvantNews => 'Vor News';

  @override
  String get ajouterTradeCheckboxApresNews => 'Nach News';

  @override
  String get ajouterTradeDirectionBuyLong => 'Kauf · Long';

  @override
  String get ajouterTradeDirectionSellShort => 'Verkauf · Short';

  @override
  String get ajouterTradeEntryExitDateHint =>
      'Tipp: Stellen Sie Datum und Uhrzeit für Ein- und Ausstieg ein. ';

  @override
  String get ajouterTradeQtyLots => 'Größe (Lose)';

  @override
  String get ajouterTradeQtyContracts => 'Größe (Verträge)';

  @override
  String get ajouterTradeQtyUnits => 'Größe (Einheiten)';

  @override
  String get ajouterTradeQtyShares => 'Größe (Anteile)';

  @override
  String get ajouterTradeShortcutsLots => 'Viele Abkürzungen';

  @override
  String get ajouterTradeShortcutsContracts => 'Vertragsverknüpfungen';

  @override
  String get ajouterTradeShortcutsQty => 'Größenverknüpfungen';

  @override
  String get ajouterTradeShortcutsCommonSizes => 'Abkürzungen (gängige Größen)';

  @override
  String get ajouterTradeLotHintMini => 'Z.B. ';

  @override
  String get ajouterTradeLotFieldHintForex => 'z.B. ';

  @override
  String get ajouterTradeLotFieldHintContracts => 'z.B. ';

  @override
  String get ajouterTradeLotFieldHintUnits => 'z.B. ';

  @override
  String get ajouterTradeLotFieldHintShares => 'z.B. ';

  @override
  String get ajouterTradeDisciplineSettingsTitle => 'Disziplineinstellungen';

  @override
  String get ajouterTradeDisciplineSettingsSubtitle =>
      'Wählen Sie aus, welche Abschnitte für diesen Handel aktiv sind.';

  @override
  String get ajouterTradeDisciplineFeelingModeTitle => 'Gefühlsmodus';

  @override
  String get ajouterTradeDisciplineFeelingAllowSubtitle =>
      'Erlauben Sie das Ausfüllen der folgenden Abschnitte.';

  @override
  String get ajouterTradeDisciplineSectionsHeading => 'ABSCHNITTE';

  @override
  String get ajouterTradeDisciplineStrategieTitle => 'Strategie';

  @override
  String get ajouterTradeDisciplineStrategieSubtitle => 'Einrichtung, Feedback';

  @override
  String get ajouterTradeDisciplinePlanTitle => 'Analyseplan';

  @override
  String get ajouterTradeDisciplinePlanSubtitle => 'Bericht, Feedback';

  @override
  String get ajouterTradeDisciplineChecklistTitle => 'Checkliste';

  @override
  String get ajouterTradeDisciplineChecklistSubtitle =>
      'Punkte, die es zu beachten gilt';

  @override
  String get ajouterTradeDisciplineEtatTitle => 'Zustand des Augenblicks';

  @override
  String get ajouterTradeDisciplineEtatSubtitle => 'Momente und Emotionen';

  @override
  String get ajouterTradeDisciplineSliderStrategieRespected =>
      'Strategie verfolgt';

  @override
  String get ajouterTradePositionSettingsTitle => 'Positionseinstellungen';

  @override
  String get ajouterTradeStrategieFeedbackBravo => 'Gut gemacht! ';

  @override
  String get ajouterTradeStrategieFeedbackWhichMissed =>
      'Welche Teile Ihrer Strategie haben Sie nicht befolgt?';

  @override
  String get ajouterTradeStrategieGoldRules => 'GOLDENE REGELN';

  @override
  String ajouterTradeStrategieRuleN(int n) {
    return 'Regel $n';
  }

  @override
  String ajouterTradeStrategieSetupTimeframesRow(Object value) {
    return 'Zeitrahmen: $value';
  }

  @override
  String ajouterTradeStrategieSetupIndicatorsRow(Object value) {
    return 'Indikatoren: $value';
  }

  @override
  String ajouterTradeStrategieSetupPatternRow(Object value) {
    return 'Muster: $value';
  }

  @override
  String ajouterTradeStrategieSetupSignalRow(Object value) {
    return 'Signal: $value';
  }

  @override
  String get ajouterTradeStrategieRiskManagement => 'RISIKOMANAGEMENT';

  @override
  String get ajouterTradeStrategieHoursSessions => 'STUNDEN & SITZUNGEN';

  @override
  String get ajouterTradeStrategieSetupModels => 'SETUP & MODELLE';

  @override
  String ajouterTradeStrategieSetupModelsWithTitle(Object title) {
    return 'SETUP & MODELLE – $title';
  }

  @override
  String get ajouterTradeStrategiePickStrategyHint =>
      'Wählen Sie eine Strategie aus der Liste oben aus, um Einrichtungsdetails anzuzeigen (Einstieg, Stopp, Ziel, Handelsmanagement usw.).';

  @override
  String get ajouterTradeStrategieRowPattern => 'Muster';

  @override
  String get ajouterTradeStrategieRowSignal => 'Signal';

  @override
  String get ajouterTradeStrategieClosedLabel100 =>
      'Großartig, Strategie befolgt';

  @override
  String get ajouterTradeStrategieClosedLabel95 => 'Fast vollständig befolgt';

  @override
  String get ajouterTradeStrategieClosedLabelLow => 'Punkte zur Überprüfung';

  @override
  String get ajouterTradePlanPickReportAbove =>
      'Wählen Sie im Feld oben einen Bericht aus.';

  @override
  String get ajouterTradePlanFeedbackAlmost100 =>
      'Sie sind nahezu 100 %: Wenden Sie weiterhin jeden Punkt Ihres Analyseplans an.';

  @override
  String get ajouterTradePlanFeedbackBravo => 'Gut gemacht! ';

  @override
  String get ajouterTradePlanFeedbackWhichMissed =>
      'Welche Teile Ihres Analyseplans haben Sie nicht befolgt?';

  @override
  String get ajouterTradePlanClosedLabel100 => 'Super, Plan befolgt';

  @override
  String get ajouterTradePlanClosedLabelLow => 'Rückmeldung';

  @override
  String get ajouterTradeChecklistFeedbackAlmost100 =>
      'Sie haben nahezu 100 % erreicht: Wenden Sie weiterhin jeden Punkt Ihrer Checkliste an.';

  @override
  String get ajouterTradeChecklistFeedbackBravo => 'Gut gemacht! ';

  @override
  String get ajouterTradeChecklistFeedbackWhichMissed =>
      'Welche Teile Ihrer Checkliste haben Sie nicht befolgt?';

  @override
  String get ajouterTradeChecklistClosedLabel100 => 'Super, Checkliste befolgt';

  @override
  String get ajouterTradeChecklistClosedLabelLow => 'Checkliste';

  @override
  String get ajouterTradeEtatFeelingPrompt => 'Welche Gefühle kamen hoch?';

  @override
  String get ajouterTradeEtatFeedbackAlmost100 =>
      'Sie sind nahe bei 100 %: Wenden Sie weiterhin jeden Punkt an.';

  @override
  String get ajouterTradeEtatClosedLabel100 => 'Ja, es ist hart. ';

  @override
  String get ajouterTradeEtatClosedLabelLow => 'Zustand des Augenblicks';

  @override
  String get ajouterTradeEtatHeaderMoment => 'IHR STAAT';

  @override
  String get ajouterTradeEtatHeaderEmotions => 'EMOTIONEN';

  @override
  String get ajouterTradeScreenshotLoadError =>
      'Das Bild konnte nicht angezeigt werden';

  @override
  String get ajouterTradeScreenshotChangeImage => 'Bild ändern';

  @override
  String get ajouterTradeScreenshotTapToAdd =>
      'Tippen Sie, um ein Bild hinzuzufügen';

  @override
  String get ajouterTradeScreenshotRemove => 'Entfernen';

  @override
  String get ajouterTradePlanRowBias => 'Voreingenommenheit';

  @override
  String get ajouterTradePlanRowTimeframeHtf => 'HTF-Zeitrahmen';

  @override
  String get ajouterTradePlanRowPhase => 'Phase';

  @override
  String get ajouterTradePlanRowNotes => 'Notizen';

  @override
  String get ajouterTradePlanRowLastPoint => 'Letzter Schwungpunkt';

  @override
  String ajouterTradePlanRowExtraSupport(int n) {
    return 'Zusätzliche Unterstützung $n';
  }

  @override
  String ajouterTradePlanRowExtraResistance(int n) {
    return 'Zusätzlicher Widerstand $n';
  }

  @override
  String get ajouterTradePlanRowOutils => 'Werkzeuge';

  @override
  String get ajouterTradePlanRowLiquidity => 'Liquidität';

  @override
  String get ajouterTradePlanRowFibPrice => 'Fib-Preis';

  @override
  String get ajouterTradePlanSectionVolume => 'VOLUMEN';

  @override
  String get analyseAddField => '+ Feld hinzufügen';

  @override
  String get analyseAddPhaseTitle => 'Phase hinzufügen';

  @override
  String get analyseAddResist => '+ Widerstand hinzufügen';

  @override
  String get analyseAddShort => '+ Hinzufügen';

  @override
  String get analyseAddSupport => '+ Unterstützung hinzufügen';

  @override
  String get analyseAddTimeframeTitle => 'Zeitrahmen hinzufügen';

  @override
  String get analyseAddTimeframeCustomEntry => 'Andere (freie Eingabe)';

  @override
  String get analyseAddTimeframeSectionRestore => 'Wiederherstellen';

  @override
  String get analyseAddTimeframeSectionIntraday => 'Intraday';

  @override
  String get analyseAddTimeframeSectionSwing => 'Swing & Position';

  @override
  String get analyseAddTrendTitle => 'Trend hinzufügen';

  @override
  String get analyseReportScreenshotSectionTitle => 'SCREENSHOT';

  @override
  String get analyseReportScreenshotAddCapture => 'Screenshot hinzufügen';

  @override
  String get analyseReportScreenshotChooseImage => 'Wählen Sie ein Bild';

  @override
  String get analyseReportScreenshotSubtitleWeb => 'Bilddatei';

  @override
  String get analyseReportScreenshotSubtitleFilePicker =>
      'Galerie oder Datei-Explorer';

  @override
  String get analyseReportScreenshotCamera => 'Kamera';

  @override
  String get analyseReportScreenshotHintWithCamera =>
      'Datei, Galerie oder Kamera';

  @override
  String get analyseReportScreenshotHintNoCamera =>
      'Wählen Sie ein Bild auf diesem Gerät aus';

  @override
  String get analyseReportScreenshotErrorPlugin =>
      'Die Bildauswahl ist für dieses Ziel nicht verfügbar. ';

  @override
  String get analyseReportScreenshotErrorGeneric =>
      'Der Screenshot konnte nicht hinzugefügt werden.';

  @override
  String get analyseCardIndicators => 'Indikatoren';

  @override
  String get analyseCardSmcLiquidity => 'SMC & Liquidität';

  @override
  String get analyseCardVolumeProfile => 'Volumenprofil';

  @override
  String get analysePageHeroTitle => 'Meine Analyse';

  @override
  String get analysePageHeroSubtitle =>
      'Analysen und Strategien in Echtzeit verwalten.';

  @override
  String get analyseSidebarConfidenceSummary => 'ÜBERBLICK';

  @override
  String get analyseSidebarConfidenceLabel => 'globales Vertrauen';

  @override
  String get analyseSidebarReportHint =>
      'Der Bericht wird mit dem verknüpften Asset in Ihrem Verlauf gespeichert.';

  @override
  String get analyseSidebarPreviewStyle => 'STILVORSCHAU';

  @override
  String get analyseConfidenceHigh => 'Hoch';

  @override
  String get analyseConfidenceLevelTitle => 'VERTRAUEN';

  @override
  String get analyseConfidenceLow => 'Niedrig';

  @override
  String analyseCopyLabel(String label) {
    return '$label kopieren';
  }

  @override
  String analyseCopyNumber(int n) {
    return '$n kopieren';
  }

  @override
  String get analyseCurrentMarketPhase => 'AKTUELLE MARKTPHASE';

  @override
  String get analyseCurrentTrend => 'AKTUELLER TREND';

  @override
  String get analyseDeleteTemplateTitle => 'Diese Vorlage löschen?';

  @override
  String get analyseDirectionLabel => 'RICHTUNG';

  @override
  String get analyseDraftLabelHint => 'Etikett…';

  @override
  String get analyseExtraBroken => 'Gebrochen';

  @override
  String get analyseExtraHeld => 'Gehalten';

  @override
  String get analyseExtraPriceHint => 'Preis';

  @override
  String get analyseFeuillePlanTitle => 'HANDELSPLANBLATT';

  @override
  String get analyseFibLevel => 'FIBONACCI-EBENE';

  @override
  String get analyseFibShort => 'FIBONACCI';

  @override
  String get analyseFreeFields => 'FREIE FELDER';

  @override
  String get analyseFvg => 'Fair-Value-Lücke (FVG)';

  @override
  String get analyseHintActifExamples => 'z.B. ';

  @override
  String get analyseHintDetailsDots => 'Einzelheiten…';

  @override
  String get analyseHintHtfChipExample => 'z.B. ';

  @override
  String get analyseHintImbalance => 'Ungleichgewicht…';

  @override
  String get analyseHintNotesDots => 'Notizen…';

  @override
  String get analyseHintPriceDots => 'Preis…';

  @override
  String get analyseHintStops => 'Wo sind die Haltestellen? ';

  @override
  String get analyseHintTextDots => 'Text…';

  @override
  String get analyseHintTfExamples => 'z.B. ';

  @override
  String get analyseHintZoneHtf => 'HTF-Zone…';

  @override
  String get analyseHtfTimeframe => 'ANALYSEZEITRAHMEN (HTF)';

  @override
  String get analyseImpactFeuille => 'Blatteinschlag';

  @override
  String get analyseImpactIndicators => 'Auswirkungen der Indikatoren';

  @override
  String analyseImpactLine(int percent) {
    return 'Auswirkung: $percent%';
  }

  @override
  String get analyseImpactModalBlurb =>
      'Die vier Auswirkungen teilen sich insgesamt zu 100 %. ';

  @override
  String get analyseImpactModalTitle => 'Schlag anpassen';

  @override
  String get analyseImpactShort => 'Auswirkungen';

  @override
  String get analyseImpactSmc => 'SMC-Auswirkungen';

  @override
  String get analyseLastPointHint => 'Letzter Punkt…';

  @override
  String get analyseLiquidityPools => 'LIQUIDITÄTSPOOLS';

  @override
  String get analyseMovementDetailsHint => 'Bewegungsdetails…';

  @override
  String get analyseNameFieldHint => 'Analysename…';

  @override
  String get analyseNameFieldLabel => 'Analysename';

  @override
  String get analyseNoTemplatesSaved => 'Keine gespeicherten Vorlagen';

  @override
  String get analyseNote => 'NOTIZ';

  @override
  String get analyseNotesIndicators => 'HINWEISE (INDIKATOREN)';

  @override
  String get analyseNotesSmcExample => 'z.B. ';

  @override
  String get analyseNotesSmcLiq => 'ANMERKUNGEN (SMC & LIQUIDITÄT)';

  @override
  String get analyseNotesVolumeProfile => 'HINWEISE (VOLUMENPROFIL)';

  @override
  String get analyseOrderBlock => 'BESTELLBLOCK (OB)';

  @override
  String get analysePhase => 'PHASE';

  @override
  String get analyseReportCellFvg => 'FVG';

  @override
  String get analyseReportCellLiqPools => 'LIQ. ';

  @override
  String get analyseReportCellOrderBlock => 'BESTELLBLOCK';

  @override
  String get analyseResistLower => 'Widerstand';

  @override
  String get analyseResistShort => 'WIDERSTEHEN.';

  @override
  String get analyseSetup => 'AUFSTELLEN';

  @override
  String get analyseSideBuy => 'Kaufen';

  @override
  String get analyseSideSell => 'Verkaufen';

  @override
  String get analyseSideWatch => 'Betrachten';

  @override
  String get analyseSmcAdds => 'SMC fügt hinzu';

  @override
  String get analyseStructTagResist => 'R';

  @override
  String get analyseStructTagSupport => 'S';

  @override
  String get analyseStructure => 'STRUKTUR';

  @override
  String get analyseStructureSectionTitle => 'Struktur';

  @override
  String get analyseSupport => 'UNTERSTÜTZUNG';

  @override
  String get analyseSupportLower => 'Unterstützung';

  @override
  String analyseTemplateApplied(String name) {
    return 'Vorlage „$name“ angewendet';
  }

  @override
  String get analyseTemplateNameHint => 'Neuer Name…';

  @override
  String get analyseTemplateRenameDialogTitle => 'Vorlage umbenennen';

  @override
  String get analyseTemplateSaveDialogTitle => 'Vorlagenname';

  @override
  String get analyseTemplateStyleHint => 'z.B. ';

  @override
  String get analyseTestedTwice => 'Getestet x 2';

  @override
  String get analyseTimeframeLabelShort => 'ZEITRAHMEN';

  @override
  String get analyseTooltipPickTemplate =>
      'Wählen Sie eine gespeicherte Vorlage';

  @override
  String get analyseTooltipSaveTemplatePills =>
      'Speichern Sie Pillen unter einem Namen (Ihrer Gewohnheit)';

  @override
  String get analyseTrend => 'TREND';

  @override
  String get analyseTrendLabel => 'Trend';

  @override
  String get analyseVolumePoc => 'POC';

  @override
  String get analyseVolumeProfile => 'VOLUMENPROFIL';

  @override
  String get analyseVolumeProfileDefaultLabel => 'Volumenprofil';

  @override
  String get analyseVolumeVah => 'VAH';

  @override
  String get analyseVolumeVal => 'VAL';

  @override
  String get analyseVolumeZoneFrom => 'Von';

  @override
  String get analyseVolumeZoneLabel => 'Zone';

  @override
  String get analyseVolumeZoneTo => 'Bis';

  @override
  String get appBrandName => 'PAYCHEK';

  @override
  String get buttonCalculate => 'Berechnen';

  @override
  String get calAmountLabel => 'Menge';

  @override
  String get calMonthlyObjectiveTitle => 'Monatsziel';

  @override
  String get calPageTitle => 'Kalender';

  @override
  String get calObjectiveLabel => 'Objektiv';

  @override
  String get calCumulativePerformanceTitle => 'Kumulierte Leistung';

  @override
  String get calBestDay => 'Bester Tag';

  @override
  String get calTradingDays => 'Handelstage';

  @override
  String get calAverageShort => 'Durchschnitt';

  @override
  String get calPnlShort => 'Gewinn- und Verlustrechnung';

  @override
  String get calCapitalChangePct => 'Hauptstadt %';

  @override
  String get calAveragePerDay => 'Durchschn./Tag';

  @override
  String get calObjectiveShort => 'Objektiv';

  @override
  String calChartError(String message) {
    return 'Fehler: $message';
  }

  @override
  String calDayTradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Trades',
      one: '1 Trade',
      zero: 'Keine Trades',
    );
    return '$_temp0';
  }

  @override
  String get monthJanuary => 'Januar';

  @override
  String get monthFebruary => 'Februar';

  @override
  String get monthMarch => 'Marsch';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Juni';

  @override
  String get monthJuly => 'Juli';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'Oktober';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'Dezember';

  @override
  String get monthAbbrJanuary => 'Jan';

  @override
  String get monthAbbrFebruary => 'Febr';

  @override
  String get monthAbbrMarch => 'Beschädigen';

  @override
  String get monthAbbrApril => 'Apr';

  @override
  String get monthAbbrMay => 'Mai';

  @override
  String get monthAbbrJune => 'Jun';

  @override
  String get monthAbbrJuly => 'Juli';

  @override
  String get monthAbbrAugust => 'Aug';

  @override
  String get monthAbbrSeptember => 'Sept';

  @override
  String get monthAbbrOctober => 'Okt';

  @override
  String get monthAbbrNovember => 'Nov';

  @override
  String get monthAbbrDecember => 'Dez';

  @override
  String get calcBestBalance => 'Beste Balance';

  @override
  String get calcEndBalance => 'Schlussbilanz';

  @override
  String get calcEquityCurveTitle => 'Diagramm der Handelsrenditekurve';

  @override
  String get calcLabelEntry => 'Eintrittspreis';

  @override
  String get calcLabelRiskShort => 'Risiko';

  @override
  String get calcLabelSl => 'Stop-Loss';

  @override
  String get calcLabelStartBalance => 'Balance starten';

  @override
  String get calcLabelTp => 'Nehmen Sie Gewinn mit';

  @override
  String get calcLabelTradesShort => 'Gewerbe';

  @override
  String get calcLabelWinRateShort => 'Gewinnrate';

  @override
  String get calcLoss => 'Verlust';

  @override
  String get calcMaxDrawdown => 'Maximaler Drawdown';

  @override
  String get calcProfitFactor => 'Gewinnfaktor';

  @override
  String get calcRatioSectionTitle => 'Verhältnis';

  @override
  String get calcResult => 'Ergebnis';

  @override
  String get calcResultOfCalculation => 'Ergebnis der Berechnung';

  @override
  String get calcRowGain => 'Gewinnen:';

  @override
  String get calcRowSl => 'SL:';

  @override
  String get calcRowVsCapital => 'Gegen Kapital';

  @override
  String get calcSettingsTitle => 'Einstellungen';

  @override
  String get calcTotalGainLabel => 'Gesamtgewinn';

  @override
  String get calcTradeReturnTableTitle => 'Ergebnisse der Handelsrendite';

  @override
  String get calcWin => 'Gewinnen';

  @override
  String get calcWinsLosses => 'Siege/Verluste';

  @override
  String get calcWorstBalance => 'Schlechteste Bilanz';

  @override
  String get calculateRatio => 'Verhältnis berechnen';

  @override
  String get cancel => 'Stornieren';

  @override
  String get capitalAmountLabel => 'Kapitalbetrag';

  @override
  String get capitalCurrencyTitle => 'Währung';

  @override
  String get capitalEllipsis => '…';

  @override
  String get capitalHintAmount => 'z.B. ';

  @override
  String get capitalInitialTitle => 'Anfangskapital';

  @override
  String get capitalLabel => 'Hauptstadt';

  @override
  String get capitalOther => 'andere';

  @override
  String get capitalTooltip => 'Kapital und Währung (Hauptkonto)';

  @override
  String get checklistAddSection => 'Fügen Sie einen Abschnitt hinzu';

  @override
  String get checklistDefaultNewSection => 'NEUER ABSCHNITT';

  @override
  String get checklistDeleteSectionBody =>
      'Diese Aktion ist für diesen Abschnitt dauerhaft.';

  @override
  String get checklistDeleteSectionTitle => 'Abschnitt löschen?';

  @override
  String get checklistEditSectionHint => 'Titel';

  @override
  String get checklistIntroBody =>
      'Stellen Sie vor dem Eingehen einer Position sicher, dass Sie alle Kriterien in Ihrem Handelsplan validieren.';

  @override
  String get checklistItemAnalyse1 =>
      'Der Hintergrundtrend (HTF) entspricht meiner Idee.';

  @override
  String get checklistItemAnalyse2 =>
      'Der Preis befindet sich in einer Schlüsselzone (Unterstützung/Widerstand, Orderblock).';

  @override
  String get checklistItemAnalyse3 =>
      'Ich habe eine eindeutige Eingabebestätigung (Muster, Divergenz).';

  @override
  String get checklistItemHint => 'Kriterium eingeben';

  @override
  String get checklistItemPsy1 =>
      'Ich handle mit einer neutralen Denkweise (kein Rachehandel).';

  @override
  String get checklistItemPsy2 =>
      'Ich akzeptiere den möglichen Verlust, bevor ich eintrete.';

  @override
  String get checklistItemPsy3 =>
      'Auch nach einer Verlustserie bleibe ich bei meinem Plan.';

  @override
  String get checklistItemRisque1 =>
      'Mein Stop-Loss wird technisch festgelegt (nicht zufällig).';

  @override
  String get checklistItemRisque2 =>
      'Das Risiko überschreitet nicht 1 % meines Kapitals.';

  @override
  String get checklistItemRisque3 =>
      'Das Risiko-Ertrags-Verhältnis beträgt mindestens 1:2.';

  @override
  String get checklistMenuEdit => 'Bearbeiten';

  @override
  String get checklistPageTitle => 'Checkliste';

  @override
  String get checklistProgressCl => 'CL';

  @override
  String get checklistSectionAnalyse => 'TECHNISCHE ANALYSE';

  @override
  String get checklistSectionPsy => 'PSYCHOLOGIE';

  @override
  String get checklistSectionRisque => 'RISIKOMANAGEMENT';

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get currencyNameHint => 'z.B. ';

  @override
  String get currencyNameLabel => 'Währungsname';

  @override
  String get customCurrencyTitle => 'Andere Währung';

  @override
  String get dashboardAiAnalyze => 'Analysieren';

  @override
  String get dashboardAiCoachBody =>
      'Tippen Sie auf „Analysieren“, damit die KI Ihre wöchentlichen Statistiken (Siegquote, Stunden, Faktoren) überprüft und maßgeschneiderte psychologische Ratschläge generiert.';

  @override
  String get dashboardAiCoachTitle => 'GEHALTSCHEK-KI-COACH';

  @override
  String get dashboardAnalyseShortcutTitle => 'Meine Analyse';

  @override
  String get dashboardBestTradeLabel => 'Bester Handel';

  @override
  String get dashboardCapitalBalanceHeader => 'KAPITAL/BILANZ';

  @override
  String get dashboardCapitalEvolutionTitle => 'KAPITALENTWICKLUNG';

  @override
  String get dashboardChecklistHeading => 'CHECKLISTE';

  @override
  String get dashboardChecklistSeeRest => 'Mehr >';

  @override
  String get dashboardChecklistAllDoneBravo => 'Gutes Trading.';

  @override
  String get dashboardMyStateSection => 'Mein Staat';

  @override
  String get dashboardOpenStrategyTooltip => 'Öffnen Sie „Meine Strategie“.';

  @override
  String dashboardPerfHourWinRate(int percent) {
    return '$percent% WR';
  }

  @override
  String get dashboardPerfHoursRow1 => '09:00 - 11:30 (Beginn)';

  @override
  String get dashboardPerfHoursRow2 => '14:30 - 16:30 (US Open)';

  @override
  String get dashboardPerfHoursRow3 => '19:00+ (Abend)';

  @override
  String get dashboardPerfHoursTitle => 'AUFFÜHRUNGSSTUNDEN';

  @override
  String get dashboardRingState => 'ZUSTAND';

  @override
  String get dashboardRingWin => 'GEWINNEN';

  @override
  String get dashboardSuccessFactorSample => 'Sport vor der Sitzung';

  @override
  String get dashboardSuccessFactorsSubtitle =>
      'Verfolgen Sie, wie sich Ihre Gewohnheiten auf Ihre Gewinnrate auswirken.';

  @override
  String get dashboardSuccessFactorsTitle => 'ERFOLGSFAKTOREN';

  @override
  String get dashboardTfAll => 'ALLE';

  @override
  String get dashboardTfDay => '1D';

  @override
  String get dashboardTfMonth => '1M';

  @override
  String get dashboardTfWeek => '1W';

  @override
  String dashboardTradeCount(int count) {
    return '$count Trades';
  }

  @override
  String get dashboardTradeOne => '1 Handel';

  @override
  String dashboardEvolutionTradesThisPeriod(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Trades in diesem Zeitraum',
      one: '1 Trade in diesem Zeitraum',
      zero: '0 Trades in diesem Zeitraum',
    );
    return '$_temp0';
  }

  @override
  String get dashboardEvolutionSparklineHoverOrigin => 'Beginn des Kumulativ';

  @override
  String get dashboardEvolutionSparklineHoverNoTrade =>
      'Keine Trades an diesem Punkt';

  @override
  String dashboardEvolutionSparklineHoverMore(int count) {
    return '+$count weitere';
  }

  @override
  String get dashboardEvolutionSparklineTapHint => 'Tippen zum Öffnen';

  @override
  String get dashboardWeekResultPrefix => 'Ergebnis:';

  @override
  String get dashboardWeekThisWeek => 'DIESE WOCHE';

  @override
  String get dashboardWeekdayShortFri => 'FR';

  @override
  String get dashboardWeekdayShortMon => 'MO';

  @override
  String get dashboardWeekdayShortSat => 'SA';

  @override
  String get dashboardWeekdayShortSun => 'SONNE';

  @override
  String get dashboardWeekdayShortThu => 'DO';

  @override
  String get dashboardWeekdayShortTue => 'DI';

  @override
  String get dashboardWeekdayShortWed => 'HEIRATEN';

  @override
  String get dashboardWorstLossLabel => 'Schlimmster Verlust';

  @override
  String get delete => 'Löschen';

  @override
  String deletePortfolioTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get deleteTooltip => 'Löschen';

  @override
  String get editPortfolioTooltip => 'Name, Kapital, Währung bearbeiten';

  @override
  String get errorAmount => 'Geben Sie einen gültigen Betrag ein (≥ 0).';

  @override
  String get errorInvalidAmount => 'Ungültiger Betrag oder ungültige Währung.';

  @override
  String get errorNameOrSymbol =>
      'Geben Sie mindestens einen Namen oder ein Symbol ein.';

  @override
  String get exportPdfFailed => 'PDF konnte nicht exportiert werden.';

  @override
  String exportPdfFailedWithError(String error) {
    return 'PDF konnte nicht exportiert werden: $error';
  }

  @override
  String get exportPdfUnavailable =>
      'PDF-Export abgebrochen oder nicht verfügbar.';

  @override
  String get homePerformance => 'Leistung';

  @override
  String get webHomeHeroSubtitle =>
      'Willkommen — hier ist deine Wochenperformance';

  @override
  String webHomeHeroWelcome(Object fullName) {
    return 'Willkommen, $fullName';
  }

  @override
  String get webHomeLiveTerminal => 'Live-Terminal';

  @override
  String get webHomeWelcomeBack => 'Willkommen zurück,';

  @override
  String get webHomeUpgradeUnlockSubtitle =>
      'Schalten Sie Echtzeit-Institutionsdaten frei';

  @override
  String get webRailMenuHeading => 'Menü';

  @override
  String get labelActif => 'Vermögenswert';

  @override
  String get labelGain => 'Gewinn- und Verlustrechnung';

  @override
  String get labelLot => 'VIEL';

  @override
  String get labelMarket => 'MARKT';

  @override
  String get labelPrice => 'PREIS';

  @override
  String get labelRiskPct => 'RISIKO %';

  @override
  String get labelSuggestedSize => 'EMPFOHLENE GRÖSSE';

  @override
  String get langChineseTraditional => '中文 (繁體)';

  @override
  String get langEnglish => 'Englisch';

  @override
  String get langFrench => 'Französisch';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get langItalian => 'Italienisch';

  @override
  String get langKorean => '한국어';

  @override
  String get langPortuguese => 'Portugiesisch';

  @override
  String get langSpanish => 'Spanisch';

  @override
  String get languageDialogSubtitle => 'Schnittstellensprache';

  @override
  String get languageDialogTitle => 'Sprache wählen';

  @override
  String get languageSection => 'Sprache';

  @override
  String get onboardingLanguageContinue => 'Weiter';

  @override
  String get mentalBad => 'Schlecht';

  @override
  String get mentalConfidence => 'Vertrauen';

  @override
  String get mentalEmotionFieldLabel => 'Emotionsname (z. B. ruhig, ängstlich)';

  @override
  String get mentalEmotional => 'Emotional';

  @override
  String get mentalEnergy => 'Energie';

  @override
  String get mentalExcited => 'Aufgeregt';

  @override
  String get mentalFocus => 'Fokus';

  @override
  String get mentalFrustrated => 'Frustriert';

  @override
  String get mentalHappy => 'Glücklich';

  @override
  String get mentalHintEmotion => 'z.B. ';

  @override
  String get mentalHintMetric => 'z.B. ';

  @override
  String get mentalHintRoutine => 'z.B. ';

  @override
  String get mentalMarketStudy => 'Marktstudie';

  @override
  String get mentalMeditation => 'Meditation (10 Min.)';

  @override
  String get mentalMetricFieldLabel => 'Metrikname (z. B. Geduld, Stress)';

  @override
  String get mentalNegative => 'Negativ (-)';

  @override
  String get mentalNeutral => 'Neutral';

  @override
  String get mentalNewEmotion => 'Neue Emotion';

  @override
  String get mentalNewMetric => 'Neue Metrik';

  @override
  String get mentalNewRoutine => 'Neue Routine';

  @override
  String get mentalPeakForm => 'Spitzenform';

  @override
  String get mentalPositive => 'Positiv (+)';

  @override
  String get mentalRestTitle => 'AUSRUHEN';

  @override
  String get mentalRiskAppetite => 'Angst';

  @override
  String get mentalRoutineFieldLabel => 'Name der Routine (z. B. Sport, Lesen)';

  @override
  String get mentalGlobalScoreCalendarTitle => 'TAGES-GESAMTSCORE';

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
  String get mentalSleepEnough => 'Ausreichend geschlafen';

  @override
  String mentalSleepImpact(int percent) {
    return 'Auswirkung: $percent%';
  }

  @override
  String get mentalSport => 'Sport / Joggen';

  @override
  String get mentalTired => 'Müde';

  @override
  String get mentalWeightGlobalImpact => 'Globale Auswirkungen';

  @override
  String get mentalWeightModalBlurb =>
      'Passen Sie an, wie wichtig dieses Kriterium ist. ';

  @override
  String get mentalWeightModalTitle => 'Schlag anpassen';

  @override
  String get mentalWeightNatureLabel => 'Art der Auswirkung';

  @override
  String get mentalWeightPolarityHelpNegative =>
      'Ein hoher Wert für dieses Kriterium verringert Ihre Gesamtpunktzahl.';

  @override
  String get mentalWeightPolarityHelpPositive =>
      'Ein hoher Wert für dieses Kriterium erhöht Ihre Gesamtpunktzahl.';

  @override
  String get mentalPageTitle => 'Geisteszustand';

  @override
  String get mentalPageIntro => 'Bewerten Sie Ihren Geisteszustand. ';

  @override
  String get mentalGaugeStateLabel => 'ZUSTAND';

  @override
  String mentalGaugeBasedOnIndicators(int count) {
    return 'Basierend auf $count Indikatoren';
  }

  @override
  String get mentalGaugeStatusStable => 'Solides Gleichgewicht';

  @override
  String get mentalGaugeStatusFragile => 'Aufmerksamkeit nötig';

  @override
  String get mentalSectionRoutinesHeading => 'MEINE ROUTINEN';

  @override
  String get mentalSectionMomentHeading => 'ZUSTAND DES MOMENTS';

  @override
  String get mentalSectionEmotionHeading => 'EMOTIONEN';

  @override
  String modelSavedSnackbar(String name) {
    return 'Vorlage „$name“ gespeichert';
  }

  @override
  String get navAdd => 'Hinzufügen';

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navDashboard => 'Armaturenbrett';

  @override
  String get navMore => 'Mehr';

  @override
  String get navTrade => 'Handel';

  @override
  String get ok => 'OK';

  @override
  String get perf0Sub =>
      'Einfluss von Stress und Müdigkeit auf die Erfolgsquote';

  @override
  String get perf0Title => 'Psychologie: Emotionen und Schlaf';

  @override
  String get perf1Sub => 'Wirtschaftlichkeitsanalyse (Mo–So)';

  @override
  String get perf1Title => 'Wochentags';

  @override
  String get perf2Sub => 'Finden Sie Ihre profitabelsten Stunden';

  @override
  String get perf2Title => 'Sitzungsstunden';

  @override
  String get perf3Sub => 'Erfolgsquote dieses Diagrammmusters';

  @override
  String get perf3Title => 'Muster: Doppelt oben/unten';

  @override
  String get perf4Sub => 'Große Umkehranalyse';

  @override
  String get perf4Title => 'Muster: Kopf und Schultern';

  @override
  String get perf5Sub => 'Validierung des Signals „Überkauft/Überverkauft“.';

  @override
  String get perf5Title => 'Indikator: RSI-Divergenz';

  @override
  String get perf6Sub => 'Gleitende durchschnittliche Crossover-Effektivität';

  @override
  String get perf6Title => 'Indikator: MACD-Crossover';

  @override
  String get perf7Sub => 'Springt bei den Werten 0,618 und 0,5';

  @override
  String get perf7Title => 'Indikator: Fibonacci-Retracement';

  @override
  String get perf8Sub => 'Auftragssperren und Liquiditätsanalyse';

  @override
  String get perf8Title => 'Strategie: Smart Money Concept (SMC)';

  @override
  String get perf9Sub =>
      'Einfluss des finanziellen Risikos auf die Gewinnquote';

  @override
  String get perf9Title => 'Volumen und Losgröße';

  @override
  String get perfAddWidgetButton => 'Widget hinzufügen';

  @override
  String get perfChartBar => 'Balkendiagramm';

  @override
  String get perfChartHBar => 'Horizontale Balken';

  @override
  String get perfChartHintBar => 'Ideal zum Vergleichen (z. B. Wochentage)';

  @override
  String get perfChartHintHBar => 'Listenformat, einfach und sauber';

  @override
  String get perfChartHintLine =>
      'Um einen Trend im Laufe der Zeit zu erkennen';

  @override
  String get perfChartHintPie => 'Für einen Gesamtprozentsatz';

  @override
  String get perfChartLine => 'Liniendiagramm';

  @override
  String get perfChartPie => 'Kreis / Messgerät';

  @override
  String get perfCustomizeIntro => 'Passen Sie Ihre Leistungsseite an.';

  @override
  String get perfDataFootnoteDuration =>
      'Daten: Aufschlüsselung nach Positionsdauer (CSV).';

  @override
  String get perfDataFootnoteVolume => 'Volumen-Proxy: Buckets nach |profit| ';

  @override
  String get perfEmptyChart =>
      'Importieren oder laden Sie Trades (CSV), um das Diagramm anzuzeigen.';

  @override
  String get perfLineChartCaption =>
      'Zeile: Kumulierter Gewinn (chronologische Reihenfolge, CSV).';

  @override
  String get perfNewWidgetTitle => 'Neues Widget';

  @override
  String get perfNoResults => 'Keine Optionen gefunden.';

  @override
  String get perfPieChartCaption => 'Slices = Handelsvolumen nach Kategorie; ';

  @override
  String get perfRemoveWidgetTooltip => 'Widget entfernen';

  @override
  String get perfSearchHint => 'Suche (z. B. Muster, Psychologie…)';

  @override
  String get perfStep1Title => '1. Was möchten Sie analysieren?';

  @override
  String get perfStep2Title => '2. Diagrammtyp';

  @override
  String get plusAdd => 'Hinzufügen';

  @override
  String get plusCalculator => 'Kalkulator';

  @override
  String get plusCalendar => 'Kalender';

  @override
  String get plusChecklist => 'Checkliste';

  @override
  String get plusDashboard => 'Armaturenbrett';

  @override
  String get plusMentalState => 'Geisteszustand';

  @override
  String get plusMyAnalysis => 'Meine Analyse';

  @override
  String get plusMyStrategy => 'Meine Strategie';

  @override
  String get plusPerformance => 'Leistung';

  @override
  String get plusSettings => 'Einstellungen';

  @override
  String get plusTrade => 'Handel';

  @override
  String get paychekAccessDeniedTitle => 'Access restricted';

  @override
  String get paychekAccessDeniedWeb =>
      'Web access for this account has been disabled. Contact support if needed.';

  @override
  String get paychekAccessDeniedMobile =>
      'Mobile app access for this account has been disabled. Contact support if needed.';

  @override
  String get portfolioNameMissing =>
      'Geben Sie einen Portfolionamen ein (z. B. Broker).';

  @override
  String get portfoliosLabel => 'Portfolios';

  @override
  String get q1Slogan => 'Wählen Sie Ihren Ansatz';

  @override
  String get q1Title => 'Was für ein Händler sind Sie?';

  @override
  String get q1o1s => 'Positionen von Sekunden bis zu einigen Minuten';

  @override
  String get q1o1t => 'Scalping';

  @override
  String get q1o2s => 'Alle Positionen werden vor Ende der Sitzung geschlossen';

  @override
  String get q1o2t => 'Tageshandel';

  @override
  String get q1o3s => 'Positionen, die zwischen 1 und 3 Tagen gehalten werden';

  @override
  String get q1o3t => 'Intraday';

  @override
  String get q1o4s =>
      'Positionen, die über mehrere Tage oder Wochen gehalten werden';

  @override
  String get q1o4t => 'Swing';

  @override
  String get q2Slogan => 'Wo bist du auf deiner Reise?';

  @override
  String get q2Title => 'Erfahrungsprofil';

  @override
  String get q2o1s => 'Du bist nicht allein';

  @override
  String get q2o1s2 =>
      'Für Trader, die gerade erst anfangen und noch auf der Suche nach ihrer Methode sind';

  @override
  String get q2o1t => 'Ich habe keine Strategie';

  @override
  String get q2o2s => 'Licht am Ende des Tunnels';

  @override
  String get q2o2s2 =>
      'Für diejenigen mit den Grundlagen, die Konsistenz wünschen';

  @override
  String get q2o2t => 'Ich habe meine Strategie';

  @override
  String get q2o3s => 'Der schwierigste Teil liegt hinter dir';

  @override
  String get q2o3s2 => 'Für erfahrene Trader, die ihre Statistiken beherrschen';

  @override
  String get q2o3t => 'Performant';

  @override
  String get q3Slogan => 'Wählen Sie Ihre oberste Priorität';

  @override
  String get q3Title => 'Was möchten Sie verbessern?';

  @override
  String get q3o1s =>
      'Hören Sie an einem Tag auf zu gewinnen, um am nächsten alles zu verlieren.';

  @override
  String get q3o1s2 =>
      'Um Ihre Eigenkapitalkurve zu stabilisieren und den emotionalen Höhenflug zu vermeiden.';

  @override
  String get q3o1t => 'AUS DER ACHTERBAHN';

  @override
  String get q3o2s =>
      'Verbessern Sie die Gewinnrate und die Teilnahmepräzision.';

  @override
  String get q3o2s2 =>
      'Für diejenigen, die häufiger gewinnen möchten, indem sie bessere Trades wählen.';

  @override
  String get q3o2t => 'WERDE EIN SCHARFSCHÜTZE';

  @override
  String get q3o3s =>
      'Meistern Sie Disziplin und stoppen Sie emotionale Entscheidungen.';

  @override
  String get q3o3s2 =>
      'Um impulsiven Handel zu beseitigen und Ihrem Plan zu 100 % zu folgen.';

  @override
  String get q3o3t => 'Bleiben Sie eiskalt';

  @override
  String get q3o4s =>
      'Verstehen Sie, welche Diagrammmuster wirklich für Sie funktionieren.';

  @override
  String get q3o4s2 =>
      'Um Ihre eigenen Erfolgsmuster zu erkennen und ein Spezialist zu werden.';

  @override
  String get q3o4t => 'FINDEN SIE IHRE UNTERSCHRIFT';

  @override
  String get q4Slogan => 'Identifizieren Sie, was Sie am meisten blockiert';

  @override
  String get q4Title => 'Was ist Ihre größte Herausforderung?';

  @override
  String get q4o1s => 'Angst, etwas zu verpassen.';

  @override
  String get q4o1s2 => 'Schnell, ich verpasse die Gewinnchance!';

  @override
  String get q4o1t => 'FOMO';

  @override
  String get q4o2s => 'Dein Herz hat dein Gehirn ersetzt.';

  @override
  String get q4o2s2 => 'Auf keinen Fall – ich MUSS mein Geld zurückgewinnen!';

  @override
  String get q4o2t => 'NEIGUNG';

  @override
  String get q4o3s => 'Keine klare Strategie oder Plan.';

  @override
  String get q4o3s2 =>
      'Ich weiß es nicht wirklich, aber es fühlt sich gut an – versuchen wir es.';

  @override
  String get q4o3t => 'HANDELSBLIND';

  @override
  String get q4o4s => 'Ständige Unruhe.';

  @override
  String get q4o4s2 =>
      'Wenn ich nicht klicke, habe ich das Gefühl, dass ich nicht arbeite.';

  @override
  String get q4o4t => 'ÜBERHANDELN';

  @override
  String get q4o5s => 'Ich denke, du bist unbesiegbar.';

  @override
  String get q4o5s2 => 'Ich bin zu gut – leichtes Geld! ';

  @override
  String get q4o5t => 'Übermäßiges Selbstvertrauen';

  @override
  String get q4o6s => 'Angst vor allem.';

  @override
  String get q4o6s2 =>
      'Ich bin mir nicht sicher, ich habe Angst, wieder zu verlieren.';

  @override
  String get q4o6t => 'LÄHMUNG';

  @override
  String get q4o7s => 'Russisches Roulette spielen.';

  @override
  String get q4o7s2 => 'Ich setze alles auf diesen Handel – tu es oder sterbe.';

  @override
  String get q4o7t => 'KEINE GELDVERWALTUNG';

  @override
  String get reglagePortfolioSheetSubtitle => 'Kontokapital und Währung';

  @override
  String get reglagePortfolioSheetTitle => 'Kapital & Portfolios';

  @override
  String get resultDontWorry => 'Mach dir keine Sorge';

  @override
  String get resultHeaderSub =>
      'Das ist nicht Ihr Profil – nur eine Berechnung; noch ist nichts real. Alles beginnt jetzt.';

  @override
  String get resultLabelGlobal => 'Global';

  @override
  String get resultLabelProfil => 'Profil';

  @override
  String get resultLabelPsychology => 'Psychologie';

  @override
  String get resultLabelStrategy => 'Strategie';

  @override
  String resultStatBullet1(int percent) {
    return '$percent % der Händler auf diesem Niveau stagnieren oder verlieren aufgrund mangelnder mathematischer Genauigkeit.';
  }

  @override
  String resultStatBullet2(int percent) {
    return '$percent % der Händler befinden sich in der gleichen Situation.';
  }

  @override
  String get resultStatBullet3 =>
      'Ein Trader mit ausgeprägter Psychologie handelt besser als einer, der 100 Strategien kennt.';

  @override
  String get save => 'Speichern';

  @override
  String get screenshot => 'SCREENSHOT';

  @override
  String get accountPageTitle => 'Konto';

  @override
  String get mobileReconnectAfterLogoutTitle => 'Du bist abgemeldet';

  @override
  String get mobileReconnectAfterLogoutBody =>
      'Melde dich erneut an, um dein Cloud-Profil und dein Abonnement wiederherzustellen. Du kannst die App auf diesem Gerät auch ohne Konto weiter nutzen.';

  @override
  String get mobileReconnectContinueWithoutAccount =>
      'Ohne Anmeldung fortfahren';

  @override
  String get profileViewDetailsSection => 'Profildetails';

  @override
  String get profileAccountStatusTitle => 'Kontostatus';

  @override
  String get profileAccountStatusPro => 'Pro';

  @override
  String get profileAccountStatusLite => 'Lite';

  @override
  String get profileTrialBadge => 'TEST';

  @override
  String profileTrialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Testtage',
      one: 'Noch 1 Testtag',
    );
    return '$_temp0';
  }

  @override
  String profileTrialEndsOn(String date) {
    return 'Test endet am $date';
  }

  @override
  String profileTrialEndedOn(String date) {
    return 'Test beendet am $date';
  }

  @override
  String profileProPeriodEndsOn(String date) {
    return 'Verlängerung am $date';
  }

  @override
  String get profileSubscribeButton =>
      'Auf Pro wechseln (49,90 \$ / Jahr — Abonnement)';

  @override
  String get profileManageSubscriptionButton => 'Abo verwalten';

  @override
  String get profileUpgradeLabel => 'Upgrade';

  @override
  String get profileEditSavedSnack => 'Profil aktualisiert';

  @override
  String get profileEditIncompleteFieldsSnack =>
      'Bitte Vorname, Nachname und E-Mail ausfüllen';

  @override
  String get profileEditInvalidEmailSnack =>
      'Bitte eine gültige E-Mail-Adresse eingeben';

  @override
  String get accountAuthSectionTitle => 'Anmeldung';

  @override
  String get accountContinueWith => 'Fortfahren mit:';

  @override
  String get accountTabLogin => 'Anmeldung';

  @override
  String get accountTabSignup => 'Registrierung';

  @override
  String get accountFieldEmail => 'E-Mail';

  @override
  String get accountFieldPassword => 'Passwort';

  @override
  String get accountFieldConfirmPassword => 'Passwort bestätigen';

  @override
  String get accountFieldBirthDate => 'Geburtsdatum';

  @override
  String get accountFieldFirstName => 'Vorname';

  @override
  String get accountFieldLastName => 'Nachname';

  @override
  String get accountLoginButton => 'Einloggen';

  @override
  String get accountSignupButton => 'Konto erstellen';

  @override
  String get authTerminalTagline => 'Meistere den Geist, meistere den Trade';

  @override
  String get authTerminalCtaLogin => 'Terminal starten';

  @override
  String get authTerminalCtaSignup => 'Identität erstellen';

  @override
  String get authTerminalEncryptedPrefix => 'Verschlüsselter Knoten:';

  @override
  String get authTerminalEncryptedStatus => 'Aktiv';

  @override
  String get authTerminalHintEmail => 'name@terminal.com';

  @override
  String get authTerminalHintPassword => '••••••••';

  @override
  String get accountLoginSnackEmailMissing => 'Anmeldung: E-Mail eingeben';

  @override
  String get accountLoginSnackEmailReady => 'Anmeldung: E-Mail eingegeben';

  @override
  String get accountSignupSnackEmailMissing => 'Registrierung: E-Mail eingeben';

  @override
  String get accountSignupSnackFirstNameMissing =>
      'Registrierung: Vorname eingeben';

  @override
  String get accountSignupSnackLastNameMissing =>
      'Registrierung: Nachname eingeben';

  @override
  String get accountSignupSnackBirthDateMissing =>
      'Registrierung: Geburtsdatum auswählen';

  @override
  String get accountSignupSnackReady => 'Registrierung: Formular bereit';

  @override
  String get accountSignupSnackPasswordMissing =>
      'Registrierung: Passwort eingeben';

  @override
  String get accountSignupSnackPasswordMismatch =>
      'Registrierung: Passwörter stimmen nicht überein';

  @override
  String get accountSignupSnackPasswordTooShort =>
      'Das Passwort muss mindestens 6 Zeichen haben';

  @override
  String get accountLoginSnackPasswordMissing => 'Anmeldung: Passwort eingeben';

  @override
  String get accountForgotPasswordLink => 'Passwort vergessen?';

  @override
  String get accountForgotPasswordSnackEmailMissing =>
      'Gib oben deine E-Mail-Adresse ein, um den Link zu erhalten.';

  @override
  String get accountForgotPasswordSnackSent =>
      'Wenn ein Konto mit dieser E-Mail existiert, erhältst du einen Link zum Festlegen eines neuen Passworts.';

  @override
  String get accountForgotPasswordSnackTooManyRequests =>
      'Zu viele Anfragen. Bitte in einigen Minuten erneut versuchen.';

  @override
  String get accountPasswordResetDialogTitle => 'Passwort zurücksetzen';

  @override
  String get accountPasswordResetDialogSubtitle =>
      'Gib die E-Mail deines Paychek-Kontos ein. Wir senden dir einen Link zum Festlegen eines neuen Passworts.';

  @override
  String get accountPasswordResetCta => 'LINK SENDEN';

  @override
  String get accountPasswordResetBackToLogin => 'ZURÜCK ZUR ANMELDUNG';

  @override
  String get accountPasswordResetSnackEmailMissing =>
      'Gib deine E-Mail-Adresse ein.';

  @override
  String get accountPasswordResetSentDialogTitle => 'Prüfe dein Postfach';

  @override
  String get accountPasswordResetSentDialogMessage =>
      'Wenn ein Konto mit dieser Adresse existiert, erhältst du eine E-Mail mit einem Link zum Festlegen eines neuen Passworts. Schau auch im Spam-Ordner nach.';

  @override
  String get accountPasswordResetSentDialogCta => 'VERSTANDEN';

  @override
  String get accountAuthSignupSuccess => 'Konto erstellt';

  @override
  String get accountAuthLoginSuccess => 'Angemeldet';

  @override
  String get accountAuthErrorWeakPassword => 'Passwort zu schwach';

  @override
  String get accountAuthErrorEmailInUse =>
      'Diese E-Mail ist bereits registriert';

  @override
  String get accountAuthErrorInvalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get accountAuthErrorWrongCredentials => 'E-Mail oder Passwort falsch';

  @override
  String get accountAuthErrorNetwork =>
      'Netzwerkfehler. Bitte erneut versuchen.';

  @override
  String get accountAuthErrorGeneric => 'Es ist ein Fehler aufgetreten';

  @override
  String get accountAuthErrorRestartOrReload =>
      'Verbindung zur Authentifizierung verloren. App vollständig beenden und neu starten (im Web kein Hot Reload).';

  @override
  String get accountAuthErrorDifferentSignInMethod =>
      'Diese E-Mail ist bereits mit einer anderen Anmeldemethode verknüpft.';

  @override
  String accountAuthErrorWithFirebaseCode(String code) {
    return 'Es ist ein Fehler aufgetreten ($code).';
  }

  @override
  String get accountAuthErrorUnknownFirebaseAuth =>
      'Anmeldung fehlgeschlagen (unbekannt). Prüfe die Verbindung, versuche es erneut oder nutze Paychek in Chrome. In der Firebase-Konsole → Authentication: E-Mail/Passwort und genutzte Anbieter aktivieren.';

  @override
  String accountAuthErrorSignInServerMessage(String message) {
    return '$message';
  }

  @override
  String get accountAuthWindowsSignInNotice =>
      'In der Windows-Desktop-App ist die Firebase-Anmeldung oft unzuverlässig (bekannte Flutter-/Firebase-Einschränkung). Nutze die Paychek-Mobile-App oder melde dich im Browser an.';

  @override
  String get accountAuthWindowsOpenWebsite => 'paychek.pro im Browser öffnen';

  @override
  String get accountSocialAppleAndroidUseGoogle =>
      'Mit Apple anmelden ist in diesem Android-Build noch nicht eingerichtet. Nutze Google oder E-Mail, oder melde dich in der Web-App an.';

  @override
  String get accountSocialAppleUnavailableDesktop =>
      'Mit Apple anmelden ist in der Windows-/Linux-Desktop-App nicht verfügbar. Nutze die Web-App (Chrome), iPhone, iPad oder Mac.';

  @override
  String get accountSocialGoogleUnavailableDesktop =>
      'Google-Anmeldung auf Windows/Linux nicht verfügbar. Nutze Chrome, Android oder iOS.';

  @override
  String get accountSocialFacebookUnavailableDesktop =>
      'Facebook-Anmeldung ist in der Windows-/Linux-Desktop-App nicht verfügbar. Nutze die Web-App (Chrome), Android, iOS oder macOS.';

  @override
  String get accountSocialGoogleWebClientMissing =>
      'Für Google auf dem Smartphone/Tablet: Web-OAuth-Client-ID in lib/reglage/social_auth_config.dart eintragen. Unter Android die SHA-1-Fingerabdrücke der App in Firebase hinterlegen (Projekteinstellungen → Android-App).';

  @override
  String get paywallTitle => 'Deine Testphase ist vorbei';

  @override
  String get paywallHeadlineBefore => 'Deine kostenlose Testphase ';

  @override
  String get paywallHeadlineAccent => 'ist vorbei';

  @override
  String get paywallUpgradeSubtitle =>
      'Upgrade auf Pro, um dein volles Trading-Potenzial freizuschalten und deinen Vorteil zu behalten.';

  @override
  String paywallEndedOn(String date) {
    return 'Testphase beendet am $date.';
  }

  @override
  String get paywallCompareCurrentPlan => 'AKTUELLER PLAN';

  @override
  String get paywallCompareRecommended => 'EMPFOHLEN';

  @override
  String get paywallPlanLiteName => 'Lite';

  @override
  String get paywallPlanProName => 'Pro';

  @override
  String get paywallLiteFeature1 => '30 Trades / Monat';

  @override
  String get paywallLiteFeature2 => 'Nur manuelle Eingabe';

  @override
  String get paywallLiteFeature3 => 'Standard-Kalender';

  @override
  String get paywallProFeature1 => 'Unbegrenzt';

  @override
  String get paywallProFeature2 => 'CSV-Import & manuelle Eingabe';

  @override
  String get paywallProFeature3 => 'Pro-Kalender';

  @override
  String get paywallProFeature4 => 'Checkliste';

  @override
  String get paywallProFeature5 => 'Analyse-Generator';

  @override
  String get paywallProFeature6 => 'Strategie-Seite';

  @override
  String get paywallProFeature7 => 'Performance-Statistiken';

  @override
  String get paywallProFeature8 => 'Mentaler Zustand';

  @override
  String get paywallProFeature9 => 'PDF-Export';

  @override
  String get paywallPriceAnnualHighlight => '49,90 \$ US / Jahr';

  @override
  String get paywallPriceApproxPerMonth => 'Das sind etwa 4,15 \$ US / Monat';

  @override
  String paywallTrialEndedBody(String date) {
    return 'Deine kostenlose 7-Tage-Testphase (neue Registrierung) endete am $date. Ohne Pro nutzt du den Lite-Plan.';
  }

  @override
  String get paywallLiteLimitedHint =>
      'In Lite bleiben nur Trade hinzufügen und Kalender offen. Der Rest ist Pro vorbehalten.';

  @override
  String get paywallProPriceAnnual => 'Pro: 49,90 \$ US / Jahr';

  @override
  String get paywallContinueFreemium => 'Mit Lite fortfahren (eingeschränkt)';

  @override
  String get paywallSubscribeButton => 'Jetzt abonnieren';

  @override
  String get paywallRestoreButton => 'Ich habe bereits ein Abonnement';

  @override
  String get paywallStoreNotConfigured =>
      'Stripe-Checkout-URL fehlt. Admin → Config → Payment-Link (https://…), Abrechnung aktivieren, angemeldet bleiben, erneut versuchen.';

  @override
  String get paywallRestoreNothingFound =>
      'Noch gesperrt: kein aktives Abonnement erkannt.';

  @override
  String get paywallLegalFooter =>
      'Sichere Zahlung über Stripe • Jederzeit kündbar • Nutzungsbedingungen';

  @override
  String get paywallGoldPremiumPill => 'Premium-Zugang';

  @override
  String get paywallGoldMarketingHeadline => 'Upgrade auf PRO';

  @override
  String get paywallGoldTagline => 'Das Tool für profitable Trader.';

  @override
  String get paywallGoldYourPlanLabel => 'Aktuell';

  @override
  String get paywallGoldLiteColumnCaption => 'Standard';

  @override
  String get paywallGoldProColumnCaption => 'Unbegrenzt';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSupportSection => 'Support';

  @override
  String get settingsSupportCardTitle => 'Support & Feedback';

  @override
  String get settingsSupportCardSubtitle =>
      'Schreib uns und lies die Anleitungen in der App.';

  @override
  String get supportFeedbackTitleLead => 'Support & ';

  @override
  String get supportFeedbackTitleAccent => 'Feedback';

  @override
  String get supportFeedbackSubtitle =>
      'Frage oder Idee? Wir sind für dich da.';

  @override
  String get supportFeedbackBack => 'Zurück';

  @override
  String get supportActionEmailLabel => 'E-Mail';

  @override
  String get supportActionEmailHint => 'Antwort unter 24 Std.';

  @override
  String get supportActionDocsLabel => 'Docs';

  @override
  String get supportActionDocsHint => 'Anleitungen';

  @override
  String get supportActionTwitterLabel => 'X';

  @override
  String get supportActionTwitterHint => 'Community';

  @override
  String get supportFormNewMessage => 'Neue Nachricht';

  @override
  String get supportFormKindLabel => 'Art der Anfrage';

  @override
  String get supportFormKindAccount => 'Konto';

  @override
  String get supportFormKindBilling => 'Abrechnung';

  @override
  String get supportFormKindFeature => 'Funktion';

  @override
  String get supportFormKindOther => 'Sonstiges';

  @override
  String get supportFormEmailLabel => 'Deine E-Mail';

  @override
  String get supportFormEmailHint => 'name@beispiel.de';

  @override
  String get supportFormDescriptionLabel => 'Beschreibung';

  @override
  String get supportFormDescriptionHint => 'Details zur Nachricht…';

  @override
  String get supportFormSubmit => 'Jetzt senden';

  @override
  String get supportFormSubmitSuccess =>
      'Danke — deine Nachricht wurde erfolgreich gesendet.';

  @override
  String get supportFormSubmitSuccessPartial =>
      'Danke — deine Nachricht wurde gesendet (Anhang nicht hochgeladen).';

  @override
  String get supportFormSubmitDone =>
      'Falls dein Mailprogramm nicht öffnet: erneut versuchen oder uns direkt mailen.';

  @override
  String get supportFormErrorEmail => 'Bitte eine E-Mail-Adresse angeben.';

  @override
  String get supportFormErrorDescription =>
      'Bitte eine Beschreibung hinzufügen.';

  @override
  String get supportFormMailSubjectPrefix => 'Paychek Support';

  @override
  String get supportFormMailBodyIntro => 'Nachricht aus der Paychek-App:';

  @override
  String get supportFormAttachmentLabel => 'Anhang (optional)';

  @override
  String get supportFormAttachmentPick => 'Foto oder PDF';

  @override
  String get supportFormAttachmentHint => 'PDF oder Bild, max. 10 MB';

  @override
  String get supportFormAttachmentRemove => 'Datei entfernen';

  @override
  String get supportFormAttachmentSignInHint =>
      'Zum Anhängen anmelden — oder E-Mail ohne Anhang nutzen.';

  @override
  String get supportFormAttachmentTooLarge => 'Datei über 10 MB.';

  @override
  String get supportFormAttachmentInvalidExtension =>
      'Nur PDF, JPG, PNG oder WebP.';

  @override
  String get supportFormAttachmentReadFailed =>
      'Datei nicht lesbar. Bitte erneut versuchen.';

  @override
  String get supportFormSubmitFirestoreDone =>
      'Danke — Nachricht gespeichert. Team sieht sie in der Admin-Konsole.';

  @override
  String get supportFormSubmitSending => 'Wird gesendet…';

  @override
  String get supportFormSubmitError =>
      'Senden fehlgeschlagen. Verbindung prüfen.';

  @override
  String get supportFormSubmitSavedPartialAttachment =>
      'Nachricht gespeichert, Anhang nicht hochgeladen (Netzwerk, Timeout oder Storage). Firebase prüfen.';

  @override
  String get supportQuickHelpTitle => 'Kurzhilfe';

  @override
  String get supportFaqWhereDataQ => 'Wo sind meine Daten?';

  @override
  String get supportFaqWhereDataA =>
      'Daten liegen auf diesem Gerät (Einstellungen, Journal, Portfolios). Abmelden oder „Lokale Daten löschen“ entfernt sie — nutze PDF-Exporte für Archive.';

  @override
  String get supportFaqFeatureQ => 'Neue Funktion gewünscht?';

  @override
  String get supportFaqFeatureA =>
      'Nutze das Formular mit „Idee vorschlagen“. Wir lesen jede Nachricht.';

  @override
  String get supportStatusLabel => 'Technischer Status';

  @override
  String get supportStatusOperational => 'Alle Systeme betriebsbereit';

  @override
  String get helpCenterTitle => 'Hilfe-Center';

  @override
  String get helpCenterSubtitle =>
      'Kurzantworten und Erklärungen zur Nutzung der App.';

  @override
  String get helpCenterSearchHint => 'Suchen…';

  @override
  String get helpCenterVersionMobile => 'Mobile-Ansicht';

  @override
  String get helpCenterVersionWeb => 'Web-Ansicht';

  @override
  String get helpCenterEmptyResults => 'Keine Treffer.';

  @override
  String get helpCenterArticleAddTradeTitle => 'Trade hinzufügen';

  @override
  String get helpCenterArticleAddTradeBody =>
      'Öffne den Tab „Hinzufügen“, fülle die Felder aus (Asset, Einstieg, Stop, Ziel …) und speichere. Optional kannst du einen Screenshot anhängen.';

  @override
  String get helpCenterArticleEditTradeTitle => 'Trade- und Journal-Übersicht';

  @override
  String get helpCenterArticleEditTradeBody =>
      'Guide : Maîtriser votre Journal de Trading (Page Trade)\nLa page Trade est le centre d\'archivage intelligent de Paychek. Elle ne se contente pas de lister vos opérations ; elle les organise pour vous offrir une vision claire de votre progression, du trade individuel à la performance mensuelle.\n\n[img:assets/help_center/trade_page_header_filters.png]\n\n1. Tableau de Bord de Période (Header)\nEn haut de votre journal, vous disposez d\'un résumé instantané de la période sélectionnée :\n\nProfit Net : Votre résultat financier net en dollars et son impact en pourcentage sur votre capital (ex: +1070,00\$ / +53,50%).\n\nLe Win Rate Ring : L\'anneau central affiche votre pourcentage de réussite global. C\'est l\'indicateur visuel immédiat de la santé de votre trading.\n\nCompteur de Trades : Le détail précis du nombre de positions Gagnantes (G), Perdantes (P) et à l\'équilibre (Br).\n\n2. Navigation et Filtres Temporels\nPersonnalisez votre vue selon votre besoin d\'analyse grâce aux sélecteurs rapides :\n\nSélecteur 1D / 1S / 1M / ALL : Basculez instantanément entre une vue journalière, hebdomadaire, mensuelle ou l\'historique complet.\n\nFiltres de statut : Isolez vos trades Gagnants, Perdants ou Breakeven d\'un seul clic pour étudier des comportements spécifiques.\n\nActifs les plus tradés : Visualisez rapidement vos statistiques sur vos instruments préférés (ex: XAUUSD, EURUSD).\n\n[img:assets/help_center/trade_page_period_pdf_report.png]\n\n3. Structure en Accordéons et Rapports PDF\nL\'interface utilise un système de \"replier/déplier\" pour une lecture fluide et des options d\'exportation à tous les niveaux :\n\nRapports de Période (Jour/Semaine/Mois) : Chaque bloc de date (ex: \"14 Mars\") affiche un résumé de la performance du jour.\n\nEn cliquant sur l\'icône PDF à côté de la date, vous téléchargez un rapport complet de cette période spécifique. Idéal pour vos bilans de fin de semaine ou de mois.\n\nRapports de Trade Individuel : Cliquez sur un trade pour le déplier et voir ses détails (Heures, Session, Entry/Exit).\n\nChaque trade possède son propre bouton PDF. Ce document génère une fiche technique pro avec votre graphique et vos scores de discipline.\n\n[img:assets/help_center/trade_page_rings_week_view.png]\n\n4. Analyse visuelle par Ring\nChaque ligne (journée ou trade) est accompagnée d\'un Ring (anneau) :\n\nPour une journée, le ring représente le Win Rate global du jour.\n\nCela vous permet d\'identifier en une seconde vos journées \"rouges\" ou \"vertes\" sans avoir à lire chaque ligne de trade.\n\n[img:assets/help_center/trade_page_options_menu.png]\n\n5. Options de Gestion et Correction (Les 3 points)\nParce qu\'une erreur de saisie peut arriver, Paychek vous donne un contrôle total sur vos archives. À côté de l\'icône PDF de chaque fiche trade, vous trouverez un menu \"Options\" (représenté par 3 points verticaux) :\n\nModifier le Trade : Vous permet de réouvrir le formulaire de saisie pour corriger un prix, changer l\'heure, ajouter un screenshot oublié ou ajuster vos scores de discipline.\n\nSupprimer le Trade : Efface définitivement l\'enregistrement de votre journal.\n\nAttention : La suppression d\'un trade mettra à jour instantanément vos statistiques globales, votre Win Rate et votre capital dans les pages Trade et Performance.';

  @override
  String get helpCenterArticleChecklistTitle => 'Checkliste';

  @override
  String get helpCenterArticleChecklistBody =>
      '📋 Checklist\n\n[img:assets/help_center/checklist_routine_discipline.png]\n\n1. Understanding the progress ring\nThe colored circle at the top of your screen is your readiness indicator.\n\n- Real-time progress: each ticked box moves the percentage forward.\n- Your checklist ring is not only on Routine — it stays in sync on your main Dashboard.\n- The gold standard: we recommend never opening a position unless your ring is at 100%. A trade taken with an incomplete checklist is often an emotional trade.\n\n2. Customize your routine\nEvery trader is unique. Paychek lets you build your own verification system.\n\n- Add a section: tap “+ Add a section” at the bottom to create a category (e.g. morning routine, economic news, post-session).\n- Manage items (⋯ menu):\n  - Add a task: open the three-dot menu next to a section title to insert a new checkpoint.\n  - Delete / edit: if a rule no longer fits your strategy, remove it to keep the UI clean.\n\n3. Default sections\nTo help you get started, we include three pillars:\n\n- Technical Analysis: validate your confluences (trend, S/R, indicators).\n- Risk Management: confirm your stop-loss is set and your risk per trade is respected.\n- Psychology: a quick check that you are not in revenge mode or euphoria.';

  @override
  String get helpCenterArticleCalendarTitle => 'Kalender';

  @override
  String get helpCenterArticleCalendarBody =>
      '📅 Guide: Calendar & performance analysis\n\nThe Paychek Calendar is your main steering tool. It turns raw data into a visual map of your success and discipline.\n\n[img:assets/help_center/calendar_overview.png]\n\n1. Month overview\nColor coding: Green cells show net profit, red cells a loss, and gray cells days with no activity.\n\nQuick summary: Above the calendar, see your win rate, trade count, and total monthly P&L at a glance.\n\nMonthly objective: Watch the progress bar to see how far you are from your financial goal. Tap the settings icon to change your target.\n\n[img:assets/help_center/calendar_monthly_objective.png]\n\n2. Expandable menu (deep analysis)\nTap any month header to open detailed analysis.\n\n[img:assets/help_center/calendar_deep_analysis.png]\n\nDiscipline rings: View your average discipline scores for the month (plan followed, checklist completed, mental state).\n\nSession breakdown: See performance by timezone — Asia, Europe, and US. Great for spotting which part of the day pays best for you.\n\nInteractive sparkline (performance curve):\n- Hover the line to pinpoint a trade (on mobile, drag along the curve with your finger).\n- Tap a point on the curve to open that trade’s full record instantly.\n\n3. Session statistics (sidebar)\nTo the right of your calendar, your consistency stats:\n\nCumulative performance: How your capital evolves day by day.\n\nBest day: Your largest daily gain of the month.\n\nAverage day: What you gain or lose on average per day.\n\n[img:assets/help_center/calendar_trades_month_report.png]\n\n4. PDF export 📄\nAt the top right of the Calendar page, the PDF icon generates a professional report in one tap.\n\nWhat’s inside: The report includes the visual calendar, the performance curve, and a recap of your discipline averages.';

  @override
  String get helpCenterArticleMentalStateTitle => 'Mentaler Zustand';

  @override
  String get helpCenterArticleMentalStateBody =>
      'Guide: Mental state — tailor your psychology\n\nRoughly 80% of trading success is psychology. The Mental state page lets you measure how you feel and see how emotions affect your results.\n\n[img:assets/help_center/mental_state_dashboard.png]\n\n1. Global score (The Ring)\nThe central ring shows your “Solid Balance”. It updates from all your indicators (emotions, rest, routines). The higher the score, the more you are in a mindset suited to trading.\n\n2. Personalized impact (gear ⚙️)\nEvery trader is different. Paychek lets you define your own rules:\n\n[img:assets/help_center/mental_state_adjust_impact.png]\n\n- Impact nature: open a criterion’s gear to set Positive (+) or Negative (−). Example: if excitement is dangerous for you, set it to Negative.\n\n- Global impact (%): the slider sets how much that criterion weighs on your global score. Crank it up for what matters most; lower it for secondary criteria.\n\n3. Sections & emotions\n\n[img:assets/help_center/mental_state_section_controls.png]\n\n- Edit / delete: pencil to rename an emotion or indicator; trash to remove it.\n\n- Section toggle (ON / OFF 100%): turn off an entire section (e.g. My Routines). When off, it no longer counts toward your daily global score.\n\n- Add (+): create your own indicators to match your routine.\n\n4. Score calendar & time window\nThe mini-calendar shows your mental score for past days.\n\n- Session settings (⚙️): set a start time and an end time.\n\n- Day mode: track from morning to evening (full-day style window).\n\n- Session mode: focus on trading hours only (e.g. 3:30 PM – 10:00 PM).';

  @override
  String get helpCenterArticleExportPdfTitle => 'PDF exportieren';

  @override
  String get helpCenterArticleExportPdfBody =>
      'Unter „Trade“ oder „Performance“ „PDF exportieren“ wählen. Schlägt es fehl, Berechtigungen prüfen und erneut versuchen.';

  @override
  String get helpCenterArticleResetDataTitle => 'Lokale Daten löschen';

  @override
  String get helpCenterArticleResetDataBody =>
      'Unter Einstellungen > Daten kannst du die auf diesem Gerät gespeicherten Daten löschen. Das lässt sich nicht rückgängig machen; einen App-Neustart danach empfehlen wir.';

  @override
  String get helpCenterArticleMyStrategyTitle => 'Meine Strategie — Playbook';

  @override
  String get helpCenterArticleMyAnalysisTitle => 'Meine Analyse — Tradingpläne';

  @override
  String get helpCenterArticleMyAnalysisBody =>
      '🔬 My Analysis: Build Your Trading Plans\n\nThe My Analysis page lets you build a full roadmap before you enter the market. By quantifying each technical element, Paychek calculates a global confidence score to validate your setup.\n\n[img:assets/help_center/analyse_trend_sheet.png]\n\n1. Trend card (context)\nDefine the frame for your opportunity:\n\nAsset & name: Use (+) to name your analysis and the instrument (e.g. EUR/USD — Weekly Swing Plan).\n\nDirection & phase: Choose your bias (Buy, Sell, or Watch) and the current market phase (Accumulation, Impulse, Distribution).\n\nConfidence slider: Set how certain you feel for this section. Open the gear (⚙️) to adjust this card’s impact (weight %) on the final report confidence.\n\n[img:assets/help_center/analyse_card_controls.png]\n\nCustomization: Use the pencil to edit available timeframes or phases, and Duplicate to compare several analyses on different timeframes in the same section.\n\n2. Technical sections (Structure, SMC, Indicators, Volume)\nEveryone trades differently. Turn cards on or off with the ON/OFF switch:\n\n[img:assets/help_center/analyse_technical_cards.png]\n\nStructure: Log support and resistance. Tick if a level was tested more than twice to strengthen relevance.\n\nSMC & Liquidity: Record Order Blocks, Fair Value Gaps (FVG), and Fibonacci levels.\n\nIndicators & Volume profile: Detail RSI/MACD signals or Point of Control (POC) zones.\n\nScreenshot: Attach a chart capture to illustrate your plan visually.\n\n3. Generating the report\nWhen your analysis is ready, tap Report.\n\n[img:assets/help_center/analyse_summary_report.png]\n\nGlobal confidence ring: The final ring is computed from your sliders and their impact weights.\n\nDynamic color coding: The validated report at the bottom uses a color that matches your direction: green (Buy), red (Sell), or yellow (Watch).\n\n[img:assets/help_center/analyse_report_embedded.png]\n\n4. Managing reports\nHistory: Reports are saved and tied to your instruments.\n\nActions: You can edit (pencil), delete (trash), or export a professional PDF of your analysis to archive or share.\n\n[img:assets/help_center/analyse_report_pdf.png]';

  @override
  String get helpCenterArticlePerformanceTitle =>
      'Performance — Trading-Scanner';

  @override
  String get settingsLogoutButton => 'Abmelden';

  @override
  String get settingsLogoutSnack => 'Du bist abgemeldet.';

  @override
  String get settingsLogoutSnackPartial =>
      'Profil auf diesem Gerät gelöscht. Erscheint dein Konto noch, prüfe die Verbindung oder starte die App neu.';

  @override
  String get splashTagline => 'Meistere den Geist, meistere den Trade';

  @override
  String get statsAvgGain => 'Durchschnittlicher Gewinn';

  @override
  String get statsPsychSub => 'Plan befolgt';

  @override
  String get statsPsychology => 'Psychologie';

  @override
  String get statsRR => 'R/R-Verhältnis';

  @override
  String get statsSectionTitle => 'STATISTIKEN';

  @override
  String get statsStrategy => 'Strategie';

  @override
  String get statsStrategySub => 'Kriterien validiert';

  @override
  String get strategieAlertSignal => 'WARNSIGNAL';

  @override
  String get strategieDescription => 'BESCHREIBUNG';

  @override
  String get strategieDescriptionHint => 'z.B. ';

  @override
  String get strategieEditSessionTitle => 'Sitzung bearbeiten';

  @override
  String get strategieHintEntry => 'Wo kann man auf KAUFEN/VERKAUFEN klicken?';

  @override
  String get strategieHintIndicatorTag => 'z.B. ';

  @override
  String get strategieHintInvalidation => 'Wo ist das Szenario falsch?';

  @override
  String get strategieHintManagement => 'Wie sichert man die Position?';

  @override
  String get strategieHintPattern => 'z.B. ';

  @override
  String get strategieHintSignal => 'Auslösen…';

  @override
  String get strategieHintTarget => 'Endgültige Ziel- oder Liquiditätszonen';

  @override
  String get strategieHintTimeframeTag => 'z.B. ';

  @override
  String get strategieIndicators => 'INDIKATOREN';

  @override
  String get strategieModelName => 'MODELLNAME';

  @override
  String get strategieNewSessionTitle => 'Neue Sitzung';

  @override
  String get strategiePatternFigure => 'MUSTER / FIGUR';

  @override
  String get strategieRuleEntryPrecise => 'PRÄZISE EINGABE';

  @override
  String get strategieRuleInvalidation => 'UNGÜLTIGKEIT (STOP LOSS)';

  @override
  String get strategieRuleManagement => 'MANAGEMENT (BREAKEVEN / PARTIALS)';

  @override
  String get strategieRuleTarget => 'ZIEL (GEWINN MITNEHMEN)';

  @override
  String get strategieSessionName => 'SITZUNGSNAME';

  @override
  String get strategieSetupColor => 'FARBE';

  @override
  String get strategieSetupEditTitle => 'Setup bearbeiten';

  @override
  String get strategieSetupNewTitle => 'Neues Setup';

  @override
  String get strategieTimeEndOptionalLabel => 'ENDE (OPTIONAL)';

  @override
  String get strategieTimeStartLabel => 'START';

  @override
  String get strategieTimeframes => 'ZEITRAHMEN';

  @override
  String get strategieZoneNoTrade => 'Kein Handel';

  @override
  String get strategieZoneTrade => 'Handel';

  @override
  String get strategieZoneType => 'ZONENTYP';

  @override
  String get strategiePagePlaybookIntro =>
      'Dein Trading-Plan (Playbook). Lies diese Regeln vor jeder Session, um diszipliniert und fokussiert zu bleiben.';

  @override
  String get analyseReportTitle => 'Bericht';

  @override
  String get strategieGestionCaptionMaximum => 'Maximum';

  @override
  String get strategieGestionCaptionMinimum => 'Minimum';

  @override
  String get strategieSectionSetupsAndModels => 'SETUPS & VORLAGEN';

  @override
  String get strategieSectionTradeCalendar => 'TRADE-KALENDER';

  @override
  String get strategieCalendarNeedSetupForUsage =>
      'Fügen Sie oben ein Setup hinzu, um die Nutzungstage zu erfassen.';

  @override
  String strategieCalendarUsageForSetup(String name) {
    return 'Nutzung — $name';
  }

  @override
  String get strategieCalendarUsageTooltip =>
      'Tag für dieses Setup markieren oder löschen (gleicher Name wie unter Trade hinzufügen).';

  @override
  String get strategieCalendarDotsExplain =>
      'Ein Punkt pro Strategie an diesem Tag, aus Ihren Trades (Trade hinzufügen, Eingangsdatum).';

  @override
  String get strategieSetupNavPrevious => 'ZURÜCK';

  @override
  String get strategieSetupNavNext => 'NÄCHSTES SETUP >';

  @override
  String get strategieSheetSetupsTitle => 'Setups & Vorlagen';

  @override
  String get strategieMenuDisableFactors => 'Deaktiviert';

  @override
  String get strategieManageTemplates => 'Vorlagen verwalten';

  @override
  String get strategieDuplicateSetup => 'Setup duplizieren';

  @override
  String get strategieMesReglesDraftHint => 'Neue Regel...';

  @override
  String get strategieSetupRemoveFromDashboard => 'Vom Dashboard entfernen';

  @override
  String get strategieSetupShowOnDashboard => 'Im Dashboard anzeigen';

  @override
  String get strategiePdfPlaybookBlurbShort =>
      'Dein Trading-Plan (Playbook). Lies diese Regeln vor jeder Session.';

  @override
  String get strategiePdfFooterNote =>
      'Goldene Regeln: Referenztexte (nicht gespeichert). Risiko, Zeiten und Setups: gespeicherte Daten.';

  @override
  String get strategiePdfTableSession => 'Session';

  @override
  String get strategiePdfTableDescription => 'Beschreibung';

  @override
  String get strategiePdfTableSchedule => 'Zeiten';

  @override
  String get strategiePdfTechnicalContext => 'Technischer Kontext';

  @override
  String get strategiePdfAlertSignal => 'Alert-Signal';

  @override
  String get strategiePdfFileNamePrefix => 'meine_strategie';

  @override
  String strategiePdfExportError(String error) {
    return 'PDF konnte nicht erstellt werden: $error';
  }

  @override
  String get symbolHint => 'z.B. ';

  @override
  String get symbolLabel => 'Symbol';

  @override
  String get tradeColEndingBalance => 'Endbilanz';

  @override
  String get tradeColPnl => 'PnL';

  @override
  String get tradeColResult => 'Ergebnis';

  @override
  String get tradeColStartingBalance => 'Ausgangsbilanz';

  @override
  String get tradeColTotalGain => 'Gesamtgewinn';

  @override
  String get tradeColTotalGainPct => 'Gesamtgewinn %';

  @override
  String get tradeColTrade => 'Handel #';

  @override
  String get tradeDeleteConfirmBody => 'Diese Aktion ist dauerhaft.';

  @override
  String get tradeDeleteConfirmTitle => 'Diesen Handel löschen?';

  @override
  String get tradeReturn => 'Handelsrendite';

  @override
  String get tradeActionsTooltip => 'Aktionen';

  @override
  String get tradeAverageShort => 'DURCHSCHNITT';

  @override
  String tradeDayTradeNumber(int n) {
    return 'Handeln Sie noch heute #$n';
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
  String get tradeEditMenu => 'Bearbeiten';

  @override
  String get tradeExportPdfTooltip => 'PDF exportieren';

  @override
  String get tradeFilterAll => 'Alle';

  @override
  String get tradeFilterBreakeven => 'Die Gewinnzone erreichen';

  @override
  String get tradeFilterLoser => 'Verlierer';

  @override
  String get tradeFilterOpenPosition => 'Offene Stellen';

  @override
  String get tradeFilterWinner => 'Gewinner';

  @override
  String tradeSummaryBreakdownShort(int w, int l, int b) {
    return 'G:$w  V:$l  B:$b';
  }

  @override
  String tradeSummaryBreakdownWithOpen(int w, int l, int b, int o) {
    return 'G:$w  V:$l  B:$b  Off:$o';
  }

  @override
  String get tradeGainShort => 'NETTO';

  @override
  String get tradeLabelChecklist => 'Checkliste';

  @override
  String get tradeLabelDuration => 'Dauer';

  @override
  String get tradeLabelEntry => 'Eintrag';

  @override
  String get tradeLabelEtat => 'Zustand';

  @override
  String get tradeLabelExit => 'Ausfahrt';

  @override
  String get tradeLabelHours => 'Std';

  @override
  String get tradeLabelPlan => 'Planen';

  @override
  String get tradeLabelSession => 'Sitzung';

  @override
  String get tradeLabelStrategie => 'Strategie';

  @override
  String get tradeLabelNews => 'News';

  @override
  String get tradeMindsetFeeling => 'Gefühl';

  @override
  String get tradeMindsetPrinciple => 'Prinzip';

  @override
  String get tradeMonthTitle => 'Monat';

  @override
  String get tradeMostTradedHeading =>
      'Die am häufigsten gehandelten Vermögenswerte';

  @override
  String get tradeNotRespected => 'Nicht befolgt';

  @override
  String tradeOpenPositionLine(String when) {
    return 'Offene Position • Eintrag $when';
  }

  @override
  String get tradePdfAnalysePostTrade => 'Überprüfung nach dem Handel';

  @override
  String get tradePdfBarresSemaine => 'Wochenbalken';

  @override
  String get tradePdfCloture => 'Geschlossen';

  @override
  String get tradePdfPositionOpen => 'Offene Position';

  @override
  String tradePdfDatePrefix(String when) {
    return 'Datum: $when';
  }

  @override
  String tradePdfDetailsTitle(String pair) {
    return 'Handelsdetails ($pair)';
  }

  @override
  String get tradePdfEtatPsychologique => 'Psychischer Zustand';

  @override
  String get tradePdfTags => 'Tags';

  @override
  String get tradeTagsSection => 'TAG';

  @override
  String get tradePdfExportDayTitle => 'Trades (Tag)';

  @override
  String get tradePdfExportMonthTitle => 'Trades (Monat)';

  @override
  String get tradePdfExportWeekTitle => 'Trades (Woche)';

  @override
  String get tradePdfGainNet => 'Netto-Gewinn- und Verlustrechnung';

  @override
  String get tradePdfImpactCapital => 'Kapitalwirkung';

  @override
  String get tradePdfMoyenne => 'Durchschnitt';

  @override
  String get tradePdfNonRespecte => 'Nicht befolgt';

  @override
  String get tradePdfPeriode => 'Zeitraum';

  @override
  String get tradePdfQualiteMoyennes => 'Qualität (Durchschnitte)';

  @override
  String tradePdfScreenshotTitle(String pair) {
    return 'Screenshot – $pair';
  }

  @override
  String get tradePdfSessions => 'Sitzungen';

  @override
  String get tradePdfSparklineMois => 'Monats-Sparkline';

  @override
  String get tradePdfTrades => 'Gewerbe';

  @override
  String get tradePdfWinRate => 'Gewinnrate';

  @override
  String tradePctOfCapital(String percent) {
    return '$percent% des Kapitals';
  }

  @override
  String get tradeScreenshotLoadError => 'Bild konnte nicht geladen werden';

  @override
  String get tradeScreenshotUnavailableWeb =>
      'Screenshot nicht verfügbar (Web)';

  @override
  String get tradeSectionChecklist => 'Checkliste';

  @override
  String get tradeSectionEtat => 'Zustand';

  @override
  String get tradeSectionPlan => 'Planen';

  @override
  String get tradeSectionStrategie => 'Strategie';

  @override
  String tradeStrategieNonRespectUnmapped(String id) {
    return 'Strategie-Detail ($id)';
  }

  @override
  String get tradeSessionAsia => 'Asien';

  @override
  String get tradeSessionEurope => 'Europa';

  @override
  String get tradeSessionLate => 'Nach Stunden';

  @override
  String get tradeSessionUs => 'UNS';

  @override
  String get tradeSideBreakevenShort => 'DIE GEWINNZONE ERREICHEN';

  @override
  String get tradeSideBuyLong => 'Kaufen';

  @override
  String get tradeSideBuyShort => 'KAUFEN';

  @override
  String get tradeSideSellLong => 'Verkaufen';

  @override
  String get tradeSideSellShort => 'VERKAUFEN';

  @override
  String get tradeSummaryProfitNet => 'NETTO-Gewinn- und Verlustrechnung';

  @override
  String get tradeSummaryTrades => 'GEWERBE';

  @override
  String get tradeSummaryWinRate => 'GEWINNRATE';

  @override
  String get tradeTotalUpper => 'GESAMT';

  @override
  String get tradeTradesListHeading => 'Gewerbe';

  @override
  String get tradeTradesMonthHeading => 'Trades (Monat)';

  @override
  String get tradeTradesWeekHeading => 'Trades (Woche)';

  @override
  String get tradeWeekTitle => 'Woche';

  @override
  String get tradeWinDayRingSubtitle => 'GEWINN (Tag)';

  @override
  String get tradeWinrateLabel => 'Gewinnrate';

  @override
  String get settingsTradingWeek5 => '5 Tage (Mo–Fr)';

  @override
  String get settingsTradingWeek7 => '7 Tage (Mo–So)';

  @override
  String get settingsTradingWeekSubtitle =>
      '5 Tage für klassische Märkte (Mo–Fr), 7 Tage für die volle Kalenderwoche (z. B. Krypto).';

  @override
  String get settingsTradingWeekTitle => 'Angezeigte Woche';

  @override
  String get settingsDashboardCardSubtitle =>
      'Start anpassen: Abschnitte und Reihenfolge';

  @override
  String get settingsDashLayoutTitle => 'Start-Abschnitte';

  @override
  String get settingsDashLayoutReorderHint =>
      'Ziehen Sie die Griffe zum Sortieren. Deaktivieren Sie einen Abschnitt, um ihn auf dem Startbildschirm auszublenden.';

  @override
  String get settingsDashOpenHomeButton => 'Start anzeigen';

  @override
  String get settingsDashSectionCapital => 'Kapital und Winrate';

  @override
  String get settingsDashSectionChecklist => 'Checkliste';

  @override
  String get settingsDashSectionAnalyse => 'Analyse';

  @override
  String get settingsDashSectionEtat => 'Mentaler Zustand';

  @override
  String get settingsDashSectionStrategie => 'Strategie';

  @override
  String get settingsDashSectionWeekly => 'Wöchentliche Performance';

  @override
  String get settingsDashSectionEvolution => 'Kapitalentwicklung';

  @override
  String get tradingSection => 'Handel';

  @override
  String get settingsCgvSection => 'AGB';

  @override
  String get settingsCgvPageTitle => 'Allgemeine Verkaufsbedingungen';

  @override
  String get settingsCgvRowTitle => 'Allgemeine Verkaufsbedingungen';

  @override
  String get settingsCgvRowSubtitle => 'Vollständigen Text in der App lesen';

  @override
  String get settingsCgvDocHeading =>
      'ALLGEMEINE VERKAUFSBEDINGUNGEN (AVB) - PAYCHEK';

  @override
  String get settingsCgv1Title => '1. Gegenstand';

  @override
  String get settingsCgv1Body =>
      'Diese AVB regeln das Abonnement für den „Premium“-Zugang zur Paychek-Anwendung, einem Trading-Tagebuch und Risikomanagement-Tool. Der Zugang erfolgt per jährlichem Abonnement mit automatischer Verlängerung um jeweils ein Jahr bis zur Kündigung.';

  @override
  String get settingsCgv2Title => '2. Erbrachte Leistungen';

  @override
  String get settingsCgv2Body =>
      'Der Premium-Zugang schaltet sämtliche Funktionen der Anwendung frei (erweiterte Statistiken, automatische Risikoberechnung, Datenexport). Der Zugang ist mit dem bei der Registrierung erstellten Nutzerkonto verknüpft.';

  @override
  String get settingsCgv3Title => '3. Preise und Zahlung';

  @override
  String get settingsCgv3Body =>
      'Direktabonnement: Der Preis beträgt 49,90 \$ USD pro Jahr (automatische Verlängerung bis zur Kündigung).\n\nPartnerangebot: Der Zugang kann kostenlos gewährt werden, wenn der Nutzer die Empfehlungsbedingungen bei einem unserer Partner erfüllt (Prop Firm oder Broker).\n\nPaychek behält sich vor, die Preise für Neukunden jederzeit zu ändern.';

  @override
  String get settingsCgv4Title => '4. Widerrufsrecht und Erstattung';

  @override
  String get settingsCgv4Body =>
      'Gemäß dem Gesetz über digitale Produkte:\n\nAufgrund der digitalen Natur der Leistung und des unmittelbaren Zugangs nach Zahlung erklärt sich der Nutzer damit einverstanden, dass die Leistung sofort beginnt, und verzichtet ausdrücklich auf sein 14-tägiges Widerrufsrecht.\n\nEine Erstattung erfolgt nicht, sobald der Premium-Zugang aktiviert wurde, außer bei einem schwerwiegenden technischen Mangel, der die Nutzung der Anwendung unmöglich macht.';

  @override
  String get settingsCgv5Title => '5. Besondere Klausel „Partnerangebot“';

  @override
  String get settingsCgv5Body =>
      'Der über einen Partner gewährte Zugang setzt die Bestätigung der Partnerschaft durch diesen Partner voraus.\n\nLehnt der Partner die Partnerschaft ab (z. B. wegen Nichteinhaltung von Einzahlungs- oder Trading-Regeln), behält sich Paychek vor, den Premium-Zugang zu widerrufen oder den Standardpreis zu verlangen.';

  @override
  String get settingsCgv6Title => '6. Risikohinweis (Trading)';

  @override
  String get settingsCgv6Body =>
      'Paychek ist kein Finanzberater. Die Anwendung ist ein technisches Hilfsmittel für Organisation und Analyse.\n\nTrading birgt ein hohes Risiko von Kapitalverlusten. Der Nutzer ist allein für seine Trading-Entscheidungen verantwortlich.\n\nPaychek haftet nicht für finanzielle Verluste des Nutzers an den Finanzmärkten.';

  @override
  String get settingsCgv7Title => '7. Verfügbarkeit des Dienstes';

  @override
  String get settingsCgv7Body =>
      'Paychek bemüht sich um einen 24/7-Zugang. Wir haften jedoch nicht für Unterbrechungen durch Wartung oder Ausfälle von Servern Dritter (Firebase, Google Cloud).';

  @override
  String get settingsCgv8Title => '8. Datenschutz';

  @override
  String get settingsCgv8Body =>
      'Trading-Daten der Nutzer sind streng vertraulich und werden nicht weiterverkauft. Sie werden sicher über unsere technischen Dienstleister gespeichert.';

  @override
  String get settingsPrivacyRowTitle => 'Datenschutzerklärung';

  @override
  String get settingsPrivacyRowSubtitle =>
      'Personenbezogene Daten, Cookies und Ihre Rechte';

  @override
  String get settingsPrivacyPageTitle => 'Datenschutzerklärung';

  @override
  String get settingsPrivacyDocHeading => 'DATENSCHUTZERKLÄRUNG — PAYCHEK';

  @override
  String get settingsDataResetSection => 'Daten';

  @override
  String get settingsDataResetTitle => 'Alle lokalen Daten löschen';

  @override
  String get settingsDataResetDescription =>
      'Wenn du Paychek eine Zeit lang genutzt hast und von vorne beginnen möchtest (wie nach einer Neuinstallation), kannst du alle auf diesem Gerät gespeicherten Daten löschen: Trades, Analysen, Journal, Dashboard-Layout, lokales Profil, Test-Anker usw.\n\nSprache und Einstellung „angezeigte Woche“ bleiben erhalten.\n\nSchließe die App vollständig und öffne sie neu, damit auch temporärer Speicher (z. B. Checkliste) aktualisiert wird.';

  @override
  String get settingsDataResetButton => 'Alle lokalen Daten löschen';

  @override
  String get settingsDataResetDialogTitle => 'Alle lokalen Daten löschen?';

  @override
  String get settingsDataResetDialogBody =>
      'Dies kann nicht rückgängig gemacht werden. Alle lokalen Paychek-Daten auf diesem Gerät werden gelöscht. Deine Firebase-Anmeldung kann bestehen bleiben – nur lokale Kopien werden entfernt.\n\nStarte die App danach neu, falls noch etwas zwischengespeichert wirkt.';

  @override
  String get settingsDataResetDialogCancel => 'Abbrechen';

  @override
  String get settingsDataResetDialogConfirm => 'Löschen';

  @override
  String get settingsDataResetSuccess =>
      'Lokale Daten gelöscht. App neu starten, falls nötig.';

  @override
  String get validate => 'Bestätigen';

  @override
  String get winrate => 'Gewinnrate';
}
