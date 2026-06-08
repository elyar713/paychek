part of 'trade_page.dart';

extension _TradePageExpandableTradeCard on _TradePageState {
  Widget _buildExpandableTradeCard(
    BuildContext context,
    TradeListItem item,
    Map<String, GlobalKey> tradeKeys,
    List<TradeListItem> allRaw, {
    Map<String, double>? capitalBeforeById,
  }) {
    _tradeKeysById.putIfAbsent(item.id, GlobalKey.new);
    final key = tradeKeys[item.id] ?? _tradeKeysById[item.id]!;

    return Container(
      key: key,
      child: TradeCard(
        item: item,
        referenceCapitalForPct: capitalBeforeById?[item.id],
        expanded: _expandedTradeId == item.id,
        tradeNumberOfDay: _tradeNumberOfDay(item, allRaw),
        checklistController: widget.checklistController,
        onToggle: () {
          _safeSetState(() {
            _expandedTradeId =
                _expandedTradeId == item.id ? null : item.id;
          });
        },
        onEdit: () => widget.onEditTrade(item),
        onExportPdf: () => exportTradePdf(
          context,
          item,
          checklistController: widget.checklistController,
        ),
        onDelete: () => _confirmDeleteTrade(context, item),
      ),
    );
  }

  Future<void> _confirmDeleteTrade(BuildContext context, TradeListItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          backgroundColor: TradeTokens.cardBg,
          title: Text(
            l.tradeDeleteConfirmTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            l.tradeDeleteConfirmBody,
            style: TextStyle(
              color: TradeTokens.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l.delete,
                style: TextStyle(
                  color: TradeTokens.lossNeon,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    if (!context.mounted) return;
    TradeJournalScope.of(context).removeById(item.id);
  }
}
