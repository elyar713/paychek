import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Séparateur logique entre tags (stockage / export texte).
const strategieSetupTagDisplaySeparator = ' • ';

const _legacySeparators = <String>[
  strategieSetupTagDisplaySeparator,
  ' · ',
  ', ',
];

String strategieSetupJoinTags(List<String> tags) {
  if (tags.isEmpty) return '—';
  return tags.join(strategieSetupTagDisplaySeparator);
}

List<String> strategieSetupSplitCsv(String s) {
  if (s.isEmpty || s == '—') return [];
  for (final sep in _legacySeparators) {
    if (s.contains(sep)) {
      return s
          .split(sep)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }
  return s
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

List<String> strategieSetupBodyToTags(String body) {
  if (body.isEmpty || body == '—') return [];
  for (final sep in _legacySeparators) {
    if (body.contains(sep)) {
      return body
          .split(sep)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }
  return [body];
}

/// Décode une valeur affichée sur la carte (tags multiples ou texte seul).
List<String> strategieSetupDisplayToTags(String display) {
  if (display.isEmpty || display == '—') return [];
  final tags = strategieSetupBodyToTags(display);
  if (tags.length > 1) return tags;
  final csv = strategieSetupSplitCsv(display);
  if (csv.length > 1) return csv;
  return tags;
}

/// Texte carte : un élément (tag) par ligne.
class StrategieSetupTaggedBodyText extends StatelessWidget {
  const StrategieSetupTaggedBodyText({
    super.key,
    required this.text,
    this.style,
    this.lineSpacing = 6,
  });

  final String text;
  final TextStyle? style;
  final double lineSpacing;

  static final TextStyle _defaultStyle = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.35,
  );

  @override
  Widget build(BuildContext context) {
    final valueStyle = style ?? _defaultStyle;
    if (text.isEmpty || text == '—') {
      return Text(text, style: valueStyle);
    }

    final tags = strategieSetupDisplayToTags(text);
    if (tags.length <= 1) {
      return Text(tags.isEmpty ? text : tags.first, style: valueStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tags.length; i++) ...[
          if (i > 0) SizedBox(height: lineSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('- ', style: valueStyle),
              Expanded(child: Text(tags[i], style: valueStyle)),
            ],
          ),
        ],
      ],
    );
  }
}
