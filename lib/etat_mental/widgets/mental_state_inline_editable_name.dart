import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../mental_state_models.dart';

/// Libellé renommable sur place (sans dialog) — stylo → [TextField] avec `InputDecoration.collapsed`.
class MentalStateInlineEditableName extends StatefulWidget {
  const MentalStateInlineEditableName({
    super.key,
    required this.text,
    required this.style,
    required this.onCommitted,
    required this.showEditIcon,
    this.iconSize = 14,
    this.shrinkWrap = false,
    this.maxLabelWidth = 160,
  });

  final String text;
  final TextStyle style;
  final ValueChanged<String> onCommitted;
  final bool showEditIcon;
  final double iconSize;
  final bool shrinkWrap;
  final double maxLabelWidth;

  @override
  State<MentalStateInlineEditableName> createState() => MentalStateInlineEditableNameState();
}

class MentalStateInlineEditableNameState extends State<MentalStateInlineEditableName> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _editing) {
      _commit();
    }
  }

  @override
  void didUpdateWidget(covariant MentalStateInlineEditableName oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && widget.text != oldWidget.text) {
      _controller.text = widget.text;
    }
    if (!widget.showEditIcon && _editing) {
      _commit();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void beginEdit() {
    if (_editing) return;
    _beginEditing();
  }

  void _handlePencilTap() {
    if (!widget.showEditIcon) return;
    _beginEditing();
  }

  void _beginEditing() {
    setState(() {
      _editing = true;
      _controller.text = widget.text;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _commit() {
    if (!_editing) return;
    final raw = _controller.text.trim();
    final next = raw.isEmpty ? widget.text : raw;
    if (next != widget.text) {
      widget.onCommitted(next);
    }
    setState(() {
      _editing = false;
      _controller.text = next;
    });
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  Widget _labelWidget() {
    return _editing
        ? TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: widget.style,
            decoration: const InputDecoration.collapsed(hintText: ''),
            maxLines: 1,
            textInputAction: TextInputAction.done,
            cursorColor: kMentalStateRingGreen,
            onSubmitted: (_) => _commit(),
          )
        : Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
  }

  @override
  Widget build(BuildContext context) {
    Widget core = _labelWidget();
    if (widget.shrinkWrap) {
      core = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxLabelWidth),
        child: core,
      );
    }

    if (widget.shrinkWrap) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          core,
          if (widget.showEditIcon && !_editing)
            InkWell(
              onTap: _handlePencilTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(LucideIcons.pencil, size: widget.iconSize, color: const Color(0xFF555555)),
              ),
            ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: core),
        if (widget.showEditIcon && !_editing)
          InkWell(
            onTap: _handlePencilTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(LucideIcons.pencil, size: widget.iconSize, color: const Color(0xFF555555)),
            ),
          ),
      ],
    );
  }
}
