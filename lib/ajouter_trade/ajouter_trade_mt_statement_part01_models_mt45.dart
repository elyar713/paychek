part of 'ajouter_trade_mt_statement_import.dart';

class MtStatementTradeRow {
  const MtStatementTradeRow({
    required this.ticket,
    required this.openTime,
    required this.closeTime,
    required this.side,
    required this.size,
    required this.symbol,
    required this.openPrice,
    required this.closePrice,
    required this.profit,
    this.csvSymbolOriginal,
  });

  final String ticket;
  final DateTime openTime;
  final DateTime closeTime;
  final TradeSide side;
  final double size;
  final String symbol;
  final double openPrice;
  final double closePrice;
  final double profit;

  /// LibellÃ© symbole tel que dans lâ€™export (Quantower, etc.) pour classer forex / future / indice.
  final String? csvSymbolOriginal;
}

class _TradingViewExecution {
  const _TradingViewExecution({
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.qty,
    required this.price,
    required this.time,
    this.csvSymbolOriginal,
  });

  final String orderId;
  final String symbol;
  final TradeSide side;
  final double qty;
  final double price;
  final DateTime time;
  final String? csvSymbolOriginal;
}

List<MtStatementTradeRow> parseMt4StatementHtml(String html) {
  final rows = <MtStatementTradeRow>[];
  final trRe = RegExp(
    r'<tr\b[^>]*>(.*?)</tr>',
    caseSensitive: false,
    dotAll: true,
  );
  final tdRe = RegExp(
    r'<td\b[^>]*>(.*?)</td>',
    caseSensitive: false,
    dotAll: true,
  );

  for (final trMatch in trRe.allMatches(html)) {
    final rowHtml = trMatch.group(1) ?? '';
    final cells = tdRe
        .allMatches(rowHtml)
        .map((m) => _htmlToText(m.group(1) ?? ''))
        .toList(growable: false);
    if (cells.length < 14) continue;

    final type = cells[2].trim().toLowerCase();
    if (type != 'buy' && type != 'sell') continue;

    final openTime = _parseMtDateTime(cells[1]);
    final closeTime = _parseMtDateTime(cells[8]);
    final size = _parseMtNumber(cells[3]);
    final openPrice = _parseMtNumber(cells[5]);
    final closePrice = _parseMtNumber(cells[9]);
    final profit = _parseMtNumber(cells[13]);
    if (openTime == null ||
        closeTime == null ||
        size == null ||
        openPrice == null ||
        closePrice == null ||
        profit == null) {
      continue;
    }

    rows.add(
      MtStatementTradeRow(
        ticket: cells[0].trim(),
        openTime: openTime,
        closeTime: closeTime,
        side: type == 'buy' ? TradeSide.achat : TradeSide.vente,
        size: size,
        symbol: cells[4].trim(),
        openPrice: openPrice,
        closePrice: closePrice,
        profit: profit,
      ),
    );
  }
  return rows;
}

List<MtStatementTradeRow> parseMt5StatementHtml(String html) {
  final section = _extractMt5PositionsHtmlSection(html);
  if (section == null) return const <MtStatementTradeRow>[];

  final hiddenTdRe = RegExp(
    r'<td\b[^>]*class\s*=\s*"hidden"[^>]*>.*?</td>',
    caseSensitive: false,
    dotAll: true,
  );
  final trRe = RegExp(
    r'<tr\b[^>]*>(.*?)</tr>',
    caseSensitive: false,
    dotAll: true,
  );
  final tdRe = RegExp(
    r'<td\b[^>]*>(.*?)</td>',
    caseSensitive: false,
    dotAll: true,
  );
  final out = <MtStatementTradeRow>[];
  List<String>? header;

  for (final trMatch in trRe.allMatches(section)) {
    final rowHtml = (trMatch.group(1) ?? '').replaceAll(hiddenTdRe, '');
    final cells = tdRe
        .allMatches(rowHtml)
        .map((m) => _htmlToText(m.group(1) ?? ''))
        .toList(growable: false);
    if (cells.isEmpty) continue;

    if (header == null) {
      final maybeHeader = cells
          .map(_normalizeHeaderToken)
          .toList(growable: false);
      if (_looksLikeMt5PositionsHeader(maybeHeader)) {
        header = maybeHeader;
      }
      continue;
    }

    final parsed = _parseMt5ByHeader(cells, header);
    if (parsed != null) out.add(parsed);
  }
  if (out.isNotEmpty) return out;

  // Fallback for MT5 HTML templates where header matching fails.
  final fallback = <MtStatementTradeRow>[];
  for (final trMatch in trRe.allMatches(section)) {
    final rowHtml = (trMatch.group(1) ?? '').replaceAll(hiddenTdRe, '');
    final cells = tdRe
        .allMatches(rowHtml)
        .map((m) => _htmlToText(m.group(1) ?? ''))
        .toList(growable: false);
    final parsed = _parseMt5Fixed13(cells);
    if (parsed != null) fallback.add(parsed);
  }
  return fallback;
}

/// Export CSV MT5â€¯: lignes sÃ©parÃ©es par des virgules, en-tÃªte type Â«â€¯Positionâ€¯/â€¯Symbole / Type / Volumeâ€¯â€¦â€¯Â» comme dans Excel.
List<MtStatementTradeRow> parseMt5PositionsCsv(String csvContent) {
  final lines = csvContent
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList(growable: false);
  if (lines.length < 2) return const <MtStatementTradeRow>[];

  final out = <MtStatementTradeRow>[];
  List<String>? headerLower;

  void tryParseRow(List<String> rawCells, {required bool fallbackOnly}) {
    final cells =
        rawCells.map((e) => e.trim()).toList(growable: false);
    if (cells.every((e) => e.isEmpty)) return;
    if (fallbackOnly) {
      final fixed = _parseMt5Fixed13(cells);
      if (fixed != null) out.add(fixed);
      return;
    }
    if (headerLower == null) {
      final normalized = cells
          .map(_normalizeHeaderToken)
          .toList(growable: false);
      if (_looksLikeMt5PositionsHeader(normalized)) {
        headerLower = normalized;
        return;
      }
      final fixed = _parseMt5Fixed13(cells);
      if (fixed != null) out.add(fixed);
      return;
    }

    final rowParsed = _parseMt5ByHeader(cells, headerLower!);
    if (rowParsed != null) {
      out.add(rowParsed);
    } else {
      final fixed = _parseMt5Fixed13(cells);
      if (fixed != null) out.add(fixed);
    }
  }

  for (final line in lines) {
    tryParseRow(_parseCsvLine(line), fallbackOnly: false);
  }

  if (out.isEmpty) {
    for (final line in lines) {
      tryParseRow(_parseCsvLine(line), fallbackOnly: true);
    }
  }

  final seen = <String>{};
  final unique = <MtStatementTradeRow>[];
  for (final row in out) {
    final key =
        '${row.ticket}_${row.closeTime.millisecondsSinceEpoch}_${row.symbol}';
    if (seen.add(key)) unique.add(row);
  }
  return unique;
}
