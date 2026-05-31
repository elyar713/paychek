part of 'ajouter_trade_mt_statement_import.dart';

/// Orders.csv ou Performance.csv (onglet Reports → Orders ou Performance).
List<MtStatementTradeRow> parseTradovateImportCsv(String csvContent) {
  if (_tradovateCsvIsPerformanceFormat(csvContent)) {
    final perf = parseTradovatePerformanceCsv(csvContent);
    if (perf.isNotEmpty) return perf;
  }
  final orders = parseTradovateOrdersCsv(csvContent);
  if (orders.isNotEmpty) return orders;
  return parseTradovatePerformanceCsv(csvContent);
}

bool _tradovateCsvIsPerformanceFormat(String csvContent) {
  final raw = _stripLeadingUtf8Bom(csvContent);
  final firstLine = raw
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .firstWhere((l) => l.isNotEmpty, orElse: () => '');
  if (firstLine.isEmpty) return false;

  var fieldDelimiter = ',';
  final commaCols = _parseCsvLine(firstLine, fieldDelimiter: ',').length;
  final semiCols = _parseCsvLine(firstLine, fieldDelimiter: ';').length;
  if (semiCols > commaCols && semiCols >= 4) fieldDelimiter = ';';

  final header = _parseCsvLine(firstLine, fieldDelimiter: fieldDelimiter)
      .map((e) => _stripLeadingUtf8Bom(e.trim()))
      .toList();
  return _tvColumnIndex(header, const <String>[
        'boughtTimestamp',
        'soldTimestamp',
      ]) !=
      null &&
      _tvColumnIndex(header, const <String>['buyFillId', 'sellFillId']) !=
          null;
}

/// Export **Performance** Tradovate (round-trips déjà calculés : `buyPrice`, `sellPrice`, `pnl`, …).
List<MtStatementTradeRow> parseTradovatePerformanceCsv(String csvContent) {
  final raw = _stripLeadingUtf8Bom(csvContent);
  final lines = raw
      .split(RegExp(r'\r?\n'))
      .where((l) => l.trim().isNotEmpty)
      .map(_stripLeadingUtf8Bom)
      .toList(growable: false);
  if (lines.length < 2) return const <MtStatementTradeRow>[];

  final firstLine = lines.first;
  var fieldDelimiter = ',';
  final commaCols = _parseCsvLine(firstLine, fieldDelimiter: ',').length;
  final semiCols = _parseCsvLine(firstLine, fieldDelimiter: ';').length;
  if (semiCols > commaCols && semiCols >= 4) {
    fieldDelimiter = ';';
  }

  final header = _parseCsvLine(firstLine, fieldDelimiter: fieldDelimiter)
      .map((e) => _stripLeadingUtf8Bom(e.trim()))
      .toList(growable: false);

  final idxSymbol = _tvColumnIndex(header, const <String>['symbol', 'Symbol']);
  final idxBuyFill = _tvColumnIndex(header, const <String>['buyFillId']);
  final idxSellFill = _tvColumnIndex(header, const <String>['sellFillId']);
  final idxQty = _tvColumnIndex(header, const <String>['qty', 'Qty', 'quantity']);
  final idxBuyPx = _tvColumnIndex(header, const <String>['buyPrice']);
  final idxSellPx = _tvColumnIndex(header, const <String>['sellPrice']);
  final idxPnl = _tvColumnIndex(header, const <String>['pnl', 'PnL', 'P/L']);
  final idxBought = _tvColumnIndex(header, const <String>[
    'boughtTimestamp',
    'boughtTime',
  ]);
  final idxSold = _tvColumnIndex(header, const <String>[
    'soldTimestamp',
    'soldTime',
  ]);

  if (idxSymbol == null ||
      idxBuyFill == null ||
      idxSellFill == null ||
      idxQty == null ||
      idxBuyPx == null ||
      idxSellPx == null ||
      idxPnl == null ||
      idxBought == null ||
      idxSold == null) {
    return const <MtStatementTradeRow>[];
  }

  final trades = <MtStatementTradeRow>[];
  var rowSeq = 0;

  for (final line in lines.skip(1)) {
    final cols = _parseCsvLine(line, fieldDelimiter: fieldDelimiter);
    final symbol = _csvAt(cols, idxSymbol).trim().toUpperCase();
    final buyFill = _csvAt(cols, idxBuyFill).trim();
    final sellFill = _csvAt(cols, idxSellFill).trim();
    final qty = _parseMtNumber(_csvAt(cols, idxQty));
    final buyPrice = _parseMtNumber(_csvAt(cols, idxBuyPx));
    final sellPrice = _parseMtNumber(_csvAt(cols, idxSellPx));
    final profit = _parseTradovatePnl(_csvAt(cols, idxPnl));
    final boughtRaw = _csvAt(cols, idxBought).trim();
    final soldRaw = _csvAt(cols, idxSold).trim();
    final boughtTime =
        _parseTradovateCsvDateTime(boughtRaw) ?? _parseMtDateTime(boughtRaw);
    final soldTime =
        _parseTradovateCsvDateTime(soldRaw) ?? _parseMtDateTime(soldRaw);

    if (symbol.isEmpty ||
        qty == null ||
        qty <= 0 ||
        buyPrice == null ||
        sellPrice == null ||
        profit == null ||
        boughtTime == null ||
        soldTime == null) {
      continue;
    }

    final isLong = !boughtTime.isAfter(soldTime);
    final openTime = isLong ? boughtTime : soldTime;
    final closeTime = isLong ? soldTime : boughtTime;
    final side = isLong ? TradeSide.achat : TradeSide.vente;
    final openPrice = isLong ? buyPrice : sellPrice;
    final closePrice = isLong ? sellPrice : buyPrice;
    final ticket = buyFill.isNotEmpty && sellFill.isNotEmpty
        ? 'td_${buyFill}_$sellFill'
        : 'td_perf_$rowSeq';

    trades.add(
      MtStatementTradeRow(
        ticket: ticket,
        openTime: openTime,
        closeTime: closeTime,
        side: side,
        size: qty,
        symbol: symbol,
        openPrice: openPrice,
        closePrice: closePrice,
        profit: profit,
        csvSymbolOriginal: symbol,
      ),
    );
    rowSeq++;
  }

  return trades;
}

/// Export **Orders.csv** Tradovate (onglet Reports → Orders).
///
/// Colonnes usuelles : `B/S`, `Contract` ou `Product`, `Avg Fill Price` / `avgPrice`,
/// `Filled Qty` / `filledQty`, `Fill Time`, `Status`.
List<MtStatementTradeRow> parseTradovateOrdersCsv(String csvContent) {
  final raw = _stripLeadingUtf8Bom(csvContent);
  final lines = raw
      .split(RegExp(r'\r?\n'))
      .where((l) => l.trim().isNotEmpty)
      .map(_stripLeadingUtf8Bom)
      .toList(growable: false);
  if (lines.length < 2) return const <MtStatementTradeRow>[];

  final firstLine = lines.first;
  var fieldDelimiter = ',';
  final commaCols = _parseCsvLine(firstLine, fieldDelimiter: ',').length;
  final semiCols = _parseCsvLine(firstLine, fieldDelimiter: ';').length;
  if (semiCols > commaCols && semiCols >= 4) {
    fieldDelimiter = ';';
  }

  final header = _parseCsvLine(firstLine, fieldDelimiter: fieldDelimiter)
      .map((e) => _stripLeadingUtf8Bom(e.trim()))
      .toList(growable: false);

  final idxBs = _tvColumnIndex(header, const <String>[
    'B/S',
    'B/s',
    'Side',
    'Buy/Sell',
  ]);
  final idxContract = _tvColumnIndex(header, const <String>[
    'Contract',
    'Symbol',
    'Instrument',
  ]);
  final idxProduct = _tvColumnIndex(header, const <String>[
    'Product',
  ]);
  final idxAvgPxCols = _csvAllColumnIndicesNorm(header, const <String>[
    'Avg Fill Price',
    'avgfillprice',
    'avgPrice',
    'Fill Price',
    'Price',
  ]);
  final idxQtyCols = _csvAllColumnIndicesNorm(header, const <String>[
    'Filled Qty',
    'filledqty',
    'filledQty',
    'Quantity',
    'Qty',
  ]);
  final idxTimeCols = _csvAllColumnIndicesNorm(header, const <String>[
    'Fill Time',
    'filltime',
    'Timestamp',
    'Date/Time',
    'Date',
  ]);
  final idxStatus = _tvColumnIndex(header, const <String>[
    'Status',
    'status',
    'State',
  ]);
  final idxOrderCols = _csvAllColumnIndicesNorm(header, const <String>[
    'orderId',
    'Order ID',
    'orderid',
    'Order Id',
  ]);

  if (idxBs == null ||
      (idxContract == null && idxProduct == null) ||
      idxAvgPxCols.isEmpty ||
      idxQtyCols.isEmpty ||
      idxTimeCols.isEmpty) {
    return const <MtStatementTradeRow>[];
  }

  final executions = <_TradingViewExecution>[];
  var lineNo = 0;

  for (final line in lines.skip(1)) {
    lineNo++;
    final cols = _parseCsvLine(line, fieldDelimiter: fieldDelimiter);

    if (idxStatus != null) {
      final status = _csvAt(cols, idxStatus);
      if (!_tvStatusMeansFilled(status)) continue;
    }

    final side = _parseTradovateSide(_csvAt(cols, idxBs));
    if (side == null) continue;

    final qty = _csvFirstPositiveNumber(cols, idxQtyCols);
    final fillPrice = _csvFirstPositiveNumber(cols, idxAvgPxCols);
    final timeRaw = _csvFirstNonEmptyCell(cols, idxTimeCols);
    final time =
        _parseTradovateCsvDateTime(timeRaw) ?? _parseMtDateTime(timeRaw);

    final contract =
        idxContract != null ? _csvAt(cols, idxContract).trim() : '';
    final product =
        idxProduct != null ? _csvAt(cols, idxProduct).trim() : '';
    final symbol = (contract.isNotEmpty ? contract : product).toUpperCase();

    var orderId = _csvFirstNonEmptyCell(cols, idxOrderCols);
    if (orderId.isEmpty) orderId = 'td_$lineNo';

    if (qty == null || fillPrice == null || time == null || symbol.isEmpty) {
      continue;
    }

    executions.add(
      _TradingViewExecution(
        orderId: orderId,
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
