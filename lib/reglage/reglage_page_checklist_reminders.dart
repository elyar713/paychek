part of 'reglage_page.dart';

/// Interrupteur rappels locaux checklist (mobile iOS / Android uniquement).
class _ChecklistRemindersSection extends StatefulWidget {
  const _ChecklistRemindersSection();

  @override
  State<_ChecklistRemindersSection> createState() =>
      _ChecklistRemindersSectionState();
}

class _ChecklistRemindersSectionState extends State<_ChecklistRemindersSection> {
  bool? _enabled;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final v = await ChecklistNotificationPrefs.isEnabled();
    if (mounted) setState(() => _enabled = v);
  }

  Future<void> _onChanged(bool value) async {
    if (_busy) return;
    setState(() {
      _enabled = value;
      _busy = true;
    });
    try {
      final raw = await ChecklistSectionsStorage.load();
      final sections = raw == null || raw.isEmpty
          ? defaultNouveauTradeSections()
          : checklistEnsureProtectedSections(raw);
      await ChecklistNotificationService.onEnabledChanged(value, sections);
      if (!value) return;
      if (!mounted) return;
      final granted =
          await ChecklistNotificationService.requestPermissionsIfNeeded();
      if (!granted && mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.checklistScheduleNotificationHint,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final on = _enabled;
    if (on == null) return const SizedBox.shrink();

    return _ReglageSurface(
      compact: true,
      child: SwitchListTile.adaptive(
        value: on,
        onChanged: _busy ? null : _onChanged,
        activeThumbColor: DashboardTokens.accent,
        title: Text(
          l10n.settingsChecklistRemindersTitle,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: DashboardTokens.onMatteEmphasis,
          ),
        ),
        subtitle: Text(
          l10n.settingsChecklistRemindersSubtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            height: 1.35,
            color: DashboardTokens.muted,
          ),
        ),
      ),
    );
  }
}
