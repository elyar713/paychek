import 'package:flutter/material.dart';

import '../analyse_tokens.dart';

class AnalyseSectionTitleRow extends StatelessWidget {
  const AnalyseSectionTitleRow({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.enabled = true,
    required this.onEnabledChanged,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  /// Si null, [AnalyseTokens.muted2].
  final Color? iconColor;
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              icon,
              size: 14,
              color: iconColor ?? AnalyseTokens.muted2,
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Switch compact (un peu plus petit que le "100%" État mental).
              const switchSlot = 30.0;
              final textMax = (constraints.maxWidth - switchSlot).clamp(0.0, double.infinity);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: textMax),
                    child: Text(
                      title,
                      style: AnalyseTokens.sectionTitleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 30,
                    height: 18,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      child: Switch(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        value: enabled,
                        onChanged: onEnabledChanged,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (trailing != null) const SizedBox(width: 8),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

