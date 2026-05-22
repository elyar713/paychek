// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get addPortfolio => 'Adicionar portfólio';

  @override
  String get ajouterTradeCapitalRequiredHint =>
      'Defina um capital (questionário) para permitir o cálculo.';

  @override
  String get ajouterTradeCapitalGainEnterExitToShowPnl =>
      'Insira o preço de saída para mostrar o P&L.';

  @override
  String get ajouterTradeCapitalGainOpenPositionNote =>
      'Posição aberta: o P&L estimado será mostrado quando você fechar.';

  @override
  String get ajouterTradeCommissionFeesLabel => 'Taxas (comissão)';

  @override
  String get ajouterTradeFillSuggestedLot => 'Preencher lote';

  @override
  String get ajouterTradeSizingEstimationFootnote =>
      '* As estimativas usam capital poupado; os valores do contrato/CFD são aproximados.';

  @override
  String get ajouterTradeScreenshotHelp =>
      'Adicione um gráfico ou configure a captura de tela (opcional).';

  @override
  String get ajouterTradeCsvChooseSoftware => 'Choisir un logiciel';

  @override
  String get ajouterTradeAnalyseCardTitle => 'ANÁLISE';

  @override
  String get ajouterTradeAnalyseCardHelp =>
      'Escolha um relatório em Minha análise — o PDF será anexado a este trade ao salvar.';

  @override
  String get ajouterTradeAnalyseChooseReport => 'Escolher uma análise';

  @override
  String get ajouterTradeAnalysePdfGenerating => 'A gerar PDF…';

  @override
  String ajouterTradeAnalysePdfAttached(String fileName) {
    return 'PDF anexado: $fileName';
  }

  @override
  String get ajouterTradeAnalyseClear => 'Remover';

  @override
  String get ajouterTradeAnalysePdfError =>
      'Não foi possível gerar o PDF da análise.';

  @override
  String get ajouterTradeAnalysePdfNotReady =>
      'Aguarde a geração do PDF ou remova a seleção.';

  @override
  String get ajouterTradeNoteCardTitle => 'NOTA';

  @override
  String get ajouterTradeNoteCardHelp =>
      'Notas pessoais sobre este trade (opcional).';

  @override
  String get ajouterTradeNoteHint => 'Contexto, lições, emoções…';

  @override
  String get ajouterTradeSessionAutoTagTitle => 'Sessão do dia';

  @override
  String get ajouterTradeSessionAutoTagSubtitle =>
      'Marca auto Princípio / Feeling pela ordem de entrada. Inclui CSV.';

  @override
  String ajouterTradeSessionPlannedCountLabel(int count) {
    return 'Trades « no plano » por dia: $count';
  }

  @override
  String get ajouterTradeSessionAutoTagHint =>
      'Ex.: 2 → trades 1–2 Princípio, a partir do 3 Feeling.';

  @override
  String ajouterTradeSessionHint(int rank, String tag) {
    return 'Trade n°$rank hoje → auto: $tag';
  }

  @override
  String get tradeNoteSectionTitle => 'Nota';

  @override
  String get ajouterTradePageTitle => 'Adicionar negociação';

  @override
  String get ajouterTradeErrorQtyPositive =>
      'Insira um tamanho de posição maior que 0.';

  @override
  String get ajouterTradeErrorEntryPrice =>
      'Insira um preço de entrada válido (maior que 0).';

  @override
  String get ajouterTradeErrorExitOrFlags =>
      'Insira um preço de saída válido ou marque a posição de equilíbrio / aberta se a saída ainda não for conhecida.';

  @override
  String get ajouterTradePsychTagBlind => 'Cego';

  @override
  String get ajouterTradeCapitalGainHeading => 'CAPITAL E GANHO';

  @override
  String get ajouterTradeMindsetPrompt => 'Você fez esta negociação com:';

  @override
  String get ajouterTradeDisciplineSettingsTooltip =>
      'Configurações: Seções de sentimento e ativas.';

  @override
  String get ajouterTradeSaveAndNext => 'Salvar & próximo';

  @override
  String ajouterTradeLiteMonthlyLimitReached(int max) {
    return 'Lite: você pode registrar até $max negociações por mês civil. Faça upgrade para Pro para entradas ilimitadas.';
  }

  @override
  String ajouterTradeLiteMonthlyLimitImportSkipped(int skipped, int max) {
    return '$skipped negociação(ões) não importada(s): o plano Lite permite no máximo $max negociações por mês civil.';
  }

  @override
  String get tradeImportPickSoftwareFirst =>
      'Escolhe uma plataforma antes de importar.';

  @override
  String get tradeImportEmptyFile => 'Ficheiro vazio ou ilegível.';

  @override
  String get tradeImportMt4HtmlOnly => 'MT4: usa uma exportação HTML/HTM.';

  @override
  String get tradeImportTradingViewCsvOnly =>
      'TradingView: usa uma exportação CSV.';

  @override
  String get tradeImportCtraderHtmlOnly =>
      'cTrader: usa um extrato HTML/HTM (conta).';

  @override
  String get tradeImportTradovateOrdersCsv =>
      'Tradovate: exporta Orders.csv (execuções).';

  @override
  String get tradeImportTradovatePickOrdersCsv =>
      'Tradovate: escolhe um ficheiro Orders.csv.';

  @override
  String get tradeImportNinjaGridCsv =>
      'NinjaTrader: exporta uma grelha CSV (ordens ou execuções).';

  @override
  String get tradeImportNinjaPickCsv =>
      'NinjaTrader: escolhe um ficheiro CSV (grelha).';

  @override
  String get tradeImportRithmicCsv =>
      'Rithmic: usa uma exportação CSV (Recent Orders).';

  @override
  String get tradeImportRithmicPickCsv => 'Rithmic: escolhe um ficheiro CSV.';

  @override
  String get tradeImportQuantowerCsv =>
      'Quantower: usa uma exportação CSV (Orders history).';

  @override
  String get tradeImportQuantowerPickCsv =>
      'Quantower: escolhe um ficheiro CSV (Orders history).';

  @override
  String get tradeImportAtasXlsxReadFailed =>
      'Não foi possível ler o .xlsx (vazio ou demasiado grande para o browser). Tenta novamente.';

  @override
  String get tradeImportAtasPickCsvXlsx =>
      'ATAS: escolhe um ficheiro CSV ou .xlsx (Estatísticas).';

  @override
  String get tradeImportAtasXlsxEmptyFile => 'Ficheiro vazio.';

  @override
  String get tradeImportAtasXlsxInvalidFormat =>
      'Não é um .xlsx Excel válido (cabeçalho em falta). Exporta novamente a partir do ATAS.';

  @override
  String get tradeImportAtasXlsxJournalMissing =>
      'Folha Journal não encontrada ou livro ilegível. Verifica a exportação Estatísticas .xlsx.';

  @override
  String get tradeImportAtasXlsxNoRows =>
      'Nenhuma linha de negociação reconhecida. Abre a folha Journal: colunas Instrument, Open time, Open/Close volume.';

  @override
  String tradeImportNotImplemented(String source) {
    return 'Importação $source ainda não disponível.';
  }

  @override
  String tradeImportEmptyMt5(String extension) {
    return 'MT5 $extension: nenhuma linha Position detetada.';
  }

  @override
  String get tradeImportEmptyTradingView =>
      'TradingView CSV: nenhuma posição fechada detetada.';

  @override
  String get tradeImportEmptyCtrader =>
      'cTrader HTML: nenhuma linha Histórico detetada.';

  @override
  String get tradeImportEmptyTradovate =>
      'Tradovate CSV: nenhum round-trip (entrada/saída) detetado.';

  @override
  String get tradeImportEmptyNinjaTrader =>
      'NinjaTrader CSV: nenhum round-trip (entrada/saída) detetado.';

  @override
  String get tradeImportEmptyAtas =>
      'ATAS: nenhuma linha reconhecida (apenas folha Journal).';

  @override
  String get tradeImportEmptyGeneric =>
      'Nenhuma posição reconhecida para esta plataforma/ficheiro.';

  @override
  String tradeImportNoneNew(String source, String duplicates) {
    return 'Nenhuma negociação nova importada de $source$duplicates.';
  }

  @override
  String tradeImportSummary(int count, String source, String duplicates) {
    return '$count negociação(ões) importada(s) de $source$duplicates.';
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
    return 'Importação falhou: $error';
  }

  @override
  String get ajouterTradeSectionEtatMoment => 'ESTADO ATUAL';

  @override
  String get ajouterTradeImagePickerClose => 'Fechar';

  @override
  String get ajouterTradeImagePickerTitle => 'Fonte da imagem';

  @override
  String get ajouterTradeGallery => 'Imagens';

  @override
  String get ajouterTradeCamera => 'Câmera';

  @override
  String get ajouterTradeFeedbackAlmost100 =>
      'Você está perto de 100%: continue aplicando todos os pontos.';

  @override
  String get ajouterTradeFeedbackTickEach =>
      'Marque cada ponto que se aplica (várias seleções).';

  @override
  String get ajouterTradeChoicesSaved => 'Escolhas salvas:';

  @override
  String ajouterTradeNonRespectedSemantic(Object label) {
    return '• Não são seguidos';
  }

  @override
  String ajouterTradeDisciplineRespectBase(int pct) {
    return 'Respeito';
  }

  @override
  String ajouterTradeDisciplineRespectNonList(Object items, Object more) {
    return '· Não seguido: $items$more';
  }

  @override
  String get ajouterTradeFieldActif => 'Ativo';

  @override
  String get ajouterTradeFieldEntree => 'Entrada';

  @override
  String get ajouterTradeFieldSortie => 'Sair';

  @override
  String get ajouterTradeCheckboxBreakeven => 'Breakeven';

  @override
  String get ajouterTradeCheckboxPositionOpen => 'Posição Aberta';

  @override
  String get ajouterTradeCheckboxAvantNews => 'Antes de notícias';

  @override
  String get ajouterTradeCheckboxApresNews => 'Depois de notícias';

  @override
  String get ajouterTradeDirectionBuyLong => 'Comprar/Long ';

  @override
  String get ajouterTradeDirectionSellShort => 'Vender/Short ';

  @override
  String get ajouterTradeEntryExitDateHint =>
      'Dica: defina a data e a hora para Entrada e Saída. Na página Desempenho, isso vincula a duração da posição ao seu lucro ou prejuízo.';

  @override
  String get ajouterTradeQtyLots => 'Tamanho (lotes)';

  @override
  String get ajouterTradeQtyContracts => 'Tamanho (contratos)';

  @override
  String get ajouterTradeQtyUnits => 'Tamanho (unidades)';

  @override
  String get ajouterTradeQtyShares => 'Tamanho (ações)';

  @override
  String get ajouterTradeShortcutsLots => 'Atalhos do lote';

  @override
  String get ajouterTradeShortcutsContracts => 'Atalhos de contrato';

  @override
  String get ajouterTradeShortcutsQty => 'Atalhos de tamanho';

  @override
  String get ajouterTradeShortcutsCommonSizes => 'Atalhos (tamanhos comuns)';

  @override
  String get ajouterTradeLotHintMini => 'Por exemplo, 0,1 = mini lote típico.';

  @override
  String get ajouterTradeLotFieldHintForex => 'por exemplo, 0,1';

  @override
  String get ajouterTradeLotFieldHintContracts => 'e.g. 2';

  @override
  String get ajouterTradeLotFieldHintUnits => 'por exemplo 1';

  @override
  String get ajouterTradeLotFieldHintShares => '[por exemplo, 10%]';

  @override
  String get ajouterTradeDisciplineSettingsTitle =>
      'Configurações de disciplina';

  @override
  String get ajouterTradeDisciplineSettingsSubtitle =>
      'Escolha quais seções estão ativas para esta negociação.';

  @override
  String get ajouterTradeDisciplineFeelingModeTitle => 'Modo sentimento';

  @override
  String get ajouterTradeDisciplineFeelingAllowSubtitle =>
      'Permitir o preenchimento das seções abaixo.';

  @override
  String get ajouterTradeDisciplineSectionsHeading => 'SEÇÕES';

  @override
  String get ajouterTradeDisciplineStrategieTitle => 'Estratégia';

  @override
  String get ajouterTradeDisciplineStrategieSubtitle =>
      'Configuração, feedback';

  @override
  String get ajouterTradeDisciplinePlanTitle => 'Analysis plan';

  @override
  String get ajouterTradeDisciplineConfidencePlanTitle => 'Plano de confiança';

  @override
  String get ajouterTradeDisciplinePlanSubtitle => 'Relatório, feedback';

  @override
  String get ajouterTradeDisciplineChecklistTitle => 'Checklist';

  @override
  String get ajouterTradeDisciplineChecklistSubtitle => 'Pontos a seguir';

  @override
  String get ajouterTradeDisciplineEtatTitle => 'Estado do momento';

  @override
  String get ajouterTradeDisciplineEtatSubtitle => 'Momentos e emoções';

  @override
  String get ajouterTradeDisciplineSliderStrategieRespected =>
      'Estratégia seguida';

  @override
  String get ajouterTradePositionSettingsTitle => 'Configurações de Posição';

  @override
  String get ajouterTradeStrategieFeedbackBravo =>
      'Muito bem! Você seguiu sua estratégia completamente.';

  @override
  String get ajouterTradeStrategieFeedbackWhichMissed =>
      'Quais partes da sua estratégia você não seguiu?';

  @override
  String get ajouterTradeStrategieGoldRules => 'REGRAS DE OURO';

  @override
  String ajouterTradeStrategieRuleN(int n) {
    return 'Regra ';
  }

  @override
  String ajouterTradeStrategieSetupTimeframesRow(Object value) {
    return 'Períodos:';
  }

  @override
  String ajouterTradeStrategieSetupIndicatorsRow(Object value) {
    return 'Indicadores: $value';
  }

  @override
  String ajouterTradeStrategieSetupPatternRow(Object value) {
    return 'Padronizar:';
  }

  @override
  String ajouterTradeStrategieSetupSignalRow(Object value) {
    return 'Sinal: $value';
  }

  @override
  String get ajouterTradeStrategieRiskManagement => 'GESTÃO DE RISCOS';

  @override
  String get ajouterTradeStrategieHoursSessions => 'HORAS E SESSÕES';

  @override
  String get ajouterTradeStrategieSetupModels => 'CONFIGURAÇÃO E MODELOS';

  @override
  String ajouterTradeStrategieSetupModelsWithTitle(Object title) {
    return 'CONFIGURAÇÃO E MODELOS — $title';
  }

  @override
  String get ajouterTradeStrategiePickStrategyHint =>
      'Escolha uma estratégia da lista acima para mostrar os detalhes de configuração (entrada, parada, destino, gerenciamento de negociação, etc.).';

  @override
  String get ajouterTradeStrategieRowPattern => 'Padrão';

  @override
  String get ajouterTradeStrategieRowSignal => 'Sinal';

  @override
  String get ajouterTradeStrategieClosedLabel100 => 'Ótimo, estratégia seguida';

  @override
  String get ajouterTradeStrategieClosedLabel95 => 'Quase totalmente seguido';

  @override
  String get ajouterTradeStrategieClosedLabelLow => 'Pontos a serem revisados';

  @override
  String get ajouterTradePlanPickReportAbove =>
      'Escolha um relatório no campo acima.';

  @override
  String get ajouterTradePlanFeedbackAlmost100 =>
      'Você está perto de 100%: continue aplicando todos os pontos do seu plano de análise.';

  @override
  String get ajouterTradePlanFeedbackBravo =>
      'Muito bem! Você seguiu seu plano de análise completamente.';

  @override
  String get ajouterTradePlanFeedbackWhichMissed =>
      'Quais partes do seu plano de análise você não seguiu?';

  @override
  String get ajouterTradePlanClosedLabel100 => 'Ótimo, plano seguido';

  @override
  String get ajouterTradePlanClosedLabelLow => 'Comentários e sugestões';

  @override
  String get ajouterTradeChecklistFeedbackAlmost100 =>
      'Você está perto de 100%: continue aplicando todos os pontos da sua lista de verificação.';

  @override
  String get ajouterTradeChecklistFeedbackBravo =>
      'Muito bem! Você seguiu sua lista de verificação completamente.';

  @override
  String get ajouterTradeChecklistFeedbackWhichMissed =>
      'Quais partes da sua lista de verificação você não seguiu?';

  @override
  String get ajouterTradeChecklistClosedLabel100 => 'Ótimo, checklist seguido';

  @override
  String get ajouterTradeChecklistClosedLabelLow => 'Checklist';

  @override
  String get ajouterTradeEtatFeelingPrompt => 'Que sentimentos surgiram?';

  @override
  String get ajouterTradeEtatFeedbackAlmost100 =>
      'Você está perto de 100%: continue aplicando todos os pontos.';

  @override
  String get ajouterTradeEtatClosedLabel100 => 'Sim, é difícil. Muito bem!';

  @override
  String get ajouterTradeEtatClosedLabelLow => 'Estado do momento';

  @override
  String get ajouterTradeEtatHeaderMoment => 'Seu Estado';

  @override
  String get ajouterTradeEtatHeaderEmotions => 'EMOÇÕES';

  @override
  String get ajouterTradeScreenshotLoadError =>
      'Não foi possível mostrar a imagem selecionada';

  @override
  String get ajouterTradeScreenshotChangeImage => 'Trocar Imagem';

  @override
  String get ajouterTradeScreenshotTapToAdd =>
      'Toque para adicionar uma imagem';

  @override
  String get ajouterTradeScreenshotRemove => 'Remover';

  @override
  String get ajouterTradePlanRowBias => 'Viés';

  @override
  String get ajouterTradePlanRowTimeframeHtf => 'Prazo HTF';

  @override
  String get ajouterTradePlanRowPhase => 'Fase';

  @override
  String get ajouterTradePlanRowNotes => 'Notas';

  @override
  String get ajouterTradePlanRowLastPoint => 'ponto de swing';

  @override
  String ajouterTradePlanRowExtraSupport(int n) {
    return 'Apoios extras';
  }

  @override
  String ajouterTradePlanRowExtraResistance(int n) {
    return 'Resistência extra $n';
  }

  @override
  String get ajouterTradePlanRowOutils => 'Ferramentas';

  @override
  String get ajouterTradePlanRowLiquidity => 'Liquidez';

  @override
  String get ajouterTradePlanRowFibPrice => 'Preço Fib';

  @override
  String get ajouterTradePlanSectionVolume => 'VOLUME';

  @override
  String get analyseAddField => '+ Adicionar campo';

  @override
  String get analyseAddPhaseTitle => 'Adicionar fase';

  @override
  String get analyseAddResist => '+ Adicionar resistência';

  @override
  String get analyseAddShort => '+ Adicionar';

  @override
  String get analyseAddSupport => 'Apoiar';

  @override
  String get analyseAddTimeframeTitle => 'Adicionar prazo';

  @override
  String get analyseAddTimeframeCustomEntry => 'Outro (texto livre)';

  @override
  String get analyseAddTimeframeSectionRestore => 'Reativar';

  @override
  String get analyseAddTimeframeSectionIntraday => 'Intraday';

  @override
  String get analyseAddTimeframeSectionSwing => 'Swing e posição';

  @override
  String get analyseAddTrendTitle => 'Adicionar tendência';

  @override
  String get analyseReportScreenshotSectionTitle => 'SCREENSHOT';

  @override
  String get analyseReportScreenshotAddCapture =>
      'Adicionar Captura de tela/ Screenshot';

  @override
  String get analyseReportScreenshotChooseImage => 'Escolha uma imagem';

  @override
  String get analyseReportScreenshotSubtitleWeb => 'Arquivo de Imagem';

  @override
  String get analyseReportScreenshotSubtitleFilePicker =>
      'Galeria ou explorador de arquivos';

  @override
  String get analyseReportScreenshotCamera => 'Câmera';

  @override
  String get analyseReportScreenshotHintWithCamera =>
      'Arquivo, galeria ou câmera';

  @override
  String get analyseReportScreenshotHintNoCamera =>
      'Escolha uma imagem neste dispositivo';

  @override
  String get analyseReportScreenshotErrorPlugin =>
      'A seleção de imagens não está disponível neste destino. Use \"Escolher uma imagem\" ou reconstrua o aplicativo (flutter clean / run).';

  @override
  String get analyseReportScreenshotErrorGeneric =>
      'Não foi possível adicionar a captura de tela.';

  @override
  String get analyseCardIndicators => 'Indicadores';

  @override
  String get analyseCardSmcLiquidity => 'SMC & Liquidez';

  @override
  String get analyseCardVolumeProfile => 'Perfil de Volume';

  @override
  String get analysePageHeroTitle => 'Minha análise';

  @override
  String get analysePageHeroSubtitle =>
      'Gira as suas análises e estratégias em tempo real.';

  @override
  String get analyseSidebarConfidenceSummary => 'RESUMO';

  @override
  String get analyseSidebarConfidenceLabel => 'confiança global';

  @override
  String get analyseSidebarReportHint =>
      'O relatório será guardado no histórico com o ativo associado.';

  @override
  String get analyseSidebarPreviewStyle => 'PRÉ-VISUALIZAÇÃO DO ESTILO';

  @override
  String get analyseConfidenceHigh => 'Alta';

  @override
  String get analyseConfidenceLevelTitle => 'Nível de confiança';

  @override
  String get analyseConfidenceLow => 'Normal';

  @override
  String analyseCopyLabel(String label) {
    return 'Copiar';
  }

  @override
  String analyseCopyNumber(int n) {
    return 'Copiar';
  }

  @override
  String get analyseCurrentMarketPhase => 'FASE ATUAL DO MERCADO';

  @override
  String get analyseCurrentTrend => 'TENDÊNCIA ATUAL';

  @override
  String get analyseDeleteTemplateTitle => 'Excluir Tema';

  @override
  String get analyseDirectionLabel => 'DIREÇÃO';

  @override
  String get analyseDraftLabelHint => 'Etiqueta';

  @override
  String get analyseExtraBroken => 'Quebrado';

  @override
  String get analyseExtraHeld => 'Realizado';

  @override
  String get analyseExtraPriceHint => 'Preço';

  @override
  String get analyseFeuillePlanTitle => 'FICHA DE PLANO DE NEGOCIAÇÃO';

  @override
  String get analyseFibLevel => 'EMA, Nível de Fibonacci,';

  @override
  String get analyseFibShort => 'Fibonacci';

  @override
  String get analyseFreeFields => 'CAMPOS LIVRES';

  @override
  String get analyseFvg => 'DIFERENÇA DE VALOR JUSTO (FVG)';

  @override
  String get analyseHintActifExamples => 'por exemplo, NASDAQ, EUR/USD...';

  @override
  String get analyseHintDetailsDots => 'Detalhes…';

  @override
  String get analyseHintHtfChipExample => 'Ex: Semanal';

  @override
  String get analyseHintImbalance => 'Desequilíbrio,';

  @override
  String get analyseHintNotesDots => 'Explicativas';

  @override
  String get analyseHintPriceDots => 'Preço';

  @override
  String get analyseHintStops =>
      'Onde estão as paradas? (por exemplo, Buy Side)';

  @override
  String get analyseHintTextDots => 'Text…';

  @override
  String get analyseHintTfExamples => 'por exemplo, MN, 3D...';

  @override
  String get analyseHintZoneHtf => 'Zona HTF…';

  @override
  String get analyseHtfTimeframe => 'PRAZO DE ANÁLISE (HTF)';

  @override
  String get analyseImpactFeuille => 'Impacto da folha';

  @override
  String get analyseImpactIndicators => 'Impacto dos indicadores';

  @override
  String analyseImpactLine(int percent) {
    return 'Impacto';
  }

  @override
  String get analyseImpactModalBlurb =>
      'Os quatro impactos compartilham 100% no total. Mover este controle deslizante ajusta os outros proporcionalmente.';

  @override
  String get analyseImpactModalTitle => 'Ajustar impacto';

  @override
  String get analyseImpactShort => 'Impacto';

  @override
  String get analyseImpactSmc => 'Impacto SMC';

  @override
  String get analyseLastPointHint => 'Último Ponto';

  @override
  String get analyseLiquidityPools => 'Pools de liquidez';

  @override
  String get analyseMovementDetailsHint => 'Detalhes do movimento';

  @override
  String get analyseNameFieldHint => 'Nome da análise...';

  @override
  String get analyseNameFieldLabel => 'Nome da análise';

  @override
  String get analyseNoTemplatesSaved => 'Nenhum modelo salvo';

  @override
  String get analyseNote => 'NOTA';

  @override
  String get analyseNotesIndicators => 'NOTAS (INDICADORES)';

  @override
  String get analyseNotesSmcExample =>
      'por exemplo, Liquidity grab before FVG...';

  @override
  String get analyseNotesSmcLiq => 'NOTAS (SMC E LIQUIDEZ)';

  @override
  String get analyseNotesVolumeProfile => 'NOTAS (PERFIL DE VOLUME)';

  @override
  String get analyseOrderBlock => 'BLOCO DE PEDIDO (OB)';

  @override
  String get analysePhase => 'FASE';

  @override
  String get analyseReportCellFvg => 'FVG';

  @override
  String get analyseReportCellLiqPools => 'PISCINAS LIQ.';

  @override
  String get analyseReportCellOrderBlock => 'Seu bloco de pedido';

  @override
  String get analyseResistLower => 'Resistência';

  @override
  String get analyseResistShort => 'RESIST';

  @override
  String get analyseSetup => 'CONFIGURAÇÃO';

  @override
  String get analyseSideBuy => 'Comprar';

  @override
  String get analyseSideSell => 'Venda';

  @override
  String get analyseSideWatch => 'Acompanhar';

  @override
  String get analyseSmcAdds => 'SMC ADICIONA';

  @override
  String get analyseStructTagResist => 'R';

  @override
  String get analyseStructTagSupport => 'S';

  @override
  String get analyseStructure => 'ESTRUTURAR';

  @override
  String get analyseStructureSectionTitle => 'Estrutura';

  @override
  String get analyseSupport => 'SUPORTE';

  @override
  String get analyseSupportLower => 'Suporte';

  @override
  String analyseTemplateApplied(String name) {
    return 'Modelo “$name” aplicado';
  }

  @override
  String get analyseTemplateNameHint => 'Novo Nome';

  @override
  String get analyseTemplateRenameDialogTitle => 'Modelo de renomear';

  @override
  String get analyseTemplateSaveDialogTitle => 'Nome do modelo';

  @override
  String get analyseTemplateStyleHint => 'por exemplo, swing, scalping...';

  @override
  String get analyseTestedTwice => 'Testado x 2';

  @override
  String get analyseTimeframeLabelShort => 'PERIODICIDADE';

  @override
  String get analyseTooltipPickTemplate => 'Escolha um modelo salvo';

  @override
  String get analyseTooltipSaveTemplatePills =>
      'Poupe comprimidos com um nome (o seu hábito)';

  @override
  String get analyseTrend => 'TENDÊNCIA';

  @override
  String get analyseTrendLabel => 'Tendência';

  @override
  String get analyseVolumePoc => 'POC';

  @override
  String get analyseVolumeProfile => 'Perfil de Volume';

  @override
  String get analyseVolumeProfileDefaultLabel => 'Perfil de Volume';

  @override
  String get analyseVolumeVah => 'VAH';

  @override
  String get analyseVolumeVal => 'VAL';

  @override
  String get analyseVolumeZoneFrom => 'De';

  @override
  String get analyseVolumeZoneLabel => 'Zona';

  @override
  String get analyseVolumeZoneTo => 'Até';

  @override
  String get appBrandName => 'PAYCHEK';

  @override
  String get buttonCalculate => 'Calcular';

  @override
  String get calAmountLabel => 'Valor';

  @override
  String get calMonthlyObjectiveTitle => 'Objetivo mensal';

  @override
  String get calPageTitle => 'Calendário';

  @override
  String get calObjectiveLabel => 'Objetivo';

  @override
  String get calCumulativePerformanceTitle => 'Desempenho cumulativo';

  @override
  String get calBestDay => 'Melhor dia';

  @override
  String get calTradingDays => 'Dias de negociação';

  @override
  String get calAverageShort => 'Média';

  @override
  String get calPnlShort => 'P&L';

  @override
  String get calCapitalChangePct => '% do capital social';

  @override
  String get calAveragePerDay => 'Média/Dia';

  @override
  String get calObjectiveShort => 'Objetivo';

  @override
  String calChartError(String message) {
    return 'Erro \$<x id=\"0\"/>:';
  }

  @override
  String calDayTradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operações',
      one: '1 operação',
      zero: 'Nenhuma operação',
    );
    return '$_temp0';
  }

  @override
  String get monthJanuary => 'Janeiro';

  @override
  String get monthFebruary => 'Fevereiro';

  @override
  String get monthMarch => 'Março';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Maio';

  @override
  String get monthJune => 'Junho';

  @override
  String get monthJuly => 'Julho';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Setembro';

  @override
  String get monthOctober => 'Outubro';

  @override
  String get monthNovember => 'Novembro';

  @override
  String get monthDecember => 'Dezembro';

  @override
  String get monthAbbrJanuary => 'Jan';

  @override
  String get monthAbbrFebruary => 'Fev';

  @override
  String get monthAbbrMarch => 'Mar';

  @override
  String get monthAbbrApril => 'Abr';

  @override
  String get monthAbbrMay => 'Maio';

  @override
  String get monthAbbrJune => 'Jun';

  @override
  String get monthAbbrJuly => 'Jul';

  @override
  String get monthAbbrAugust => 'Ago';

  @override
  String get monthAbbrSeptember => 'Set';

  @override
  String get monthAbbrOctober => 'Out';

  @override
  String get monthAbbrNovember => 'Nov';

  @override
  String get monthAbbrDecember => 'Dez';

  @override
  String get calcBestBalance => 'Melhor saldo';

  @override
  String get calcEndBalance => 'Saldos finais';

  @override
  String get calcEquityCurveTitle =>
      'Gráfico da curva de retorno da negociação';

  @override
  String get calcLabelEntry => 'Preço de entrada';

  @override
  String get calcLabelRiskShort => 'Risco';

  @override
  String get calcLabelSl => 'Limite de perdas (stop loss)';

  @override
  String get calcLabelStartBalance => 'Saldo inicial';

  @override
  String get calcLabelTp => 'Take profit';

  @override
  String get calcLabelTradesShort => 'Operações';

  @override
  String get calcLabelWinRateShort => 'Acerto';

  @override
  String get calcLoss => 'Derrota';

  @override
  String get calcMaxDrawdown => 'Drawdown Máximo';

  @override
  String get calcProfitFactor => 'Fator de lucro';

  @override
  String get calcRatioSectionTitle => 'Proporção';

  @override
  String get calcResult => 'Resultado';

  @override
  String get calcResultOfCalculation => 'Resultado da apuração';

  @override
  String get calcRowGain => 'Ganho: ';

  @override
  String get calcRowSl => 'Assunto:';

  @override
  String get calcRowVsCapital => 'Vs capital';

  @override
  String get calcSettingsTitle => 'Configurações';

  @override
  String get calcTotalGainLabel => 'Ganho total';

  @override
  String get calcTradeReturnTableTitle => 'Resultados retorno DA negociação';

  @override
  String get calcWin => 'Vitória';

  @override
  String get calcWinsLosses => 'Ganhos / Perdas';

  @override
  String get calcErrorInvalidBalance => 'Saldo inicial inválido.';

  @override
  String get calcErrorTradesRange =>
      'O número de negociações deve estar entre 1 e 2000.';

  @override
  String get calcErrorWinRateRange =>
      'A taxa de vitória deve estar entre 0 e 100.';

  @override
  String get calcErrorRiskRange => 'O risco (%) deve estar entre 0 e 100.';

  @override
  String get calcErrorInvalidRiskReward => 'Risk:Reward inválido.';

  @override
  String get calcErrorInvalidLot => 'Lote inválido.';

  @override
  String get calcErrorInvalidEntry => 'Preço de entrada inválido.';

  @override
  String get calcErrorInvalidSl => 'Stop loss inválido.';

  @override
  String get calcErrorInvalidTp => 'Take profit inválido.';

  @override
  String get calcErrorEntrySlIdentical =>
      'Entrada e SL não podem ser idênticos.';

  @override
  String get calcDisclaimerEstimates =>
      'Atenção: estes cálculos não são valores contratuais. Servem apenas como referência.';

  @override
  String get calcHeaderSubtitleEstimates =>
      'Simulações de rendimento e ratio — valores indicativos.';

  @override
  String get calcMarketIndex => 'Índice';

  @override
  String get calcMarketFutures => 'Futuro';

  @override
  String get calcMarketStock => 'Ação';

  @override
  String get calcMarketCommodities => 'Matérias-primas';

  @override
  String get calcWorstBalance => 'Pior saldo';

  @override
  String get calculateRatio => 'Calcular razão';

  @override
  String get cancel => 'Cancelar';

  @override
  String get capitalAmountLabel => 'Montante de capital';

  @override
  String get capitalCurrencyTitle => 'Moeda';

  @override
  String get capitalEllipsis => '…';

  @override
  String get capitalHintAmount => 'por exemplo, 10 450';

  @override
  String get capitalInitialTitle => 'Capital inicial';

  @override
  String get capitalLabel => 'Capital';

  @override
  String get capitalOther => 'outros';

  @override
  String get capitalTooltip => 'Capital e moeda (conta principal)';

  @override
  String get checklistAddSection => 'Adicionar uma secção';

  @override
  String get checklistDefaultNewSection => 'NOVA SEÇÃO';

  @override
  String get checklistDeleteSectionBody =>
      'Esta ação é permanente para esta seção.';

  @override
  String get checklistDeleteSectionTitle => 'Remove seção';

  @override
  String get checklistEditSectionHint => 'Título';

  @override
  String get checklistIntroBody =>
      'Antes de assumir uma posição, certifique-se de validar todos os critérios do seu plano de negociação.';

  @override
  String get checklistDailyCalendarTitle => 'CHECKLIST POR DIA';

  @override
  String get checklistDailyUncheckedTitle => 'NÃO MARCADOS';

  @override
  String get checklistDailyUncheckedNoActivity =>
      'Nenhuma atividade neste dia.';

  @override
  String get checklistDailyUncheckedNoDue =>
      'Nenhum critério previsto para este dia.';

  @override
  String get checklistDailyUncheckedAllDone =>
      'Todos os critérios do dia estão marcados.';

  @override
  String get checklistDailyUncheckedNoHistory =>
      'Nenhum detalhe da checklist foi guardado para este dia. O acompanhamento de critérios não marcados está disponível a partir de hoje.';

  @override
  String get checklistItemNews1 =>
      'Calendário económico consultado (FED, CPI, NFP, PIB…).';

  @override
  String get checklistItemNews2 => 'FOMC / FED: sem trade durante o anúncio.';

  @override
  String get checklistItemNews3 => 'CPI (inflação): hora e impacto previstos.';

  @override
  String get checklistItemNews4 =>
      'NFP (emprego EUA): janela de risco identificada.';

  @override
  String get checklistItemAnalyse1 =>
      'A tendência de fundo (HTF) se alinha à minha ideia.';

  @override
  String get checklistItemAnalyse2 =>
      'O preço está em uma zona-chave (Suporte/Resistência, Bloco de Pedidos).';

  @override
  String get checklistItemAnalyse3 =>
      'Tenho uma confirmação de entrada clara (Padrão, Divergência).';

  @override
  String get checklistItemHint => 'Inserir critério';

  @override
  String get checklistItemPsy1 =>
      'Eu negocio com uma mentalidade neutra (sem negociação de vingança).';

  @override
  String get checklistItemPsy2 => 'Aceito a perda potencial antes de entrar.';

  @override
  String get checklistItemPsy3 =>
      'Eu mantenho meu plano mesmo depois de uma série de perdas.';

  @override
  String get checklistItemRisque1 =>
      'Meu stop loss é definido tecnicamente (não aleatoriamente).';

  @override
  String get checklistItemRisque2 => 'O risco não excede 1% do meu capital.';

  @override
  String get checklistItemRisque3 =>
      'A relação risco/recompensa é de pelo menos 1:2.';

  @override
  String get checklistMenuEdit => 'Editar';

  @override
  String get checklistSectionToggleOn => 'Ativar seção';

  @override
  String get checklistSectionToggleOff => 'Desativar seção';

  @override
  String get checklistPageTitle => 'Checklist';

  @override
  String get checklistProgressCl => 'CL';

  @override
  String get checklistSectionNews => 'NEWS · CALENDÁRIO ECONÓMICO';

  @override
  String get checklistSectionAnalyse => 'ANÁLISE TÉCNICA';

  @override
  String get checklistSectionPsy => 'PSICOLOGIA';

  @override
  String get checklistSectionRisque => 'GESTÃO DE RISCOS';

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
  String get clearAll => 'Limpar Tudo';

  @override
  String get confirm => 'Confirmar';

  @override
  String get currencyNameHint => 'por exemplo, CHF, XOF';

  @override
  String get currencyNameLabel => 'Nome da Moeda';

  @override
  String get customCurrencyTitle => 'Outra moeda';

  @override
  String get dashboardAiAnalyze => 'Analise';

  @override
  String get dashboardAiCoachBody =>
      'Toque em « Analisar » para que a IA reveja as suas estatísticas semanais (Taxa de vitórias, Horas, Fatores) e gere aconselhamento psicológico personalizado.';

  @override
  String get dashboardAiCoachTitle => 'PAYCHEK AI COACH';

  @override
  String get dashboardAnalyseShortcutTitle => 'Minha análise';

  @override
  String get dashboardBestTradeLabel => 'Melhor negociação';

  @override
  String get dashboardCapitalBalanceHeader => 'Saldo de Capital';

  @override
  String get dashboardCapitalEvolutionTitle => 'EVOLUÇÃO DO CAPITAL';

  @override
  String get dashboardChecklistHeading => 'LISTA DE VERIFICAÇÕES';

  @override
  String get dashboardChecklistSeeRest => 'Mais >';

  @override
  String get dashboardChecklistAllDoneBravo => 'Bom trade.';

  @override
  String get dashboardMyStateSection => 'Meu estado';

  @override
  String get dashboardOpenStrategyTooltip => 'Abrir Minha Estratégia';

  @override
  String dashboardPerfHourWinRate(int percent) {
    return 'WR';
  }

  @override
  String get dashboardPerfHoursRow1 => '09:00 - 11:30 (Início)';

  @override
  String get dashboardPerfHoursRow2 => '14:30 - 16:30 (US Open)';

  @override
  String get dashboardPerfHoursRow3 => '19:00+ (Noite)';

  @override
  String get dashboardPerfHoursTitle => 'HORAS DE DESEMPENHO';

  @override
  String get dashboardRingState => 'UF';

  @override
  String get dashboardRingWin => 'GANHAR';

  @override
  String get dashboardSuccessFactorSample => 'Esporte antes da sessão';

  @override
  String get dashboardSuccessFactorsSubtitle =>
      'Acompanhe como seus hábitos afetam sua taxa de vitórias.';

  @override
  String get dashboardSuccessFactorsTitle => 'Fatores de sucesso ';

  @override
  String get dashboardTfAll => 'TODOS';

  @override
  String get dashboardTfDay => 'Leitor de código de barras com fio 1D';

  @override
  String get dashboardTfMonth => '1M';

  @override
  String get dashboardTfWeek => '1W';

  @override
  String dashboardTradeCount(int count) {
    return '$count negociações';
  }

  @override
  String get dashboardTradeOne => '1 negociação';

  @override
  String dashboardEvolutionTradesThisPeriod(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count negociações neste período',
      one: '1 negociação neste período',
      zero: '0 negociações neste período',
    );
    return '$_temp0';
  }

  @override
  String get dashboardEvolutionSparklineHoverOrigin => 'Abertura do acumulado';

  @override
  String get dashboardEvolutionSparklineHoverNoTrade =>
      'Sem negociações neste patamar';

  @override
  String dashboardEvolutionSparklineHoverMore(int count) {
    return '+$count outras';
  }

  @override
  String get dashboardEvolutionSparklineTapHint => 'Toque para abrir';

  @override
  String get dashboardWeekResultPrefix => 'Resultado:';

  @override
  String get dashboardWeekThisWeek => 'DA SEMANA';

  @override
  String get dashboardWeekdayShortFri => 'SEX';

  @override
  String get dashboardWeekdayShortMon => 'SEG';

  @override
  String get dashboardWeekdayShortSat => 'SAT';

  @override
  String get dashboardWeekdayShortSun => 'DOM';

  @override
  String get dashboardWeekdayShortThu => 'QUI';

  @override
  String get dashboardWeekdayShortTue => 'TER';

  @override
  String get dashboardWeekdayShortWed => 'QUA';

  @override
  String get dashboardWorstLossLabel => 'Pior perda';

  @override
  String get delete => 'Excluir';

  @override
  String deletePortfolioTitle(String name) {
    return 'Eliminar \"$name\"?';
  }

  @override
  String get deleteTooltip => 'Excluir';

  @override
  String get editPortfolioTooltip => 'Editar nome, capital, moeda';

  @override
  String get errorAmount => 'Você deve inserir um valor válido';

  @override
  String get errorInvalidAmount => 'Valor ou moeda inválidos.';

  @override
  String get errorNameOrSymbol => 'Insira pelo menos um nome ou um símbolo.';

  @override
  String get exportPdfFailed => 'Não foi possível exportar o PDF.';

  @override
  String exportPdfFailedWithError(String error) {
    return 'Não foi possível exportar PDF: $error';
  }

  @override
  String get exportPdfUnavailable =>
      'Exportação de PDF cancelada ou indisponível.';

  @override
  String get homePerformance => 'Aproveitamento';

  @override
  String get webHomeHeroSubtitle =>
      'Bem-vindo — aqui está o seu desempenho semanal';

  @override
  String webHomeHeroWelcome(Object fullName) {
    return 'Bem-vindo, $fullName';
  }

  @override
  String get webHomeLiveTerminal => 'Terminal ao vivo';

  @override
  String get webHomeWelcomeBack => 'Bem-vindo de volta,';

  @override
  String get webHomeUpgradeUnlockSubtitle =>
      'Desbloqueie dados institucionais em tempo real';

  @override
  String get webRailMenuHeading => 'Menu';

  @override
  String get labelActif => 'Ativo';

  @override
  String get labelGain => 'P&L';

  @override
  String get labelLot => 'LOT';

  @override
  String get labelMarket => 'MERCADO';

  @override
  String get labelPrice => 'PREÇO';

  @override
  String get labelRiskPct => 'RISCO';

  @override
  String get labelSuggestedSize => 'Tamanho sugerido';

  @override
  String get langChineseTraditional => '中文 （繁體';

  @override
  String get langEnglish => 'Inglês';

  @override
  String get langFrench => 'Francês';

  @override
  String get langGerman => 'Alemão';

  @override
  String get langItalian => 'Italiano ';

  @override
  String get langKorean => '한국어';

  @override
  String get langPortuguese => 'Português';

  @override
  String get langSpanish => 'Español';

  @override
  String get languageDialogSubtitle => 'Idioma da interface.';

  @override
  String get languageDialogTitle => 'Escolher idioma';

  @override
  String get languageSection => 'Idioma';

  @override
  String get onboardingLanguageContinue => 'Continuar';

  @override
  String get mentalBad => 'Mal';

  @override
  String get mentalConfidence => 'Confiança';

  @override
  String get mentalEmotionFieldLabel =>
      'Nome da emoção (por exemplo, Calmo, Medroso)';

  @override
  String get mentalEmotional => 'Emocional';

  @override
  String get mentalEnergy => 'Energia';

  @override
  String get mentalExcited => 'Empolgada(o) ';

  @override
  String get mentalFocus => 'Foco';

  @override
  String get mentalFrustrated => 'Decepcionado';

  @override
  String get mentalHappy => 'Feliz';

  @override
  String get mentalHintEmotion => 'por exemplo, calmo, medroso';

  @override
  String get mentalHintMetric => 'por exemplo, Paciência, Estresse';

  @override
  String get mentalHintRoutine => 'por exemplo, esporte, leitura';

  @override
  String get mentalMarketStudy => 'MARKET STUDY ';

  @override
  String get mentalMeditation => 'Meditação (10 min)';

  @override
  String get mentalMetricFieldLabel =>
      'Nome da métrica (por exemplo, Paciência, Estresse)';

  @override
  String get mentalNegative => 'Negative (-)';

  @override
  String get mentalNeutral => 'Não concordo nem discordo';

  @override
  String get mentalNewEmotion => 'Nova emoção';

  @override
  String get mentalNewMetric => 'Nova Métrica:';

  @override
  String get mentalNewRoutine => 'Nova rotina?';

  @override
  String get mentalPeakForm => 'Forma de pico';

  @override
  String get mentalPositive => 'Positive (+)';

  @override
  String get mentalRestTitle => 'REST';

  @override
  String get mentalRiskAppetite => 'Medo';

  @override
  String get mentalRoutineFieldLabel =>
      'Nome da rotina (por exemplo, esporte, leitura)';

  @override
  String get mentalDayDetailTitle => 'CRITÉRIOS DO DIA';

  @override
  String get mentalDayDetailNoData =>
      'Sem dados para este dia. Atualize o seu estado mental para guardar.';

  @override
  String get mentalDayDetailGlobalScore => 'PONTUAÇÃO GLOBAL';

  @override
  String get mentalGlobalScoreCalendarTitle => 'PONTUAÇÃO GLOBAL POR DIA';

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
  String get mentalSleepEnough => 'Dormiu o suficiente';

  @override
  String mentalSleepImpact(int percent) {
    return 'Impacto';
  }

  @override
  String get mentalSport => 'Esporte / corrida';

  @override
  String get mentalTired => 'Cansado';

  @override
  String get mentalWeightGlobalImpact => 'Impacto Global';

  @override
  String get mentalWeightModalBlurb =>
      'Ajuste a importância desse critério. Use o multiplicador ou defina a porcentagem desejada diretamente.';

  @override
  String get mentalWeightModalTitle => 'Ajustar impacto';

  @override
  String get mentalWeightNatureLabel => 'Natureza do impacto ';

  @override
  String get mentalWeightPolarityHelpNegative =>
      'Um valor alto para este critério DIMINUIRÁ sua pontuação global.';

  @override
  String get mentalWeightPolarityHelpPositive =>
      'Um valor alto para este critério AUMENTARÁ sua pontuação global.';

  @override
  String get mentalPageTitle => 'Estado mental';

  @override
  String get mentalPageIntro =>
      'Avalie seu estado mental. Personalize o impacto (peso) de cada critério para corresponder ao seu perfil.';

  @override
  String get mentalGaugeStateLabel => 'UF';

  @override
  String mentalGaugeBasedOnIndicators(int count) {
    return 'Com base em $count indicadores';
  }

  @override
  String get mentalGaugeStatusStable => 'Equilíbrio sólido';

  @override
  String get mentalGaugeStatusFragile => 'Precisa de atenção';

  @override
  String get mentalSectionRoutinesHeading => 'MINHAS ROTINAS';

  @override
  String get mentalSectionMomentHeading => 'ESTADO DO MOMENTO';

  @override
  String get mentalSectionEmotionHeading => 'EMOÇÕES';

  @override
  String modelSavedSnackbar(String name) {
    return 'Modelo \"$name\" guardado';
  }

  @override
  String get navAdd => 'Adicionar';

  @override
  String get navCalendar => 'Calendário';

  @override
  String get navDashboard => 'Painel';

  @override
  String get navMore => 'Maior';

  @override
  String get navTrade => 'Comércio';

  @override
  String get tradePageIntro => 'Diário, filtros e registros de trades.';

  @override
  String get ok => 'OK';

  @override
  String get perf0Sub => 'Impacto do estresse e da fadiga na taxa de vitórias';

  @override
  String get perf0Title => 'Psicologia: Emoções e sono';

  @override
  String get perf1Sub => 'Análise de rentabilidade (Seg-Dom)';

  @override
  String get perf1Title => 'Dias da semana';

  @override
  String get perf2Sub => 'Encontre as suas horas mais rentáveis';

  @override
  String get perf2Title => 'Horas da sessão';

  @override
  String get perf3Sub => 'Taxa de sucesso deste padrão de gráfico';

  @override
  String get perf3Title => 'Padrão: Duplo superior / inferior';

  @override
  String get perf4Sub => 'Análise de reversão principal';

  @override
  String get perf4Title => 'Padrão: Cabeça e ombros';

  @override
  String get perf5Sub => 'Validação do sinal de sobrecompra/sobrevenda';

  @override
  String get perf5Title => 'Indicador: Divergência do RSI';

  @override
  String get perf6Sub => 'Eficácia do cruzamento da média móvel';

  @override
  String get perf6Title => 'Indicador: cruzamento MACD';

  @override
  String get perf7Sub => 'Salta nos níveis 0,618 e 0,5';

  @override
  String get perf7Title => 'Indicador: Retração de Fibonacci';

  @override
  String get perf8Sub => 'Blocos de ordens e análise de liquidez';

  @override
  String get perf8Title => 'Estratégia: Conceito de Dinheiro Inteligente (SMC)';

  @override
  String get perf9Sub => 'Impacto do risco financeiro na taxa de ganhos';

  @override
  String get perf9Title => 'Volume e tamanho do lote';

  @override
  String get perfAddWidgetButton => 'Adicionar widget';

  @override
  String get perfChartBar => 'Gráfico de barras';

  @override
  String get perfChartHBar => 'Barras horizontais';

  @override
  String get perfChartHintBar =>
      'Ideal para comparação (por exemplo, dias úteis)';

  @override
  String get perfChartHintHBar => 'Formato de lista, simples e limpo';

  @override
  String get perfChartHintLine => 'Para ver uma tendência ao longo do tempo';

  @override
  String get perfChartHintPie => 'Para uma porcentagem geral';

  @override
  String get perfChartLine => 'Gráfico de linhas';

  @override
  String get perfChartPie => 'Círculo / medidor';

  @override
  String get perfCustomizeIntro => 'Personalize sua página de Desempenho.';

  @override
  String get perfDataFootnoteDuration =>
      'Dados: discriminação por duração da posição (CSV).';

  @override
  String get perfDataFootnoteVolume =>
      'Proxy de volume: buckets por |lucro| (CSV).';

  @override
  String get perfEmptyChart =>
      'Importe ou carregue negociações (CSV) para exibir o gráfico.';

  @override
  String get perfLineChartCaption =>
      'Linha: lucro acumulado (ordem cronológica, CSV).';

  @override
  String get perfNewWidgetTitle => 'Novo widget';

  @override
  String get perfNoResults => 'Nenhuma opção encontrada.';

  @override
  String get perfPieChartCaption =>
      'Fatias = volume de negociação por categoria; % em disco = participação do total.';

  @override
  String get perfRemoveWidgetTooltip => 'Remover Widget';

  @override
  String get perfSearchHint => 'Pesquisa (por exemplo, padrão, psicologia...)';

  @override
  String get perfStep1Title => '1. O que você deseja analisar?';

  @override
  String get perfStep2Title => '2. Tipo de gráfico';

  @override
  String get plusAdd => 'Adicionar';

  @override
  String get plusCalculator => 'Calculadora';

  @override
  String get plusCalendar => 'Calendário';

  @override
  String get plusChecklist => 'Checklist';

  @override
  String get plusDashboard => 'Painel';

  @override
  String get plusMentalState => 'Estado mental';

  @override
  String get plusMyAnalysis => 'Minha análise';

  @override
  String get plusMyStrategy => 'Minha estratégia';

  @override
  String get plusPerformance => 'Aproveitamento';

  @override
  String get plusSettings => 'Configurações';

  @override
  String get plusTrade => 'Comércio';

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
      'Insira um nome de portfólio (por exemplo, corretor).';

  @override
  String get portfoliosLabel => 'Portfólios';

  @override
  String get q1Slogan => 'Escolha a sua abordagem';

  @override
  String get q1Title => 'Que tipo de trader você é?';

  @override
  String get q1o1s => 'Posições de segundos a alguns minutos';

  @override
  String get q1o1t => 'Scalping';

  @override
  String get q1o2s =>
      'Todas as posições são fechadas antes do término da sessão';

  @override
  String get q1o2t => 'Day trading';

  @override
  String get q1o3s => 'Posições mantidas entre 1 e 3 dias';

  @override
  String get q1o3t => 'Intradiário';

  @override
  String get q1o4s => 'Posições mantidas ao longo de vários dias ou semanas';

  @override
  String get q1o4t => 'Swing';

  @override
  String get q2Slogan => 'Onde você está em sua jornada?';

  @override
  String get q2Title => 'Perfil de experiência';

  @override
  String get q2o1s => 'Você não está sozinho';

  @override
  String get q2o1s2 =>
      'Para traders que estão começando e ainda procurando seu método';

  @override
  String get q2o1t => 'Eu não tenho uma estratégia';

  @override
  String get q2o2s => 'Luz ao fim do túnel';

  @override
  String get q2o2s2 => 'Para aqueles com o básico que querem consistência';

  @override
  String get q2o2t => 'Eu tenho minha estratégia';

  @override
  String get q2o3s => 'A parte mais difícil ficou para trás';

  @override
  String get q2o3s2 => 'Para traders experientes que dominam suas estatísticas';

  @override
  String get q2o3t => 'Alto desempenho';

  @override
  String get q3Slogan => 'Escolha a sua prioridade máxima';

  @override
  String get q3Title => 'O que você mais deseja melhorar?';

  @override
  String get q3o1s => 'Pare de ganhar um dia para perder tudo no dia seguinte.';

  @override
  String get q3o1s2 =>
      'Para estabilizar sua curva de equidade e evitar o elevador emocional.';

  @override
  String get q3o1t => 'SAIR DA MONTANHA-RUSSA';

  @override
  String get q3o2s => 'Melhore a taxa de acertos e a precisão das entradas.';

  @override
  String get q3o2s2 =>
      'Para quem quer ganhar mais vezes escolhendo melhor cada operação.';

  @override
  String get q3o2t => 'TORNE-SE UM SNIPER';

  @override
  String get q3o3s => 'Domine a disciplina e pare decisões emocionais.';

  @override
  String get q3o3s2 =>
      'Para eliminar o trading impulsivo e seguir seu plano 100%.';

  @override
  String get q3o3t => 'MANTENHA A FRIEZA';

  @override
  String get q3o4s =>
      'Entenda quais padrões gráficos funcionam de verdade para você.';

  @override
  String get q3o4s2 =>
      'Para identificar seus próprios padrões vencedores e virar especialista.';

  @override
  String get q3o4t => 'ENCONTRE A SUA ASSINATURA';

  @override
  String get q4Slogan => 'Identifique o que mais bloqueia você';

  @override
  String get q4Title => 'Qual é o seu maior desafio?';

  @override
  String get q4o1s => 'Medo de ficar de fora.';

  @override
  String get q4o1s2 => 'Rápido, vou perder a chance de lucrar!';

  @override
  String get q4o1t => 'FOMO';

  @override
  String get q4o2s => 'Seu coração substituiu seu cérebro.';

  @override
  String get q4o2s2 => 'De jeito nenhum — eu DEVO recuperar meu dinheiro!';

  @override
  String get q4o2t => 'TILT';

  @override
  String get q4o3s => 'Nenhuma estratégia ou plano claro.';

  @override
  String get q4o3s2 =>
      'Eu não sei bem, mas sinto que vai dar certo — vamos tentar.';

  @override
  String get q4o3t => 'OPERAR À CEGAS';

  @override
  String get q4o4s => 'Agitação constante.';

  @override
  String get q4o4s2 => 'Se eu não clicar, sinto que não estou trabalhando.';

  @override
  String get q4o4t => 'OVERTRADING';

  @override
  String get q4o5s => 'Achar que é invencível.';

  @override
  String get q4o5s2 => 'Eu sou demais — dinheiro fácil! Vou dobrar a aposta.';

  @override
  String get q4o5t => 'EXCESSO DE CONFIANÇA';

  @override
  String get q4o6s => 'Medo de tudo.';

  @override
  String get q4o6s2 => 'Não tenho certeza, tenho medo de perder de novo.';

  @override
  String get q4o6t => 'PARALISIA';

  @override
  String get q4o7s => 'Brincar com roleta russa.';

  @override
  String get q4o7s2 => 'Estou colocando tudo nesta operação — tudo ou nada.';

  @override
  String get q4o7t => 'SEM GESTÃO DE CAPITAL';

  @override
  String get reglagePortfolioSheetSubtitle => 'Capital e moeda da conta';

  @override
  String get reglagePortfolioSheetTitle => 'Capital e portfólios';

  @override
  String get resultDontWorry => 'Não se preocupe';

  @override
  String get resultHeaderSub =>
      'Este não é o seu perfil - é apenas um cálculo; nada é real ainda. Tudo começa agora.';

  @override
  String get resultLabelGlobal => 'Global';

  @override
  String get resultLabelProfil => 'Perfil';

  @override
  String get resultLabelPsychology => 'Psicologia';

  @override
  String get resultLabelStrategy => 'Estratégia';

  @override
  String resultStatBullet1(int percent) {
    return '$percent% dos traders nesse nível ficam estagnados ou perdem devido à falta de rigor matemático.';
  }

  @override
  String resultStatBullet2(int percent) {
    return '$percent% dos traders estão na mesma situação.';
  }

  @override
  String get resultStatBullet3 =>
      'Um trader com psicologia forte negocia melhor do que aquele que conhece 100 estratégias.';

  @override
  String get save => 'Salvar';

  @override
  String get screenshot => 'SCREENSHOT';

  @override
  String get accountPageTitle => 'Conta';

  @override
  String get mobileReconnectAfterLogoutTitle => 'Sessão terminada';

  @override
  String get mobileReconnectAfterLogoutBody =>
      'Inicia sessão novamente para recuperar o teu perfil na cloud e a tua subscrição. Também podes continuar a usar a app neste dispositivo sem conta.';

  @override
  String get mobileReconnectContinueWithoutAccount =>
      'Continuar sem iniciar sessão';

  @override
  String get profileViewDetailsSection => 'Dados do perfil';

  @override
  String get profileAccountStatusTitle => 'Estado da conta';

  @override
  String get profileAccountStatusPro => 'Pro';

  @override
  String get profileAccountStatusLite => 'Lite';

  @override
  String get profileTrialBadge => 'TESTE';

  @override
  String profileTrialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count dias de teste',
      one: 'Falta 1 dia de teste',
    );
    return '$_temp0';
  }

  @override
  String profileTrialEndsOn(String date) {
    return 'O teste termina em $date';
  }

  @override
  String profileTrialEndedOn(String date) {
    return 'O teste terminou em $date';
  }

  @override
  String profileProPeriodEndsOn(String date) {
    return 'Renovação em $date';
  }

  @override
  String get profileSubscribeButton =>
      'Passar ao Pro (a partir de 8,99 \$ / mês)';

  @override
  String get profileManageSubscriptionButton => 'Gerir subscrição';

  @override
  String get profileUpgradeLabel => 'Upgrade';

  @override
  String get profileEditSavedSnack => 'Perfil atualizado';

  @override
  String get profileEditIncompleteFieldsSnack =>
      'Preencha nome, sobrenome e e-mail';

  @override
  String get profileEditInvalidEmailSnack => 'Introduza um e-mail válido';

  @override
  String get accountChangePasswordButton => 'Alterar palavra-passe';

  @override
  String get accountChangePasswordDialogTitle => 'Alterar palavra-passe';

  @override
  String get accountChangePasswordCurrentLabel => 'Palavra-passe atual';

  @override
  String get accountChangePasswordNewLabel => 'Nova palavra-passe';

  @override
  String get accountChangePasswordConfirmLabel =>
      'Confirmar nova palavra-passe';

  @override
  String get accountChangePasswordCta => 'GUARDAR';

  @override
  String get accountChangePasswordSuccessSnack => 'Palavra-passe atualizada';

  @override
  String get accountChangePasswordCurrentMissing =>
      'Introduz a tua palavra-passe atual';

  @override
  String get accountChangePasswordRequiresRecentLogin =>
      'Por segurança, inicia sessão novamente e tenta outra vez.';

  @override
  String get accountChangePasswordForgotLink => 'Esqueceste a palavra-passe?';

  @override
  String get accountAuthSectionTitle => 'Entrar';

  @override
  String get accountContinueWith => 'Continuar com:';

  @override
  String get accountTabLogin => 'Entrar';

  @override
  String get accountTabSignup => 'Cadastro';

  @override
  String get accountFieldEmail => 'E-mail';

  @override
  String get accountFieldPassword => 'Senha';

  @override
  String get accountFieldConfirmPassword => 'Confirmar senha';

  @override
  String get accountFieldBirthDate => 'Data de nascimento';

  @override
  String get accountFieldFirstName => 'Nome';

  @override
  String get accountFieldLastName => 'Sobrenome';

  @override
  String get accountLoginButton => 'Entrar';

  @override
  String get accountSignupButton => 'Criar conta';

  @override
  String get authTerminalTagline => 'Domine a mente, domine o trade';

  @override
  String get authTerminalCtaLogin => 'Abrir terminal';

  @override
  String get authTerminalCtaSignup => 'Criar identidade';

  @override
  String get webLandingLoginSubtitle => 'Bem-vindo de volta ao Paychek.';

  @override
  String get webLandingSignupSubtitle => 'Junta-te à elite dos traders.';

  @override
  String get webLandingLoginCta => 'ENTRAR';

  @override
  String get webLandingSignupCta => 'EXPERIMENTAR GRÁTIS';

  @override
  String get webLandingNoAccountLabel => 'SEM CONTA?';

  @override
  String get webLandingRegisterLink => 'REGISTAR';

  @override
  String get webLandingAlreadyMemberLabel => 'JÁ ÉS MEMBRO?';

  @override
  String get webLandingLoginLink => 'ENTRAR';

  @override
  String get authTerminalEncryptedPrefix => 'Nó encriptado:';

  @override
  String get authTerminalEncryptedStatus => 'Ativo';

  @override
  String get authTerminalHintEmail => 'nome@terminal.com';

  @override
  String get authTerminalHintPassword => '••••••••';

  @override
  String get accountLoginSnackEmailMissing => 'Entrar: informe o e-mail';

  @override
  String get accountLoginSnackEmailReady => 'Entrar: e-mail informado';

  @override
  String get accountSignupSnackEmailMissing => 'Cadastro: informe o e-mail';

  @override
  String get accountSignupSnackFirstNameMissing => 'Cadastro: informe o nome';

  @override
  String get accountSignupSnackLastNameMissing =>
      'Cadastro: informe o sobrenome';

  @override
  String get accountSignupSnackBirthDateMissing =>
      'Cadastro: selecione a data de nascimento';

  @override
  String get accountSignupSnackReady => 'Cadastro: formulário pronto';

  @override
  String get accountSignupSnackPasswordMissing => 'Cadastro: informe a senha';

  @override
  String get accountSignupSnackPasswordMismatch =>
      'Cadastro: as senhas não coincidem';

  @override
  String get accountSignupSnackPasswordTooShort =>
      'A senha deve ter pelo menos 6 caracteres';

  @override
  String get accountLoginSnackPasswordMissing => 'Entrar: informe a senha';

  @override
  String get accountForgotPasswordLink => 'Esqueceu a senha?';

  @override
  String get accountForgotPasswordSnackEmailMissing =>
      'Informe seu e-mail acima para receber o link.';

  @override
  String get accountForgotPasswordSnackSent =>
      'Se existir uma conta com este e-mail, você receberá um link para definir uma nova senha.';

  @override
  String get accountForgotPasswordSnackTooManyRequests =>
      'Muitas tentativas. Tente novamente em alguns minutos.';

  @override
  String get accountPasswordResetDialogTitle => 'Redefinir senha';

  @override
  String get accountPasswordResetDialogSubtitle =>
      'Informe o e-mail da sua conta Paychek. Enviaremos um link para definir uma nova senha.';

  @override
  String get accountPasswordResetCta => 'ENVIAR LINK';

  @override
  String get accountPasswordResetBackToLogin => 'VOLTAR AO LOGIN';

  @override
  String get accountPasswordResetSnackEmailMissing => 'Informe seu e-mail.';

  @override
  String get accountPasswordResetSentDialogTitle => 'Verifique seu e-mail';

  @override
  String get accountPasswordResetSentDialogMessage =>
      'Se existir uma conta com este endereço, você receberá um e-mail com um link para definir uma nova senha. Verifique também a pasta de spam.';

  @override
  String get accountPasswordResetSentDialogCta => 'ENTENDI';

  @override
  String get accountAuthSignupSuccess => 'Conta criada';

  @override
  String get accountAuthLoginSuccess => 'Login realizado';

  @override
  String get accountAuthErrorWeakPassword => 'Senha muito fraca';

  @override
  String get accountAuthErrorEmailInUse => 'Este e-mail já está em uso';

  @override
  String get accountAuthErrorInvalidEmail => 'E-mail inválido';

  @override
  String get accountAuthErrorWrongCredentials => 'E-mail ou senha incorretos';

  @override
  String get accountAuthErrorNetwork => 'Erro de rede. Tente de novo.';

  @override
  String get accountAuthErrorGeneric => 'Algo deu errado';

  @override
  String get accountAuthErrorRestartOrReload =>
      'Conexão com a autenticação perdida. Encerre o app por completo e execute de novo (na Web, evite hot reload).';

  @override
  String get accountAuthErrorDifferentSignInMethod =>
      'Este e-mail já está em uso com outro método de login.';

  @override
  String accountAuthErrorWithFirebaseCode(String code) {
    return 'Algo deu errado ($code).';
  }

  @override
  String get accountAuthErrorUnknownFirebaseAuth =>
      'Não foi possível entrar (desconhecido). Verifique a conexão, tente de novo ou abra o Paychek no Chrome. No Firebase Console → Authentication, ative E-mail/senha e os provedores que você usa.';

  @override
  String accountAuthErrorSignInServerMessage(String message) {
    return '$message';
  }

  @override
  String get accountAuthWindowsSignInNotice =>
      'No app de desktop Windows, o login com Firebase costuma ser instável (limitação conhecida do Flutter / Firebase). Use o app móvel Paychek ou entre pelo navegador.';

  @override
  String get accountAuthWindowsOpenWebsite => 'Abrir paychek.pro no navegador';

  @override
  String get accountSocialAppleAndroidUseGoogle =>
      'Entrar com a Apple não está configurado no Android nesta versão. Use Google ou e-mail, ou entre pela web.';

  @override
  String get accountSocialAppleUnavailableDesktop =>
      'Entrar com a Apple não está disponível no app de desktop Windows/Linux. Use a web (Chrome), iPhone, iPad ou Mac.';

  @override
  String get accountSocialGoogleUnavailableDesktop =>
      'Login com Google indisponível no Windows/Linux. Use Chrome, Android ou iOS.';

  @override
  String get accountSocialFacebookUnavailableDesktop =>
      'Login com Facebook não está disponível no app desktop Windows/Linux. Use a versão web (Chrome), Android, iOS ou macOS.';

  @override
  String get accountSocialGoogleWebClientMissing =>
      'Para Google em celular ou tablet: defina o ID do cliente OAuth Web em lib/reglage/social_auth_config.dart. No Android, adicione a impressão digital SHA-1 do app no Firebase (Configurações do projeto → app Android).';

  @override
  String get paywallTitle => 'Seu período de teste acabou';

  @override
  String get paywallHeadlineBefore => 'Seu teste gratuito ';

  @override
  String get paywallHeadlineAccent => 'acabou';

  @override
  String get paywallUpgradeSubtitle =>
      'Faça upgrade para o Pro para desbloquear todo o seu potencial de trading e manter sua vantagem.';

  @override
  String paywallEndedOn(String date) {
    return 'Teste encerrado em $date.';
  }

  @override
  String get paywallCompareCurrentPlan => 'PLANO ATUAL';

  @override
  String get paywallCompareRecommended => 'RECOMENDADO';

  @override
  String get paywallPlanLiteName => 'Lite';

  @override
  String get paywallPlanProName => 'Pro';

  @override
  String get paywallLiteFeature1 => '30 trades / mês';

  @override
  String get paywallLiteFeature2 => 'Somente entrada manual';

  @override
  String get paywallLiteFeature3 => 'Calendário padrão';

  @override
  String get paywallProFeature1 => 'Ilimitado';

  @override
  String get paywallProFeature2 => 'Importação CSV e entrada manual';

  @override
  String get paywallProFeature3 => 'Calendário Pro';

  @override
  String get paywallProFeature4 => 'Checklist';

  @override
  String get paywallProFeature5 => 'Gerador de análise';

  @override
  String get paywallProFeature6 => 'Página Estratégia';

  @override
  String get paywallProFeature7 => 'Estatísticas de performance';

  @override
  String get paywallProFeature8 => 'Estado mental';

  @override
  String get paywallProFeature9 => 'Exportação PDF';

  @override
  String get paywallMobilePlanAnnualTitle => '1 ano (12 meses)';

  @override
  String get paywallMobilePlanQuarterlyTitle => '3 meses';

  @override
  String get paywallMobilePlanMonthlyTitle => '1 mês';

  @override
  String paywallMobilePlanPerMonthLine(String price) {
    return 'Cerca de $price \$ US / mês';
  }

  @override
  String get paywallMobilePlanPerMonthPrefix => 'Cerca de ';

  @override
  String get paywallMobilePlanPerMonthPriceSuffix => ' \$ US';

  @override
  String get paywallMobilePlanPerMonthEnd => ' / mês';

  @override
  String paywallMobilePlanTotalLine(String total) {
    return '$total \$';
  }

  @override
  String get paywallMobilePlanAnnualBilling => 'Faturado anualmente';

  @override
  String get paywallMobilePlanQuarterlyBilling => 'A cada 3 meses';

  @override
  String get paywallMobilePlanMonthlyBilling => 'Faturado mensalmente';

  @override
  String get paywallMobilePlanMonthlyCommitment => 'Compromisso mensal';

  @override
  String get paywallMobilePlanSavings44 => 'Poupe 44%';

  @override
  String get paywallMobilePlanPopular => 'Popular';

  @override
  String get paywallMobileCompareFeatureCol => 'Funcionalidade';

  @override
  String get paywallMobileRowTrades => 'Trades / mês';

  @override
  String get paywallMobileRowEntry => 'Entrada de dados';

  @override
  String get paywallMobileRowCalendar => 'Calendário';

  @override
  String get paywallMobileRowChecklist => 'Checklist';

  @override
  String get paywallMobileRowAnalysis => 'Gerador de análise';

  @override
  String get paywallMobileRowStrategy => 'Página Estratégia';

  @override
  String get paywallMobileRowStats => 'Estatísticas de desempenho';

  @override
  String get paywallMobileRowMental => 'Estado mental';

  @override
  String get paywallMobileRowExport => 'Exportação PDF';

  @override
  String get paywallPriceAnnualHighlight => 'US\$ 59,99 / ano';

  @override
  String get paywallPriceApproxPerMonth => 'Cerca de US\$ 4,99 / mês';

  @override
  String paywallTrialEndedBody(String date) {
    return 'Seus 7 dias grátis (novo cadastro) terminaram em $date. Sem Pro, você fica no plano Lite.';
  }

  @override
  String get paywallLiteLimitedHint =>
      'No Lite, só adicionar trade e o calendário ficam abertos. O restante exige Pro.';

  @override
  String get paywallContinueFreemium => 'Continuar no Lite (acesso limitado)';

  @override
  String get paywallSubscribeButton => 'Assinar agora';

  @override
  String get paywallRestoreButton => 'Já sou assinante';

  @override
  String get paywallStoreNotConfigured =>
      'Link Stripe em falta. Admin → Config → URL de pagamento (https://…), ativa a faturação e tenta de novo (sessão iniciada).';

  @override
  String get paywallRestoreNothingFound =>
      'Ainda bloqueado: assinatura ativa não encontrada.';

  @override
  String get paywallLegalFooter =>
      'Pagamento seguro via Stripe • Cancele quando quiser • Termos de serviço';

  @override
  String get paywallGoldPremiumPill => 'Acesso premium';

  @override
  String get paywallGoldMarketingHeadline => 'Upgrade para PRO';

  @override
  String get paywallGoldTagline => 'A ferramenta dos traders lucrativos.';

  @override
  String get paywallGoldYourPlanLabel => 'Atual';

  @override
  String get paywallGoldLiteColumnCaption => 'Standard';

  @override
  String get paywallGoldProColumnCaption => 'Ilimitado';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSupportSection => 'Suporte';

  @override
  String get settingsSupportCardTitle => 'Suporte e feedback';

  @override
  String get settingsSupportCardSubtitle =>
      'Envia-nos uma mensagem e consulta os guias na app.';

  @override
  String get supportFeedbackTitleLead => 'Suporte e ';

  @override
  String get supportFeedbackTitleAccent => 'Feedback';

  @override
  String get supportFeedbackSubtitle => 'Dúvida ou ideia? Estamos a ouvir-te.';

  @override
  String get supportActionEmailLabel => 'E-mail';

  @override
  String get supportActionEmailHint => 'Resposta até 24 h';

  @override
  String get supportActionDocsLabel => 'Docs';

  @override
  String get supportActionDocsHint => 'Guias de utilização';

  @override
  String get supportActionTwitterLabel => 'X';

  @override
  String get supportActionTwitterHint => 'Comunidade';

  @override
  String get supportFormNewMessage => 'Nova mensagem';

  @override
  String get supportFormKindLabel => 'Tipo de pedido';

  @override
  String get supportFormKindAccount => 'Conta';

  @override
  String get supportFormKindBilling => 'Faturação';

  @override
  String get supportFormKindFeature => 'Funcionalidade';

  @override
  String get supportFormKindOther => 'Outro';

  @override
  String get supportFormEmailLabel => 'Seu e-mail';

  @override
  String get supportFormEmailHint => 'nome@exemplo.com';

  @override
  String get supportFormDescriptionLabel => 'Descrição';

  @override
  String get supportFormDescriptionHint => 'Detalhes da mensagem…';

  @override
  String get supportFormSubmit => 'Enviar agora';

  @override
  String get supportFormSubmitSuccess =>
      'Obrigado — a tua mensagem foi enviada com sucesso.';

  @override
  String get supportFormSubmitSuccessPartial =>
      'Obrigado — a tua mensagem foi enviada (anexo não carregado).';

  @override
  String get supportFormSubmitDone =>
      'Se o teu cliente de e-mail não abriu, tenta de novo ou escreve-nos diretamente.';

  @override
  String get supportFormErrorEmail => 'Indica um endereço de e-mail.';

  @override
  String get supportFormErrorDescription => 'Adiciona uma descrição.';

  @override
  String get supportFormMailSubjectPrefix => 'Paychek suporte';

  @override
  String get supportFormMailBodyIntro => 'Mensagem enviada pela app Paychek:';

  @override
  String get supportFormAttachmentLabel => 'Anexo (opcional)';

  @override
  String get supportFormAttachmentPick => 'Foto ou PDF';

  @override
  String get supportFormAttachmentHint => 'PDF ou imagem, máx. 10 MB';

  @override
  String get supportFormAttachmentRemove => 'Remover ficheiro';

  @override
  String get supportFormAttachmentSignInHint =>
      'Inicia sessão para anexar — ou usa o e-mail sem anexo.';

  @override
  String get supportFormAttachmentTooLarge => 'Ficheiro acima de 10 MB.';

  @override
  String get supportFormAttachmentInvalidExtension =>
      'Apenas PDF, JPG, PNG ou WebP.';

  @override
  String get supportFormAttachmentReadFailed =>
      'Não foi possível ler o ficheiro.';

  @override
  String get supportFormSubmitFirestoreDone =>
      'Obrigado — mensagem guardada. A equipa vê na consola admin.';

  @override
  String get supportFormSubmitSending => 'A enviar…';

  @override
  String get supportFormSubmitError => 'Envio falhou. Verifica a ligação.';

  @override
  String supportErrorEmailOpenFailed(String error) {
    return 'Não foi possível abrir o e-mail: $error';
  }

  @override
  String get supportErrorEmailAppUnavailable =>
      'Não foi possível abrir a app de e-mail. Verifica se tens um cliente instalado.';

  @override
  String get supportFormSubmitSavedPartialAttachment =>
      'Mensagem guardada sem anexo (rede, tempo ou Storage). Verifica o Firebase.';

  @override
  String get supportQuickHelpTitle => 'Ajuda rápida';

  @override
  String get supportFaqWhereDataQ => 'Onde estão os meus dados?';

  @override
  String get supportFaqWhereDataA =>
      'Os dados ficam neste dispositivo (preferências, diário, carteiras) e sincronizam com a tua conta quando tens sessão iniciada. Exporta PDFs se precisares de arquivo. Terminar sessão não apaga a nuvem — volta a iniciar sessão para recuperar.';

  @override
  String get supportFaqFeatureQ => 'Precisas de uma nova funcionalidade?';

  @override
  String get supportFaqFeatureA =>
      'Usa o formulário com «Sugerir uma ideia». Lemos todas as mensagens.';

  @override
  String get supportStatusLabel => 'Estado técnico';

  @override
  String get supportStatusOperational => 'Serviços operacionais';

  @override
  String get helpCenterTitle => 'Central de ajuda';

  @override
  String get helpCenterSubtitle =>
      'Respostas rápidas e explicações sobre o uso do app.';

  @override
  String get helpCenterSearchHint => 'Pesquisar…';

  @override
  String get helpCenterVersionMobile => 'Versão móvel';

  @override
  String get helpCenterVersionWeb => 'Versão Web';

  @override
  String get helpCenterEmptyResults => 'Sem resultados.';

  @override
  String get helpCenterArticleAddTradeTitle => 'Adicionar um trade';

  @override
  String get helpCenterArticleAddTradeBody =>
      'Vá ao separador Adicionar, preencha os campos (ativo, entrada, stop, alvo…) e guarde. Pode anexar uma captura de ecrã se precisar.';

  @override
  String get helpCenterArticleEditTradeTitle => 'Diário — página do trade';

  @override
  String get helpCenterArticleEditTradeBody =>
      'Guide : Maîtriser votre Journal de Trading (Page Trade)\nLa page Trade est le centre d\'archivage intelligent de Paychek. Elle ne se contente pas de lister vos opérations ; elle les organise pour vous offrir une vision claire de votre progression, du trade individuel à la performance mensuelle.\n\n[img:assets/help_center/trade_page_header_filters.png]\n\n1. Tableau de Bord de Période (Header)\nEn haut de votre journal, vous disposez d\'un résumé instantané de la période sélectionnée :\n\nProfit Net : Votre résultat financier net en dollars et son impact en pourcentage sur votre capital (ex: +1070,00\$ / +53,50%).\n\nLe Win Rate Ring : L\'anneau central affiche votre pourcentage de réussite global. C\'est l\'indicateur visuel immédiat de la santé de votre trading.\n\nCompteur de Trades : Le détail précis du nombre de positions Gagnantes (G), Perdantes (P) et à l\'équilibre (Br).\n\n2. Navigation et Filtres Temporels\nPersonnalisez votre vue selon votre besoin d\'analyse grâce aux sélecteurs rapides :\n\nSélecteur 1D / 1S / 1M / ALL : Basculez instantanément entre une vue journalière, hebdomadaire, mensuelle ou l\'historique complet.\n\nFiltres de statut : Isolez vos trades Gagnants, Perdants ou Breakeven d\'un seul clic pour étudier des comportements spécifiques.\n\nActifs les plus tradés : Visualisez rapidement vos statistiques sur vos instruments préférés (ex: XAUUSD, EURUSD).\n\n[img:assets/help_center/trade_page_period_pdf_report.png]\n\n3. Structure en Accordéons et Rapports PDF\nL\'interface utilise un système de \"replier/déplier\" pour une lecture fluide et des options d\'exportation à tous les niveaux :\n\nRapports de Période (Jour/Semaine/Mois) : Chaque bloc de date (ex: \"14 Mars\") affiche un résumé de la performance du jour.\n\nEn cliquant sur l\'icône PDF à côté de la date, vous téléchargez un rapport complet de cette période spécifique. Idéal pour vos bilans de fin de semaine ou de mois.\n\nRapports de Trade Individuel : Cliquez sur un trade pour le déplier et voir ses détails (Heures, Session, Entry/Exit).\n\nChaque trade possède son propre bouton PDF. Ce document génère une fiche technique pro avec votre graphique et vos scores de discipline.\n\n[img:assets/help_center/trade_page_rings_week_view.png]\n\n4. Analyse visuelle par Ring\nChaque ligne (journée ou trade) est accompagnée d\'un Ring (anneau) :\n\nPour une journée, le ring représente le Win Rate global du jour.\n\nCela vous permet d\'identifier en une seconde vos journées \"rouges\" ou \"vertes\" sans avoir à lire chaque ligne de trade.\n\n[img:assets/help_center/trade_page_options_menu.png]\n\n5. Options de Gestion et Correction (Les 3 points)\nParce qu\'une erreur de saisie peut arriver, Paychek vous donne un contrôle total sur vos archives. À côté de l\'icône PDF de chaque fiche trade, vous trouverez un menu \"Options\" (représenté par 3 points verticaux) :\n\nModifier le Trade : Vous permet de réouvrir le formulaire de saisie pour corriger un prix, changer l\'heure, ajouter un screenshot oublié ou ajuster vos scores de discipline.\n\nSupprimer le Trade : Efface définitivement l\'enregistrement de votre journal.\n\nAttention : La suppression d\'un trade mettra à jour instantanément vos statistiques globales, votre Win Rate et votre capital dans les pages Trade et Performance.';

  @override
  String get helpCenterArticleChecklistTitle => 'Checklist';

  @override
  String get helpCenterArticleChecklistBody =>
      '📋 Checklist\n\n[img:assets/help_center/checklist_routine_discipline.png]\n\n1. Understanding the progress ring\nThe colored circle at the top of your screen is your readiness indicator.\n\n- Real-time progress: each ticked box moves the percentage forward.\n- Your checklist ring is not only on Routine — it stays in sync on your main Dashboard.\n- The gold standard: we recommend never opening a position unless your ring is at 100%. A trade taken with an incomplete checklist is often an emotional trade.\n\n2. Customize your routine\nEvery trader is unique. Paychek lets you build your own verification system.\n\n- Add a section: tap “+ Add a section” at the bottom to create a category (e.g. morning routine, economic news, post-session).\n- Manage items (⋯ menu):\n  - Add a task: open the three-dot menu next to a section title to insert a new checkpoint.\n  - Delete / edit: if a rule no longer fits your strategy, remove it to keep the UI clean.\n\n3. Default sections\nTo help you get started, we include three pillars:\n\n- Technical Analysis: validate your confluences (trend, S/R, indicators).\n- Risk Management: confirm your stop-loss is set and your risk per trade is respected.\n- Psychology: a quick check that you are not in revenge mode or euphoria.';

  @override
  String get helpCenterArticleCalendarTitle => 'Calendário';

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
      'Em Trade ou Desempenho, use Exportar PDF. Se falhar, verifique as permissões e tente novamente.';

  @override
  String get helpCenterArticleResetDataTitle => 'Apagar dados locais';

  @override
  String get helpCenterArticleResetDataBody =>
      'Em Definições > Dados pode apagar os dados guardados neste dispositivo. É irreversível; recomendamos reiniciar a app depois.';

  @override
  String get helpCenterArticleMyStrategyTitle => 'Minha estratégia — Playbook';

  @override
  String get helpCenterArticleMyAnalysisTitle =>
      'Minha análise — planos de trade';

  @override
  String get helpCenterArticleMyAnalysisBody =>
      '🔬 My Analysis: Build Your Trading Plans\n\nThe My Analysis page lets you build a full roadmap before you enter the market. By quantifying each technical element, Paychek calculates a global confidence score to validate your setup.\n\n[img:assets/help_center/analyse_trend_sheet.png]\n\n1. Trend card (context)\nDefine the frame for your opportunity:\n\nAsset & name: Use (+) to name your analysis and the instrument (e.g. EUR/USD — Weekly Swing Plan).\n\nDirection & phase: Choose your bias (Buy, Sell, or Watch) and the current market phase (Accumulation, Impulse, Distribution).\n\nConfidence slider: Set how certain you feel for this section. Open the gear (⚙️) to adjust this card’s impact (weight %) on the final report confidence.\n\n[img:assets/help_center/analyse_card_controls.png]\n\nCustomization: Use the pencil to edit available timeframes or phases, and Duplicate to compare several analyses on different timeframes in the same section.\n\n2. Technical sections (Structure, SMC, Indicators, Volume)\nEveryone trades differently. Turn cards on or off with the ON/OFF switch:\n\n[img:assets/help_center/analyse_technical_cards.png]\n\nStructure: Log support and resistance. Tick if a level was tested more than twice to strengthen relevance.\n\nSMC & Liquidity: Record Order Blocks, Fair Value Gaps (FVG), and Fibonacci levels.\n\nIndicators & Volume profile: Detail RSI/MACD signals or Point of Control (POC) zones.\n\nScreenshot: Attach a chart capture to illustrate your plan visually.\n\n3. Generating the report\nWhen your analysis is ready, tap Report.\n\n[img:assets/help_center/analyse_summary_report.png]\n\nGlobal confidence ring: The final ring is computed from your sliders and their impact weights.\n\nDynamic color coding: The validated report at the bottom uses a color that matches your direction: green (Buy), red (Sell), or yellow (Watch).\n\n[img:assets/help_center/analyse_report_embedded.png]\n\n4. Managing reports\nHistory: Reports are saved and tied to your instruments.\n\nActions: You can edit (pencil), delete (trash), or export a professional PDF of your analysis to archive or share.\n\n[img:assets/help_center/analyse_report_pdf.png]';

  @override
  String get helpCenterArticlePerformanceTitle =>
      'Desempenho — scanner de trades';

  @override
  String get settingsLogoutButton => 'Terminar sessão';

  @override
  String get settingsLogoutSnack => 'Sessão terminada.';

  @override
  String get settingsLogoutSnackPartial =>
      'Perfil apagado neste dispositivo. Se a conta ainda aparecer, verifica a rede ou reinicia a app.';

  @override
  String get splashTagline => 'Domine a mente, domine o trade';

  @override
  String get statsAvgGain => 'Ganho-média';

  @override
  String get statsPsychSub => 'Plano seguido';

  @override
  String get statsPsychology => 'Psicologia';

  @override
  String get statsRR => 'Relação R/R';

  @override
  String get statsSectionTitle => 'ESTATISTICAS';

  @override
  String get statsStrategy => 'Estratégia';

  @override
  String get statsStrategySub => 'Critérios validados';

  @override
  String get strategieAlertSignal => 'SINAL DE ALERTA';

  @override
  String get strategieDescription => 'DESCRIÇÃO';

  @override
  String get strategieDescriptionHint => 'por exemplo, baixa volatilidade';

  @override
  String get strategieEditSessionTitle => 'Editar Sessão';

  @override
  String get strategieHintEntry => 'Onde clicar em COMPRAR/VENDER?';

  @override
  String get strategieHintIndicatorTag => 'por exemplo, RSI';

  @override
  String get strategieHintInvalidation => 'Onde está o cenário errado?';

  @override
  String get strategieHintManagement => 'Como garantir a posição?';

  @override
  String get strategieHintPattern => 'por exemplo, Fundo Duplo';

  @override
  String get strategieHintSignal => 'Gatilho';

  @override
  String get strategieHintTarget => 'Meta final ou zonas de liquidez';

  @override
  String get strategieHintTimeframeTag => 'por exemplo, M15';

  @override
  String get strategieIndicators => 'INDICADORES';

  @override
  String get strategieModelName => 'Nome do Modelo';

  @override
  String get strategieNewSessionTitle => 'Nova sessão';

  @override
  String get strategiePatternFigure => 'PADRÃO / FIGURA';

  @override
  String get strategieRuleEntryPrecise => 'ENTRADA PRECISA';

  @override
  String get strategieRuleInvalidation => 'INVALIDAÇÃO (STOP LOSS)';

  @override
  String get strategieRuleManagement =>
      'GESTÃO (PONTO DE EQUILÍBRIO / PARCIAIS)';

  @override
  String get strategieRuleTarget => 'META (OBTER LUCRO)';

  @override
  String get strategieSessionName => 'Nome da sessão';

  @override
  String get strategieSetupColor => 'COR';

  @override
  String get strategieSetupEditTitle => 'Editar configuração';

  @override
  String get strategieSetupNewTitle => 'Nova configuração';

  @override
  String get strategieTimeEndOptionalLabel => 'Data de Término (Opcional)';

  @override
  String get strategieTimeStartLabel => 'START';

  @override
  String get strategieTimeframes => 'Prazos';

  @override
  String get strategieZoneNoTrade => 'Sem negociação';

  @override
  String get strategieZoneTrade => 'Comércio';

  @override
  String get strategieZoneType => 'Tipo de área';

  @override
  String get strategiePagePlaybookIntro =>
      'O teu plano de trading (Playbook). Revisa estas regras antes de cada sessão para manter disciplina e foco.';

  @override
  String get analyseReportTitle => 'Relatório';

  @override
  String get strategieGestionCaptionMaximum => 'Máximo';

  @override
  String get strategieGestionCaptionMinimum => 'Mínimo';

  @override
  String get strategieSectionSetupsAndModels => 'SETUPS E MODELOS';

  @override
  String get strategieSectionTradeCalendar => 'CALENDÁRIO DE TRADES';

  @override
  String get strategieCalendarNeedSetupForUsage =>
      'Adicione um setup acima para registar os dias de utilização.';

  @override
  String strategieCalendarUsageForSetup(String name) {
    return 'Utilização — $name';
  }

  @override
  String get strategieCalendarUsageTooltip =>
      'Marcar ou remover este dia para este setup (mesmo nome que em Adicionar trade).';

  @override
  String get strategieCalendarDotsExplain =>
      'Um ponto por estratégia usada nesse dia, a partir dos seus trades (Adicionar trade, data de entrada).';

  @override
  String get strategieSetupNavPrevious => 'ANTERIOR';

  @override
  String get strategieSetupNavNext => 'PRÓXIMO SETUP >';

  @override
  String get strategieSheetSetupsTitle => 'Setups e modelos';

  @override
  String get strategieMenuDisableFactors => 'Desativado';

  @override
  String get strategieManageTemplates => 'Gerir modelos';

  @override
  String get strategieDuplicateSetup => 'Duplicar um setup';

  @override
  String get strategieMesReglesDraftHint => 'Nova regra...';

  @override
  String get strategieSetupRemoveFromDashboard => 'Remover do painel';

  @override
  String get strategieSetupShowOnDashboard => 'Mostrar no painel';

  @override
  String get strategiePdfPlaybookBlurbShort =>
      'O teu plano de trading (Playbook). Revisa estas regras antes de cada sessão.';

  @override
  String get strategiePdfFooterNote =>
      'Regras de ouro: textos de referência (não guardados). Risco, horários e setups: dados guardados.';

  @override
  String get strategiePdfTableSession => 'Sessão';

  @override
  String get strategiePdfTableDescription => 'Descrição';

  @override
  String get strategiePdfTableSchedule => 'Horários';

  @override
  String get strategiePdfTechnicalContext => 'Contexto técnico';

  @override
  String get strategiePdfAlertSignal => 'Sinal de alerta';

  @override
  String get strategiePdfFileNamePrefix => 'minha_estrategia';

  @override
  String strategiePdfExportError(String error) {
    return 'Não foi possível criar o PDF: $error';
  }

  @override
  String get symbolHint => 'por exemplo, Fr, ₣';

  @override
  String get symbolLabel => 'Símbolo';

  @override
  String get tradeColEndingBalance => 'Saldos finais';

  @override
  String get tradeColPnl => 'P/L';

  @override
  String get tradeColResult => 'Resultado';

  @override
  String get tradeColStartingBalance => 'Balance de inicio';

  @override
  String get tradeColTotalGain => 'Ganho total';

  @override
  String get tradeColTotalGainPct => 'Ganho total';

  @override
  String get tradeColTrade => 'Negocie';

  @override
  String get tradeDeleteConfirmBody => 'Esta ação é permanente.';

  @override
  String get tradeDeleteConfirmTitle => 'Excluir esta negociação?';

  @override
  String get tradeReturn => 'Retorno da negociação';

  @override
  String get tradeActionsTooltip => 'Ações';

  @override
  String get tradeAverageShort => 'MEDIA';

  @override
  String tradeDayTradeNumber(int n) {
    return 'Negocie #$n hoje';
  }

  @override
  String tradeDurationHoursMinutes(int hours, String minutes) {
    return '${hours}h $minutes';
  }

  @override
  String tradeDurationMinutes(int minutes) {
    return 'Min.';
  }

  @override
  String get tradeEditMenu => 'Editar';

  @override
  String get tradeLinkedAnalyseOpenPdf => 'Abrir PDF da análise';

  @override
  String get tradeExportPdfTooltip => 'Exportar PDF';

  @override
  String get tradeFilterAll => 'Todos';

  @override
  String get tradeFilterBreakeven => 'Breakeven';

  @override
  String get tradeFilterLoser => 'Perdedores';

  @override
  String get tradeFilterOpenPosition => 'Vagas abertas';

  @override
  String get tradeFilterWinner => 'Vencedores';

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
  String get tradeLabelDuration => 'Duração';

  @override
  String get tradeLabelEntry => 'Entrada';

  @override
  String get tradeLabelEtat => 'UF';

  @override
  String get tradeLabelExit => 'Sair';

  @override
  String get tradeLabelHours => 'Horas';

  @override
  String get tradeLabelPlan => 'Plano';

  @override
  String get tradePlanAnalysisNoData => '—';

  @override
  String get tradePlanAnalysisMissingAll =>
      'Aucun trade n\'a de plan Mon Analyse lié. Ouvrez un trade (modifier) et associez un rapport pour afficher le % Plan.';

  @override
  String tradePlanAnalysisMissingPartial(int missing, int total) {
    return '$missing trade(s) sur $total sans plan Mon Analyse — associez un rapport depuis Ajouter / modifier trade.';
  }

  @override
  String get performancePlanAnalysisMissingBanner =>
      'Les statistiques « Analyse (plan) » ne comptent que les trades avec un rapport Mon Analyse lié. Sur cette période, aucun trade qualifié — associez un plan depuis le journal.';

  @override
  String get performancePlanAnalysisSectionEmpty =>
      'Aucun trade avec plan lié. Associez un rapport Mon Analyse à vos trades pour voir le winrate par respect du plan.';

  @override
  String get tradeStrategieExecutionNoData => '—';

  @override
  String get tradeStrategieExecutionMissingAll =>
      'Aucun trade n\'a de stratégie renseignée (setup + slider). Modifiez un trade dans Ajouter trade pour afficher le % Stratégie.';

  @override
  String tradeStrategieExecutionMissingPartial(int missing, int total) {
    return '$missing trade(s) sur $total sans stratégie renseignée — choisissez un setup et le slider lors de l\'enregistrement.';
  }

  @override
  String get performanceStrategieExecutionSectionEmpty =>
      'Aucun trade avec stratégie renseignée (slider / setup). Les cartes Horaires et Gestion du risque plus haut restent calculées automatiquement.';

  @override
  String get tradeChecklistNoData => '—';

  @override
  String get tradeChecklistMissingAll =>
      'Aucun trade n\'a de checklist cochée pour le jour d\'entrée. Cochez des cases sur la page Checklist (ou rétroaction sur le trade).';

  @override
  String tradeChecklistMissingPartial(int missing, int total) {
    return '$missing trade(s) sur $total sans checklist renseignée pour le jour d\'entrée.';
  }

  @override
  String get performanceChecklistSectionEmpty =>
      'Aucun trade avec checklist cochée le jour d\'entrée. Les stats ne comptent que les trades liés à une checklist remplie.';

  @override
  String get tradeEtatNoData => '—';

  @override
  String get tradeEtatMissingAll =>
      'Aucun trade n\'a d\'état mental réglé pour le jour d\'entrée. Renseignez la page État mental (ou rétroaction sur le trade).';

  @override
  String tradeEtatMissingPartial(int missing, int total) {
    return '$missing trade(s) sur $total sans état mental réglé pour le jour d\'entrée.';
  }

  @override
  String get performanceEtatSectionEmpty =>
      'Aucun trade avec état mental réglé pour le jour d\'entrée. Les cartes Horaires / Gestion du risque restent calculées automatiquement.';

  @override
  String get tradeLabelSession => 'Sessão';

  @override
  String get tradeLabelStrategie => 'Estratégia';

  @override
  String get tradeLabelNews => 'Notícias';

  @override
  String get tradeMindsetFeeling => 'Feeling';

  @override
  String get tradeMindsetPrinciple => 'Princípio';

  @override
  String get tradeMindsetTalent => 'Talento';

  @override
  String get tradeMonthTitle => 'Mês';

  @override
  String get tradeMostTradedHeading => 'Ativos mais negociados';

  @override
  String get tradeNotRespected => '• Não são seguidos';

  @override
  String tradeOpenPositionLine(String when) {
    return 'Posição aberta • Entrada $when';
  }

  @override
  String get tradePdfAnalysePostTrade => 'Avaliação pós-negociação';

  @override
  String get tradePdfBarresSemaine => 'Barras da semana';

  @override
  String get tradePdfCloture => 'Fechado';

  @override
  String get tradePdfPositionOpen => 'Posição Aberta';

  @override
  String tradePdfDatePrefix(String when) {
    return '0 Data:';
  }

  @override
  String tradePdfDetailsTitle(String pair) {
    return 'Detalhes da transação';
  }

  @override
  String get tradePdfEtatPsychologique => 'Estado psicológico';

  @override
  String get tradePdfTags => 'Tags';

  @override
  String get tradeTagsSection => 'TAG';

  @override
  String get tradePdfExportDayTitle => 'Negociações (dia)';

  @override
  String get tradePdfExportMonthTitle => 'Negociações (mês)';

  @override
  String get tradePdfExportWeekTitle => 'Negociações (semana)';

  @override
  String get tradePdfGainNet => 'P&L líquido';

  @override
  String get tradePdfImpactCapital => 'Impacto de capital';

  @override
  String get tradePdfMoyenne => 'Média';

  @override
  String get tradePdfNonRespecte => '• Não são seguidos';

  @override
  String get tradePdfPeriode => 'Período';

  @override
  String get tradePdfQualiteMoyennes => 'Qualidade (médias)';

  @override
  String tradePdfScreenshotTitle(String pair) {
    return 'Screenshot';
  }

  @override
  String get tradePdfSessions => 'Sessões';

  @override
  String get tradePdfSparklineMois => 'Sparkline do mês';

  @override
  String get tradePdfTrades => 'Operações';

  @override
  String get tradePdfWinRate => 'Acerto';

  @override
  String tradePctOfCapital(String percent) {
    return '$percent% do capital';
  }

  @override
  String get tradeScreenshotLoadError => 'Não foi possível carregar a imagem';

  @override
  String get tradeScreenshotUnavailableWeb =>
      'Captura de tela indisponível (web)';

  @override
  String get tradeSectionChecklist => 'Checklist';

  @override
  String get tradeSectionEtat => 'UF';

  @override
  String get tradeSectionPlan => 'Plano';

  @override
  String get tradeSectionStrategie => 'Estratégia';

  @override
  String tradeStrategieNonRespectUnmapped(String id) {
    return 'Detalhe da estratégia';
  }

  @override
  String get tradeSessionAsia => 'Ásia';

  @override
  String get tradeSessionEurope => 'Europa';

  @override
  String get tradeSessionLate => 'horas extras ';

  @override
  String get tradeSessionUs => 'EUA';

  @override
  String get tradeSideBreakevenShort => 'Breakeven';

  @override
  String get tradeSideBuyLong => 'Comprar';

  @override
  String get tradeSideBuyShort => 'COMPRAR';

  @override
  String get tradeSideSellLong => 'Venda';

  @override
  String get tradeSideSellShort => 'VENDER';

  @override
  String get tradeSummaryProfitNet => 'P&L LÍQUIDO';

  @override
  String get tradeSummaryTrades => 'NEGOCIAÇÕES';

  @override
  String get tradeSummaryWinRate => 'Taxa de ganho';

  @override
  String get tradeTotalUpper => 'TOTAL';

  @override
  String get tradeTradesListHeading => 'Operações';

  @override
  String get tradeTradesMonthHeading => 'Negociações (mês)';

  @override
  String get tradeTradesWeekHeading => 'Negociações (semana)';

  @override
  String get tradeWeekTitle => 'Semana';

  @override
  String get tradeWinDayRingSubtitle => 'VITÓRIA (dia)';

  @override
  String get tradeWinrateLabel => 'Acerto';

  @override
  String get settingsTradingWeek5 => '5 dias (seg–sex)';

  @override
  String get settingsTradingWeek7 => '7 dias (seg–dom)';

  @override
  String get settingsTradingWeekSubtitle =>
      '5 dias para mercados tradicionais (seg–sex), 7 dias para a semana completa (ex.: cripto).';

  @override
  String get settingsTradingWeekTitle => 'Semana exibida';

  @override
  String get settingsDashboardCardSubtitle =>
      'Personalizar início: seções e ordem';

  @override
  String get settingsDashLayoutTitle => 'Seções do início';

  @override
  String get settingsDashLayoutReorderHint =>
      'Arraste as alças para reordenar. Desative uma seção para ocultá-la no início.';

  @override
  String get settingsDashOpenHomeButton => 'Ver início';

  @override
  String get settingsDashSectionCapital => 'Capital e win rate';

  @override
  String get settingsDashSectionChecklist => 'Checklist';

  @override
  String get settingsDashSectionAnalyse => 'Análise';

  @override
  String get settingsDashSectionEtat => 'Estado mental';

  @override
  String get settingsDashSectionStrategie => 'Estratégia';

  @override
  String get settingsDashSectionWeekly => 'Desempenho semanal';

  @override
  String get settingsDashSectionEvolution => 'Evolução do capital';

  @override
  String get settingsDashSectionLens => 'Paychek Lens';

  @override
  String get tradingSection => 'Negociação';

  @override
  String get settingsCgvSection => 'Termos legais';

  @override
  String get settingsCgvPageTitle => 'Condições gerais de venda';

  @override
  String get settingsCgvRowTitle => 'Condições gerais de venda';

  @override
  String get settingsCgvRowSubtitle => 'Ler o texto completo na aplicação';

  @override
  String get settingsCgvDocHeading =>
      'CONDIÇÕES GERAIS DE VENDA (CGV) - PAYCHEK';

  @override
  String get settingsCgv1Title => '1. Objeto';

  @override
  String get settingsCgv1Body =>
      'As presentes CGV regem a subscrição de acesso «Pro» (Premium) à aplicação Paychek, uma ferramenta de diário de trading e gestão de risco. O acesso é fornecido por subscrição mensal, trimestral ou anual, renovada automaticamente em cada período até cancelamento.';

  @override
  String get settingsCgv2Title => '2. Serviços prestados';

  @override
  String get settingsCgv2Body =>
      'O acesso Premium desbloqueia todas as funcionalidades da aplicação (estatísticas avançadas, cálculo automático de risco, exportação de dados). O acesso está associado à conta de utilizador criada no registo.';

  @override
  String get settingsCgv3Title => '3. Preços e pagamento';

  @override
  String get settingsCgv3Body =>
      'Subscrição direta: os planos Pro são faturados em dólares americanos (USD) via Stripe, com renovação automática até cancelamento:\n• US\$ 8,99 / mês\n• US\$ 20,97 / 3 meses\n• US\$ 59,99 / ano\n\nOferta de parceiro: O acesso pode ser oferecido gratuitamente se o utilizador cumprir as condições de referência junto de um dos nossos parceiros (Prop Firm ou broker).\n\nA Paychek reserva-se o direito de alterar os preços a qualquer momento para novos clientes.';

  @override
  String get settingsCgv4Title => '4. Direito de livre resolução e reembolso';

  @override
  String get settingsCgv4Body =>
      'Em conformidade com a legislação sobre produtos digitais:\n\nDevido à natureza digital do serviço e ao acesso imediato ao conteúdo após o pagamento, o utilizador aceita que o serviço comece de imediato e renuncia expressamente ao direito de livre resolução de 14 dias.\n\nNão será efetuado reembolso após a ativação do acesso Premium, exceto em caso de falha técnica grave que torne a aplicação inutilizável.';

  @override
  String get settingsCgv5Title =>
      '5. Cláusula específica \"Oferta de parceiro\"';

  @override
  String get settingsCgv5Body =>
      'O acesso concedido através de um parceiro depende da validação da afiliação por esse parceiro.\n\nSe o parceiro recusar a afiliação (por incumprimento das regras de depósito ou de trading), a Paychek reserva-se o direito de revogar o acesso Premium ou exigir o pagamento das tarifas Pro em vigor.';

  @override
  String get settingsCgv6Title => '6. Aviso de riscos (Trading)';

  @override
  String get settingsCgv6Body =>
      'A Paychek não é um consultor financeiro. A aplicação é uma ferramenta técnica de gestão e análise.\n\nO trading envolve um elevado risco de perda de capital. O utilizador é o único responsável pelas suas decisões de trading.\n\nA Paychek não poderá ser responsabilizada por perdas financeiras do utilizador nos mercados.';

  @override
  String get settingsCgv7Title => '7. Disponibilidade do serviço';

  @override
  String get settingsCgv7Body =>
      'A Paychek esforça-se por manter o acesso 24/7. Contudo, não somos responsáveis por interrupções devidas a manutenção ou falhas de servidores de terceiros (Firebase, Google Cloud).';

  @override
  String get settingsCgv8Title => '8. Proteção de dados';

  @override
  String get settingsCgv8Body =>
      'Os dados de trading dos utilizadores são estritamente confidenciais e nunca são revendidos. São armazenados de forma segura através dos nossos fornecedores técnicos.';

  @override
  String get settingsPrivacyRowTitle => 'Política de privacidade';

  @override
  String get settingsPrivacyRowSubtitle =>
      'Dados pessoais, cookies e os seus direitos';

  @override
  String get settingsPrivacyPageTitle => 'Política de privacidade';

  @override
  String get settingsPrivacyDocHeading => 'POLÍTICA DE PRIVACIDADE — PAYCHEK';

  @override
  String get settingsDataResetSection => 'Dados';

  @override
  String get settingsDataResetTitle => 'Apagar todos os dados locais';

  @override
  String get settingsDataResetDescription =>
      'Se usaste o Paychek durante algum tempo e queres recomeçar do zero (como após reinstalar a aplicação), podes apagar tudo neste dispositivo: trades, análises, diário, layout do painel, perfil local, âncora de trial, etc.\n\nMantêm-se o idioma e a opção «semana mostrada».\n\nFecha completamente a aplicação e volta a abri-la para limpar memória temporária (ex.: checklist).';

  @override
  String get settingsDataResetButton => 'Apagar tudo neste dispositivo';

  @override
  String get settingsDataResetDialogTitle => 'Apagar todos os dados locais?';

  @override
  String get settingsDataResetDialogBody =>
      'Ação irreversível. Os dados Paychek guardados localmente serão eliminados. A sessão Firebase pode manter-se iniciada; apenas cópias locais são removidas.\n\nReinicia a app depois se algo parecer em cache.';

  @override
  String get settingsDataResetDialogCancel => 'Cancelar';

  @override
  String get settingsDataResetDialogConfirm => 'Apagar tudo';

  @override
  String get settingsDataResetSuccess =>
      'Dados locais apagados. Reinicia a app se necessário.';

  @override
  String get validate => 'Confirmar';

  @override
  String get winrate => 'Acerto';
}
