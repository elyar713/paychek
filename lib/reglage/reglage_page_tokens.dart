part of 'reglage_page.dart';

/// Titre de section (TRADING, SUPPORT…) — capitales sur le web.
TextStyle reglageSectionHeaderRowStyle() {
  return GoogleFonts.plusJakartaSans(
    fontSize: kIsWeb ? 10 : 11,
    fontWeight: FontWeight.w700,
    letterSpacing: kIsWeb ? 2.4 : 0.8,
    color: kIsWeb
        ? PaychekWebTokens.textGray600
        : DashboardTokens.labelGrey,
  );
}

String reglageSectionHeadingText(String localized) =>
    kIsWeb ? localized.toUpperCase() : localized;

/// Teal marque (alignÃ© splash / icÃ´ne app).
const Color _kBrandTeal = Color(0xFF1EB48A);
const Color _kSettingsLogoutRed = Color(0xFFE57373);

String _formatThousands(double value) {
  final s = value.round().abs().toString();
  final len = s.length;
  final out = StringBuffer();
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) out.write(' ');
    out.write(s[i]);
  }
  return out.toString();
}

