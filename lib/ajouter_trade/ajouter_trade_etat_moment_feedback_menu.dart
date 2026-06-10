import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_feedback_category_buttons.dart';
import 'ajouter_trade_shell_scope.dart';
import '../etat_mental/mental_state_controller.dart';

/// Rétroaction inline état mental — catégories Moment / Émotions puis boutons items.
class AjouterTradeEtatMomentFeedbackMenu extends StatefulWidget {
  const AjouterTradeEtatMomentFeedbackMenu({
    super.key,
    required this.etatMomentPercent,
    required this.controller,
    this.onNonRespectSelectionChanged,
  });

  final double etatMomentPercent;
  final MentalStateController controller;
  final ValueChanged<Set<String>>? onNonRespectSelectionChanged;

  @override
  State<AjouterTradeEtatMomentFeedbackMenu> createState() =>
      _AjouterTradeEtatMomentFeedbackMenuState();
}

class _AjouterTradeEtatMomentFeedbackMenuState
    extends State<AjouterTradeEtatMomentFeedbackMenu> {
  final Set<String> _nonRespectSelection = <String>{};

  void _clearNonRespectIfOffAddTradeTab() {
    final scope = AjouterTradeShellScope.maybeOf(context);
    if (scope == null || scope.shellTabIndex == 2) return;
    if (_nonRespectSelection.isEmpty) return;
    _nonRespectSelection.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
  void didUpdateWidget(covariant AjouterTradeEtatMomentFeedbackMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldP = oldWidget.etatMomentPercent.round().clamp(0, 100);
    final newP = widget.etatMomentPercent.round().clamp(0, 100);
    if (oldP < 95 && newP >= 95) {
      _nonRespectSelection.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onNonRespectSelectionChanged
            ?.call(Set<String>.from(_nonRespectSelection));
      });
      setState(() {});
    }
  }

  List<AjouterTradeFeedbackCategory> _categories(AppLocalizations l) {
    return [
      if (widget.controller.moment.isNotEmpty)
        AjouterTradeFeedbackCategory(
          id: 'moment',
          title: l.ajouterTradeEtatHeaderMoment,
          items: [
            for (final m in widget.controller.moment)
              AjouterTradeFeedbackItem(
                id: 'moment:${m.id}',
                label: m.label,
                subtitle: '${m.value.round().clamp(0, 100)}%',
              ),
          ],
        ),
      if (widget.controller.emotions.isNotEmpty)
        AjouterTradeFeedbackCategory(
          id: 'emotion',
          title: l.ajouterTradeEtatHeaderEmotions,
          items: [
            for (final e in widget.controller.emotions)
              AjouterTradeFeedbackItem(
                id: 'emotion:${e.id}',
                label: e.label,
                subtitle: '${e.value.round().clamp(0, 100)}%',
              ),
          ],
        ),
    ];
  }

  void _toggleId(String id) {
    setState(() {
      if (_nonRespectSelection.contains(id)) {
        _nonRespectSelection.remove(id);
      } else {
        _nonRespectSelection.add(id);
      }
    });
    widget.onNonRespectSelectionChanged?.call(Set<String>.from(_nonRespectSelection));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = widget.etatMomentPercent.round().clamp(0, 100);
    final categories = _categories(l);

    if (p >= 100) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        decoration: BoxDecoration(
          color: DashboardTokens.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: DashboardTokens.accent.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          l.ajouterTradeEtatClosedLabel100,
          style: const TextStyle(
            color: DashboardTokens.accent,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      );
    }

    if (p >= 95) {
      return Text(
        l.ajouterTradeEtatFeedbackAlmost100,
        style: const TextStyle(
          color: DashboardTokens.muted,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          height: 1.35,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.ajouterTradeEtatFeelingPrompt,
          style: TextStyle(
            color: DashboardTokens.negative.withValues(alpha: 0.92),
            fontWeight: FontWeight.w800,
            fontSize: 11,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.ajouterTradeFeedbackTickEach,
          style: const TextStyle(
            color: DashboardTokens.muted,
            fontWeight: FontWeight.w600,
            fontSize: 10,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        AjouterTradeFeedbackCategoryButtons(
          categories: categories,
          selectedIds: _nonRespectSelection,
          onToggle: _toggleId,
        ),
      ],
    );
  }
}
