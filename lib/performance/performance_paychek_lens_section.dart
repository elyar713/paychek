import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../checklist/checklist_models.dart';
import '../checklist/checklist_sections_storage.dart';
import '../reglage/user_portfolio_scope.dart';
import '../reglage/user_portfolio_store.dart';
import '../trade/trade_journal_helper.dart';
import '../trade/trade_journal_scope.dart';
import '../trade/trade_journal_store.dart';
import 'performance_custom_lens_card.dart';
import 'performance_custom_lens_model.dart';
import 'performance_custom_lens_storage.dart';
import 'performance_journal_adapter.dart';
import 'performance_locale_copy.dart';
import 'performance_trade_model.dart';

/// Même seuil que la page Performance (paires de cartes enregistrées).
const double kPaychekLensWideBreakpoint = 920;

/// Section Paychek Lens : brouillon + cartes enregistrées (données journal + stockage).
class PaychekLensSection extends StatefulWidget {
  const PaychekLensSection({
    super.key,
    this.showAddButton = true,
    this.cardChrome = PerformanceCustomLensCardChrome.performance,
  });

  /// Masquer « Ajouter » (ex. accueil dashboard) tout en gardant « Réinitialiser ».
  final bool showAddButton;

  /// Style des cartes (accueil vs page Performance).
  final PerformanceCustomLensCardChrome cardChrome;

  @override
  State<PaychekLensSection> createState() => _PaychekLensSectionState();
}

class _PaychekLensSectionState extends State<PaychekLensSection> {
  List<Trade> _trades = [];
  TradeJournalStore? _journalStore;
  UserPortfolioStore? _portfolioStore;
  PerformanceCustomLensConfig _customLensDraft =
      PerformanceCustomLensConfig.defaults();
  List<PerformanceCustomLensSavedCard> _customLensSavedCards = const [];
  List<ChecklistSectionData> _checklistSections = defaultNouveauTradeSections();

  List<Trade> get _disciplineVisibleTrades =>
      _trades.where((t) => !t.performanceLite).toList();

  @override
  void initState() {
    super.initState();
    _loadCustomLensSavedCards();
    _loadChecklistSectionsForLens();
  }

  Future<void> _loadChecklistSectionsForLens() async {
    final data = await ChecklistSectionsStorage.load();
    if (!mounted) return;
    if (data != null && data.isNotEmpty) {
      setState(() => _checklistSections = data);
    }
  }

  Future<void> _loadCustomLensSavedCards() async {
    final cards = await PerformanceCustomLensStorage.loadSavedCards();
    if (!mounted) return;
    setState(() => _customLensSavedCards = cards);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var changed = false;
    final next = TradeJournalScope.of(context);
    if (!identical(_journalStore, next)) {
      _journalStore?.removeListener(_onJournalChanged);
      _journalStore = next;
      _journalStore!.addListener(_onJournalChanged);
      changed = true;
    }
    final nextP = UserPortfolioScope.of(context);
    if (!identical(_portfolioStore, nextP)) {
      _portfolioStore?.removeListener(_onJournalChanged);
      _portfolioStore = nextP;
      _portfolioStore!.addListener(_onJournalChanged);
      changed = true;
    }
    if (changed) _applyTradeSource();
  }

  @override
  void dispose() {
    _journalStore?.removeListener(_onJournalChanged);
    _portfolioStore?.removeListener(_onJournalChanged);
    super.dispose();
  }

  void _onJournalChanged() => _applyTradeSource();

  void _applyTradeSource() {
    if (!mounted) return;
    final items = activeJournalTradesOrDemo(context);
    setState(() => _trades = performanceTradesFromJournal(items));
  }

  void _onCustomLensDraftChanged(PerformanceCustomLensConfig next) {
    setState(() => _customLensDraft = next);
  }

  void _onCustomLensReset() {
    setState(() => _customLensDraft = PerformanceCustomLensConfig.defaults());
  }

  void _onCustomLensAdd() {
    final draft = _customLensDraft;
    if (draft.elementId.isEmpty) {
      final code = Localizations.localeOf(context).languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            perf6(
              code,
              'Choisissez un élément avant d’ajouter une carte.',
              'Choose an element before adding a card.',
              'Elige un elemento antes de añadir una tarjeta.',
              'Wählen Sie ein Element, bevor Sie eine Karte hinzufügen.',
              'Escolha um elemento antes de adicionar um cartão.',
              '카드를 추가하기 전에 요소를 선택하세요.',
            ),
          ),
        ),
      );
      return;
    }
    final card = PerformanceCustomLensSavedCard(
      id: 'lens_${DateTime.now().millisecondsSinceEpoch}',
      config: draft,
      savedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    final next = [card, ..._customLensSavedCards];
    setState(() {
      _customLensSavedCards = next;
      _customLensDraft = PerformanceCustomLensConfig.defaults();
    });
    unawaited(PerformanceCustomLensStorage.saveSavedCards(next));
  }

  void _onCustomLensRemoveSaved(String id) {
    final next = _customLensSavedCards.where((c) => c.id != id).toList();
    setState(() => _customLensSavedCards = next);
    unawaited(PerformanceCustomLensStorage.saveSavedCards(next));
  }

  Widget _customLensSavedCard(
    List<Trade> trades,
    PerformanceCustomLensSavedCard saved,
  ) {
    return PerformanceCustomLensCard(
      trades: trades,
      config: saved.config,
      checklistSections: _checklistSections,
      readOnly: true,
      chrome: widget.cardChrome,
      onRemove: () => _onCustomLensRemoveSaved(saved.id),
    );
  }

  /// Cartes enregistrées : 1ʳᵉ pleine largeur ; à partir de la 2ᵉ, paires côte à côte.
  Widget _customLensSavedCardsLayout(List<Trade> trades, double gap) {
    final cards = _customLensSavedCards.reversed.toList();
    if (cards.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];

    void addRow(Widget row) {
      if (children.isNotEmpty) children.add(SizedBox(height: gap));
      children.add(row);
    }

    if (cards.length == 1) {
      addRow(_customLensSavedCard(trades, cards[0]));
    } else {
      for (var i = 0; i < cards.length; i += 2) {
        final left = cards[i];
        if (i + 1 < cards.length) {
          final right = cards[i + 1];
          addRow(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _customLensSavedCard(trades, left)),
                SizedBox(width: gap),
                Expanded(child: _customLensSavedCard(trades, right)),
              ],
            ),
          );
        } else {
          addRow(_customLensSavedCard(trades, left));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trades = _disciplineVisibleTrades;
    final gap = MediaQuery.sizeOf(context).width >= kPaychekLensWideBreakpoint
        ? 14.0
        : 16.0;
    final savedBlock = _customLensSavedCardsLayout(trades, gap);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_customLensSavedCards.isNotEmpty) ...[
          savedBlock,
          SizedBox(height: gap),
        ],
        PerformanceCustomLensCard(
          trades: trades,
          config: _customLensDraft,
          onConfigChanged: _onCustomLensDraftChanged,
          checklistSections: _checklistSections,
          chrome: widget.cardChrome,
          onAdd: widget.showAddButton ? _onCustomLensAdd : null,
          onReset: _onCustomLensReset,
        ),
      ],
    );
  }
}
