import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../trade/trade_models.dart';
import 'calendrier_constants.dart';

TextStyle dayDigitsStyle(Color color) {
  const size = kDayDigitFontSize;
  const weight = FontWeight.w500;
  final useSfPro = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);
  if (useSfPro) {
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontWeight: weight,
      color: color,
      fontSize: size,
      height: 1,
    );
  }
  return GoogleFonts.inter(
    color: color,
    fontSize: size,
    fontWeight: weight,
    height: 1,
  );
}

int dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

Map<int, double> netPnlByEntryDay(List<TradeListItem> items) {
  final m = <int, double>{};
  for (final t in items) {
    final k = dayKey(DateTime(t.entreeAt.year, t.entreeAt.month, t.entreeAt.day));
    m[k] = (m[k] ?? 0) + t.gainAmount;
  }
  return m;
}

Map<int, int> countTradesByEntryDay(List<TradeListItem> items) {
  final m = <int, int>{};
  for (final t in items) {
    final k = dayKey(DateTime(t.entreeAt.year, t.entreeAt.month, t.entreeAt.day));
    m[k] = (m[k] ?? 0) + 1;
  }
  return m;
}

/// Trades dont la date d’entrée tombe sur ce jour calendaire (ordre chronologique).
List<TradeListItem> tradesOnCalendarDay(List<TradeListItem> trades, DateTime day) {
  final k0 = dayKey(DateTime(day.year, day.month, day.day));
  final out = trades
      .where(
        (t) =>
            dayKey(
              DateTime(t.entreeAt.year, t.entreeAt.month, t.entreeAt.day),
            ) ==
            k0,
      )
      .toList();
  out.sort((a, b) => a.entreeAt.compareTo(b.entreeAt));
  return out;
}

Color dayDigitColor({
  required DateTime date,
  required Map<int, double> pnlByDay,
  required bool isSelected,
  required bool isFuture,
  required Color dayColor,
  required Color selectedColor,
  required Color futureColor,
  required Color futureSelectedColor,
}) {
  const eps = 1e-9;
  final net = pnlByDay[dayKey(date)];
  if (net != null) {
    if (net.abs() < eps) {
      return kBreakevenText;
    }
    return net > 0 ? kGainText : kLossText;
  }
  if (isSelected) {
    return isFuture ? futureSelectedColor : selectedColor;
  }
  return isFuture ? futureColor : dayColor;
}

String weekdayOneLetter(int sundayFirstIndex, String languageCode) {
  const en = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  const fr = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
  final lang = languageCode.toLowerCase();
  final list = lang.startsWith('fr') ? fr : en;
  return list[sundayFirstIndex];
}

({Color? bg, Color? border}) dayTileColors({
  required DateTime date,
  required Map<int, double> pnlByDay,
  required bool isSelected,
  required bool isToday,
}) {
  const eps = 1e-9;
  final net = pnlByDay[dayKey(date)];
  if (net != null) {
    if (net.abs() < eps) {
      return (
        bg: isSelected ? kBreakevenFillSelected : kBreakevenFill,
        border: null,
      );
    }
    if (net > 0) {
      return (
        bg: isSelected ? kGainFillSelected : kGainFill,
        border: null,
      );
    }
    return (
      bg: isSelected ? kLossFillSelected : kLossFill,
      border: null,
    );
  }
  if (isSelected) {
    return (bg: kNeutralSelectedFill, border: kSelectedBorderColor);
  }
  if (isToday) {
    return (bg: null, border: kTodayBorderColor);
  }
  return (bg: null, border: null);
}

String _asciiGroupIntPart(String digits) {
  final n = digits.length;
  if (n <= 3) return digits;
  final buf = StringBuffer();
  for (var i = 0; i < n; i++) {
    if (i > 0 && (n - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return buf.toString();
}

/// FR : signe +/**-**, partie entière avec **espaces milliers ASCII**, virgule décimale (sans ICU / sans `intl` — fiable Web & mobile).
String formatMoneyLocal(double v) {
  final sign = (v < 0 || (v == 0 && v.isNegative)) ? '-' : '+';
  final raw = v.abs().toStringAsFixed(2);
  final dot = raw.indexOf('.');
  final intPart = dot < 0 ? raw : raw.substring(0, dot);
  final frac = dot < 0 ? '00' : raw.substring(dot + 1);
  return '$sign${_asciiGroupIntPart(intPart)},$frac';
}

/// [`formatMoneyLocal`] + devise : **espace normal** avant la devise (toujours visible, pas de fines Unicode).
String formatMoneyWithCurrencySymbol(double v, String currencySymbol) {
  final amt = formatMoneyLocal(v);
  final sym = currencySymbol.trim();
  if (sym.isEmpty) return amt;
  return '$amt $sym';
}
