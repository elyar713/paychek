import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../web/paychek_web_tokens.dart';
import '../../widgets/paychek_minimal_upgrade_button.dart';
import '../dashboard_home_plan_logic.dart';
import 'paychek_plan_minimal_badge.dart';
import 'timeframe_pills.dart';

/// En-tête accueil minimal (**même rendu web et mobile**) : welcome + nom + badge plan | Upgrade compact.
/// [selectedTimeframeIndex] / [onTimeframeChanged] : si l’un est null, les pilules période sont masquées (mobile).
class DashboardHomeHero extends StatelessWidget {
  const DashboardHomeHero({
    super.key,
    required this.subtitle,
    this.welcomeUserName,
    this.accountPlanIsPro,
    this.selectedTimeframeIndex,
    this.onTimeframeChanged,
    this.onUpgradeTap,
  });

  final String subtitle;
  final String? welcomeUserName;
  final bool? accountPlanIsPro;
  final int? selectedTimeframeIndex;
  final ValueChanged<int>? onTimeframeChanged;
  final VoidCallback? onUpgradeTap;

  bool get _showTimeframeStrip =>
      selectedTimeframeIndex != null && onTimeframeChanged != null;

  static final Color _headerBorder = Colors.white.withValues(alpha: 0.06);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final tfLabels = [
      l.dashboardTfDay,
      l.dashboardTfWeek,
      l.dashboardTfMonth,
      l.dashboardTfAll,
    ];

    final displayName = (welcomeUserName?.isNotEmpty ?? false)
        ? welcomeUserName!
        : subtitle;

    final isMobileHome = !_showTimeframeStrip;

    final upgrade = onUpgradeTap != null
        ? PaychekMinimalUpgradeButton(
            label: l.profileUpgradeLabel,
            onTap: onUpgradeTap!,
          )
        : null;

    final planBadge = DashboardHomePlanLogic.shouldShowPlanBadge(accountPlanIsPro)
        ? PaychekPlanMinimalBadge(isPro: accountPlanIsPro!)
        : null;

    final hasHeaderExtras = planBadge != null || upgrade != null;
    final nameFontSize = isMobileHome && hasHeaderExtras ? 16.0 : 20.0;

    final welcomeBlock = _MinimalWelcomeBlock(
      welcomePrefix: l.webHomeWelcomeBack,
      displayName: displayName,
      nameColor: scheme.onSurface,
      nameFontSize: nameFontSize,
      planBadge: planBadge,
    );

    Widget headerBody;
    if (isMobileHome) {
      // iOS / Android : Upgrade sous le nom (aligné à droite), pas sur la même ligne.
      headerBody = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          welcomeBlock,
          if (upgrade != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: upgrade,
            ),
          ],
        ],
      );
    } else {
      headerBody = LayoutBuilder(
        builder: (context, constraints) {
          final stackUpgrade = constraints.maxWidth < 420;
          if (stackUpgrade) {
            return _MinimalWelcomeBlock(
              welcomePrefix: l.webHomeWelcomeBack,
              displayName: displayName,
              nameColor: scheme.onSurface,
              nameFontSize: nameFontSize,
              planBadge: planBadge,
              nameRowTrailing: upgrade,
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: welcomeBlock),
              ?upgrade,
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _headerBorder, width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: headerBody,
              ),
            ),
            if (_showTimeframeStrip) ...[
              const SizedBox(height: 16),
              if (narrow)
                Align(
                  alignment: Alignment.centerLeft,
                  child: _HomeTfStrip(
                    tfLabels: tfLabels,
                    selectedIndex: selectedTimeframeIndex!,
                    onChanged: onTimeframeChanged!,
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    _HomeTfStrip(
                      tfLabels: tfLabels,
                      selectedIndex: selectedTimeframeIndex!,
                      onChanged: onTimeframeChanged!,
                    ),
                  ],
                ),
            ],
          ],
        );
      },
    );
  }
}

class _MinimalWelcomeBlock extends StatelessWidget {
  const _MinimalWelcomeBlock({
    required this.welcomePrefix,
    required this.displayName,
    required this.nameColor,
    required this.nameFontSize,
    this.planBadge,
    this.nameRowTrailing,
  });

  final String welcomePrefix;
  final String displayName;
  final Color nameColor;
  final double nameFontSize;
  final Widget? planBadge;
  /// Web étroit : CTA Upgrade sur la ligne du nom.
  final Widget? nameRowTrailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          welcomePrefix,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
            color: PaychekWebTokens.textZinc500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: nameColor,
                ),
              ),
            ),
            if (planBadge != null) ...[
              const SizedBox(width: 8),
              planBadge!,
            ],
            if (nameRowTrailing != null) ...[
              const Spacer(),
              nameRowTrailing!,
            ],
          ],
        ),
      ],
    );
  }
}

class _HomeTfStrip extends StatelessWidget {
  const _HomeTfStrip({
    required this.tfLabels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> tfLabels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PaychekWebTokens.pillTrackBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PaychekWebTokens.borderGray800),
      ),
      child: TimeframePills(
        labels: tfLabels,
        selectedIndex: selectedIndex,
        onChanged: onChanged,
        width: 236,
        trackColor: Colors.transparent,
        selectedBackgroundColor: PaychekWebTokens.accentEmerald,
        selectedForegroundColor: Colors.black87,
        unselectedLabelColor: PaychekWebTokens.textGray500,
      ),
    );
  }
}
