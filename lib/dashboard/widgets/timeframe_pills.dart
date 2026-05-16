import 'package:flutter/material.dart';

import '../dashboard_tokens.dart';

/// Petite case 1J / 1S / 1M / ALL : compacte, coins légèrement arrondis.
/// Largeur fixe — ne s’étire pas sur toute la ligne.
class TimeframePills extends StatelessWidget {
  const TimeframePills({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.width,
    this.trackColor,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
    this.unselectedLabelColor,
  });

  /// Largeur cible par défaut (barre compacte).
  static const double kDefaultWidth = 152;

  final double? width;
  final Color? trackColor;
  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;
  final Color? unselectedLabelColor;

  static const double _outerRadius = 8;
  /// Rayon des coins du segment vert (un peu plus petit que l’intérieur du cadre).
  static const double _selectedRadius = 5;

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final w = width ?? TimeframePills.kDefaultWidth;
    final bg = trackColor ?? DashboardTokens.cardBoxBg;
    final selBg = selectedBackgroundColor ?? DashboardTokens.accentDeep;
    final selFg = selectedForegroundColor ?? Colors.black87;
    final unsel = unselectedLabelColor ?? Colors.white70;
    return SizedBox(
      width: w,
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(_outerRadius),
        ),
        child: Row(
          children: List.generate(labels.length, (i) {
            final sel = i == selectedIndex;
            final n = labels.length;
            final BorderRadius? radiusSel = sel
                ? _selectedBorderRadius(i, n)
                : null;
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: radiusSel ?? BorderRadius.zero,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? selBg : Colors.transparent,
                      borderRadius: radiusSel,
                    ),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        color: sel ? selFg : unsel,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Coins du segment actif : arrondis extérieurs alignés sur le cadre, léger arrondi au milieu.
  static BorderRadius _selectedBorderRadius(int index, int count) {
    const r = _selectedRadius;
    final rMid = r * 0.55;
    if (count <= 1) return BorderRadius.circular(r);
    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(r),
        bottomLeft: Radius.circular(r),
        topRight: Radius.circular(rMid),
        bottomRight: Radius.circular(rMid),
      );
    }
    if (index == count - 1) {
      return BorderRadius.only(
        topRight: Radius.circular(r),
        bottomRight: Radius.circular(r),
        topLeft: Radius.circular(rMid),
        bottomLeft: Radius.circular(rMid),
      );
    }
    return BorderRadius.circular(r);
  }
}
