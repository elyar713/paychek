// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get actionAdd => 'Agregar';

  @override
  String get addPortfolio => 'Agregar cartera';

  @override
  String get ajouterTradeCapitalRequiredHint =>
      'Establezca una capital (cuestionario) para permitir el cálculo.';

  @override
  String get ajouterTradeCapitalGainEnterExitToShowPnl =>
      'Ingrese el precio de salida para mostrar las pérdidas y ganancias.';

  @override
  String get ajouterTradeCapitalGainOpenPositionNote =>
      'Posición abierta: las pérdidas y ganancias estimadas se mostrarán cuando cierres.';

  @override
  String get ajouterTradeCommissionFeesLabel => 'Honorarios (comisión)';

  @override
  String get ajouterTradeFillSuggestedLot => 'Llenar lote';

  @override
  String get ajouterTradeSizingEstimationFootnote =>
      '* Las estimaciones utilizan capital ahorrado; Las cifras del contrato/CFD son aproximadas.';

  @override
  String get ajouterTradeScreenshotHelp =>
      'Agregue un gráfico o una captura de pantalla de configuración (opcional).';

  @override
  String get ajouterTradeCsvChooseSoftware => 'Choisir un logiciel';

  @override
  String get ajouterTradePageTitle => 'Agregar comercio';

  @override
  String get ajouterTradeErrorQtyPositive =>
      'Introduzca un tamaño de posición mayor que 0.';

  @override
  String get ajouterTradeErrorEntryPrice =>
      'Introduzca un precio de entrada válido (mayor que 0).';

  @override
  String get ajouterTradeErrorExitOrFlags =>
      'Ingrese un precio de salida válido o verifique la posición de equilibrio/abierta si aún no se conoce la salida.';

  @override
  String get ajouterTradePsychTagBlind => 'Ciego';

  @override
  String get ajouterTradeCapitalGainHeading => 'CAPITAL Y GANANCIA';

  @override
  String get ajouterTradeMindsetPrompt => 'Realizaste esta operación con:';

  @override
  String get ajouterTradeDisciplineSettingsTooltip =>
      'Configuración: Secciones de sensación y actividad.';

  @override
  String get ajouterTradeSaveAndNext => 'Guardar y siguiente';

  @override
  String ajouterTradeLiteMonthlyLimitReached(int max) {
    return 'Lite: puedes registrar hasta $max operaciones por mes natural. Pasa a Pro para entradas ilimitadas.';
  }

  @override
  String ajouterTradeLiteMonthlyLimitImportSkipped(int skipped, int max) {
    return '$skipped operación(es) no importada(s): Lite permite como máximo $max operaciones por mes natural.';
  }

  @override
  String get tradeImportPickSoftwareFirst =>
      'Elige una plataforma antes de importar.';

  @override
  String get tradeImportEmptyFile => 'Archivo vacío o ilegible.';

  @override
  String get tradeImportMt4HtmlOnly => 'MT4: usa una exportación HTML/HTM.';

  @override
  String get tradeImportTradingViewCsvOnly =>
      'TradingView: usa una exportación CSV.';

  @override
  String get tradeImportCtraderHtmlOnly =>
      'cTrader: usa un informe HTML/HTM (cuenta).';

  @override
  String get tradeImportTradovateOrdersCsv =>
      'Tradovate: exporta Orders.csv (ejecuciones).';

  @override
  String get tradeImportTradovatePickOrdersCsv =>
      'Tradovate: elige un archivo Orders.csv.';

  @override
  String get tradeImportNinjaGridCsv =>
      'NinjaTrader: exporta una cuadrícula CSV (órdenes o ejecuciones).';

  @override
  String get tradeImportNinjaPickCsv =>
      'NinjaTrader: elige un archivo CSV (cuadrícula).';

  @override
  String get tradeImportRithmicCsv =>
      'Rithmic: usa una exportación CSV (Recent Orders).';

  @override
  String get tradeImportRithmicPickCsv => 'Rithmic: elige un archivo CSV.';

  @override
  String get tradeImportQuantowerCsv =>
      'Quantower: usa una exportación CSV (Orders history).';

  @override
  String get tradeImportQuantowerPickCsv =>
      'Quantower: elige un archivo CSV (Orders history).';

  @override
  String get tradeImportAtasXlsxReadFailed =>
      'No se pudo leer el .xlsx (vacío o demasiado grande para el navegador). Inténtalo de nuevo.';

  @override
  String get tradeImportAtasPickCsvXlsx =>
      'ATAS: elige un archivo CSV o .xlsx (Estadísticas).';

  @override
  String get tradeImportAtasXlsxEmptyFile => 'Archivo vacío.';

  @override
  String get tradeImportAtasXlsxInvalidFormat =>
      'No es un .xlsx Excel válido (falta la cabecera). Vuelve a exportar desde ATAS.';

  @override
  String get tradeImportAtasXlsxJournalMissing =>
      'Hoja Journal no encontrada o libro ilegible. Revisa la exportación Estadísticas .xlsx.';

  @override
  String get tradeImportAtasXlsxNoRows =>
      'Ninguna fila de operación reconocida. Abre la hoja Journal: columnas Instrument, Open time, Open/Close volume.';

  @override
  String tradeImportNotImplemented(String source) {
    return 'Importación $source aún no disponible.';
  }

  @override
  String tradeImportEmptyMt5(String extension) {
    return 'MT5 $extension: no se detectaron filas Position.';
  }

  @override
  String get tradeImportEmptyTradingView =>
      'TradingView CSV: no se detectaron posiciones cerradas.';

  @override
  String get tradeImportEmptyCtrader =>
      'cTrader HTML: no se detectaron filas Historial.';

  @override
  String get tradeImportEmptyTradovate =>
      'Tradovate CSV: no se detectó round-trip (entrada/salida).';

  @override
  String get tradeImportEmptyNinjaTrader =>
      'NinjaTrader CSV: no se detectó round-trip (entrada/salida).';

  @override
  String get tradeImportEmptyAtas =>
      'ATAS: ninguna fila reconocida (solo hoja Journal).';

  @override
  String get tradeImportEmptyGeneric =>
      'No se reconoció ninguna posición para esta plataforma/archivo.';

  @override
  String tradeImportNoneNew(String source, String duplicates) {
    return 'No se importaron operaciones nuevas desde $source$duplicates.';
  }

  @override
  String tradeImportSummary(int count, String source, String duplicates) {
    return '$count operación(es) importada(s) desde $source$duplicates.';
  }

  @override
  String tradeImportDuplicatesSuffix(int count) {
    return ' · $count duplicado(s) ignorado(s)';
  }

  @override
  String tradeImportDuplicatesOnlySuffix(int count) {
    return ' · $count duplicado(s)';
  }

  @override
  String tradeImportFailed(String error) {
    return 'Importación fallida: $error';
  }

  @override
  String get ajouterTradeSectionEtatMoment => 'ESTADO ACTUAL';

  @override
  String get ajouterTradeImagePickerClose => 'Cerca';

  @override
  String get ajouterTradeImagePickerTitle => 'Fuente de la imagen';

  @override
  String get ajouterTradeGallery => 'Galería';

  @override
  String get ajouterTradeCamera => 'Cámara';

  @override
  String get ajouterTradeFeedbackAlmost100 =>
      'Estás cerca del 100%: sigue aplicando cada punto.';

  @override
  String get ajouterTradeFeedbackTickEach =>
      'Marque cada punto que corresponda (selecciones múltiples).';

  @override
  String get ajouterTradeChoicesSaved => 'Opciones guardadas:';

  @override
  String ajouterTradeNonRespectedSemantic(Object label) {
    return 'No seguido: $label';
  }

  @override
  String ajouterTradeDisciplineRespectBase(int pct) {
    return 'Respeto $pct %';
  }

  @override
  String ajouterTradeDisciplineRespectNonList(Object items, Object more) {
    return '· No seguido: $items$more';
  }

  @override
  String get ajouterTradeFieldActif => 'Activo';

  @override
  String get ajouterTradeFieldEntree => 'Entrada';

  @override
  String get ajouterTradeFieldSortie => 'Salida';

  @override
  String get ajouterTradeCheckboxBreakeven => 'Punto de equilibrio';

  @override
  String get ajouterTradeCheckboxPositionOpen => 'Posición abierta';

  @override
  String get ajouterTradeCheckboxAvantNews => 'Antes de noticias';

  @override
  String get ajouterTradeCheckboxApresNews => 'Después de noticias';

  @override
  String get ajouterTradeDirectionBuyLong => 'Compra · Long';

  @override
  String get ajouterTradeDirectionSellShort => 'Venta · Short';

  @override
  String get ajouterTradeEntryExitDateHint =>
      'Consejo: establezca la fecha y hora de Entrada y Salida. En la página Rendimiento, esto vincula la duración de la posición con sus ganancias o pérdidas.';

  @override
  String get ajouterTradeQtyLots => 'Tamaño (lotes)';

  @override
  String get ajouterTradeQtyContracts => 'Tamaño (contratos)';

  @override
  String get ajouterTradeQtyUnits => 'Tamaño (unidades)';

  @override
  String get ajouterTradeQtyShares => 'Tamaño (acciones)';

  @override
  String get ajouterTradeShortcutsLots => 'Muchos atajos';

  @override
  String get ajouterTradeShortcutsContracts => 'Atajos de contrato';

  @override
  String get ajouterTradeShortcutsQty => 'Atajos de tamaño';

  @override
  String get ajouterTradeShortcutsCommonSizes => 'Atajos (tamaños comunes)';

  @override
  String get ajouterTradeLotHintMini => 'P.ej. 0,1 = mini lote típico.';

  @override
  String get ajouterTradeLotFieldHintForex => 'p.ej. 0.1';

  @override
  String get ajouterTradeLotFieldHintContracts => 'p.ej. 2';

  @override
  String get ajouterTradeLotFieldHintUnits => 'p.ej. 1';

  @override
  String get ajouterTradeLotFieldHintShares => 'p.ej. 10';

  @override
  String get ajouterTradeDisciplineSettingsTitle =>
      'Configuración de disciplina';

  @override
  String get ajouterTradeDisciplineSettingsSubtitle =>
      'Elija qué secciones están activas para este comercio.';

  @override
  String get ajouterTradeDisciplineFeelingModeTitle => 'Modo sentimiento';

  @override
  String get ajouterTradeDisciplineFeelingAllowSubtitle =>
      'Permita completar las secciones a continuación.';

  @override
  String get ajouterTradeDisciplineSectionsHeading => 'SECCIONES';

  @override
  String get ajouterTradeDisciplineStrategieTitle => 'Estrategia';

  @override
  String get ajouterTradeDisciplineStrategieSubtitle =>
      'Configuración, comentarios';

  @override
  String get ajouterTradeDisciplinePlanTitle => 'Plan de análisis';

  @override
  String get ajouterTradeDisciplineConfidencePlanTitle => 'Plan de confianza';

  @override
  String get ajouterTradeDisciplinePlanSubtitle => 'Informe, comentarios';

  @override
  String get ajouterTradeDisciplineChecklistTitle => 'Lista de verificación';

  @override
  String get ajouterTradeDisciplineChecklistSubtitle => 'Puntos a seguir';

  @override
  String get ajouterTradeDisciplineEtatTitle => 'Estado del momento';

  @override
  String get ajouterTradeDisciplineEtatSubtitle => 'Momentos y emociones';

  @override
  String get ajouterTradeDisciplineSliderStrategieRespected =>
      'Estrategia seguida';

  @override
  String get ajouterTradePositionSettingsTitle => 'Configuración de posición';

  @override
  String get ajouterTradeStrategieFeedbackBravo =>
      '¡Bien hecho! Seguiste tu estrategia completamente.';

  @override
  String get ajouterTradeStrategieFeedbackWhichMissed =>
      '¿Qué partes de tu estrategia no seguiste?';

  @override
  String get ajouterTradeStrategieGoldRules => 'REGLAS DE ORO';

  @override
  String ajouterTradeStrategieRuleN(int n) {
    return 'Regla $n';
  }

  @override
  String ajouterTradeStrategieSetupTimeframesRow(Object value) {
    return 'Plazos: $value';
  }

  @override
  String ajouterTradeStrategieSetupIndicatorsRow(Object value) {
    return 'Indicadores: $value';
  }

  @override
  String ajouterTradeStrategieSetupPatternRow(Object value) {
    return 'Patrón: $value';
  }

  @override
  String ajouterTradeStrategieSetupSignalRow(Object value) {
    return 'Señal: $value';
  }

  @override
  String get ajouterTradeStrategieRiskManagement => 'GESTIÓN DE RIESGOS';

  @override
  String get ajouterTradeStrategieHoursSessions => 'HORAS Y SESIONES';

  @override
  String get ajouterTradeStrategieSetupModels => 'CONFIGURACIÓN Y MODELOS';

  @override
  String ajouterTradeStrategieSetupModelsWithTitle(Object title) {
    return 'CONFIGURACIÓN Y MODELOS: $title';
  }

  @override
  String get ajouterTradeStrategiePickStrategyHint =>
      'Elija una estrategia de la lista anterior para mostrar los detalles de configuración (entrada, parada, objetivo, gestión comercial, etc.).';

  @override
  String get ajouterTradeStrategieRowPattern => 'Patrón';

  @override
  String get ajouterTradeStrategieRowSignal => 'Señal';

  @override
  String get ajouterTradeStrategieClosedLabel100 =>
      'Genial, se siguió la estrategia.';

  @override
  String get ajouterTradeStrategieClosedLabel95 =>
      'Seguido casi en su totalidad';

  @override
  String get ajouterTradeStrategieClosedLabelLow => 'Puntos para revisar';

  @override
  String get ajouterTradePlanPickReportAbove =>
      'Elija un informe en el campo de arriba.';

  @override
  String get ajouterTradePlanFeedbackAlmost100 =>
      'Estás cerca del 100%: sigue aplicando cada punto de tu plan de análisis.';

  @override
  String get ajouterTradePlanFeedbackBravo =>
      '¡Bien hecho! Seguiste tu plan de análisis por completo.';

  @override
  String get ajouterTradePlanFeedbackWhichMissed =>
      '¿Qué partes de su plan de análisis no siguió?';

  @override
  String get ajouterTradePlanClosedLabel100 => 'Genial, se siguió el plan.';

  @override
  String get ajouterTradePlanClosedLabelLow => 'Comentario';

  @override
  String get ajouterTradeChecklistFeedbackAlmost100 =>
      'Estás cerca del 100%: sigue aplicando cada punto de tu lista de verificación.';

  @override
  String get ajouterTradeChecklistFeedbackBravo =>
      '¡Bien hecho! Seguiste tu lista de verificación completamente.';

  @override
  String get ajouterTradeChecklistFeedbackWhichMissed =>
      '¿Qué partes de tu lista de verificación no seguiste?';

  @override
  String get ajouterTradeChecklistClosedLabel100 =>
      'Genial, se siguió la lista de verificación';

  @override
  String get ajouterTradeChecklistClosedLabelLow => 'Lista de verificación';

  @override
  String get ajouterTradeEtatFeelingPrompt => '¿Qué sentimientos surgieron?';

  @override
  String get ajouterTradeEtatFeedbackAlmost100 =>
      'Estás cerca del 100%: sigue aplicando cada punto.';

  @override
  String get ajouterTradeEtatClosedLabel100 => 'Sí, es duro. ¡Bien hecho!';

  @override
  String get ajouterTradeEtatClosedLabelLow => 'Estado del momento';

  @override
  String get ajouterTradeEtatHeaderMoment => 'TU ESTADO';

  @override
  String get ajouterTradeEtatHeaderEmotions => 'EMOCIONES';

  @override
  String get ajouterTradeScreenshotLoadError => 'No se pudo mostrar la imagen.';

  @override
  String get ajouterTradeScreenshotChangeImage => 'Cambiar imagen';

  @override
  String get ajouterTradeScreenshotTapToAdd => 'Toca para agregar una imagen';

  @override
  String get ajouterTradeScreenshotRemove => 'Eliminar';

  @override
  String get ajouterTradePlanRowBias => 'Inclinación';

  @override
  String get ajouterTradePlanRowTimeframeHtf => 'Plazo HTF';

  @override
  String get ajouterTradePlanRowPhase => 'Fase';

  @override
  String get ajouterTradePlanRowNotes => 'Notas';

  @override
  String get ajouterTradePlanRowLastPoint => 'Último punto de swing';

  @override
  String ajouterTradePlanRowExtraSupport(int n) {
    return 'Soporte adicional $n';
  }

  @override
  String ajouterTradePlanRowExtraResistance(int n) {
    return 'Resistencia adicional $n';
  }

  @override
  String get ajouterTradePlanRowOutils => 'Herramientas';

  @override
  String get ajouterTradePlanRowLiquidity => 'Liquidez';

  @override
  String get ajouterTradePlanRowFibPrice => 'precio fib';

  @override
  String get ajouterTradePlanSectionVolume => 'VOLUMEN';

  @override
  String get analyseAddField => '+ Agregar campo';

  @override
  String get analyseAddPhaseTitle => 'Agregar fase';

  @override
  String get analyseAddResist => '+ Añadir resistencia';

  @override
  String get analyseAddShort => '+ Agregar';

  @override
  String get analyseAddSupport => '+ Agregar soporte';

  @override
  String get analyseAddTimeframeTitle => 'Agregar período de tiempo';

  @override
  String get analyseAddTimeframeCustomEntry => 'Otro (texto libre)';

  @override
  String get analyseAddTimeframeSectionRestore => 'Reactivar';

  @override
  String get analyseAddTimeframeSectionIntraday => 'Intraday';

  @override
  String get analyseAddTimeframeSectionSwing => 'Swing y posición';

  @override
  String get analyseAddTrendTitle => 'Agregar tendencia';

  @override
  String get analyseReportScreenshotSectionTitle => 'CAPTURA';

  @override
  String get analyseReportScreenshotAddCapture => 'Añadir captura';

  @override
  String get analyseReportScreenshotChooseImage => 'Elegir imagen';

  @override
  String get analyseReportScreenshotSubtitleWeb => 'Archivo de imagen';

  @override
  String get analyseReportScreenshotSubtitleFilePicker =>
      'Galería o explorador de archivos';

  @override
  String get analyseReportScreenshotCamera => 'Cámara';

  @override
  String get analyseReportScreenshotHintWithCamera =>
      'Archivo, galería o cámara';

  @override
  String get analyseReportScreenshotHintNoCamera =>
      'Elegir una imagen en este dispositivo';

  @override
  String get analyseReportScreenshotErrorPlugin =>
      'La selección de imagen no está disponible en este destino. Usa «Elegir imagen» o reconstruye la app (flutter clean / run).';

  @override
  String get analyseReportScreenshotErrorGeneric =>
      'No se pudo añadir la captura.';

  @override
  String get analyseCardIndicators => 'Indicadores';

  @override
  String get analyseCardSmcLiquidity => 'SMC y liquidez';

  @override
  String get analyseCardVolumeProfile => 'Perfil de volumen';

  @override
  String get analysePageHeroTitle => 'Mi análisis';

  @override
  String get analysePageHeroSubtitle =>
      'Gestiona tus análisis y estrategias en tiempo real.';

  @override
  String get analyseSidebarConfidenceSummary => 'RESUMEN';

  @override
  String get analyseSidebarConfidenceLabel => 'confianza global';

  @override
  String get analyseSidebarReportHint =>
      'El informe se guardará en tu historial con el activo asociado.';

  @override
  String get analyseSidebarPreviewStyle => 'VISTA DE ESTILO';

  @override
  String get analyseConfidenceHigh => 'Alto';

  @override
  String get analyseConfidenceLevelTitle => 'NIVEL DE CONFIANZA';

  @override
  String get analyseConfidenceLow => 'Bajo';

  @override
  String analyseCopyLabel(String label) {
    return 'Copiar $label';
  }

  @override
  String analyseCopyNumber(int n) {
    return 'Copiar $n';
  }

  @override
  String get analyseCurrentMarketPhase => 'FASE ACTUAL DEL MERCADO';

  @override
  String get analyseCurrentTrend => 'TENDENCIA ACTUAL';

  @override
  String get analyseDeleteTemplateTitle => '¿Eliminar esta plantilla?';

  @override
  String get analyseDirectionLabel => 'DIRECCIÓN';

  @override
  String get analyseDraftLabelHint => 'Etiqueta…';

  @override
  String get analyseExtraBroken => 'Roto';

  @override
  String get analyseExtraHeld => 'Sostuvo';

  @override
  String get analyseExtraPriceHint => 'Precio';

  @override
  String get analyseFeuillePlanTitle => 'HOJA DE PLAN COMERCIAL';

  @override
  String get analyseFibLevel => 'NIVEL FIBONACCI';

  @override
  String get analyseFibShort => 'FIBONACCI';

  @override
  String get analyseFreeFields => 'CAMPOS LIBRES';

  @override
  String get analyseFvg => 'BRECHA DE VALOR RAZONABLE (FVG)';

  @override
  String get analyseHintActifExamples => 'p.ej. NASDAQ, EUR/USD…';

  @override
  String get analyseHintDetailsDots => 'Detalles…';

  @override
  String get analyseHintHtfChipExample => 'p.ej. Semanalmente';

  @override
  String get analyseHintImbalance => 'Desequilibrio…';

  @override
  String get analyseHintNotesDots => 'Notas…';

  @override
  String get analyseHintPriceDots => 'Precio…';

  @override
  String get analyseHintStops =>
      '¿Dónde están las paradas? (por ejemplo, lado comprador)';

  @override
  String get analyseHintTextDots => 'Texto…';

  @override
  String get analyseHintTfExamples => 'p.ej. MN, 3D…';

  @override
  String get analyseHintZoneHtf => 'Zona HTF…';

  @override
  String get analyseHtfTimeframe => 'PLAZO DE ANÁLISIS (HTF)';

  @override
  String get analyseImpactFeuille => 'Impacto de la hoja';

  @override
  String get analyseImpactIndicators => 'Impacto de los indicadores';

  @override
  String analyseImpactLine(int percent) {
    return 'Impacto: $percent%';
  }

  @override
  String get analyseImpactModalBlurb =>
      'Los cuatro impactos se reparten el 100% en total. Al mover este control deslizante se ajustan los demás proporcionalmente.';

  @override
  String get analyseImpactModalTitle => 'Ajustar el impacto';

  @override
  String get analyseImpactShort => 'Impacto';

  @override
  String get analyseImpactSmc => 'Impacto del SMC';

  @override
  String get analyseLastPointHint => 'Último punto…';

  @override
  String get analyseLiquidityPools => 'PISCINAS DE LIQUIDEZ';

  @override
  String get analyseMovementDetailsHint => 'Detalles del movimiento...';

  @override
  String get analyseNameFieldHint => 'Nombre del análisis…';

  @override
  String get analyseNameFieldLabel => 'Nombre del análisis';

  @override
  String get analyseNoTemplatesSaved => 'No hay plantillas guardadas';

  @override
  String get analyseNote => 'NOTA';

  @override
  String get analyseNotesIndicators => 'NOTAS (INDICADORES)';

  @override
  String get analyseNotesSmcExample => 'p.ej. Toma de liquidez ante FVG...';

  @override
  String get analyseNotesSmcLiq => 'NOTAS (SMC Y LIQUIDEZ)';

  @override
  String get analyseNotesVolumeProfile => 'NOTAS (PERFIL DE VOLUMEN)';

  @override
  String get analyseOrderBlock => 'BLOQUE DE ORDEN (OB)';

  @override
  String get analysePhase => 'FASE';

  @override
  String get analyseReportCellFvg => 'FVG';

  @override
  String get analyseReportCellLiqPools => 'LIQ. QUINIELAS';

  @override
  String get analyseReportCellOrderBlock => 'BLOQUE DE PEDIDO';

  @override
  String get analyseResistLower => 'Resistencia';

  @override
  String get analyseResistShort => 'RESISTIR.';

  @override
  String get analyseSetup => 'CONFIGURACIÓN';

  @override
  String get analyseSideBuy => 'Comprar';

  @override
  String get analyseSideSell => 'Vender';

  @override
  String get analyseSideWatch => 'Mirar';

  @override
  String get analyseSmcAdds => 'AGREGA SMC';

  @override
  String get analyseStructTagResist => 'R';

  @override
  String get analyseStructTagSupport => 'S';

  @override
  String get analyseStructure => 'ESTRUCTURA';

  @override
  String get analyseStructureSectionTitle => 'Estructura';

  @override
  String get analyseSupport => 'APOYO';

  @override
  String get analyseSupportLower => 'Apoyo';

  @override
  String analyseTemplateApplied(String name) {
    return 'Plantilla “$name” aplicada';
  }

  @override
  String get analyseTemplateNameHint => 'Nuevo nombre…';

  @override
  String get analyseTemplateRenameDialogTitle => 'Cambiar nombre de plantilla';

  @override
  String get analyseTemplateSaveDialogTitle => 'Nombre de la plantilla';

  @override
  String get analyseTemplateStyleHint => 'p.ej. Swing, especulación...';

  @override
  String get analyseTestedTwice => 'Probado x 2';

  @override
  String get analyseTimeframeLabelShort => 'PERIODO DE TIEMPO';

  @override
  String get analyseTooltipPickTemplate => 'Elija una plantilla guardada';

  @override
  String get analyseTooltipSaveTemplatePills =>
      'Guarda pastillas bajo un nombre (tu hábito)';

  @override
  String get analyseTrend => 'TENDENCIA';

  @override
  String get analyseTrendLabel => 'Tendencia';

  @override
  String get analyseVolumePoc => 'POS';

  @override
  String get analyseVolumeProfile => 'PERFIL DE VOLUMEN';

  @override
  String get analyseVolumeProfileDefaultLabel => 'Perfil de volumen';

  @override
  String get analyseVolumeVah => 'vah';

  @override
  String get analyseVolumeVal => 'VAL';

  @override
  String get analyseVolumeZoneFrom => 'De';

  @override
  String get analyseVolumeZoneLabel => 'Zona';

  @override
  String get analyseVolumeZoneTo => 'A';

  @override
  String get appBrandName => 'PAYCHEK';

  @override
  String get buttonCalculate => 'Calcular';

  @override
  String get calAmountLabel => 'Cantidad';

  @override
  String get calMonthlyObjectiveTitle => 'Objetivo mensual';

  @override
  String get calPageTitle => 'Calendario';

  @override
  String get calObjectiveLabel => 'Objetivo';

  @override
  String get calCumulativePerformanceTitle => 'Rendimiento acumulado';

  @override
  String get calBestDay => 'mejor dia';

  @override
  String get calTradingDays => 'Días de negociación';

  @override
  String get calAverageShort => 'Promedio';

  @override
  String get calPnlShort => 'PyG';

  @override
  String get calCapitalChangePct => 'Capital %';

  @override
  String get calAveragePerDay => 'Promedio / día';

  @override
  String get calObjectiveShort => 'Objetivo';

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
  String get monthJanuary => 'Enero';

  @override
  String get monthFebruary => 'Febrero';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Puede';

  @override
  String get monthJune => 'Junio';

  @override
  String get monthJuly => 'Julio';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Septiembre';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthNovember => 'Noviembre';

  @override
  String get monthDecember => 'Diciembre';

  @override
  String get monthAbbrJanuary => 'Ene';

  @override
  String get monthAbbrFebruary => 'Feb';

  @override
  String get monthAbbrMarch => 'Mar';

  @override
  String get monthAbbrApril => 'Abr';

  @override
  String get monthAbbrMay => 'Puede';

  @override
  String get monthAbbrJune => 'Jun';

  @override
  String get monthAbbrJuly => 'Jul';

  @override
  String get monthAbbrAugust => 'Ago';

  @override
  String get monthAbbrSeptember => 'Sep';

  @override
  String get monthAbbrOctober => 'Oct';

  @override
  String get monthAbbrNovember => 'Nov';

  @override
  String get monthAbbrDecember => 'Dic';

  @override
  String get calcBestBalance => 'Mejor equilibrio';

  @override
  String get calcEndBalance => 'Saldo final';

  @override
  String get calcEquityCurveTitle => 'Gráfico de curva de retorno comercial';

  @override
  String get calcLabelEntry => 'Precio de entrada';

  @override
  String get calcLabelRiskShort => 'Riesgo';

  @override
  String get calcLabelSl => 'detener la pérdida';

  @override
  String get calcLabelStartBalance => 'Saldo inicial';

  @override
  String get calcLabelTp => 'Tomar ganancias';

  @override
  String get calcLabelTradesShort => 'Vientos alisios';

  @override
  String get calcLabelWinRateShort => 'Tasa de ganancia';

  @override
  String get calcLoss => 'Pérdida';

  @override
  String get calcMaxDrawdown => 'Reducción máxima';

  @override
  String get calcProfitFactor => 'factor de beneficio';

  @override
  String get calcRatioSectionTitle => 'Relación';

  @override
  String get calcResult => 'Resultado';

  @override
  String get calcResultOfCalculation => 'Resultado del cálculo';

  @override
  String get calcRowGain => 'Ganar:';

  @override
  String get calcRowSl => 'SL:';

  @override
  String get calcRowVsCapital => 'contra el capital';

  @override
  String get calcSettingsTitle => 'Ajustes';

  @override
  String get calcTotalGainLabel => 'ganancia total';

  @override
  String get calcTradeReturnTableTitle =>
      'Devolución de resultados comerciales';

  @override
  String get calcWin => 'Ganar';

  @override
  String get calcWinsLosses => 'Victorias / Derrotas';

  @override
  String get calcErrorInvalidBalance => 'Saldo inicial no válido.';

  @override
  String get calcErrorTradesRange =>
      'El número de operaciones debe estar entre 1 y 2000.';

  @override
  String get calcErrorWinRateRange => 'El win rate debe estar entre 0 y 100.';

  @override
  String get calcErrorRiskRange => 'El riesgo (%) debe estar entre 0 y 100.';

  @override
  String get calcErrorInvalidRiskReward => 'Risk:Reward no válido.';

  @override
  String get calcErrorInvalidLot => 'Lote no válido.';

  @override
  String get calcErrorInvalidEntry => 'Precio de entrada no válido.';

  @override
  String get calcErrorInvalidSl => 'Stop loss no válido.';

  @override
  String get calcErrorInvalidTp => 'Take profit no válido.';

  @override
  String get calcErrorEntrySlIdentical =>
      'Entrada y SL no pueden ser idénticos.';

  @override
  String get calcDisclaimerEstimates =>
      'Atención: estos cálculos no son cifras contractuales. Solo sirven como referencia.';

  @override
  String get calcHeaderSubtitleEstimates =>
      'Simulaciones de rendimiento y ratio — valores indicativos.';

  @override
  String get calcMarketIndex => 'Índice';

  @override
  String get calcMarketFutures => 'Futuros';

  @override
  String get calcMarketStock => 'Acción';

  @override
  String get calcMarketCommodities => 'Materias primas';

  @override
  String get calcWorstBalance => 'Peor saldo';

  @override
  String get calculateRatio => 'Calcular proporción';

  @override
  String get cancel => 'Cancelar';

  @override
  String get capitalAmountLabel => 'Monto del capital';

  @override
  String get capitalCurrencyTitle => 'Divisa';

  @override
  String get capitalEllipsis => '…';

  @override
  String get capitalHintAmount => 'p.ej. 10 450';

  @override
  String get capitalInitialTitle => 'capital inicial';

  @override
  String get capitalLabel => 'Capital';

  @override
  String get capitalOther => 'otro';

  @override
  String get capitalTooltip => 'Capital y moneda (cuenta principal)';

  @override
  String get checklistAddSection => 'Agregar una sección';

  @override
  String get checklistDefaultNewSection => 'NUEVA SECCIÓN';

  @override
  String get checklistDeleteSectionBody =>
      'Esta acción es permanente para esta sección.';

  @override
  String get checklistDeleteSectionTitle => '¿Eliminar sección?';

  @override
  String get checklistEditSectionHint => 'Título';

  @override
  String get checklistIntroBody =>
      'Antes de tomar una posición, asegúrese de validar todos los criterios de su plan comercial.';

  @override
  String get checklistDailyCalendarTitle => 'CHECKLIST POR DÍA';

  @override
  String get checklistDailyUncheckedTitle => 'NO MARCADOS';

  @override
  String get checklistDailyUncheckedNoActivity => 'Sin actividad este día.';

  @override
  String get checklistDailyUncheckedNoDue =>
      'Ningún criterio previsto este día.';

  @override
  String get checklistDailyUncheckedAllDone =>
      'Todos los criterios del día están marcados.';

  @override
  String get checklistDailyUncheckedNoHistory =>
      'No hay detalles de checklist guardados para este día. El seguimiento de criterios no marcados está disponible desde hoy.';

  @override
  String get checklistItemNews1 =>
      'Calendario económico revisado (FED, CPI, NFP, PIB…).';

  @override
  String get checklistItemNews2 => 'FOMC / FED: sin operar durante el anuncio.';

  @override
  String get checklistItemNews3 => 'CPI (inflación): hora e impacto previstos.';

  @override
  String get checklistItemNews4 =>
      'NFP (empleo EE. UU.): ventana de riesgo identificada.';

  @override
  String get checklistItemAnalyse1 =>
      'La tendencia de fondo (HTF) se alinea con mi idea.';

  @override
  String get checklistItemAnalyse2 =>
      'El precio está en una zona clave (Soporte/Resistencia, Bloqueo de Orden).';

  @override
  String get checklistItemAnalyse3 =>
      'Tengo una confirmación de entrada clara (Patrón, Divergencia).';

  @override
  String get checklistItemHint => 'Introducir criterio';

  @override
  String get checklistItemPsy1 =>
      'Opero con una mentalidad neutral (sin operaciones de venganza).';

  @override
  String get checklistItemPsy2 =>
      'Acepto la pérdida potencial antes de entrar.';

  @override
  String get checklistItemPsy3 =>
      'Sigo con mi plan incluso después de una serie de pérdidas.';

  @override
  String get checklistItemRisque1 =>
      'Mi stop loss se establece técnicamente (no al azar).';

  @override
  String get checklistItemRisque2 => 'El riesgo no supera el 1% de mi capital.';

  @override
  String get checklistItemRisque3 =>
      'La relación riesgo/recompensa es al menos 1:2.';

  @override
  String get checklistMenuEdit => 'Editar';

  @override
  String get checklistPageTitle => 'Lista de verificación';

  @override
  String get checklistProgressCl => 'CL';

  @override
  String get checklistSectionNews => 'NEWS · CALENDARIO ECONÓMICO';

  @override
  String get checklistSectionAnalyse => 'ANÁLISIS TÉCNICO';

  @override
  String get checklistSectionPsy => 'PSICOLOGÍA';

  @override
  String get checklistSectionRisque => 'GESTIÓN DE RIESGOS';

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
  String get clearAll => 'Borrar todo';

  @override
  String get confirm => 'Confirmar';

  @override
  String get currencyNameHint => 'p.ej. CHF, XOF';

  @override
  String get currencyNameLabel => 'Nombre de la moneda';

  @override
  String get customCurrencyTitle => 'Otra moneda';

  @override
  String get dashboardAiAnalyze => 'Analizar';

  @override
  String get dashboardAiCoachBody =>
      'Toque «Analizar» para que la IA revise sus estadísticas semanales (tasa de ganancias, horas, factores) y genere consejos psicológicos personalizados.';

  @override
  String get dashboardAiCoachTitle => 'ENTRENADOR DE AI DE PAGO';

  @override
  String get dashboardAnalyseShortcutTitle => 'Mi análisis';

  @override
  String get dashboardBestTradeLabel => 'Mejor comercio';

  @override
  String get dashboardCapitalBalanceHeader => 'CAPITAL / SALDO';

  @override
  String get dashboardCapitalEvolutionTitle => 'EVOLUCIÓN DEL CAPITAL';

  @override
  String get dashboardChecklistHeading => 'LISTA DE VERIFICACIÓN';

  @override
  String get dashboardChecklistSeeRest => 'Más >';

  @override
  String get dashboardChecklistAllDoneBravo => 'Buen trading.';

  @override
  String get dashboardMyStateSection => 'mi estado';

  @override
  String get dashboardOpenStrategyTooltip => 'Abrir mi estrategia';

  @override
  String dashboardPerfHourWinRate(int percent) {
    return '$percent% WR';
  }

  @override
  String get dashboardPerfHoursRow1 => '09:00 - 11:30 (Inicio)';

  @override
  String get dashboardPerfHoursRow2 => '14:30 - 16:30 (Abierto de EE. UU.)';

  @override
  String get dashboardPerfHoursRow3 => '19:00+ (tarde)';

  @override
  String get dashboardPerfHoursTitle => 'HORAS DE FUNCIONAMIENTO';

  @override
  String get dashboardRingState => 'ESTADO';

  @override
  String get dashboardRingWin => 'GANAR';

  @override
  String get dashboardSuccessFactorSample => 'Deporte antes de la sesión';

  @override
  String get dashboardSuccessFactorsSubtitle =>
      'Realice un seguimiento de cómo sus hábitos afectan su tasa de ganancias.';

  @override
  String get dashboardSuccessFactorsTitle => 'FACTORES DE ÉXITO';

  @override
  String get dashboardTfAll => 'TODO';

  @override
  String get dashboardTfDay => '1D';

  @override
  String get dashboardTfMonth => '1M';

  @override
  String get dashboardTfWeek => '1W';

  @override
  String dashboardTradeCount(int count) {
    return '$count operaciones';
  }

  @override
  String get dashboardTradeOne => '1 comercio';

  @override
  String dashboardEvolutionTradesThisPeriod(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operaciones este período',
      one: '1 operación este período',
      zero: '0 operaciones este período',
    );
    return '$_temp0';
  }

  @override
  String get dashboardEvolutionSparklineHoverOrigin => 'Inicio del acumulado';

  @override
  String get dashboardEvolutionSparklineHoverNoTrade =>
      'Sin operaciones en este punto';

  @override
  String dashboardEvolutionSparklineHoverMore(int count) {
    return '+$count más';
  }

  @override
  String get dashboardEvolutionSparklineTapHint => 'Toca para abrir';

  @override
  String get dashboardWeekResultPrefix => 'Resultado:';

  @override
  String get dashboardWeekThisWeek => 'ESTA SEMANA';

  @override
  String get dashboardWeekdayShortFri => 'VIE';

  @override
  String get dashboardWeekdayShortMon => 'LUN';

  @override
  String get dashboardWeekdayShortSat => 'SE SENTÓ';

  @override
  String get dashboardWeekdayShortSun => 'SOL';

  @override
  String get dashboardWeekdayShortThu => 'JUE';

  @override
  String get dashboardWeekdayShortTue => 'MAR';

  @override
  String get dashboardWeekdayShortWed => 'CASARSE';

  @override
  String get dashboardWorstLossLabel => 'peor perdida';

  @override
  String get delete => 'Borrar';

  @override
  String deletePortfolioTitle(String name) {
    return '¿Eliminar “$name”?';
  }

  @override
  String get deleteTooltip => 'Borrar';

  @override
  String get editPortfolioTooltip => 'Editar nombre, capital, moneda';

  @override
  String get errorAmount => 'Ingrese una cantidad válida (≥ 0).';

  @override
  String get errorInvalidAmount => 'Cantidad o moneda no válida.';

  @override
  String get errorNameOrSymbol => 'Introduzca al menos un nombre o un símbolo.';

  @override
  String get exportPdfFailed => 'No se pudo exportar PDF.';

  @override
  String exportPdfFailedWithError(String error) {
    return 'No se pudo exportar PDF: $error';
  }

  @override
  String get exportPdfUnavailable =>
      'Exportación de PDF cancelada o no disponible.';

  @override
  String get homePerformance => 'Actuación';

  @override
  String get webHomeHeroSubtitle =>
      'Bienvenido, aquí está tu rendimiento semanal';

  @override
  String webHomeHeroWelcome(Object fullName) {
    return 'Bienvenido, $fullName';
  }

  @override
  String get webHomeLiveTerminal => 'Terminal en vivo';

  @override
  String get webHomeWelcomeBack => 'Bienvenido de nuevo,';

  @override
  String get webHomeUpgradeUnlockSubtitle =>
      'Desbloquea datos institucionales en tiempo real';

  @override
  String get webRailMenuHeading => 'Menú';

  @override
  String get labelActif => 'Activo';

  @override
  String get labelGain => 'PyG';

  @override
  String get labelLot => 'LOTE';

  @override
  String get labelMarket => 'MERCADO';

  @override
  String get labelPrice => 'PRECIO';

  @override
  String get labelRiskPct => 'RIESGO %';

  @override
  String get labelSuggestedSize => 'TAMAÑO SUGERIDO';

  @override
  String get langChineseTraditional => '中文 (繁體)';

  @override
  String get langEnglish => 'Inglés';

  @override
  String get langFrench => 'francés';

  @override
  String get langGerman => 'alemán';

  @override
  String get langItalian => 'italiano';

  @override
  String get langKorean => '한국어';

  @override
  String get langPortuguese => 'portugués';

  @override
  String get langSpanish => 'Español';

  @override
  String get languageDialogSubtitle => 'Idioma de la interfaz';

  @override
  String get languageDialogTitle => 'Elige idioma';

  @override
  String get languageSection => 'Idioma';

  @override
  String get onboardingLanguageContinue => 'Continuar';

  @override
  String get mentalBad => 'Malo';

  @override
  String get mentalConfidence => 'Confianza';

  @override
  String get mentalEmotionFieldLabel =>
      'Nombre de la emoción (por ejemplo, tranquilo, temeroso)';

  @override
  String get mentalEmotional => 'Emocional';

  @override
  String get mentalEnergy => 'Energía';

  @override
  String get mentalExcited => 'Entusiasmado';

  @override
  String get mentalFocus => 'Enfocar';

  @override
  String get mentalFrustrated => 'Frustrado';

  @override
  String get mentalHappy => 'Feliz';

  @override
  String get mentalHintEmotion => 'p.ej. tranquilo, temeroso';

  @override
  String get mentalHintMetric => 'p.ej. Paciencia, Estrés';

  @override
  String get mentalHintRoutine => 'p.ej. Deporte, Lectura';

  @override
  String get mentalMarketStudy => 'estudio de mercado';

  @override
  String get mentalMeditation => 'Meditación (10 min)';

  @override
  String get mentalMetricFieldLabel =>
      'Nombre de la métrica (por ejemplo, paciencia, estrés)';

  @override
  String get mentalNegative => 'Negativo (-)';

  @override
  String get mentalNeutral => 'Neutral';

  @override
  String get mentalNewEmotion => 'Nueva emoción';

  @override
  String get mentalNewMetric => 'Nueva métrica';

  @override
  String get mentalNewRoutine => 'nueva rutina';

  @override
  String get mentalPeakForm => 'Forma pico';

  @override
  String get mentalPositive => 'Positivo (+)';

  @override
  String get mentalRestTitle => 'DESCANSAR';

  @override
  String get mentalRiskAppetite => 'Miedo';

  @override
  String get mentalRoutineFieldLabel =>
      'Nombre de la rutina (por ejemplo, deporte, lectura)';

  @override
  String get mentalDayDetailTitle => 'CRITERIOS DEL DÍA';

  @override
  String get mentalDayDetailNoData =>
      'Sin datos para este día. Actualiza tu estado mental para guardarlos.';

  @override
  String get mentalDayDetailGlobalScore => 'PUNTUACIÓN GLOBAL';

  @override
  String get mentalGlobalScoreCalendarTitle => 'PUNTUACIÓN GLOBAL POR DÍA';

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
  String get mentalSleepEnough => 'Dormí lo suficiente';

  @override
  String mentalSleepImpact(int percent) {
    return 'Impacto: $percent%';
  }

  @override
  String get mentalSport => 'Deporte / trotar';

  @override
  String get mentalTired => 'Cansado';

  @override
  String get mentalWeightGlobalImpact => 'Impacto global';

  @override
  String get mentalWeightModalBlurb =>
      'Ajuste la importancia de este criterio. Utiliza el multiplicador o establece el porcentaje que quieras directamente.';

  @override
  String get mentalWeightModalTitle => 'Ajustar el impacto';

  @override
  String get mentalWeightNatureLabel => 'Naturaleza del impacto';

  @override
  String get mentalWeightPolarityHelpNegative =>
      'Un valor alto para este criterio DISMINUIRÁ su puntuación global.';

  @override
  String get mentalWeightPolarityHelpPositive =>
      'Un valor alto para este criterio AUMENTARÁ su puntuación global.';

  @override
  String get mentalPageTitle => 'estado mental';

  @override
  String get mentalPageIntro =>
      'Califica tu estado mental. Personalice el impacto (peso) de cada criterio para que coincida con su perfil.';

  @override
  String get mentalGaugeStateLabel => 'ESTADO';

  @override
  String mentalGaugeBasedOnIndicators(int count) {
    return 'Según $count indicadores';
  }

  @override
  String get mentalGaugeStatusStable => 'Equilibrio sólido';

  @override
  String get mentalGaugeStatusFragile => 'Requiere atención';

  @override
  String get mentalSectionRoutinesHeading => 'MIS RUTINAS';

  @override
  String get mentalSectionMomentHeading => 'ESTADO DEL MOMENTO';

  @override
  String get mentalSectionEmotionHeading => 'EMOCIONES';

  @override
  String modelSavedSnackbar(String name) {
    return 'Plantilla “$name” guardada';
  }

  @override
  String get navAdd => 'Agregar';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navMore => 'Más';

  @override
  String get navTrade => 'Comercio';

  @override
  String get ok => 'DE ACUERDO';

  @override
  String get perf0Sub =>
      'Impacto del estrés y la fatiga en la tasa de victorias';

  @override
  String get perf0Title => 'Psicología: Emociones y sueño';

  @override
  String get perf1Sub => 'Análisis de rentabilidad (lun-dom)';

  @override
  String get perf1Title => 'Días laborables';

  @override
  String get perf2Sub => 'Encuentra tus horas más rentables';

  @override
  String get perf2Title => 'Horas de sesión';

  @override
  String get perf3Sub => 'Tasa de éxito de este patrón gráfico';

  @override
  String get perf3Title => 'Patrón: Doble arriba/abajo';

  @override
  String get perf4Sub => 'Análisis de reversión importante';

  @override
  String get perf4Title => 'Patrón: cabeza y hombros';

  @override
  String get perf5Sub => 'Validación de señal de sobrecompra/sobreventa';

  @override
  String get perf5Title => 'Indicador: divergencia RSI';

  @override
  String get perf6Sub => 'Efectividad cruzada de media móvil';

  @override
  String get perf6Title => 'Indicador: cruce MACD';

  @override
  String get perf7Sub => 'Rebota en los niveles 0,618 y 0,5';

  @override
  String get perf7Title => 'Indicador: retroceso de Fibonacci';

  @override
  String get perf8Sub => 'Bloques de órdenes y análisis de liquidez.';

  @override
  String get perf8Title => 'Estrategia: Concepto de dinero inteligente (SMC)';

  @override
  String get perf9Sub =>
      'Impacto del riesgo financiero en la tasa de ganancias';

  @override
  String get perf9Title => 'Volumen y tamaño del lote';

  @override
  String get perfAddWidgetButton => 'Agregar widget';

  @override
  String get perfChartBar => 'gráfico de barras';

  @override
  String get perfChartHBar => 'barras horizontales';

  @override
  String get perfChartHintBar =>
      'Ideal para comparar (por ejemplo, entre semana)';

  @override
  String get perfChartHintHBar => 'Formato de lista, simple y limpio.';

  @override
  String get perfChartHintLine =>
      'Para ver una tendencia a lo largo del tiempo';

  @override
  String get perfChartHintPie => 'Para un porcentaje global';

  @override
  String get perfChartLine => 'gráfico de líneas';

  @override
  String get perfChartPie => 'Círculo / calibre';

  @override
  String get perfCustomizeIntro => 'Personaliza tu página de Rendimiento.';

  @override
  String get perfDataFootnoteDuration =>
      'Datos: desglose por duración de la posición (CSV).';

  @override
  String get perfDataFootnoteVolume =>
      'Proxy de volumen: segmentos por |beneficio| (CSV).';

  @override
  String get perfEmptyChart =>
      'Importe o cargue operaciones (CSV) para mostrar el gráfico.';

  @override
  String get perfLineChartCaption =>
      'Línea: beneficio acumulado (orden cronológico, CSV).';

  @override
  String get perfNewWidgetTitle => 'Nuevo widget';

  @override
  String get perfNoResults => 'No se encontraron opciones.';

  @override
  String get perfPieChartCaption =>
      'Rebanadas = volumen comercial por categoría; % en disco = participación del total.';

  @override
  String get perfRemoveWidgetTooltip => 'Quitar widget';

  @override
  String get perfSearchHint => 'Búsqueda (por ejemplo, patrón, psicología…)';

  @override
  String get perfStep1Title => '1. ¿Qué quieres analizar?';

  @override
  String get perfStep2Title => '2. Tipo de gráfico';

  @override
  String get plusAdd => 'Agregar';

  @override
  String get plusCalculator => 'Calculadora';

  @override
  String get plusCalendar => 'Calendario';

  @override
  String get plusChecklist => 'Lista de verificación';

  @override
  String get plusDashboard => 'Panel';

  @override
  String get plusMentalState => 'estado mental';

  @override
  String get plusMyAnalysis => 'mi análisis';

  @override
  String get plusMyStrategy => 'mi estrategia';

  @override
  String get plusPerformance => 'Actuación';

  @override
  String get plusSettings => 'Ajustes';

  @override
  String get plusTrade => 'Comercio';

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
      'Introduzca un nombre de cartera (por ejemplo, corredor).';

  @override
  String get portfoliosLabel => 'Portafolios';

  @override
  String get q1Slogan => 'Elige tu enfoque';

  @override
  String get q1Title => '¿Qué tipo de comerciante eres?';

  @override
  String get q1o1s => 'Posiciones desde segundos hasta unos minutos.';

  @override
  String get q1o1t => 'especulación';

  @override
  String get q1o2s =>
      'Todas las posiciones se cierran antes de que finalice la sesión.';

  @override
  String get q1o2t => 'negociación intradía';

  @override
  String get q1o3s => 'Cargos desempeñados entre 1 y 3 días';

  @override
  String get q1o3t => 'intradiario';

  @override
  String get q1o4s => 'Cargos ocupados durante varios días o semanas.';

  @override
  String get q1o4t => 'Balancearse';

  @override
  String get q2Slogan => '¿Dónde estás en tu viaje?';

  @override
  String get q2Title => 'Perfil de experiencia';

  @override
  String get q2o1s => 'no estas solo';

  @override
  String get q2o1s2 =>
      'Para traders que están empezando y todavía buscan su método';

  @override
  String get q2o1t => 'no tengo una estrategia';

  @override
  String get q2o2s => 'Luz al final del túnel';

  @override
  String get q2o2s2 => 'Para aquellos con lo básico que quieren coherencia.';

  @override
  String get q2o2t => 'tengo mi estrategia';

  @override
  String get q2o3s => 'La parte más difícil está detrás de ti.';

  @override
  String get q2o3s2 =>
      'Para traders experimentados que dominan sus estadísticas';

  @override
  String get q2o3t => 'Intérprete';

  @override
  String get q3Slogan => 'Elige tu principal prioridad';

  @override
  String get q3Title => '¿Qué quieres mejorar?';

  @override
  String get q3o1s =>
      'Dejar de ganar un día para perderlo todo al día siguiente.';

  @override
  String get q3o1s2 =>
      'Para estabilizar su curva de capital y evitar el ascensor emocional.';

  @override
  String get q3o1t => 'FUERA DE LA MONTAÑA RUSA';

  @override
  String get q3o2s => 'Mejore la tasa de ganancias y la precisión de entrada.';

  @override
  String get q3o2s2 =>
      'Para aquellos que quieren ganar más a menudo eligiendo mejores operaciones.';

  @override
  String get q3o2t => 'CONVIÉRTETE EN UN FRANCOTIRADOR';

  @override
  String get q3o3s =>
      'Domina la disciplina y deja de tomar decisiones emocionales.';

  @override
  String get q3o3s2 =>
      'Para eliminar el comercio impulsivo y seguir su plan al 100%.';

  @override
  String get q3o3t => 'MANTENTE FRÍO';

  @override
  String get q3o4s =>
      'Comprenda qué patrones de gráficos realmente funcionan para usted.';

  @override
  String get q3o4s2 =>
      'Para detectar tus propios patrones ganadores y convertirte en un especialista.';

  @override
  String get q3o4t => 'ENCUENTRA TU FIRMA';

  @override
  String get q4Slogan => 'Identifica lo que más te bloquea';

  @override
  String get q4Title => '¿Cuál es tu mayor desafío?';

  @override
  String get q4o1s => 'Miedo a perderse algo.';

  @override
  String get q4o1s2 => '¡Rápido, perderé la oportunidad de obtener ganancias!';

  @override
  String get q4o1t => 'FOMO';

  @override
  String get q4o2s => 'Tu corazón reemplazó a tu cerebro.';

  @override
  String get q4o2s2 => 'De ninguna manera, ¡DEBO recuperar mi dinero!';

  @override
  String get q4o2t => 'INCLINACIÓN';

  @override
  String get q4o3s => 'No hay una estrategia o un plan claro.';

  @override
  String get q4o3s2 => 'Realmente no lo sé, pero se siente bien, intentémoslo.';

  @override
  String get q4o3t => 'COMERCIAR A CIEGOS';

  @override
  String get q4o4s => 'Inquietud constante.';

  @override
  String get q4o4s2 => 'Si no hago clic, siento que no estoy trabajando.';

  @override
  String get q4o4t => 'SOBRECOMERCIO';

  @override
  String get q4o5s => 'Pensando que eres invencible.';

  @override
  String get q4o5s2 =>
      'Soy demasiado bueno: ¡dinero fácil! Doblaré la apuesta.';

  @override
  String get q4o5t => 'EXCESO DE SEGURIDAD';

  @override
  String get q4o6s => 'Miedo a todo.';

  @override
  String get q4o6s2 => 'No estoy seguro, tengo miedo de volver a perder.';

  @override
  String get q4o6t => 'PARÁLISIS';

  @override
  String get q4o7s => 'Jugar a la ruleta rusa.';

  @override
  String get q4o7s2 => 'Estoy poniendo todo en este negocio: vida o muerte.';

  @override
  String get q4o7t => 'SIN GESTIÓN DE DINERO';

  @override
  String get reglagePortfolioSheetSubtitle => 'Capital de cuenta y moneda';

  @override
  String get reglagePortfolioSheetTitle => 'Capital y carteras';

  @override
  String get resultDontWorry => 'No te preocupes';

  @override
  String get resultHeaderSub =>
      'Este no es su perfil, es sólo un cálculo; nada es real todavía. Todo empieza ahora.';

  @override
  String get resultLabelGlobal => 'Global';

  @override
  String get resultLabelProfil => 'Perfil';

  @override
  String get resultLabelPsychology => 'Psicología';

  @override
  String get resultLabelStrategy => 'Estrategia';

  @override
  String resultStatBullet1(int percent) {
    return 'El $percent% de los traders en este nivel se estancan o pierden debido a la falta de rigor matemático.';
  }

  @override
  String resultStatBullet2(int percent) {
    return 'El $percent% de los comerciantes se encuentran en la misma situación.';
  }

  @override
  String get resultStatBullet3 =>
      'Un operador con una psicología sólida opera mejor que uno que conoce 100 estrategias.';

  @override
  String get save => 'Ahorrar';

  @override
  String get screenshot => 'CAPTURA DE PANTALLA';

  @override
  String get accountPageTitle => 'Cuenta';

  @override
  String get mobileReconnectAfterLogoutTitle => 'Sesión cerrada';

  @override
  String get mobileReconnectAfterLogoutBody =>
      'Vuelve a iniciar sesión para recuperar tu perfil en la nube y tu suscripción. También puedes seguir usando la app en este dispositivo sin cuenta.';

  @override
  String get mobileReconnectContinueWithoutAccount =>
      'Continuar sin iniciar sesión';

  @override
  String get profileViewDetailsSection => 'Datos del perfil';

  @override
  String get profileAccountStatusTitle => 'Estado de la cuenta';

  @override
  String get profileAccountStatusPro => 'Pro';

  @override
  String get profileAccountStatusLite => 'Lite';

  @override
  String get profileTrialBadge => 'PRUEBA';

  @override
  String profileTrialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count días de prueba',
      one: 'Queda 1 día de prueba',
    );
    return '$_temp0';
  }

  @override
  String profileTrialEndsOn(String date) {
    return 'La prueba termina el $date';
  }

  @override
  String profileTrialEndedOn(String date) {
    return 'La prueba finalizó el $date';
  }

  @override
  String profileProPeriodEndsOn(String date) {
    return 'Renovación el $date';
  }

  @override
  String get profileSubscribeButton => 'Pasar a Pro (desde 8,99 \$ / mes)';

  @override
  String get profileManageSubscriptionButton => 'Gestionar suscripción';

  @override
  String get profileUpgradeLabel => 'Upgrade';

  @override
  String get profileEditSavedSnack => 'Perfil actualizado';

  @override
  String get profileEditIncompleteFieldsSnack =>
      'Completa nombre, apellidos y correo';

  @override
  String get profileEditInvalidEmailSnack =>
      'Introduce un correo electrónico válido';

  @override
  String get accountAuthSectionTitle => 'Conexión';

  @override
  String get accountContinueWith => 'Continuar con:';

  @override
  String get accountTabLogin => 'Conexión';

  @override
  String get accountTabSignup => 'Registro';

  @override
  String get accountFieldEmail => 'Correo electrónico';

  @override
  String get accountFieldPassword => 'Contraseña';

  @override
  String get accountFieldConfirmPassword => 'Confirmar contraseña';

  @override
  String get accountFieldBirthDate => 'Fecha de nacimiento';

  @override
  String get accountFieldFirstName => 'Nombre';

  @override
  String get accountFieldLastName => 'Apellidos';

  @override
  String get accountLoginButton => 'Iniciar sesión';

  @override
  String get accountSignupButton => 'Crear cuenta';

  @override
  String get authTerminalTagline => 'Domina la mente, domina el trade';

  @override
  String get authTerminalCtaLogin => 'Iniciar terminal';

  @override
  String get authTerminalCtaSignup => 'Crear identidad';

  @override
  String get webLandingLoginSubtitle => 'Bienvenido de nuevo a Paychek.';

  @override
  String get webLandingSignupSubtitle => 'Únete a la élite de los traders.';

  @override
  String get webLandingLoginCta => 'INICIAR SESIÓN';

  @override
  String get webLandingSignupCta => 'PROBAR GRATIS';

  @override
  String get webLandingNoAccountLabel => '¿NO TIENES CUENTA?';

  @override
  String get webLandingRegisterLink => 'REGISTRARSE';

  @override
  String get webLandingAlreadyMemberLabel => '¿YA ERES MIEMBRO?';

  @override
  String get webLandingLoginLink => 'INICIAR SESIÓN';

  @override
  String get authTerminalEncryptedPrefix => 'Nodo cifrado:';

  @override
  String get authTerminalEncryptedStatus => 'Activo';

  @override
  String get authTerminalHintEmail => 'nombre@terminal.com';

  @override
  String get authTerminalHintPassword => '••••••••';

  @override
  String get accountLoginSnackEmailMissing => 'Conexión: ingresa el correo';

  @override
  String get accountLoginSnackEmailReady => 'Conexión: correo ingresado';

  @override
  String get accountSignupSnackEmailMissing => 'Registro: ingresa el correo';

  @override
  String get accountSignupSnackFirstNameMissing =>
      'Registro: ingresa el nombre';

  @override
  String get accountSignupSnackLastNameMissing =>
      'Registro: ingresa los apellidos';

  @override
  String get accountSignupSnackBirthDateMissing =>
      'Registro: selecciona la fecha de nacimiento';

  @override
  String get accountSignupSnackReady => 'Registro: formulario listo';

  @override
  String get accountSignupSnackPasswordMissing =>
      'Registro: ingresa la contraseña';

  @override
  String get accountSignupSnackPasswordMismatch =>
      'Registro: las contraseñas no coinciden';

  @override
  String get accountSignupSnackPasswordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get accountLoginSnackPasswordMissing =>
      'Iniciar sesión: ingresa la contraseña';

  @override
  String get accountForgotPasswordLink => '¿Olvidaste la contraseña?';

  @override
  String get accountForgotPasswordSnackEmailMissing =>
      'Introduce tu correo arriba para recibir el enlace.';

  @override
  String get accountForgotPasswordSnackSent =>
      'Si existe una cuenta con este correo, recibirás un enlace para establecer una nueva contraseña.';

  @override
  String get accountForgotPasswordSnackTooManyRequests =>
      'Demasiadas solicitudes. Vuelve a intentarlo en unos minutos.';

  @override
  String get accountPasswordResetDialogTitle => 'Restablecer contraseña';

  @override
  String get accountPasswordResetDialogSubtitle =>
      'Introduce el correo de tu cuenta Paychek. Te enviaremos un enlace para crear una nueva contraseña.';

  @override
  String get accountPasswordResetCta => 'ENVIAR ENLACE';

  @override
  String get accountPasswordResetBackToLogin => 'VOLVER AL INICIO DE SESIÓN';

  @override
  String get accountPasswordResetSnackEmailMissing =>
      'Introduce tu correo electrónico.';

  @override
  String get accountPasswordResetSentDialogTitle => 'Revisa tu correo';

  @override
  String get accountPasswordResetSentDialogMessage =>
      'Si existe una cuenta con esta dirección, recibirás un correo con un enlace para crear una nueva contraseña. Revisa también la carpeta de spam.';

  @override
  String get accountPasswordResetSentDialogCta => 'ENTENDIDO';

  @override
  String get accountAuthSignupSuccess => 'Cuenta creada';

  @override
  String get accountAuthLoginSuccess => 'Sesión iniciada';

  @override
  String get accountAuthErrorWeakPassword => 'La contraseña es demasiado débil';

  @override
  String get accountAuthErrorEmailInUse => 'Este correo ya está registrado';

  @override
  String get accountAuthErrorInvalidEmail => 'Correo no válido';

  @override
  String get accountAuthErrorWrongCredentials =>
      'Correo o contraseña incorrectos';

  @override
  String get accountAuthErrorNetwork => 'Error de red. Inténtalo de nuevo.';

  @override
  String get accountAuthErrorGeneric => 'Algo salió mal';

  @override
  String get accountAuthErrorRestartOrReload =>
      'Se perdió la conexión con la autenticación. Cierra la app por completo y vuelve a ejecutarla (en la Web, evita hot reload).';

  @override
  String get accountAuthErrorDifferentSignInMethod =>
      'Este correo ya está registrado con otro método de acceso.';

  @override
  String accountAuthErrorWithFirebaseCode(String code) {
    return 'Algo salió mal ($code).';
  }

  @override
  String get accountAuthErrorUnknownFirebaseAuth =>
      'No se pudo iniciar sesión (desconocido). Comprueba la conexión, inténtalo de nuevo o abre Paychek en Chrome. En Firebase Console → Authentication, activa Correo/contraseña y los proveedores que uses.';

  @override
  String accountAuthErrorSignInServerMessage(String message) {
    return '$message';
  }

  @override
  String get accountAuthWindowsSignInNotice =>
      'En la app de escritorio para Windows, el inicio de sesión con Firebase suele fallar (limitación conocida de Flutter / Firebase). Usa la app móvil Paychek o entra desde el navegador.';

  @override
  String get accountAuthWindowsOpenWebsite =>
      'Abrir paychek.pro en el navegador';

  @override
  String get accountSocialAppleAndroidUseGoogle =>
      'Iniciar sesión con Apple no está configurado en Android en esta versión. Usa Google o el correo, o entra desde la web.';

  @override
  String get accountSocialAppleUnavailableDesktop =>
      'Iniciar sesión con Apple no está disponible en la app de escritorio Windows/Linux. Usa la web (Chrome), iPhone, iPad o Mac.';

  @override
  String get accountSocialGoogleUnavailableDesktop =>
      'Inicio de sesión con Google no disponible en Windows/Linux. Usa Chrome, Android o iOS.';

  @override
  String get accountSocialFacebookUnavailableDesktop =>
      'El inicio de sesión con Facebook no está disponible en la app de escritorio Windows/Linux. Usa la web (Chrome), Android, iOS o macOS.';

  @override
  String get accountSocialGoogleWebClientMissing =>
      'Para Google en móvil o tableta: configura el ID de cliente OAuth Web en lib/reglage/social_auth_config.dart. En Android, añade la huella SHA-1 de la app en Firebase (Ajustes del proyecto → tu app Android).';

  @override
  String get paywallTitle => 'Tu período de prueba ha terminado';

  @override
  String get paywallHeadlineBefore => 'Tu prueba gratuita ';

  @override
  String get paywallHeadlineAccent => 'ha terminado';

  @override
  String get paywallUpgradeSubtitle =>
      'Pásate a Pro para desbloquear todo tu potencial de trading y mantener tu ventaja.';

  @override
  String paywallEndedOn(String date) {
    return 'Prueba finalizada el $date.';
  }

  @override
  String get paywallCompareCurrentPlan => 'PLAN ACTUAL';

  @override
  String get paywallCompareRecommended => 'RECOMENDADO';

  @override
  String get paywallPlanLiteName => 'Lite';

  @override
  String get paywallPlanProName => 'Pro';

  @override
  String get paywallLiteFeature1 => '30 trades / mes';

  @override
  String get paywallLiteFeature2 => 'Solo entrada manual';

  @override
  String get paywallLiteFeature3 => 'Calendario estándar';

  @override
  String get paywallProFeature1 => 'Ilimitado';

  @override
  String get paywallProFeature2 => 'Importación CSV y entrada manual';

  @override
  String get paywallProFeature3 => 'Calendario Pro';

  @override
  String get paywallProFeature4 => 'Checklist';

  @override
  String get paywallProFeature5 => 'Generador de análisis';

  @override
  String get paywallProFeature6 => 'Página Estrategia';

  @override
  String get paywallProFeature7 => 'Estadísticas de rendimiento';

  @override
  String get paywallProFeature8 => 'Estado mental';

  @override
  String get paywallProFeature9 => 'Exportación PDF';

  @override
  String get paywallMobilePlanAnnualTitle => '1 año (12 meses)';

  @override
  String get paywallMobilePlanQuarterlyTitle => '3 meses';

  @override
  String get paywallMobilePlanMonthlyTitle => '1 mes';

  @override
  String paywallMobilePlanPerMonthLine(String price) {
    return 'Unos $price \$ US / mes';
  }

  @override
  String get paywallMobilePlanPerMonthPrefix => 'Unos ';

  @override
  String get paywallMobilePlanPerMonthPriceSuffix => ' \$ US';

  @override
  String get paywallMobilePlanPerMonthEnd => ' / mes';

  @override
  String paywallMobilePlanTotalLine(String total) {
    return '$total \$';
  }

  @override
  String get paywallMobilePlanAnnualBilling => 'Facturado al año';

  @override
  String get paywallMobilePlanQuarterlyBilling => 'Cada 3 meses';

  @override
  String get paywallMobilePlanMonthlyBilling => 'Facturado al mes';

  @override
  String get paywallMobilePlanMonthlyCommitment => 'Compromiso mensual';

  @override
  String get paywallMobilePlanSavings44 => 'Ahorra un 44 %';

  @override
  String get paywallMobilePlanPopular => 'Popular';

  @override
  String get paywallMobileCompareFeatureCol => 'Función';

  @override
  String get paywallMobileRowTrades => 'Trades / mes';

  @override
  String get paywallMobileRowEntry => 'Entrada de datos';

  @override
  String get paywallMobileRowCalendar => 'Calendario';

  @override
  String get paywallMobileRowChecklist => 'Checklist';

  @override
  String get paywallMobileRowAnalysis => 'Generador de análisis';

  @override
  String get paywallMobileRowStrategy => 'Página Estrategia';

  @override
  String get paywallMobileRowStats => 'Estadísticas de rendimiento';

  @override
  String get paywallMobileRowMental => 'Estado mental';

  @override
  String get paywallMobileRowExport => 'Exportación PDF';

  @override
  String get paywallPriceAnnualHighlight => '59,99 \$ US / año';

  @override
  String get paywallPriceApproxPerMonth => 'Unos 4,99 \$ US / mes';

  @override
  String paywallTrialEndedBody(String date) {
    return 'Tu prueba gratuita de 7 días (nuevo registro) finalizó el $date. Sin Pro, pasas al plan Lite.';
  }

  @override
  String get paywallLiteLimitedHint =>
      'En Lite solo quedan añadir un trade y el calendario. Lo demás requiere Pro.';

  @override
  String get paywallContinueFreemium => 'Seguir en Lite (acceso limitado)';

  @override
  String get paywallSubscribeButton => 'Suscribirme ahora';

  @override
  String get paywallRestoreButton => 'Ya tengo una suscripción';

  @override
  String get paywallStoreNotConfigured =>
      'Falta el enlace de Stripe. Admin → Config → URL de pago (https://…), activa la facturación e inténtalo de nuevo (sesión iniciada).';

  @override
  String get paywallRestoreNothingFound =>
      'Sigues bloqueado: no hay suscripción activa.';

  @override
  String get paywallLegalFooter =>
      'Pago seguro con Stripe • Cancela cuando quieras • Términos del servicio';

  @override
  String get paywallGoldPremiumPill => 'Acceso premium';

  @override
  String get paywallGoldMarketingHeadline => 'Pasa a PRO';

  @override
  String get paywallGoldTagline => 'La herramienta de los traders rentables.';

  @override
  String get paywallGoldYourPlanLabel => 'Actual';

  @override
  String get paywallGoldLiteColumnCaption => 'Standard';

  @override
  String get paywallGoldProColumnCaption => 'Ilimitado';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSupportSection => 'Soporte';

  @override
  String get settingsSupportCardTitle => 'Soporte y opiniones';

  @override
  String get settingsSupportCardSubtitle =>
      'Escríbenos y consulta las guías en la app.';

  @override
  String get supportFeedbackTitleLead => 'Soporte y ';

  @override
  String get supportFeedbackTitleAccent => 'Feedback';

  @override
  String get supportFeedbackSubtitle => '¿Pregunta o idea? Estamos contigo.';

  @override
  String get supportActionEmailLabel => 'Correo';

  @override
  String get supportActionEmailHint => 'Respuesta en 24 h';

  @override
  String get supportActionDocsLabel => 'Docs';

  @override
  String get supportActionDocsHint => 'Guías de uso';

  @override
  String get supportActionTwitterLabel => 'X';

  @override
  String get supportActionTwitterHint => 'Comunidad';

  @override
  String get supportFormNewMessage => 'Nuevo mensaje';

  @override
  String get supportFormKindLabel => 'Tipo de solicitud';

  @override
  String get supportFormKindAccount => 'Cuenta';

  @override
  String get supportFormKindBilling => 'Facturación';

  @override
  String get supportFormKindFeature => 'Funcionalidad';

  @override
  String get supportFormKindOther => 'Otro';

  @override
  String get supportFormEmailLabel => 'Tu correo';

  @override
  String get supportFormEmailHint => 'nombre@ejemplo.com';

  @override
  String get supportFormDescriptionLabel => 'Descripción';

  @override
  String get supportFormDescriptionHint => 'Detalles del mensaje…';

  @override
  String get supportFormSubmit => 'Enviar ahora';

  @override
  String get supportFormSubmitSuccess =>
      'Gracias — tu mensaje se envió correctamente.';

  @override
  String get supportFormSubmitSuccessPartial =>
      'Gracias — tu mensaje se envió (adjunto no subido).';

  @override
  String get supportFormSubmitDone =>
      'Si no se abrió el correo, inténtalo de nuevo o escríbenos directamente.';

  @override
  String get supportFormErrorEmail => 'Indica un correo electrónico.';

  @override
  String get supportFormErrorDescription => 'Añade una descripción.';

  @override
  String get supportFormMailSubjectPrefix => 'Paychek soporte';

  @override
  String get supportFormMailBodyIntro =>
      'Mensaje enviado desde la app Paychek:';

  @override
  String get supportFormAttachmentLabel => 'Adjunto (opcional)';

  @override
  String get supportFormAttachmentPick => 'Foto o PDF';

  @override
  String get supportFormAttachmentHint => 'PDF o imagen, máx. 10 MB';

  @override
  String get supportFormAttachmentRemove => 'Quitar archivo';

  @override
  String get supportFormAttachmentSignInHint =>
      'Inicia sesión para adjuntar — o usa el correo sin adjunto.';

  @override
  String get supportFormAttachmentTooLarge => 'El archivo supera 10 MB.';

  @override
  String get supportFormAttachmentInvalidExtension =>
      'Solo PDF, JPG, PNG o WebP.';

  @override
  String get supportFormAttachmentReadFailed =>
      'No se pudo leer el archivo. Inténtalo de nuevo.';

  @override
  String get supportFormSubmitFirestoreDone =>
      'Gracias — mensaje guardado. El equipo puede verlo en la consola admin.';

  @override
  String get supportFormSubmitSending => 'Enviando…';

  @override
  String get supportFormSubmitError => 'No se pudo enviar. Revisa la conexión.';

  @override
  String supportErrorEmailOpenFailed(String error) {
    return 'No se pudo abrir el correo: $error';
  }

  @override
  String get supportErrorEmailAppUnavailable =>
      'No se pudo abrir la app de correo. Comprueba que tengas un cliente instalado.';

  @override
  String get supportFormSubmitSavedPartialAttachment =>
      'Mensaje guardado, pero no se subió el adjunto (red, tiempo o Storage). Revisa Firebase o inténtalo después.';

  @override
  String get supportQuickHelpTitle => 'Ayuda rápida';

  @override
  String get supportFaqWhereDataQ => '¿Dónde están mis datos?';

  @override
  String get supportFaqWhereDataA =>
      'Tus datos están en este dispositivo (preferencias, diario, carteras). Cerrar sesión o borrar datos locales puede eliminarlos — exporta PDFs si necesitas archivos.';

  @override
  String get supportFaqFeatureQ => '¿Necesitas una función nueva?';

  @override
  String get supportFaqFeatureA =>
      'Usa el formulario con «Proponer una idea». Leemos cada mensaje.';

  @override
  String get supportStatusLabel => 'Estado técnico';

  @override
  String get supportStatusOperational => 'Servicios operativos';

  @override
  String get helpCenterTitle => 'Centro de ayuda';

  @override
  String get helpCenterSubtitle =>
      'Respuestas rápidas y explicaciones para usar la app.';

  @override
  String get helpCenterSearchHint => 'Buscar…';

  @override
  String get helpCenterVersionMobile => 'Versión móvil';

  @override
  String get helpCenterVersionWeb => 'Versión web';

  @override
  String get helpCenterEmptyResults => 'Sin resultados.';

  @override
  String get helpCenterArticleAddTradeTitle => 'Añadir un trade';

  @override
  String get helpCenterArticleAddTradeBody =>
      'Ve a la pestaña Añadir, rellena los campos (activo, entrada, stop, objetivo…) y guarda. Puedes adjuntar una captura si lo necesitas.';

  @override
  String get helpCenterArticleEditTradeTitle => 'Diario — página de trade';

  @override
  String get helpCenterArticleEditTradeBody =>
      'Guide : Maîtriser votre Journal de Trading (Page Trade)\nLa page Trade est le centre d\'archivage intelligent de Paychek. Elle ne se contente pas de lister vos opérations ; elle les organise pour vous offrir une vision claire de votre progression, du trade individuel à la performance mensuelle.\n\n[img:assets/help_center/trade_page_header_filters.png]\n\n1. Tableau de Bord de Période (Header)\nEn haut de votre journal, vous disposez d\'un résumé instantané de la période sélectionnée :\n\nProfit Net : Votre résultat financier net en dollars et son impact en pourcentage sur votre capital (ex: +1070,00\$ / +53,50%).\n\nLe Win Rate Ring : L\'anneau central affiche votre pourcentage de réussite global. C\'est l\'indicateur visuel immédiat de la santé de votre trading.\n\nCompteur de Trades : Le détail précis du nombre de positions Gagnantes (G), Perdantes (P) et à l\'équilibre (Br).\n\n2. Navigation et Filtres Temporels\nPersonnalisez votre vue selon votre besoin d\'analyse grâce aux sélecteurs rapides :\n\nSélecteur 1D / 1S / 1M / ALL : Basculez instantanément entre une vue journalière, hebdomadaire, mensuelle ou l\'historique complet.\n\nFiltres de statut : Isolez vos trades Gagnants, Perdants ou Breakeven d\'un seul clic pour étudier des comportements spécifiques.\n\nActifs les plus tradés : Visualisez rapidement vos statistiques sur vos instruments préférés (ex: XAUUSD, EURUSD).\n\n[img:assets/help_center/trade_page_period_pdf_report.png]\n\n3. Structure en Accordéons et Rapports PDF\nL\'interface utilise un système de \"replier/déplier\" pour une lecture fluide et des options d\'exportation à tous les niveaux :\n\nRapports de Période (Jour/Semaine/Mois) : Chaque bloc de date (ex: \"14 Mars\") affiche un résumé de la performance du jour.\n\nEn cliquant sur l\'icône PDF à côté de la date, vous téléchargez un rapport complet de cette période spécifique. Idéal pour vos bilans de fin de semaine ou de mois.\n\nRapports de Trade Individuel : Cliquez sur un trade pour le déplier et voir ses détails (Heures, Session, Entry/Exit).\n\nChaque trade possède son propre bouton PDF. Ce document génère une fiche technique pro avec votre graphique et vos scores de discipline.\n\n[img:assets/help_center/trade_page_rings_week_view.png]\n\n4. Analyse visuelle par Ring\nChaque ligne (journée ou trade) est accompagnée d\'un Ring (anneau) :\n\nPour une journée, le ring représente le Win Rate global du jour.\n\nCela vous permet d\'identifier en une seconde vos journées \"rouges\" ou \"vertes\" sans avoir à lire chaque ligne de trade.\n\n[img:assets/help_center/trade_page_options_menu.png]\n\n5. Options de Gestion et Correction (Les 3 points)\nParce qu\'une erreur de saisie peut arriver, Paychek vous donne un contrôle total sur vos archives. À côté de l\'icône PDF de chaque fiche trade, vous trouverez un menu \"Options\" (représenté par 3 points verticaux) :\n\nModifier le Trade : Vous permet de réouvrir le formulaire de saisie pour corriger un prix, changer l\'heure, ajouter un screenshot oublié ou ajuster vos scores de discipline.\n\nSupprimer le Trade : Efface définitivement l\'enregistrement de votre journal.\n\nAttention : La suppression d\'un trade mettra à jour instantanément vos statistiques globales, votre Win Rate et votre capital dans les pages Trade et Performance.';

  @override
  String get helpCenterArticleChecklistTitle => 'Lista de comprobación';

  @override
  String get helpCenterArticleChecklistBody =>
      '📋 Checklist\n\n[img:assets/help_center/checklist_routine_discipline.png]\n\n1. Understanding the progress ring\nThe colored circle at the top of your screen is your readiness indicator.\n\n- Real-time progress: each ticked box moves the percentage forward.\n- Your checklist ring is not only on Routine — it stays in sync on your main Dashboard.\n- The gold standard: we recommend never opening a position unless your ring is at 100%. A trade taken with an incomplete checklist is often an emotional trade.\n\n2. Customize your routine\nEvery trader is unique. Paychek lets you build your own verification system.\n\n- Add a section: tap “+ Add a section” at the bottom to create a category (e.g. morning routine, economic news, post-session).\n- Manage items (⋯ menu):\n  - Add a task: open the three-dot menu next to a section title to insert a new checkpoint.\n  - Delete / edit: if a rule no longer fits your strategy, remove it to keep the UI clean.\n\n3. Default sections\nTo help you get started, we include three pillars:\n\n- Technical Analysis: validate your confluences (trend, S/R, indicators).\n- Risk Management: confirm your stop-loss is set and your risk per trade is respected.\n- Psychology: a quick check that you are not in revenge mode or euphoria.';

  @override
  String get helpCenterArticleCalendarTitle => 'Calendario';

  @override
  String get helpCenterArticleCalendarBody =>
      '📅 Guide: Calendar & performance analysis\n\nThe Paychek Calendar is your main steering tool. It turns raw data into a visual map of your success and discipline.\n\n[img:assets/help_center/calendar_overview.png]\n\n1. Month overview\nColor coding: Green cells show net profit, red cells a loss, and gray cells days with no activity.\n\nQuick summary: Above the calendar, see your win rate, trade count, and total monthly P&L at a glance.\n\nMonthly objective: Watch the progress bar to see how far you are from your financial goal. Tap the settings icon to change your target.\n\n[img:assets/help_center/calendar_monthly_objective.png]\n\n2. Expandable menu (deep analysis)\nTap any month header to open detailed analysis.\n\n[img:assets/help_center/calendar_deep_analysis.png]\n\nDiscipline rings: View your average discipline scores for the month (plan followed, checklist completed, mental state).\n\nSession breakdown: See performance by timezone — Asia, Europe, and US. Great for spotting which part of the day pays best for you.\n\nInteractive sparkline (performance curve):\n- Hover the line to pinpoint a trade (on mobile, drag along the curve with your finger).\n- Tap a point on the curve to open that trade’s full record instantly.\n\n3. Session statistics (sidebar)\nTo the right of your calendar, your consistency stats:\n\nCumulative performance: How your capital evolves day by day.\n\nBest day: Your largest daily gain of the month.\n\nAverage day: What you gain or lose on average per day.\n\n[img:assets/help_center/calendar_trades_month_report.png]\n\n4. PDF export 📄\nAt the top right of the Calendar page, the PDF icon generates a professional report in one tap.\n\nWhat’s inside: The report includes the visual calendar, the performance curve, and a recap of your discipline averages.';

  @override
  String get helpCenterArticleMentalStateTitle => 'Estado mental';

  @override
  String get helpCenterArticleMentalStateBody =>
      'Guide: Mental state — tailor your psychology\n\nRoughly 80% of trading success is psychology. The Mental state page lets you measure how you feel and see how emotions affect your results.\n\n[img:assets/help_center/mental_state_dashboard.png]\n\n1. Global score (The Ring)\nThe central ring shows your “Solid Balance”. It updates from all your indicators (emotions, rest, routines). The higher the score, the more you are in a mindset suited to trading.\n\n2. Personalized impact (gear ⚙️)\nEvery trader is different. Paychek lets you define your own rules:\n\n[img:assets/help_center/mental_state_adjust_impact.png]\n\n- Impact nature: open a criterion’s gear to set Positive (+) or Negative (−). Example: if excitement is dangerous for you, set it to Negative.\n\n- Global impact (%): the slider sets how much that criterion weighs on your global score. Crank it up for what matters most; lower it for secondary criteria.\n\n3. Sections & emotions\n\n[img:assets/help_center/mental_state_section_controls.png]\n\n- Edit / delete: pencil to rename an emotion or indicator; trash to remove it.\n\n- Section toggle (ON / OFF 100%): turn off an entire section (e.g. My Routines). When off, it no longer counts toward your daily global score.\n\n- Add (+): create your own indicators to match your routine.\n\n4. Score calendar & time window\nThe mini-calendar shows your mental score for past days.\n\n- Session settings (⚙️): set a start time and an end time.\n\n- Day mode: track from morning to evening (full-day style window).\n\n- Session mode: focus on trading hours only (e.g. 3:30 PM – 10:00 PM).';

  @override
  String get helpCenterArticleExportPdfTitle => 'Exportar PDF';

  @override
  String get helpCenterArticleExportPdfBody =>
      'En Trade o Rendimiento, usa Exportar PDF. Si falla, revisa los permisos e inténtalo de nuevo.';

  @override
  String get helpCenterArticleResetDataTitle => 'Borrar datos locales';

  @override
  String get helpCenterArticleResetDataBody =>
      'En Ajustes > Datos puedes borrar los datos guardados en este dispositivo. Es irreversible; conviene reiniciar la app después.';

  @override
  String get helpCenterArticleMyStrategyTitle => 'Mi estrategia — Playbook';

  @override
  String get helpCenterArticleMyAnalysisTitle =>
      'Mi análisis — planes de trading';

  @override
  String get helpCenterArticleMyAnalysisBody =>
      '🔬 My Analysis: Build Your Trading Plans\n\nThe My Analysis page lets you build a full roadmap before you enter the market. By quantifying each technical element, Paychek calculates a global confidence score to validate your setup.\n\n[img:assets/help_center/analyse_trend_sheet.png]\n\n1. Trend card (context)\nDefine the frame for your opportunity:\n\nAsset & name: Use (+) to name your analysis and the instrument (e.g. EUR/USD — Weekly Swing Plan).\n\nDirection & phase: Choose your bias (Buy, Sell, or Watch) and the current market phase (Accumulation, Impulse, Distribution).\n\nConfidence slider: Set how certain you feel for this section. Open the gear (⚙️) to adjust this card’s impact (weight %) on the final report confidence.\n\n[img:assets/help_center/analyse_card_controls.png]\n\nCustomization: Use the pencil to edit available timeframes or phases, and Duplicate to compare several analyses on different timeframes in the same section.\n\n2. Technical sections (Structure, SMC, Indicators, Volume)\nEveryone trades differently. Turn cards on or off with the ON/OFF switch:\n\n[img:assets/help_center/analyse_technical_cards.png]\n\nStructure: Log support and resistance. Tick if a level was tested more than twice to strengthen relevance.\n\nSMC & Liquidity: Record Order Blocks, Fair Value Gaps (FVG), and Fibonacci levels.\n\nIndicators & Volume profile: Detail RSI/MACD signals or Point of Control (POC) zones.\n\nScreenshot: Attach a chart capture to illustrate your plan visually.\n\n3. Generating the report\nWhen your analysis is ready, tap Report.\n\n[img:assets/help_center/analyse_summary_report.png]\n\nGlobal confidence ring: The final ring is computed from your sliders and their impact weights.\n\nDynamic color coding: The validated report at the bottom uses a color that matches your direction: green (Buy), red (Sell), or yellow (Watch).\n\n[img:assets/help_center/analyse_report_embedded.png]\n\n4. Managing reports\nHistory: Reports are saved and tied to your instruments.\n\nActions: You can edit (pencil), delete (trash), or export a professional PDF of your analysis to archive or share.\n\n[img:assets/help_center/analyse_report_pdf.png]';

  @override
  String get helpCenterArticlePerformanceTitle =>
      'Rendimiento — escáner de trading';

  @override
  String get settingsLogoutButton => 'Cerrar sesión';

  @override
  String get settingsLogoutSnack => 'Sesión cerrada.';

  @override
  String get settingsLogoutSnackPartial =>
      'Perfil borrado en el dispositivo. Si tu cuenta sigue visible, revisa la red o reinicia la app.';

  @override
  String get splashTagline => 'Domina la mente, domina el trade';

  @override
  String get statsAvgGain => 'Ganancia promedio';

  @override
  String get statsPsychSub => 'Plan seguido';

  @override
  String get statsPsychology => 'Psicología';

  @override
  String get statsRR => 'relación R/R';

  @override
  String get statsSectionTitle => 'ESTADÍSTICA';

  @override
  String get statsStrategy => 'Estrategia';

  @override
  String get statsStrategySub => 'Criterios validados';

  @override
  String get strategieAlertSignal => 'SEÑAL DE ALERTA';

  @override
  String get strategieDescription => 'DESCRIPCIÓN';

  @override
  String get strategieDescriptionHint => 'p.ej. Baja volatilidad';

  @override
  String get strategieEditSessionTitle => 'Editar sesión';

  @override
  String get strategieHintEntry => '¿Dónde hacer clic en COMPRAR/VENDER?';

  @override
  String get strategieHintIndicatorTag => 'p.ej. RSI';

  @override
  String get strategieHintInvalidation => '¿Dónde está mal el escenario?';

  @override
  String get strategieHintManagement => '¿Cómo asegurar el puesto?';

  @override
  String get strategieHintPattern => 'p.ej. Doble Fondo';

  @override
  String get strategieHintSignal => 'Desencadenar…';

  @override
  String get strategieHintTarget => 'Objetivo final o zonas de liquidez';

  @override
  String get strategieHintTimeframeTag => 'p.ej. M15';

  @override
  String get strategieIndicators => 'INDICADORES';

  @override
  String get strategieModelName => 'NOMBRE DEL MODELO';

  @override
  String get strategieNewSessionTitle => 'Nueva sesión';

  @override
  String get strategiePatternFigure => 'PATRÓN / FIGURA';

  @override
  String get strategieRuleEntryPrecise => 'ENTRADA PRECISA';

  @override
  String get strategieRuleInvalidation => 'INVALIDACIÓN (STOP LOSS)';

  @override
  String get strategieRuleManagement => 'GESTIÓN (BREAKEVEN / PARCIALES)';

  @override
  String get strategieRuleTarget => 'OBJETIVO (OBTENCIÓN DE BENEFICIOS)';

  @override
  String get strategieSessionName => 'NOMBRE DE LA SESIÓN';

  @override
  String get strategieSetupColor => 'COLOR';

  @override
  String get strategieSetupEditTitle => 'Editar configuración';

  @override
  String get strategieSetupNewTitle => 'Nueva configuración';

  @override
  String get strategieTimeEndOptionalLabel => 'FINAL (OPCIONAL)';

  @override
  String get strategieTimeStartLabel => 'COMENZAR';

  @override
  String get strategieTimeframes => 'PLAZOS';

  @override
  String get strategieZoneNoTrade => 'No hay intercambio';

  @override
  String get strategieZoneTrade => 'Comercio';

  @override
  String get strategieZoneType => 'TIPO DE ZONA';

  @override
  String get strategiePagePlaybookIntro =>
      'Tu plan de trading (Playbook). Repasa estas reglas antes de cada sesión para mantener la disciplina y el enfoque.';

  @override
  String get analyseReportTitle => 'Informe';

  @override
  String get strategieGestionCaptionMaximum => 'Máximo';

  @override
  String get strategieGestionCaptionMinimum => 'Mínimo';

  @override
  String get strategieSectionSetupsAndModels => 'SETUPS Y PLANTILLAS';

  @override
  String get strategieSectionTradeCalendar => 'CALENDARIO DE TRADES';

  @override
  String get strategieCalendarNeedSetupForUsage =>
      'Añade un setup arriba para registrar los días de uso.';

  @override
  String strategieCalendarUsageForSetup(String name) {
    return 'Uso — $name';
  }

  @override
  String get strategieCalendarUsageTooltip =>
      'Marcar o quitar este día para este setup (mismo nombre que en Añadir trade).';

  @override
  String get strategieCalendarDotsExplain =>
      'Un punto por estrategia usada ese día, según tus trades (Añadir trade, fecha de entrada).';

  @override
  String get strategieSetupNavPrevious => 'ANTERIOR';

  @override
  String get strategieSetupNavNext => 'SIGUIENTE SETUP >';

  @override
  String get strategieSheetSetupsTitle => 'Setups y plantillas';

  @override
  String get strategieMenuDisableFactors => 'Desactivado';

  @override
  String get strategieManageTemplates => 'Gestionar plantillas';

  @override
  String get strategieDuplicateSetup => 'Duplicar un setup';

  @override
  String get strategieMesReglesDraftHint => 'Nueva regla...';

  @override
  String get strategieSetupRemoveFromDashboard => 'Quitar del panel';

  @override
  String get strategieSetupShowOnDashboard => 'Mostrar en el panel';

  @override
  String get strategiePdfPlaybookBlurbShort =>
      'Tu plan de trading (Playbook). Repasa estas reglas antes de cada sesión.';

  @override
  String get strategiePdfFooterNote =>
      'Reglas de oro: textos de referencia (no guardados). Riesgo, horarios y setups: datos guardados.';

  @override
  String get strategiePdfTableSession => 'Sesión';

  @override
  String get strategiePdfTableDescription => 'Descripción';

  @override
  String get strategiePdfTableSchedule => 'Horario';

  @override
  String get strategiePdfTechnicalContext => 'Contexto técnico';

  @override
  String get strategiePdfAlertSignal => 'Señal de alerta';

  @override
  String get strategiePdfFileNamePrefix => 'mi_estrategia';

  @override
  String strategiePdfExportError(String error) {
    return 'No se pudo crear el PDF: $error';
  }

  @override
  String get symbolHint => 'p.ej. fr, ₣';

  @override
  String get symbolLabel => 'Símbolo';

  @override
  String get tradeColEndingBalance => 'Saldo final';

  @override
  String get tradeColPnl => 'PNL';

  @override
  String get tradeColResult => 'Resultado';

  @override
  String get tradeColStartingBalance => 'Saldo inicial';

  @override
  String get tradeColTotalGain => 'ganancia total';

  @override
  String get tradeColTotalGainPct => '% de ganancia total';

  @override
  String get tradeColTrade => 'Comercio #';

  @override
  String get tradeDeleteConfirmBody => 'Esta acción es permanente.';

  @override
  String get tradeDeleteConfirmTitle => '¿Eliminar esta operación?';

  @override
  String get tradeReturn => 'retorno comercial';

  @override
  String get tradeActionsTooltip => 'Comportamiento';

  @override
  String get tradeAverageShort => 'PROMEDIO';

  @override
  String tradeDayTradeNumber(int n) {
    return 'Opere #$n hoy';
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
  String get tradeEditMenu => 'Editar';

  @override
  String get tradeExportPdfTooltip => 'Exportar PDF';

  @override
  String get tradeFilterAll => 'Todo';

  @override
  String get tradeFilterBreakeven => 'Punto de equilibrio';

  @override
  String get tradeFilterLoser => 'Perdedores';

  @override
  String get tradeFilterOpenPosition => 'Posiciones abiertas';

  @override
  String get tradeFilterWinner => 'Ganadores';

  @override
  String tradeSummaryBreakdownShort(int w, int l, int b) {
    return 'G:$w  P:$l  Br:$b';
  }

  @override
  String tradeSummaryBreakdownWithOpen(int w, int l, int b, int o) {
    return 'G:$w  P:$l  Br:$b  Abi:$o';
  }

  @override
  String get tradeGainShort => 'NETO';

  @override
  String get tradeLabelChecklist => 'Lista de verificación';

  @override
  String get tradeLabelDuration => 'Duración';

  @override
  String get tradeLabelEntry => 'Entrada';

  @override
  String get tradeLabelEtat => 'Estado';

  @override
  String get tradeLabelExit => 'Salida';

  @override
  String get tradeLabelHours => 'Horas';

  @override
  String get tradeLabelPlan => 'Plan';

  @override
  String get tradeLabelSession => 'Sesión';

  @override
  String get tradeLabelStrategie => 'Estrategia';

  @override
  String get tradeLabelNews => 'Noticias';

  @override
  String get tradeMindsetFeeling => 'Sentimiento';

  @override
  String get tradeMindsetPrinciple => 'Principio';

  @override
  String get tradeMonthTitle => 'Mes';

  @override
  String get tradeMostTradedHeading => 'Activos más negociados';

  @override
  String get tradeNotRespected => 'No seguido';

  @override
  String tradeOpenPositionLine(String when) {
    return 'Posición abierta • Entrada $when';
  }

  @override
  String get tradePdfAnalysePostTrade => 'Revisión post-negociación';

  @override
  String get tradePdfBarresSemaine => 'barras semanales';

  @override
  String get tradePdfCloture => 'Cerrado';

  @override
  String get tradePdfPositionOpen => 'Posición abierta';

  @override
  String tradePdfDatePrefix(String when) {
    return 'Fecha: $when';
  }

  @override
  String tradePdfDetailsTitle(String pair) {
    return 'Detalles comerciales ($pair)';
  }

  @override
  String get tradePdfEtatPsychologique => 'Estado psicológico';

  @override
  String get tradePdfTags => 'Etiquetas';

  @override
  String get tradeTagsSection => 'TAG';

  @override
  String get tradePdfExportDayTitle => 'Operaciones (día)';

  @override
  String get tradePdfExportMonthTitle => 'Operaciones (mes)';

  @override
  String get tradePdfExportWeekTitle => 'Operaciones (semana)';

  @override
  String get tradePdfGainNet => 'PyG netas';

  @override
  String get tradePdfImpactCapital => 'Impacto de capital';

  @override
  String get tradePdfMoyenne => 'Promedio';

  @override
  String get tradePdfNonRespecte => 'No seguido';

  @override
  String get tradePdfPeriode => 'Período';

  @override
  String get tradePdfQualiteMoyennes => 'Calidad (promedios)';

  @override
  String tradePdfScreenshotTitle(String pair) {
    return 'Captura de pantalla: $pair';
  }

  @override
  String get tradePdfSessions => 'Sesiones';

  @override
  String get tradePdfSparklineMois => 'Minigráfico del mes';

  @override
  String get tradePdfTrades => 'Vientos alisios';

  @override
  String get tradePdfWinRate => 'Tasa de ganancia';

  @override
  String tradePctOfCapital(String percent) {
    return '$percent% del capital';
  }

  @override
  String get tradeScreenshotLoadError => 'No se pudo cargar la imagen';

  @override
  String get tradeScreenshotUnavailableWeb =>
      'Captura de pantalla no disponible (web)';

  @override
  String get tradeSectionChecklist => 'Lista de verificación';

  @override
  String get tradeSectionEtat => 'Estado';

  @override
  String get tradeSectionPlan => 'Plan';

  @override
  String get tradeSectionStrategie => 'Estrategia';

  @override
  String tradeStrategieNonRespectUnmapped(String id) {
    return 'Detalle de estrategia ($id)';
  }

  @override
  String get tradeSessionAsia => 'Asia';

  @override
  String get tradeSessionEurope => 'Europa';

  @override
  String get tradeSessionLate => 'Fuera de horas';

  @override
  String get tradeSessionUs => 'A NOSOTROS';

  @override
  String get tradeSideBreakevenShort => 'DESPERDICIO';

  @override
  String get tradeSideBuyLong => 'Comprar';

  @override
  String get tradeSideBuyShort => 'COMPRAR';

  @override
  String get tradeSideSellLong => 'Vender';

  @override
  String get tradeSideSellShort => 'VENDER';

  @override
  String get tradeSummaryProfitNet => 'PyG NETA';

  @override
  String get tradeSummaryTrades => 'VIENTOS ALISIOS';

  @override
  String get tradeSummaryWinRate => 'TASA DE GANANCIA';

  @override
  String get tradeTotalUpper => 'TOTAL';

  @override
  String get tradeTradesListHeading => 'Vientos alisios';

  @override
  String get tradeTradesMonthHeading => 'Operaciones (mes)';

  @override
  String get tradeTradesWeekHeading => 'Operaciones (semana)';

  @override
  String get tradeWeekTitle => 'Semana';

  @override
  String get tradeWinDayRingSubtitle => 'GANAR (día)';

  @override
  String get tradeWinrateLabel => 'Tasa de ganancia';

  @override
  String get settingsTradingWeek5 => '5 días (lun–vie)';

  @override
  String get settingsTradingWeek7 => '7 días (lun–dom)';

  @override
  String get settingsTradingWeekSubtitle =>
      '5 días para mercados tradicionales (lun–vie), 7 días para la semana completa (p. ej. cripto).';

  @override
  String get settingsTradingWeekTitle => 'Semana mostrada';

  @override
  String get settingsDashboardCardSubtitle =>
      'Personalizar inicio: secciones y orden';

  @override
  String get settingsDashLayoutTitle => 'Secciones del inicio';

  @override
  String get settingsDashLayoutReorderHint =>
      'Arrastra las asas para reordenar. Desactiva una sección para ocultarla en el inicio.';

  @override
  String get settingsDashOpenHomeButton => 'Ver inicio';

  @override
  String get settingsDashSectionCapital => 'Capital y win rate';

  @override
  String get settingsDashSectionChecklist => 'Lista de verificación';

  @override
  String get settingsDashSectionAnalyse => 'Análisis';

  @override
  String get settingsDashSectionEtat => 'Estado mental';

  @override
  String get settingsDashSectionStrategie => 'Estrategia';

  @override
  String get settingsDashSectionWeekly => 'Rendimiento semanal';

  @override
  String get settingsDashSectionEvolution => 'Evolución del capital';

  @override
  String get settingsDashSectionLens => 'Paychek Lens';

  @override
  String get tradingSection => 'Comercio';

  @override
  String get settingsCgvSection => 'Condiciones';

  @override
  String get settingsCgvPageTitle => 'Condiciones generales de venta';

  @override
  String get settingsCgvRowTitle => 'Condiciones generales de venta';

  @override
  String get settingsCgvRowSubtitle =>
      'Leer el texto completo en la aplicación';

  @override
  String get settingsCgvDocHeading =>
      'CONDICIONES GENERALES DE VENTA (CGV) - PAYCHEK';

  @override
  String get settingsCgv1Title => '1. Objeto';

  @override
  String get settingsCgv1Body =>
      'Las presentes CGV regulan la suscripción al acceso «Pro» (Premium) a la aplicación Paychek, una herramienta de diario de trading y gestión de riesgos. El acceso se proporciona mediante suscripción mensual, trimestral o anual, renovada automáticamente en cada periodo hasta su cancelación.';

  @override
  String get settingsCgv2Title => '2. Servicios prestados';

  @override
  String get settingsCgv2Body =>
      'El acceso Premium desbloquea todas las funciones de la aplicación (estadísticas avanzadas, cálculo automático de riesgo, exportación de datos). El acceso está vinculado a la cuenta de usuario creada en el registro.';

  @override
  String get settingsCgv3Title => '3. Precios y pago';

  @override
  String get settingsCgv3Body =>
      'Suscripción directa: los planes Pro se facturan en dólares estadounidenses (USD) a través de Stripe, con renovación automática hasta cancelación:\n• 8,99 \$ USD / mes\n• 20,97 \$ USD / 3 meses\n• 59,99 \$ USD / año\n\nOferta de socio: El acceso puede ofrecerse gratis si el usuario cumple las condiciones de referidos con uno de nuestros socios (Prop Firm o broker).\n\nPaychek se reserva el derecho de modificar los precios en cualquier momento para nuevos clientes.';

  @override
  String get settingsCgv4Title => '4. Derecho de desistimiento y reembolso';

  @override
  String get settingsCgv4Body =>
      'Conforme a la legislación sobre productos digitales:\n\nDebido a la naturaleza digital del servicio y al acceso inmediato al contenido tras el pago, el usuario acepta que el servicio comience de inmediato y renuncia expresamente al derecho de desistimiento de 14 días.\n\nNo se realizará ningún reembolso una vez activado el acceso Premium, salvo en caso de fallo técnico grave que impida usar la aplicación.';

  @override
  String get settingsCgv5Title => '5. Cláusula específica \"Oferta de socio\"';

  @override
  String get settingsCgv5Body =>
      'El acceso ofrecido mediante un socio está supeditado a la validación de la afiliación por dicho socio.\n\nSi el socio rechaza la afiliación (por incumplimiento de las normas de depósito o de trading), Paychek se reserva el derecho de revocar el acceso Premium o exigir el pago de las tarifas Pro vigentes.';

  @override
  String get settingsCgv6Title => '6. Advertencia de riesgos (Trading)';

  @override
  String get settingsCgv6Body =>
      'Paychek no es un asesor financiero. La aplicación es una herramienta técnica de gestión y análisis.\n\nEl trading conlleva un alto riesgo de pérdida de capital. El usuario es el único responsable de sus decisiones de trading.\n\nPaychek no será responsable de las pérdidas financieras del usuario en los mercados.';

  @override
  String get settingsCgv7Title => '7. Disponibilidad del servicio';

  @override
  String get settingsCgv7Body =>
      'Paychek procura mantener el acceso 24/7. No obstante, no somos responsables de las interrupciones por mantenimiento o fallos de servidores de terceros (Firebase, Google Cloud).';

  @override
  String get settingsCgv8Title => '8. Protección de datos';

  @override
  String get settingsCgv8Body =>
      'Los datos de trading de los usuarios son estrictamente confidenciales y nunca se revenden. Se almacenan de forma segura a través de nuestros proveedores técnicos.';

  @override
  String get settingsPrivacyRowTitle => 'Política de privacidad';

  @override
  String get settingsPrivacyRowSubtitle =>
      'Datos personales, cookies y tus derechos';

  @override
  String get settingsPrivacyPageTitle => 'Política de privacidad';

  @override
  String get settingsPrivacyDocHeading => 'POLÍTICA DE PRIVACIDAD — PAYCHEK';

  @override
  String get settingsDataResetSection => 'Datos';

  @override
  String get settingsDataResetTitle => 'Borrar todos los datos locales';

  @override
  String get settingsDataResetDescription =>
      'Si has usado Paychek durante un tiempo y quieres volver a empezar (como tras reinstalar la app), puedes borrar todo lo guardado en este dispositivo: operaciones, análisis, diario, diseño del panel, perfil local, anclaje de prueba, etc.\n\nSe mantienen tu idioma y la opción de «semana mostrada».\n\nCierra por completo la aplicación y ábrela de nuevo para vaciar memoria temporal (p. ej. checklist).';

  @override
  String get settingsDataResetButton => 'Borrar todo en este dispositivo';

  @override
  String get settingsDataResetDialogTitle => '¿Borrar todos los datos locales?';

  @override
  String get settingsDataResetDialogBody =>
      'Acción irreversible. Se eliminarán los datos locales de Paychek en este dispositivo. Tu sesión en Firebase puede seguir iniciada; solo se borran copias locales.\n\nReinicia la app si algo parece seguir en caché.';

  @override
  String get settingsDataResetDialogCancel => 'Cancelar';

  @override
  String get settingsDataResetDialogConfirm => 'Borrar todo';

  @override
  String get settingsDataResetSuccess =>
      'Datos locales borrados. Reinicia la app si es necesario.';

  @override
  String get validate => 'Confirmar';

  @override
  String get winrate => 'Tasa de ganancia';
}
