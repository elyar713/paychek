import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../strategie_tokens.dart';
import 'strategie_gestion_risque_section_menu.dart';

/// Textes et montants (€ / capital) alignés sur le dashboard.
abstract final class StrategieGestionRisqueFormat {
  StrategieGestionRisqueFormat._();

  /// « montant au taux / capital » avec symbole devise.
  static String riskAmountLine(
    double capital,
    double rate,
    String currencySymbol,
  ) {
    final part = capital * rate;
    return '${formatMoneyTwoDecimals(part)} $currencySymbol / ${formatMoneyTotal(capital)} $currencySymbol';
  }

  static String formatMoneyTwoDecimals(double v) {
    return v.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String formatMoneyTotal(double v) {
    if (v == v.roundToDouble()) {
      return separateThousands(v.round());
    }
    return v.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String separateThousands(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    if (n < 0) buf.write('-');
    final len = s.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static double? parseFlexible(String s) {
    final t = s.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  static String formatNumEdit(double v) {
    if (v == v.roundToDouble()) return '${v.round()}';
    var s = v.toStringAsFixed(4);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s.replaceAll('.', ',');
  }

  static String pctDisplay(double p) {
    if (p == p.roundToDouble()) return '${p.round()}%';
    return '${p.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '').replaceAll('.', ',')}%';
  }

  static String rrDisplay(double rrRatio) {
    final r = rrRatio;
    if (r == r.roundToDouble()) return '1:${r.round()}';
    var s = r.toStringAsFixed(2).replaceAll('.', ',');
    s = s.replaceAll(RegExp(r'0+$'), '');
    if (s.endsWith(',')) s = s.substring(0, s.length - 1);
    return '1:$s';
  }
}

/// Une case de la grille 2×2 (label, valeur / édition, sous-ligne €).
class StrategieGestionRisqueRiskCell extends StatelessWidget {
  const StrategieGestionRisqueRiskCell({
    super.key,
    required this.editKey,
    required this.label,
    required this.editMode,
    required this.displayMain,
    required this.editingController,
    required this.onEditingChanged,
    required this.decimalField,
    required this.mainColor,
    this.captionUnderMain,
    this.sub,
    this.subMuted = false,
    this.showToggle = false,
    this.toggleValue = true,
    this.onToggleChanged,
    this.toggleAreaKey,
    this.onEnterEditTap,
  });

  final GlobalKey editKey;
  final String label;
  final bool editMode;
  final String displayMain;
  final TextEditingController editingController;
  final VoidCallback onEditingChanged;
  final bool decimalField;
  final Color mainColor;
  final String? captionUnderMain;
  final String? sub;
  final bool subMuted;
  final bool showToggle;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  /// Exclu du « tap ailleurs = valider » en mode Désactivé (même logique que les cases Modifier).
  final GlobalKey? toggleAreaKey;
  /// Tap sur la valeur en lecture seule → active le mode Modifier.
  final VoidCallback? onEnterEditTap;

  static TextStyle get _labelStyle => GoogleFonts.plusJakartaSans(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.47,
        color: StrategieTokens.labelMuted,
        height: 1.15,
      );

  /// Hauteur fixe pour le titre (2 lignes) : aligne le **facteur** entre les cases (ex. RISQUE vs TRADE).
  double _labelSlotHeight(BuildContext context) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'Hg\nHg',
        style: _labelStyle,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 2,
    )..layout(maxWidth: 200);
    return tp.height;
  }

  /// Largeur type 4 chiffres (`1000`) — identique pour les 4 cases.
  static const String _editBoxWidthRefText = '1000';

  static const double _editBoxPadH = 8;
  static const double _editBoxPadV = 5;

  TextStyle _mainValueTextStyle() => GoogleFonts.plusJakartaSans(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: mainColor,
        height: 1,
      );

  /// Taille extérieure de la case édition (pour largeur + hauteur de ligne fixe).
  Size _editBoxOuterSize(BuildContext context) {
    final tp = TextPainter(
      text: TextSpan(text: _editBoxWidthRefText, style: _mainValueTextStyle()),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return Size(
      tp.width + _editBoxPadH * 2,
      tp.height + _editBoxPadV * 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final valueRowHeight = _editBoxOuterSize(context).height;

    return Container(
      key: editMode ? editKey : null,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: StrategieTokens.innerDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showToggle && onToggleChanged != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                KeyedSubtree(
                  key: toggleAreaKey,
                  child: StrategieGestionRisqueFactorToggle(
                    value: toggleValue,
                    onChanged: onToggleChanged!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          SizedBox(
            height: _labelSlotHeight(context),
            width: double.infinity,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: _labelStyle,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: valueRowHeight,
            width: double.infinity,
            child: Center(
              child: editMode
                  ? _buildEditField(context)
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onEnterEditTap,
                      child: _buildMainValueText(),
                    ),
            ),
          ),
          if (captionUnderMain != null) ...[
            const SizedBox(height: 8),
            Text(
              captionUnderMain!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: StrategieTokens.labelMuted,
                height: 1.15,
              ),
            ),
          ],
          if (sub != null) ...[
            const SizedBox(height: 14),
            Text(
              sub!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: subMuted
                    ? StrategieTokens.labelMuted.withValues(alpha: 0.55)
                    : StrategieTokens.labelMuted,
                height: 1.15,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Facteur principal : même style partout ; `%` forcé au même corps que les chiffres.
  Widget _buildMainValueText() {
    final style = _mainValueTextStyle();
    if (displayMain.endsWith('%') && displayMain.length > 1) {
      final body = displayMain.substring(0, displayMain.length - 1);
      return Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(text: body),
            TextSpan(text: '%', style: style),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text(
      displayMain,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  Widget _buildEditField(BuildContext context) {
    final inputFormatters = <TextInputFormatter>[
      if (decimalField)
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
      else
        FilteringTextInputFormatter.digitsOnly,
    ];

    final sz = _editBoxOuterSize(context);

    return Container(
      width: sz.width,
      height: sz.height,
      padding: const EdgeInsets.symmetric(
        horizontal: _editBoxPadH,
        vertical: _editBoxPadV,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: editingController,
        onChanged: (_) => onEditingChanged(),
        keyboardType: decimalField
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        inputFormatters: inputFormatters,
        textAlign: TextAlign.center,
        style: _mainValueTextStyle(),
        cursorColor: mainColor,
        showCursor: true,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
        ),
      ),
    );
  }
}
