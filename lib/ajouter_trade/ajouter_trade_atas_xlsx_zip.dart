import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

// Un fichier `.xlsx` est un classeur Excel ; son format interne est une archive **ZIP**
// (Office Open XML). On décompresse donc les octets du `.xlsx` comme un ZIP — c’est normal.

/// Extrait la matrice de la feuille **Journal** ATAS (Statistiques .xlsx).
///
/// 1. Feuille nommée « Journal » dans le classeur (toutes casses).
/// 2. Sinon, première feuille dont les en-têtes ressemblent au journal ATAS
///    (Instrument, Open time, Open volume…).
List<List<String>> readAtasJournalSheetMatrixFromXlsx(Uint8List bytes) {
  Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    return const <List<String>>[];
  }

  Uint8List? readEntryInsensitive(String path) {
    final want = path.replaceAll('\\', '/').toLowerCase();
    for (final f in archive.files) {
      if (!f.isFile) continue;
      final name = f.name.replaceAll('\\', '/').toLowerCase();
      if (name != want) continue;
      return _archiveFileToBytes(f);
    }
    return null;
  }

  String? utf8OrNull(Uint8List? b) =>
      b == null || b.isEmpty ? null : String.fromCharCodes(b);

  final sstXml = utf8OrNull(readEntryInsensitive('xl/sharedStrings.xml'));
  final shared = sstXml == null ? <String>[] : _parseSharedStrings(sstXml);

  List<List<String>>? trySheetXml(Uint8List? sheetBytes) {
    if (sheetBytes == null) return null;
    final xml = utf8OrNull(sheetBytes);
    if (xml == null) return null;
    final m = _sheetXmlToMatrix(xml, shared);
    return m.isEmpty ? null : m;
  }

  // --- A) Feuille nommée Journal ---
  final workbookXml = utf8OrNull(readEntryInsensitive('xl/workbook.xml'));
  if (workbookXml != null) {
    final journalRid = _workbookJournalRelationshipId(workbookXml) ??
        RegExp(
          r'name\s*=\s*"Journal"[^>]*r:id\s*=\s*"(rId\d+)"',
          caseSensitive: false,
        ).firstMatch(workbookXml)?.group(1);

    if (journalRid != null) {
      final relsXml = utf8OrNull(readEntryInsensitive('xl/_rels/workbook.xml.rels'));
      if (relsXml != null) {
        final sheetPath = _relationshipTargetForId(relsXml, journalRid);
        if (sheetPath != null) {
          final normalized = _normalizeXlTarget(sheetPath);
          final named = trySheetXml(readEntryInsensitive(normalized));
          if (named != null && named.isNotEmpty) {
            return named;
          }
        }
      }
    }
  }

  // --- B) Parcourir toutes les feuilles xl/worksheets/sheetN.xml ---
  for (final path in _listWorksheetPathsSorted(archive)) {
    final m = trySheetXml(readEntryInsensitive(path));
    if (m != null && _hasAtasJournalHeaderRow(m)) {
      return m;
    }
  }

  return const <List<String>>[];
}

Uint8List _archiveFileToBytes(ArchiveFile f) {
  final c = f.content;
  if (c is Uint8List) return c;
  if (c is List<int>) return Uint8List.fromList(c);
  return Uint8List(0);
}

String _normalizeXlTarget(String sheetPath) {
  var p = sheetPath.replaceAll('\\', '/');
  if (p.startsWith('/xl/')) {
    return p.substring(1);
  }
  if (p.startsWith('xl/')) {
    return p;
  }
  if (p.startsWith('/')) {
    return 'xl$p';
  }
  return 'xl/$p';
}

bool _isJournalSheetName(String? name) {
  if (name == null) return false;
  return name.trim().toLowerCase() == 'journal';
}

String? _workbookJournalRelationshipId(String workbookXml) {
  final doc = XmlDocument.parse(workbookXml);
  for (final el in doc.descendants.whereType<XmlElement>()) {
    if (el.name.local != 'sheet') continue;
    if (!_isJournalSheetName(el.getAttribute('name'))) continue;

    for (final a in el.attributes) {
      final v = a.value.trim();
      if (RegExp(r'^rId\d+$').hasMatch(v)) return v;
    }
  }
  return null;
}

String? _relationshipTargetForId(String relsXml, String rid) {
  final doc = XmlDocument.parse(relsXml);
  for (final el in doc.descendants.whereType<XmlElement>()) {
    if (el.name.local != 'Relationship') continue;
    final id = el.getAttribute('Id');
    if (id != rid) continue;
    return el.getAttribute('Target');
  }
  return RegExp(
        r'Id\s*=\s*"$rid"[^>]*Target\s*=\s*"([^"]+)"',
        caseSensitive: false,
      ).firstMatch(relsXml)?.group(1) ??
      RegExp(
        r'Target\s*=\s*"([^"]+)"[^>]*Id\s*=\s*"$rid"',
        caseSensitive: false,
      ).firstMatch(relsXml)?.group(1);
}

/// Chemins `xl/worksheets/sheetN.xml` triés par N (insensible à la casse du chemin archive).
List<String> _listWorksheetPathsSorted(Archive archive) {
  final re = RegExp(r'xl/worksheets/sheet(\d+)\.xml$', caseSensitive: false);
  final items = <({int n, String path})>[];
  for (final f in archive.files) {
    if (!f.isFile) continue;
    final norm = f.name.replaceAll('\\', '/');
    final m = re.firstMatch(norm.toLowerCase());
    if (m != null) {
      items.add((n: int.parse(m.group(1)!), path: norm));
    }
  }
  items.sort((a, b) => a.n.compareTo(b.n));
  return items.map((e) => e.path.replaceAll('\\', '/')).toList();
}

String _headerNorm(String s) {
  var t = s.trim().toLowerCase().replaceAll('\uFEFF', '');
  t = t.replaceAll('\u00A0', ' ');
  t = t.replaceAll(RegExp(r"[''`´]"), '');
  t = t.replaceAll(RegExp(r'\s'), '');
  return t;
}

/// Détecte une ligne d’en-têtes type feuille Journal ATAS (FR/EN).
bool _hasAtasJournalHeaderRow(List<List<String>> matrix) {
  for (final row in matrix.take(40)) {
    if (row.isEmpty || row.every((e) => e.trim().isEmpty)) continue;
    final keys = row.map(_headerNorm).where((s) => s.isNotEmpty).toSet();

    final hasInstr = keys.any(
      (k) => k == 'instrument' || k == 'symbole' || k.contains('instrument'),
    );
    final hasOpenT = keys.any(
      (k) =>
          k == 'opentime' ||
          k == 'heuredouverture' ||
          (k.contains('open') && k.contains('time')),
    );
    final hasCloseT = keys.any(
      (k) =>
          k == 'closetime' ||
          k == 'heuredefermeture' ||
          (k.contains('close') && k.contains('time')),
    );
    final hasVol = (keys.contains('openvolume') && keys.contains('closevolume')) ||
        keys.contains('volume') ||
        keys.contains('qty');

    if (hasInstr && hasOpenT && hasCloseT && hasVol) {
      return true;
    }
  }
  return false;
}

List<String> _parseSharedStrings(String xml) {
  final doc = XmlDocument.parse(xml);
  final out = <String>[];
  for (final si in doc.descendants.whereType<XmlElement>()) {
    if (si.name.local != 'si') continue;
    final buf = StringBuffer();
    for (final t in si.descendants.whereType<XmlElement>()) {
      if (t.name.local == 't') {
        buf.write(t.innerText);
      }
    }
    out.add(buf.toString());
  }
  return out;
}

List<List<String>> _sheetXmlToMatrix(String sheetXml, List<String> sharedStrings) {
  final doc = XmlDocument.parse(sheetXml);

  XmlElement? sheetData;
  for (final el in doc.descendants.whereType<XmlElement>()) {
    if (el.name.local == 'sheetData') {
      sheetData = el;
      break;
    }
  }
  if (sheetData == null) return const <List<String>>[];

  final rowMap = <int, Map<int, String>>{};

  for (final rowEl in sheetData.childElements) {
    if (rowEl.name.local != 'row') continue;

    // Les `<c>` sont en général enfants directs de `<row>`, pas toujours (extensions).
    final cells = rowEl.descendants.whereType<XmlElement>().where(
          (e) => e.name.local == 'c',
        );
    for (final c in cells) {
      final ref = c.getAttribute('r');
      if (ref == null || ref.isEmpty) continue;

      final text = _cellPlainText(c, sharedStrings);
      if (text == null) continue;

      final col = _excelColumnIndexFromCellRef(ref);
      final row = _excelRowFromCellRef(ref);
      if (row < 1) continue;

      rowMap.putIfAbsent(row, () => <int, String>{})[col] = text;
    }
  }

  if (rowMap.isEmpty) return const <List<String>>[];

  final rows = rowMap.keys.toList()..sort();
  var maxCol = 0;
  for (final m in rowMap.values) {
    for (final k in m.keys) {
      if (k > maxCol) maxCol = k;
    }
  }

  final matrix = <List<String>>[];
  for (final rn in rows) {
    final m = rowMap[rn]!;
    final row = List<String>.filled(maxCol + 1, '');
    for (final e in m.entries) {
      if (e.key <= maxCol) {
        row[e.key] = e.value;
      }
    }
    matrix.add(row);
  }
  return matrix;
}

String? _cellPlainText(XmlElement c, List<String> sharedStrings) {
  final t = c.getAttribute('t');

  if (t == 'inlineStr') {
    final buf = StringBuffer();
    for (final el in c.descendants.whereType<XmlElement>()) {
      if (el.name.local == 't') {
        buf.write(el.innerText);
      }
    }
    return buf.toString();
  }

  XmlElement? vEl;
  for (final ch in c.childElements) {
    if (ch.name.local == 'v') {
      vEl = ch;
      break;
    }
  }
  if (vEl == null) {
    for (final ch in c.descendants.whereType<XmlElement>()) {
      if (ch.name.local == 'v' && ch.parent == c) {
        vEl = ch;
        break;
      }
    }
  }
  if (vEl == null) return null;

  final vText = vEl.innerText;
  if (t == 's') {
    return _sharedStringAt(sharedStrings, vText);
  }
  return vText;
}

String _sharedStringAt(List<String> shared, String indexRaw) {
  final i = int.tryParse(indexRaw.trim());
  if (i == null || i < 0 || i >= shared.length) return '';
  return shared[i];
}

int _excelColumnLettersToZeroBased(String letters) {
  var n = 0;
  for (final code in letters.toUpperCase().codeUnits) {
    if (code < 65 || code > 90) break;
    n = n * 26 + (code - 64);
  }
  return n - 1;
}

int _excelColumnIndexFromCellRef(String ref) {
  final m = RegExp(r'^([A-Za-z]+)').firstMatch(ref);
  if (m == null) return 0;
  return _excelColumnLettersToZeroBased(m.group(1)!);
}

int _excelRowFromCellRef(String ref) {
  final m = RegExp(r'(\d+)$').firstMatch(ref);
  return int.tryParse(m?.group(1) ?? '') ?? 0;
}
