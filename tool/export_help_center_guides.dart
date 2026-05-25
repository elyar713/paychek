// Extrait les corps helpCenter*Body de app_en.arb vers assets/help_center/guides/{slug}/en.txt
// Run: dart run tool/export_help_center_guides.dart
import 'dart:convert';
import 'dart:io';

const _slugByBodyKey = <String, String>{
  'helpCenterArticleAddTradeBody': 'add_trade',
  'helpCenterArticleEditTradeBody': 'trade_page',
  'helpCenterArticleChecklistBody': 'checklist',
  'helpCenterArticleCalendarBody': 'calendar',
  'helpCenterArticleMentalStateBody': 'mental_state',
  'helpCenterArticleMyAnalysisBody': 'my_analysis',
  'helpCenterArticleExportPdfBody': 'export_pdf',
  'helpCenterArticleResetDataBody': 'reset_data',
};

Future<void> main() async {
  final enPath = File('lib/l10n/app_en.arb');
  final en = jsonDecode(await enPath.readAsString()) as Map<String, dynamic>;
  final root = Directory('assets/help_center/guides');

  for (final entry in _slugByBodyKey.entries) {
    final body = en[entry.key];
    if (body is! String || body.trim().isEmpty) {
      stderr.writeln('skip ${entry.key}: missing');
      continue;
    }
    final dir = Directory('${root.path}/${entry.value}');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final out = File('${dir.path}/en.txt');
  final existing = out.existsSync() ? await out.readAsString() : '';
    if (existing.trim().isNotEmpty && existing.trim() != body.trim()) {
      stdout.writeln('keep ${out.path} (already edited, differs from ARB)');
      continue;
    }
    await out.writeAsString(body);
    stdout.writeln('wrote ${out.path} (${body.length} chars)');
  }
}
