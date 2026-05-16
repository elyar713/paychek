import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

/// Web : téléchargement du fichier via blob (sans plugin natif).
Future<bool> trySaveReportPdfOnPlatform(List<int> bytes, String filename) async {
  final u8 = Uint8List.fromList(bytes);
  final blob = Blob([u8.toJS].toJS);
  final url = URL.createObjectURL(blob);
  final anchor = HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';
  document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
  return true;
}
