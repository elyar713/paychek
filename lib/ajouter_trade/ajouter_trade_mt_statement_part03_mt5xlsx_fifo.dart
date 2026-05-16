part of 'ajouter_trade_mt_statement_import.dart';


List<MtStatementTradeRow> parseMt5StatementXlsx(Uint8List bytes) {
  final excel = Excel.decodeBytes(bytes);
  final out = <MtStatementTradeRow>[];
  final seen = <String>{};
  var sawPositionsSection = false;

  for (final table in excel.tables.values) {
    var inPositions = false;
    List<String> headerLower = const <String>[];

    for (final row in table.rows) {
      final cells = row
          .map((c) => _excelCellToPlain(c?.value))
          .toList(growable: false);
      final lower = cells
          .map((e) => e.toLowerCase().trim())
          .toList(growable: false);

      if (!inPositions) {
        if (lower.any((v) => v.contains('positions'))) {
          inPositions = true;
          sawPositionsSection = true;
          headerLower = const <String>[];
        }
        continue;
      }

      if (lower.any(
        (v) =>
            v.contains('ordres') ||
            v.contains('orders') ||
            v.contains('transactions'),
      )) {
        break;
      }

      if (headerLower.isEmpty) {
        final normalized = lower
            .map(_normalizeHeaderToken)
            .toList(growable: false);
        if (_looksLikeMt5PositionsHeader(normalized)) {
          headerLower = normalized;
          continue;
        }
        final fixed = _parseMt5Fixed13(cells);
        if (fixed != null) _appendUniqueMtRow(out, seen, fixed);
        continue;
      }

      final rowParsed = _parseMt5ByHeader(cells, headerLower);
      if (rowParsed != null) {
        _appendUniqueMtRow(out, seen, rowParsed);
      } else {
        final fixed = _parseMt5Fixed13(cells);
        if (fixed != null) _appendUniqueMtRow(out, seen, fixed);
      }
    }
  }

  if (out.isEmpty && !sawPositionsSection) {
    for (final table in excel.tables.values) {
      for (final row in table.rows) {
        final cells = row
            .map((c) => _excelCellToPlain(c?.value))
            .toList(growable: false);
        final fixed = _parseMt5Fixed13(cells);
        if (fixed != null) _appendUniqueMtRow(out, seen, fixed);
      }
    }
  }

  return out;
}

int? _tvHeaderIndex(List<String> header, List<String> candidates) {
  for (final c in candidates) {
    final i = header.indexOf(c);
    if (i >= 0) return i;
  }
  return null;
}

/// En-tÃªtes TradingView : dâ€™abord Ã©galitÃ© stricte, puis normalisation (casse / espaces / BOM rÃ©siduel colonne).
int? _tvColumnIndex(List<String> header, List<String> candidates) {
  final fromExact = _tvHeaderIndex(header, candidates);
  if (fromExact != null) return fromExact;
  return _csvColumnIndexNorm(header, candidates);
}

String _stripLeadingUtf8Bom(String s) {
  if (s.isEmpty) return s;
  return s.startsWith('\uFEFF') ? s.substring(1) : s;
}

bool _tvStatusMeansFilled(String raw) {
  final s = raw.toLowerCase().trim();
  if (s.isEmpty) return false;
  if (s.contains('partial')) return false;
  if (s.contains('cancel')) return false;
  if (s.contains('pending')) return false;
  if (s.contains('working')) return false;
  if (s.contains('reject')) return false;
  return s == 'rempli' ||
      s == 'filled' ||
      s == 'fully filled' ||
      s == 'complete' ||
      s == 'executed' ||
      s == 'closed' ||
      s == 'close' ||
      s == 'clos' ||
      s == 'fermé' ||
      s == 'fermée' ||
      s == 'fermee' ||
      s == 'done' ||
      s == 'settled' ||
      s == 'terminÃ©' ||
      s == 'termine' ||
      s == 'terminé';
}

/// En-tÃªtes CSV sans tenir compte des espaces / casse (ex. Tradovate).
int? _csvColumnIndexNorm(List<String> header, List<String> candidates) {
  final lowered =
      header.map((e) => e.trim().toLowerCase().replaceAll(' ', '')).toList();
  for (final cand in candidates) {
    final key = cand.trim().toLowerCase().replaceAll(' ', '');
    final i = lowered.indexOf(key);
    if (i >= 0) return i;
  }
  return null;
}

/// Dates type export Tradovateâ€¯: `MM/dd/yyyy HH:mm:ss`.
DateTime? _parseTradovateCsvDateTime(String raw) {
  final s = raw.trim().replaceAll('\u00A0', ' ');
  final m = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})',
  ).firstMatch(s);
  if (m == null) return null;
  try {
    final month = int.parse(m.group(1)!);
    final day = int.parse(m.group(2)!);
    final year = int.parse(m.group(3)!);
    final hh = int.parse(m.group(4)!);
    final mm = int.parse(m.group(5)!);
    final ss = int.parse(m.group(6)!);
    return DateTime(year, month, day, hh, mm, ss);
  } catch (_) {
    return null;
  }
}

/// Appariement entrÃ©e/sortie FIFO par symbole ([_futuresPointValueUsd]).
List<MtStatementTradeRow> _fifoMatchFuturesExecutions(
  List<_TradingViewExecution> executions, {
  required String ticketPrefix,
}) {
  if (executions.isEmpty) return const <MtStatementTradeRow>[];

  executions.sort((a, b) => a.time.compareTo(b.time));
  final openBySymbol = <String, List<_TradingViewExecution>>{};
  final trades = <MtStatementTradeRow>[];
  var ticketSeq = 0;

  for (final exec in executions) {
    final bucket = openBySymbol.putIfAbsent(
      exec.symbol,
      () => <_TradingViewExecution>[],
    );
    var remaining = exec.qty;

    while (remaining > 0) {
      final oppositeIndex = bucket.indexWhere(
        (o) => o.side != exec.side && o.qty > 0,
      );
      if (oppositeIndex < 0) break;
      final open = bucket[oppositeIndex];
      final matchedQty = remaining < open.qty ? remaining : open.qty;

      final openIsLong = open.side == TradeSide.achat;
      final pointValue = _futuresPointValueUsd(exec.symbol);
      final profit = openIsLong
          ? (exec.price - open.price) * pointValue * matchedQty
          : (open.price - exec.price) * pointValue * matchedQty;
      trades.add(
        MtStatementTradeRow(
          ticket: '${ticketPrefix}_${open.orderId}_${exec.orderId}_$ticketSeq',
          openTime: open.time,
          closeTime: exec.time,
          side: open.side,
          size: matchedQty,
          symbol: exec.symbol,
          openPrice: open.price,
          closePrice: exec.price,
          profit: profit,
          csvSymbolOriginal: exec.csvSymbolOriginal ?? open.csvSymbolOriginal,
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

  return trades;
}
