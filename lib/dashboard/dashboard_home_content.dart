import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../analyse/analyse_report_snapshot.dart';
import '../strategie/widgets/strategie_setup_card.dart';
import '../checklist/checklist_page_controller.dart';
import 'dashboard_analyse_shortcut.dart';
import 'dashboard_checklist_preview.dart';
import 'dashboard_etat_moment_section.dart';
import 'dashboard_home_plan_logic.dart';
import 'dashboard_home_layout_keys.dart';
import 'dashboard_home_layout_scope.dart';
import 'dashboard_home_strategie_teaser.dart';
import '../reglage/user_profile_scope.dart';
import '../web/paychek_web_tokens.dart';
import '../web/web_dashboard_checklist_analyse_pair.dart';
import '../web/web_dashboard_config.dart';
import 'pages/capital/widgets/capital_balance_card.dart';
import 'widgets/capital_evolution_card.dart';
import 'widgets/dashboard_calendrier_card.dart';
import 'widgets/dashboard_home_hero.dart';
import 'widgets/dashboard_paychek_lens_section.dart';
import 'widgets/web_this_week_calendar_pair.dart';

/// Contenu scrollable de l’onglet Accueil (sans Scaffold).
class DashboardHomeContent extends StatefulWidget {
  const DashboardHomeContent({
    super.key,
    required this.checklistController,
    required this.analysePreviewSnapshot,
    required this.strategiePreviewSetup,
    required this.onOpenChecklist,
    required this.onOpenAnalyse,
    required this.onOpenEtatMental,
    required this.onOpenStrategie,
    required this.onOpenTrade,
    required this.onOpenTradeById,
    this.accountPlanIsPro,
    this.liteFreemiumRestricted = false,
    this.onLiteFreemiumRestrictedTap,
    this.onHomeUpgradeTap,
  });

  final ChecklistPageController checklistController;
  final AnalyseReportSnapshot? analysePreviewSnapshot;
  final StrategieSetupCardData? strategiePreviewSetup;
  final VoidCallback onOpenChecklist;
  final VoidCallback onOpenAnalyse;
  final VoidCallback onOpenEtatMental;
  final VoidCallback onOpenStrategie;
  final VoidCallback onOpenTrade;
  final ValueChanged<String> onOpenTradeById;

  /// `null` : entitlement pas encore chargé ; `true`/`false` : Pro / Lite ([DashboardHomePlanLogic]).
  final bool? accountPlanIsPro;

  /// Après essai : interactions accueil → paywall Pro (navigation dashboard autorisée).
  final bool liteFreemiumRestricted;

  final VoidCallback? onLiteFreemiumRestrictedTap;

  /// Compte connecté non Pro : ouvre le paywall Pro (feuille existante).
  final VoidCallback? onHomeUpgradeTap;

  @override
  State<DashboardHomeContent> createState() => _DashboardHomeContentState();
}

class _DashboardHomeContentState extends State<DashboardHomeContent> {
  void _onLiteTap() => widget.onLiteFreemiumRestrictedTap?.call();

  /// Carte Capital : web rail → « Tous » ; web étroit → jour ; mobile → « Tous » (courbe fusionnée).
  int _capitalTimeframe = WebDashboardConfig.useLeftRail
      ? 3
      : (kIsWeb ? 0 : 3);

  /// Évolution du capital (web) : « Tous » par défaut.
  int _evolutionTimeframe = 3;

  Widget _sectionForId(String id, {bool webPairStretch = false}) {
    switch (id) {
      case DashboardHomeLayoutKeys.capitalBalance:
        return CapitalBalanceCard(
          timeframeIndex: _capitalTimeframe,
          onTimeframeChanged: widget.liteFreemiumRestricted
              ? (_) => _onLiteTap()
              : (i) => setState(() {
                  _capitalTimeframe = i;
                  _evolutionTimeframe = i;
                }),
          checklistController: widget.checklistController,
          onOpenChecklist: widget.onOpenChecklist,
          onOpenEtatMental: widget.onOpenEtatMental,
          onOpenTrade: widget.onOpenTrade,
          onOpenTradeById: kIsWeb ? null : widget.onOpenTradeById,
          hideTimeframePills: WebDashboardConfig.useLeftRail,
          cardDecoration: WebDashboardConfig.useLeftRail
              ? PaychekWebTokens.shellCardDecoration()
              : null,
          webPairStretch: webPairStretch,
        );
      case DashboardHomeLayoutKeys.checklist:
        return DashboardChecklistPreview(
          controller: widget.checklistController,
          onOpenChecklist: widget.onOpenChecklist,
          liteInteractionLocked: widget.liteFreemiumRestricted,
          onLiteInteractionLockedTap: widget.onLiteFreemiumRestrictedTap,
          includeRiskSectionPreview: WebDashboardConfig.useLeftRail,
          cardBackgroundColor: WebDashboardConfig.useLeftRail
              ? Colors.transparent
              : null,
        );
      case DashboardHomeLayoutKeys.analyse:
        return DashboardAnalyseShortcut(
          snapshot: widget.analysePreviewSnapshot,
          onOpenAnalyse: widget.onOpenAnalyse,
          cardBackgroundColor: WebDashboardConfig.useLeftRail
              ? Colors.transparent
              : null,
        );
      case DashboardHomeLayoutKeys.etatMental:
        return DashboardEtatMomentSection(
          onOpenEtatMental: widget.onOpenEtatMental,
          liteInteractionLocked: widget.liteFreemiumRestricted,
          onLiteInteractionLockedTap: widget.onLiteFreemiumRestrictedTap,
          contentPadding: WebDashboardConfig.useLeftRail
              ? const EdgeInsets.symmetric(horizontal: 28, vertical: 24)
              : null,
          cardBackgroundColor: WebDashboardConfig.useLeftRail
              ? Colors.transparent
              : null,
        );
      case DashboardHomeLayoutKeys.strategie:
        return DashboardHomeStrategieTeaser(
          previewSetup: widget.strategiePreviewSetup,
          onOpenStrategie: widget.onOpenStrategie,
          contentPadding: WebDashboardConfig.useLeftRail
              ? const EdgeInsets.symmetric(horizontal: 28, vertical: 24)
              : null,
          cardBackgroundColor: WebDashboardConfig.useLeftRail
              ? Colors.transparent
              : null,
        );
      case DashboardHomeLayoutKeys.paychekLens:
        return DashboardPaychekLensSection(
          contentPadding: WebDashboardConfig.useLeftRail
              ? const EdgeInsets.symmetric(horizontal: 28, vertical: 24)
              : null,
          cardBackgroundColor: WebDashboardConfig.useLeftRail
              ? Colors.transparent
              : null,
        );
      case DashboardHomeLayoutKeys.capitalEvolution:
        return CapitalEvolutionCard(
          timeframeIndex: _evolutionTimeframe,
          onTimeframeChanged: widget.liteFreemiumRestricted
              ? (_) => _onLiteTap()
              : (i) => setState(() {
                  _evolutionTimeframe = i;
                  if (WebDashboardConfig.useLeftRail) {
                    _capitalTimeframe = i;
                  }
                }),
          onOpenTradeById: widget.onOpenTradeById,
          hideTimeframePills: WebDashboardConfig.useLeftRail || !kIsWeb,
          cardDecoration: WebDashboardConfig.useLeftRail
              ? PaychekWebTokens.shellCardDecoration()
              : null,
          webPairStretch: webPairStretch,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Mobile : évolution fusionnée dans [CapitalBalanceCard] — pas de carte séparée.
  List<String> _mobileHomeSectionOrder(List<String> ids) {
    return ids
        .where((id) => id != DashboardHomeLayoutKeys.capitalEvolution)
        .toList();
  }

  /// Web : capital + évolution ; checklist + analyse ; état + stratégie + this week + calendrier ; puis le reste.
  Widget _buildWebHomeSections(List<String> orderedVisibleIds) {
    const capId = DashboardHomeLayoutKeys.capitalBalance;
    const evoId = DashboardHomeLayoutKeys.capitalEvolution;
    const checkId = DashboardHomeLayoutKeys.checklist;
    const analyseId = DashboardHomeLayoutKeys.analyse;
    const etatId = DashboardHomeLayoutKeys.etatMental;
    const stratId = DashboardHomeLayoutKeys.strategie;
    const paychekLensId = DashboardHomeLayoutKeys.paychekLens;

    final hasCap = orderedVisibleIds.contains(capId);
    final hasEvo = orderedVisibleIds.contains(evoId);
    final hasCheck = orderedVisibleIds.contains(checkId);
    final hasAnalyse = orderedVisibleIds.contains(analyseId);
    final hasEtat = orderedVisibleIds.contains(etatId);
    final hasStrat = orderedVisibleIds.contains(stratId);
    final hasPaychekLens = orderedVisibleIds.contains(paychekLensId);

    final rest = orderedVisibleIds
        .where(
          (id) =>
              id != capId &&
              id != evoId &&
              id != checkId &&
              id != analyseId &&
              id != etatId &&
              id != stratId &&
              id != paychekLensId,
        )
        .toList();

    final showCapitalRow = hasCap || hasEvo;
    final showCheckAnalyseRow = hasCheck || hasAnalyse;
    final showEtatStratRow = hasEtat || hasStrat;

    final gapAfterCapital =
        showCapitalRow &&
        (showCheckAnalyseRow || showEtatStratRow || hasPaychekLens || rest.isNotEmpty);
    final gapAfterCheckAnalyse =
        showCheckAnalyseRow && (showEtatStratRow || hasPaychekLens || rest.isNotEmpty);
    final gapAfterPaychekLens = hasPaychekLens && rest.isNotEmpty;
    final gapBeforePaychekLens = hasPaychekLens &&
        (showCapitalRow || showCheckAnalyseRow || showEtatStratRow || WebDashboardConfig.useLeftRail);

    /// Ligne capital + évolution : capital ~27 %, évolution ~73 %.
    const webCapitalRowFlex = 10;
    const webEvolutionRowFlex = 27;
    const webCapitalPairGap = 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showCapitalRow)
          hasCap && hasEvo
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    // Quand la fenêtre est ultra étroite, `maxWidth - gap` peut devenir <= 0
                    // et produire des tailles négatives → erreurs de contraintes/pixels.
                    if (constraints.maxWidth < 520) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionForId(capId),
                          const SizedBox(height: 20),
                          _sectionForId(evoId),
                        ],
                      );
                    }

                    final inner = (constraints.maxWidth - webCapitalPairGap)
                        .clamp(0.0, double.infinity);
                    final sumFlex = webCapitalRowFlex + webEvolutionRowFlex;
                    final capW = inner * webCapitalRowFlex / sumFlex;
                    final evoW = inner - capW;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: capW,
                          child: _sectionForId(capId),
                        ),
                        SizedBox(width: webCapitalPairGap),
                        SizedBox(
                          width: evoW,
                          child: _sectionForId(evoId),
                        ),
                      ],
                    );
                  },
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasCap) Expanded(child: _sectionForId(capId)),
                    if (hasEvo) Expanded(child: _sectionForId(evoId)),
                  ],
                ),
        if (gapAfterCapital) const SizedBox(height: 20),
        if (showCheckAnalyseRow)
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final gap = wide ? 20.0 : 0.0;
              if (hasCheck && hasAnalyse) {
                return WebDashboardChecklistAnalysePair(
                  wide: wide,
                  gap: gap,
                  checklistChild: _sectionForId(checkId),
                  analyseChild: _sectionForId(analyseId),
                  onOpenChecklistFull: widget.onOpenChecklist,
                );
              }
              if (hasCheck) {
                return WebDashboardPairedCard(child: _sectionForId(checkId));
              }
              return WebDashboardPairedCard(child: _sectionForId(analyseId));
            },
          ),
        if (gapAfterCheckAnalyse) const SizedBox(height: 20),
        if (showEtatStratRow)
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final webRail = WebDashboardConfig.useLeftRail;
              /// Web large + rail : gauche = État mental, puis Stratégie, puis This week ;
              /// droite = Calendrier (à la place de l’ancienne pile strat + this week).
              if (webRail && wide && hasEtat && hasStrat) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WebDashboardPairedCard(
                            child: SizedBox(
                              width: double.infinity,
                              child: _sectionForId(etatId),
                            ),
                          ),
                          const SizedBox(height: 20),
                          WebDashboardPairedCard(
                            child: SizedBox(
                              width: double.infinity,
                              child: _sectionForId(stratId),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: WebDashboardPairedCard(
                        child: SizedBox(
                          width: double.infinity,
                          child: DashboardCalendrierCard(
                            onOpenTradeById: widget.liteFreemiumRestricted
                                ? null
                                : widget.onOpenTradeById,
                            liteInteractionLocked: widget.liteFreemiumRestricted,
                            onLiteInteractionLockedTap:
                                widget.onLiteFreemiumRestrictedTap,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (wide && hasEtat && hasStrat) {
                /// 50 % / 50 % (flex 1:1). Pas de hauteur forcée : scroll vertical infini.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: WebDashboardPairedCard(
                        child: SizedBox(
                          width: double.infinity,
                          child: _sectionForId(etatId),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: WebDashboardPairedCard(
                        child: SizedBox(
                          width: double.infinity,
                          child: _sectionForId(stratId),
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (!wide && hasEtat && hasStrat) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WebDashboardPairedCard(child: _sectionForId(etatId)),
                    const SizedBox(height: 24),
                    WebDashboardPairedCard(child: _sectionForId(stratId)),
                    const SizedBox(height: 24),
                    WebDashboardPairedCard(
                      child: DashboardCalendrierCard(
                        onOpenTradeById: widget.liteFreemiumRestricted
                            ? null
                            : widget.onOpenTradeById,
                        liteInteractionLocked: widget.liteFreemiumRestricted,
                        onLiteInteractionLockedTap:
                            widget.onLiteFreemiumRestrictedTap,
                      ),
                    ),
                  ],
                );
              }
              if (hasEtat) {
                return WebDashboardPairedCard(child: _sectionForId(etatId));
              }
              return WebDashboardPairedCard(child: _sectionForId(stratId));
            },
          ),
        if (WebDashboardConfig.useLeftRail)
          LayoutBuilder(
            builder: (context, constraints) {
              final calendarInEtatStratColumn = showEtatStratRow &&
                  hasEtat &&
                  hasStrat &&
                  constraints.maxWidth >= 720;
              if (calendarInEtatStratColumn) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showCapitalRow ||
                      showCheckAnalyseRow ||
                      showEtatStratRow)
                    const SizedBox(height: 20),
                  WebThisWeekCalendarPair(
                    onOpenTradeById: widget.liteFreemiumRestricted
                        ? null
                        : widget.onOpenTradeById,
                    liteInteractionLocked: widget.liteFreemiumRestricted,
                    onLiteInteractionLockedTap:
                        widget.onLiteFreemiumRestrictedTap,
                  ),
                ],
              );
            },
          ),
        if (gapBeforePaychekLens) const SizedBox(height: 20),
        if (hasPaychekLens) _sectionForId(paychekLensId),
        if (gapAfterPaychekLens) const SizedBox(height: 20),
        for (var i = 0; i < rest.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          _sectionForId(rest[i]),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final layoutStore = DashboardHomeLayoutScope.of(context);
    final profileStore = UserProfileScope.of(context);
    final web = WebDashboardConfig.useLeftRail;
    return SafeArea(
      child: SingleChildScrollView(
        padding: web
            ? const EdgeInsets.fromLTRB(32, 32, 32, 32)
            : const EdgeInsets.symmetric(horizontal: 24),
        child: ListenableBuilder(
          listenable: profileStore,
          builder: (context, _) {
            final profile = profileStore.profile;
            final welcomeName = profile.dashboardHeaderTitle;
            final webHeroSubtitle =
                (welcomeName != null && welcomeName.isNotEmpty)
                    ? l10n.webHomeHeroWelcome(welcomeName)
                    : l10n.webHomeHeroSubtitle;
            final showUpgrade = DashboardHomePlanLogic.shouldShowHomeUpgrade(
              isProKnown: widget.accountPlanIsPro,
              upgradeTap: widget.onHomeUpgradeTap,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!web) const SizedBox(height: 8),
                DashboardHomeHero(
                  subtitle: webHeroSubtitle,
                  welcomeUserName:
                      (welcomeName != null && welcomeName.isNotEmpty)
                          ? welcomeName
                          : null,
                  accountPlanIsPro: widget.accountPlanIsPro,
                  selectedTimeframeIndex: web ? _capitalTimeframe : null,
                  onTimeframeChanged: web
                      ? (widget.liteFreemiumRestricted
                          ? (_) => _onLiteTap()
                          : (i) => setState(() {
                              _capitalTimeframe = i;
                              _evolutionTimeframe = i;
                            }))
                      : null,
                  onUpgradeTap:
                      showUpgrade ? widget.onHomeUpgradeTap : null,
                ),
                SizedBox(height: web ? 24 : 20),
                ListenableBuilder(
                  listenable: layoutStore,
                  builder: (context, _) {
                    final ids = layoutStore.orderedVisibleIds.toList();
                    if (WebDashboardConfig.useLeftRail) {
                      return _buildWebHomeSections(ids);
                    }
                    final mobileIds = _mobileHomeSectionOrder(ids);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < mobileIds.length; i++) ...[
                          if (i > 0) const SizedBox(height: 20),
                          _sectionForId(mobileIds[i]),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],
            );
          },
        ),
      ),
    );
  }
}
