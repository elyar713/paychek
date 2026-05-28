import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/dashboard_tokens.dart';

/// Hauteur des pilules Actif / Qté / Entrée / Sortie (carte instrument).
const double kAjouterTradeInstrumentFieldHeight = 36;

/// Libellé au-dessus + pilule remplissable (hauteur alignée sur [AjouterTradeDirectionBar]).
class AjouterTradeLabeledFieldBox extends StatelessWidget {
  const AjouterTradeLabeledFieldBox({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.labelStyle,
    required this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.fieldHeight,
    this.valueFontSize,
    this.fieldWidth,
    this.fieldTrailing,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextStyle? labelStyle;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// Hauteur de la pilule (défaut 36).
  final double? fieldHeight;

  /// Taille du texte saisi / hint (défaut 12).
  final double? valueFontSize;

  /// Largeur fixe de la pilule ; si `null`, la pilule s’étire ([Expanded]) sur la ligne.
  final double? fieldWidth;

  /// À droite de la pilule, séparé (ex. engrenage réglages quantité).
  final Widget? fieldTrailing;

  static const double _defaultFieldHeight = kAjouterTradeInstrumentFieldHeight;
  static const double _radius = 10;
  static const double _trailingGap = 6;

  @override
  Widget build(BuildContext context) {
    final fs = valueFontSize ?? 12.0;
    final baseValueStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
              color: DashboardTokens.onMatteEmphasis,
              fontWeight: FontWeight.w800,
              fontSize: fs,
            ) ??
            TextStyle(
              color: DashboardTokens.onMatteEmphasis,
              fontWeight: FontWeight.w800,
              fontSize: fs,
            );
    final centeredStyle = baseValueStyle.copyWith(
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
    );
    final hintStyle = centeredStyle.copyWith(
      color: DashboardTokens.muted.withValues(alpha: 0.55),
      fontWeight: FontWeight.w600,
    );

    final h = fieldHeight ?? _defaultFieldHeight;
    final horizontalPad = fs <= 11 ? 6.0 : 8.0;
    final fieldBox = Container(
      height: h,
      decoration: BoxDecoration(
        color: DashboardTokens.cardBoxBg,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: DashboardTokens.cardBoxBorder),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: horizontalPad),
      child: TextField(
        controller: controller,
        enabled: true,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        maxLines: 1,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.done,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: centeredStyle,
        cursorColor: DashboardTokens.accent,
        showCursor: true,
        scrollPadding: EdgeInsets.zero,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          isDense: true,
          filled: false,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: labelStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (fieldWidth != null)
              SizedBox(width: fieldWidth, child: fieldBox)
            else
              Expanded(child: fieldBox),
            if (fieldTrailing != null) ...[
              SizedBox(width: _trailingGap),
              fieldTrailing!,
            ],
          ],
        ),
      ],
    );
  }
}

/// Ligne case à cocher compacte (Breakeven, news, etc.) — même géométrie partout.
class AjouterTradeInlineCheckboxRow extends StatelessWidget {
  const AjouterTradeInlineCheckboxRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.labelStyle,
  });

  static const double leadingSize = 26;
  static const double gapAfterLeading = 4;

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final ls =
        labelStyle ??
        const TextStyle(
          color: DashboardTokens.labelGrey,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          height: 1.15,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: leadingSize,
              height: leadingSize,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: DashboardTokens.cardBoxBorder),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return DashboardTokens.accent;
                  }
                  return null;
                }),
                checkColor: DashboardTokens.onMatteEmphasis,
              ),
            ),
            SizedBox(width: gapAfterLeading),
            Expanded(
              child: Text(
                label,
                style: ls,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloc date/heure + case à cocher : espacements et alignement réglables ici.
class AjouterTradeDateAndCheckboxColumn extends StatelessWidget {
  const AjouterTradeDateAndCheckboxColumn({
    super.key,
    required this.dateTimeText,
    required this.dateStyle,
    required this.checkboxValue,
    required this.onCheckboxChanged,
    required this.checkboxLabel,
    required this.checkboxLabelStyle,
    this.alignStart = false,
    this.onDateTimeTap,
    this.dateLayerLink,
    this.dateRowMeasureKey,
    this.highlightDateRow = false,
  });

  /// Espace sous le champ (Entrée/Sortie) avant la ligne date.
  static const double gapAfterField = 8;

  /// Espace entre la ligne date et la ligne case à cocher.
  static const double gapDateToCheckbox = 10;

  /// Largeur max du bloc case + libellé (centré sous la date).
  static const double checkboxBlockMaxWidth = 188;

  /// Même largeur que la case à cocher pour aligner calendrier et checkbox.
  static const double _leadingControlSize =
      AjouterTradeInlineCheckboxRow.leadingSize;

  static const double _gapAfterLeading =
      AjouterTradeInlineCheckboxRow.gapAfterLeading;

  final String dateTimeText;
  final TextStyle? dateStyle;
  final bool checkboxValue;
  final ValueChanged<bool?> onCheckboxChanged;
  final String checkboxLabel;
  final TextStyle? checkboxLabelStyle;

  /// Si `true` : date et case alignées au **début** de la colonne (ex. Sortie / Position).
  final bool alignStart;

  /// Si non null : la ligne date/heure ouvre le sélecteur (date puis heure).
  final VoidCallback? onDateTimeTap;

  /// Ancrage du popunder date/heure (sous la ligne).
  final LayerLink? dateLayerLink;

  /// Mesure la largeur utile pour dimensionner le popunder.
  final GlobalKey? dateRowMeasureKey;

  /// Ligne date soulignée quand le sélecteur est ouvert.
  final bool highlightDateRow;

  @override
  Widget build(BuildContext context) {
    final ds =
        dateStyle ??
        const TextStyle(
          color: DashboardTokens.muted,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
          height: 1.2,
        );
    final ls =
        checkboxLabelStyle ??
        const TextStyle(
          color: DashboardTokens.labelGrey,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          height: 1.15,
        );

    final calendarSlot = SizedBox(
      width: _leadingControlSize,
      height: _leadingControlSize,
      child: Center(
        child: Icon(
          Icons.calendar_today_outlined,
          size: 11,
          color: DashboardTokens.muted,
        ),
      ),
    );

    final checkboxRow = AjouterTradeInlineCheckboxRow(
      value: checkboxValue,
      onChanged: (v) => onCheckboxChanged(v),
      label: checkboxLabel,
      labelStyle: ls,
    );

    final dateRowCore = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        calendarSlot,
        SizedBox(width: _gapAfterLeading),
        Expanded(
          child: Text(
            dateTimeText,
            style: ds,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignStart ? TextAlign.start : TextAlign.center,
          ),
        ),
      ],
    );

    Widget dateRow = onDateTimeTap == null
        ? dateRowCore
        : Tooltip(
            message: 'Choisir la date et l’heure',
            child: DecoratedBox(
              decoration: highlightDateRow
                  ? const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: DashboardTokens.accent,
                          width: 1.5,
                        ),
                      ),
                    )
                  : const BoxDecoration(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDateTimeTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 4),
                    child: dateRowCore,
                  ),
                ),
              ),
            ),
          );

    if (dateLayerLink != null) {
      dateRow = CompositedTransformTarget(
        key: dateRowMeasureKey,
        link: dateLayerLink!,
        child: dateRow,
      );
    }

    final stacked = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dateRow,
        const SizedBox(height: gapDateToCheckbox),
        checkboxRow,
      ],
    );

    if (alignStart) {
      return stacked;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: checkboxBlockMaxWidth),
        child: stacked,
      ),
    );
  }
}
