import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../questionnaire_tokens.dart';
import 'questionnaire_half_sun_icon.dart';

class QuestionnaireOptionData {
  const QuestionnaireOptionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitle2,
    this.halfSunIcon = false,
    this.mPlus2Slogan1 = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  /// Deuxième ligne (slogan complémentaire), optionnelle.
  final String? subtitle2;
  /// Si vrai, affiche un soleil moitié blanc / moitié noir (Intraday).
  final bool halfSunIcon;
  /// Questionnaire 1 : slogan 1 en M PLUS 2 (sinon Noto Kufi Arabic).
  final bool mPlus2Slogan1;
}

/// Carte sans bordure : fond gris → fond doré lors du choix.
class QuestionnaireOptionCard extends StatefulWidget {
  const QuestionnaireOptionCard({
    super.key,
    required this.data,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final QuestionnaireOptionData data;
  final bool selected;
  final VoidCallback onTap;
  /// Variante plus compacte (utile sur web / desktop).
  final bool compact;

  @override
  State<QuestionnaireOptionCard> createState() => _QuestionnaireOptionCardState();
}

class _QuestionnaireOptionCardState extends State<QuestionnaireOptionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final baseBg = widget.selected ? QuestionnaireTokens.cardSelectedBg : QuestionnaireTokens.cardBg;
    final bg = (!widget.selected && _hovered) ? QuestionnaireTokens.cardHoverBg : baseBg;

    final titleColor = widget.selected ? QuestionnaireTokens.goldLight : Colors.white;
    final subtitleColor = widget.selected ? const Color(0xFFD4C9A8) : QuestionnaireTokens.subtitle;
    final iconColor = widget.selected ? QuestionnaireTokens.gold : Colors.white;

    final borderColor = widget.selected
        ? QuestionnaireTokens.cardBorderSelected
        : (_hovered ? QuestionnaireTokens.cardBorderHover : QuestionnaireTokens.cardBorder);

    final leading = widget.data.halfSunIcon
        ? QuestionnaireHalfSunIcon(size: compact ? 20 : 22)
        : Icon(widget.data.icon, color: iconColor, size: compact ? 20 : 22);

    final slogan1Color = widget.data.subtitle2 != null
        ? Color.lerp(subtitleColor, Colors.black, 0.18)!
        : subtitleColor;
    final slogan2Color = widget.data.subtitle2 != null
        ? Color.lerp(subtitleColor, Colors.white, 0.16)!
        : subtitleColor;

    final iconBg = widget.selected
        ? QuestionnaireTokens.goldIconBg
        : (_hovered ? const Color(0x0FFFFFFF) : const Color(0x0AFFFFFF));

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 12 : 14),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHover: (v) => setState(() => _hovered = v),
            borderRadius: BorderRadius.circular(QuestionnaireTokens.radius + 6),
            splashColor: Colors.white12,
            highlightColor: Colors.white10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 16 : 18,
                vertical: compact ? 14 : 16,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(QuestionnaireTokens.radius + 6),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: QuestionnaireTokens.shadow.withValues(alpha: widget.selected ? 0.38 : 0.22),
                    blurRadius: widget.selected ? 22 : 16,
                    offset: const Offset(0, 10),
                  ),
                  if (widget.selected)
                    BoxShadow(
                      color: QuestionnaireTokens.gold.withValues(alpha: 0.10),
                      blurRadius: 26,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 170),
                    curve: Curves.easeOutCubic,
                    width: compact ? 40 : 44,
                    height: compact ? 40 : 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(compact ? 12 : 14),
                      border: Border.all(
                        color: widget.selected ? QuestionnaireTokens.cardBorderSelected : QuestionnaireTokens.cardBorder,
                      ),
                    ),
                    child: Center(child: leading),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.data.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      fontSize: compact ? 15 : null,
                                      color: titleColor,
                                    ),
                              ),
                            ),
                            AnimatedScale(
                              duration: const Duration(milliseconds: 160),
                              scale: widget.selected ? 1 : 0.96,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 160),
                                opacity: widget.selected ? 1 : 0,
                                child: Container(
                                  width: compact ? 22 : 24,
                                  height: compact ? 22 : 24,
                                  decoration: BoxDecoration(
                                    color: QuestionnaireTokens.gold.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: QuestionnaireTokens.cardBorderSelected),
                                  ),
                                  child: const Icon(Icons.check, size: 16, color: QuestionnaireTokens.goldLight),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 5 : 6),
                        Text(
                          widget.data.subtitle,
                          style: widget.data.mPlus2Slogan1
                              ? GoogleFonts.mPlus2(
                                  color: slogan1Color,
                                  height: 1.25,
                                  fontSize: compact ? 12.5 : 13.5,
                                  fontWeight: FontWeight.w400,
                                )
                              : GoogleFonts.notoKufiArabic(
                                  color: slogan1Color,
                                  height: 1.25,
                                  fontSize: compact ? 12.5 : 13.5,
                                  fontWeight: FontWeight.w400,
                                ),
                        ),
                        if (widget.data.subtitle2 != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.data.subtitle2!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: slogan2Color,
                                  height: 1.3,
                                  fontWeight: FontWeight.w400,
                                  fontSize: compact ? 11 : 12,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
