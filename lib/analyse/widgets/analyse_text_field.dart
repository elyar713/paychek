import 'package:flutter/material.dart';

import '../analyse_tokens.dart';

class AnalyseTextField extends StatefulWidget {
  const AnalyseTextField({
    super.key,
    required this.hintText,
    required this.value,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
    this.compact = false,
  });

  final String hintText;
  final String value;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int maxLines;
  /// Une ligne, hauteur fixe (ex. alignement avec une pilule inline compacte).
  final bool compact;

  /// Hauteur du champ en mode [compact] (ligne TF + dernier point).
  static const double compactRowHeight = 36;

  @override
  State<AnalyseTextField> createState() => _AnalyseTextFieldState();
}

class _AnalyseTextFieldState extends State<AnalyseTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(AnalyseTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMin = widget.compact ? 1 : widget.minLines;
    final effectiveMax = widget.compact ? 1 : widget.maxLines;
    final pad = widget.compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 0)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 4);

    final fieldStyle = widget.compact
        ? AnalyseTokens.inputTextStyle.copyWith(height: 1.0)
        : AnalyseTokens.inputTextStyle;
    final hintStyle = TextStyle(
      color: AnalyseTokens.muted2,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: widget.compact ? 1.0 : null,
    );

    final field = Container(
      decoration: BoxDecoration(
        color: AnalyseTokens.fieldBg,
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusField),
      ),
      padding: pad,
      alignment: widget.compact ? Alignment.center : null,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        minLines: effectiveMin,
        maxLines: effectiveMax,
        style: fieldStyle,
        cursorColor: AnalyseTokens.accentGreen,
        textAlignVertical: widget.compact ? TextAlignVertical.center : null,
        strutStyle: widget.compact
            ? const StrutStyle(
                fontSize: 13,
                height: 1.0,
                leading: 0,
                forceStrutHeight: true,
              )
            : null,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: hintStyle,
          border: InputBorder.none,
          isDense: widget.compact,
          contentPadding: widget.compact
              ? const EdgeInsets.symmetric(horizontal: 0, vertical: 10)
              : null,
        ),
      ),
    );

    if (widget.compact) {
      return SizedBox(
        height: AnalyseTextField.compactRowHeight,
        child: field,
      );
    }
    return field;
  }
}
