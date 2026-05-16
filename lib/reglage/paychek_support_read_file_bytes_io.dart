import 'dart:io';
import 'dart:typed_data';

/// Mobile / desktop : lecture des octets depuis le chemin renvoyé par FilePicker.
Future<Uint8List?> paychekSupportReadLocalPathAsBytes(String? filePath) async {
  if (filePath == null || filePath.isEmpty) return null;
  try {
    final f = File(filePath);
    if (!await f.exists()) return null;
    return await f.readAsBytes();
  } catch (_) {
    return null;
  }
}
