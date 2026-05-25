// Run: dart run tool/clear_help_center_bodies.dart
import 'dart:convert';
import 'dart:io';

const _bodyKeys = <String>[
  'helpCenterArticleAddTradeBody',
  'helpCenterArticleEditTradeBody',
  'helpCenterArticleChecklistBody',
  'helpCenterArticleCalendarBody',
  'helpCenterArticleMentalStateBody',
  'helpCenterArticleExportPdfBody',
  'helpCenterArticleResetDataBody',
  'helpCenterArticleMyAnalysisBody',
];

Future<void> main() async {
  final l10nDir = Directory('lib/l10n');
  for (final file in l10nDir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.arb')) continue;
    final raw = await file.readAsString();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    var changed = false;
    for (final key in _bodyKeys) {
      if (map.containsKey(key) && map[key] != '') {
        map[key] = '';
        changed = true;
      }
    }
    if (changed) {
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString('${encoder.convert(map)}\n');
      stdout.writeln('cleared bodies in ${file.path}');
    }
  }
}
