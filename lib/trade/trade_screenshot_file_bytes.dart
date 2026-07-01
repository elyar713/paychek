import 'dart:io';
import 'dart:typed_data';

Future<Uint8List?> readTradeScreenshotFileBytes(String path) async {
  try {
    final f = File(path);
    if (await f.exists()) return await f.readAsBytes();
  } catch (_) {}
  return null;
}
