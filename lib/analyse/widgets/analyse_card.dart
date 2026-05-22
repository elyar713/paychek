import 'package:flutter/material.dart';

import '../analyse_tokens.dart';

class AnalyseCard extends StatelessWidget {
  const AnalyseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.editorSection,
  });

  final Widget child;
  final EdgeInsets padding;
  final AnalyseEditorSection? editorSection;

  @override
  Widget build(BuildContext context) {
    final bg = editorSection?.sectionCardBg ?? AnalyseTokens.cardBg;
    final glow = editorSection?.sectionAccent.withValues(alpha: 0.06);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AnalyseTokens.radiusCard),
        border: Border.all(color: AnalyseTokens.cardBorder),
        boxShadow: [
          ...AnalyseTokens.nightCardShadow,
          if (glow != null)
            BoxShadow(
              color: glow,
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: child,
    );
  }
}

