import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_discipline_prefs_storage.dart';
import 'ajouter_trade_discipline_settings_sheet_widgets.dart';

/// Préférences affichées dans la feuille « discipline » (Ajouter trade).
@immutable
class AjouterTradeDisciplinePrefs {
  const AjouterTradeDisciplinePrefs({
    required this.authorizeWhenFeeling,
    required this.strategie,
    required this.planAnalyse,
    required this.checklist,
    required this.etatMoment,
    required this.sessionAutoTagEnabled,
    required this.plannedTradesPerDay,
  });

  static const defaults = AjouterTradeDisciplinePrefs(
    authorizeWhenFeeling: false,
    strategie: true,
    planAnalyse: true,
    checklist: true,
    etatMoment: true,
    sessionAutoTagEnabled: false,
    plannedTradesPerDay: 2,
  );

  final bool authorizeWhenFeeling;
  final bool strategie;
  final bool planAnalyse;
  final bool checklist;
  final bool etatMoment;

  /// Test : classe Principe / Feeling selon l’ordre des trades du jour (CSV inclus).
  final bool sessionAutoTagEnabled;
  final int plannedTradesPerDay;

  AjouterTradeDisciplinePrefs copyWith({
    bool? authorizeWhenFeeling,
    bool? strategie,
    bool? planAnalyse,
    bool? checklist,
    bool? etatMoment,
    bool? sessionAutoTagEnabled,
    int? plannedTradesPerDay,
  }) {
    return AjouterTradeDisciplinePrefs(
      authorizeWhenFeeling:
          authorizeWhenFeeling ?? this.authorizeWhenFeeling,
      strategie: strategie ?? this.strategie,
      planAnalyse: planAnalyse ?? this.planAnalyse,
      checklist: checklist ?? this.checklist,
      etatMoment: etatMoment ?? this.etatMoment,
      sessionAutoTagEnabled:
          sessionAutoTagEnabled ?? this.sessionAutoTagEnabled,
      plannedTradesPerDay:
          plannedTradesPerDay ?? this.plannedTradesPerDay,
    );
  }

  Map<String, dynamic> toJson() => {
        'authorizeWhenFeeling': authorizeWhenFeeling,
        'strategie': strategie,
        'planAnalyse': planAnalyse,
        'checklist': checklist,
        'etatMoment': etatMoment,
        'sessionAutoTagEnabled': sessionAutoTagEnabled,
        'plannedTradesPerDay': plannedTradesPerDay.clamp(1, 10),
      };

  static AjouterTradeDisciplinePrefs fromJson(Map<String, dynamic> m) {
    return AjouterTradeDisciplinePrefs(
      authorizeWhenFeeling: m['authorizeWhenFeeling'] as bool? ?? false,
      strategie: m['strategie'] as bool? ?? true,
      planAnalyse: m['planAnalyse'] as bool? ?? true,
      checklist: m['checklist'] as bool? ?? true,
      etatMoment: m['etatMoment'] as bool? ?? true,
      sessionAutoTagEnabled: m['sessionAutoTagEnabled'] as bool? ?? false,
      plannedTradesPerDay: (m['plannedTradesPerDay'] as num?)?.round() ?? 2,
    );
  }
}

/// Bottom sheet : autorisation Feeling + interrupteurs par section.
Future<void> showAjouterTradeDisciplineSettingsSheet({
  required BuildContext context,
  required AjouterTradeDisciplinePrefs initial,
  required ValueChanged<AjouterTradeDisciplinePrefs> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return _AjouterTradeDisciplineSheetBody(
        initial: initial,
        onChanged: onChanged,
      );
    },
  );
}

class _AjouterTradeDisciplineSheetBody extends StatefulWidget {
  const _AjouterTradeDisciplineSheetBody({
    required this.initial,
    required this.onChanged,
  });

  final AjouterTradeDisciplinePrefs initial;
  final ValueChanged<AjouterTradeDisciplinePrefs> onChanged;

  @override
  State<_AjouterTradeDisciplineSheetBody> createState() =>
      _AjouterTradeDisciplineSheetBodyState();
}

class _AjouterTradeDisciplineSheetBodyState
    extends State<_AjouterTradeDisciplineSheetBody> {
  late AjouterTradeDisciplinePrefs _p;

  @override
  void initState() {
    super.initState();
    _p = widget.initial;
  }

  void _emit(AjouterTradeDisciplinePrefs next) {
    final normalized = next.copyWith(
      plannedTradesPerDay: next.plannedTradesPerDay.clamp(1, 10),
    );
    setState(() => _p = normalized);
    widget.onChanged(normalized);
    AjouterTradeDisciplinePrefsStorage.save(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final textTheme = Theme.of(context).textTheme;

    final maxH = MediaQuery.sizeOf(context).height * 0.78;

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: bottom + 10,
      ),
      child: Material(
        color: DashboardTokens.cardBoxBg,
        elevation: 12,
        shadowColor: Colors.black54,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(22),
          bottom: Radius.circular(22),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(22),
            bottom: Radius.circular(22),
          ),
          child: SizedBox(
            height: maxH,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: DashboardTokens.cardBoxBorder),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: DashboardTokens.muted.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l.ajouterTradeDisciplineSettingsTitle,
                        style: textTheme.titleMedium?.copyWith(
                          color: DashboardTokens.onMatteEmphasis,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.ajouterTradeDisciplineSettingsSubtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: DashboardTokens.muted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AjouterTradeDisciplineFeelingCard(
                          value: _p.authorizeWhenFeeling,
                          onChanged: (v) => _emit(
                            _p.copyWith(authorizeWhenFeeling: v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AjouterTradeSessionMindsetTestCard(
                          autoTagEnabled: _p.sessionAutoTagEnabled,
                          plannedTradesPerDay: _p.plannedTradesPerDay,
                          onAutoTagChanged: (v) => _emit(
                            _p.copyWith(sessionAutoTagEnabled: v),
                          ),
                          onPlannedChanged: (n) => _emit(
                            _p.copyWith(plannedTradesPerDay: n),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.ajouterTradeDisciplineSectionsHeading,
                          style: textTheme.labelSmall?.copyWith(
                            color: DashboardTokens.titleGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AjouterTradeDisciplineSectionSwitchTile(
                          title: l.ajouterTradeDisciplineStrategieTitle,
                          subtitle: l.ajouterTradeDisciplineStrategieSubtitle,
                          value: _p.strategie,
                          onChanged: (v) => _emit(_p.copyWith(strategie: v)),
                        ),
                        AjouterTradeDisciplineSectionSwitchTile(
                          title: l.ajouterTradeDisciplinePlanTitle,
                          subtitle: l.ajouterTradeDisciplinePlanSubtitle,
                          value: _p.planAnalyse,
                          onChanged: (v) =>
                              _emit(_p.copyWith(planAnalyse: v)),
                        ),
                        AjouterTradeDisciplineSectionSwitchTile(
                          title: l.ajouterTradeDisciplineChecklistTitle,
                          subtitle: l.ajouterTradeDisciplineChecklistSubtitle,
                          value: _p.checklist,
                          onChanged: (v) => _emit(_p.copyWith(checklist: v)),
                        ),
                        AjouterTradeDisciplineSectionSwitchTile(
                          title: l.ajouterTradeDisciplineEtatTitle,
                          subtitle: l.ajouterTradeDisciplineEtatSubtitle,
                          value: _p.etatMoment,
                          onChanged: (v) => _emit(_p.copyWith(etatMoment: v)),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: DashboardTokens.accent,
                        foregroundColor: DashboardTokens.onMatteEmphasis,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l.ajouterTradeImagePickerClose,
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
  }
}
