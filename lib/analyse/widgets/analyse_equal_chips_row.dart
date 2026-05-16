import 'package:flutter/material.dart';

import '../analyse_tokens.dart';

/// Option : libellé + couleur d’accent quand sélectionné (même logique que Achat / Vente / À surveiller).
class AnalyseEqualChipOption<T> {
  const AnalyseEqualChipOption({
    required this.value,
    required this.label,
    required this.accent,
  });

  final T value;
  final String label;
  final Color accent;
}

/// Rangée de puces **même largeur** ([IntrinsicHeight] + [Expanded]), style compact.
///
/// En [pillEditing], chaque puce peut afficher un **X** (retrait) et un bouton **+** carré arrondi à droite (ajout),
/// gérés par [onRemoveOption] / [onAddOption].
class AnalyseEqualChipsRow<T extends Object> extends StatelessWidget {
  const AnalyseEqualChipsRow({
    super.key,
    this.value,
    required this.onChanged,
    required this.options,
    this.pillEditing = false,
    this.onRemoveOption,
    this.onAddOption,
    this.pillEditingWrapSuffix = const [],
    this.allowDeselect = false,
  });

  /// Valeur courante. Si [allowDeselect] est `false` et que c’est `null`, l’affichage retombe sur [options].first.
  final T? value;
  final ValueChanged<T?> onChanged;
  final List<AnalyseEqualChipOption<T>> options;

  /// Si `true`, un second appui sur la puce **déjà** sélectionnée appelle `onChanged(null)` (toutes les puces grises).
  final bool allowDeselect;

  /// Mode édition des pilules (ajout / suppression sans dialogue).
  final bool pillEditing;

  /// Retire une pilule (ex. [AnalyseController.toggleHtfPill]). Le **X** n’apparaît que s’il reste au moins 2 pilules.
  final ValueChanged<T>? onRemoveOption;

  /// Ajoute une pilule (ex. bottom sheet). En mode édition le **+** s’affiche si non `null` ;
  /// le parent peut le fournir dès que [pillEditing] est actif (même si tout est déjà affiché).
  final VoidCallback? onAddOption;

  /// Affichés **à gauche** du bouton [+] en mode édition (ex. pilule de saisie perso).
  final List<Widget> pillEditingWrapSuffix;

  @override
  Widget build(BuildContext context) {
    assert(options.isNotEmpty, 'AnalyseEqualChipsRow: options must not be empty');
    final T? current =
        allowDeselect ? value : (value ?? options.first.value);
    final showRemove = pillEditing && onRemoveOption != null && options.length > 1;
    final showAdd = pillEditing && onAddOption != null;

    void handleChipTap(T option) {
      if (allowDeselect && value == option) {
        onChanged(null);
      } else {
        onChanged(option);
      }
    }

    bool chipSelected(T option) =>
        current != null && current == option;

    if (pillEditing) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < options.length; i++)
                  showRemove
                      ? _CompactChipWithRemove(
                          label: options[i].label,
                          accent: options[i].accent,
                          selected: chipSelected(options[i].value),
                          onTap: () => handleChipTap(options[i].value),
                          onRemove: () => onRemoveOption!(options[i].value),
                        )
                      : _EqualChip(
                          label: options[i].label,
                          accent: options[i].accent,
                          selected: chipSelected(options[i].value),
                          onTap: () => handleChipTap(options[i].value),
                          fillCell: false,
                        ),
              ],
            ),
          ),
          for (final w in pillEditingWrapSuffix) ...[
            const SizedBox(width: 8),
            w,
          ],
          if (showAdd) ...[
            const SizedBox(width: 8),
            _AddPillButton(onTap: onAddOption!),
          ],
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _EqualChip(
                label: options[i].label,
                accent: options[i].accent,
                selected: chipSelected(options[i].value),
                onTap: () => handleChipTap(options[i].value),
                fillCell: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Puce compacte + bouton fermer (mode édition).
class _CompactChipWithRemove extends StatelessWidget {
  const _CompactChipWithRemove({
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 8),
          child: _EqualChip(
            label: label,
            accent: accent,
            selected: selected,
            onTap: onTap,
            fillCell: false,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: AnalyseTokens.muted,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPillButton extends StatelessWidget {
  const _AddPillButton({required this.onTap});

  final VoidCallback onTap;

  static const double _r = 8;

  @override
  Widget build(BuildContext context) {
    final rr = BorderRadius.circular(_r);
    return Tooltip(
      message: 'Ajouter une pilule',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: rr,
          child: SizedBox(
            width: 34,
            height: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AnalyseTokens.chipBg,
                borderRadius: rr,
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: AnalyseTokens.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EqualChip extends StatelessWidget {
  const _EqualChip({
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
    this.fillCell = true,
  });

  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  /// `true` : occupe toute la largeur du parent ([Expanded]), puces égales.
  /// `false` : largeur selon le texte, pour [Wrap] en mode édition.
  final bool fillCell;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? accent.withValues(alpha: 0.18) : AnalyseTokens.chipBg;
    final fg = selected ? accent : AnalyseTokens.muted;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: fillCell ? double.infinity : null,
      height: fillCell ? double.infinity : null,
      constraints: fillCell
          ? null
          : const BoxConstraints(
              minHeight: 36,
              minWidth: 44,
            ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: fillCell ? 6 : 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusChip),
        border: Border.all(
          color: selected ? accent.withValues(alpha: 0.72) : const Color(0xFF1E242E),
          width: selected ? 1.25 : 1,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusChip),
        child: fillCell ? child : IntrinsicWidth(child: child),
      ),
    );
  }
}
