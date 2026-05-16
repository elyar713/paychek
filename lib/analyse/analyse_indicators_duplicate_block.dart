import 'package:flutter/material.dart';

import 'analyse_controller.dart';
import 'analyse_indicators_duplicate_layout.dart';

/// Copie : TF + setup + champs libres + notes éditables (pas confiance / impact).
class AnalyseIndicatorsDuplicateBlock extends StatefulWidget {
  const AnalyseIndicatorsDuplicateBlock({
    super.key,
    required this.controller,
    required this.snapshotIndex,
    required this.indexLabel,
    required this.editMode,
    this.onRemove,
  });

  final AnalyseController controller;
  final int snapshotIndex;
  final int indexLabel;
  final bool editMode;
  final VoidCallback? onRemove;

  @override
  State<AnalyseIndicatorsDuplicateBlock> createState() =>
      _AnalyseIndicatorsDuplicateBlockState();
}

class _AnalyseIndicatorsDuplicateBlockState
    extends State<AnalyseIndicatorsDuplicateBlock> {
  final TextEditingController _dupDraftCtrl = TextEditingController();
  final FocusNode _dupDraftFocus = FocusNode();
  bool _dupDraftOpen = false;

  AnalyseController get _c => widget.controller;
  int get _idx => widget.snapshotIndex;

  @override
  void initState() {
    super.initState();
    _dupDraftFocus.addListener(_onDupDraftFocusChanged);
  }

  void _onDupDraftFocusChanged() {
    if (_dupDraftFocus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_dupDraftFocus.hasFocus) return;
      if (!_dupDraftOpen) return;
      _finishDupDraft();
    });
  }

  void _finishDupDraft() {
    if (!_dupDraftOpen) return;
    final t = _dupDraftCtrl.text.trim();
    _dupDraftOpen = false;
    if (t.isNotEmpty) {
      _c.addIndicatorsSnapshotIndicator(_idx, t);
    }
    _dupDraftCtrl.clear();
    if (mounted) setState(() {});
  }

  void _openDupDraft() {
    setState(() => _dupDraftOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dupDraftFocus.requestFocus();
    });
  }

  void _onDupAddTap() {
    if (!_dupDraftOpen) {
      _openDupDraft();
      return;
    }
    final t = _dupDraftCtrl.text.trim();
    if (t.isEmpty) {
      _dupDraftOpen = false;
      _dupDraftCtrl.clear();
      if (mounted) setState(() {});
      _dupDraftFocus.unfocus();
      return;
    }
    _dupDraftOpen = false;
    _c.addIndicatorsSnapshotIndicator(_idx, t);
    _dupDraftCtrl.clear();
    if (mounted) setState(() {});
    _dupDraftFocus.unfocus();
  }

  void _onDupDraftSubmitted() {
    final t = _dupDraftCtrl.text.trim();
    if (t.isEmpty) {
      _dupDraftFocus.unfocus();
      return;
    }
    _dupDraftOpen = false;
    _c.addIndicatorsSnapshotIndicator(_idx, t);
    _dupDraftCtrl.clear();
    if (mounted) setState(() {});
    _dupDraftFocus.unfocus();
  }

  @override
  void dispose() {
    _dupDraftFocus.removeListener(_onDupDraftFocusChanged);
    _dupDraftFocus.dispose();
    _dupDraftCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyseIndicatorsDuplicateLayout(
      controller: widget.controller,
      snapshotIndex: widget.snapshotIndex,
      indexLabel: widget.indexLabel,
      editMode: widget.editMode,
      onRemove: widget.onRemove,
      dupDraftOpen: _dupDraftOpen,
      dupDraftCtrl: _dupDraftCtrl,
      dupDraftFocus: _dupDraftFocus,
      onDupAddTap: _onDupAddTap,
      onDupDraftSubmitted: _onDupDraftSubmitted,
      onFinishDupDraft: _finishDupDraft,
    );
  }
}
