part of 'ajouter_trade_mt_statement_import.dart';


/// Racines reconnues **du plus long au plus court** pour [alnum.startsWith] (hors [6E], traitÃ© Ã  part).
const _futureRootLongestFirst = <String>[
  'MNQ', 'MES', 'MCL', 'MGC', 'MYM', 'M2K', 'SIL', 'RTY',
  'ES', 'NQ', 'YM', 'CL', 'GC', 'SI', 'HG', 'NG', 'ZB', 'ZN', 'BZ',
];

/// \$ P&L par **1,00 unitÃ© de prix cotÃ©e** du contrat Ã— nb de contrats (ordre de grandeur CME/NYMEX/COMEX).
const _futureUsdPerFullPriceUnit = <String, double>{
  '6E': 125000,
  'MNQ': 2,
  'MES': 5,
  'NQ': 20,
  'ES': 50,
  'MYM': 0.5,
  'YM': 5,
  'M2K': 5,
  'SIL': 2500,
  'RTY': 50,
  'CL': 1000,
  'MCL': 500,
  'GC': 100,
  'MGC': 10,
  'SI': 5000,
  'NG': 10000,
  'HG': 25000,
  'ZB': 1000,
  'ZN': 800,
  'BZ': 1000,
};

double _futuresPointValueUsd(String rawSymbol) {
  final symbol = _normalizeTvFutureRoot(rawSymbol);
  return _futureUsdPerFullPriceUnit[symbol] ?? 1.0;
}

String _normalizeTvFutureRoot(String raw) {
  final upper = raw.trim().toUpperCase();
  final after = upper.contains(':') ? upper.split(':').last : upper;
  final alnumPrefix = RegExp(r'^([A-Z0-9]+)').firstMatch(after)?.group(1) ?? '';
  if (alnumPrefix.isEmpty) {
    return after.length >= 2 ? after.substring(0, 2) : after;
  }
  if (alnumPrefix.startsWith('6E')) return '6E';
  for (final root in _futureRootLongestFirst) {
    if (alnumPrefix.startsWith(root)) return root;
  }
  if (alnumPrefix.length >= 2) return alnumPrefix.substring(0, 2);
  return alnumPrefix;
}

void _appendUniqueMtRow(
  List<MtStatementTradeRow> out,
  Set<String> seen,
  MtStatementTradeRow row,
) {
  final key = '${row.ticket}_${row.closeTime.millisecondsSinceEpoch}';
  if (seen.add(key)) out.add(row);
}

String? _extractMt5PositionsHtmlSection(String html) {
  final lower = html.toLowerCase();
  final from = lower.indexOf('<b>positions</b>');
  if (from < 0) return null;
  var end = lower.length;
  for (final marker in const <String>[
    '<b>ordres</b>',
    '<b>orders</b>',
    '<b>transactions</b>',
  ]) {
    final idx = lower.indexOf(marker, from + 1);
    if (idx >= 0 && idx < end) end = idx;
  }
  return html.substring(from, end);
}

bool _looksLikeMt5PositionsHeader(List<String> normalized) {
  final joined = normalized.join(' ');
  return joined.contains('position') &&
      joined.contains('symbol') &&
      joined.contains('type') &&
      joined.contains('volume') &&
      joined.contains('profit');
}

MtStatementTradeRow? _parseMt5ByHeader(
  List<String> cells,
  List<String> header,
) {
  final idxOpenTime = _indexByContains(header, const <String>[
    'heure',
    'time',
  ], fromEnd: false);
  final idxTicket = _indexByContains(header, const <String>[
    'position',
  ], fromEnd: false);
  final idxSymbol = _indexByContains(header, const <String>[
    'symbol',
    'symbole',
  ], fromEnd: false);
  final idxType = _indexByContains(header, const <String>[
    'type',
  ], fromEnd: false);
  final idxVolume = _indexByContains(header, const <String>[
    'volume',
    'size',
  ], fromEnd: false);
  final idxOpenPrice = _indexByContains(header, const <String>[
    'prix',
    'price',
  ], fromEnd: false);
  final idxCloseTime = _indexByContains(header, const <String>[
    'heure',
    'time',
  ], fromEnd: true);
  final idxClosePrice = _indexByContains(header, const <String>[
    'prix',
    'price',
  ], fromEnd: true);
  final idxProfit = _indexByContains(header, const <String>[
    'profit',
    'p/l',
  ], fromEnd: false);

  final ticket = _cellAt(cells, idxTicket).trim();
  if (!RegExp(r'^\d+$').hasMatch(ticket)) return null;
  final type = _cellAt(cells, idxType).trim().toLowerCase();
  final side = type == 'buy'
      ? TradeSide.achat
      : type == 'sell'
      ? TradeSide.vente
      : null;
  if (side == null) return null;

  final openTime = _parseMtDateTime(_cellAt(cells, idxOpenTime));
  final closeTime = _parseMtDateTime(_cellAt(cells, idxCloseTime));
  final size = _parseMtNumber(_cellAt(cells, idxVolume));
  final openPrice = _parseMtNumber(_cellAt(cells, idxOpenPrice));
  final closePrice = _parseMtNumber(_cellAt(cells, idxClosePrice));
  final profit = _parseMtNumber(_cellAt(cells, idxProfit));
  final symbol = _cellAt(cells, idxSymbol).trim();

  if (openTime == null ||
      closeTime == null ||
      size == null ||
      openPrice == null ||
      closePrice == null ||
      profit == null ||
      symbol.isEmpty) {
    return null;
  }

  return MtStatementTradeRow(
    ticket: ticket,
    openTime: openTime,
    closeTime: closeTime,
    side: side,
    size: size,
    symbol: symbol,
    openPrice: openPrice,
    closePrice: closePrice,
    profit: profit,
  );
}

MtStatementTradeRow? _parseMt5Fixed13(List<String> cells) {
  if (cells.length < 13) return null;
  final ticket = cells[1].trim();
  if (!RegExp(r'^\d+$').hasMatch(ticket)) return null;
  final type = cells[3].trim().toLowerCase();
  final side = type == 'buy'
      ? TradeSide.achat
      : type == 'sell'
      ? TradeSide.vente
      : null;
  if (side == null) return null;

  final openTime = _parseMtDateTime(cells[0]);
  final closeTime = _parseMtDateTime(cells[8]);
  final size = _parseMtNumber(cells[4]);
  final openPrice = _parseMtNumber(cells[5]);
  final closePrice = _parseMtNumber(cells[9]);
  final profit = _parseMtNumber(cells[12]);
  final symbol = cells[2].trim();

  if (openTime == null ||
      closeTime == null ||
      size == null ||
      openPrice == null ||
      closePrice == null ||
      profit == null ||
      symbol.isEmpty) {
    return null;
  }

  return MtStatementTradeRow(
    ticket: ticket,
    openTime: openTime,
    closeTime: closeTime,
    side: side,
    size: size,
    symbol: symbol,
    openPrice: openPrice,
    closePrice: closePrice,
    profit: profit,
  );
}
