// Run: dart run tool/embed_help_center_images.dart
import 'dart:convert';
import 'dart:io';

const _images = <String>[
  'assets/help_center/dashboard_capital_balance.gif',
  'assets/help_center/dashboard_capital_evolution.gif',
  'assets/help_center/dashboard_personal_analysis.gif',
  'assets/help_center/dashboard_checklist.gif',
  'assets/help_center/dashboard_mental_state.gif',
  'assets/help_center/dashboard_strategy.gif',
  'assets/help_center/dashboard_calendar.png',
  'assets/help_center/dashboard_custom_performance.gif',
  'assets/help_center/add_trade.gif',
  'assets/help_center/add_trade_custom_actif.gif',
  'assets/help_center/add_trade_screenshot_csv_note.gif',
];

Future<void> main() async {
  final buffer = StringBuffer('''
import 'dart:convert';
import 'dart:typed_data';

/// Images help center embarquées (fiables en web dev sans rebuild assets).
/// Généré par [tool/embed_help_center_images.dart].
const Map<String, String> kHelpCenterEmbeddedImagesBase64 =
    <String, String>{
''');

  for (final assetPath in _images) {
    final file = File(assetPath);
    if (!file.existsSync()) {
      stderr.writeln('missing $assetPath');
      exitCode = 1;
      continue;
    }
    final b64 = base64Encode(await file.readAsBytes());
    buffer.writeln("  '$assetPath':");
    buffer.writeln("      '$b64',");
    stdout.writeln('embedded ${file.lengthSync()} bytes -> $assetPath');
  }

  buffer.writeln('''};

Uint8List? helpCenterEmbeddedImageBytes(String assetPath) {
  final encoded = kHelpCenterEmbeddedImagesBase64[assetPath];
  if (encoded == null || encoded.isEmpty) return null;
  return base64Decode(encoded);
}
''');

  const outPath = 'lib/help_center/help_center_embedded_images.dart';
  await File(outPath).writeAsString(buffer.toString());
  stdout.writeln('wrote $outPath');
}
