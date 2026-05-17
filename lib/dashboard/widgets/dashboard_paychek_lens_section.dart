import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../checklist/checklist_tokens.dart';
import '../../performance/performance_custom_lens_card.dart';
import '../../performance/performance_locale_copy.dart';
import '../../performance/performance_paychek_lens_section.dart';
import '../../web/paychek_web_tokens.dart';
import '../../web/web_dashboard_config.dart';
import '../dashboard_tokens.dart';

/// Accueil : en-tête + [PaychekLensSection] (même largeur que « Ma stratégie » sur mobile).
class DashboardPaychekLensSection extends StatelessWidget {
  const DashboardPaychekLensSection({
    super.key,
    this.contentPadding,
    this.cardBackgroundColor,
  });

  final EdgeInsetsGeometry? contentPadding;
  final Color? cardBackgroundColor;

  static final TextStyle _titleStyle = ChecklistTokens.sectionTitleOnCardStyle.copyWith(
    fontSize: 10,
    letterSpacing: 0.4,
  );

  Widget _header(BuildContext context, {required bool webDash}) {
    final code = Localizations.localeOf(context).languageCode;
    final title = perf6(
      code,
      'Paychek Lens',
      'Paychek Lens',
      'Paychek Lens',
      'Paychek Lens',
      'Paychek Lens',
      'Paychek Lens',
    );
    final titleColor = webDash
        ? PaychekWebTokens.textGray500
        : ChecklistTokens.sectionTitleOnCardStyle.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          LucideIcons.slidersHorizontal,
          size: 16,
          color: titleColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            webDash ? title.toUpperCase() : title,
            style: webDash
                ? _titleStyle.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: titleColor,
                  )
                : _titleStyle,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final webDash = WebDashboardConfig.useLeftRail;

    final lens = PaychekLensSection(
      showAddButton: false,
      cardChrome: webDash
          ? PerformanceCustomLensCardChrome.bare
          : PerformanceCustomLensCardChrome.dashboardHome,
    );

    if (webDash) {
      return ColoredBox(
        color: cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
        child: Padding(
          padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, webDash: true),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: lens,
              ),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: cardBackgroundColor ?? DashboardTokens.scaffoldMatte,
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context, webDash: false),
            const SizedBox(height: ChecklistTokens.sectionHeaderToItemsGap),
            lens,
          ],
        ),
      ),
    );
  }
}
