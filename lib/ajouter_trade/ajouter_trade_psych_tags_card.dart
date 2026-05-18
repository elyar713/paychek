import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/dashboard_tokens.dart';

/// Rayon des coins des pastilles (carré visuel, coins légèrement arrondis).
const double kAjouterTradePsychTagCornerRadius = 14;

/// Carte bas de page : tags FOMO / TILT — ajout inline, long appui pour supprimer.
class AjouterTradePsychTagsCard extends StatelessWidget {
  const AjouterTradePsychTagsCard({
    super.key,
    required this.labels,
    required this.selected,
    required this.onToggle,
    required this.onRemoveTag,
    required this.showNewTagField,
    required this.newTagController,
    required this.newTagFocus,
    required this.onNewTagSubmitted,
    required this.onPlusTap,
    this.titleStyle,
    this.cardDecoration,
    this.sectionTitleColor,
  });

  final BoxDecoration? cardDecoration;
  final Color? sectionTitleColor;

  final List<String> labels;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onRemoveTag;
  final bool showNewTagField;
  final TextEditingController newTagController;
  final FocusNode newTagFocus;
  final VoidCallback onNewTagSubmitted;
  final VoidCallback onPlusTap;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final maxChipW = (screenW - 64).clamp(100.0, 280.0);

    return Container(
      width: double.infinity,
      padding: DashboardTokens.cardPadding,
      decoration: cardDecoration ?? DashboardTokens.cardBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TAG',
            style: (titleStyle ??
                    const TextStyle(
                      color: DashboardTokens.onMatteEmphasis,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.35,
                    ))
                .copyWith(
              color: sectionTitleColor ?? DashboardTokens.titleGold,
              fontSize: 9,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final label in labels)
                _PsychTagTile(
                  label: label,
                  selected: selected.contains(label),
                  maxChipW: maxChipW,
                  onTap: () => onToggle(label),
                  onLongPress: () => onRemoveTag(label),
                ),
              if (showNewTagField)
                _PsychNewTagField(
                  maxChipW: maxChipW,
                  controller: newTagController,
                  focusNode: newTagFocus,
                  onSubmitted: onNewTagSubmitted,
                ),
              _AddPsychTagTile(onTap: onPlusTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _PsychTagTile extends StatelessWidget {
  const _PsychTagTile({
    required this.label,
    required this.selected,
    required this.maxChipW,
    required this.onTap,
    required this.onLongPress,
  });

  final String label;
  final bool selected;
  final double maxChipW;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(kAjouterTradePsychTagCornerRadius),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxChipW),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: DashboardTokens.scaffoldMatte,
              borderRadius: BorderRadius.circular(kAjouterTradePsychTagCornerRadius),
              border: Border.all(
                width: selected ? 1.5 : 1,
                color: selected
                    ? DashboardTokens.accent
                    : DashboardTokens.cardBoxBorder,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                softWrap: true,
                style: const TextStyle(
                  color: DashboardTokens.onMatteEmphasis,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PsychNewTagField extends StatelessWidget {
  const _PsychNewTagField({
    required this.maxChipW,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final double maxChipW;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: maxChipW,
        minHeight: 34,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DashboardTokens.scaffoldMatte,
          borderRadius: BorderRadius.circular(kAjouterTradePsychTagCornerRadius),
          border: Border.all(
            color: DashboardTokens.accent,
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(
            color: DashboardTokens.onMatteEmphasis,
            fontWeight: FontWeight.w700,
            fontSize: 9,
            height: 1.1,
          ),
          cursorColor: DashboardTokens.accent,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: '…',
            hintStyle: TextStyle(
              color: DashboardTokens.muted,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(48),
          ],
          onSubmitted: (_) {
            onSubmitted();
            focusNode.unfocus();
          },
        ),
      ),
    );
  }
}

class _AddPsychTagTile extends StatelessWidget {
  const _AddPsychTagTile({required this.onTap});

  final VoidCallback onTap;

  static const double _side = 34;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kAjouterTradePsychTagCornerRadius),
        child: SizedBox(
          width: _side,
          height: _side,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: DashboardTokens.scaffoldMatte,
              borderRadius: BorderRadius.circular(kAjouterTradePsychTagCornerRadius),
              border: Border.all(
                color: DashboardTokens.cardBoxBorder,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 18,
                color: DashboardTokens.labelGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
