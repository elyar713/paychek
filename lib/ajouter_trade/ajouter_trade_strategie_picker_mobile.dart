import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import '../strategie/widgets/strategie_setup_card.dart';

/// Sélecteur stratégie — iOS / Android uniquement (pas le web).
bool ajouterTradeUseMobileStrategiePicker(BuildContext context) => !kIsWeb;

String _setupPickerSubtitle(StrategieSetupCardData setup) {
  final pattern = setup.pattern.trim();
  if (pattern.isNotEmpty && pattern != '—') return pattern;
  final signal = setup.signalText.trim();
  if (signal.isNotEmpty && signal != '—') return signal;
  final tf = setup.timeframes.trim();
  if (tf.isNotEmpty && tf != '—') return tf;
  return '';
}

Future<void> showAjouterTradeStrategiePickerSheet({
  required BuildContext context,
  required List<StrategieSetupCardData> setups,
  required String selectedTitle,
  required ValueChanged<String> onSelected,
}) {
  final l = AppLocalizations.of(context)!;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollController) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: DashboardTokens.cardBoxBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DashboardTokens.muted.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l.ajouterTradeStrategieSetupModels,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: DashboardTokens.onMatteEmphasis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l.ajouterTradeDisciplineStrategieSubtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: DashboardTokens.labelGrey,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: DashboardTokens.labelGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: setups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final setup = setups[i];
                      final selected = setup.title == selectedTitle;
                      return _StrategieSetupPickerTile(
                        setup: setup,
                        selected: selected,
                        onTap: () {
                          onSelected(setup.title);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Carte pleine largeur — contenu empilé, sans bandes latérales.
class AjouterTradeStrategiePickerField extends StatelessWidget {
  const AjouterTradeStrategiePickerField({
    super.key,
    required this.setups,
    required this.value,
    required this.onChanged,
  });

  final List<StrategieSetupCardData> setups;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (setups.isEmpty) return const SizedBox.shrink();

    final selected = setups.where((e) => e.title == value).toList();
    final setup = selected.isNotEmpty ? selected.first : setups.first;
    final subtitle = _setupPickerSubtitle(setup);
    final l = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showAjouterTradeStrategiePickerSheet(
          context: context,
          setups: setups,
          selectedTitle: value,
          onSelected: onChanged,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: DashboardTokens.scaffoldMatte,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: setup.dotColor.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.ajouterTradeDisciplineStrategieTitle.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: DashboardTokens.labelGrey,
                  ),
                ),
                const SizedBox(height: 10),
                _TitleWithDot(title: setup.title, color: setup.dotColor),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: DashboardTokens.labelGrey,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: DashboardTokens.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: DashboardTokens.accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    l.ajouterTradeDisciplineStrategieSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DashboardTokens.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StrategieSetupPickerTile extends StatelessWidget {
  const _StrategieSetupPickerTile({
    required this.setup,
    required this.selected,
    required this.onTap,
  });

  final StrategieSetupCardData setup;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = _setupPickerSubtitle(setup);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? DashboardTokens.accent.withValues(alpha: 0.1)
                : DashboardTokens.scaffoldMatte,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? DashboardTokens.accent
                  : DashboardTokens.cardBoxBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TitleWithDot(title: setup.title, color: setup.dotColor),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: DashboardTokens.labelGrey,
                      height: 1.35,
                    ),
                  ),
                ],
                if (setup.timeframes.trim().isNotEmpty &&
                    setup.timeframes != '—') ...[
                  const SizedBox(height: 10),
                  Text(
                    setup.timeframes,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DashboardTokens.labelGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleWithDot extends StatelessWidget {
  const _TitleWithDot({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DashboardTokens.onMatteEmphasis,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
