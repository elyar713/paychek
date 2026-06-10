import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';

/// Un élément sélectionnable (point non respecté).
class AjouterTradeFeedbackItem {
  const AjouterTradeFeedbackItem({
    required this.id,
    required this.label,
    this.subtitle,
  });

  final String id;
  final String label;
  final String? subtitle;
}

/// Groupe : ex. Golden rules, Timeframes, Checklist « Pré-session », etc.
class AjouterTradeFeedbackCategory {
  const AjouterTradeFeedbackCategory({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<AjouterTradeFeedbackItem> items;
}

/// Catégories en boutons ; clic catégorie → ligne de boutons items en dessous.
class AjouterTradeFeedbackCategoryButtons extends StatefulWidget {
  const AjouterTradeFeedbackCategoryButtons({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onToggle,
    this.enabled = true,
  });

  final List<AjouterTradeFeedbackCategory> categories;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final bool enabled;

  @override
  State<AjouterTradeFeedbackCategoryButtons> createState() =>
      _AjouterTradeFeedbackCategoryButtonsState();
}

class _AjouterTradeFeedbackCategoryButtonsState
    extends State<AjouterTradeFeedbackCategoryButtons> {
  String? _expandedCategoryId;

  static List<AjouterTradeFeedbackItem> _visibleItems(
    List<AjouterTradeFeedbackItem> items,
  ) {
    return [
      for (final it in items)
        if (_isVisibleItem(it)) it,
    ];
  }

  static bool _isVisibleItem(AjouterTradeFeedbackItem it) {
    final t = it.label.trim();
    return t.isNotEmpty && t != '—';
  }

  @override
  void didUpdateWidget(covariant AjouterTradeFeedbackCategoryButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_expandedCategoryId != null) {
      final stillExists = widget.categories.any((c) => c.id == _expandedCategoryId);
      if (!stillExists) _expandedCategoryId = null;
    }
  }

  AjouterTradeFeedbackCategory? get _expanded {
    final id = _expandedCategoryId;
    if (id == null) return null;
    for (final c in widget.categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  int _selectedCountInCategory(AjouterTradeFeedbackCategory c) {
    var n = 0;
    for (final it in _visibleItems(c.items)) {
      if (widget.selectedIds.contains(it.id)) n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.categories
        .map(
          (c) => AjouterTradeFeedbackCategory(
            id: c.id,
            title: c.title,
            items: _visibleItems(c.items),
          ),
        )
        .where((c) => c.items.isNotEmpty)
        .toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final expanded = _expanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in visible)
              _CategoryChip(
                title: c.title,
                selected: _expandedCategoryId == c.id,
                badgeCount: _selectedCountInCategory(c),
                onTap: widget.enabled
                    ? () {
                        setState(() {
                          _expandedCategoryId =
                              _expandedCategoryId == c.id ? null : c.id;
                        });
                      }
                    : null,
              ),
          ],
        ),
        if (expanded != null && expanded.items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final it in expanded.items)
                _ItemChip(
                  label: it.label,
                  subtitle: it.subtitle,
                  selected: widget.selectedIds.contains(it.id),
                  onTap: widget.enabled ? () => widget.onToggle(it.id) : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.title,
    required this.selected,
    required this.badgeCount,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final int badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? DashboardTokens.titleGold.withValues(alpha: 0.85)
        : DashboardTokens.cardBoxBorder;
    final bg = selected
        ? DashboardTokens.titleGold.withValues(alpha: 0.12)
        : DashboardTokens.scaffoldMatte;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: selected
                      ? DashboardTokens.titleGold
                      : DashboardTokens.onMatteEmphasis,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.2,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: DashboardTokens.negative.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: DashboardTokens.negative.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  const _ItemChip({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? DashboardTokens.negative.withValues(alpha: 0.9)
        : DashboardTokens.cardBoxBorder;
    final bg = selected
        ? DashboardTokens.negative.withValues(alpha: 0.14)
        : DashboardTokens.cardBoxBg;
    final fg = selected
        ? DashboardTokens.negative.withValues(alpha: 0.95)
        : DashboardTokens.onMatteEmphasis;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: DashboardTokens.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
