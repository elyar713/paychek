import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème console admin Paychek — fond très sombre, accent vert néon.
abstract final class AdminTheme {
  AdminTheme._();

  static const Color bg = Color(0xFF0A0A0A);
  /// Fonds type maquette HTML « admin panel v2 » (support).
  static const Color supportCanvas = Color(0xFF07090D);
  static const Color supportPanel = Color(0xFF0A0C10);
  /// Rail latéral (contraste léger avec le fond principal).
  static const Color sidebarBg = Color(0xFF0C0C0F);
  static const Color card = Color(0xFF141414);
  static const Color cardElevated = Color(0xFF181C1A);
  static const Color border = Color(0xFF1F2937);
  static const Color accent = Color(0xFF2ECC71);
  static const Color accentDim = Color(0xFF1B5E3A);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDim = Color(0xFF6B7280);
  static const Color warning = Color(0xFFF59E0B);
  /// Mise en évidence des tickets / bulles avec pièce jointe.
  static const Color attachmentHighlight = Color(0xFFEF4444);
  static const Color liveBlue = Color(0xFF3B82F6);

  /// Encadré rouge léger pour les blocs « pièce jointe » (admin support).
  static BoxDecoration attachmentPanelDecoration() => BoxDecoration(
        color: attachmentHighlight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: attachmentHighlight.withValues(alpha: 0.72),
          width: 1.2,
        ),
      );

  static const Color liveYellow = Color(0xFFEAB308);

  static ThemeData theme() {
    final baseText = GoogleFonts.plusJakartaSans(
      color: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        surface: bg,
        primary: accent,
        onPrimary: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: baseText,
        bodyMedium: baseText.copyWith(fontSize: 14),
        bodySmall: baseText.copyWith(fontSize: 12, color: textMuted),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      dividerColor: border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent, width: 1.2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: textDim, fontSize: 14),
        labelStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 13),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: textMuted,
          letterSpacing: 0.5,
        ),
        dataTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
      ),
    );
  }
}
