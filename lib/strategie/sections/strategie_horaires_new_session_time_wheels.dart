import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sélecteur d'heure sous DÉBUT / FIN — roues (mobile) ou listes (web, clics fiables).
class StrategieSessionInlineTimeWheels extends StatelessWidget {
  const StrategieSessionInlineTimeWheels({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  final TimeOfDay initial;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _StrategieSessionWebTimePickers(
        key: key,
        initial: initial,
        onChanged: onChanged,
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: _StrategieSessionMobileTimeWheels(
        key: key,
        initial: initial,
        onChanged: onChanged,
      ),
    );
  }
}

/// Web : menus déroulants (pas de conflit scroll / souris avec [ListWheelScrollView]).
class _StrategieSessionWebTimePickers extends StatefulWidget {
  const _StrategieSessionWebTimePickers({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  final TimeOfDay initial;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  State<_StrategieSessionWebTimePickers> createState() =>
      _StrategieSessionWebTimePickersState();
}

class _StrategieSessionWebTimePickersState
    extends State<_StrategieSessionWebTimePickers> {
  static const _fieldBg = Color(0xFF1A1A1A);
  static const _border = Color(0xFF333333);

  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initial.hour;
    _minute = widget.initial.minute;
  }

  void _emit() {
    widget.onChanged(TimeOfDay(hour: _hour, minute: _minute));
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  TextStyle get _valueStyle => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  Widget _dropdownShell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }

  Widget _hourDropdown() {
    return _dropdownShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _hour,
          isExpanded: true,
          isDense: true,
          iconSize: 18,
          dropdownColor: const Color(0xFF1A1A1A),
          style: _valueStyle,
          iconEnabledColor: const Color(0xFF888888),
          items: [
            for (var h = 0; h < 24; h++)
              DropdownMenuItem(value: h, child: Text(_pad(h))),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _hour = v);
            _emit();
          },
        ),
      ),
    );
  }

  Widget _minuteDropdown() {
    return _dropdownShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _minute,
          isExpanded: true,
          isDense: true,
          iconSize: 18,
          dropdownColor: const Color(0xFF1A1A1A),
          style: _valueStyle,
          iconEnabledColor: const Color(0xFF888888),
          items: [
            for (var m = 0; m < 60; m++)
              DropdownMenuItem(value: m, child: Text(_pad(m))),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _minute = v);
            _emit();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          children: [
            Expanded(child: _hourDropdown()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                ':',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            Expanded(child: _minuteDropdown()),
          ],
        ),
      ),
    );
  }
}

/// Mobile : roues compactes — mise à jour live.
class _StrategieSessionMobileTimeWheels extends StatefulWidget {
  const _StrategieSessionMobileTimeWheels({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  final TimeOfDay initial;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  State<_StrategieSessionMobileTimeWheels> createState() =>
      _StrategieSessionMobileTimeWheelsState();
}

class _StrategieSessionMobileTimeWheelsState
    extends State<_StrategieSessionMobileTimeWheels> {
  static const _digitColor = Color(0xFFC8C8C8);
  static const _selectionFill = Color(0xFF2A2A2A);
  static const _separatorColor = Color(0xFF444444);

  static const _itemExtent = 26.0;
  static const _visibleLines = 5;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initial.hour;
    _minute = widget.initial.minute;
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(TimeOfDay(hour: _hour, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    final wheelHeight = _itemExtent * _visibleLines;

    return Material(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: SizedBox(
            height: wheelHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _wheelList(
                        controller: _hourController,
                        itemCount: 24,
                        label: (i) => i.toString().padLeft(2, '0'),
                        onChanged: (i) {
                          setState(() => _hour = i);
                          _emit();
                        },
                      ),
                    ),
                    Expanded(
                      child: _wheelList(
                        controller: _minuteController,
                        itemCount: 60,
                        label: (i) => i.toString().padLeft(2, '0'),
                        onChanged: (i) {
                          setState(() => _minute = i);
                          _emit();
                        },
                      ),
                    ),
                  ],
                ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      height: _itemExtent + 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _selectionFill.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 1,
                      height: wheelHeight - 8,
                      color: _separatorColor,
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

  Widget _wheelList({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _itemExtent,
      perspective: 0.001,
      diameterRatio: 1.12,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          return Center(
            child: Text(
              label(index),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _digitColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
