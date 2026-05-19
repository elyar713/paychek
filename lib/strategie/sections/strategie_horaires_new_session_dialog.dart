import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../strategie_tokens.dart';
import 'strategie_horaires_new_session_dialog_models.dart';
import 'strategie_horaires_new_session_time_wheels.dart';

export 'strategie_horaires_new_session_dialog_models.dart';

enum _TimePick { start, end }

/// Dialogue modal Â« Nouvelle session Â» (maquette : nom, description, dÃ©but/fin, type de zone).
///
/// [initial] non null â†’ prÃ©remplissage + libellÃ©s **Ã©dition** (mÃªme fenÃªtre).
Future<StrategieNewSessionDialogResult?> showStrategieNewSessionDialog(
  BuildContext context, {
  StrategieNewSessionDialogInitial? initial,
}) {
  return showDialog<StrategieNewSessionDialogResult?>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (ctx) => _StrategieNewSessionDialog(initial: initial),
  );
}

class _StrategieNewSessionDialog extends StatefulWidget {
  const _StrategieNewSessionDialog({this.initial});

  final StrategieNewSessionDialogInitial? initial;

  @override
  State<_StrategieNewSessionDialog> createState() =>
      _StrategieNewSessionDialogState();
}

class _StrategieNewSessionDialogState extends State<_StrategieNewSessionDialog> {
  late final TextEditingController _nameC;
  late final TextEditingController _descC;
  TimeOfDay? _start;
  TimeOfDay? _end;

  /// `false` = **Trade** (sÃ©lectionnÃ© par dÃ©faut), `true` = **No Trade**.
  bool _noTradeZone = false;

  /// Roues heure/minute ouvertes sous **DÃ‰BUT** ou **FIN** (`null` = fermÃ©).
  _TimePick? _openTimePick;

  static const _labelColor = Color(0xFF888888);

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameC = TextEditingController(text: i?.title ?? '');
    _descC = TextEditingController(text: i?.description ?? '');
    _start = i?.startTime;
    _end = i?.endTime;
    if (i != null) _noTradeZone = i.isNoTradeZone;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _descC.dispose();
    super.dispose();
  }

  TextStyle get _labelStyle => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
        color: _labelColor,
      );

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF666666),
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFF111111),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF222222)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: StrategieTokens.emerald),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String _timeLabel(TimeOfDay? t) {
    if (t == null) return '--:--';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _toggleTimePick(_TimePick target) {
    setState(() {
      if (_openTimePick == target) {
        _openTimePick = null;
      } else {
        _openTimePick = target;
      }
    });
  }

  Widget _buildStartEndTimeFields(AppLocalizations l) {
    final startField = _timeFieldWithOptionalWheels(
      label: l.strategieTimeStartLabel,
      value: _start,
      pick: _TimePick.start,
    );
    final endField = _timeFieldWithOptionalWheels(
      label: l.strategieTimeEndOptionalLabel,
      value: _end,
      pick: _TimePick.end,
    );
    if (kIsWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          startField,
          const SizedBox(height: 16),
          endField,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: startField),
        const SizedBox(width: 12),
        Expanded(child: endField),
      ],
    );
  }

  Widget _timeFieldWithOptionalWheels({
    required String label,
    required TimeOfDay? value,
    required _TimePick pick,
  }) {
    final isOpen = _openTimePick == pick;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleTimePick(pick),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _timeLabel(value),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: StrategieTokens.labelMuted,
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    LucideIcons.clock,
                    size: 15,
                    color: StrategieTokens.labelMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isOpen) ...[
          const SizedBox(height: 6),
          StrategieSessionInlineTimeWheels(
            key: ValueKey(pick),
            initial: pick == _TimePick.start
                ? (_start ?? TimeOfDay.now())
                : (_end ?? _start ?? TimeOfDay.now()),
            onChanged: (t) => setState(() {
              if (pick == _TimePick.start) {
                _start = t;
              } else {
                _end = t;
              }
            }),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: const Color(0xFF0a0a0a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF222222)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: kIsWeb ? 360 : 320),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            physics: _openTimePick != null
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 16,
                      color: StrategieTokens.emerald,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _editing
                            ? l.strategieEditSessionTitle
                            : l.strategieNewSessionTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.pencil,
                      size: 16,
                      color: StrategieTokens.labelMuted,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: '',
                      icon: const Icon(
                        LucideIcons.x,
                        size: 20,
                        color: Color(0xFF555555),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l.strategieSessionName, style: _labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameC,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: _fieldDecoration(),
                ),
                const SizedBox(height: 16),
                Text(l.strategieDescription, style: _labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _descC,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: _fieldDecoration(
                    hintText: l.strategieDescriptionHint,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStartEndTimeFields(l),
                const SizedBox(height: 16),
                Text(l.strategieZoneType, style: _labelStyle),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: !_noTradeZone
                              ? StrategieTokens.emerald
                              : const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => setState(() => _noTradeZone = false),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Text(
                                  l.strategieZoneTrade,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: !_noTradeZone
                                        ? Colors.black
                                        : const Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Material(
                          color: _noTradeZone
                              ? StrategieTokens.riskRed
                              : const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => setState(() => _noTradeZone = true),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Text(
                                  l.strategieZoneNoTrade,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _noTradeZone
                                        ? Colors.black
                                        : const Color(0xFF666666),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
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
                        onPressed: () {
                          final title = _nameC.text.trim();
                          if (title.isEmpty) return;
                          Navigator.pop(
                            context,
                            StrategieNewSessionDialogResult(
                              title: title,
                              description: _descC.text.trim(),
                              startTime: _start,
                              endTime: _end,
                              isNoTradeZone: _noTradeZone,
                            ),
                          );
                        },
                        child:
                            Text(_editing ? l.save : l.actionAdd),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



