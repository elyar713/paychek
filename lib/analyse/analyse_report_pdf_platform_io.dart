import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../shared/ios_share_origin.dart';

/// Bureau : dialogue « Enregistrer sous ».
/// Android / iOS : PDF temporaire + feuille de partage ([Share]) — sans plugin `printing`.
Future<bool> trySaveReportPdfOnPlatform(
  List<int> bytes,
  String filename, {
  BuildContext? shareContext,
}) async {
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
    if (bytes.isEmpty) return false;
    final safeName =
        filename.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_');
    final origin = resolveSharePositionOrigin(context: shareContext);
    final data = Uint8List.fromList(bytes);

    // iOS (simulateur inclus) : bytes en mémoire — évite « error fetching item for URL file://… ».
    if (t == TargetPlatform.iOS) {
      await Share.shareXFiles(
        <XFile>[
          XFile.fromData(
            data,
            mimeType: 'application/pdf',
            name: safeName,
          ),
        ],
        subject: safeName,
        sharePositionOrigin: origin,
      );
      return true;
    }

    final dir = await getTemporaryDirectory();
    final outPath = p.join(dir.path, safeName);
    final file = File(outPath);
    await file.writeAsBytes(data, flush: true);
    if (!file.existsSync()) return false;
    await Share.shareXFiles(
      <XFile>[
        XFile(
          file.path,
          mimeType: 'application/pdf',
          name: safeName,
        ),
      ],
      subject: safeName,
      sharePositionOrigin: origin,
    );
    return true;
  }

  return false;
}
