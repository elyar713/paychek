// ignore_for_file: invalid_use_of_protected_member

part of 'ajouter_trade_page.dart';

extension _AjouterTradePageSessionMindset on _AjouterTradePageState {
  TradeSessionMindsetRules get _sessionMindsetRules => TradeSessionMindsetRules(
        autoTagEnabled: _sessionAutoTagEnabled,
        plannedTradesPerDay: _plannedTradesPerDay,
      );

  Future<void> _loadDisciplinePrefsFromStorage() async {
    final p = await AjouterTradeDisciplinePrefsStorage.load();
    if (!mounted) return;
    setState(() {
      _authorizeDisciplineWhenFeeling = p.authorizeWhenFeeling;
      _sectionStrategieEnabled = p.strategie;
      _sectionPlanEnabled = p.planAnalyse;
      _sectionChecklistEnabled = p.checklist;
      _sectionEtatEnabled = p.etatMoment;
      _sessionAutoTagEnabled = p.sessionAutoTagEnabled;
      _plannedTradesPerDay = p.plannedTradesPerDay.clamp(1, 10);
    });
    _applySessionMindsetToFormIfEnabled();
  }

  void _applySessionMindsetToFormIfEnabled() {
    if (!_sessionAutoTagEnabled || !mounted) return;
    final store = TradeJournalScope.of(context);
    final portfolioId = _editingPortfolioId ??
        UserPortfolioScope.of(context).activePortfolioId;
    final mindset = resolveTradeSessionMindset(
      entreeAt: _entreeDateTime,
      existing: store.items,
      rules: _sessionMindsetRules,
      portfolioId: portfolioId,
      excludeTradeId: _editingTradeId,
    );
    final key = tradeMindsetToAjouterTradeKey(mindset);
    setState(() {
      _tradeMindset = key;
      _authorizeDisciplineWhenFeeling = mindset != TradeMindset.feeling;
    });
  }

  String? _sessionMindsetHintText(AppLocalizations l) {
    if (!_sessionAutoTagEnabled) return null;
    final store = TradeJournalScope.of(context);
    final portfolioId = _editingPortfolioId ??
        UserPortfolioScope.of(context).activePortfolioId;
    final rank = tradeSessionRankOnDay(
      entreeAt: _entreeDateTime,
      existing: store.items,
      portfolioId: portfolioId,
      excludeTradeId: _editingTradeId,
    );
    final mindset = tradeSessionMindsetForRank(rank, _sessionMindsetRules);
    final tag = mindset == TradeMindset.feeling
        ? l.tradeMindsetFeeling
        : l.tradeMindsetPrinciple;
    return l.ajouterTradeSessionHint(rank, tag);
  }
}
