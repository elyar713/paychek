import 'package:flutter/material.dart';

/// Palette maquette mobile v2 (#020205 / noir & or).
abstract final class PaywallMobileTokens {
  PaywallMobileTokens._();

  static const Color bg = Color(0xFF020205);
  static const Color cardBg = Color(0xFF0B0C10);
  static const Color tableBg = Color(0xFF000000);
  static const Color neutral950 = Color(0xFF0A0A0A);
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber300 = Color(0xFFFCD34D);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE0B2),
      Color(0xFFD4A359),
      Color(0xFFB38038),
    ],
  );

  static const LinearGradient selectedPlanGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0x1AF59E0B),
      Color(0x00000000),
    ],
  );

  static const LinearGradient goldPillBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AF59E0B),
      Color(0x0DF59E0B),
    ],
  );
}
