import 'package:flutter/material.dart';

import 'analyse_models.dart';

abstract final class AnalyseTokens {
  AnalyseTokens._();

  /// Ancienne colonne unique (mobile).
  static const pageMaxWidth = 420.0;

  /// Tableau de bord analyse : grille + panneau latéral.
  static const pageMaxWidthDashboard = 1180.0;

  /// [LayoutBuilder] : à partir de cette largeur, deux colonnes + sidebar.
  static const layoutBreakpointWide = 960.0;

  /// Grille Direction / Tendance | TF / Phase sur la feuille contexte.
  static const layoutBreakpointFeuilleGrid = 520.0;

  static const bg = Colors.black;
  /// Cartes / sections (plus sombre que le fond page pour le relief).
  static const cardBg = Color(0xFF070707);
  static const cardBorder = Color(0xFF1A1A1A);
  static const muted = Color(0xFF777777);
  static const muted2 = Color(0xFF555555);
  static const matteText = Color(0xFFE6E6E6);

  static const accentGreen = Color(0xFF2BD17E);
  static const accentAmber = Color(0xFFF3B23B);
  static const accentRed = Color(0xFFE84B4B);

  /// Puces « TIMEFRAME » (HTF) sélectionnées : **blanc**.
  static const chipHtfSelected = Color(0xFFFFFFFF);

  /// Puces « Phase actuelle du marché » sélectionnées : **bleu**.
  static const chipPhaseSelected = Color(0xFF4A9EFF);

  static const chipBg = Color(0xFF0A0A0A);
  static const fieldBg = Color(0xFF080808);
  /// Fond des blocs « Copie » contexte : un peu plus clair que [cardBg] pour les repérer vite.
  static const contexteDuplicateBg = Color(0xFF101010);
  /// Fond des blocs « Copie » structure : même principe que [contexteDuplicateBg].
  static const structureDuplicateBg = Color(0xFF101010);
  /// Fond des blocs « Copie » indicateurs : un peu plus clair que [fieldBg] / carte pour trancher avec l’original.
  static const indicatorsDuplicateBg = Color(0xFF141414);
  /// Fond des blocs « Copie » SMC (feuille + rapport) pour les repérer comme les autres duplicatas.
  static const smcDuplicateBg = Color(0xFF141414);

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

  static const radiusCard = 18.0;
  static const radiusChip = 14.0;
  static const radiusField = 14.0;

  static const sectionTitleStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: matteText,
    letterSpacing: 0.2,
  );

  static const labelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: muted,
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
  /// Fond de carte légèrement teinté.
  Color get sectionCardBg => switch (this) {
        AnalyseEditorSection.feuillePlan => const Color(0xFF0A1018),
        AnalyseEditorSection.structure => const Color(0xFF100E18),
        AnalyseEditorSection.indicateurs => const Color(0xFF0A1518),
        AnalyseEditorSection.smcLiquidite => const Color(0xFF100E14),
        AnalyseEditorSection.profilVolume => const Color(0xFF0F0F12),
      };

  Color get sectionCardBorder => switch (this) {
        AnalyseEditorSection.feuillePlan => const Color(0xFF1E3A55),
        AnalyseEditorSection.structure => const Color(0xFF3D2B6E),
        AnalyseEditorSection.indicateurs => const Color(0xFF1E4555),
        AnalyseEditorSection.smcLiquidite => const Color(0xFF3D3548),
        AnalyseEditorSection.profilVolume => const Color(0xFF323238),
      };

  /// Icône de titre + libellé « FEUILLE DE PLAN » (pas de vert / ambre : même famille que le rapport validé).
  Color get sectionAccent => switch (this) {
        AnalyseEditorSection.feuillePlan => const Color(0xFF5E9FFF),
        AnalyseEditorSection.structure => const Color(0xFFB08CFF),
        AnalyseEditorSection.indicateurs => const Color(0xFF5EC0D4),
        AnalyseEditorSection.smcLiquidite => const Color(0xFF9B8CFF),
        AnalyseEditorSection.profilVolume => const Color(0xFF9BA3B0),
      };
}

