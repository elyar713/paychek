import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Roues compactes sous la case DÉBUT / FIN — mise à jour live, sans boutons.
class StrategieSessionInlineTimeWheels extends StatefulWidget {
  const StrategieSessionInlineTimeWheels({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  final TimeOfDay initial;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  State<StrategieSessionInlineTimeWheels> createState() =>
      _StrategieSessionInlineTimeWheelsState();
}

class _StrategieSessionInlineTimeWheelsState
    extends State<StrategieSessionInlineTimeWheels> {
  static const _digitColor = Color(0xFFC8C8C8);
  static const _selectionFill = Color(0xFF2A2A2A);
  static const _separatorColor = Color(0xFF444444);

  /// Même hauteur de ligne que la case DÉBUT (lisible) ; 5 lignes visibles.
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
