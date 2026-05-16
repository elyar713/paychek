import 'package:flutter/material.dart';

class MentalStateCardTitleRow extends StatelessWidget {
  const MentalStateCardTitleRow({
    super.key,
    required this.left,
    this.right,
  });

  final Widget left;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: left),
        if (right != null)
          Flexible(
            fit: FlexFit.loose,
            child: Align(
              alignment: Alignment.centerRight,
              child: right!,
            ),
          ),
      ],
    );
  }
}
