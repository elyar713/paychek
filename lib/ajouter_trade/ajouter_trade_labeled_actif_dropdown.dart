import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import 'ajouter_trade_actif_dropdown_overlay.dart';
import 'ajouter_trade_shell_scope.dart';

/// Libellé + pilule ; menu sous la pilule (même largeur), **étoile** favori par ligne.
class AjouterTradeLabeledActifDropdown extends StatefulWidget {
  const AjouterTradeLabeledActifDropdown({
    super.key,
    required this.label,
    required this.labelStyle,
    required this.value,
    required this.items,
    required this.onChanged,
    this.valueFontSize,
    this.onCustomActifAdded,
    this.persistedFavoriteActif,
    this.onPersistFavoriteToggle,
  });

  final String label;
  final TextStyle? labelStyle;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final double? valueFontSize;

  /// Si défini : ligne « + Ajouter » + pilule de saisie au-dessus (ex. dialogue engrenage).
  final ValueChanged<String>? onCustomActifAdded;

  /// Actif favori persisté (une étoile) pour ce marché ; [onPersistFavoriteToggle] requis pour l’utiliser.
  final String? persistedFavoriteActif;

  /// `add`: true = enregistrer [symbol] comme favori, false = retirer l’étoile pour [symbol].
  final void Function(String symbol, {required bool add})? onPersistFavoriteToggle;

  @override
  State<AjouterTradeLabeledActifDropdown> createState() =>
      _AjouterTradeLabeledActifDropdownState();
}

class _AjouterTradeLabeledActifDropdownState
    extends State<AjouterTradeLabeledActifDropdown> {
  final GlobalKey _pillKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _menuEntry;

  /// Favoris par libellé d’actif (mémoire vive si pas de persistance parent).
  final Set<String> _favoriteActifs = {};

  Set<String> get _effectiveFavoriteSet {
    final p = widget.persistedFavoriteActif;
    final usePersist = widget.onPersistFavoriteToggle != null;
    if (usePersist && p != null && p.trim().isNotEmpty) {
      return {p.trim()};
    }
    if (usePersist) return {};
    return _favoriteActifs;
  }

  final TextEditingController _newActifController = TextEditingController();
  final FocusNode _newActifFocus = FocusNode();
  bool _showNewActifPill = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AjouterTradeShellScope.maybeOf(context);
    if (scope != null && scope.shellTabIndex != 2 && _menuEntry != null) {
      _closeMenu();
    }
  }

  static const double _fieldH = 36;
  static const double _radius = 10;

  void _toggleFavorite(String symbol) {
    final persist = widget.onPersistFavoriteToggle;
    if (persist != null) {
      final cur = widget.persistedFavoriteActif?.trim();
      final add = cur != symbol;
      persist(symbol, add: add);
      _menuEntry?.markNeedsBuild();
      return;
    }
    setState(() {
      if (_favoriteActifs.contains(symbol)) {
        _favoriteActifs.remove(symbol);
      } else {
        _favoriteActifs.add(symbol);
      }
    });
    _menuEntry?.markNeedsBuild();
  }

  void _closeMenu() {
    final hadOverlay = _menuEntry != null;
    _menuEntry?.remove();
    _menuEntry = null;
    // Ne pas setState si aucun menu : évite un rebuild inutile avant Overlay.of
    // (et cas « ancestor désactivé » si le parent remplace l’arbre).
    if (hadOverlay && mounted) {
      setState(() {
        _showNewActifPill = false;
        _newActifController.clear();
      });
    }
  }

  void _onTapAddActifRow() {
    setState(() => _showNewActifPill = true);
    _menuEntry?.markNeedsBuild();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _newActifFocus.requestFocus();
    });
  }

  void _submitNewActif() {
    final raw = _newActifController.text.trim();
    if (raw.isEmpty) return;
    final add = widget.onCustomActifAdded;
    if (add == null) return;
    if (widget.items.contains(raw)) {
      widget.onChanged(raw);
      _closeMenu();
      return;
    }
    add(raw);
    _closeMenu();
  }

  void _onPillTap() {
    if (_menuEntry != null) {
      _closeMenu();
      return;
    }
    _openMenu();
  }

  void _openMenu() {
    if (widget.items.isEmpty && widget.onCustomActifAdded == null) return;
    if (!mounted) return;
    final box = _pillKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final w = box.size.width;
    _closeMenu();
    if (!mounted) return;

    final fs = widget.valueFontSize ?? 12.0;
    final itemStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
              color: DashboardTokens.onMatteEmphasis,
              fontWeight: FontWeight.w800,
              fontSize: fs,
            ) ??
            TextStyle(
              color: DashboardTokens.onMatteEmphasis,
              fontWeight: FontWeight.w800,
              fontSize: fs,
            );

    final pillLabel = _pillDisplayLabel();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        return AjouterTradeActifDropdownOverlayPane(
          layerLink: _layerLink,
          width: w,
          items: widget.items,
          pillLabel: pillLabel,
          itemStyle: itemStyle,
          onDismissTap: _closeMenu,
          onSelectSymbol: widget.onChanged,
          favoriteActifs: _effectiveFavoriteSet,
          onToggleFavorite: _toggleFavorite,
          onCustomActifAdded: widget.onCustomActifAdded,
          showNewActifPill: _showNewActifPill,
          newActifController: _newActifController,
          newActifFocus: _newActifFocus,
          onTapAddActifRow: _onTapAddActifRow,
          onSubmitNewActif: _submitNewActif,
        );
      },
    );

    if (!mounted) return;
    Overlay.of(context).insert(entry);
    _menuEntry = entry;
  }

  @override
  void dispose() {
    _menuEntry?.remove();
    _menuEntry = null;
    _newActifFocus.dispose();
    _newActifController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AjouterTradeLabeledActifDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.items, widget.items)) {
      _closeMenu();
    }
    if (oldWidget.persistedFavoriteActif != widget.persistedFavoriteActif) {
      // Éviter markNeedsBuild pendant le build (assertion overlay).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _menuEntry?.markNeedsBuild();
      });
    }
  }

  /// Texte pilule : preset canonique si dans la liste, sinon symbole saisi ailleurs.
  String _pillDisplayLabel() {
    final v = widget.value.trim();
    if (v.isEmpty) {
      return widget.items.isNotEmpty ? widget.items.first : '';
    }
    for (final e in widget.items) {
      if (e == widget.value || e.trim() == v) return e;
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    final fs = widget.valueFontSize ?? 12.0;
    final itemStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
              color: DashboardTokens.onMatteEmphasis,
              fontWeight: FontWeight.w800,
              fontSize: fs,
            ) ??
            TextStyle(
              color: DashboardTokens.onMatteEmphasis,
              fontWeight: FontWeight.w800,
              fontSize: fs,
            );

    final pillLabel = _pillDisplayLabel();

    final fieldBox = CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        key: _pillKey,
        color: Colors.transparent,
        child: InkWell(
          onTap: _onPillTap,
          borderRadius: BorderRadius.circular(_radius),
          child: Container(
            height: _fieldH,
            padding: const EdgeInsets.only(left: 8, right: 4),
            decoration: BoxDecoration(
              color: DashboardTokens.cardBoxBg,
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: DashboardTokens.cardBoxBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    pillLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: itemStyle,
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 22,
                  color: DashboardTokens.labelGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: widget.labelStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        fieldBox,
      ],
    );
  }
}
