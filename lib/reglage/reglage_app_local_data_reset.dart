import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard/dashboard_home_layout_store.dart';
import '../etat_mental/mental_state_controller.dart';
import '../questionnaire/user_capital_store.dart';
import '../trade/trade_journal_store.dart';
import 'app_locale_scope.dart';
import 'reglage_language_prefs.dart';
import 'reglage_profile_prefs.dart';
import 'trading_week_prefs.dart';
import 'trading_week_scope.dart';
import 'user_portfolio_store.dart';
import 'user_profile_store.dart';

/// Efface les données locales Paychek sur l’appareil (sauf langue + semaine affichée).
///
/// Équivalent pratique à une réinstallation pour les données persistées.
Future<void> applyAppLocalDataReset({
  required UserCapitalStore capital,
  required UserPortfolioStore portfolio,
  required UserProfileStore profileStore,
  required TradeJournalStore journal,
  required DashboardHomeLayoutStore layoutStore,
  required AppLocaleController localeController,
  required TradingWeekController tradingWeek,
}) async {
  final lang = await ReglageLanguagePrefs.loadCode();
  final week = await TradingWeekPrefs.load();

  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  await ReglageLanguagePrefs.save(lang);
  await TradingWeekPrefs.save(week);

  await ReglageProfilePrefs.clearStoredAccountProfile();

  await capital.clear();
  journal.clear();
  await portfolio.load(seedCapital: capital);

  await profileStore.load();

  await layoutStore.load();

  await localeController.load();
  await tradingWeek.load();

  MentalStateController.instance.resetToFactoryDefaults();
  await MentalStateController.instance.loadSharePreferences();
}
