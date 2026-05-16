import 'package:flutter/material.dart';

/// Corps d’une section sous [AnalyseSectionTitleRow] : animation de hauteur
/// (effet rideau) quand [expanded] passe à false.
class AnalyseCollapsibleSectionBody extends StatelessWidget {
  const AnalyseCollapsibleSectionBody({
    super.key,
    required this.expanded,
    required this.child,
  });

  final bool expanded;
  final Widget child;

  static const Duration _duration = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: _duration,
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: expanded ? child : const SizedBox.shrink(),
    );
  }
}
