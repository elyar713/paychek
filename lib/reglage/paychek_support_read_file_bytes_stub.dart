import 'dart:typed_data';

/// Web / plateforme sans `dart:io` : pas de lecture par chemin local.
Future<Uint8List?> paychekSupportReadLocalPathAsBytes(String? filePath) async =>
    null;
