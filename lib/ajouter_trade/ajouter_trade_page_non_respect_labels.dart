import 'dart:ui' show Locale;

import '../l10n/app_localizations.dart';
import '../strategie/strategie_feedback_reference.dart';
import '../strategie/strategie_mes_regles_storage.dart';
import '../strategie/strategie_setup_tag_labels.dart';
import '../strategie/widgets/strategie_setup_cards_content.dart';

/// Libellé lisible pour un id « non respect » — **élément** coché (tag / valeur),
/// jamais le sujet de section (titre TIMEFRAMES, ENTRÉE PRÉCISE, etc.).
String labelForStrategieNonRespectId(
  String id,
  String strategieChoisie, {
  required AppLocalizations l,
  required Locale locale,
}) {
  final regles = StrategieMesReglesStore.rulesForLocale(locale);

  if (id.startsWith('mes_regles_')) {
    final idx = int.tryParse(id.substring('mes_regles_'.length));
    if (idx != null && idx >= 0 && idx < regles.length) {
      return regles[idx];
    }
  }

  if (id.startsWith('gestion_risque_')) {
    final idx = int.tryParse(id.substring('gestion_risque_'.length));
    final gestion = StrategieFeedbackReference.gestionRisque(locale);
    if (idx != null && idx >= 0 && idx < gestion.length) {
      return _normalizeElementText(gestion[idx].valeur);
    }
  }

  if (id.startsWith('horaire_')) {
    final idx = int.tryParse(id.substring('horaire_'.length));
    final horaires = StrategieFeedbackReference.horairesSessions(locale);
    if (idx != null && idx >= 0 && idx < horaires.length) {
      return _horaireSessionElementLabel(horaires[idx]);
    }
  }

  if (id.startsWith('setup_')) {
    final setups = strategieSetupCardDataAllKnown();
    final preferred = strategieSetupCardDataPourTitre(strategieChoisie);
    if (preferred != null) {
      final label = labelForSetupNonRespectIdOnCard(id, preferred);
      if (label != null) return label;
    }
    for (final data in setups) {
      if (preferred != null &&
          strategieSetupTitleEquals(data.title, preferred.title)) {
        continue;
      }
      final label = labelForSetupNonRespectIdOnCard(id, data);
      if (label != null) return label;
    }
  }

  if (id.startsWith('setup_')) {
    return l.tradeStrategieNonRespectUnmapped(id);
  }

  return id;
}

String _normalizeElementText(String raw) =>
    raw.replaceAll(RegExp(r'\s+'), ' ').trim();

String _horaireSessionElementLabel(({String titre, String sousTitre, String creneau}) h) {
  final st = h.sousTitre.trim();
  final cr = h.creneau.trim();
  if (st.isNotEmpty && cr.isNotEmpty) return '$st ($cr)';
  if (cr.isNotEmpty) return cr;
  if (st.isNotEmpty) return st;
  return h.titre.trim();
}

