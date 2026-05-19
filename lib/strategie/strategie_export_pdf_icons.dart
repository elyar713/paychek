import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdf/pdf.dart';

import '../shared/paychek_pdf_icon_raster.dart';
import 'widgets/strategie_setup_rule_styles.dart';

/// Cache PNG des 4 icônes de règles setup pour l’export PDF Ma stratégie.
class StrategieExportPdfIcons {
  StrategieExportPdfIcons._({
    required this.entry,
    required this.invalidation,
    required this.target,
    required this.management,
  });

  final Uint8List? entry;
  final Uint8List? invalidation;
  final Uint8List? target;
  final Uint8List? management;

  static Future<StrategieExportPdfIcons> load() async {
    Future<Uint8List?> one(IconData icon, Color color) =>
        rasterizeIconForPdf(icon: icon, color: color, logicalSize: 16);

    final results = await Future.wait([
      one(LucideIcons.crosshair, const Color(0xFF0F172A)),
      one(LucideIcons.shield, const Color(0xFFDC2626)),
      one(LucideIcons.circleDot, const Color(0xFF15803D)),
      one(LucideIcons.lock, const Color(0xFF64748B)),
    ]);

    return StrategieExportPdfIcons._(
      entry: results[0],
      invalidation: results[1],
      target: results[2],
      management: results[3],
    );
  }

  Uint8List? bytesForKey(String key) => switch (key) {
        'invalidation' => invalidation,
        'target' => target,
        'management' => management,
        _ => entry,
      };

  Uint8List? bytesForIcon(IconData icon) =>
      bytesForKey(StrategieSetupRuleStyles.iconKeyForIcon(icon));
}

PdfColor strategiePdfHeadingColor(IconData icon) {
  if (icon == LucideIcons.crosshair) {
    return PdfColor.fromHex('0F172A');
  }
  if (icon == LucideIcons.shield) {
    return PdfColor.fromHex('DC2626');
  }
  if (icon == LucideIcons.circleDot) {
    return PdfColor.fromHex('15803D');
  }
  return PdfColor.fromHex('64748B');
}
