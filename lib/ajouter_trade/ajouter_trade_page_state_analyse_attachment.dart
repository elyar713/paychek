// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageStateAnalyseAttachment on _AjouterTradePageState {
  void _clearTradeLinkedAnalyse() {
    setState(() {
      _tradeLinkedAnalyseReport = null;
      _tradeLinkedAnalysePdfBytes = null;
      _tradeLinkedAnalysePdfFileName = null;
      _tradeLinkedAnalysePdfGenerating = false;
    });
  }

  Future<void> _onTradeLinkedAnalyseSelected(AnalyseReportSnapshot? snap) async {
    if (!mounted) return;
    if (snap == null) {
      _clearTradeLinkedAnalyse();
      return;
    }

    setState(() {
      _tradeLinkedAnalyseReport = snap;
      _tradeLinkedAnalysePdfBytes = null;
      _tradeLinkedAnalysePdfFileName = null;
      _tradeLinkedAnalysePdfGenerating = true;
    });

    try {
      final l = AppLocalizations.of(context)!;
      final locale = Localizations.localeOf(context);
      final bytes = await buildAnalyseReportPdf(
        snap,
        locale: locale,
        l: l,
      );
      if (!mounted) return;
      setState(() {
        _tradeLinkedAnalysePdfBytes = bytes;
        _tradeLinkedAnalysePdfFileName = analyseReportPdfFileName(snap);
        _tradeLinkedAnalysePdfGenerating = false;
      });
    } catch (e, st) {
      debugPrint('_onTradeLinkedAnalyseSelected: $e\n$st');
      if (!mounted) return;
      setState(() => _tradeLinkedAnalysePdfGenerating = false);
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.ajouterTradeAnalysePdfError)),
      );
    }
  }

  /// Recharge le PDF si le rapport est connu mais les bytes manquent (édition).
  Future<void> _ensureTradeLinkedAnalysePdf() async {
    final snap = _tradeLinkedAnalyseReport;
    if (snap == null) return;
    if (_tradeLinkedAnalysePdfBytes != null &&
        _tradeLinkedAnalysePdfBytes!.isNotEmpty) {
      return;
    }
    await _onTradeLinkedAnalyseSelected(snap);
  }
}
