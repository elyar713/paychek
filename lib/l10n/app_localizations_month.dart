import 'app_localizations.dart';

/// Month names from ARB so they follow [MaterialApp.locale] (not only system locale).
extension AppLocalizationsMonth on AppLocalizations {
  String monthName(int month) {
    switch (month) {
      case DateTime.january:
        return monthJanuary;
      case DateTime.february:
        return monthFebruary;
      case DateTime.march:
        return monthMarch;
      case DateTime.april:
        return monthApril;
      case DateTime.may:
        return monthMay;
      case DateTime.june:
        return monthJune;
      case DateTime.july:
        return monthJuly;
      case DateTime.august:
        return monthAugust;
      case DateTime.september:
        return monthSeptember;
      case DateTime.october:
        return monthOctober;
      case DateTime.november:
        return monthNovember;
      case DateTime.december:
        return monthDecember;
      default:
        return '';
    }
  }

  /// Short month label for compact timestamps (chart tooltips).
  String monthAbbrev(int month) {
    switch (month) {
      case DateTime.january:
        return monthAbbrJanuary;
      case DateTime.february:
        return monthAbbrFebruary;
      case DateTime.march:
        return monthAbbrMarch;
      case DateTime.april:
        return monthAbbrApril;
      case DateTime.may:
        return monthAbbrMay;
      case DateTime.june:
        return monthAbbrJune;
      case DateTime.july:
        return monthAbbrJuly;
      case DateTime.august:
        return monthAbbrAugust;
      case DateTime.september:
        return monthAbbrSeptember;
      case DateTime.october:
        return monthAbbrOctober;
      case DateTime.november:
        return monthAbbrNovember;
      case DateTime.december:
        return monthAbbrDecember;
      default:
        return '';
    }
  }
}
