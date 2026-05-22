import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'analyse_models.dart';

abstract final class AnalyseTokens {
  AnalyseTokens._();

  /// Ancienne colonne unique (mobile).
  static const pageMaxWidth = 420.0;

  /// Tableau de bord analyse : entonnoir 3 colonnes (maquette Trading Plan).
  static const pageMaxWidthDashboard = 1280.0;

  /// Largeur max du corps (alignée sur [PerformancePage]).
  static const pageContentMaxWidth = 1200.0;

  /// Breakpoint page / padding horizontal (aligné Performance).
  static const pageLayoutWideBreakpoint = 920.0;

  /// [LayoutBuilder] : entonnoir 3 colonnes (lg).
  static const layoutBreakpointWide = 1024.0;

  /// Padding intérieur des cartes section (identique Performance).
  static const sectionCardPadding = EdgeInsets.all(20);

  /// Padding scroll page analyse (identique Performance).
  static EdgeInsets pageScrollPadding({required bool wide}) =>
      EdgeInsets.fromLTRB(wide ? 24 : 16, 0, wide ? 24 : 16, 48);

  /// Grille Direction / Tendance | TF / Phase sur la feuille contexte.
  static const layoutBreakpointFeuilleGrid = 520.0;

  // —— Palette OLED Dark (maquette pitch black) ——
  static const bg = Color(0xFF000000);
  static const textPrimary = Color(0xFFECECF1);
  static const headerBg = Color(0xE6050508); // #050508/90
  static const cardBg = Color(0xFF07080B);
  static const cardBgRaised = Color(0xFF07080B);
  static const inputBg = Color(0xFF0E0F14);
  static const inputBgDeep = Color(0xFF050608);
  static const cardBorder = Color(0xFF1B1C24);
  static const headerBorder = Color(0xFF1E2026);
  static const smcPanelBg = Color(0xFF0A0D14);
  static const vpPanelBg = Color(0xFF090A0E);

  static const oledBlue = Color(0xFF3B82F6);
  static const oledIndigo = Color(0xFF818CF8);
  static const oledGreen = Color(0xFF10B981);
  static const oledRed = Color(0xFFEF4444);
  static const oledAmber = Color(0xFFF59E0B);

  static const zinc100 = Color(0xFFF4F4F5);
  static const zinc200 = Color(0xFFE4E4E7);
  static const zinc300 = Color(0xFFD4D4D8);
  static const zinc400 = Color(0xFFA1A1AA);
  static const zinc500 = Color(0xFF71717A);
  static const zinc600 = Color(0xFF52525B);
  static const zinc700 = Color(0xFF3F3F46);

  // Alias rétrocompat (rapports, puces existantes)
  static const slate100 = zinc100;
  static const slate200 = zinc200;
  static const slate300 = zinc300;
  static const slate400 = zinc400;
  static const slate500 = zinc500;
  static const slate800Border = cardBorder;
  static const slate800Tint = Color(0xFF0E0F14);
  static const blue400 = oledBlue;
  static const blue500 = oledBlue;
  static const blue600 = oledBlue;
  static const blue900 = Color(0xFF172554);
  static const nightBorder = cardBorder;
  static const funnelHeaderBg = inputBg;
  static const bgElevated = inputBg;

  static const muted = zinc400;
  static const muted2 = zinc500;
  static const matteText = zinc200;

  static const accentGreen = oledGreen;
  static const accentAmber = oledAmber;
  static const accentRed = oledRed;

  static const chipHtfSelected = oledBlue;
  static const chipPhaseSelected = oledBlue;
  static const blue300 = oledIndigo;

  static const chipBg = inputBg;
  static const fieldBg = inputBg;
  static const contexteDuplicateBg = Color(0xFF0E0F14);
  static const structureDuplicateBg = Color(0xFF0E0F14);
  static const indicatorsDuplicateBg = Color(0xFF0E0F14);
  static const smcDuplicateBg = Color(0xFF0E0F14);

  /// Aligné sur les libellés figés du snapshot (FR/EN/ES/DE/PT : ACHAT·BUY…, VENTE·SELL…, WATCH…).
  /// L’ancien décor ne reconnaissait que ACHAT/VENTE → tout le reste tombait en ambre.
  static AnalyseDirectionBias directionBiasFromReportLabel(String biasLabel) {
    final t = biasLabel.trim();
    if (t.isEmpty) return AnalyseDirectionBias.surveiller;
    final s = t.toUpperCase();
    if (s == 'ACHAT' ||
        s == 'BUY' ||
        s == 'COMPRA' ||
        s == 'KAUF') {
      return AnalyseDirectionBias.achat;
    }
    if (s == 'VENTE' ||
        s == 'SELL' ||
        s == 'VENTA' ||
        s == 'VERKAUF' ||
        s == 'VENDA') {
      return AnalyseDirectionBias.vente;
    }
    if (s == 'WATCH' ||
        s == 'VIGILAR' ||
        s == 'BEOBACHTEN' ||
        s == 'OBSERVAR' ||
        s.contains('SURVEILLER')) {
      return AnalyseDirectionBias.surveiller;
    }
    return AnalyseDirectionBias.surveiller;
  }

  /// Décor du panneau « Rapport » selon la direction (achat = vert, vente = rouge, à surveiller = ambre).
  static BoxDecoration reportPanelDecorationForBias(AnalyseDirectionBias bias) {
    final (Color bg, Color border, Color glow) = switch (bias) {
      AnalyseDirectionBias.achat => (
          const Color(0xFF0F2418),
          const Color(0xFF1E3D2F),
          accentGreen,
        ),
      AnalyseDirectionBias.vente => (
          const Color(0xFF2A1010),
          const Color(0xFF3D2222),
          accentRed,
        ),
      AnalyseDirectionBias.surveiller => (
          const Color(0xFF2A2210),
          const Color(0xFF3D3420),
          accentAmber,
        ),
    };
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: glow.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// À partir du libellé figé du rapport ([AnalyseReportSnapshot.biasLabel]), toutes langues.
  static BoxDecoration reportPanelDecorationForBiasLabel(String biasLabel) {
    return reportPanelDecorationForBias(
      directionBiasFromReportLabel(biasLabel),
    );
  }

  /// Couleurs du bouton « Rapport » (sidebar, pied de page mobile) : achat / vente / à surveiller.
  static (Color background, Color foreground) reportPrimaryButtonColorsForBias(
    AnalyseDirectionBias bias,
  ) {
    return switch (bias) {
      AnalyseDirectionBias.achat => (accentGreen, const Color(0xFF0A0F0C)),
      AnalyseDirectionBias.vente => (accentRed, Colors.white),
      AnalyseDirectionBias.surveiller =>
        (accentAmber, const Color(0xFF1A1406)),
    };
  }

  static const radiusCard = 16.0;
  static const radiusChip = 12.0;
  static const radiusField = 8.0;

  static const pageBackdropDecoration = BoxDecoration(color: bg);

  static List<BoxShadow> get oledCardShadow => const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get nightCardShadow => oledCardShadow;

  static BoxDecoration get headerDecoration => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: cardBorder),
        boxShadow: oledCardShadow,
      );

  static BoxDecoration get funnelColumnDecoration => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: cardBorder),
        boxShadow: oledCardShadow,
      );

  /// Fond carte étape (bordure uniforme — la barre d’accent est ajoutée dans [AnalyseOledStepShell]).
  static BoxDecoration oledStepDecoration() => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: cardBorder),
        boxShadow: oledCardShadow,
      );

  static BoxDecoration get fieldDecoration => BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      );

  static BoxDecoration get fieldDecorationDeep => BoxDecoration(
        color: inputBgDeep,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cardBorder),
      );

  /// Champs en lecture seule dans le rapport OLED (pas de bordure).
  static BoxDecoration get reportFieldDecoration => BoxDecoration(
        color: inputBgDeep,
        borderRadius: BorderRadius.circular(6),
      );

  static InputDecoration fieldInputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: slate500,
        ),
        filled: true,
        fillColor: fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusField),
          borderSide: const BorderSide(color: slate800Border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusField),
          borderSide: const BorderSide(color: slate800Border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusField),
          borderSide: BorderSide(color: blue500.withValues(alpha: 0.5)),
        ),
      );

  static TextStyle get kickerBlueStyle => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: zinc400,
      );

  static TextStyle get oledSectionLabel => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: zinc400,
      );

  static TextStyle get oledMicroLabel => GoogleFonts.plusJakartaSans(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: zinc400,
      );

  /// Libellés champs OB / FVG / Liquidité / Fibonacci (panneau SMC OLED).
  static TextStyle get oledSmcFieldLabel => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: zinc500,
      );

  static TextStyle get inputValueStyle => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      );

  static TextStyle get inputBodyStyle => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get sectionLabelStyle => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: slate400,
      );

  static const sectionTitleStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: slate200,
    letterSpacing: 0.2,
  );

  static const labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: slate400,
  );

  /// Libellés POC / VAH (section Profil de volume) — gris froid (évite le ton or / ambre du rapport).
  static const volumeProfileLabelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: Color(0xFF8A93A0),
  );

  /// Même rendu que la ligne date / libellés « ACTIF » (petit gris).
  static const inlineMutedStyle = TextStyle(
    color: muted,
    fontWeight: FontWeight.w600,
    fontSize: 10,
    letterSpacing: 0.15,
  );

  static const inputTextStyle = TextStyle(
    fontSize: 13,
    color: matteText,
    fontWeight: FontWeight.w600,
  );

  /// Rouge (0 %) → ambre (50 %) → vert (100 %) — curseurs « Niveau de confiance » / jauge.
  static Color confidenceColorForPercent(int p) {
    final x = p.clamp(0, 100).toDouble();
    if (x <= 50) {
      return Color.lerp(accentRed, accentAmber, x / 50)!;
    }
    return Color.lerp(accentAmber, accentGreen, (x - 50) / 50)!;
  }
}

/// Sections du formulaire Analyse : repère visuel (fond / bordure / accent).
enum AnalyseEditorSection {
  feuillePlan,
  structure,
  indicateurs,
  smcLiquidite,
  profilVolume,
}

extension AnalyseEditorSectionChrome on AnalyseEditorSection {
  Color get sectionCardBg => AnalyseTokens.cardBg;
  Color get sectionCardBorder => AnalyseTokens.cardBorder;
  Color get sectionAccent => switch (this) {
        AnalyseEditorSection.feuillePlan => AnalyseTokens.oledBlue,
        AnalyseEditorSection.structure => AnalyseTokens.oledIndigo,
        AnalyseEditorSection.indicateurs => AnalyseTokens.oledGreen,
        AnalyseEditorSection.smcLiquidite => AnalyseTokens.oledIndigo,
        AnalyseEditorSection.profilVolume => AnalyseTokens.zinc300,
      };
}

