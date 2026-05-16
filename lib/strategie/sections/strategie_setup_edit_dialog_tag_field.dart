import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../strategie_tokens.dart';

/// Zone tags + champ + bouton **+** (dialogue Modifier setup).
class StrategieSetupTagField extends StatefulWidget {
  const StrategieSetupTagField({
    super.key,
    required this.tags,
    required this.hintText,
    required this.onChanged,
  });

  final List<String> tags;
  final String hintText;
  final ValueChanged<List<String>> onChanged;

  @override
  State<StrategieSetupTagField> createState() => _StrategieSetupTagFieldState();
}

class _StrategieSetupTagFieldState extends State<StrategieSetupTagField> {
  late final TextEditingController _c;

  static const _chipBg = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    _c = TextEditingController();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _add() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    widget.onChanged([...widget.tags, t]);
    _c.clear();
    setState(() {});
  }

  void _removeAt(int i) {
    final next = List<String>.from(widget.tags)..removeAt(i);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 38),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < widget.tags.length; i++)
                    Material(
                      color: _chipBg,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                widget.tags[i],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _removeAt(i),
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: StrategieTokens.labelMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              TextField(
                controller: _c,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF666666),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(top: 10),
                ),
                onSubmitted: (_) => _add(),
              ),
            ],
          ),
        ),
        Positioned(
          right: 6,
          bottom: 6,
          child: Material(
            color: const Color(0xFF333333),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _add,
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(Icons.add, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
