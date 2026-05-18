import '../l10n/app_localizations.dart';
import 'mental_state_controller.dart';

/// Applies translated default labels for known metric/emotion ids (user-renamed rows keep custom text until locale changes).
void applyMentalStateDefaultLabelsFromL10n(
  AppLocalizations l,
  MentalStateController c,
) {
  for (final m in c.factors) {
    final s = _routineFactorLabel(l, m.id);
    if (s != null) m.label = s;
  }
  for (final m in c.moment) {
    final s = _momentMetricLabel(l, m.id);
    if (s != null) m.label = s;
  }
  for (final e in c.emotions) {
    final s = _defaultEmotionLabel(l, e.id);
    if (s != null) e.label = s;
  }
}

String mentalStateMetricDisplayLabel(
  AppLocalizations l,
  String id,
  String stored,
) {
  final t = stored.trim();
  final localized =
      _routineFactorLabel(l, id) ?? _momentMetricLabel(l, id);
  if (t.isNotEmpty && (localized == null || t != localized)) return t;
  if (localized != null) return localized;
  return t.isEmpty ? id : t;
}

String mentalStateEmotionDisplayLabel(
  AppLocalizations l,
  String id,
  String stored,
) {
  final t = stored.trim();
  final localized = _defaultEmotionLabel(l, id);
  if (t.isNotEmpty && (localized == null || t != localized)) return t;
  if (localized != null) return localized;
  return t.isEmpty ? id : t;
}

String? _routineFactorLabel(AppLocalizations l, String id) {
  switch (id) {
    case 'meditation':
      return l.mentalMeditation;
    case 'sport_jogging':
      return l.mentalSport;
    default:
      return null;
  }
}

String? _momentMetricLabel(AppLocalizations l, String id) {
  switch (id) {
    case 'focus':
      return l.mentalFocus;
    case 'confidence':
      return l.mentalConfidence;
    case 'risk':
      return l.mentalRiskAppetite;
    case 'energy':
      return l.mentalEnergy;
    case 'study':
      return l.mentalMarketStudy;
    case 'emotion':
      return l.mentalEmotional;
    default:
      return null;
  }
}

String? _defaultEmotionLabel(AppLocalizations l, String id) {
  switch (id) {
    case 'e1':
      return l.mentalExcited;
    case 'e2':
      return l.mentalHappy;
    case 'e3':
      return l.mentalNeutral;
    case 'e4':
      return l.mentalBad;
    case 'e5':
      return l.mentalFrustrated;
    default:
      return null;
  }
}
