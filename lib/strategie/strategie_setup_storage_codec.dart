import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'widgets/strategie_setup_card.dart';

const _jsonV = 1;

int _argb(Color c) {
  final a = (c.a * 255.0).round() & 0xFF;
  final r = (c.r * 255.0).round() & 0xFF;
  final g = (c.g * 255.0).round() & 0xFF;
  final b = (c.b * 255.0).round() & 0xFF;
  return (a << 24) | (r << 16) | (g << 8) | b;
}

Color _color(Object? v) {
  if (v is int) return Color(v);
  if (v is num) return Color(v.toInt());
  return const Color(0xFFFFFFFF);
}

Map<String, dynamic> encodeStrategieSetupCardData(StrategieSetupCardData d) {
  return <String, dynamic>{
    'v': _jsonV,
    'title': d.title,
    'dotColor': _argb(d.dotColor),
    'timeframes': d.timeframes,
    'indicateurs': d.indicateurs,
    'pattern': d.pattern,
    'signalText': d.signalText,
    'signalColor': _argb(d.signalColor),
    'ruleBlocks': [
      for (final b in d.ruleBlocks)
        <String, dynamic>{
          'iconCodePoint': b.icon.codePoint,
          'iconFontFamily': b.icon.fontFamily,
          'iconFontPackage': b.icon.fontPackage,
          'heading': b.heading,
          'headingColor': _argb(b.headingColor),
          'body': b.body,
        },
    ],
  };
}

StrategieSetupCardData decodeStrategieSetupCardData(Map<String, dynamic> m) {
  final blocks = <StrategieSetupRuleBlock>[];
  final raw = m['ruleBlocks'];
  if (raw is List) {
    for (final e in raw) {
      if (e is! Map) continue;
      final em = Map<String, dynamic>.from(e);
      blocks.add(
        StrategieSetupRuleBlock(
          // IMPORTANT:
          // In release mode, Flutter's icon tree-shaking requires IconData to be const.
          // Stored (dynamic) IconData from JSON prevents tree-shaking and breaks release builds.
          // We therefore use a stable Lucide icon here.
          icon: LucideIcons.checkCircle2,
          heading: em['heading'] as String? ?? '',
          headingColor: _color(em['headingColor']),
          body: em['body'] as String? ?? '',
        ),
      );
    }
  }
  return StrategieSetupCardData(
    title: m['title'] as String? ?? '',
    dotColor: _color(m['dotColor']),
    timeframes: m['timeframes'] as String? ?? '—',
    indicateurs: m['indicateurs'] as String? ?? '—',
    pattern: m['pattern'] as String? ?? '—',
    signalText: m['signalText'] as String? ?? '—',
    signalColor: _color(m['signalColor']),
    ruleBlocks: blocks,
  );
}

bool strategieSetupsEqualForStar(
  StrategieSetupCardData a,
  StrategieSetupCardData b,
) {
  return jsonEncode(encodeStrategieSetupCardData(a)) ==
      jsonEncode(encodeStrategieSetupCardData(b));
}
