import 'package:flutter/material.dart';

import '../analyse/analyse_tokens.dart';

/// Checklist : palette OLED alignée sur [AnalyseTokens].
class ChecklistTokens {
  ChecklistTokens._();

  static const horizontalPadding = 18.0;
  /// Espace entre deux cartes de section (vertical).
  static const sectionGap = 10.0;

  /// Espace entre la dernière section et le bouton « Ajouter une section ».
  static const sectionToAddButtonGap = 16.0;

  /// Titre barre « Nouveau Trade » : blanc mat.
  static const pageTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Color(0xFFF2F2F2),
    height: 1.15,
  );

  /// Blanc **mat** (pas #FFF pur) — sous-titre sous l’en-tête.
  static const introStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF999999),
    height: 1.4,
  );

  /// Titres de section — même rendu que [AnalyseTokens.oledSectionLabel].
  static const sectionTitleOnCardStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.4,
    color: AnalyseTokens.zinc400,
    height: 1.2,
  );

  /// Lignes checklist : gris plus sombre.
  static const itemLabelOnCardStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFFB0B0B0),
    height: 1.35,
  );

  /// Ligne dont l'échéance est passée sans coche (hebdo / date précise).
  static const itemLabelExpiredStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF5C5C5C),
    height: 1.35,
  );

  static const cardBg = AnalyseTokens.cardBg;
  static const sectionCardBorder = AnalyseTokens.cardBorder;
  static const sectionCardBorderWidth = 1.0;

  static const dividerOnCard = AnalyseTokens.cardBorder;

  static const pillBg = AnalyseTokens.inputBg;
  static const pillText = Color(0xFFA8A8A8);

  static const cardRadius = 14.0;

  /// Case à cocher : décochée = gris ; cochée = **carré plein** blanc + coche foncée.
  static const checkboxBorderUnchecked = Color(0xFF8A8A8A);
  static const checkboxCheckedFill = Color(0xFFF2F2F2);
  static const checkboxCheckOnFill = Color(0xFF080808);

  /// Barré sur libellé coché : trait un peu plus **épais**.
  static const itemLabelStrikethroughThickness = 2.25;

  /// Padding interne des cartes (compact).
  static const sectionCardPadding = EdgeInsets.fromLTRB(12, 10, 4, 6);
  static const sectionHeaderToItemsGap = 4.0;

  /// Ligne checklist : padding vertical par item.
  static const itemRowVerticalPadding = 9.0;
  static const itemRowCheckGap = 10.0;

  /// Icône ⋯ : blanc cassé mat.
  static const sectionMenuIconColor = Color(0xFFB8B8B8);

  /// Résumé rappel personnalisé (hebdo / date précise) au-dessus d’une ligne.
  static const scheduleCustomSummary = Color(0xFF56B4FF);

  /// Espace vertical du résumé date (éloigné du séparateur, proche du libellé).
  static const scheduleSummaryPaddingTop = 8.0;
  static const scheduleSummaryPaddingBottom = 0.0;
  static const scheduleSummaryFontSize = 9.0;

  /// Menu ⋯ : coins arrondis, fond **légèrement** transparent (même base que [cardBg]).
  static const sectionPopupMenuRadius = 12.0;
  /// Alpha ~94 % (moins transparent qu’avant, ~0xE6).
  static const sectionPopupMenuBg = Color(0xF0080808);

  /// Padding des lignes du menu (moins d’espace à droite).
  static const sectionPopupMenuItemPadding =
      EdgeInsets.only(left: 10, right: 6, top: 8, bottom: 8);

  /// Textes du menu ⋯ : plus **petit** que les lignes checklist (14), gris foncé.
  static const sectionPopupMenuItemStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF8A8A8A),
    height: 1.25,
  );

  /// Bouton « Ajouter une section » : gris **léger**, lisible sur noir (fond page = noir, pas de plaque).
  static const addSectionStrokeColor = Color(0xCCB8C4CE);
  static const addSectionContentColor = Color(0xE0C8D2DA);

  static const addSectionTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: addSectionContentColor,
  );

  /// Anneau **global** (toute la checklist) : piste + arc rouge → vert.
  static const sectionProgressRingSize = 88.0;
  static const sectionProgressRingStroke = 4.5;
  static const sectionProgressRingTrack = Color(0xFF2E2E2E);
  static const sectionProgressRingRed = Color(0xFFE53935);
  static const sectionProgressRingGreen = Color(0xFF66BB6A);

  static const sectionProgressPercentStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xFFF2F2F2),
    height: 1.0,
  );

  /// Sous le pourcentage : « CL », gris un peu foncé.
  static const sectionProgressClStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: Color(0xFF7A7A7A),
    height: 1.0,
  );
}
