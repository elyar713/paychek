import 'package:flutter/material.dart';

import '../analyse_tokens.dart';

class AnalyseInlinePill extends StatelessWidget {
  const AnalyseInlinePill({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onPressed,
    this.compact = false,
    this.height,
    this.iconOffset,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  /// Reçoit le [context] de la pilule (pour ancrer un menu sous le bon [RenderBox]).
  final void Function(BuildContext context)? onPressed;
  /// Moins de padding (ex. ligne TF à côté d’un champ compact).
  final bool compact;
  /// Hauteur fixe (ex. 36 px comme le champ texte compact TF) pour aligner sur une ligne à côté.
  final double? height;
  /// Décalage de l’icône (ex. flèche TF : un peu à gauche et vers le bas).
  final Offset? iconOffset;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 14.0 : 16.0;
    final hPad = compact ? 6.0 : 12.0;
    final vPad = compact ? 5.0 : 10.0;
    final fontSize = compact ? 11.0 : 12.0;

    Widget? iconWidget;
    if (icon != null) {
      iconWidget = Icon(icon, size: iconSize, color: AnalyseTokens.muted2);
      if (iconOffset != null) {
        iconWidget = Transform.translate(offset: iconOffset!, child: iconWidget);
      }
    }

    final textStyle = TextStyle(
      color: const Color(0xFFCFCFCF),
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
    );

    final rightReserveForCenteredLabel = iconWidget != null
        ? iconSize + (compact ? 4.0 : 8.0)
        : 0.0;

    final row = height != null
        ? Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(right: rightReserveForCenteredLabel),
                  child: Center(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: textStyle,
                    ),
                  ),
                ),
              ),
              if (iconWidget != null)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(child: iconWidget),
                ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconWidget != null) ...[
                iconWidget,
                SizedBox(width: compact ? 6 : 8),
              ],
              Text(label, style: textStyle),
            ],
          );

    final inkChild = height != null
        ? SizedBox(
            height: height,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: row,
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: row,
          );

    return Material(
      color: AnalyseTokens.chipBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusChip),
        side: compact ? const BorderSide(color: AnalyseTokens.cardBorder) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (onPressed != null) {
            onPressed!(context);
          } else {
            onTap?.call();
          }
        },
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusChip),
        child: inkChild,
      ),
    );
  }
}

/// « + Libellé » avec saisie **sur place** (pilule / champ, sans dialogue).
class AnalyseAddInlineFieldRow extends StatefulWidget {
  const AnalyseAddInlineFieldRow({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.onCommitted,
  });

  final String label;
  final String value;
  final String hint;
  final ValueChanged<String> onCommitted;

  static const _plusCircle = 22.0;

  @override
  State<AnalyseAddInlineFieldRow> createState() => _AnalyseAddInlineFieldRowState();
}

class _AnalyseAddInlineFieldRowState extends State<AnalyseAddInlineFieldRow>
    with WidgetsBindingObserver {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  bool _editing = false;
  double _lastViewInsetBottom = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ctrl = TextEditingController(text: widget.value);
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bottom = MediaQuery.viewInsetsOf(context).bottom;
      if (_editing && _lastViewInsetBottom > 0 && bottom == 0) {
        _commitAndClose();
      }
      _lastViewInsetBottom = bottom;
    });
  }

  void _onFocusChange() {
    if (!_focus.hasFocus && _editing) {
      _commitAndClose();
    }
  }

  void _commitAndClose() {
    if (!_editing) return;
    final t = _ctrl.text.trim();
    if (t != widget.value) widget.onCommitted(t);
    if (mounted) setState(() => _editing = false);
  }

  void _startEditing() {
    _ctrl.text = widget.value;
    _lastViewInsetBottom = MediaQuery.viewInsetsOf(context).bottom;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
      _ctrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _ctrl.text.length,
      );
    });
  }

  @override
  void didUpdateWidget(covariant AnalyseAddInlineFieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.value != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  /// Pilule avec bordure uniquement pendant la saisie.
  BoxDecoration get _pillDecorationEditing => BoxDecoration(
        color: AnalyseTokens.chipBg,
        borderRadius: BorderRadius.circular(12),
      );

  /// Zone à droite du « + » : libellé, pilule avec valeur, ou champ en édition (même emplacement).
  Widget _buildTrailing(String v, bool hasValue) {
    if (_editing) {
      return DecoratedBox(
        decoration: _pillDecorationEditing,
        child: TextField(
          controller: _ctrl,
          focusNode: _focus,
          style: const TextStyle(
            color: Color(0xFFDFDFDF),
            fontWeight: FontWeight.w700,
            fontSize: 11,
            height: 1.2,
          ),
          cursorColor: AnalyseTokens.accentGreen,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AnalyseTokens.muted2,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          maxLines: 2,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _commitAndClose(),
          onTapOutside: (_) => _commitAndClose(),
        ),
      );
    }
    if (hasValue) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _startEditing,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              v,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFDFDFDF),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _startEditing,
        borderRadius: BorderRadius.circular(8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AnalyseTokens.muted,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 0.15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.value.trim();
    final hasValue = v.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _editing ? null : _startEditing,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: AnalyseAddInlineFieldRow._plusCircle,
                height: AnalyseAddInlineFieldRow._plusCircle,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 15,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TapRegion(
              onTapOutside: (_) => _commitAndClose(),
              child: _buildTrailing(v, hasValue),
            ),
          ),
        ],
      ),
    );
  }
}
