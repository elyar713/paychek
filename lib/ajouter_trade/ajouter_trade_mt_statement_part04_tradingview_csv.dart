part of 'ajouter_trade_mt_statement_import.dart';


List<MtStatementTradeRow> parseTradingViewOrdersCsv(String csvContent) {
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
  if (semiCols > commaCols && semiCols >= 2) {
    fieldDelimiter = ';';
  }

  final header =
      _parseCsvLine(firstLine, fieldDelimiter: fieldDelimiter)
          .map((e) => _stripLeadingUtf8Bom(e.trim()))
          .toList();
  final idxSymbol = _tvColumnIndex(header, const <String>[
    'Symbole',
    'Symbol',
    'Ticker',
    'instrument',
    'Instrument',
  ]);
  final idxSide = _tvColumnIndex(header, const <String>[
    'CÃ´tÃ©',
    'Côté',
    'Side',
    'Type',
    'direction',
    'Direction',
    'Order side',
  ]);
  final idxQty = _tvColumnIndex(header, const <String>[
    'QtÃ©',
    'Qté',
    'Qty',
    'Quantity',
    'Size',
    'size',
    'Lots',
    'lots',
    'Amount',
  ]);
  final idxFillPrice = _tvColumnIndex(header, const <String>[
    'Prix de remplissage',
    'Fill price',
    'Fill Price',
    'Avg fill price',
    'Avg Fill Price',
    'average fill price',
    'Price',
    'Avg Price',
    'Average price',
  ]);
  final idxStatus = _tvColumnIndex(header, const <String>[
    'Statut',
    'Status',
    'Ã‰tat',
    'État',
    'Etat',
    'state',
    'State',
    'Order status',
  ]);
  final idxPlacedTime = _tvColumnIndex(header, const <String>[
    'Heure de placement',
    'Placed time',
    'Placed Time',
    'Open Time',
    'Open time',
  ]);
  final idxClosedTime = _tvColumnIndex(header, const <String>[
    'Heure de clÃ´ture',
    'Closing time',
    'Closing Time',
    'Closed time',
    'Closed Time',
    'Timestamp',
    'timestamp',
    'Date',
    'Time',
    'Execution Time',
    'Execution time',
    'Fill Time',
    'Fill time',
    'Trade Time',
    'trade time',
    'Datetime',
    'Date/time',
    'Closing Time (UTC)',
  ]);
  final idxOrderId = _tvColumnIndex(header, const <String>[
    "ID d'ordre",
    'Order ID',
    'Order id',
    'OrderId',
    'orderId',
    'Id',
    'ID',
    'Trade ID',
    'Deal ID',
    'Deal id',
  ]);
  /// Colonne Â« dernier recours Â» pour lâ€™horodatage si les colonnes dÃ©diÃ©es sont vides ou absentes sur une ligne.
  final idxGenericTimeFallback = idxClosedTime ??
      idxPlacedTime ??
      _tvColumnIndex(header, const <String>[
        'Datetime',
        'Date / time',
        'Date Time',
      ]);

  if (idxSymbol == null ||
      idxSide == null ||
      idxQty == null ||
      idxFillPrice == null ||
      idxGenericTimeFallback == null) {
    return const <MtStatementTradeRow>[];
  }

  final executions = <_TradingViewExecution>[];
  var rowSeq = 0;
  for (final line in lines.skip(1)) {
    rowSeq++;
    final cols =
        _parseCsvLine(line, fieldDelimiter: fieldDelimiter)
            .map((e) => e.trim())
            .toList();
    if (idxStatus != null) {
      final status = _csvAt(cols, idxStatus);
      // Cellule vide : beaucoup d'exports TradingView ne remplissent pas le statut pour
      // les exécutions déjà passées — ne pas exclure toute la grille.
      if (status.trim().isNotEmpty && !_tvStatusMeansFilled(status)) continue;
    }

    final sideRaw =
        _csvAt(cols, idxSide).toLowerCase().trim().replaceAll('\u00A0', ' ');
    TradeSide? side;
    if (sideRaw == 'buy' ||
        sideRaw == 'b' ||
        sideRaw == 'long' ||
        sideRaw == 'achat' ||
        sideRaw.startsWith('buy ') ||
        sideRaw.startsWith('long')) {
      side = TradeSide.achat;
    } else if (sideRaw == 'sell' ||
        sideRaw == 's' ||
        sideRaw == 'short' ||
        sideRaw == 'vente' ||
        sideRaw.startsWith('sell ') ||
        sideRaw.startsWith('short')) {
      side = TradeSide.vente;
    }
    if (side == null) continue;

    final qty = _parseMtNumber(_csvAt(cols, idxQty));
    final fillPrice = _parseMtNumber(_csvAt(cols, idxFillPrice));
    DateTime? time;
    if (idxClosedTime != null) {
      time = _parseMtDateTime(_csvAt(cols, idxClosedTime));
    }
    if (time == null && idxPlacedTime != null) {
      time = _parseMtDateTime(_csvAt(cols, idxPlacedTime));
    }
    time ??= _parseMtDateTime(_csvAt(cols, idxGenericTimeFallback));
    final rawSymbol = _csvAt(cols, idxSymbol).trim();
    final symbol = rawSymbol.contains(':')
        ? rawSymbol.split(':').last.trim()
        : rawSymbol;
    var orderId = idxOrderId != null ? _csvAt(cols, idxOrderId).trim() : '';
    if (orderId.isEmpty) {
      orderId = 'tv_r$rowSeq';
    }
    if (qty == null ||
        qty <= 0 ||
        fillPrice == null ||
        time == null ||
        symbol.isEmpty) {
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
        csvSymbolOriginal: _csvAt(cols, idxSymbol).trim(),
      ),
    );
  }

  return _fifoMatchFuturesExecutions(
    executions,
    ticketPrefix: 'tv',
  );
}
