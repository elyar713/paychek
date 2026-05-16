part of 'ajouter_trade_mt_statement_import.dart';


/// Export **Orders.csv** Tradovate (fills : `B/S`, `Product`, `avgPrice`, `filledQty`, `Fill Time`, `Status`).
List<MtStatementTradeRow> parseTradovateOrdersCsv(String csvContent) {
  final lines = csvContent
      .split(RegExp(r'\r?\n'))
      .where((l) => l.trim().isNotEmpty)
      .toList(growable: false);
  if (lines.length < 2) return const <MtStatementTradeRow>[];

  final header =
      _parseCsvLine(lines.first).map((e) => e.trim()).toList(growable: false);

  final idxOrder = _csvColumnIndexNorm(header, const <String>[
    'orderId',
    'Order ID',
    'orderid',
  ]);
  final idxBs = _csvColumnIndexNorm(header, const <String>[
    'B/S',
    'B/s',
    'Side',
  ]);
  final idxProduct = _csvColumnIndexNorm(header, const <String>[
    'Product',
  ]);
  final idxAvgPx = _csvColumnIndexNorm(header, const <String>[
    'avgPrice',
    'Avg Fill Price',
    'avgfillprice',
  ]);
  final idxQty = _csvColumnIndexNorm(header, const <String>[
    'filledQty',
    'Filled Qty',
    'filledqty',
    'Quantity',
  ]);
  final idxFillTime = _csvColumnIndexNorm(header, const <String>[
    'Fill Time',
    'Timestamp',
    'filltime',
  ]);
  final idxStatus = _csvColumnIndexNorm(header, const <String>[
    'Status',
    'status',
  ]);

  if (idxBs == null ||
      idxProduct == null ||
      idxAvgPx == null ||
      idxQty == null ||
      idxFillTime == null ||
      idxStatus == null ||
      idxOrder == null) {
    return const <MtStatementTradeRow>[];
  }

  final executions = <_TradingViewExecution>[];

  for (final line in lines.skip(1)) {
    final cols = _parseCsvLine(line);
    final status = _csvAt(cols, idxStatus).toLowerCase().trim();
    if (!status.contains('filled')) continue;

    final sideRaw = _csvAt(cols, idxBs).trim().toLowerCase();
    TradeSide? side;
    if (sideRaw == 'buy' || sideRaw.startsWith('buy')) {
      side = TradeSide.achat;
    } else if (sideRaw == 'sell' || sideRaw.startsWith('sell')) {
      side = TradeSide.vente;
    }
    if (side == null) continue;

    final qty = _parseMtNumber(_csvAt(cols, idxQty));
    final fillPrice = _parseMtNumber(_csvAt(cols, idxAvgPx));
    final timeRaw = _csvAt(cols, idxFillTime).trim();
    final time =
        _parseTradovateCsvDateTime(timeRaw) ??
            _parseMtDateTime(timeRaw);
    final symbol = _csvAt(cols, idxProduct).trim().toUpperCase();
    final orderId = _csvAt(cols, idxOrder).trim();
    if (qty == null ||
        qty <= 0 ||
        fillPrice == null ||
        time == null ||
        symbol.isEmpty) {
      continue;
    }

    executions.add(
      _TradingViewExecution(
        orderId: orderId.isEmpty ? 'td' : orderId,
        symbol: symbol,
        side: side,
        qty: qty,
        price: fillPrice,
        time: time,
      ),
    );
  }

  return _fifoMatchFuturesExecutions(
    executions,
    ticketPrefix: 'td',
  );
}
