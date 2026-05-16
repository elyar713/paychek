import 'package:flutter/material.dart';

import 'checklist_page_controller.dart';
import 'checklist_page_view.dart';

/// Page « Nouveau Trade » : 3 sections + menu ⋯ + ajout de section.
///
/// [controller] est typiquement fourni par [DashboardPage] pour partager l’état
/// avec l’aperçu sur l’accueil.
class ChecklistPage extends StatefulWidget {
  const ChecklistPage({
    super.key,
    required this.controller,
    this.onBack,
    this.liteFreemiumRestricted = false,
    this.onLiteFreemiumRestrictedTap,
  });

  final ChecklistPageController controller;

  /// Retour → Dashboard (onglet).
  final VoidCallback? onBack;
  final bool liteFreemiumRestricted;
  final VoidCallback? onLiteFreemiumRestrictedTap;

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  void _onBack() {
    if (!widget.controller.prepareBackNavigation()) return;
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => ChecklistPageView(
        controller: widget.controller,
        onBack: _onBack,
        liteFreemiumRestricted: widget.liteFreemiumRestricted,
        onLiteFreemiumRestrictedTap: widget.onLiteFreemiumRestrictedTap,
      ),
    );
  }
}
