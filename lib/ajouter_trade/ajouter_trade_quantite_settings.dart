import 'dart:math' show min;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ajouter_trade_actifs.dart';
import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_quantite_settings_form.dart';
import 'ajouter_trade_quantite_settings_header.dart';
import '../dashboard/dashboard_tokens.dart';
import '../strategie/sections/strategie_gestion_risque_section_display.dart';
import 'ajouter_trade_position_sizing.dart';

/// Boîte modale centrée « réglages position » : marché, actif, lot, prix (devise = questionnaire).
Future<void> showAjouterTradeQuantiteSettingsSheet({
  required BuildContext context,
  required AjouterTradeAssetClass initialMarche,
  required String initialActif,
  required String initialLot,
  required String initialPrix,
  required void Function(
    AjouterTradeAssetClass marche,
    String actif,
    String lot,
    String prix,
  )
  onApply,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => AnimatedPadding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _QuantiteSettingsSheet(
          initialMarche: initialMarche,
          initialActif: initialActif,
          initialLot: initialLot,
          initialPrix: initialPrix,
          onApply: onApply,
        ),
      ),
    ),
  );
}

class _QuantiteSettingsSheet extends StatefulWidget {
  const _QuantiteSettingsSheet({
    required this.initialMarche,
    required this.initialActif,
    required this.initialLot,
    required this.initialPrix,
    required this.onApply,
  });

  final AjouterTradeAssetClass initialMarche;
  final String initialActif;
  final String initialLot;
  final String initialPrix;
  final void Function(
    AjouterTradeAssetClass marche,
    String actif,
    String lot,
    String prix,
  )
  onApply;

  @override
  State<_QuantiteSettingsSheet> createState() => _QuantiteSettingsSheetState();
}

class _QuantiteSettingsSheetState extends State<_QuantiteSettingsSheet> {
  late AjouterTradeAssetClass _marche;
  late String _actif;
  late final TextEditingController _lotCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _riskPctCtrl;
  late final TextEditingController _stopDistCtrl;

  /// Actifs saisis dans la feuille, par marché (non persistés hors session).
  final Map<AjouterTradeAssetClass, List<String>> _customActifsByMarche = {};

  List<String> _actifItemsForMarche(AjouterTradeAssetClass m) {
    final base = ajouterTradeActifsPour(
      m,
      locale: Localizations.localeOf(context),
    );
    final out = List<String>.from(base);
    for (final e in _customActifsByMarche[m] ?? const <String>[]) {
      if (!out.contains(e)) out.add(e);
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _marche = widget.initialMarche;
    final initNorm = widget.initialActif.trim();
    final base = ajouterTradeActifsPour(
      _marche,
      locale: ui.PlatformDispatcher.instance.locale,
    );
    if (initNorm.isNotEmpty && !base.contains(initNorm)) {
      _customActifsByMarche[_marche] = [initNorm];
    }
    _lotCtrl = TextEditingController(text: widget.initialLot);
    _prixCtrl = TextEditingController(text: widget.initialPrix);
    _riskPctCtrl = TextEditingController(
      text: StrategieGestionRisqueFormat.formatNumEdit(1),
    );
    _stopDistCtrl = TextEditingController(
      text: StrategieGestionRisqueFormat.formatNumEdit(
        defaultStopDistanceForSizing(_marche),
      ),
    );
    _riskPctCtrl.addListener(() => setState(() {}));
    _stopDistCtrl.addListener(() => setState(() {}));
    final merged = _actifItemsForMarche(_marche);
    _actif = initNorm.isNotEmpty && merged.contains(initNorm)
        ? initNorm
        : (merged.isNotEmpty ? merged.first : initNorm);
  }

  @override
  void dispose() {
    _lotCtrl.dispose();
    _prixCtrl.dispose();
    _riskPctCtrl.dispose();
    _stopDistCtrl.dispose();
    super.dispose();
  }

  void _onMarcheChanged(AjouterTradeAssetClass v) {
    setState(() {
      _marche = v;
      final merged = _actifItemsForMarche(v);
      _actif = merged.contains(_actif) ? _actif : merged.first;
      _stopDistCtrl.text = StrategieGestionRisqueFormat.formatNumEdit(
        defaultStopDistanceForSizing(v),
      );
    });
  }

  void _onCustomActifAdded(String symbol) {
    setState(() {
      if (_actifItemsForMarche(_marche).contains(symbol)) {
        _actif = symbol;
        return;
      }
      final list = List<String>.from(_customActifsByMarche[_marche] ?? []);
      list.add(symbol);
      _customActifsByMarche[_marche] = list;
      _actif = symbol;
    });
  }

  @override
  Widget build(BuildContext context) {
    const sheetMaxWidth = 304.0;
    final availW = MediaQuery.sizeOf(context).width - 40;
    final sheetW = min(sheetMaxWidth, availW);

    final labelStyle =
        Theme.of(context).textTheme.labelSmall?.copyWith(
              color: DashboardTokens.labelGrey,
              fontWeight: FontWeight.w700,
              fontSize: 9,
              letterSpacing: 0.35,
            ) ??
            const TextStyle(
              color: DashboardTokens.labelGrey,
              fontWeight: FontWeight.w700,
              fontSize: 9,
              letterSpacing: 0.35,
            );

    final actifLabelStyle =
        Theme.of(context).textTheme.labelSmall?.copyWith(
              color: DashboardTokens.labelGrey,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.35,
            ) ??
            const TextStyle(
              color: DashboardTokens.labelGrey,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.35,
            );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: sheetW,
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: DashboardTokens.cardBoxBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DashboardTokens.cardBoxBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AjouterTradeQuantiteSettingsHeader(
                onClose: () => Navigator.of(context).pop(),
              ),
              AjouterTradeQuantiteSettingsForm(
                marche: _marche,
                onMarcheChanged: _onMarcheChanged,
                actif: _actif,
                actifItems: _actifItemsForMarche(_marche),
                onActifChanged: (v) => setState(() => _actif = v),
                onCustomActifAdded: _onCustomActifAdded,
                riskPctCtrl: _riskPctCtrl,
                stopDistCtrl: _stopDistCtrl,
                lotCtrl: _lotCtrl,
                prixCtrl: _prixCtrl,
                labelStyle: labelStyle,
                actifLabelStyle: actifLabelStyle,
                onApplySuggestedLot: (suggested) {
                  setState(() {
                    _lotCtrl.text =
                        StrategieGestionRisqueFormat.formatNumEdit(suggested);
                  });
                },
                onApplyPressed: () {
                  widget.onApply(
                    _marche,
                    _actif,
                    _lotCtrl.text,
                    _prixCtrl.text,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
