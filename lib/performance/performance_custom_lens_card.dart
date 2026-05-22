import 'performance_tokens.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../checklist/checklist_models.dart';
import '../dashboard/dashboard_tokens.dart';
import '../strategie/strategie_tokens.dart';
import '../l10n/app_localizations.dart';
import 'performance_custom_lens_catalog.dart';
import 'performance_custom_lens_labels.dart';
import 'performance_custom_lens_logic.dart';
import 'performance_custom_lens_model.dart';
import 'performance_custom_lens_partitions.dart';
import 'performance_custom_lens_plan.dart';
import 'performance_locale_copy.dart';
import 'performance_trade_model.dart';

const Color kPerformanceLensGreen = PerformanceTokens.green;

/// Cartes / sections — style OLED ([PerformanceTokens]).
BoxDecoration performanceCustomLensSectionDecoration() =>
    PerformanceTokens.sectionDecoration();

/// Style du conteneur de [PerformanceCustomLensCard].
enum PerformanceCustomLensCardChrome {
  /// Page Performance (carte sombre dédiée).
  performance,

  /// Accueil mobile : même largeur que « Ma stratégie » ([StrategieTokens.sectionDecoration]).
  dashboardHome,

  /// Accueil web : contenu seul, cadre fourni par le parent.
  bare,
}

/// Carte « analyse personnalisée » (dimension, élément, barres de win rate).
class PerformanceCustomLensCard extends StatelessWidget {
  const PerformanceCustomLensCard({
    super.key,
    required this.trades,
    required this.config,
    required this.checklistSections,
    this.onConfigChanged,
    this.onAdd,
    this.onReset,
    this.onRemove,
    this.readOnly = false,
    this.chrome = PerformanceCustomLensCardChrome.performance,
  });

  final List<Trade> trades;
  final PerformanceCustomLensConfig config;
  final List<ChecklistSectionData> checklistSections;
  final ValueChanged<PerformanceCustomLensConfig>? onConfigChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onReset;
  final VoidCallback? onRemove;
  final bool readOnly;
  final PerformanceCustomLensCardChrome chrome;

  @override
  Widget build(BuildContext context) {
    final persist = onConfigChanged;
    final code = Localizations.localeOf(context).languageCode;
    final locale = Localizations.localeOf(context);
    final l = AppLocalizations.of(context)!;
    String txt(
      String fr,
      String en,
      String es,
      String de,
      String pt,
      String ko,
    ) => perf6(code, fr, en, es, de, pt, ko);
    String tradesWord(int n) => performanceTradeWordPlural(code, n);

    String? strategieTitleHint;
    final planIndex = buildPerformanceCustomLensPlanIndex(
      trades: trades,
      l: l,
      locale: locale,
    );
    for (final t in trades) {
      if ((t.strategieTitle ?? '').isNotEmpty) {
        strategieTitleHint = t.strategieTitle;
        break;
      }
    }

    final catalog = performanceCustomLensMasterCatalog(
      dimension: config.dimension,
      trades: trades,
      l: l,
      locale: locale,
      checklistSections: checklistSections,
      planIndex: planIndex,
    );
    final options = [
      for (final o in catalog)
        PerformanceCustomLensElementOption(
          id: o.id,
          label: performanceCustomLensElementLabel(
            dimension: config.dimension,
            elementId: o.id,
            l: l,
            locale: locale,
            strategieTitleHint: strategieTitleHint,
            planIndex: planIndex,
            checklistSections: checklistSections,
          ),
          tradeHits: o.tradeHits,
        ),
    ];

    var effectiveConfig = config;
    if (!readOnly &&
        config.elementId.isNotEmpty &&
        !options.any((o) => o.id == config.elementId)) {
      effectiveConfig = config.copyWith(elementId: '');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        persist?.call(effectiveConfig);
      });
    }

    final bands = performanceCustomLensBandStats(
      trades: trades,
      config: effectiveConfig,
      txt: txt,
    );
    final thresholds = effectiveConfig.sortedThresholds;

    void applyConfig(PerformanceCustomLensConfig next) => persist?.call(next);

    final elementTitle = effectiveConfig.elementId.isEmpty
        ? null
        : performanceCustomLensElementLabel(
            dimension: effectiveConfig.dimension,
            elementId: effectiveConfig.elementId,
            l: l,
            locale: locale,
            strategieTitleHint: strategieTitleHint,
            planIndex: planIndex,
            checklistSections: checklistSections,
          );

    Widget dimensionChip(PerformanceCustomLensDimension dim, String label) {
      final active = effectiveConfig.dimension == dim;
      return Expanded(
        child: GestureDetector(
          onTap: readOnly
              ? null
              : () {
                  applyConfig(
                    PerformanceCustomLensConfig(
                      dimension: dim,
                      elementId: '',
                      thresholds: List<double>.from(effectiveConfig.thresholds),
                    ),
                  );
                },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: active
                  ? kPerformanceLensGreen.withValues(alpha: 0.14)
                  : PerformanceTokens.innerBgDeep,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active
                    ? kPerformanceLensGreen.withValues(alpha: 0.55)
                    : PerformanceTokens.cardBorder,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active
                    ? kPerformanceLensGreen
                    : PerformanceTokens.textSecondary,
                height: 1.2,
              ),
            ),
          ),
        ),
      );
    }

    final firstShare = thresholds.isEmpty ? 50.0 : thresholds.first;

    Widget firstBarShareEditor() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: PerformanceTokens.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PerformanceTokens.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                txt(
                  '1ʳᵉ barre (part du score)',
                  '1st bar (score share)',
                  '1.ª barra (parte del score)',
                  '1. Balken (Score-Anteil)',
                  '1ª barra (parte do score)',
                  '1번째 막대(점수 비율)',
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PerformanceTokens.textSecondary,
                ),
              ),
            ),
            _performanceCustomLensThresholdStepBtn(
              icon: Icons.remove,
              onTap: firstShare <= kCustomLensMinBandShare
                  ? null
                  : () {
                      applyConfig(
                        effectiveConfig.copyWith(
                          thresholds: customLensSetFirstThreshold(
                            thresholds,
                            firstShare - 5,
                          ),
                        ),
                      );
                    },
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${firstShare.round()} %',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: kPerformanceLensGreen,
                ),
              ),
            ),
            _performanceCustomLensThresholdStepBtn(
              icon: Icons.add,
              onTap:
                  firstShare >=
                      100 -
                          kCustomLensMinBandShare *
                              (effectiveConfig.barCount - 1)
                  ? null
                  : () {
                      applyConfig(
                        effectiveConfig.copyWith(
                          thresholds: customLensSetFirstThreshold(
                            thresholds,
                            firstShare + 5,
                          ),
                        ),
                      );
                    },
            ),
          ],
        ),
      );
    }

    final BoxDecoration? decoration;
    final EdgeInsetsGeometry padding;
    switch (chrome) {
      case PerformanceCustomLensCardChrome.dashboardHome:
        decoration = StrategieTokens.sectionDecoration().copyWith(
          color: Colors.black,
        );
        padding = const EdgeInsets.fromLTRB(16, 14, 16, 16);
      case PerformanceCustomLensCardChrome.bare:
        decoration = null;
        padding = EdgeInsets.zero;
      case PerformanceCustomLensCardChrome.performance:
        decoration = performanceCustomLensSectionDecoration();
        padding = const EdgeInsets.all(20);
    }

    return Container(
      padding: padding,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _performanceCustomLensCardTitle(
                      LucideIcons.slidersHorizontal,
                      readOnly
                          ? (elementTitle ??
                                txt(
                                  'Analyse enregistrée',
                                  'Saved analysis',
                                  'Análisis guardado',
                                  'Gespeicherte Auswertung',
                                  'Análise guardada',
                                  '저장된 분석',
                                ))
                          : txt(
                              'Analyse personnalisée',
                              'Custom analysis',
                              'Análisis personalizado',
                              'Eigene Auswertung',
                              'Análise personalizada',
                              '맞춤 분석',
                            ),
                      titleColor: Colors.white,
                    ),
                    if (!readOnly && elementTitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        elementTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: PerformanceTokens.textBright,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!readOnly && onAdd != null) ...[
                _performanceCustomLensHeaderBtn(
                  label: txt(
                    'Ajouter',
                    'Add',
                    'Añadir',
                    'Hinzufügen',
                    'Adicionar',
                    '추가',
                  ),
                  onTap: onAdd!,
                  filled: true,
                ),
                if (onReset != null) const SizedBox(width: 6),
              ],
              if (!readOnly && onReset != null)
                _performanceCustomLensHeaderBtn(
                  label: txt(
                    'Réinitialiser',
                    'Reset',
                    'Restablecer',
                    'Zurücksetzen',
                    'Repor',
                    '초기화',
                  ),
                  onTap: onReset!,
                  filled: false,
                ),
              if (readOnly && onRemove != null)
                _performanceCustomLensHeaderBtn(
                  label: txt(
                    'Retirer',
                    'Remove',
                    'Quitar',
                    'Entfernen',
                    'Remover',
                    '제거',
                  ),
                  onTap: onRemove!,
                  filled: false,
                ),
            ],
          ),
          if (!readOnly) ...[
            const SizedBox(height: 8),
            Text(
              txt(
                'Choisissez une dimension et un point non respecté : les barres comparent le win rate selon le score discipline (seuils réglables).',
                'Pick a dimension and a missed checkpoint: bars compare win rate by discipline score (adjustable thresholds).',
                'Elige dimensión y punto no respetado: las barras comparan el win rate según la puntuación (umbrales ajustables).',
                'Dimension und nicht eingehaltenen Punkt wählen: Balken vergleichen Winrate nach Disziplin-Score (Schwellen einstellbar).',
                'Escolha dimensão e ponto não respeitado: barras comparam win rate pelo score (limiares ajustáveis).',
                '차원과 미준수 항목을 고른 뒤, 규율 점수 구간별 승률을 막대로 비교합니다(임계값 조절).',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: PerformanceTokens.labelMuted,
                height: 1.45,
              ),
            ),
          ],
          if (!readOnly) ...[
            const SizedBox(height: 16),
            Text(
              txt(
                '1 — Dimension',
                '1 — Dimension',
                '1 — Dimensión',
                '1 — Dimension',
                '1 — Dimensão',
                '1 — 차원',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: PerformanceTokens.labelDim,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                dimensionChip(
                  PerformanceCustomLensDimension.etat,
                  txt(
                    'État mental',
                    'Mental state',
                    'Estado mental',
                    'Mental',
                    'Estado mental',
                    '멘탈',
                  ),
                ),
                const SizedBox(width: 6),
                dimensionChip(
                  PerformanceCustomLensDimension.checklist,
                  txt(
                    'Checklist',
                    'Checklist',
                    'Checklist',
                    'Checkliste',
                    'Checklist',
                    '체크리스트',
                  ),
                ),
                const SizedBox(width: 6),
                dimensionChip(
                  PerformanceCustomLensDimension.plan,
                  txt(
                    'Analyse',
                    'Analysis',
                    'Análisis',
                    'Analyse',
                    'Análise',
                    '분석',
                  ),
                ),
                const SizedBox(width: 6),
                dimensionChip(
                  PerformanceCustomLensDimension.strategie,
                  txt(
                    'Stratégie',
                    'Strategy',
                    'Estrategia',
                    'Strategie',
                    'Estratégia',
                    '전략',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              txt(
                '2 — Élément',
                '2 — Element',
                '2 — Elemento',
                '2 — Element',
                '2 — Elemento',
                '2 — 요소',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: PerformanceTokens.labelDim,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            _PerformanceCustomLensElementField(
              options: options,
              selectedId: effectiveConfig.elementId,
              placeholder: txt(
                'Choisir un élément',
                'Choose an element',
                'Elegir un elemento',
                'Element wählen',
                'Escolher um elemento',
                '요소 선택',
              ),
              onSelected: (id) =>
                  applyConfig(effectiveConfig.copyWith(elementId: id)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  txt(
                    'Barres & seuils',
                    'Bars & thresholds',
                    'Barras y umbrales',
                    'Balken & Schwellen',
                    'Barras e limiares',
                    '막대·임계값',
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: PerformanceTokens.labelDim,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                if (effectiveConfig.barCount <
                    PerformanceCustomLensConfig.maxBars)
                  TextButton.icon(
                    onPressed: () {
                      applyConfig(
                        effectiveConfig.copyWith(
                          thresholds: customLensAddBar(thresholds),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 16,
                      color: kPerformanceLensGreen,
                    ),
                    label: Text(
                      txt('Barre', 'Bar', 'Barra', 'Balken', 'Barra', '막대'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kPerformanceLensGreen,
                      ),
                    ),
                  ),
                if (effectiveConfig.barCount >
                    PerformanceCustomLensConfig.minBars)
                  TextButton(
                    onPressed: () {
                      applyConfig(
                        effectiveConfig.copyWith(
                          thresholds: customLensRemoveBar(thresholds),
                        ),
                      );
                    },
                    child: Text(
                      txt(
                        'Retirer',
                        'Remove',
                        'Quitar',
                        'Entfernen',
                        'Remover',
                        '제거',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: PerformanceTokens.labelMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            firstBarShareEditor(),
            const SizedBox(height: 6),
            Text(
              txt(
                'Les barres se partagent 100 % du score discipline ; les autres parts s’ajustent quand vous modifiez la 1ʳᵉ.',
                'Bars share 100% of the discipline score; other shares adjust when you change the 1st.',
                'Las barras reparten el 100 % del score; el resto se ajusta al cambiar la 1.ª.',
                'Balken teilen 100 % des Scores; andere Anteile passen sich an, wenn Sie den 1. ändern.',
                'As barras dividem 100% do score; o resto ajusta ao mudar a 1ª.',
                '막대는 규율 점수 100%를 나눕니다. 첫 막대를 바꾸면 나머지가 조정됩니다.',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: PerformanceTokens.labelDim,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (!readOnly && effectiveConfig.elementId.isEmpty)
            Text(
              txt(
                'Sélectionnez un élément.',
                'Select an element.',
                'Selecciona un elemento.',
                'Element wählen.',
                'Selecione um elemento.',
                '요소를 선택하세요.',
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: PerformanceTokens.textSecondary,
              ),
            )
          else if (effectiveConfig.elementId.isNotEmpty)
            for (var i = 0; i < bands.length; i++)
              _performanceCustomLensBandRow(
                band: bands[i],
                tradesWord: tradesWord,
                barTint: kPerformanceLensGreen,
              ),
        ],
      ),
    );
  }
}

Widget _performanceCustomLensCardTitle(
  IconData icon,
  String title, {
  Color titleColor = PerformanceTokens.textSecondary,
}) {
  return Row(
    children: [
      Icon(icon, size: 16, color: kPerformanceLensGreen.withValues(alpha: 0.9)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: titleColor,
            letterSpacing: 1.35,
          ),
        ),
      ),
    ],
  );
}

Widget _performanceCustomLensHeaderBtn({
  required String label,
  required VoidCallback onTap,
  required bool filled,
}) {
  return Material(
    color: filled
        ? kPerformanceLensGreen.withValues(alpha: 0.18)
        : Colors.transparent,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: filled
                ? kPerformanceLensGreen.withValues(alpha: 0.55)
                : PerformanceTokens.chipBorderInactive,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: filled
                ? kPerformanceLensGreen
                : PerformanceTokens.textSecondary,
          ),
        ),
      ),
    ),
  );
}

Widget _performanceCustomLensThresholdStepBtn({
  required IconData icon,
  required VoidCallback? onTap,
}) {
  return Material(
    color: PerformanceTokens.innerBg,
    shape: const CircleBorder(
      side: BorderSide(color: PerformanceTokens.cardBorder),
    ),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 14,
          color: onTap == null ? PerformanceTokens.labelFaint : Colors.white70,
        ),
      ),
    ),
  );
}

Widget _performanceCustomLensBandRow({
  required PerformanceCustomLensBandStat band,
  required String Function(int) tradesWord,
  required Color barTint,
}) {
  final has = band.hasData;
  final wrPct = has ? ((band.winRate * 100).round()) : 0;
  final wrFill = has ? band.winRate.clamp(0.0, 1.0) : 0.0;
  final barFill = has && wrFill > 0 ? (wrFill < 0.04 ? 0.04 : wrFill) : null;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                band.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              has ? '$wrPct% WR' : '—',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: has ? barTint : PerformanceTokens.labelDim,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          has
              ? '${band.tradeCount} ${tradesWord(band.tradeCount)}'
              : '0 ${tradesWord(0)}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: PerformanceTokens.labelMuted,
          ),
        ),
        const SizedBox(height: 6),
        _performanceCustomLensRoundedHistogramBar(
          fill01: barFill,
          fillColor: barTint,
          height: 11,
        ),
      ],
    ),
  );
}

/// Piste + remplissage en pilule (coins ronds).
Widget _performanceCustomLensRoundedHistogramBar({
  double? fill01,
  required Color fillColor,
  double height = 11,
}) {
  final r = height / 2;
  return LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      var fillW = 0.0;
      if (fill01 != null) {
        final eff = fill01.clamp(0.0, 1.0);
        if (eff > 0) {
          fillW = w * eff;
          final minDot = math.max(height * 0.92, w * 0.032);
          if (fillW < minDot) fillW = minDot;
          if (fillW > w) fillW = w;
        }
      }

      return SizedBox(
        height: height,
        width: w,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.centerLeft,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: PerformanceTokens.bg,
                borderRadius: BorderRadius.circular(r),
                border: Border.all(color: PerformanceTokens.cardBorder),
              ),
              child: SizedBox(width: w, height: height),
            ),
            if (fillW > 0)
              Container(
                width: fillW,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r),
                  color: fillColor,
                ),
              ),
          ],
        ),
      );
    },
  );
}

/// Sélecteur type « Choisir un logiciel » : fond transparent, menu [showMenu] sous le champ.
class _PerformanceCustomLensElementField extends StatelessWidget {
  const _PerformanceCustomLensElementField({
    required this.options,
    required this.selectedId,
    required this.placeholder,
    required this.onSelected,
  });

  final List<PerformanceCustomLensElementOption> options;
  final String selectedId;
  final String placeholder;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = options.where((o) => o.id == selectedId).toList();
    final label = selected.isEmpty ? null : selected.first.label;

    Future<void> openMenu(BuildContext fieldContext) async {
      if (options.isEmpty) return;
      final renderObject = fieldContext.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) return;
      final overlayState = Overlay.of(context);
      final overlay = overlayState.context.findRenderObject();
      if (overlay is! RenderBox) return;

      final topLeft = renderObject.localToGlobal(
        Offset.zero,
        ancestor: overlay,
      );
      final bottomRight = renderObject.localToGlobal(
        renderObject.size.bottomRight(Offset.zero),
        ancestor: overlay,
      );
      final fieldWidth = renderObject.size.width;
      final spaceBelow = overlay.size.height - bottomRight.dy - 8;
      final maxMenuHeight = math.min(320.0, math.max(160.0, spaceBelow));

      final picked = await showMenu<String>(
        context: context,
        color: DashboardTokens.cardBoxBg,
        position: RelativeRect.fromLTRB(
          topLeft.dx,
          bottomRight.dy + 4,
          overlay.size.width - bottomRight.dx,
          0,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        elevation: 12,
        shadowColor: Colors.black54,
        constraints: BoxConstraints(
          minWidth: fieldWidth,
          maxWidth: fieldWidth,
          maxHeight: maxMenuHeight,
        ),
        items: [
          for (final o in options)
            PopupMenuItem<String>(
              value: o.id,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      o.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashboardTokens.onMatteEmphasis,
                      ),
                    ),
                  ),
                  if (o.tradeHits > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${o.tradeHits}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: DashboardTokens.labelGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
      if (picked != null) onSelected(picked);
    }

    return Material(
      color: Colors.transparent,
      child: Builder(
        builder: (fieldContext) => InkWell(
          onTap: () => openMenu(fieldContext),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DashboardTokens.cardBoxBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label ?? placeholder,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: label != null
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: label != null
                          ? DashboardTokens.onMatteEmphasis
                          : DashboardTokens.labelGrey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.expand_more,
                  size: 18,
                  color: DashboardTokens.labelGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
