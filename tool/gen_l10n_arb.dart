// dart run tool/gen_l10n_arb.dart
//
// Les chaÃ®nes sont dÃ©coupÃ©es en [part] (dossier tool/l10n/) pour rester < ~300 lignes par fichier.
// lib/l10n/app_*.arb : un seul fichier par locale (exigence flutter gen-l10n).
// lib/l10n/app_localizations*.dart : gÃ©nÃ©rÃ©s monolithiques par Flutter (non dÃ©coupables sans sortir de gen-l10n).
import 'dart:convert';
import 'dart:io';

import 'l10n/arb_metadata.dart';

part 'l10n/locale_maps_de_0.dart';
part 'l10n/locale_maps_de_1.dart';
part 'l10n/locale_maps_de.dart';
part 'l10n/locale_maps_en_0.dart';
part 'l10n/locale_maps_en_1.dart';
part 'l10n/locale_maps_en.dart';
part 'l10n/locale_maps_es_0.dart';
part 'l10n/locale_maps_es_1.dart';
part 'l10n/locale_maps_es.dart';
part 'l10n/locale_maps_fr_0.dart';
part 'l10n/locale_maps_fr_1.dart';
part 'l10n/locale_maps_fr.dart';
part 'l10n/locale_maps_it_0.dart';
part 'l10n/locale_maps_it_1.dart';
part 'l10n/locale_maps_it.dart';
part 'l10n/locale_maps_ko_0.dart';
part 'l10n/locale_maps_ko_1.dart';
part 'l10n/locale_maps_ko.dart';
part 'l10n/locale_maps_pt_0.dart';
part 'l10n/locale_maps_pt_1.dart';
part 'l10n/locale_maps_pt.dart';
part 'l10n/locale_maps_zh_tw_0.dart';
part 'l10n/locale_maps_zh_tw_1.dart';
part 'l10n/locale_maps_zh_tw.dart';
part 'l10n/locale_maps.dart';

void main() {
  final root = Directory.current;
  final out = Directory('${root.path}/lib/l10n');
  out.createSync(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');

  const locales = ['en', 'fr', 'es', 'pt', 'ko', 'zh_TW', 'de', 'it'];
  for (final loc in locales) {
    final fname = loc == 'zh_TW' ? 'app_zh_TW.arb' : 'app_$loc.arb';
    final f = File('${out.path}/$fname');
    f.writeAsStringSync('${encoder.convert(buildArbMap(loc))}\n');
    // ignore: avoid_print
    print('Wrote ${f.path}');
  }
  final zhTwPath = File('${out.path}/app_zh_TW.arb');
  final zhPath = File('${out.path}/app_zh.arb');
  zhPath.writeAsStringSync(
    zhTwPath.readAsStringSync().replaceFirst(
          '"@@locale": "zh_TW"',
          '"@@locale": "zh"',
        ),
  );
  // ignore: avoid_print
  print('Wrote ${zhPath.path} (fallback zh)');
}

Map<String, dynamic> buildArbMap(String loc) {
  final m = _t[loc]!;
  final map = <String, dynamic>{'@@locale': loc};
  for (final e in m.entries) {
    map[e.key] = e.value;
  }
  applyArbPlaceholderMetadata(map);
  return map;
}



