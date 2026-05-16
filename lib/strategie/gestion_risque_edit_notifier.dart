import 'package:flutter/material.dart';

/// Coordonne le « tap hors zone » sur **toute la page** pour :
/// - **Gestion du risque — Modifier** : valider (hors cases noires et menu ⋮) ;
/// - **Gestion du risque — Désactivé** : valider interrupteurs (hors switches et menu ⋮) ;
/// - **Horaires & sessions — Modifier** : valider (hors lignes session et menu ⋮) ;
/// - **Setups & modèles — Modifier** : valider (hors cartes et menu ⋮).
class GestionRisqueEditNotifier {
  bool isEditing = false;
  List<GlobalKey> editKeys = [];
  GlobalKey? menuKey;
  VoidCallback? onCommitOutside;

  bool isConfiguringDisable = false;
  List<GlobalKey> disableExcludeKeys = [];
  VoidCallback? onCommitDisableOutside;

  /// Fermeture mutuelle : la section GR enregistre ; Horaires l’appelle avant son édition.
  VoidCallback? onForceCloseGestionRisqueEdit;

  /// Fermeture mutuelle : Horaires enregistre ; GR l’appelle avant édition / mode Désactivé.
  VoidCallback? onForceCloseHorairesEdit;

  /// Fermeture mutuelle : Setups enregistre ; GR / Horaires l’appellent avant édition.
  VoidCallback? onForceCloseSetupsEdit;

  bool horairesEditing = false;
  GlobalKey? horairesMenuKey;
  List<GlobalKey> horairesExcludeKeys = [];
  VoidCallback? onCommitHorairesOutside;

  bool setupsEditing = false;
  GlobalKey? setupsMenuKey;
  List<GlobalKey> setupsExcludeKeys = [];
  VoidCallback? onCommitSetupsOutside;

  /// Valide / ferme l’édition au **relâchement** du doigt (pas au `down`) :
  /// sinon le premier tap sur un [TextField] est avalé et la saisie est impossible.
  void handlePointerUp(PointerUpEvent e) {
    if (isEditing && onCommitOutside != null) {
      if (_hit(menuKey, e.position)) return;
      for (final key in editKeys) {
        if (_hit(key, e.position)) return;
      }
      onCommitOutside!();
      return;
    }

    if (isConfiguringDisable && onCommitDisableOutside != null) {
      if (_hit(menuKey, e.position)) return;
      for (final key in disableExcludeKeys) {
        if (_hit(key, e.position)) return;
      }
      onCommitDisableOutside!();
      return;
    }

    if (horairesEditing && onCommitHorairesOutside != null) {
      if (_hit(horairesMenuKey, e.position)) return;
      for (final key in horairesExcludeKeys) {
        if (_hit(key, e.position)) return;
      }
      onCommitHorairesOutside!();
      return;
    }

    if (setupsEditing && onCommitSetupsOutside != null) {
      if (_hit(setupsMenuKey, e.position)) return;
      for (final key in setupsExcludeKeys) {
        if (_hit(key, e.position)) return;
      }
      onCommitSetupsOutside!();
    }
  }

  static bool _hit(GlobalKey? key, Offset global) {
    if (key == null) return false;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return false;
    final topLeft = box.localToGlobal(Offset.zero);
    final rect = topLeft & box.size;
    return rect.contains(global);
  }
}
