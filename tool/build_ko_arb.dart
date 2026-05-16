// Builds lib/l10n/app_ko.arb from app_en.arb + tool/ko_part_*.json overrides
// Run: dart run tool/build_ko_arb.dart

import 'dart:convert';
import 'dart:io';

void main() {
  final enPath = File('lib/l10n/app_en.arb');
  if (!enPath.existsSync()) {
    stderr.writeln('Missing ${enPath.path}');
    exit(1);
  }
  final en = jsonDecode(enPath.readAsStringSync()) as Map<String, dynamic>;
  final overrides = <String, String>{};
  for (var i = 1; i <= 12; i++) {
    final p = File('tool/ko_part_$i.json');
    if (!p.existsSync()) continue;
    final m = jsonDecode(p.readAsStringSync()) as Map<String, dynamic>;
    for (final e in m.entries) {
      overrides[e.key] = e.value as String;
    }
  }
  final out = <String, dynamic>{'@@locale': 'ko'};
  for (final e in en.entries) {
    final k = e.key;
    if (k == '@@locale') continue;
    final v = e.value;
    if (k.startsWith('@')) {
      out[k] = v;
      continue;
    }
    if (v is String) {
      out[k] = overrides[k] ?? v;
    } else {
      out[k] = v;
    }
  }
  File('lib/l10n/app_ko.arb').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(out)}\n',
  );
  stdout.writeln(
    'Wrote lib/l10n/app_ko.arb (${overrides.length} Korean strings, '
    '${en.length - overrides.length} fallback EN)',
  );
}
