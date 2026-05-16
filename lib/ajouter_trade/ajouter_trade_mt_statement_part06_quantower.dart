part of 'ajouter_trade_mt_statement_import.dart';


DateTime? _parseQuantowerCsvDateTime(String raw) {
  // Example: `06/05/2026 15:36:43 +01:00`
  final s = raw.trim().replaceAll('\u00A0', ' ');
  final m = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})(?:\s*([+-])(\d{2}):(\d{2}))?$',
  ).firstMatch(s);
  if (m == null) return null;
  try {
    final day = int.parse(m.group(1)!);
    final month = int.parse(m.group(2)!);
    final year = int.parse(m.group(3)!);
    final hh = int.parse(m.group(4)!);
    final mm = int.parse(m.group(5)!);
    final ss = int.parse(m.group(6)!);
    final sign = m.group(7);
    final offH = m.group(8);
    final offM = m.group(9);
    if (sign == null || offH == null || offM == null) {
      return DateTime(year, month, day, hh, mm, ss);
    }
    // Convert to an ISO-8601 string and let DateTime.parse handle the offset.
    // Avoid manual timezone math so the dashboard doesn't shift times unexpectedly.
    final iso =
        '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}T'
        '${hh.toString().padLeft(2, '0')}:'
        '${mm.toString().padLeft(2, '0')}:'
        '${ss.toString().padLeft(2, '0')}'
        '$sign${offH.padLeft(2, '0')}:${offM.padLeft(2, '0')}';
    return DateTime.parse(iso);
  } catch (_) {
    return null;
  }
}

String _qtExecKey({
  required String symbol,
  required TradeSide side,
  required DateTime time,
  required double qty,
  required double price,
}) {
  return '$symbol|${side.name}|${time.toIso8601String()}|${qty.toStringAsFixed(8)}|${price.toStringAsFixed(10)}';
}

/// Export Quantower CSV.
///
/// Supporte 2 formats:
/// - **Trades**: en-tÃªte avec `Date/Time`, `Gross P/L`, `Net P/L`
/// - **Orders history**: en-tÃªte avec `Status`, `Order ID`, `Average fill price`
///
/// Dans les 2 cas on reconstruit des trades via appariement FIFO des exÃ©cutions `Filled`
/// (Buy/Sell) par symbole (futures) et on estime le PnL via [_futuresPointValueUsd].
List<MtStatementTradeRow> parseQuantowerOrdersHistoryCsv(String csvContent) {
  final lines = csvContent
      .split(RegExp(r'\r?\n'))
      .where((l) => l.trim().isNotEmpty)
      .toList(growable: false);
  if (lines.length < 2) return const <MtStatementTradeRow>[];

  final header =
      _parseCsvLine(lines.first).map((e) => e.trim()).toList(growable: false);

  final idxDateTime = _csvColumnIndexNorm(header, const <String>[
    'Date/Time',
    'Date Time',
    'Date',
  ]);
  final idxGross = _csvColumnIndexNorm(header, const <String>[
    'Gross P/L',
    'Gross P&L',
    'GrossPL',
  ]);
  final idxNet = _csvColumnIndexNorm(header, const <String>[
    'Net P/L',
    'Net P&L',
    'NetPL',
  ]);

  final isTradesFormat =
      idxDateTime != null && (idxGross != null || idxNet != null);

  final idxSymbol = _csvColumnIndexNorm(header, const <String>['Symbol']);
  final idxSide = _csvColumnIndexNorm(header, const <String>['Side']);
  final idxQty = _csvColumnIndexNorm(header, const <String>['Quantity']);
  final idxPrice = _csvColumnIndexNorm(header, const <String>['Price']);

  if (idxSymbol == null || idxSide == null || idxQty == null || idxPrice == null) {
    return const <MtStatementTradeRow>[];
  }

  if (isTradesFormat) {
    final executions = <_TradingViewExecution>[];
    final providedProfitByCloseExecKey = <String, double>{};

    for (final line in lines.skip(1)) {
      final cols = _parseCsvLine(line);
      final sideRaw = _csvAt(cols, idxSide).toLowerCase().trim();
      final TradeSide? side = sideRaw == 'buy'
          ? TradeSide.achat
          : sideRaw == 'sell'
              ? TradeSide.vente
              : null;
      if (side == null) continue;

      final rawSymbol = _csvAt(cols, idxSymbol).trim();
      if (rawSymbol.isEmpty) continue;
      final symbol = _normalizeTvFutureRoot(rawSymbol);

      final qtyRaw = _csvAt(cols, idxQty).trim();
      var qty = _parseMtNumber(qtyRaw);
      if (qty == null) continue;
      qty = qty.abs();
      if (qty <= 0) continue;

      final price = _parseMtNumber(_csvAt(cols, idxPrice).trim());
      if (price == null) continue;

      final timeRaw = _csvAt(cols, idxDateTime).trim();
      final t =
          _parseQuantowerCsvDateTime(timeRaw) ??
          _parseTradovateCsvDateTime(timeRaw) ??
          _parseMtDateTime(timeRaw);
      if (t == null) continue;

      // Provided P&L (often only on close rows, and sometimes Net is 0 but Gross isn't).
      final netRaw = idxNet != null ? _csvAt(cols, idxNet).trim() : '';
      final grossRaw = idxGross != null ? _csvAt(cols, idxGross).trim() : '';
      final net = netRaw.isEmpty ? null : _parseMtNumber(netRaw);
      final gross = grossRaw.isEmpty ? null : _parseMtNumber(grossRaw);
      final provided = (net != null && net != 0.0) ? net : gross;
      if (provided != null && provided != 0.0) {
        providedProfitByCloseExecKey[_qtExecKey(
          symbol: symbol,
          side: side,
          time: t,
          qty: qty,
          price: price,
        )] = provided;
      }

      executions.add(
        _TradingViewExecution(
          orderId: 'qt',
          symbol: symbol,
          side: side,
          qty: qty,
          price: price,
          time: t,
          csvSymbolOriginal: rawSymbol,
        ),
      );
    }

    if (executions.isEmpty) return const <MtStatementTradeRow>[];

    executions.sort((a, b) => a.time.compareTo(b.time));
    final openBySymbol = <String, List<_TradingViewExecution>>{};
    final out = <MtStatementTradeRow>[];
    var ticketSeq = 0;

    for (final exec in executions) {
      final bucket = openBySymbol.putIfAbsent(
        exec.symbol,
        () => <_TradingViewExecution>[],
      );
      var remaining = exec.qty;

      final closeKey = _qtExecKey(
        symbol: exec.symbol,
        side: exec.side,
        time: exec.time,
        qty: exec.qty,
        price: exec.price,
      );
      final providedCloseProfit = providedProfitByCloseExecKey[closeKey];
      final hasProvidedCloseProfit =
          providedCloseProfit != null && providedCloseProfit != 0.0;

      // If Quantower provides a P&L for this close execution, keep it as ONE trade
      // (size can be >1), so we don't split the P&L across multiple rows.
      if (hasProvidedCloseProfit) {
        var matchedTotal = 0.0;
        var weightedEntry = 0.0;
        DateTime? firstOpenTime;
        TradeSide? openSide;

        while (remaining > 0) {
          final oppositeIndex = bucket.indexWhere(
            (o) => o.side != exec.side && o.qty > 0,
          );
          if (oppositeIndex < 0) break;
          final open = bucket[oppositeIndex];
          final matchedQty = remaining < open.qty ? remaining : open.qty;

          matchedTotal += matchedQty;
          weightedEntry += open.price * matchedQty;
          firstOpenTime ??= open.time;
          openSide ??= open.side;

          remaining -= matchedQty;
          final newQty = open.qty - matchedQty;
          if (newQty <= 0) {
            bucket.removeAt(oppositeIndex);
          } else {
            bucket[oppositeIndex] = _TradingViewExecution(
              orderId: open.orderId,
              symbol: open.symbol,
              side: open.side,
              qty: newQty,
              price: open.price,
              time: open.time,
              csvSymbolOriginal: open.csvSymbolOriginal,
            );
          }
        }

        if (matchedTotal > 0 && firstOpenTime != null && openSide != null) {
          final avgEntry = weightedEntry / matchedTotal;
          out.add(
            MtStatementTradeRow(
              ticket:
                  'qt_${exec.symbol}_${exec.time.millisecondsSinceEpoch}_$ticketSeq',
              openTime: firstOpenTime,
              closeTime: exec.time,
              side: openSide,
              size: matchedTotal,
              symbol: exec.symbol,
              openPrice: avgEntry,
              closePrice: exec.price,
              profit: providedCloseProfit,
              csvSymbolOriginal: exec.csvSymbolOriginal,
            ),
          );
          ticketSeq++;
          continue;
        }
        // If we couldn't match, fall through to normal logic.
      }

      while (remaining > 0) {
        final oppositeIndex = bucket.indexWhere(
          (o) => o.side != exec.side && o.qty > 0,
        );
        if (oppositeIndex < 0) break;
        final open = bucket[oppositeIndex];
        final matchedQty = remaining < open.qty ? remaining : open.qty;

        final openIsLong = open.side == TradeSide.achat;
        final pointValue = _futuresPointValueUsd(exec.symbol);
        final estimatedProfit = openIsLong
            ? (exec.price - open.price) * pointValue * matchedQty
            : (open.price - exec.price) * pointValue * matchedQty;

        final usedProfit = estimatedProfit;

        out.add(
          MtStatementTradeRow(
            ticket: 'qt_${exec.symbol}_${exec.time.millisecondsSinceEpoch}_$ticketSeq',
            openTime: open.time,
            closeTime: exec.time,
            side: open.side,
            size: matchedQty,
            symbol: exec.symbol,
            openPrice: open.price,
            closePrice: exec.price,
            profit: usedProfit,
            csvSymbolOriginal: exec.csvSymbolOriginal,
          ),
        );
        ticketSeq++;

        remaining -= matchedQty;
        final newQty = open.qty - matchedQty;
        if (newQty <= 0) {
          bucket.removeAt(oppositeIndex);
        } else {
          bucket[oppositeIndex] = _TradingViewExecution(
            orderId: open.orderId,
            symbol: open.symbol,
            side: open.side,
            qty: newQty,
            price: open.price,
            time: open.time,
            csvSymbolOriginal: open.csvSymbolOriginal,
          );
        }
      }

      if (remaining > 0) {
        bucket.add(
          _TradingViewExecution(
            orderId: exec.orderId,
            symbol: exec.symbol,
            side: exec.side,
            qty: remaining,
            price: exec.price,
            time: exec.time,
            csvSymbolOriginal: exec.csvSymbolOriginal,
          ),
        );
      }
    }

    return out;
  }

  // Fallback: Orders history format
  final executions = <_TradingViewExecution>[];
  final idxStatus = _csvColumnIndexNorm(header, const <String>['Status']);
  final idxOrderId = _csvColumnIndexNorm(header, const <String>[
    'Order ID',
    'OrderID',
    'OrderId',
    'Order id',
  ]);
  final idxAvgFill = _csvColumnIndexNorm(header, const <String>[
    'Average fill price',
    'Average fill',
    'Avg fill price',
    'Avg Fill Price',
  ]);

  if (idxStatus == null || idxOrderId == null) {
    return const <MtStatementTradeRow>[];
  }

  for (final line in lines.skip(1)) {
    final cols = _parseCsvLine(line);
    final status = _csvAt(cols, idxStatus).toLowerCase().trim();
    if (!status.contains('filled')) continue;

    final sideRaw = _csvAt(cols, idxSide).toLowerCase().trim();
    final TradeSide? side = sideRaw == 'buy'
        ? TradeSide.achat
        : sideRaw == 'sell'
            ? TradeSide.vente
            : null;
    if (side == null) continue;

    final rawSymbol = _csvAt(cols, idxSymbol).trim();
    if (rawSymbol.isEmpty) continue;
    final symbol = _normalizeTvFutureRoot(rawSymbol);

    final qtyRaw = _csvAt(cols, idxQty).trim();
    var qty = _parseMtNumber(qtyRaw);
    if (qty == null) continue;
    if (qty < 0) qty = -qty;
    if (qty <= 0) continue;

    final avgRaw = idxAvgFill == null ? '' : _csvAt(cols, idxAvgFill).trim();
    final pxRaw = avgRaw.isNotEmpty ? avgRaw : _csvAt(cols, idxPrice).trim();
    final price = _parseMtNumber(pxRaw);
    if (price == null) continue;

    final orderId = _csvAt(cols, idxOrderId).trim();
    final time = DateTime.now();

    executions.add(
      _TradingViewExecution(
        orderId: orderId.isEmpty ? 'qt' : orderId,
        symbol: symbol,
        side: side,
        qty: qty,
        price: price,
        time: time,
        csvSymbolOriginal: rawSymbol,
      ),
    );
  }

  return _fifoMatchFuturesExecutions(executions, ticketPrefix: 'qt');
}
