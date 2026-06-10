import 'package:flutter/material.dart';

import '../analyse/analyse_report_snapshot.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_feedback_category_buttons.dart';
import 'ajouter_trade_plan_analyse_feedback_items.dart';
import 'ajouter_trade_shell_scope.dart';

/// Rétroaction inline — catégories du rapport d’analyse puis boutons items (non respectés).
class AjouterTradePlanAnalyseFeedbackMenu extends StatefulWidget {
  const AjouterTradePlanAnalyseFeedbackMenu({
    super.key,
    required this.planRespectPercent,
    required this.selectedReport,
    this.onNonRespectSelectionChanged,
  });

  final double planRespectPercent;
  final AnalyseReportSnapshot? selectedReport;
  final ValueChanged<Set<String>>? onNonRespectSelectionChanged;

  @override
  State<AjouterTradePlanAnalyseFeedbackMenu> createState() =>
      _AjouterTradePlanAnalyseFeedbackMenuState();
}

class _AjouterTradePlanAnalyseFeedbackMenuState
    extends State<AjouterTradePlanAnalyseFeedbackMenu> {
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
  void didUpdateWidget(covariant AjouterTradePlanAnalyseFeedbackMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    var cleared = false;
    final old = oldWidget.selectedReport;
    final cur = widget.selectedReport;
    final changed = (old?.actif != cur?.actif) || (old?.sousTitre != cur?.sousTitre);
    if (changed) {
      _nonRespectSelection.clear();
      cleared = true;
    }
    final oldP = oldWidget.planRespectPercent.round().clamp(0, 100);
    final newP = widget.planRespectPercent.round().clamp(0, 100);
    if (oldP < 95 && newP >= 95) {
      _nonRespectSelection.clear();
      cleared = true;
    }
    if (cleared) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onNonRespectSelectionChanged
            ?.call(Set<String>.from(_nonRespectSelection));
      });
      setState(() {});
    }
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
    final report = widget.selectedReport;
    final p = widget.planRespectPercent.round().clamp(0, 100);

    if (report == null) {
      return Text(
        l.ajouterTradePlanPickReportAbove,
        style: const TextStyle(
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
          l.ajouterTradePlanFeedbackBravo,
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
        l.ajouterTradePlanFeedbackAlmost100,
        style: const TextStyle(
          color: DashboardTokens.muted,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          height: 1.35,
        ),
      );
    }

    final categories = planAnalyseFeedbackCategoriesFor(report, l);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${report.actif} — ${report.sousTitre}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: DashboardTokens.onMatteEmphasis,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.ajouterTradePlanFeedbackWhichMissed,
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
