import '../calendrier/calendrier_utils.dart' as cal;
import '../trade/trade_models.dart';
import 'strategie_tokens.dart';
import 'widgets/strategie_calendrier_day_cell.dart';
import 'widgets/strategie_setup_cards_content.dart';

/// Points du calendrier : **trades** (stratégie + jour d’entrée) ∪ marques manuelles [usageByTitle].
List<StrategieCalendrierDayMark> buildStrategieCalendrierMarksForDay({
  required int forDayKey,
  required List<TradeListItem> trades,
  required Map<String, Set<int>> usageByTitle,
}) {
  final titles = <String>{};

  for (final t in trades) {
    final dk = cal.dayKey(
      DateTime(t.entreeAt.year, t.entreeAt.month, t.entreeAt.day),
    );
    if (dk != forDayKey) continue;
    final tit = t.strategieTitle.trim();
    if (tit.isNotEmpty) titles.add(tit);
  }

  for (final e in usageByTitle.entries) {
    if (e.value.contains(forDayKey)) {
      titles.add(e.key);
    }
  }

  final out = <StrategieCalendrierDayMark>[];
  for (final title in titles) {
    final data = strategieSetupCardDataPourTitre(title);
    out.add(
      StrategieCalendrierDayMark(
        title: title,
        dotColor: data?.dotColor ?? StrategieTokens.labelMuted,
      ),
    );
  }
  out.sort((a, b) => a.title.compareTo(b.title));
  return out;
}
