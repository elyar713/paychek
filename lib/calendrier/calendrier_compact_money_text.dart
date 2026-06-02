import 'package:flutter/material.dart';

import 'calendrier_utils.dart';

/// Montant + devise sur **une seule ligne** (rétrécit si la case est étroite).
class CalendrierCompactMoneyText extends StatelessWidget {
  const CalendrierCompactMoneyText({
    super.key,
    required this.amount,
    required this.currencySymbol,
    required this.style,
    this.textAlign = TextAlign.center,
    this.alignment,
  });

  final double amount;
  final String currencySymbol;
  final TextStyle style;
  final TextAlign textAlign;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    final text = formatMoneyWithCurrencySymbol(amount, currencySymbol);
    final align = alignment ?? switch (textAlign) {
      TextAlign.end => Alignment.centerRight,
      TextAlign.start => Alignment.centerLeft,
      _ => Alignment.center,
    };

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: align,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          textAlign: textAlign,
          style: style,
        ),
      ),
    );
  }
}
