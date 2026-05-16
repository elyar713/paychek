// dart run tool/rebuild_locale_maps_from_arb.dart
//
// Reconstruit tool/l10n/locale_maps_*.dart depuis lib/l10n/app_*.arb (UTF-8 correct).
// Fusionne app_<loc>.arb + app_<loc>_2.arb si prÃ©sent.
// Met Ã  jour les directives `part` dans tool/gen_l10n_arb.dart.
// Ensuite : dart run tool/gen_l10n_arb.dart && flutter gen-l10n
import 'dart:convert';
import 'dart:io';

const _maxLinesPerFile = 300;

void main() {
  final root = Directory.current;
  final libL10n = Directory('${root.path}/lib/l10n');
  final outDir = Directory('${root.path}/tool/l10n');
  outDir.createSync(recursive: true);

  _deleteOldLocaleMapParts(outDir);

  final locales = <String, List<String>>{
    'en': ['app_en.arb', 'app_en_2.arb'],
    'fr': ['app_fr.arb', 'app_fr_2.arb'],
    'es': ['app_es.arb', 'app_es_2.arb'],
    'pt': ['app_pt.arb', 'app_pt_2.arb'],
    'ko': ['app_ko.arb', 'app_ko_2.arb'],
    'zh_TW': ['app_zh_TW.arb', 'app_zh_TW_2.arb'],
    'de': ['app_de.arb', 'app_de_2.arb'],
    'it': ['app_it.arb', 'app_it_2.arb'],
  };

  final maps = <String, Map<String, String>>{};
  for (final e in locales.entries) {
    maps[e.key] = _loadMerged(libL10n, e.value);
  }

  _writePartFiles(outDir, maps);
  _syncGenL10nArbParts(root);

  // ignore: avoid_print
  print('Done. locale_maps + gen_l10n_arb.dart parts.');
}

void _deleteOldLocaleMapParts(Directory outDir) {
  for (final entity in outDir.listSync()) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (name.startsWith('locale_maps') && name.endsWith('.dart')) {
      entity.deleteSync();
    }
  }
}

void _syncGenL10nArbParts(Directory root) {
  const locs = ['de', 'en', 'es', 'fr', 'it', 'ko', 'pt', 'zh_tw'];
  final outDir = Directory('${root.path}/tool/l10n');
  final parts = <String>[];
  for (final loc in locs) {
    final stem = 'locale_maps_$loc';
    var i = 0;
    while (File('${outDir.path}/${stem}_$i.dart').existsSync()) {
      parts.add("part 'l10n/${stem}_$i.dart';");
      i++;
    }
    parts.add("part 'l10n/$stem.dart';");
  }
  parts.add("part 'l10n/locale_maps.dart';");

  final genPath = '${root.path}/tool/gen_l10n_arb.dart';
  final f = File(genPath);
  if (!f.existsSync()) return;
  const startMarker = "import 'l10n/arb_metadata.dart';";
  const endMarker = 'void main()';
  final s = f.readAsStringSync();
  final i0 = s.indexOf(startMarker);
  final i1 = s.indexOf(endMarker);
  if (i0 < 0 || i1 < 0 || i1 <= i0) return;
  final head = s.substring(0, i0 + startMarker.length);
  final tail = s.substring(i1);
  f.writeAsStringSync('$head\n\n${parts.join('\n')}\n\n$tail');
}

Map<String, String> _loadMerged(Directory libL10n, List<String> files) {
  final merged = <String, dynamic>{};
  for (final name in files) {
    final f = File('${libL10n.path}/$name');
    if (!f.existsSync()) continue;
    final map = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    merged.addAll(map);
  }
  final out = <String, String>{};
  for (final e in merged.entries) {
    if (e.key.startsWith('@')) continue;
    final v = e.value;
    if (v is String) out[e.key] = v;
  }
  return out;
}

void _writePartFiles(Directory outDir, Map<String, Map<String, String>> maps) {
  final varNames = <String, String>{
    'en': '_en',
    'fr': '_fr',
    'es': '_es',
    'pt': '_pt',
    'ko': '_ko',
    'zh_TW': '_zhTw',
    'de': '_de',
    'it': '_it',
  };

  for (final e in maps.entries) {
    final loc = e.key;
    final map = e.value;
    final baseVar = varNames[loc]!;
    final stem = 'locale_maps_${loc.toLowerCase()}';
    final chunks = _chunkMap(map, _maxLinesPerFile - 40);
    if (chunks.length == 1) {
      final path = '${outDir.path}/$stem.dart';
      final sb = StringBuffer()
        ..writeln("part of '../gen_l10n_arb.dart';")
        ..writeln()
        ..writeln('const $baseVar = <String, String>{');
      _writeEntries(sb, chunks.single);
      sb.writeln('};');
      File(path).writeAsStringSync('$sb\n');
    } else {
      for (var i = 0; i < chunks.length; i++) {
        final partVar = '${baseVar}_$i';
        final path = '${outDir.path}/${stem}_$i.dart';
        final sb = StringBuffer()
          ..writeln("part of '../gen_l10n_arb.dart';")
          ..writeln()
          ..writeln('const $partVar = <String, String>{');
        _writeEntries(sb, chunks[i]);
        sb.writeln('};');
        File(path).writeAsStringSync('$sb\n');
      }
      final sbMerge = StringBuffer()
        ..writeln("part of '../gen_l10n_arb.dart';")
        ..writeln()
        ..writeln('const $baseVar = <String, String>{');
      for (var i = 0; i < chunks.length; i++) {
        sbMerge.writeln('  ...${baseVar}_$i,');
      }
      sbMerge.writeln('};');
      File('${outDir.path}/$stem.dart').writeAsStringSync('$sbMerge\n');
    }
  }

  _writeLocaleMapsIndex(outDir, maps.keys.toList()..sort(), varNames);
}

List<Map<String, String>> _chunkMap(Map<String, String> map, int maxEntries) {
  final keys = map.keys.toList()..sort();
  if (keys.length <= maxEntries) return [map];
  final n = (keys.length / maxEntries).ceil();
  final chunkSize = (keys.length / n).ceil();
  final out = <Map<String, String>>[];
  for (var i = 0; i < keys.length; i += chunkSize) {
    final end = (i + chunkSize > keys.length) ? keys.length : i + chunkSize;
    final m = <String, String>{};
    for (var j = i; j < end; j++) {
      final k = keys[j];
      m[k] = map[k]!;
    }
    out.add(m);
  }
  return out;
}

void _writeEntries(StringBuffer sb, Map<String, String> map) {
  final keys = map.keys.toList()..sort();
  for (final k in keys) {
    sb.writeln('  ${jsonEncode(k)}: ${jsonEncode(map[k])},');
  }
}

void _writeLocaleMapsIndex(
  Directory outDir,
  List<String> sortedLocales,
  Map<String, String> varNames,
) {
  final sb = StringBuffer()
    ..writeln("part of '../gen_l10n_arb.dart';")
    ..writeln()
    ..writeln('/// Table des locales (clÃ© â†’ texte).')
    ..writeln('final Map<String, Map<String, String>> _t = {');
  for (final loc in sortedLocales) {
    sb.writeln("  '$loc': ${varNames[loc]},");
  }
  sb.writeln('};');
  File('${outDir.path}/locale_maps.dart').writeAsStringSync('$sb\n');
}


