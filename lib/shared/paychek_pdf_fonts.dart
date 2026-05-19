import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'paychek_pdf_text.dart';

/// Polices Unicode embarquées pour les exports PDF (Noto Sans + Noto Sans KR).
///
/// Les fichiers sont dans [assets/fonts/] pour éviter Helvetica (pas d’Unicode)
/// et les téléchargements réseau au moment de l’export.
abstract final class PaychekPdfFonts {
  PaychekPdfFonts._();

  static pw.Font? _regular;
  static pw.Font? _bold;
  static pw.Font? _italic;
  static pw.Font? _krRegular;
  static Future<void>? _loadFuture;

  static const _assetRegular = 'assets/fonts/NotoSans-Regular.ttf';
  static const _assetBold = 'assets/fonts/NotoSans-Bold.ttf';
  static const _assetItalic = 'assets/fonts/NotoSans-Italic.ttf';
  static const _assetKr = 'assets/fonts/NotoSansKR-Variable.ttf';

  static bool get isLoaded =>
      _regular != null &&
      _bold != null &&
      _italic != null &&
      _krRegular != null;

  static Future<void> ensureLoaded() {
    return _loadFuture ??= _loadAll();
  }

  static Future<void> _loadAll() async {
    if (isLoaded) return;
    try {
      final results = await Future.wait([
        rootBundle.load(_assetRegular),
        rootBundle.load(_assetBold),
        rootBundle.load(_assetItalic),
        rootBundle.load(_assetKr),
      ]);
      _regular = pw.Font.ttf(results[0]);
      _bold = pw.Font.ttf(results[1]);
      _italic = pw.Font.ttf(results[2]);
      _krRegular = pw.Font.ttf(results[3]);
    } catch (e, st) {
      debugPrint('[PaychekPdfFonts] load failed: $e\n$st');
      rethrow;
    }
  }

  static pw.ThemeData theme() {
    _assertLoaded();
    return pw.ThemeData.withFont(
      base: _regular!,
      bold: _bold!,
      italic: _italic!,
      boldItalic: _bold!,
    );
  }

  static void _assertLoaded() {
    if (!isLoaded) {
      throw StateError('Call PaychekPdfFonts.ensureLoaded() before building PDF');
    }
  }

  static pw.Font _pickFont({
    required bool bold,
    required bool italic,
    required bool useKrPrimary,
  }) {
    if (useKrPrimary) {
      return _krRegular!;
    }
    if (italic) {
      return bold ? _bold! : _italic!;
    }
    return bold ? _bold! : _regular!;
  }

  /// Style PDF : police explicite, sans [FontWeight.bold] (sinon dart_pdf retombe sur Helvetica-Bold).
  static pw.TextStyle style({
    required String text,
    bool preferHangulPrimary = false,
    double fontSize = 9,
    bool bold = false,
    PdfColor? color,
    double? height,
    double? letterSpacing,
    pw.FontStyle fontStyle = pw.FontStyle.normal,
  }) {
    _assertLoaded();
    final hasHangul = paychekPdfTextHasHangul(text);
    final useKrPrimary =
        preferHangulPrimary || (hasHangul && _isMostlyHangul(text));
    final wantItalic = fontStyle == pw.FontStyle.italic;

    final primary = _pickFont(
      bold: bold,
      italic: wantItalic,
      useKrPrimary: useKrPrimary,
    );

    final List<pw.Font> fallback;
    if (useKrPrimary) {
      fallback = [_pickFont(bold: bold, italic: wantItalic, useKrPrimary: false)];
    } else if (hasHangul) {
      fallback = [_krRegular!];
    } else {
      fallback = const [];
    }

    // Ne jamais passer fontStyle / fontWeight au moteur PDF : sinon repli
    // Helvetica / Helvetica-Bold / Helvetica-Oblique (pas d’Unicode).
    return pw.TextStyle(
      font: primary,
      fontFallback: fallback,
      fontSize: fontSize,
      fontWeight: pw.FontWeight.normal,
      fontStyle: pw.FontStyle.normal,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );  }

  static bool _isMostlyHangul(String text) {
    var hangul = 0;
    var letters = 0;
    for (final r in text.runes) {
      if (r <= 0x20) continue;
      letters++;
      if ((r >= 0xAC00 && r <= 0xD7A3) || (r >= 0x1100 && r <= 0x11FF)) {
        hangul++;
      }
    }
    return letters > 0 && hangul / letters >= 0.35;
  }

  static pw.Widget text(
    String? value, {
    bool preferHangulPrimary = false,
    double fontSize = 9,
    bool bold = false,
    PdfColor? color,
    double? height,
    double? letterSpacing,
    pw.TextAlign? textAlign,
    int? maxLines,
    pw.TextOverflow? overflow,
    pw.FontStyle fontStyle = pw.FontStyle.normal,
  }) {
    final normalized = paychekPdfNormalize(value);
    return pw.Text(
      normalized,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style(
        text: normalized,
        preferHangulPrimary: preferHangulPrimary,
        fontSize: fontSize,
        bold: bold,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      ),
    );
  }
}
