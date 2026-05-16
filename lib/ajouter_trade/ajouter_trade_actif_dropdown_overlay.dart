import 'dart:math' show min;

import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';

/// Contenu du menu overlay (étoiles, liste d’actifs, option « Ajouter un actif »).
class AjouterTradeActifDropdownOverlayPane extends StatelessWidget {
  const AjouterTradeActifDropdownOverlayPane({
    super.key,
    required this.layerLink,
    required this.width,
    required this.items,
    required this.pillLabel,
    required this.itemStyle,
    required this.onDismissTap,
    required this.onSelectSymbol,
    required this.favoriteActifs,
    required this.onToggleFavorite,
    this.onCustomActifAdded,
    required this.showNewActifPill,
    required this.newActifController,
    required this.newActifFocus,
    required this.onTapAddActifRow,
    required this.onSubmitNewActif,
  });

  final LayerLink layerLink;
  final double width;
  final List<String> items;
  final String pillLabel;
  final TextStyle itemStyle;
  final VoidCallback onDismissTap;
  final ValueChanged<String> onSelectSymbol;
  final Set<String> favoriteActifs;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<String>? onCustomActifAdded;

  final bool showNewActifPill;
  final TextEditingController newActifController;
  final FocusNode newActifFocus;
  final VoidCallback onTapAddActifRow;
  final VoidCallback onSubmitNewActif;

  static const double _menuItemH = 40;
  static const double _menuListMaxHeight = 280;
  static const double _starColW = 38;
  static const double _starIconSize = 18;
  static const double _fieldH = 36;
  static const double _radius = 10;
  static const Color _starOn = Color(0xFFE8C547);

  @override
  Widget build(BuildContext context) {
    final rowH = _menuItemH;
    final orderedItems = () {
      if (items.isEmpty) return items;
      if (favoriteActifs.isEmpty) return items;
      final favs = <String>[];
      final rest = <String>[];
      for (final e in items) {
        if (favoriteActifs.contains(e)) {
          favs.add(e);
        } else {
          rest.add(e);
        }
      }
      return <String>[...favs, ...rest];
    }();

    Widget overlayActifRow(String e) {
      return Container(
        height: rowH,
        color: e == pillLabel
            ? DashboardTokens.accent.withValues(alpha: 0.12)
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _starColW,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onToggleFavorite(e),
                  child: Center(
                    child: Icon(
                      favoriteActifs.contains(e)
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: _starIconSize,
                      color: favoriteActifs.contains(e)
                          ? _starOn
                          : DashboardTokens.labelGrey,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onDismissTap();
                    onSelectSymbol(e);
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Center(
                        child: Text(
                          e,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: itemStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // IMPORTANT: l'Overlay peut fournir des contraintes « loose » ; on force une
    // taille finie pour éviter les erreurs "infinite size during layout".
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismissTap,
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: Material(
                elevation: 8,
                color: DashboardTokens.cardBoxBg,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius),
                  side: const BorderSide(
                    color: DashboardTokens.cardBoxBorder,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (onCustomActifAdded != null) ...[
                      if (showNewActifPill)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                          child: Container(
                            height: _fieldH,
                            decoration: BoxDecoration(
                              color: DashboardTokens.cardBoxBg,
                              borderRadius: BorderRadius.circular(_radius),
                              border: Border.all(
                                color: DashboardTokens.cardBoxBorder,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: newActifController,
                                    focusNode: newActifFocus,
                                    style: itemStyle,
                                    textAlign: TextAlign.center,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => onSubmitNewActif(),
                                    cursorColor: DashboardTokens.accent,
                                    decoration: InputDecoration(
                                      hintText: 'Symbole ou paire',
                                      hintStyle: itemStyle.copyWith(
                                        color: DashboardTokens.muted
                                            .withValues(alpha: 0.55),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 10,
                                      ),
                                      isCollapsed: true,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                    icon: Icon(
                                      Icons.check_rounded,
                                      color: DashboardTokens.accent,
                                      size: 22,
                                    ),
                                    onPressed: onSubmitNewActif,
                                    tooltip: 'Valider',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onTapAddActifRow,
                          child: SizedBox(
                            height: _menuItemH,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: _starColW,
                                  child: Center(
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: _starIconSize,
                                      color: DashboardTokens.accent,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8),
                                      child: Text(
                                        'Ajouter un actif',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: itemStyle.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: DashboardTokens.accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: DashboardTokens.cardBoxBorder,
                      ),
                    ],
                    if (items.isNotEmpty)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: min(
                            _menuListMaxHeight,
                            orderedItems.length * rowH,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final e in orderedItems) overlayActifRow(e),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
