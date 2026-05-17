import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../gestion_risque_edit_notifier.dart';
import '../strategie_feedback_reference.dart';
import '../strategie_horaires_sessions_storage.dart';
import '../strategie_firestore_sync.dart';
import '../strategie_realtime_notifier.dart';
import '../strategie_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/strategie_section_frame.dart';
import 'strategie_horaires_new_session_dialog.dart';
import 'strategie_horaires_sessions_section_menu.dart';

class _SessionItem {
  const _SessionItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.titleColor,
    required this.timeColor,
    this.startTime,
    this.endTime,
    this.isNoTradeZone = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final Color titleColor;
  final Color timeColor;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isNoTradeZone;
}

/// Horaires & sessions.
/// Menu ⋮ : **Ajouter** (dialogue « Nouvelle session », même esprit crayon) / **Modifier** (crayon + poubelle).
/// **Ajouter** active le mode édition si besoin (crayons visibles au retour).
/// Modifier : 1er tap = mode édition ; 2e tap = annuler ; validation = tap hors lignes / ⋮.
class StrategieHorairesSessionsSection extends StatefulWidget {
  const StrategieHorairesSessionsSection({
    super.key,
    required this.editNotifier,
  });

  final GestionRisqueEditNotifier editNotifier;

  @override
  State<StrategieHorairesSessionsSection> createState() =>
      _StrategieHorairesSessionsSectionState();
}

class _StrategieHorairesSessionsSectionState
    extends State<StrategieHorairesSessionsSection> {
  bool _editMode = false;

  final GlobalKey _menuKey = GlobalKey();

  late List<_SessionItem> _sessions;
  final List<GlobalKey> _sessionRowKeys = [];
  Locale? _localeSynced;

  List<_SessionItem> _defaultSessions(Locale locale) {
    final defaults = StrategieFeedbackReference.horairesSessions(locale);
    return [
      _SessionItem(
        icon: LucideIcons.sunrise,
        iconBg: const Color(0xFF0D2A22),
        iconColor: StrategieTokens.emerald,
        title: defaults[0].titre,
        subtitle: defaults[0].sousTitre,
        time: defaults[0].creneau,
        titleColor: Colors.white,
        timeColor: Colors.white,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 30),
      ),
      _SessionItem(
        icon: LucideIcons.sun,
        iconBg: const Color(0xFF0D2A22),
        iconColor: StrategieTokens.emerald,
        title: defaults[1].titre,
        subtitle: defaults[1].sousTitre,
        time: defaults[1].creneau,
        titleColor: Colors.white,
        timeColor: Colors.white,
        startTime: const TimeOfDay(hour: 14, minute: 30),
        endTime: const TimeOfDay(hour: 16, minute: 30),
      ),
      _SessionItem(
        icon: LucideIcons.moon,
        iconBg: const Color(0xFF2A1515),
        iconColor: const Color(0xFFE57373),
        title: defaults[2].titre,
        subtitle: defaults[2].sousTitre,
        time: defaults[2].creneau,
        titleColor: StrategieTokens.riskRed,
        timeColor: StrategieTokens.riskRed,
        startTime: const TimeOfDay(hour: 17, minute: 0),
        isNoTradeZone: true,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    final loc = WidgetsBinding.instance.platformDispatcher.locale;
    _sessions = _defaultSessions(loc);
    _syncSessionKeysLength();
    _loadPersistedSessions();
    StrategieRealtimeNotifier.tick.addListener(_onStrategieRemoteTick);
  }

  void _onStrategieRemoteTick() {
    unawaited(_loadPersistedSessions());
  }

  Future<void> _loadPersistedSessions() async {
    final list = await StrategieHorairesSessionsStorage.load();
    if (!mounted) return;
    final appLoc = Localizations.localeOf(context);
    setState(() {
      _sessions = list.map((p) => _persistedToSession(p, appLoc)).toList();
      _syncSessionKeysLength();
    });
  }

  _SessionItem _persistedToSession(StrategieSessionPersisted p, Locale locale) {
    final v = strategieSessionVisuals(p);
    final slot = StrategieFeedbackReference.horairesSessionSlotIndex(p.title);
    if (slot != null) {
      final d = StrategieFeedbackReference.horairesSessions(locale)[slot];
      final timeSlot =
          StrategieFeedbackReference.horairesSessionSlotForCreneau(p.timeDisplay);
      final timeStr = (timeSlot == slot) ? d.creneau : p.timeDisplay;
      return _SessionItem(
        icon: v.icon,
        iconBg: v.iconBg,
        iconColor: v.iconColor,
        title: d.titre,
        subtitle: d.sousTitre,
        time: timeStr,
        titleColor: v.titleColor,
        timeColor: v.timeColor,
        startTime: v.startTime,
        endTime: v.endTime,
        isNoTradeZone: p.isNoTradeZone,
      );
    }
    return _SessionItem(
      icon: v.icon,
      iconBg: v.iconBg,
      iconColor: v.iconColor,
      title: p.title,
      subtitle: p.subtitle,
      time: p.timeDisplay,
      titleColor: v.titleColor,
      timeColor: v.timeColor,
      startTime: v.startTime,
      endTime: v.endTime,
      isNoTradeZone: p.isNoTradeZone,
    );
  }

  _SessionItem _relocalizeIfDefault(_SessionItem s, Locale locale) {
    final slot = StrategieFeedbackReference.horairesSessionSlotIndex(s.title);
    if (slot == null) return s;
    final d = StrategieFeedbackReference.horairesSessions(locale)[slot];
    final timeSlot = StrategieFeedbackReference.horairesSessionSlotForCreneau(s.time);
    final timeStr = (timeSlot == slot) ? d.creneau : s.time;
    return _SessionItem(
      icon: s.icon,
      iconBg: s.iconBg,
      iconColor: s.iconColor,
      title: d.titre,
      subtitle: d.sousTitre,
      time: timeStr,
      titleColor: s.titleColor,
      timeColor: s.timeColor,
      startTime: s.startTime,
      endTime: s.endTime,
      isNoTradeZone: s.isNoTradeZone,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appLoc = Localizations.localeOf(context);
    if (_localeSynced?.languageCode == appLoc.languageCode) return;
    final prev = _localeSynced;
    _localeSynced = appLoc;
    if (prev == null) {
      final platformLoc = WidgetsBinding.instance.platformDispatcher.locale;
      if (platformLoc.languageCode != appLoc.languageCode) {
        setState(() {
          _sessions = _sessions.map((s) => _relocalizeIfDefault(s, appLoc)).toList();
        });
      }
      return;
    }
    setState(() {
      _sessions = _sessions.map((s) => _relocalizeIfDefault(s, appLoc)).toList();
    });
  }

  StrategieSessionPersisted _sessionToPersisted(_SessionItem item) {
    var st = item.startTime;
    var en = item.endTime;
    if (st == null && en == null) {
      final parsed = _tryParseTimeRange(item.time);
      st = parsed.$1;
      en = parsed.$2;
    }
    if (st == null) {
      return StrategieSessionPersisted(
        title: item.title,
        subtitle: item.subtitle,
        timeDisplay: item.time,
        startHour: 0,
        startMinute: 0,
        endHour: null,
        endMinute: null,
        isNoTradeZone: item.isNoTradeZone,
      );
    }
    return StrategieSessionPersisted(
      title: item.title,
      subtitle: item.subtitle,
      timeDisplay: item.time,
      startHour: st.hour,
      startMinute: st.minute,
      endHour: en?.hour,
      endMinute: en?.minute,
      isNoTradeZone: item.isNoTradeZone,
    );
  }

  void _persistSessions() {
    final list = _sessions.map(_sessionToPersisted).toList();
    unawaited(() async {
      await StrategieHorairesSessionsStorage.save(list);
      await StrategieFirestoreSync.pushIfSignedIn(sessionsOverride: list);
    }());
  }

  void _syncSessionKeysLength() {
    while (_sessionRowKeys.length < _sessions.length) {
      _sessionRowKeys.add(GlobalKey());
    }
    while (_sessionRowKeys.length > _sessions.length) {
      _sessionRowKeys.removeLast();
    }
  }

  @override
  void dispose() {
    StrategieRealtimeNotifier.tick.removeListener(_onStrategieRemoteTick);
    final n = widget.editNotifier;
    n.horairesEditing = false;
    n.horairesMenuKey = null;
    n.horairesExcludeKeys = [];
    n.onCommitHorairesOutside = null;
    n.onForceCloseHorairesEdit = null;
    super.dispose();
  }

  /// 1er appui : édition (crayons + poubelles). En édition : ré-appui = **annuler**.
  void _onMenuModify() {
    if (_editMode) {
      _cancelEdit();
    } else {
      _startEdit();
    }
  }

  void _startEdit() {
    widget.editNotifier.onForceCloseGestionRisqueEdit?.call();
    widget.editNotifier.onForceCloseSetupsEdit?.call();
    setState(() => _editMode = true);
  }

  void _commitEdit() {
    if (!_editMode || !mounted) return;
    setState(() => _editMode = false);
  }

  void _cancelEdit() {
    if (!_editMode || !mounted) return;
    setState(() => _editMode = false);
  }

  String _formatSessionTimeRange(TimeOfDay? start, TimeOfDay? end) {
    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (start == null && end == null) return '—';
    if (start != null && end != null) return '${fmt(start)} - ${fmt(end)}';
    if (start != null) return fmt(start);
    return fmt(end!);
  }

  /// Parse affichage existant si [startTime]/[endTime] absents (sessions anciennes).
  (TimeOfDay?, TimeOfDay?) _tryParseTimeRange(String t) {
    final s = t.trim();
    final range = RegExp(r'^(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})$');
    final m = range.firstMatch(s);
    if (m != null) {
      return (
        TimeOfDay(hour: int.parse(m[1]!), minute: int.parse(m[2]!)),
        TimeOfDay(hour: int.parse(m[3]!), minute: int.parse(m[4]!)),
      );
    }
    final apres = RegExp(
      r'(?:Après|Apres|After)\s+(\d{1,2}):(\d{2})',
      caseSensitive: false,
    );
    final m2 = apres.firstMatch(s);
    if (m2 != null) {
      return (TimeOfDay(hour: int.parse(m2[1]!), minute: int.parse(m2[2]!)), null);
    }
    return (null, null);
  }

  StrategieNewSessionDialogInitial _initialFromSession(_SessionItem item) {
    var start = item.startTime;
    var end = item.endTime;
    if (start == null && end == null) {
      final p = _tryParseTimeRange(item.time);
      start = p.$1;
      end = p.$2;
    }
    return StrategieNewSessionDialogInitial(
      title: item.title,
      description: item.subtitle,
      startTime: start,
      endTime: end,
      isNoTradeZone: item.isNoTradeZone,
    );
  }

  _SessionItem _sessionItemFromResult(
    StrategieNewSessionDialogResult r, {
    IconData? preferredTradeIcon,
  }) {
    final noTrade = r.isNoTradeZone;
    return _SessionItem(
      icon: noTrade ? LucideIcons.moon : (preferredTradeIcon ?? LucideIcons.sunrise),
      iconBg: noTrade ? const Color(0xFF2A1515) : const Color(0xFF0D2A22),
      iconColor: noTrade ? const Color(0xFFE57373) : StrategieTokens.emerald,
      title: r.title,
      subtitle: r.description,
      time: _formatSessionTimeRange(r.startTime, r.endTime),
      titleColor: noTrade ? StrategieTokens.riskRed : Colors.white,
      timeColor: noTrade ? StrategieTokens.riskRed : Colors.white,
      startTime: r.startTime,
      endTime: r.endTime,
      isNoTradeZone: noTrade,
    );
  }

  Future<void> _openSessionDialog({int? editIndex}) async {
    final initial =
        editIndex != null ? _initialFromSession(_sessions[editIndex]) : null;
    final r = await showStrategieNewSessionDialog(context, initial: initial);
    if (!mounted || r == null) return;
    setState(() {
      final prev = editIndex != null ? _sessions[editIndex] : null;
      final preserveIcon = prev != null && !prev.isNoTradeZone ? prev.icon : null;
      final item = _sessionItemFromResult(r, preferredTradeIcon: preserveIcon);
      if (editIndex != null) {
        _sessions[editIndex] = item;
      } else {
        _sessions.add(item);
      }
    });
    _persistSessions();
  }

  Future<void> _onMenuAdd() async {
    widget.editNotifier.onForceCloseGestionRisqueEdit?.call();
    widget.editNotifier.onForceCloseSetupsEdit?.call();
    if (!mounted) return;
    if (!_editMode) {
      setState(() => _editMode = true);
    }
    await _openSessionDialog(editIndex: null);
  }

  void _removeSessionAt(int index) {
    setState(() {
      _sessions.removeAt(index);
      _sessionRowKeys.removeAt(index);
    });
    _persistSessions();
  }

  void _syncHorairesNotifier() {
    final n = widget.editNotifier;
    n.horairesEditing = _editMode;
    n.horairesMenuKey = _menuKey;
    n.horairesExcludeKeys = [..._sessionRowKeys];
    n.onCommitHorairesOutside = _commitEdit;
    n.onForceCloseHorairesEdit = _cancelEdit;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    _syncSessionKeysLength();
    _syncHorairesNotifier();
    return StrategieSectionFrame(
      backgroundColor: StrategieTokens.mesReglesSectionCardBg,
      leadingIcon: LucideIcons.clock,
      title: l.ajouterTradeStrategieHoursSessions,
      titleColor: StrategieTokens.titleGrey,
      trailingMenu: KeyedSubtree(
        key: _menuKey,
        child: buildStrategieHorairesSessionsPopupMenu(
          onAdd: _onMenuAdd,
          onModify: _onMenuModify,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _sessions.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _SessionRow(
              key: _sessionRowKeys[i],
              icon: _sessions[i].icon,
              iconBg: _sessions[i].iconBg,
              iconColor: _sessions[i].iconColor,
              title: _sessions[i].title,
              subtitle: _sessions[i].subtitle,
              time: _sessions[i].time,
              titleColor: _sessions[i].titleColor,
              timeColor: _sessions[i].timeColor,
              editMode: _editMode,
              onEditRow: _editMode ? () => _openSessionDialog(editIndex: i) : null,
              onDeleteRow: _editMode ? () => _removeSessionAt(i) : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.titleColor,
    required this.timeColor,
    required this.editMode,
    this.onEditRow,
    this.onDeleteRow,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final Color titleColor;
  final Color timeColor;
  final bool editMode;
  final VoidCallback? onEditRow;
  final VoidCallback? onDeleteRow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StrategieTokens.rowBg,
        borderRadius: BorderRadius.circular(StrategieTokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(StrategieTokens.radiusSm),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: StrategieTokens.labelMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 132),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: timeColor,
                  ),
                ),
                if (editMode && (onEditRow != null || onDeleteRow != null)) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (onEditRow != null)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                          tooltip: l.checklistMenuEdit,
                          icon: Icon(
                            LucideIcons.pencil,
                            size: 16,
                            color: StrategieTokens.labelMuted,
                          ),
                          onPressed: onEditRow,
                        ),
                      if (onDeleteRow != null)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: StrategieTokens.riskRed,
                          ),
                          onPressed: onDeleteRow,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
