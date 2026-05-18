import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reglage/paychek_prefs_scope.dart';
import '../l10n/app_localizations.dart';
import 'mental_state_day_breakdown.dart';
import 'mental_state_date_utils.dart';
import 'mental_state_localized_labels.dart';
import 'mental_state_models.dart';
import 'mental_state_share_logic.dart';
import 'mental_state_storage.dart';

/// État partagé entre [MentalStatePage] et le cercle EM du Dashboard.
class MentalStateController extends ChangeNotifier {
  MentalStateController._() {
    _resetToDefaults();
    _scheduleMidnightCalendarTimer();
  }

  static final MentalStateController instance = MentalStateController._();

  late double sleepValue;
  late double sleepWeight;
  bool sleepInverse = false;
  late double routinesGlobalWeight;
  late double momentBlockWeight;
  late List<MentalStateMetric> factors;
  late List<MentalStateMetric> moment;
  late List<MentalStateEmotion> emotions;
  /// Tags sélectionnés (multi-sélection) pour la carte Émotions.
  final Set<String> selectedEmotionIds = <String>{};

  bool factorsShare100 = false;
  bool momentShare100 = true;
  bool emotionsShare100 = true;

  late double emotionBlockWeight;

  /// Locale tag for which [ensureLocalizedLabels] last applied default strings.
  String? _localizedLabelsLocaleTag;

  static const _kPrefFactorsShareBase = 'mental_state_factors_share100';
  static const _kPrefMomentShareBase = 'mental_state_moment_share100';
  static const _kPrefEmotionsShareBase = 'mental_state_emotions_share100';
  /// Ancienne clé (sommeil seul) — supprimée au prochain enregistrement.
  static const _kPrefSleepByDayLegacyBase = 'mental_state_sleep_by_day_v1';
  static const _kCalendarOverallByDayBase =
      'mental_state_calendar_overall_by_day_v2';
  static const _kPrefMentalDayStartMinutesBase =
      'mental_state_calendar_day_start_minutes_v1';
  static const _kPrefMentalDayEndMinutesBase =
      'mental_state_calendar_day_end_minutes_v1';

  static String get _kPrefFactorsShare =>
      paychekScopedPrefsKey(_kPrefFactorsShareBase);
  static String get _kPrefMomentShare =>
      paychekScopedPrefsKey(_kPrefMomentShareBase);
  static String get _kPrefEmotionsShare =>
      paychekScopedPrefsKey(_kPrefEmotionsShareBase);
  static String get _kPrefSleepByDayLegacy =>
      paychekScopedPrefsKey(_kPrefSleepByDayLegacyBase);
  static String get _kCalendarOverallByDay =>
      paychekScopedPrefsKey(_kCalendarOverallByDayBase);
  static String get _kPrefMentalDayStartMinutes =>
      paychekScopedPrefsKey(_kPrefMentalDayStartMinutesBase);
  static String get _kPrefMentalDayEndMinutes =>
      paychekScopedPrefsKey(_kPrefMentalDayEndMinutesBase);

  /// `yyyy-MM-dd` → score global (anneau) pour la période d’ancrage (voir [MentalStateDateUtils.scoringWindowForAnchor]).
  final Map<String, double> _overallScoreByDay = {};
  /// `yyyy-MM-dd` → snapshot complet (curseurs/poids/listes) pour pouvoir consulter l’historique au tap.
  final Map<String, Map<String, dynamic>> _snapshotByDay = {};
  /// `yyyy-MM-dd` → jour explicitement modifié par l’utilisateur (sinon affichage `—` dans le calendrier).
  final Set<String> _touchedDays = <String>{};

  Timer? _persistCalendarDebounce;

  /// Minuteur : à chaque fin de période ([we]), enregistrement du snapshot.
  Timer? _midnightCalendarTimer;

  /// Début de la plage score ([_mentalDayEnd] définit la fin — voir [MentalStateDateUtils]).
  TimeOfDay _mentalDayStart = MentalStateDateUtils.kDefaultDayStart;

  /// Fin de la plage score (persistée). Par défaut 23:59 = journée civile 00:00–23:59.
  TimeOfDay _mentalDayEnd = MentalStateDateUtils.kDefaultDayEnd;

  /// Dernier [sleepDayKey] de période score au premier plan — rattrapage si frontière manquée en arrière-plan.
  String? _lastForegroundMentalDayKey;

  static String sleepDayKey(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return '${x.year.toString().padLeft(4, '0')}-'
        '${x.month.toString().padLeft(2, '0')}-'
        '${x.day.toString().padLeft(2, '0')}';
  }

  void _resetToDefaults() {
    sleepValue = 80;
    sleepWeight = 34;
    routinesGlobalWeight = 16.5;
    momentBlockWeight = 16.5;
    sleepInverse = false;
    emotionBlockWeight = 33;
    factors = [
      MentalStateMetric(
        id: 'meditation',
        label: 'Méditation (10 min)',
        value: 100,
        weight: 0,
        inverse: false,
        barColor: kMentalStateRingGreen,
        isMainSlider: true,
      ),
      MentalStateMetric(
        id: 'sport_jogging',
        label: 'Sport / Jogging',
        value: 35,
        weight: 0,
        inverse: false,
        barColor: kMentalStateRingGreen,
        isMainSlider: true,
      ),
    ];
    MentalStateShareLogic.equalizeFactorWeights(factors);
    const nm = 6.0;
    final shareM = 100.0 / nm;
    moment = [
      MentalStateMetric(id: 'focus', label: 'Focus', value: 70, weight: shareM, inverse: false, barColor: kMentalStateRingGreen),
      MentalStateMetric(id: 'confidence', label: 'Confiance', value: 60, weight: shareM, inverse: false, barColor: kMentalStateRingGreen),
      MentalStateMetric(id: 'risk', label: 'Peur', value: 50, weight: shareM, inverse: true, barColor: kMentalStateMatteRed),
      MentalStateMetric(id: 'energy', label: 'Énergie', value: 75, weight: shareM, inverse: false, barColor: kMentalStateRingGreen),
      MentalStateMetric(id: 'study', label: 'Étude marché', value: 90, weight: shareM, inverse: false, barColor: kMentalStateRingGreen),
      MentalStateMetric(id: 'emotion', label: 'Émotionnel', value: 30, weight: shareM, inverse: true, barColor: kMentalStateMatteRed),
    ];
    MentalStateShareLogic.fixMomentSumOnIndex(moment, moment.length - 1);
    emotions = [
      MentalStateEmotion(id: 'e1', label: 'Excité(e)', value: 100, weight: 20, inverse: false),
      MentalStateEmotion(id: 'e2', label: 'Content(e)', value: 80, weight: 20, inverse: false),
      MentalStateEmotion(id: 'e3', label: 'Neutre', value: 50, weight: 20, inverse: false),
      MentalStateEmotion(id: 'e4', label: 'Mauvais', value: 20, weight: 20, inverse: false),
      MentalStateEmotion(id: 'e5', label: 'Frustré(e)', value: 0, weight: 20, inverse: false),
    ];
    MentalStateShareLogic.fixSum100Emotions(emotions);
    selectedEmotionIds
      ..clear()
      ..addAll(emotions.take(1).map((e) => e.id));
    _localizedLabelsLocaleTag = null;
    _overallScoreByDay.clear();
    _mentalDayStart = MentalStateDateUtils.kDefaultDayStart;
    _mentalDayEnd = MentalStateDateUtils.kDefaultDayEnd;
  }

  /// Réinitialise les curseurs / listes comme au premier lancement (données locales effacées).
  void resetToFactoryDefaults() {
    _midnightCalendarTimer?.cancel();
    _midnightCalendarTimer = null;
    _lastForegroundMentalDayKey = null;
    _resetToDefaults();
    notifyListeners();
    SharedPreferences.getInstance().then((p) async {
      await p.remove(_kPrefSleepByDayLegacy);
      await p.remove(_kCalendarOverallByDay);
      await p.remove(_kPrefMentalDayStartMinutes);
      await p.remove(_kPrefMentalDayEndMinutes);
    });
    _scheduleMidnightCalendarTimer();
  }

  void touch() {
    _markTodayTouched();
    notifyListeners();
  }

  void _markTodayTouched() {
    final k = _currentMentalDayKey();
    _touchedDays.add(k);
    _overallScoreByDay[k] = overallScore;
    _snapshotByDay[k] = _currentDaySnapshot();
  }

  /// Score global affiché dans le mini-calendrier : identique à l’anneau pour la **période en cours** ; historique sinon.
  ///
  /// Chaque période score est figée dans [_overallScoreByDay] à la frontière ([_finalizeMentalDayAtBoundary])
  /// et mise à jour en continu ([_snapshotTodayOverallForCalendar]).
  double? overallScoreForCalendarDay(DateTime day) {
    final d = MentalStateDateUtils.dateOnly(day);
    final now = DateTime.now();
    final calendarToday = MentalStateDateUtils.dateOnly(now);
    if (d.isAfter(calendarToday)) return null;

    final inside = MentalStateDateUtils.anchorDateContaining(
      now,
      _mentalDayStart,
      _mentalDayEnd,
    );
    final liveAnchor = inside ??
        MentalStateDateUtils.anchorDateForScoringKeyWhenGapped(
          now,
          _mentalDayStart,
          _mentalDayEnd,
        );
    final liveAnchorDate = MentalStateDateUtils.dateOnly(liveAnchor);

    if (MentalStateDateUtils.isSameDate(d, liveAnchorDate)) {
      final k = sleepDayKey(d);
      return _touchedDays.contains(k) ? overallScore : null;
    }
    final k = sleepDayKey(d);
    return _touchedDays.contains(k) ? _overallScoreByDay[k] : null;
  }

  /// Heure de début de la plage score (affichage + persistance).
  TimeOfDay get mentalDayStart => _mentalDayStart;

  /// Heure de fin de la plage score (affichage + persistance).
  TimeOfDay get mentalDayEnd => _mentalDayEnd;

  /// Libellé court « HH:mm–HH:mm » pour la plage [mentalDayStart]–[mentalDayEnd].
  String mentalDayWindowLabel() {
    return '${mentalDayStartTimeLabel()}–${mentalDayEndTimeLabel()}';
  }

  /// Heure de début de la plage (HH:mm).
  String mentalDayStartTimeLabel() {
    final s = _mentalDayStart;
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${p2(s.hour)}:${p2(s.minute)}';
  }

  /// Heure de fin affichée (HH:mm) — correspond à [mentalDayEnd].
  String mentalDayEndTimeLabel() {
    final e = _mentalDayEnd;
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${p2(e.hour)}:${p2(e.minute)}';
  }

  String _currentMentalDayKey() {
    final now = DateTime.now();
    final inside = MentalStateDateUtils.anchorDateContaining(
      now,
      _mentalDayStart,
      _mentalDayEnd,
    );
    if (inside != null) {
      return sleepDayKey(inside);
    }
    final gapped = MentalStateDateUtils.anchorDateForScoringKeyWhenGapped(
      now,
      _mentalDayStart,
      _mentalDayEnd,
    );
    return sleepDayKey(gapped);
  }

  Future<void> setMentalDayWindow({
    required TimeOfDay start,
    required TimeOfDay end,
  }) async {
    final sa = TimeOfDay(
      hour: start.hour.clamp(0, 23),
      minute: start.minute.clamp(0, 59),
    );
    final ea = TimeOfDay(
      hour: end.hour.clamp(0, 23),
      minute: end.minute.clamp(0, 59),
    );
    if (sa.hour == _mentalDayStart.hour &&
        sa.minute == _mentalDayStart.minute &&
        ea.hour == _mentalDayEnd.hour &&
        ea.minute == _mentalDayEnd.minute) {
      return;
    }
    _mentalDayStart = sa;
    _mentalDayEnd = ea;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kPrefMentalDayStartMinutes, sa.hour * 60 + sa.minute);
    await p.setInt(_kPrefMentalDayEndMinutes, ea.hour * 60 + ea.minute);
    _lastForegroundMentalDayKey = _currentMentalDayKey();
    _scheduleMidnightCalendarTimer();
    notifyListeners();
  }

  void _snapshotTodayOverallForCalendar() {
    // Ne pas remplir le calendrier tant que l’utilisateur n’a pas interagi aujourd’hui.
    // L’historique ne contient que les jours explicitement modifiés.
    final k = _currentMentalDayKey();
    if (_touchedDays.contains(k)) {
      _overallScoreByDay[k] = overallScore;
      _snapshotByDay[k] = _currentDaySnapshot();
    }
  }

  Map<String, dynamic> _currentDaySnapshot() {
    final b = toCloudBundle();
    b.remove('calendarOverallByDay');
    b.remove('dailySnapshots');
    return b;
  }

  Map<String, dynamic>? snapshotForCalendarDay(DateTime day) {
    final d = MentalStateDateUtils.dateOnly(day);
    final key = sleepDayKey(d);
    if (!_touchedDays.contains(key)) return null;
    return _snapshotByDay[key];
  }

  /// Critères et pourcentages du jour (snapshot + score global du calendrier).
  MentalStateDayBreakdown? dayBreakdownFor(DateTime day, AppLocalizations l) {
    final score = overallScoreForCalendarDay(day);
    if (score == null) return null;
    final snap = snapshotForCalendarDay(day);
    if (snap == null) return null;
    return MentalStateDayBreakdown.fromSnapshot(snap, l, score.round());
  }

  /// Rattrapage v1 / données partielles : scores ou snapshots sans liste `touched`.
  void _reconcileTouchedDaysFromScores() {
    if (_touchedDays.isNotEmpty) return;
    _touchedDays.addAll(_overallScoreByDay.keys);
    _touchedDays.addAll(_snapshotByDay.keys);
  }

  /// Fusionne le JSON calendrier dédié (prefs) sans effacer l’état déjà chargé.
  void _mergeCalendarPrefsFromRaw(String? raw) {
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final m = Map<String, dynamic>.from(decoded);
      if (m['v'] == 2 || m.containsKey('scores')) {
        final scores = m['scores'];
        if (scores is Map) {
          for (final e in scores.entries) {
            final v = e.value;
            if (v is num) {
              _overallScoreByDay[e.key.toString()] = v.toDouble();
            }
          }
        }
        final touched = m['touched'];
        if (touched is List) {
          for (final e in touched) {
            final k = e.toString().trim();
            if (k.isNotEmpty) _touchedDays.add(k);
          }
        }
        return;
      }
      for (final e in m.entries) {
        final v = e.value;
        if (v is num) {
          _overallScoreByDay[e.key.toString()] = v.toDouble();
        }
      }
    } catch (_) {}
  }

  Future<void> _persistOverallScoresByDay() async {
    try {
      final p = await SharedPreferences.getInstance();
      final trimmed = _trimDayScoreMap(Map<String, double>.from(_overallScoreByDay));
      final payload = <String, dynamic>{
        'v': 2,
        'scores': trimmed,
        'touched': _touchedDays.toList()..sort(),
      };
      await p.setString(_kCalendarOverallByDay, jsonEncode(payload));
      await p.remove(_kPrefSleepByDayLegacy);
    } catch (_) {}
  }

  Map<String, double> _trimDayScoreMap(Map<String, double> m) {
    if (m.length <= 450) return m;
    final sortedKeys = m.keys.toList()..sort();
    for (var i = 0; i < sortedKeys.length - 450; i++) {
      m.remove(sortedKeys[i]);
    }
    return m;
  }

  Map<String, Map<String, dynamic>> _trimDaySnapshotMap(
    Map<String, Map<String, dynamic>> m,
  ) {
    if (m.length <= 450) return m;
    final sortedKeys = m.keys.toList()..sort();
    for (var i = 0; i < sortedKeys.length - 450; i++) {
      m.remove(sortedKeys[i]);
    }
    return m;
  }

  void _schedulePersistCalendar() {
    _persistCalendarDebounce?.cancel();
    _persistCalendarDebounce = Timer(const Duration(milliseconds: 500), () {
      _persistCalendarDebounce = null;
      _persistOverallScoresByDay();
      MentalStateStorage.saveBundleMap(toCloudBundle());
    });
  }

  void _scheduleMidnightCalendarTimer() {
    _midnightCalendarTimer?.cancel();
    final now = DateTime.now();
    final next = MentalStateDateUtils.nextScoringPeriodEndAfter(
      now,
      _mentalDayStart,
      _mentalDayEnd,
    );
    var dur = next.difference(now);
    if (dur.inMilliseconds <= 0) {
      dur = const Duration(milliseconds: 500);
    }
    _midnightCalendarTimer = Timer(dur, _finalizeMentalDayAtBoundary);
  }

  /// Frontière de période score : enregistre la période qui vient de se terminer ([we] exclus).
  void _finalizeMentalDayAtBoundary() {
    final now = DateTime.now();
    final ended = MentalStateDateUtils.anchorDateForPeriodEndedAt(
      now,
      _mentalDayStart,
      _mentalDayEnd,
    );
    if (ended != null) {
      final endedKey = sleepDayKey(ended);
      if (_touchedDays.contains(endedKey)) {
        _overallScoreByDay[endedKey] = overallScore;
        _snapshotByDay[endedKey] = _currentDaySnapshot();
      }
    }
    _snapshotTodayOverallForCalendar();
    super.notifyListeners();
    _schedulePersistCalendar();
    _scheduleMidnightCalendarTimer();
  }

  /// À rappeler au premier plan ([AppLifecycleState.resumed]) : replanifie la frontière et rattrape un changement de période.
  void onAppForegroundForCalendar() {
    final key = _currentMentalDayKey();
    if (_lastForegroundMentalDayKey != null &&
        _lastForegroundMentalDayKey != key) {
      // Ne pas réécrire la période passée avec les curseurs du jour courant.
      _snapshotTodayOverallForCalendar();
      super.notifyListeners();
      _schedulePersistCalendar();
    }
    _lastForegroundMentalDayKey = key;
    _scheduleMidnightCalendarTimer();
  }

  @override
  void notifyListeners() {
    _snapshotTodayOverallForCalendar();
    super.notifyListeners();
    _schedulePersistCalendar();
  }

  /// Syncs default metric/emotion labels from [AppLocalizations] when locale changes.
  void ensureLocalizedLabels(Locale locale, AppLocalizations l) {
    final tag = locale.toString();
    if (_localizedLabelsLocaleTag == tag) return;
    _localizedLabelsLocaleTag = tag;
    applyMentalStateDefaultLabelsFromL10n(l, this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasListeners) return;
      notifyListeners();
    });
  }

  /// Supprime tous les facteurs « routines » (dialogue de confirmation côté UI).
  void clearAllFactors() {
    factors.clear();
    touch();
  }

  Future<void> loadSharePreferences() async {
    final p = await SharedPreferences.getInstance();
    factorsShare100 = p.getBool(_kPrefFactorsShare) ?? false;
    momentShare100 = p.getBool(_kPrefMomentShare) ?? true;
    emotionsShare100 = p.getBool(_kPrefEmotionsShare) ?? true;
    final calendarRaw = p.getString(_kCalendarOverallByDay);
    _snapshotByDay.clear();
    _touchedDays.clear();
    _overallScoreByDay.clear();
    final mins = p.getInt(_kPrefMentalDayStartMinutes);
    if (mins != null && mins >= 0 && mins < 24 * 60) {
      _mentalDayStart = TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
    } else {
      _mentalDayStart = MentalStateDateUtils.kDefaultDayStart;
    }
    final endMins = p.getInt(_kPrefMentalDayEndMinutes);
    if (endMins != null && endMins >= 0 && endMins < 24 * 60) {
      _mentalDayEnd = TimeOfDay(hour: endMins ~/ 60, minute: endMins % 60);
    } else {
      _mentalDayEnd = MentalStateDateUtils.kDefaultDayEnd;
    }
    // Migration : ancien format 00:00–00:00 (24 h implicite) → 00:00–23:59.
    if (MentalStateDateUtils.isTwentyFourHourWindow(_mentalDayStart, _mentalDayEnd) &&
        _mentalDayEnd.hour == 0 &&
        _mentalDayEnd.minute == 0) {
      _mentalDayEnd = MentalStateDateUtils.kDefaultDayEnd;
      await p.setInt(
        _kPrefMentalDayEndMinutes,
        _mentalDayEnd.hour * 60 + _mentalDayEnd.minute,
      );
    }
    _lastForegroundMentalDayKey = _currentMentalDayKey();
    _scheduleMidnightCalendarTimer();
    await _loadFullBundleIfPresent();
    // Clé dédiée souvent plus à jour que `mental_state_bundle_v1` (écrite en parallèle).
    _mergeCalendarPrefsFromRaw(calendarRaw);
    _reconcileTouchedDaysFromScores();
    notifyListeners();
  }

  // (Backfill supprimé volontairement) : un jour reste vide tant que l’utilisateur
  // n’a pas interagi. Le calendrier reflète uniquement les jours « touchés ».

  void toggleEmotionSelected(String id) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return;
    if (selectedEmotionIds.contains(trimmed)) {
      selectedEmotionIds.remove(trimmed);
    } else {
      selectedEmotionIds.add(trimmed);
    }
    touch();
  }

  bool isEmotionSelected(String id) => selectedEmotionIds.contains(id);

  /// Émotions actuellement sélectionnées (ordre de la liste).
  List<MentalStateEmotion> get selectedEmotions => [
        for (final e in emotions)
          if (selectedEmotionIds.contains(e.id)) e,
      ];

  /// Part affichée sur la puce : poids libre, ou part parmi les sélectionnées (mode 100 %).
  int emotionChipImpactPercent(MentalStateEmotion e) =>
      MentalStateShareLogic.emotionChipImpactPercent(
        emotion: e,
        selectedIds: selectedEmotionIds,
        selected: selectedEmotions,
        share100: emotionsShare100,
      );

  Future<void> _loadFullBundleIfPresent() async {
    final m = await MentalStateStorage.loadBundleMap();
    if (m == null || m.isEmpty) return;
    await _applyBundleMap(m, persist: false);
  }

  Map<String, dynamic> toCloudBundle() {
    final cal = Map<String, double>.from(_overallScoreByDay);
    return MentalStateStorage.encodeBundle(
      sleepValue: sleepValue,
      sleepWeight: sleepWeight,
      sleepInverse: sleepInverse,
      routinesGlobalWeight: routinesGlobalWeight,
      momentBlockWeight: momentBlockWeight,
      emotionBlockWeight: emotionBlockWeight,
      factorsShare100: factorsShare100,
      momentShare100: momentShare100,
      emotionsShare100: emotionsShare100,
      factors: factors,
      moment: moment,
      emotions: emotions,
      selectedEmotionIds: selectedEmotionIds.toList(growable: false),
    )
      ..['calendarOverallByDay'] = cal
      ..['dailySnapshots'] = _trimDaySnapshotMap(
        Map<String, Map<String, dynamic>>.from(_snapshotByDay),
      )
      ..['touchedDays'] = _touchedDays.toList(growable: false);
  }

  Future<void> applyFromCloudBundle(Map<String, dynamic> bundle) async {
    await _applyBundleMap(bundle, persist: true);
  }

  Future<void> _applyBundleMap(
    Map<String, dynamic> bundle, {
    required bool persist,
  }) async {
    final preserveTouched = Set<String>.from(_touchedDays);
    final preserveScores = Map<String, double>.from(_overallScoreByDay);
    final preserveSnaps = <String, Map<String, dynamic>>{
      for (final e in _snapshotByDay.entries)
        e.key: Map<String, dynamic>.from(e.value),
    };

    final sv = (bundle['sleepValue'] as num?)?.toDouble();
    final sw = (bundle['sleepWeight'] as num?)?.toDouble();
    final sInv = bundle['sleepInverse'] as bool?;
    final rgw = (bundle['routinesGlobalWeight'] as num?)?.toDouble();
    final mbw = (bundle['momentBlockWeight'] as num?)?.toDouble();
    final ebw = (bundle['emotionBlockWeight'] as num?)?.toDouble();
    final f100 = bundle['factorsShare100'] as bool?;
    final m100 = bundle['momentShare100'] as bool?;
    final e100 = bundle['emotionsShare100'] as bool?;
    final selIds = bundle['selectedEmotionIds'];

    if (sv != null) sleepValue = sv.clamp(0, 100);
    if (sw != null) sleepWeight = sw.clamp(0, 100);
    if (sInv != null) sleepInverse = sInv;
    if (rgw != null) routinesGlobalWeight = rgw.clamp(0, 100);
    if (mbw != null) {
      momentBlockWeight = mbw.clamp(0, 100);
    } else if (!bundle.containsKey('momentBlockWeight')) {
      // Ancienne version : le poids « routines » couvrait facteurs + moment.
      final half = routinesGlobalWeight / 2;
      momentBlockWeight = half;
      routinesGlobalWeight = half;
    }
    if (ebw != null) emotionBlockWeight = ebw.clamp(0, 100);
    if (f100 != null) factorsShare100 = f100;
    if (m100 != null) momentShare100 = m100;
    if (e100 != null) emotionsShare100 = e100;
    selectedEmotionIds.clear();
    if (selIds is List) {
      for (final e in selIds) {
        final id = e.toString().trim();
        if (id.isNotEmpty) selectedEmotionIds.add(id);
      }
    } else {
      // Compat: anciennes versions (single index).
      final sei = (bundle['selectedEmotionIndex'] as num?)?.toInt();
      if (sei != null && sei >= 0 && sei < emotions.length) {
        selectedEmotionIds.add(emotions[sei].id);
      }
    }

    final rawF = bundle['factors'];
    if (rawF is List) {
      final out = <MentalStateMetric>[];
      for (final e in rawF) {
        final m = MentalStateStorage.decodeMetric(e);
        if (m != null) out.add(m);
      }
      if (out.isNotEmpty) factors = out;
    }
    final rawM = bundle['moment'];
    if (rawM is List) {
      final out = <MentalStateMetric>[];
      for (final e in rawM) {
        final m = MentalStateStorage.decodeMetric(e);
        if (m != null) out.add(m);
      }
      if (out.isNotEmpty) moment = out;
    }
    final rawE = bundle['emotions'];
    if (rawE is List) {
      final out = <MentalStateEmotion>[];
      for (final e in rawE) {
        final x = MentalStateStorage.decodeEmotion(e);
        if (x != null) out.add(x);
      }
      if (out.isNotEmpty) emotions = out;
    }

    // Nettoyage : retirer des sélections les ids absents.
    final existing = {for (final e in emotions) e.id};
    selectedEmotionIds.removeWhere((id) => !existing.contains(id));
    if (selectedEmotionIds.isEmpty && emotions.isNotEmpty) {
      selectedEmotionIds.add(emotions.first.id);
    }

    final rawCal = bundle['calendarOverallByDay'];
    if (rawCal is Map) {
      _overallScoreByDay.clear();
      for (final entry in rawCal.entries) {
        final k = entry.key.toString();
        final v = entry.value;
        if (v is num) _overallScoreByDay[k] = v.toDouble();
      }
    }

    final rawSnaps = bundle['dailySnapshots'];
    if (rawSnaps is Map) {
      _snapshotByDay.clear();
      for (final entry in rawSnaps.entries) {
        final k = entry.key.toString();
        final v = entry.value;
        if (v is Map) {
          _snapshotByDay[k] = Map<String, dynamic>.from(v);
        }
      }
    }

    final rawTouched = bundle['touchedDays'];
    _touchedDays.clear();
    if (rawTouched is List) {
      for (final e in rawTouched) {
        final k = e.toString().trim();
        if (k.isNotEmpty) _touchedDays.add(k);
      }
      if (_touchedDays.isEmpty && _overallScoreByDay.isNotEmpty) {
        _reconcileTouchedDaysFromScores();
      }
    } else {
      // Compat: anciennes versions → considérer les jours présents comme touchés.
      _touchedDays.addAll(_overallScoreByDay.keys);
    }

    // Ne pas perdre le mini-calendrier local si un bundle cloud/local est en retard.
    for (final k in preserveTouched) {
      _touchedDays.add(k);
      final s = preserveScores[k];
      if (s != null) _overallScoreByDay[k] = s;
      final snap = preserveSnaps[k];
      if (snap != null) _snapshotByDay[k] = snap;
    }
    _reconcileTouchedDaysFromScores();

    if (persist) {
      await MentalStateStorage.saveBundleMap(bundle);
      // On garde les prefs existantes (fenêtre de journée + share flags) déjà persistes,
      // mais on force un persist calendrier.
      _schedulePersistCalendar();
    }
    notifyListeners();
  }

  /// Met à jour le curseur sommeil ; [notifyListeners] enregistre aussi le score global du jour (mini-calendrier).
  void updateSleepValue(double v) {
    sleepValue = v.clamp(0, 100);
    touch();
  }

  Future<void> _saveSharePreference(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
  }

  Future<void> setFactorsShare100(bool v) async {
    if (v == factorsShare100) return;
    final snapSleep = sleepWeight;
    final snapRoutinesPillar = routinesGlobalWeight;
    final snapMomentPillar = momentBlockWeight;
    final snapEmotionPillar = emotionBlockWeight;
    factorsShare100 = v;
    if (v) {
      MentalStateShareLogic.normalizeFactorsTo100(factors);
    }
    sleepWeight = snapSleep;
    routinesGlobalWeight = snapRoutinesPillar;
    momentBlockWeight = snapMomentPillar;
    emotionBlockWeight = snapEmotionPillar;
    touch();
    await _saveSharePreference(_kPrefFactorsShare, factorsShare100);
  }

  Future<void> setMomentShare100(bool v) async {
    if (v == momentShare100) return;
    momentShare100 = v;
    if (v) {
      MentalStateShareLogic.normalizeMomentTo100(moment);
    }
    touch();
    await _saveSharePreference(_kPrefMomentShare, momentShare100);
  }

  Future<void> setEmotionsShare100(bool v) async {
    if (v == emotionsShare100) return;
    emotionsShare100 = v;
    if (v) {
      MentalStateShareLogic.normalizeEmotionsTo100(emotions);
    }
    touch();
    await _saveSharePreference(_kPrefEmotionsShare, emotionsShare100);
  }

  void setFactorShare(int index, double targetPercent) {
    MentalStateShareLogic.setFactorShare(factors, index, targetPercent);
  }

  void equalizeFactorWeights() {
    MentalStateShareLogic.equalizeFactorWeights(factors);
  }

  void setMomentShare(int index, double targetPercent) {
    MentalStateShareLogic.setMomentShare(moment, index, targetPercent);
  }

  void equalizeMomentWeights() {
    MentalStateShareLogic.equalizeMomentWeights(moment);
  }

  void _applyGlobalFour(List<double> w) {
    sleepWeight = w[0];
    routinesGlobalWeight = w[1];
    momentBlockWeight = w[2];
    emotionBlockWeight = w[3];
  }

  List<double> get _globalFourWeights => [
        sleepWeight,
        routinesGlobalWeight,
        momentBlockWeight,
        emotionBlockWeight,
      ];

  void setGlobalSleepShare(double targetPercent) {
    final w = List<double>.from(_globalFourWeights);
    MentalStateShareLogic.setGlobalFourShare(w, 0, targetPercent);
    _applyGlobalFour(w);
    touch();
  }

  void setGlobalRoutinesShare(double targetPercent) {
    final w = List<double>.from(_globalFourWeights);
    MentalStateShareLogic.setGlobalFourShare(w, 1, targetPercent);
    _applyGlobalFour(w);
    touch();
  }

  void setGlobalMomentShare(double targetPercent) {
    final w = List<double>.from(_globalFourWeights);
    MentalStateShareLogic.setGlobalFourShare(w, 2, targetPercent);
    _applyGlobalFour(w);
    touch();
  }

  void setGlobalEmotionShare(double targetPercent) {
    final w = List<double>.from(_globalFourWeights);
    MentalStateShareLogic.setGlobalFourShare(w, 3, targetPercent);
    _applyGlobalFour(w);
    touch();
  }

  void equalizeEmotionWeights() {
    if (emotionsShare100 && selectedEmotionIds.isNotEmpty) {
      MentalStateShareLogic.equalizeEmotionWeights(selectedEmotions);
    } else {
      MentalStateShareLogic.equalizeEmotionWeights(emotions);
    }
    touch();
  }

  void setEmotionShare(int index, double targetPercent) {
    if (emotionsShare100 &&
        index >= 0 &&
        index < emotions.length &&
        selectedEmotionIds.contains(emotions[index].id) &&
        selectedEmotionIds.isNotEmpty) {
      final sel = selectedEmotions;
      final idxInSel = sel.indexWhere((e) => e.id == emotions[index].id);
      if (idxInSel >= 0) {
        MentalStateShareLogic.setEmotionShareSingle(sel, idxInSel, targetPercent);
        touch();
        return;
      }
    }
    MentalStateShareLogic.setEmotionShareSingle(emotions, index, targetPercent);
    touch();
  }

  void addFactorWithShare(MentalStateMetric m, double targetPercent) {
    MentalStateShareLogic.addFactorWithShare(
      factors: factors,
      factorsShare100: factorsShare100,
      m: m,
      targetPercent: targetPercent,
    );
  }

  void addMomentWithShare(MentalStateMetric m, double targetPercent) {
    MentalStateShareLogic.addMomentWithShare(
      moment: moment,
      momentShare100: momentShare100,
      m: m,
      targetPercent: targetPercent,
    );
  }

  void addEmotionWithShare(MentalStateEmotion e, double targetPercent) {
    MentalStateShareLogic.addEmotionWithShare(
      emotions: emotions,
      emotionsShare100: emotionsShare100,
      e: e,
      targetPercent: targetPercent,
    );
  }

  double get globalFourTotal =>
      sleepWeight + routinesGlobalWeight + momentBlockWeight + emotionBlockWeight;

  double sumSlidersWeight() => globalFourTotal;

  double totalWeightSum() => globalFourTotal;

  int weightPercent(double w) => w.clamp(0, 100).round();

  int emotionFactorImpactPercent(MentalStateEmotion e) =>
      emotionChipImpactPercent(e);

  double get overallScore {
    double num = 0;
    double den = 0;
    final sleepNorm = sleepInverse ? (100 - sleepValue) : sleepValue;
    num += sleepNorm * sleepWeight;
    den += sleepWeight;

    double scoreFactors = 0;
    if (factors.isNotEmpty) {
      if (factorsShare100) {
        var numF = 0.0;
        var denF = 0.0;
        for (final f in factors) {
          numF += f.normalizedForScore() * f.weight;
          denF += f.weight;
        }
        scoreFactors = denF > 0 ? numF / denF : 0;
      } else {
        var s = 0.0;
        for (final f in factors) {
          s += (f.weight / 100.0) * f.normalizedForScore();
        }
        scoreFactors = s / factors.length;
      }
    }
    double scoreMoment = 0;
    if (moment.isNotEmpty) {
      if (momentShare100) {
        var numM = 0.0;
        var denM = 0.0;
        for (final m in moment) {
          numM += m.normalizedForScore() * m.weight;
          denM += m.weight;
        }
        scoreMoment = denM > 0 ? numM / denM : 0;
      } else {
        var s = 0.0;
        for (final m in moment) {
          s += (m.weight / 100.0) * m.normalizedForScore();
        }
        scoreMoment = s / moment.length;
      }
    }
    if (factors.isNotEmpty) {
      num += scoreFactors * routinesGlobalWeight;
      den += routinesGlobalWeight;
    }
    if (moment.isNotEmpty) {
      num += scoreMoment * momentBlockWeight;
      den += momentBlockWeight;
    }

    if (emotions.isNotEmpty && selectedEmotionIds.isNotEmpty) {
      final selected = emotions.where((e) => selectedEmotionIds.contains(e.id)).toList();
      if (selected.isNotEmpty) {
        final sumW = selected.fold<double>(0, (s, e) => s + e.weight.clamp(0, 100));
        for (final em in selected) {
          final w = em.weight.clamp(0, 100);
          final ew = sumW > 0 ? (emotionBlockWeight * (w / sumW)) : 0;
          num += em.normalizedForScore() * ew;
          den += ew;
        }
      }
    }
    if (den <= 0) return 0;
    return (num / den).clamp(0, 100);
  }

  double get overallProgressFraction => overallScore / 100.0;

  /// Sommeil + routines + métriques du moment + une entrée par émotion (pour le sous-titre jauge).
  int get indicatorCount {
    var n = 1 + factors.length + moment.length;
    if (emotions.isNotEmpty) {
      n += emotions.length;
    }
    return n;
  }
}
