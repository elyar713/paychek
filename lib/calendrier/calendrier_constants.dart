import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../web/paychek_web_tokens.dart';

const double kDayCellRadius = 7;
const double kDayCellGap = 4;
const double kTitleFontSize = 14;
const double kNavIconSize = 18;
const double kWeekdayFontSize = 9;
const double kDayDigitFontSize = 12;
const double kCalendarBodyMaxWidth = 400;
const double kTopInfoCardHeight = 50;

const Color kTitleColor = Color(0xFF9A9A9A);
const Color kWeekdayColor = Color(0xFF5B5B5B);
const Color kDayColor = Color(0xFF5A5A5A);
const Color kDayFutureColor = Color(0xFF484848);
const Color kDaySelectedColor = Color(0xFFD8D8D8);
const Color kDayFutureSelectedColor = Color(0xFFBFBFBF);
const Color kSelectedBorderColor = Color(0xFF5E5E5E);
const Color kTodayBorderColor = Color(0xFF1E1E1E);
const Color kNeutralSelectedFill = Color(0xFF171717);
const Color kGainFill = Color(0xFF0B2F23);
const Color kGainFillSelected = Color(0xFF103527);
const Color kGainText = Color(0xFF28A872);
const Color kLossFill = Color(0xFF31131A);
const Color kLossFillSelected = Color(0xFF3A1620);
const Color kLossText = Color(0xFFFF4E58);
const Color kBreakevenFill = Color(0xFF1F1F1F);
const Color kBreakevenFillSelected = Color(0xFF272727);
const Color kBreakevenText = Color(0xFF909090);

/// Fonds des cartes Calendrier (stats, graphique, pilules) — plus lisibles que le noir plein.
const Color kCalCardBg = Color(0xFF18181C);
const Color kCalCardBgSelected = Color(0xFF1E1E24);
const Color kCalCardBorder = Color(0xFF2E2E36);

Color get kCalCardSurface =>
    kIsWeb ? PaychekWebTokens.cardBg : kCalCardBg;

Color get kCalMonthPillSelected =>
    kIsWeb ? PaychekWebTokens.pillTrackBg : kCalCardBgSelected;

Color get kCalCardBorderResolved =>
    kIsWeb ? PaychekWebTokens.borderGray800 : kCalCardBorder;
