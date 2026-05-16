import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Même convention que l’enregistrement d’un trade ([Ajouter trade]).
String formatTradeEntryDateLine(DateTime entreeAt, BuildContext context) {
  final loc = Localizations.localeOf(context).toString();
  return DateFormat("dd MMMM yyyy '•' HH:mm", loc).format(entreeAt.toLocal());
}
