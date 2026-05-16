part of 'ajouter_trade_mt_statement_import.dart';


/// Export Rithmic "Recent Orders" CSV.
///
/// Le fichier contient 2 sections ("Working Orders" puis "Completed Orders").
/// On importe uniquement les lignes **Completed Orders** avec `Status = Filled`
/// pour reconstruire des round-trips FIFO par symbole.
List<MtStatementTradeRow> parseRithmicRecentOrdersCsv(String csvContent) {
  final rawLines = csvContent
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .toList(growable: false);
  if (rawLines.length < 3) return const <MtStatementTradeRow>[];

  var inCompleted = false;
  List<String>? header;
  final executions = <_TradingViewExecution>[];

  int? idxStatus;
  int? idxSide;
  int? idxQty;
  int? idxSymbol;
  int? idxAvgFill;
  int? idxUpdateTime;
  int? idxCreateTime;
  int? idxOrderNumber;

  for (final line in rawLines) {
    if (line.isEmpty) continue;

    final lower = line.toLowerCase();
    if (lower == 'completed orders') {
      inCompleted = true;
      header = null;
      continue;
    }
    if (lower == 'working orders') {
      inCompleted = false;
      header = null;
      continue;
    }
    if (!inCompleted) continue;

    // Header rows are quoted CSV.
    final cols = _parseCsvLine(line).map((e) => e.trim()).toList();
    if (cols.isEmpty) continue;

    if (header == null) {
      header = cols;
      idxStatus = _csvColumnIndexNorm(header, const ['Status']);
      idxSide = _csvColumnIndexNorm(header, const ['Buy/Sell', 'BuySell', 'Side']);
      idxQty = _csvColumnIndexNorm(header, const ['Qty To Fill', 'Qty', 'Quantity']);
      idxSymbol = _csvColumnIndexNorm(header, const ['Symbol']);
      idxAvgFill = _csvColumnIndexNorm(header, const ['Avg Fill Price', 'Average fill price']);
      idxUpdateTime = _csvColumnIndexNorm(header, const ['Update Time (RDT)', 'Update Time']);
      idxCreateTime = _csvColumnIndexNorm(header, const ['Create Time (RDT)', 'Create Time']);
      idxOrderNumber = _csvColumnIndexNorm(header, const ['Order Number', 'Order']);
      continue;
    }

    String at(int? idx) => idx == null ? '' : _csvAt(cols, idx).trim();

    final status = at(idxStatus).toLowerCase();
    if (!status.contains('filled')) continue;

    final sideRaw = at(idxSide).toUpperCase();
    final TradeSide? side = (sideRaw == 'B' || sideRaw == 'BUY')
        ? TradeSide.achat
        : (sideRaw == 'S' || sideRaw == 'SELL')
            ? TradeSide.vente
            : null;
    if (side == null) continue;

    final qty = _parseMtNumber(at(idxQty))?.abs();
    if (qty == null || qty <= 0) continue;

    final symRaw = at(idxSymbol).toUpperCase();
    if (symRaw.isEmpty) continue;
    final symbol = _normalizeTvFutureRoot(symRaw);

    final price = _parseMtNumber(at(idxAvgFill));
    if (price == null) continue;

    final timeRaw = at(idxUpdateTime).isNotEmpty ? at(idxUpdateTime) : at(idxCreateTime);
    final time = _parseMtDateTime(timeRaw);
    if (time == null) continue;

    final orderId = at(idxOrderNumber);

    executions.add(
      _TradingViewExecution(
        orderId: orderId.isEmpty ? 'rh' : orderId,
        symbol: symbol,
        side: side,
        qty: qty,
        price: price,
        time: time,
        csvSymbolOriginal: symRaw,
      ),
    );
  }

  return _fifoMatchFuturesExecutions(executions, ticketPrefix: 'rh');
}

List<String> _parseNinjaTraderGridLine(String line) =>
    line.split(';').map((e) => e.trim()).toList(growable: false);

int? _ntGridHeaderIndex(List<String> headerCells, List<String> candidates) {
  final norm = headerCells.map((e) => e.trim().toLowerCase()).toList();
  for (final c in candidates) {
    final k = c.trim().toLowerCase();
    final i = norm.indexOf(k);
    if (i >= 0) return i;
  }
  return null;
}

/// Date grille NinjaTraderâ€¯: `dd/MM` ou `MM/dd` selon donnÃ©es (composante >â€¯12 dÃ©sambiguÃ¯se).
DateTime? _parseNinjaTraderGridDateTime(String raw) {
  final t = raw.trim().replaceAll('\u00A0', ' ');
  final m = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})',
  ).firstMatch(t);
  if (m == null) return null;
  final g1 = int.parse(m.group(1)!);
  final g2 = int.parse(m.group(2)!);
  final y = int.parse(m.group(3)!);
  final hh = int.parse(m.group(4)!);
  final mm = int.parse(m.group(5)!);
  final ss = int.parse(m.group(6)!);

  DateTime? build(int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    try {
      return DateTime(y, month, day, hh, mm, ss);
    } catch (_) {
      return null;
    }
  }

  if (g1 > 12) return build(g2, g1);
  if (g2 > 12) return build(g1, g2);
  return build(g1, g2) ?? build(g2, g1);
}

/// Export **NinjaTrader Grid** CSV (sÃ©parateurâ€¯`;`, prix type `7294,5`).
List<MtStatementTradeRow> parseNinjaTraderGridCsv(String csvContent) {
  final lines = csvContent
      .split(RegExp(r'\r?\n'))
      .where((l) => l.trim().isNotEmpty)
      .toList(growable: false);
  if (lines.length < 2) return const <MtStatementTradeRow>[];

  final first = lines.first;
  if (!first.contains(';')) {
    return const <MtStatementTradeRow>[];
  }

  final header = _parseNinjaTraderGridLine(lines.first);
  final idxInstr = _ntGridHeaderIndex(header, const <String>[
    'Instrument',
    'instrument',
    'Instr.',
  ]);
  final idxAction = _ntGridHeaderIndex(header, const <String>[
    'Action',
  ]);
  final idxQty = _ntGridHeaderIndex(header, const <String>[
    'Quantity',
    'qty',
    'QuantitÃ©',
  ]);
  final idxState = _ntGridHeaderIndex(header, const <String>[
    'State',
    'Ã‰tat',
  ]);
  final idxFilled = _ntGridHeaderIndex(header, const <String>[
    'Filled',
    'Filled qty',
    'Executed',
  ]);
  final idxAvgPx = _ntGridHeaderIndex(header, const <String>[
    'Avg. price',
    'average price',
    'avgprice',
    'avg fill price',
    'prix moyen',
  ]);
  final idxTime = _ntGridHeaderIndex(header, const <String>[
    'Time',
    'Heure',
  ]);
  final idxId = _ntGridHeaderIndex(header, const <String>[
    'ID',
    'id',
    'Order id',
  ]);

  if (idxInstr == null ||
      idxAction == null ||
      idxQty == null ||
      idxState == null ||
      idxAvgPx == null ||
      idxTime == null ||
      idxId == null) {
    return const <MtStatementTradeRow>[];
  }

  final executions = <_TradingViewExecution>[];

  for (final line in lines.skip(1)) {
    if (!line.contains(';')) continue;
    final cols = _parseNinjaTraderGridLine(line);
    if (cols.length <= idxTime) continue;

    final stateRaw = idxState < cols.length ? cols[idxState].trim().toLowerCase() : '';
    if (!stateRaw.contains('filled')) continue;

    final filledQty = idxFilled != null && idxFilled < cols.length
        ? _parseMtNumber(cols[idxFilled])
        : null;
    if (filledQty != null && filledQty <= 0) continue;

    final sideRaw = cols[idxAction].trim().toLowerCase();
    final TradeSide? side = sideRaw == 'buy'
        ? TradeSide.achat
        : sideRaw == 'sell'
        ? TradeSide.vente
        : null;
    if (side == null) continue;

    final qty = _parseMtNumber(cols[idxQty]);
    final avgPxRaw = cols[idxAvgPx].trim();
    final fillPrice = _parseMtNumber(avgPxRaw);
    final timeRaw = cols[idxTime].trim();
    final time =
        _parseNinjaTraderGridDateTime(timeRaw) ??
            _parseTradovateCsvDateTime(timeRaw) ??
            _parseMtDateTime(timeRaw);
    final instrument = cols[idxInstr].trim();
    if (instrument.isEmpty) continue;
    final symbol = _normalizeTvFutureRoot(instrument);
    final orderId = cols[idxId].trim();
    final useQty =
        qty != null && qty > 0 ? qty : (filledQty != null && filledQty > 0 ? filledQty : null);
    if (useQty == null ||
        useQty <= 0 ||
        fillPrice == null ||
        time == null ||
        symbol.isEmpty) {
      continue;
    }

    executions.add(
      _TradingViewExecution(
        orderId: orderId.isEmpty ? 'nt' : orderId,
        symbol: symbol,
        side: side,
        qty: useQty,
        price: fillPrice,
        time: time,
        csvSymbolOriginal: instrument,
      ),
    );
  }

  return _fifoMatchFuturesExecutions(
    executions,
    ticketPrefix: 'nt',
  );
}
