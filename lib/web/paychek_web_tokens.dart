import 'package:flutter/material.dart';

/// Palette Web alignée sur la maquette React / Tailwind fournie.
abstract final class PaychekWebTokens {
  PaychekWebTokens._();

  /// `text-zinc-500` (Tailwind zinc-500).
  static const Color textZinc500 = Color(0xFF71717A);

  /// `amber-500` — CTA upgrade maquette header web.
  static const Color upgradeAmber = Color(0xFFF59E0B);

  /// Fond « glass » type `rgba(9, 9, 11, 0.8)`.
  static const Color glassCardFill = Color(0xCC09090B);

  /// `bg-[#0a0a0a]`, `min-h-screen`.
  static const Color scaffoldBg = Color(0xFF0A0A0A);

  static const Color railBg = Color(0xFF0A0A0A);

  /// `bg-[#111111]`, cartes principales.
  static const Color cardBg = Color(0xFF111111);

  /// `border-gray-800` (Tailwind) ≈ #1F2937.
  static const Color borderGray800 = Color(0xFF1F2937);

  /// Alias pour le code existant ([shellCardDecoration], rail).
  static Color get cardBorder => borderGray800;

  /// Piste des pilules période : `bg-[#141414]`.
  static const Color pillTrackBg = Color(0xFF141414);

  /// `text-gray-500` labels.
  static const Color textGray500 = Color(0xFF6B7280);

  /// `text-gray-400` / `text-gray-600` nav secondaire.
  static const Color textGray400 = Color(0xFF9CA3AF);
  static const Color textGray600 = Color(0xFF4B5563);

  /// `emerald-500` (Tailwind) — boutons, actifs, barres.
  static const Color accentEmerald = Color(0xFF10B981);

  /// `emerald-400` — survol CTA.
  static const Color accentEmeraldLight = Color(0xFF34D399);

  /// Libellés de section type maquette (orange / cuivré).
  static const Color sectionLabelCopper = Color(0xFFE8A66B);

  static const double radiusCard = 16;
  static const double radiusNavItem = 8;
  static const double radiusButton = 12;

  static Color get accentMint => accentEmerald;

  static Color get accentMintDark => const Color(0xFF059669);

  static BoxDecoration shellCardDecoration() => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(
          color: borderGray800,
          width: 1,
        ),
      );

  /// CTA `bg-emerald-500` (plein, sans dégradé).
  static BoxDecoration primaryButtonDecoration() => const BoxDecoration(
        color: accentEmerald,
        borderRadius: BorderRadius.all(Radius.circular(radiusButton)),
      );
}
