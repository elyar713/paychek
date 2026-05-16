import 'dart:io';

import 'package:pdfrx/pdfrx.dart';

/// Extrait le texte d’un PDF (pdfrx + PDFium).
///
/// **Ne pas** utiliser avec `dart run` seul : PDFium n’est pas embarqué dans le VM,
/// vous obtiendrez une erreur FFI. Pour un essai CLI, soit lancer depuis l’app
/// Desktop Windows où `flutter build windows` déploie `pdfium.dll`, soit copier
/// `build/windows/x64/runner/Release/pdfium.dll` à la racine du projet et exécuter
/// depuis un environnement où ce chargement fonctionne.
///
/// Usage prévu : fichier de secours ; préférez ouvrir le PDF depuis l’app si vous
/// intégrez l’import.
Future<void> main(List<String> args) async {
  final path = args.isEmpty
      ? r'c:\Users\elyar\Desktop\performance_journal_2026-05-05.pdf'
      : args.first;
  final doc = await PdfDocument.openFile(path);
  try {
    final b = StringBuffer();
    for (final p in doc.pages) {
      final tx = await p.loadText();
      b.writeln(tx.fullText);
    }
    stdout.write(b.toString());
  } finally {
    await doc.dispose();
  }
}
