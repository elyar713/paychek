part of 'ajouter_trade_mt_statement_import.dart';


String? _extractCtraderHistoryHtmlSection(String html) {
  final lower = html.toLowerCase();
  const starts = <String>[
    '<strong>historique</strong>',
    '<strong>history</strong>',
  ];
  var startIdx = -1;
  for (final s in starts) {
    final i = lower.indexOf(s);
    if (i >= 0 && (startIdx < 0 || i < startIdx)) {
      startIdx = i;
    }
  }
  if (startIdx < 0) return null;

  const endMarks = <String>[
    '<strong>positions</strong>',
    '<strong>positionen</strong>',
    '<strong>orders</strong>',
    '<strong>ordres</strong>',
  ];
  var endIdx = html.length;
  for (final e in endMarks) {
    final j = lower.indexOf(e, startIdx + 30);
    if (j >= 0 && j < endIdx) {
      endIdx = j;
    }
  }
  return html.substring(startIdx, endIdx);
}

bool _looksLikeCtraderHistoryHeader(List<String> norm) {
  var hasId = false;
  var hasSymbol = false;
  var hasClosingOrNet = false;
  for (final n in norm) {
    final t = n.trim();
    if (t.isEmpty) continue;
    if (t == 'id') {
      hasId = true;
    }
    if (t.contains('symbole') || t == 'symbol') {
      hasSymbol = true;
    }
    if ((t.contains('quantite') && t.contains('cloture')) ||
        (t.contains('quantity') && t.contains('closing')) ||
        (t.contains('lots') && t.contains('closing')) ||
        (t.contains('heure') && t.contains('cloture')) ||
        (t.contains('closing') && t.contains('time'))) {
      hasClosingOrNet = true;
    }
  }
  return hasId && hasSymbol && hasClosingOrNet;
}

void _fillCtraderHistoryColumnIndices(
  List<String> norm,
  Map<String, int> col,
) {
  for (var i = 0; i < norm.length; i++) {
    final n = norm[i].trim();
    if (n.isEmpty) continue;

    void put(String key, int idx) => col[key] ??= idx;

    if (n == 'id') put('id', i);

    if (n.contains('symbole') || n == 'symbol') put('symbol', i);

    if (n == 'side' ||
        (n.contains('sens') && n.contains('ouverture')) ||
        (n.contains('opening') &&
            (n.contains('side') || n.contains('sense')))) {
      put('side', i);
    }

    if ((n.contains('heure') || n.contains('zeit')) &&
        (n.contains('cloture') || n.contains('close'))) {
      put('closeTime', i);
    }

    if ((n.contains('closing') && n.contains('time')) ||
        (n.contains('geschlossen') && (n.contains('zeit') || n.contains('time')))) {
      put('closeTime', i);
    }

    if (((n.contains('cours') || n.contains('course')) &&
            (n.contains('entree') || n.contains('entry'))) ||
        (n.contains('entry') && n.contains('price'))) {
      put('entryPrice', i);
    }

    if (((n.contains('price') &&
                (n.contains('cloture') || n.contains('close'))) ||
            (n.contains('close') && n.contains('price'))) &&
        !n.contains('time') &&
        !n.contains('heure')) {
      put('exitPrice', i);
    }

    if ((n.contains('quantite') && n.contains('cloture')) ||
        (n.contains('quantity') && n.contains('closing')) ||
        (n.contains('lots') &&
            (n.contains('closing') || n.contains('cloture')))) {
      put('qty', i);
    }

    if (n == 'nets' ||
        (n.startsWith('net') &&
            n.length <= 6 &&
            !n.contains('total') &&
            !n.contains('sous'))) {
      put('net', i);
    }
  }
}

void _applyCtraderColumnLayoutFallback(Map<String, int> col, int cellCount) {
  if (cellCount < 9) return;
  col.putIfAbsent('id', () => 1);
  col.putIfAbsent('symbol', () => 2);
  col.putIfAbsent('side', () => 3);
  col.putIfAbsent('closeTime', () => 4);
  col.putIfAbsent('entryPrice', () => 5);
  col.putIfAbsent('exitPrice', () => 6);
  col.putIfAbsent('qty', () => 7);
  col.putIfAbsent('net', () => 8);
}

MtStatementTradeRow? _parseCtraderHistoryDataRow(
  List<String> cells,
  Map<String, int> col,
) {
  final idIdx = col['id'] ?? -1;
  final symIdx = col['symbol'] ?? -1;
  final sideIdx = col['side'] ?? -1;
  final tCloseIdx = col['closeTime'] ?? -1;
  final pxInIdx = col['entryPrice'] ?? -1;
  final pxOutIdx = col['exitPrice'] ?? -1;
  final qtyIdx = col['qty'] ?? -1;
  final netIdx = col['net'] ?? -1;
  String at(int idx) =>
      idx >= 0 && idx < cells.length ? cells[idx].trim() : '';

  final ticket = at(idIdx);
  if (ticket.isEmpty || ticket.length < 2) return null;

  final symbol = at(symIdx).toUpperCase();
  if (symbol.isEmpty || symbol.startsWith('-')) return null;

  final sideRaw = at(sideIdx).toLowerCase();
  final TradeSide? side =
      sideRaw == 'buy'
          ? TradeSide.achat
          : sideRaw == 'sell'
          ? TradeSide.vente
          : null;
  if (side == null) return null;

  final closeRaw = at(tCloseIdx);
  final closeTime = _parseCtraderDateTime(closeRaw) ?? _parseMtDateTime(closeRaw);
  if (closeTime == null) return null;

  final openPrice = _parseMtNumber(at(pxInIdx));
  final closePrice = _parseMtNumber(at(pxOutIdx));
  final size = _parseCtraderLotsQuantity(at(qtyIdx));
  final profit = _parseMtNumber(at(netIdx));
  if (openPrice == null ||
      closePrice == null ||
      size == null ||
      profit == null) {
    return null;
  }
  // Le relevÃ© nâ€™indique pas lâ€™ouverture : garde chronologie et courbes cumulÃ©es.
  final openTime = closeTime;

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

DateTime? _parseCtraderDateTime(String raw) {
  final s = raw
      .trim()
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u200B', '')
      .replaceAll('\uFEFF', '');
  final m = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})(?:\.(\d{1,6}))?$',
  ).firstMatch(s);
  if (m == null) return null;

  try {
    final day = int.parse(m.group(1)!);
    final month = int.parse(m.group(2)!);
    final year = int.parse(m.group(3)!);
    final hh = int.parse(m.group(4)!);
    final mm = int.parse(m.group(5)!);
    final ss = int.parse(m.group(6)!);

    final frac = m.group(7);
    var milli = 0;
    if (frac != null && frac.isNotEmpty) {
      final padded =
          frac.length <= 3 ? frac.padRight(3, '0') : frac.substring(0, 3);
      milli = int.tryParse(padded) ?? 0;
    }
    return DateTime.utc(year, month, day, hh, mm, ss, milli);
  } catch (_) {
    return null;
  }
}

double? _parseCtraderLotsQuantity(String raw) {
  final cleaned = raw.toLowerCase().replaceAll(',', '.').trim();
  final m =
      RegExp(r'([\d.]+)', caseSensitive: false).firstMatch(cleaned);
  if (m == null || m.group(1)!.isEmpty) return null;
  return double.tryParse(m.group(1)!);
}

String _ctraderHistoryRowKey(MtStatementTradeRow r) =>
    '${r.ticket}_${r.closeTime.millisecondsSinceEpoch}';

bool _ctraderDealIdLooksValid(String raw) {
  final id = raw.trim();
  if (id.length < 2 || id.startsWith('-')) return false;
  return id.startsWith('DID') || RegExp(r'^[\w.-]+$').hasMatch(id);
}

/// RelevÃ© HTML cTrader (Spotware), section **Historique** / **History** (positions clÃ´turÃ©es).
List<MtStatementTradeRow> parseCtraderAccountStatementHtml(String html) {
  final section = _extractCtraderHistoryHtmlSection(html);
  if (section == null || section.trim().isEmpty) {
    return const <MtStatementTradeRow>[];
  }

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

  Map<String, int>? col;
  final out = <MtStatementTradeRow>[];
  final seen = <String>{};

  void tryParseFallbackRow(List<String> cells) {
    if (cells.length < 9) return;
    final fb = <String, int>{};
    _applyCtraderColumnLayoutFallback(fb, cells.length);
    final row = _parseCtraderHistoryDataRow(cells, fb);
    if (row != null && seen.add(_ctraderHistoryRowKey(row))) {
      out.add(row);
    }
  }

  for (final trMatch in trRe.allMatches(section)) {
    final rowHtml = trMatch.group(1) ?? '';
    final lowerRo = rowHtml.toLowerCase();
    if (rowHtml.contains('title-style')) continue;
    if (lowerRo.contains('totals-title') || lowerRo.contains('total-cell')) {
      continue;
    }
    if (lowerRo.contains('- aucune') ||
        lowerRo.contains('aucune position') ||
        lowerRo.contains('no history') ||
        lowerRo.contains('no closed')) {
      continue;
    }

    final cells = tdRe
        .allMatches(rowHtml)
        .map((m) => _htmlToText(m.group(1) ?? ''))
        .toList(growable: false);
    if (cells.length < 4) continue;

    final norm = cells
        .map(_normalizeHeaderToken)
        .map((e) => e.trim())
        .toList(growable: false);

    if (_looksLikeCtraderHistoryHeader(norm)) {
      final next = <String, int>{};
      _fillCtraderHistoryColumnIndices(norm, next);
      _applyCtraderColumnLayoutFallback(next, cells.length);
      col = next;
      continue;
    }

    if (col == null) continue;

    final mapped = Map<String, int>.from(col);
    _applyCtraderColumnLayoutFallback(mapped, cells.length);
    final row = _parseCtraderHistoryDataRow(cells, mapped);
    if (row == null) continue;
    final idIdx = mapped['id'] ?? -1;
    final rawId =
        idIdx >= 0 && idIdx < cells.length ? cells[idIdx].trim() : '';
    if (!_ctraderDealIdLooksValid(rawId)) continue;
    if (!seen.add(_ctraderHistoryRowKey(row))) continue;
    out.add(row);
  }

  if (out.isEmpty) {
    for (final trMatch in trRe.allMatches(section)) {
      final rowHtml = trMatch.group(1) ?? '';
      if (rowHtml.contains('title-style')) continue;
      if (rowHtml.toLowerCase().contains('total-cell')) continue;
      final cells = tdRe
          .allMatches(rowHtml)
          .map((m) => _htmlToText(m.group(1) ?? ''))
          .toList(growable: false);
      tryParseFallbackRow(cells);
    }
  }

  return out;
}
