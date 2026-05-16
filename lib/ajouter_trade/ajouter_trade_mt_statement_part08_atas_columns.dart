part of 'ajouter_trade_mt_statement_import.dart';


DateTime _excelSerialToUtcDateTime(double serial) {
  final whole = serial.floor();
  final frac = serial - whole;
  final base = DateTime.utc(1899, 12, 30);
  final datePart = base.add(Duration(days: whole));
  final ms = (frac * Duration.millisecondsPerDay).round();
  return datePart.add(Duration(milliseconds: ms));
}

/// Dates export ATAS (feuille Journal) : nombre sÃ©riel Excel ; sinon formats texte habituels.
DateTime? _parseAtasDateTime(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  final asDouble = double.tryParse(t.replaceAll(',', '.'));
  if (asDouble != null && asDouble > 29542 && asDouble < 65000) {
    return _excelSerialToUtcDateTime(asDouble);
  }
  return _parseNinjaTraderGridDateTime(t) ??
      _parseTradovateCsvDateTime(t) ??
      _parseMtDateTime(t);
}

class _AtasColumnIndices {
  const _AtasColumnIndices({
    required this.instr,
    required this.openT,
    required this.openPx,
    required this.closeT,
    required this.closePx,
    this.vol,
    this.openVol,
    this.closeVol,
    this.pnl,
    this.side,
  });

  final int instr;
  final int openT;
  final int openPx;
  final int closeT;
  final int closePx;
  /// Ancien export Â«â€¯Long 1 / Short 1â€¯Â» ou volume + colonne Side.
  final int? vol;
  /// Feuille **Journal** ATAS : volumes signÃ©s (ex. `-1` = short 1 lot).
  final int? openVol;
  final int? closeVol;
  final int? pnl;
  final int? side;

  bool get _journalSignedVolumes =>
      openVol != null && closeVol != null && vol == null;
}

String _atasNormHeaderKey(String s) {
  var t = s.trim().toLowerCase().replaceAll('\uFEFF', '');
  t = t.replaceAll('\u00A0', ' ');
  t = t.replaceAll(RegExp(r"[''`Â´]"), '');
  t = t.replaceAll(RegExp(r'\s'), '');
  return t;
}

int? _atasColumnIndex(List<String> lowered, List<String> candidates) {
  for (final cand in candidates) {
    final key = _atasNormHeaderKey(cand);
    final i = lowered.indexOf(key);
    if (i >= 0) return i;
  }
  return null;
}

int? _atasFirstColumnWhere(
  List<String> lowered,
  bool Function(String h) matches,
) {
  for (var i = 0; i < lowered.length; i++) {
    if (matches(lowered[i])) return i;
  }
  return null;
}

_AtasColumnIndices? _atasResolveColumns(List<String> header) {
  final lowered = header.map(_atasNormHeaderKey).toList();

  var idxInstr = _atasColumnIndex(lowered, const <String>[
    'instrument',
    'symbol',
    'ticker',
    'symbole',
    'instruments',
  ]);
  var idxOpenT = _atasColumnIndex(lowered, const <String>[
    'opentime',
    'entrytime',
    'datetimeopen',
    'starttime',
    'timestam',
    'heuredouverture',
    'dateheureouverture',
  ]);
  var idxOpenPx = _atasColumnIndex(lowered, const <String>[
    'openprice',
    'entryprice',
    'pxopen',
    'prixdouverture',
  ]);
  var idxCloseT = _atasColumnIndex(lowered, const <String>[
    'closetime',
    'exittime',
    'datetimeclose',
    'endtime',
    'heuredefermeture',
    'heuredecloture',
    'dateheurefermeture',
  ]);
  var idxClosePx = _atasColumnIndex(lowered, const <String>[
    'closeprice',
    'exitprice',
    'pxclose',
    'prixdecloture',
  ]);
  var idxOpenVolOnly = _atasColumnIndex(lowered, const <String>[
    'openvolume',
  ]);
  var idxCloseVolOnly = _atasColumnIndex(lowered, const <String>[
    'closevolume',
  ]);
  var idxVolSingle = _atasColumnIndex(lowered, const <String>[
    'volume',
    'qty',
    'quantity',
    'size',
    'lots',
    'contracts',
    'position',
  ]);
  final idxPnl = _atasColumnIndex(lowered, const <String>[
    'pnl',
    'profit',
    'netpnl',
    'netprofit',
    'gain',
    'realizedpnl',
    'benefice',
    'pl',
  ]);
  final idxSide = _atasColumnIndex(lowered, const <String>[
    'side',
    'type',
    'direction',
    'bs',
    'sens',
    'positiontype',
  ]);

  // Second passe : libellÃ©s ATAS / Excel variables (sous-chaÃ®nes).
  idxInstr ??= _atasFirstColumnWhere(
    lowered,
    (h) =>
        h.contains('instrument') ||
        h.contains('symbole') ||
        (h.contains('symbol') && !h.contains('comment')),
  );
  idxOpenT ??= _atasFirstColumnWhere(
    lowered,
    (h) =>
        h == 'opentime' ||
        h == 'entrytime' ||
        (h.contains('open') &&
            h.contains('time') &&
            !h.contains('close') &&
            !h.contains('price')),
  );
  idxCloseT ??= _atasFirstColumnWhere(
    lowered,
    (h) =>
        h == 'closetime' ||
        (h.contains('close') &&
            h.contains('time') &&
            !h.contains('open') &&
            !h.contains('price')),
  );
  idxOpenPx ??= _atasFirstColumnWhere(
    lowered,
    (h) =>
        h.contains('open') &&
        (h.contains('price') || h.contains('px')) &&
        !h.contains('close'),
  );
  idxClosePx ??= _atasFirstColumnWhere(
    lowered,
    (h) =>
        h.contains('close') &&
        (h.contains('price') || h.contains('px')) &&
        !h.contains('open'),
  );
  idxOpenVolOnly ??= _atasFirstColumnWhere(
    lowered,
    (h) =>
        h.contains('open') &&
        (h.contains('vol') || h.contains('lot') || h.contains('qty')) &&
        !h.contains('close'),
  );
  idxCloseVolOnly ??= _atasFirstColumnWhere(
    lowered,
    (h) =>
        h.contains('close') &&
        (h.contains('vol') || h.contains('lot') || h.contains('qty')),
  );

  if (idxInstr == null ||
      idxOpenT == null ||
      idxOpenPx == null ||
      idxCloseT == null ||
      idxClosePx == null) {
    return null;
  }

  // Feuille **Journal** ATAS : Open volume / Close volume numÃ©riques signÃ©s.
  if (idxOpenVolOnly != null && idxCloseVolOnly != null) {
    return _AtasColumnIndices(
      instr: idxInstr,
      openT: idxOpenT,
      openPx: idxOpenPx,
      closeT: idxCloseT,
      closePx: idxClosePx,
      openVol: idxOpenVolOnly,
      closeVol: idxCloseVolOnly,
      pnl: idxPnl,
      side: idxSide,
    );
  }

  if (idxVolSingle == null) return null;

  return _AtasColumnIndices(
    instr: idxInstr,
    openT: idxOpenT,
    openPx: idxOpenPx,
    closeT: idxCloseT,
    closePx: idxClosePx,
    vol: idxVolSingle,
    pnl: idxPnl,
    side: idxSide,
  );
}
