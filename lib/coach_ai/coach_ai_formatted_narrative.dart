import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'coach_ai_response_format.dart';

/// Texte coach enrichi : titres gras, catégories colorées, chiffres mis en avant.
class CoachAiFormattedNarrative extends StatelessWidget {
  const CoachAiFormattedNarrative({super.key, required this.text});

  final String text;

  static const _bodySize = 13.5;
  static const _headSize = 14.0;
  static const _emphasisSize = 13.5;
  static const _captionSize = 12.0;
  static const _badgeSize = 13.0;
  static const _badgeBox = 26.0;

  static final _numberedSplit = RegExp(r'(?:\n|^)(?=\d+\.\s)');

  static List<String> _splitBlocks(String raw) {
    var t = raw.replaceAll('\r\n', '\n').trim();
    t = t.replaceAll(RegExp(r'(?<!\n)\s+(?=\d+\.\s)'), '\n');
    return t.split(_numberedSplit).where((s) => s.trim().isNotEmpty).toList();
  }

  static TextStyle _base({
    double size = _bodySize,
    Color color = const Color(0xFFD1D5DB),
    FontWeight weight = FontWeight.w500,
    double height = 1.5,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  static Color _categoryColor(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('risque') || c.contains('risk')) return const Color(0xFFF87171);
    if (c.contains('horaire') || c.contains('timing') || c.contains('heure')) {
      return const Color(0xFF60A5FA);
    }
    if (c.contains('entrée') || c.contains('entree') || c.contains('entry')) {
      return const Color(0xFFF59E0B);
    }
    if (c.contains('pattern') || c.contains('setup') || c.contains('stratégie') || c.contains('strategie')) {
      return const Color(0xFFA78BFA);
    }
    if (c.contains('mental') || c.contains('psycho') || c.contains('émotion') || c.contains('emotion')) {
      return const Color(0xFFC084FC);
    }
    if (c.contains('checklist')) return const Color(0xFFFBBF24);
    if (c.contains('analyse') || c.contains('analysis')) return const Color(0xFF38BDF8);
    return const Color(0xFF9CA3AF);
  }

  static List<TextSpan> _inlineSpans(String input) {
    final spans = <TextSpan>[];
    final re = RegExp(
      r'(\d+\.\s*%?)|' // 100% or 27
      r'(-\d+(?:[.,]\d+)?)|' // -500
      r'(\(\s*[^)]{2,48}\s*\))|' // (Gestion du risque)
      r'("[^"]+")|' // "3 Maximum"
      r"(Règle de [^:]+:|Règle [^:]+:|Checklist|Analyse|Stratégie|État mental|Entraînement PAYCHEK|FOMO|TILT)",
    );
    var i = 0;
    for (final m in re.allMatches(input)) {
      if (m.start > i) {
        spans.add(TextSpan(text: input.substring(i, m.start), style: _base()));
      }
      final chunk = m.group(0) ?? '';
      if (chunk.startsWith('(') && chunk.endsWith(')')) {
        final inner = chunk.substring(1, chunk.length - 1).trim();
        spans.add(
          TextSpan(
            text: '($inner)',
            style: _base(
              size: _captionSize,
              color: _categoryColor(inner),
              weight: FontWeight.w800,
            ),
          ),
        );
      } else if (chunk.startsWith('"')) {
        spans.add(
          TextSpan(
            text: chunk,
            style: _base(size: _emphasisSize, color: Colors.white, weight: FontWeight.w800),
          ),
        );
      } else if (chunk.startsWith('-')) {
        spans.add(
          TextSpan(
            text: chunk,
            style: _base(size: _headSize, color: const Color(0xFFF87171), weight: FontWeight.w800),
          ),
        );
      } else if (chunk.contains('%')) {
        final isBad = chunk.startsWith('100') || int.tryParse(chunk.replaceAll('%', '')) == 0;
        spans.add(
          TextSpan(
            text: chunk,
            style: _base(
              size: _emphasisSize,
              color: isBad ? const Color(0xFFF87171) : const Color(0xFF34D399),
              weight: FontWeight.w800,
            ),
          ),
        );
      } else if (RegExp(r'^\d').hasMatch(chunk)) {
        spans.add(
          TextSpan(
            text: chunk,
            style: _base(size: _emphasisSize, color: const Color(0xFF34D399), weight: FontWeight.w800),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: chunk,
            style: _base(size: _emphasisSize, color: const Color(0xFF6EE7B7), weight: FontWeight.w800),
          ),
        );
      }
      i = m.end;
    }
    if (i < input.length) {
      spans.add(TextSpan(text: input.substring(i), style: _base()));
    }
    return spans;
  }

  static ({String head, String body}) _splitItemContent(String raw) {
    var t = raw.trim();
    final cat = RegExp(r'\([^)]+\)').firstMatch(t);
    if (cat != null && cat.end < t.length) {
      final after = t.substring(cat.end).trimLeft();
      if (after.startsWith('.') || after.startsWith(':')) {
        return (head: t.substring(0, cat.end).trim(), body: after.replaceFirst(RegExp(r'^[.:]\s*'), ''));
      }
      if (after.isNotEmpty) {
        return (head: t.substring(0, cat.end).trim(), body: after);
      }
    }
    final dot = t.indexOf('. ');
    if (dot > 20 && dot < 140) {
      return (head: t.substring(0, dot + 1).trim(), body: t.substring(dot + 2).trim());
    }
    return (head: t, body: '');
  }

  Widget _introBlock(String intro) {
    if (intro.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Synthèse  ',
              style: _base(size: _captionSize, color: const Color(0xFF6EE7B7), weight: FontWeight.w800, letterSpacing: 0.4),
            ),
            ..._inlineSpans(intro.trim()),
          ],
        ),
      ),
    );
  }

  Widget _numberedItem(String block) {
    final m = RegExp(r'^(\d+)\.\s*(.*)$', dotAll: true).firstMatch(block.trim());
    if (m == null) {
      return RichText(text: TextSpan(children: _inlineSpans(block)));
    }
    final index = m.group(1)!;
    final content = m.group(2)!.trim();
    if (content.isEmpty) return const SizedBox.shrink();
    final parts = _splitItemContent(content);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _badgeBox,
            height: _badgeBox,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: Text(
              index,
              style: _base(size: _badgeSize, color: const Color(0xFF6EE7B7), weight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: _inlineSpans(parts.head),
                    style: _base(size: _headSize, color: Colors.white, weight: FontWeight.w700),
                  ),
                ),
                if (parts.body.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(children: _inlineSpans(parts.body)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final raw = CoachAiResponseFormat.normalizeNarrative(text.trim());
    if (raw.isEmpty) return const SizedBox.shrink();

    final chunks = _splitBlocks(raw);
    final intro = chunks.first.trim();
    var items = chunks.length > 1 ? chunks.sublist(1) : <String>[];
    items = items.where((block) {
      final t = block.trim();
      if (t.isEmpty) return false;
      if (RegExp(r'^\d+\.?$').hasMatch(t)) return false;
      return true;
    }).toList();

    if (items.isEmpty) {
      return RichText(text: TextSpan(children: _inlineSpans(raw)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _introBlock(intro),
        ...items.map(_numberedItem),
      ],
    );
  }
}
