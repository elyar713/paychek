import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../checklist_tokens.dart';

/// Poignées réorganisation — Lucide (fiable sur web release ; Material tree-shake peut les omettre).
class ChecklistReorderToggleIcon extends StatelessWidget {
  const ChecklistReorderToggleIcon({
    super.key,
    required this.active,
    this.size = 22,
  });

  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      LucideIcons.arrowUpDown,
      size: size,
      color: active
          ? const Color(0xFF1EB48A)
          : ChecklistTokens.sectionMenuIconColor,
    );
  }
}

class ChecklistReorderDragHandle extends StatelessWidget {
  const ChecklistReorderDragHandle({
    super.key,
    this.size = 20,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      LucideIcons.gripVertical,
      size: size,
      color: ChecklistTokens.sectionMenuIconColor,
    );
  }
}
