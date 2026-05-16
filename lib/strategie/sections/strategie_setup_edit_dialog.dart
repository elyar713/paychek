import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../strategie_tokens.dart';
import '../widgets/strategie_setup_card.dart';
import 'strategie_setup_edit_dialog_models.dart';
import 'strategie_setup_edit_dialog_tag_field.dart';

export 'strategie_setup_edit_dialog_models.dart';

/// Ouvre le dialogue (maquette : tags, nom, couleur, sections rÃ¨gles).
Future<StrategieSetupEditDialogResult?> showStrategieSetupEditDialog(
  BuildContext context, {
  required StrategieSetupCardData initial,
  bool isNew = false,
}) {
  return showDialog<StrategieSetupEditDialogResult?>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (ctx) => _StrategieSetupEditDialog(
      initial: initial,
      isNew: isNew,
    ),
  );
}

class _StrategieSetupEditDialog extends StatefulWidget {
  const _StrategieSetupEditDialog({
    required this.initial,
    required this.isNew,
  });

  final StrategieSetupCardData initial;
  final bool isNew;

  @override
  State<_StrategieSetupEditDialog> createState() =>
      _StrategieSetupEditDialogState();
}

class _StrategieSetupEditDialogState extends State<_StrategieSetupEditDialog> {
  static const _labelColor = Color(0xFF888888);
  static const _fieldBg = Color(0xFF111111);
  static const _border = Color(0xFF222222);

  late final TextEditingController _nameC;
  late Color _dotColor;
  late String _colorLabel;

  late List<String> _timeframes;
  late List<String> _indicators;
  late List<String> _patterns;
  late List<String> _signals;
  late List<String> _entree;
  late List<String> _invalidation;
  late List<String> _cible;
  late List<String> _gestion;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    _nameC = TextEditingController(text: d.title);
    _dotColor = strategieSetupClosestPresetColor(d.dotColor);
    _colorLabel = strategieSetupEditColorPresets
        .firstWhere(
          (e) => e.color == _dotColor,
          orElse: () => strategieSetupEditColorPresets.first,
        )
        .label;

    _timeframes = strategieSetupSplitCsv(d.timeframes);
    _indicators = strategieSetupSplitCsv(d.indicateurs);
    _patterns = d.pattern.isEmpty || d.pattern == 'â€”'
        ? []
        : strategieSetupBodyToTags(d.pattern);
    _signals = d.signalText.isEmpty || d.signalText == 'â€”'
        ? []
        : strategieSetupBodyToTags(d.signalText);

    if (d.ruleBlocks.length >= 4) {
      _entree = strategieSetupBodyToTags(d.ruleBlocks[0].body);
      _invalidation = strategieSetupBodyToTags(d.ruleBlocks[1].body);
      _cible = strategieSetupBodyToTags(d.ruleBlocks[2].body);
      _gestion = strategieSetupBodyToTags(d.ruleBlocks[3].body);
    } else {
      _entree = [];
      _invalidation = [];
      _cible = [];
      _gestion = [];
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    super.dispose();
  }

  TextStyle get _labelStyle => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
        color: _labelColor,
      );

  void _submit() {
    final name = _nameC.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      StrategieSetupEditDialogResult(
        modelName: name,
        dotColor: _dotColor,
        timeframes: List<String>.from(_timeframes),
        indicators: List<String>.from(_indicators),
        patterns: List<String>.from(_patterns),
        signals: List<String>.from(_signals),
        entreePrecise: List<String>.from(_entree),
        invalidation: List<String>.from(_invalidation),
        cible: List<String>.from(_cible),
        gestion: List<String>.from(_gestion),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final dialogW = math.min(360.0, media.size.width - 32);
    final dialogH = math.min(640.0, media.size.height * 0.9);
    final footerBottom = math.max(16.0, media.padding.bottom);

    return Dialog(
      backgroundColor: const Color(0xFF0a0a0a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: SizedBox(
        width: dialogW,
        height: dialogH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.candlestickChart,
                    size: 18,
                    color: StrategieTokens.emerald,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isNew ? l.strategieSetupNewTitle : l.strategieSetupEditTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, size: 20, color: StrategieTokens.labelMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(l.strategieModelName, style: _labelStyle),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameC,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                decoration: _outlineDecoration(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 86,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l.strategieSetupColor,
                                style: _labelStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.only(left: 6, right: 2),
                                decoration: BoxDecoration(
                                  color: _fieldBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _colorLabel,
                                    isExpanded: true,
                                    isDense: true,
                                    dropdownColor: const Color(0xFF1A1A1A),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    iconSize: 18,
                                    iconEnabledColor: StrategieTokens.labelMuted,
                                    items: strategieSetupEditColorPresets
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.label,
                                            child: Text(
                                              e.label,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() {
                                        _colorLabel = v;
                                        _dotColor = strategieSetupEditColorPresets
                                            .firstWhere((e) => e.label == v)
                                            .color;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(l.strategieTimeframes, style: _labelStyle),
                              const SizedBox(height: 8),
                              StrategieSetupTagField(
                                tags: _timeframes,
                                hintText: l.strategieHintTimeframeTag,
                                onChanged: (l) => setState(() => _timeframes = l),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(l.strategieIndicators, style: _labelStyle),
                              const SizedBox(height: 8),
                              StrategieSetupTagField(
                                tags: _indicators,
                                hintText: l.strategieHintIndicatorTag,
                                onChanged: (l) => setState(() => _indicators = l),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l.strategiePatternFigure, style: _labelStyle),
                    const SizedBox(height: 8),
                    StrategieSetupTagField(
                      tags: _patterns,
                      hintText: l.strategieHintPattern,
                      onChanged: (l) => setState(() => _patterns = l),
                    ),
                    const SizedBox(height: 16),
                    Text(l.strategieAlertSignal, style: _labelStyle),
                    const SizedBox(height: 8),
                    StrategieSetupTagField(
                      tags: _signals,
                      hintText: l.strategieHintSignal,
                      onChanged: (l) => setState(() => _signals = l),
                    ),
                    const SizedBox(height: 20),
                    _iconSectionHeader(
                      LucideIcons.crosshair,
                      l.strategieRuleEntryPrecise,
                      Colors.white,
                    ),
                    const SizedBox(height: 8),
                    StrategieSetupTagField(
                      tags: _entree,
                      hintText: l.strategieHintEntry,
                      onChanged: (l) => setState(() => _entree = l),
                    ),
                    const SizedBox(height: 16),
                    _iconSectionHeader(
                      LucideIcons.shield,
                      l.strategieRuleInvalidation,
                      StrategieTokens.riskRed,
                    ),
                    const SizedBox(height: 8),
                    StrategieSetupTagField(
                      tags: _invalidation,
                      hintText: l.strategieHintInvalidation,
                      onChanged: (l) => setState(() => _invalidation = l),
                    ),
                    const SizedBox(height: 16),
                    _iconSectionHeader(
                      LucideIcons.circleDot,
                      l.strategieRuleTarget,
                      StrategieTokens.emerald,
                    ),
                    const SizedBox(height: 8),
                    StrategieSetupTagField(
                      tags: _cible,
                      hintText: l.strategieHintTarget,
                      onChanged: (l) => setState(() => _cible = l),
                    ),
                    const SizedBox(height: 16),
                    _iconSectionHeader(
                      LucideIcons.lock,
                      l.strategieRuleManagement,
                      StrategieTokens.labelMuted,
                    ),
                    const SizedBox(height: 8),
                    StrategieSetupTagField(
                      tags: _gestion,
                      hintText: l.strategieHintManagement,
                      onChanged: (l) => setState(() => _gestion = l),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: _border),
            Material(
              color: const Color(0xFF0a0a0a),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, footerBottom),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF888888),
                          side: const BorderSide(color: Color(0xFF333333)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submit,
                        child: Text(l.save),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _outlineDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: _fieldBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: StrategieTokens.emerald),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _iconSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}



