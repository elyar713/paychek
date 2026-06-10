import 'package:flutter/material.dart';

import 'ajouter_trade_shell_scope.dart';
import 'ajouter_trade_strategie_feedback_retroaction.dart';
import '../strategie/widgets/strategie_setup_cards_content.dart';
import '../shared/paychek_frame_callbacks.dart';

/// Rétroaction inline selon le % « Stratégie respectée » — catégories puis boutons items.
class AjouterTradeStrategieFeedbackMenu extends StatefulWidget {
  const AjouterTradeStrategieFeedbackMenu({
    super.key,
    required this.strategieRespectPercent,
    required this.strategieTitle,
    this.onNonRespectSelectionChanged,
  });

  final double strategieRespectPercent;
  final String strategieTitle;

  /// Identifiants stables des éléments cochés comme « non respectés » (multi-sélection).
  final ValueChanged<Set<String>>? onNonRespectSelectionChanged;

  @override
  State<AjouterTradeStrategieFeedbackMenu> createState() =>
      _AjouterTradeStrategieFeedbackMenuState();
}

class _AjouterTradeStrategieFeedbackMenuState
    extends State<AjouterTradeStrategieFeedbackMenu> {
  /// Coche = élément **non** respecté (multi-choix).
  final Set<String> _nonRespectSelection = <String>{};

  void _clearNonRespectIfOffAddTradeTab() {
    final scope = AjouterTradeShellScope.maybeOf(context);
    if (scope == null || scope.shellTabIndex == 2) return;
    if (_nonRespectSelection.isEmpty) return;
    _nonRespectSelection.clear();
    PaychekFrameCallbacks.runPostFrame(() {
      if (!mounted) return;
      widget.onNonRespectSelectionChanged
          ?.call(Set<String>.from(_nonRespectSelection));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clearNonRespectIfOffAddTradeTab();
  }

  @override
  void didUpdateWidget(AjouterTradeStrategieFeedbackMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    var cleared = false;
    if (oldWidget.strategieTitle != widget.strategieTitle) {
      _nonRespectSelection.clear();
      cleared = true;
    }
    final oldP = oldWidget.strategieRespectPercent.round().clamp(0, 100);
    final newP = widget.strategieRespectPercent.round().clamp(0, 100);
    if (oldP < 95 && newP >= 95) {
      _nonRespectSelection.clear();
      cleared = true;
    }
    if (cleared) {
      PaychekFrameCallbacks.runPostFrame(() {
        if (!mounted) return;
        widget.onNonRespectSelectionChanged
            ?.call(Set<String>.from(_nonRespectSelection));
      });
      setState(() {});
    }
  }

  void _toggleNonRespect(String id) {
    setState(() {
      if (_nonRespectSelection.contains(id)) {
        _nonRespectSelection.remove(id);
      } else {
        _nonRespectSelection.add(id);
      }
    });
    widget.onNonRespectSelectionChanged
        ?.call(Set<String>.from(_nonRespectSelection));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.strategieRespectPercent.round().clamp(0, 100);
    final data = strategieSetupCardDataPourTitre(widget.strategieTitle);

    return AjouterTradeStrategieFeedbackRetroactionBody(
      p: p,
      data: data,
      nonRespectSelection: _nonRespectSelection,
      onToggleNonRespect: _toggleNonRespect,
    );
  }
}
