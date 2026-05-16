part of 'ajouter_trade_mt_statement_import.dart';


/// Grille **Journal** ATAS Statistics courante : Account, Instrument, Open time, â€¦
/// (indices 0-based). UtilisÃ© si les en-tÃªtes ne matchent pas exactement.
List<MtStatementTradeRow> _atasParseFromStringMatrixFixedJournalLayout(
  List<List<String>> matrix,
) {
  const kInstr = 1;
  const kOpenT = 2;
  const kOpenPx = 3;
  const kOpenVol = 4;
  const kCloseT = 5;
  const kClosePx = 6;
  const kCloseVol = 7;

  var headerRow = -1;
  for (var r = 0; r < matrix.length && r < 40; r++) {
    final row = matrix[r];
    if (row.length <= kInstr) continue;
    if (row.every((e) => e.trim().isEmpty)) continue;
    final a = _atasNormHeaderKey(row[kInstr]);
    final b = row.length > kOpenT ? _atasNormHeaderKey(row[kOpenT]) : '';
    if (a.contains('instrument') &&
        (b.contains('open') || b.contains('time') || b.contains('heure'))) {
      headerRow = r;
      break;
    }
  }
  if (headerRow < 0) return const <MtStatementTradeRow>[];

  final hdr = matrix[headerRow];
  if (hdr.length <= kCloseVol) return const <MtStatementTradeRow>[];

  final hn = hdr.map(_atasNormHeaderKey).toList();
  final kPnl = _atasColumnIndex(hn, const ['pnl', 'profit', 'netpnl']) ??
      _atasFirstColumnWhere(hn, (h) => h.contains('pnl')) ??
      (hdr.length > 10 ? 10 : hdr.length - 1);

  final ix = _AtasColumnIndices(
    instr: kInstr,
    openT: kOpenT,
    openPx: kOpenPx,
    closeT: kCloseT,
    closePx: kClosePx,
    openVol: kOpenVol,
    closeVol: kCloseVol,
    vol: null,
    pnl: kPnl < hdr.length ? kPnl : null,
    side: null,
  );

  final needCols = math.max(math.max(kCloseVol, kClosePx), kPnl + 1);
  final out = <MtStatementTradeRow>[];
  var seq = 0;
  for (var r = headerRow + 1; r < matrix.length; r++) {
    final cols = matrix[r];
    if (cols.length < needCols) continue;
    if (cols.every((e) => e.trim().isEmpty)) continue;
    final row = _atasParseOneRow(cols, ix, seq);
    if (row != null) {
      out.add(row);
      seq++;
    }
  }
  return out;
}

({TradeSide side, double size})? _atasParseVolumeAndSide(
  String volRaw,
  List<String> cols,
  int? idxSide,
) {
  final v = volRaw.trim();
  final volRe = RegExp(
    r'^\s*(Long|Short)\s+([\d.,]+)\s*$',
    caseSensitive: false,
  );
  final m = volRe.firstMatch(v);
  if (m != null) {
    final isLong = m.group(1)!.toLowerCase() == 'long';
    final sz = _parseMtNumber(m.group(2) ?? '');
    if (sz != null && sz > 0) {
      return (
        side: isLong ? TradeSide.achat : TradeSide.vente,
        size: sz,
      );
    }
  }

  if (idxSide != null && idxSide >= 0 && idxSide < cols.length) {
    final raw = cols[idxSide].trim().toLowerCase().replaceAll('\u00A0', ' ');
    final compact = raw.replaceAll(RegExp(r'\s'), '');
    final sz = _parseMtNumber(v);
    TradeSide? sd;
    if (compact == 'buy' ||
        compact == 'long' ||
        compact == 'achat' ||
        compact == 'b' ||
        compact.startsWith('buy')) {
      sd = TradeSide.achat;
    } else if (compact == 'sell' ||
        compact == 'short' ||
        compact == 'vente' ||
        compact == 's' ||
        compact.startsWith('sell')) {
      sd = TradeSide.vente;
    }
    if (sd != null && sz != null && sz > 0) {
      return (side: sd, size: sz);
    }
  }
  return null;
}

MtStatementTradeRow? _atasParseOneRow(
  List<String> cols,
  _AtasColumnIndices ix,
  int seq,
) {
  final idxList = <int>[
    ix.instr,
    ix.openT,
    ix.openPx,
    ix.closeT,
    ix.closePx,
    if (ix.vol != null) ix.vol!,
    if (ix.openVol != null) ix.openVol!,
    if (ix.closeVol != null) ix.closeVol!,
    if (ix.pnl != null) ix.pnl!,
    if (ix.side != null) ix.side!,
  ];
  final needLen = idxList.reduce(math.max);
  if (cols.length <= needLen) return null;

  final rawInstr = cols[ix.instr].trim();
  if (rawInstr.isEmpty) return null;

  final ({TradeSide side, double size}) pv;
  if (ix._journalSignedVolumes) {
    final ov = _parseMtNumber(cols[ix.openVol!]);
    if (ov == null || ov == 0) return null;
    final sz = ov.abs();
    final side = ov > 0 ? TradeSide.achat : TradeSide.vente;
    pv = (side: side, size: sz);
  } else if (ix.vol != null) {
    final parsed = _atasParseVolumeAndSide(cols[ix.vol!], cols, ix.side);
    if (parsed == null) return null;
    pv = parsed;
  } else {
    return null;
  }

  final openPx = _parseMtNumber(cols[ix.openPx]);
  final closePx = _parseMtNumber(cols[ix.closePx]);
  if (openPx == null || closePx == null) return null;

  final openRaw = cols[ix.openT].trim();
  final closeRaw = cols[ix.closeT].trim();
  final openTime = _parseAtasDateTime(openRaw);
  final closeTime = _parseAtasDateTime(closeRaw);
  if (openTime == null || closeTime == null) return null;

  double? profit =
      ix.pnl != null ? _parseMtNumber(cols[ix.pnl!]) : null;
  profit ??= () {
    final openIsLong = pv.side == TradeSide.achat;
    final pt = _futuresPointValueUsd(rawInstr);
    return openIsLong
        ? (closePx - openPx) * pt * pv.size
        : (openPx - closePx) * pt * pv.size;
  }();

  final symbol = _normalizeTvFutureRoot(rawInstr);
  final ticket = 'atas_${symbol}_${closeTime.millisecondsSinceEpoch}_$seq';

  return MtStatementTradeRow(
    ticket: ticket,
    openTime: openTime,
    closeTime: closeTime,
    side: pv.side,
    size: pv.size,
    symbol: symbol,
    openPrice: openPx,
    closePrice: closePx,
    profit: profit,
    csvSymbolOriginal: rawInstr,
  );
}

List<MtStatementTradeRow> _atasParseFromStringMatrix(
  List<List<String>> matrix,
) {
  _AtasColumnIndices? ix;
  var headerRow = -1;
  for (var r = 0; r < matrix.length && r < 50; r++) {
    final row = matrix[r];
    if (row.every((e) => e.trim().isEmpty)) continue;
    ix = _atasResolveColumns(row);
    if (ix != null) {
      headerRow = r;
      break;
    }
  }
  if (ix == null) return const <MtStatementTradeRow>[];

  final out = <MtStatementTradeRow>[];
  var seq = 0;
  for (var r = headerRow + 1; r < matrix.length; r++) {
    final cols = matrix[r];
    if (cols.every((e) => e.trim().isEmpty)) continue;
    final row = _atasParseOneRow(cols, ix, seq);
    if (row != null) {
      out.add(row);
      seq++;
    }
  }
  return out;
}

String _atasCsvDelimiter(String firstLine) {
  final semi = ';'.allMatches(firstLine).length;
  final comma = ','.allMatches(firstLine).length;
  if (semi >= 2 && semi >= comma) return ';';
  return ',';
}

/// Export **ATAS** : CSV (`;` ou `,`) ou feuille **Journal** du classeur Statistiques (.xlsx).
/// Volume : `Long 1` / `Short 1`, ou colonne numÃ©rique + **Side** / **Type**.
List<MtStatementTradeRow> parseAtasTradesCsv(String csvContent) {
  final raw = _stripLeadingUtf8Bom(csvContent);
  final lines = raw
      .split(RegExp(r'\r?\n'))
      .where((l) => l.trim().isNotEmpty)
      .map(_stripLeadingUtf8Bom)
      .toList(growable: false);
  if (lines.length < 2) return const <MtStatementTradeRow>[];

  final delim = _atasCsvDelimiter(lines.first);
  List<String> splitLine(String line) {
    if (delim == ',') {
      return _parseCsvLine(line, fieldDelimiter: ',');
    }
    return line.split(';').map((e) => e.trim()).toList(growable: false);
  }

  final matrix = <List<String>>[];
  for (final line in lines) {
    matrix.add(splitLine(line));
  }
  return _atasParseFromStringMatrix(matrix);
}

/// RÃ©sultat import `.xlsx` ATAS : [emptyReason] pour SnackBar si [rows] vide.
class AtasXlsxParseOutcome {
  const AtasXlsxParseOutcome({
    required this.rows,
    this.emptyReason,
  });

  final List<MtStatementTradeRow> rows;
  final String? emptyReason;
}

/// Statistiques ATAS : **uniquement** la feuille **Journal** (ZIP/XML interne au `.xlsx`).
AtasXlsxParseOutcome parseAtasTradesXlsxOutcome(Uint8List bytes) {
  if (bytes.isEmpty) {
    return const AtasXlsxParseOutcome(
      rows: [],
      emptyReason: 'Fichier vide.',
    );
  }
  if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4B) {
    return const AtasXlsxParseOutcome(
      rows: [],
      emptyReason:
          'Ce fichier nâ€™est pas un .xlsx Excel valide (en-tÃªte manquant). RÃ©exporte depuis ATAS.',
    );
  }

  final zipMatrix = readAtasJournalSheetMatrixFromXlsx(bytes);
  if (zipMatrix.length < 2) {
    return const AtasXlsxParseOutcome(
      rows: [],
      emptyReason:
          'Feuille Â« Journal Â» introuvable ou classeur illisible. VÃ©rifie lâ€™export Statistiques .xlsx.',
    );
  }

  var rows = _atasParseFromStringMatrix(zipMatrix);
  if (rows.isEmpty) {
    rows = _atasParseFromStringMatrixFixedJournalLayout(zipMatrix);
  }

  if (rows.isEmpty) {
    return const AtasXlsxParseOutcome(
      rows: [],
      emptyReason:
          'Aucune ligne de trade reconnue. Ouvre la feuille Journal : colonnes Instrument, Open time, Open/Close volume.',
    );
  }
  return AtasXlsxParseOutcome(rows: rows, emptyReason: null);
}

List<MtStatementTradeRow> parseAtasTradesXlsx(Uint8List bytes) =>
    parseAtasTradesXlsxOutcome(bytes).rows;
