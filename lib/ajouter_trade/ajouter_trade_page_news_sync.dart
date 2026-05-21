// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageStateNewsSync on _AjouterTradePageState {
  void _onChecklistSectionsChanged() {
    if (!mounted) return;
    _applyNewsFlagsFromChecklist();
  }

  /// Met à jour les cases Avant / Après news selon la checklist NEWS (date + heure).
  void _applyNewsFlagsFromChecklist() {
    if (!checklistNewsSectionEnabled(widget.checklistController.sections)) {
      return;
    }
    final flags = classifyTradeNewsTimingFromController(
      entreeAt: _entreeDateTime,
      checklist: widget.checklistController,
    );
    if (_avantNews == flags.avantNews && _apresNews == flags.apresNews) return;
    setState(() {
      _avantNews = flags.avantNews;
      _apresNews = flags.apresNews;
    });
  }
}
