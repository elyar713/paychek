import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mon_app_finder/firebase_options.dart';
import 'package:mon_app_finder/auth/mobile_mandatory_auth_screen.dart';
import 'package:mon_app_finder/etat_mental/mental_state_controller.dart';
import 'package:mon_app_finder/main.dart';
import 'firebase_test_mocks.dart';
import 'package:mon_app_finder/questionnaire/user_capital_store.dart';
import 'package:mon_app_finder/reglage/app_locale_scope.dart';
import 'package:mon_app_finder/reglage/user_portfolio_store.dart';
import 'package:mon_app_finder/reglage/user_profile_store.dart';
import 'package:mon_app_finder/trade/trade_journal_store.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash puis langue puis écran connexion', (WidgetTester tester) async {
    final store = UserCapitalStore();
    await store.load();
    final portfolioStore = UserPortfolioStore();
    await portfolioStore.load(seedCapital: store);
    final userProfileStore = UserProfileStore();
    await userProfileStore.load();
    final appLocaleController = AppLocaleController();
    await appLocaleController.load();
    await tester.pumpWidget(
      PaychekApp(
        capitalStore: store,
        portfolioStore: portfolioStore,
        tradeJournalStore: TradeJournalStore(),
        userProfileStore: userProfileStore,
        appLocaleController: appLocaleController,
      ),
    );

    expect(find.text('PAYCHEK'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pumpAndSettle();

    expect(find.text('Choose language'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Mobile : après la langue, connexion obligatoire (questionnaire = PostAuthGate une fois connecté).
    expect(find.byType(MobileMandatoryAuthScreen), findsOneWidget);

    MentalStateController.instance.cancelMidnightCalendarTimerForTests();
  });
}
