import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ajouter_trade/ajouter_trade_page_non_respect_labels.dart';
import '../ajouter_trade/ajouter_trade_plan_analyse_feedback_items.dart';
import '../checklist/checklist_page_controller.dart';
import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../l10n/checklist_localizations.dart';
import '../etat_mental/mental_state_controller.dart';
import '../questionnaire/user_capital_scope.dart';
import '../reglage/user_portfolio_scope.dart';
import 'trade_date_format.dart';
import 'trade_models.dart';
import 'trade_session.dart';
import 'trade_tokens.dart';

part 'trade_card_build.dart';

class TradeCard extends StatelessWidget {
  const TradeCard({
    super.key,
    required this.item,
    required this.expanded,
    required this.onToggle,
    required this.onTapOutsideWhenExpanded,
    required this.tradeNumberOfDay,
    required this.checklistController,
    required this.onEdit,
    required this.onDelete,
    required this.onExportPdf,
  });

  final TradeListItem item;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onTapOutsideWhenExpanded;
  final int tradeNumberOfDay;
  final ChecklistPageController checklistController;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExportPdf;

  String _sessionLabel(AppLocalizations l10n, DateTime d) =>
      tradeSessionLabel(l10n, tradeSessionBucketId(d));

  String _formatHourMinute(DateTime d) {
    String p2(int n) => n.toString().padLeft(2, '0');
    final l = d.toLocal();
    return '${p2(l.hour)}:${p2(l.minute)}';
  }

  String _formatDuration(AppLocalizations l10n, Duration d) {
    final totalMin = d.inMinutes.abs();
    final hh = totalMin ~/ 60;
    final mm = totalMin % 60;
    if (hh <= 0) return l10n.tradeDurationMinutes(mm);
    return l10n.tradeDurationHoursMinutes(hh, mm.toString().padLeft(2, '0'));
  }

  ({IconData icon, String label, Color color}) _mindsetUi(AppLocalizations l10n) {
    switch (item.mindset) {
      case TradeMindset.principe:
        return (
          icon: Icons.verified_rounded,
          label: l10n.tradeMindsetPrinciple,
          color: TradeTokens.profitNeon,
        );
      case TradeMindset.feeling:
        return (
          icon: Icons.psychology_alt_rounded,
          label: l10n.tradeMindsetFeeling,
          color: TradeTokens.lossNeon,
        );
    }
  }

  List<String> _resolveChecklistNonRespect(AppLocalizations l) {
    final out = <String>[];
    for (final id in item.checklistNonRespectIds) {
      final parts = id.split(':');
      if (parts.length != 2) {
        out.add(id);
        continue;
      }
      final sectionId = parts[0];
      final itemId = parts[1];
      for (final s in checklistController.sections) {
        if (s.id != sectionId) continue;
        for (final it in s.items) {
          if (it.id == itemId) {
            out.add(checklistItemLabel(l, itemId, it.label));
            break;
          }
        }
      }
    }
    return out;
  }

  List<String> _resolveEtatNonRespect() {
    final out = <String>[];
    final c = MentalStateController.instance;
    for (final id in item.etatNonRespectIds) {
      final parts = id.split(':');
      if (parts.length != 2) {
        out.add(id);
        continue;
      }
      final kind = parts[0];
      final key = parts[1];
      if (kind == 'moment') {
        final m = c.moment.where((e) => e.id == key).toList();
        if (m.isNotEmpty) out.add(m.first.label);
        continue;
      }
      if (kind == 'emotion') {
        final e = c.emotions.where((e) => e.id == key).toList();
        if (e.isNotEmpty) out.add(e.first.label);
        continue;
      }
      out.add(id);
    }
    return out;
  }

  List<String> _resolveStrategieNonRespect(AppLocalizations l10n, Locale locale) {
    return item.strategieNonRespectIds
        .map(
          (id) => labelForStrategieNonRespectId(
            id,
            item.strategieTitle,
            l: l10n,
            locale: locale,
          ),
        )
        .toList();
  }

  List<String> _resolvePlanNonRespect(AppLocalizations l10n) {
    final report = item.planReport;
    if (report == null) {
      return item.planNonRespectIds.toList();
    }
    final entries = planAnalyseFeedbackEntriesFor(report, l10n);
    final rows = entries.whereType<PlanAnalyseFeedbackRow>().toList();
    final out = <String>[];
    for (final id in item.planNonRespectIds) {
      final row = rows.where((r) => r.id == id).toList();
      if (row.isEmpty) {
        out.add(id);
      } else {
        final r = row.first;
        final h = (r.hint ?? '').trim();
        out.add(h.isEmpty ? r.label : '${r.label} : $h');
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return _buildTradeCard(context);
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: TradeTokens.pillInactiveBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TradeTokens.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.labelSmall?.copyWith(
                color: TradeTokens.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: t.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          '$label: ',
          style: t.labelSmall?.copyWith(
            color: TradeTokens.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniSectionTitle extends StatelessWidget {
  const _MiniSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: t.labelSmall?.copyWith(
          color: DashboardTokens.titleGold,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MiniBullet extends StatelessWidget {
  const _MiniBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '• $text',
        style: t.bodySmall?.copyWith(
          color: TradeTokens.textSecondary,
          fontSize: 11,
          height: 1.25,
        ),
      ),
    );
  }
}
