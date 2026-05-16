import 'package:flutter/material.dart';

/// Index d’onglet du [DashboardPage] (0–4), fourni au-dessus du contenu **Ajouter un trade**.
///
/// Les widgets qui insèrent un [OverlayEntry] doivent fermer leurs overlays lorsque
/// [shellTabIndex] != 2, car l’overlay n’est pas descendant des [ExcludeFocus] du shell
/// et peut laisser des dépendances de focus incohérentes (assertion `_FocusInheritedScope`).
class AjouterTradeShellScope extends InheritedWidget {
  const AjouterTradeShellScope({
    super.key,
    required this.shellTabIndex,
    required super.child,
  });

  /// Même sémantique que `_bodyIndex` dans `dashboard_page.dart` (2 = onglet Ajouter).
  final int shellTabIndex;

  static AjouterTradeShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AjouterTradeShellScope>();
  }

  @override
  bool updateShouldNotify(AjouterTradeShellScope oldWidget) =>
      shellTabIndex != oldWidget.shellTabIndex;
}
