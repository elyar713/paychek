import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Bureau : dialogue « Enregistrer sous ».
/// Android / iOS : PDF temporaire + feuille de partage ([Share]) — sans plugin `printing`.
Future<bool> trySaveReportPdfOnPlatform(List<int> bytes, String filename) async {
  final t = defaultTargetPlatform;

  if (t == TargetPlatform.windows ||
      t == TargetPlatform.linux ||
      t == TargetPlatform.macOS) {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Enregistrer le rapport PDF',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (path == null) return false;
    var out = path;
    if (!out.toLowerCase().endsWith('.pdf')) {
      out = '$out.pdf';
    }
    await File(out).writeAsBytes(bytes);
    return true;
  }

  if (t == TargetPlatform.android || t == TargetPlatform.iOS) {
    final safeName =
        filename.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_');
    final dir = await getTemporaryDirectory();
    final outPath = p.join(dir.path, safeName);
    final file = File(outPath);
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      <XFile>[
        XFile(
          file.path,
          mimeType: 'application/pdf',
          name: safeName,
        ),
      ],
      subject: safeName,
    );
    return true;
  }

  return false;
}
