part of 'ajouter_trade_mt_statement_import.dart';


int _indexByContains(
  List<String> values,
  List<String> tokens, {
  required bool fromEnd,
}) {
  if (fromEnd) {
    for (var i = values.length - 1; i >= 0; i--) {
      final v = values[i];
      for (final t in tokens) {
        if (v.contains(t)) return i;
      }
    }
    return -1;
  }
  for (var i = 0; i < values.length; i++) {
    final v = values[i];
    for (final t in tokens) {
      if (v.contains(t)) return i;
    }
  }
  return -1;
}

String _normalizeHeaderToken(String value) {
  final v = value.toLowerCase().trim();
  return v
      .replaceAll('Ã©', 'e')
      .replaceAll('Ã¨', 'e')
      .replaceAll('Ãª', 'e')
      .replaceAll('Ã ', 'a')
      .replaceAll('Ã¹', 'u');
}

String _cellAt(List<String> cells, int idx) {
  if (idx < 0 || idx >= cells.length) return '';
  return cells[idx];
}

String _htmlToText(String raw) {
  var s = raw;
  s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ');
  s = s.replaceAll(RegExp(r'<[^>]+>'), '');
  s = s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
  s = s
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u200B', '')
      .replaceAll('\uFEFF', '');
  return s.trim();
}

DateTime? _parseMtDateTime(String raw) {
  var cleaned = raw
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u200B', '')
      .replaceAll('\uFEFF', '')
      .trim();
  if (cleaned.isEmpty || cleaned.toLowerCase() == 'no transactions') {
    return null;
  }
  final embedded = RegExp(
    r'(\d{4}[.-]\d{2}[.-]\d{2}\s+\d{2}:\d{2}:\d{2})',
  ).firstMatch(cleaned);
  if (embedded != null) {
    cleaned = (embedded.group(1) ?? cleaned).replaceAll('-', '.');
  }
  try {
    return DateFormat('yyyy.MM.dd HH:mm:ss').parseStrict(cleaned);
  } catch (_) {
    // Common alternate string format.
    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(cleaned);
    } catch (_) {
      final iso = DateTime.tryParse(cleaned);
      if (iso != null) return iso;
      // TradingView / Europe : jour-mois-année
      try {
        return DateFormat('dd/MM/yyyy HH:mm:ss').parseStrict(cleaned);
      } catch (_) {}
      try {
        return DateFormat('dd/MM/yyyy HH:mm').parseStrict(cleaned);
      } catch (_) {}
      try {
        return DateFormat('MM/dd/yyyy HH:mm:ss').parseStrict(cleaned);
      } catch (_) {}
      try {
        return DateFormat('MM/dd/yyyy HH:mm').parseStrict(cleaned);
      } catch (_) {}
      // Excel package may stringify as DateCellValue(year: 2026, month: 5, ...)
      final y = RegExp(
        r'year:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(cleaned);
      final m = RegExp(
        r'month:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(cleaned);
      final d = RegExp(
        r'day:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(cleaned);
      if (y == null || m == null || d == null) return null;
      final hh = RegExp(
        r'hour:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(cleaned);
      final mm = RegExp(
        r'minute:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(cleaned);
      final ss = RegExp(
        r'second:\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(cleaned);
      return DateTime(
        int.parse(y.group(1)!),
        int.parse(m.group(1)!),
        int.parse(d.group(1)!),
        hh == null ? 0 : int.parse(hh.group(1)!),
        mm == null ? 0 : int.parse(mm.group(1)!),
        ss == null ? 0 : int.parse(ss.group(1)!),
      );
    }
  }
}

double? _parseMtNumber(String raw) {
  final cleaned = raw.replaceAll(' ', '').replaceAll(',', '.').trim();
  if (cleaned.isEmpty) return null;
  final direct = double.tryParse(cleaned);
  if (direct != null) return direct;

  // Excel package may stringify as DoubleCellValue(value: 1.16946)
  final firstNumber = RegExp(r'[-+]?\d*\.?\d+').firstMatch(cleaned)?.group(0);
  if (firstNumber == null || firstNumber.isEmpty) return null;
  return double.tryParse(firstNumber);
}

String _excelCellToPlain(CellValue? cellValue) {
  if (cellValue == null) return '';
  final raw = cellValue.toString().trim();
  final m = RegExp(r'value:\s*(.*?)\)$').firstMatch(raw);
  if (m != null) return (m.group(1) ?? '').trim();
  return raw;
}

List<String> _parseCsvLine(String line, {String fieldDelimiter = ','}) {
  if (fieldDelimiter.length != 1) {
    throw ArgumentError.value(fieldDelimiter, 'fieldDelimiter', 'CSV separator must be a single character');
  }
  final delim = fieldDelimiter;
  final out = <String>[];
  final b = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        b.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (ch == delim && !inQuotes) {
      out.add(b.toString());
      b.clear();
    } else {
      b.write(ch);
    }
  }
  out.add(b.toString());
  return out;
}

String _csvAt(List<String> cols, int idx) {
  if (idx < 0 || idx >= cols.length) return '';
  return cols[idx];
}
