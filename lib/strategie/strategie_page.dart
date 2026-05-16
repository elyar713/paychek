import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../performance/performance_locale_copy.dart';
import 'gestion_risque_edit_notifier.dart';
import 'sections/strategie_gestion_risque_section.dart';
import 'sections/strategie_horaires_sessions_section.dart';
import 'sections/strategie_mes_regles_section.dart';
import 'sections/strategie_calendrier_section.dart';
import 'sections/strategie_setup_modeles_section.dart';
import 'widgets/strategie_day_violations_card.dart';
import 'strategie_export_pdf.dart';
import 'strategie_tokens.dart';

/// Page « Ma Stratégie » — sections modulaires (maquettes).
///
/// [onNavigateToDashboard] : après fermeture de la route (flèche ou retour système), bascule
/// explicite vers l’**accueil Dashboard** (ex. `onOpenMainTab(0)` ou `_goTo(0)`).
///
/// [onReturnToDashboard] : rappel additionnel post-frame (optionnel).
///
/// [onCloseAsTab] : affichage dans [IndexedStack] — flèche / retour sans [Navigator.pop].
class StrategiePage extends StatefulWidget {
  const StrategiePage({
    super.key,
    this.onNavigateToDashboard,
    this.onReturnToDashboard,
    this.onCloseAsTab,
    this.liteFreemiumRestricted = false,
    this.onLiteFreemiumRestrictedTap,
  });

  /// Appelé juste après [Navigator.pop] pour forcer l’onglet Dashboard.
  final VoidCallback? onNavigateToDashboard;
  final VoidCallback? onReturnToDashboard;
  final VoidCallback? onCloseAsTab;
  final bool liteFreemiumRestricted;
  final VoidCallback? onLiteFreemiumRestrictedTap;

  @override
  State<StrategiePage> createState() => _StrategiePageState();
}

class _StrategiePageState extends State<StrategiePage> {
  final GestionRisqueEditNotifier _gestionRisqueEdit = GestionRisqueEditNotifier();
  late final ValueNotifier<int> _visibleSetupIndex;
  late final ValueNotifier<DateTime?> _selectedCalendarDay;

  /// Aligné sur Performance : mêmes paliers de marge horizontale que la page.
  static const double _kHeaderPadWideBreakpoint = 920;

  double _contentHorizontalPad(double width) =>
      width >= _kHeaderPadWideBreakpoint ? 24.0 : 20.0;

  @override
  void initState() {
    super.initState();
    _visibleSetupIndex = ValueNotifier<int>(0);
    _selectedCalendarDay = ValueNotifier<DateTime?>(DateTime.now());
  }

  @override
  void dispose() {
    _visibleSetupIndex.dispose();
    _selectedCalendarDay.dispose();
    super.dispose();
  }

  void _handleLeadingBack() {
    final embedded = widget.onCloseAsTab != null;
    if (embedded) {
      widget.onCloseAsTab!();
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Comme Performance : en-tête limité à [pageMaxContentWidth] et centré — pas sur toute la largeur de l’écran.
  Widget _buildStrategieHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final hPad = _contentHorizontalPad(w);
        final l = AppLocalizations.of(context)!;
        final code = Localizations.localeOf(context).languageCode;
        String t6(String fr, String en, String es, String de, String pt, String ko) =>
            perf6(code, fr, en, es, de, pt, ko);
        final innerMax = math.min(
          StrategieTokens.pageMaxContentWidth,
          w - 2 * hPad,
        );

        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: innerMax),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: _handleLeadingBack,
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFF555555),
                        padding: const EdgeInsets.all(10),
                        minimumSize: const Size(40, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.plusMyStrategy,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.4,
                                color: DashboardTokens.onMatteEmphasis,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t6(
                                'Playbook : règles, risque, horaires et setups.',
                                'Playbook: rules, risk, sessions, and setups.',
                                'Playbook: reglas, riesgo, horarios y setups.',
                                'Playbook: Regeln, Risiko, Zeiten und Setups.',
                                'Playbook: regras, risco, horários e setups.',
                                '플레이북: 규칙·리스크·세션·셋업.',
                              ),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                color: const Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
                      child: Tooltip(
                        message: t6(
                          'Exporter en PDF',
                          'Export as PDF',
                          'Exportar en PDF',
                          'Als PDF exportieren',
                          'Exportar em PDF',
                          'PDF로 내보내기',
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFF0F2620),
                            border: Border.all(color: StrategieTokens.emerald, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: StrategieTokens.emerald.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: widget.liteFreemiumRestricted
                                  ? widget.onLiteFreemiumRestrictedTap
                                  : () => exportStrategiePdf(context),
                              borderRadius: BorderRadius.circular(14),
                              splashColor: StrategieTokens.emerald.withValues(alpha: 0.28),
                              highlightColor: StrategieTokens.emerald.withValues(alpha: 0.14),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf_rounded,
                                      size: 23,
                                      color: StrategieTokens.emerald,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'PDF',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        color: DashboardTokens.onMatteEmphasis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void afterPopLegacy() {
      final cb = widget.onReturnToDashboard;
      if (cb == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => cb());
    }

    final embedded = widget.onCloseAsTab != null;

    return PopScope(
      canPop: !embedded,
      onPopInvokedWithResult: (didPop, result) {
        if (embedded) {
          if (!didPop) widget.onCloseAsTab!();
          return;
        }
        if (didPop) {
          widget.onNavigateToDashboard?.call();
          afterPopLegacy();
        }
      },
      child: Scaffold(
        backgroundColor: DashboardTokens.scaffoldMatte,
        body: SafeArea(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerUp: _gestionRisqueEdit.handlePointerUp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStrategieHeader(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide =
                          constraints.maxWidth >= StrategieTokens.twoColumnBreakpoint;
                      final hPad = _contentHorizontalPad(constraints.maxWidth);
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: StrategieTokens.pageMaxContentWidth,
                            ),
                            child: wide
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            const StrategieMesReglesSection(),
                                            const SizedBox(height: 16),
                                            StrategieGestionRisqueSection(
                                              editNotifier: _gestionRisqueEdit,
                                            ),
                                            const SizedBox(height: 16),
                                            StrategieHorairesSessionsSection(
                                              editNotifier: _gestionRisqueEdit,
                                            ),
                                            const SizedBox(height: 16),
                                            StrategieDayViolationsCard(
                                              selectedDay: _selectedCalendarDay,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            StrategieSetupModelesSection(
                                              editNotifier: _gestionRisqueEdit,
                                              visibleSetupIndex: _visibleSetupIndex,
                                            ),
                                            const SizedBox(height: 16),
                                            StrategieCalendrierSection(
                                              visibleSetupIndex: _visibleSetupIndex,
                                              selectedDayNotifier: _selectedCalendarDay,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const StrategieMesReglesSection(),
                                      const SizedBox(height: 16),
                                      StrategieGestionRisqueSection(
                                        editNotifier: _gestionRisqueEdit,
                                      ),
                                      const SizedBox(height: 16),
                                      StrategieHorairesSessionsSection(
                                        editNotifier: _gestionRisqueEdit,
                                      ),
                                      const SizedBox(height: 16),
                                      StrategieSetupModelesSection(
                                        editNotifier: _gestionRisqueEdit,
                                        visibleSetupIndex: _visibleSetupIndex,
                                      ),
                                      const SizedBox(height: 16),
                                      StrategieCalendrierSection(
                                        visibleSetupIndex: _visibleSetupIndex,
                                        selectedDayNotifier: _selectedCalendarDay,
                                      ),
                                      const SizedBox(height: 16),
                                      StrategieDayViolationsCard(
                                        selectedDay: _selectedCalendarDay,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
