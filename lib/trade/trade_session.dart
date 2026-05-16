import '../l10n/app_localizations.dart';

const String kTradeSessionAsia = 'asia';
const String kTradeSessionEurope = 'europe';
const String kTradeSessionUs = 'us';
const String kTradeSessionLate = 'late';

/// Entry-time buckets (local clock): stable keys for counters + PDF.
String tradeSessionBucketId(DateTime d) {
  final l = d.toLocal();
  final h = l.hour + (l.minute / 60.0);
  if (h >= 0 && h < 7) return kTradeSessionAsia;
  if (h >= 7 && h < 13) return kTradeSessionEurope;
  if (h >= 13 && h < 18) return kTradeSessionUs;
  return kTradeSessionLate;
}

String tradeSessionLabel(AppLocalizations loc, String id) {
  switch (id) {
    case kTradeSessionAsia:
      return loc.tradeSessionAsia;
    case kTradeSessionEurope:
      return loc.tradeSessionEurope;
    case kTradeSessionUs:
      return loc.tradeSessionUs;
    case kTradeSessionLate:
      return loc.tradeSessionLate;
    default:
      return id;
  }
}

Map<String, int> tradeSessionCountsEmpty() => <String, int>{
      kTradeSessionAsia: 0,
      kTradeSessionEurope: 0,
      kTradeSessionUs: 0,
      kTradeSessionLate: 0,
    };
