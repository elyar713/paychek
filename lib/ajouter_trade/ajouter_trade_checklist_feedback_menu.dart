import 'package:flutter/material.dart';

import '../checklist/checklist_page_controller.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../l10n/checklist_localizations.dart';
import 'ajouter_trade_feedback_category_buttons.dart';
import 'ajouter_trade_shell_scope.dart';

/// Rétroaction inline checklist — une catégorie par section, items en boutons.
class AjouterTradeChecklistFeedbackMenu extends StatefulWidget {
  const AjouterTradeChecklistFeedbackMenu({
    super.key,
    required this.checklistRespectPercent,
    required this.controller,
    this.onNonRespectSelectionChanged,
  });

  final double checklistRespectPercent;
  final ChecklistPageController controller;
  final ValueChanged<Set<String>>? onNonRespectSelectionChanged;

  @override
  State<AjouterTradeChecklistFeedbackMenu> createState() =>
      _AjouterTradeChecklistFeedbackMenuState();
}

class _AjouterTradeChecklistFeedbackMenuState
    extends State<AjouterTradeChecklistFeedbackMenu> {
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
  void didUpdateWidget(covariant AjouterTradeChecklistFeedbackMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldP = oldWidget.checklistRespectPercent.round().clamp(0, 100);
    final newP = widget.checklistRespectPercent.round().clamp(0, 100);
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
      for (final s in widget.controller.sections)
        if (s.items.isNotEmpty)
          AjouterTradeFeedbackCategory(
            id: s.id,
            title: checklistSectionTitle(l, s.id, s.title),
            items: [
              for (final it in s.items)
                AjouterTradeFeedbackItem(
                  id: '${s.id}:${it.id}',
                  label: checklistItemLabel(l, it.id, it.label),
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
    final p = widget.checklistRespectPercent.round().clamp(0, 100);
    final categories = _categories(l);

    if (categories.isEmpty) {
      return const Text(
        '—',
        style: TextStyle(
          color: DashboardTokens.muted,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      );
    }

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
          l.ajouterTradeChecklistFeedbackBravo,
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
        l.ajouterTradeChecklistFeedbackAlmost100,
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
          l.ajouterTradeChecklistFeedbackWhichMissed,
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
