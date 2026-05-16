part of 'ajouter_trade_page.dart';

/// Scrolls indépendants pour le layout web large ; contrôleurs ici évite les `null` après hot reload sur [State].
class _AjouterTradeWebWideDoubleColumn extends StatefulWidget {
  const _AjouterTradeWebWideDoubleColumn({
    required this.leftColumn,
    required this.rightColumn,
  });

  final Widget leftColumn;
  final Widget rightColumn;

  @override
  State<_AjouterTradeWebWideDoubleColumn> createState() =>
      _AjouterTradeWebWideDoubleColumnState();
}

class _AjouterTradeWebWideDoubleColumnState
    extends State<_AjouterTradeWebWideDoubleColumn> {
  late final ScrollController _leftScroll = ScrollController();
  late final ScrollController _rightScroll = ScrollController();

  @override
  void dispose() {
    _leftScroll.dispose();
    _rightScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 12,
          child: Scrollbar(
            controller: _leftScroll,
            child: SingleChildScrollView(
              controller: _leftScroll,
              child: widget.leftColumn,
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 8,
          child: Scrollbar(
            controller: _rightScroll,
            child: SingleChildScrollView(
              controller: _rightScroll,
              child: widget.rightColumn,
            ),
          ),
        ),
      ],
    );
  }
}
