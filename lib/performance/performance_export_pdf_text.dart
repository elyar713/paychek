part of 'performance_export_pdf.dart';

/// Texte pour le PDF : ASCII (Helvetica) par défaut ; hangoul conservé en mode [_pdfHangulMode].
String _pdfText(String s) {
  if (_pdfHangulMode) {
    return _pdfUnicodeNormalize(s);
  }
  return _asciiOnly(s);
}

String _pdfUnicodeNormalize(String s) {
  var x = s.trim();
  if (x.isEmpty) return '-';
  x = x.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');
  x = x.replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ');
  x = x.replaceAll('×', 'x');
  x = x.replaceAll('✕', 'x');
  x = x.replaceAll('·', '-');
  x = x.replaceAll('•', '-');
  x = x.replaceAll(RegExp(r'[«»]'), '"');
  x = x.replaceAll(RegExp(r'[\u2018\u2019\u201A\u201B]'), "'");
  x = x.replaceAll(RegExp(r'[\u201C\u201D\u201E\u201F]'), '"');
  x = x.replaceAll(RegExp(r'[\u2012\u2013\u2014\u2212]'), '-');
  x = x.replaceAll('…', '...');
  x = x.replaceAll('€', 'EUR');
  x = x.replaceAll('’', "'");
  const map = <String, String>{
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'É': 'E',
    'È': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'À': 'A',
    'Â': 'A',
    'Ä': 'A',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'Ù': 'U',
    'Û': 'U',
    'Ü': 'U',
    'î': 'i',
    'ï': 'i',
    'Î': 'I',
    'Ï': 'I',
    'ô': 'o',
    'ö': 'o',
    'Ô': 'O',
    'Ö': 'O',
    'ç': 'c',
    'Ç': 'C',
    'œ': 'oe',
    'Œ': 'OE',
    'æ': 'ae',
    'Æ': 'AE',
  };
  map.forEach((k, v) => x = x.replaceAll(k, v));
  return x;
}

/// Texte compatible police PDF standard (Helvetica / WinAnsi) : garde ASCII + Latin-1
/// imprimable ; le reste devient « ? » (évite les carrés / glyphes manquants).
String _asciiOnly(String s) {
  var x = s.trim();
  x = x.replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ');
  x = x.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');
  x = x.replaceAll('×', 'x');
  x = x.replaceAll('✕', 'x');
  x = x.replaceAll('·', '-');
  x = x.replaceAll('•', '-');
  x = x.replaceAll(RegExp(r'[«»]'), '"');
  x = x.replaceAll(RegExp(r'[\u2018\u2019\u201A\u201B]'), "'");
  x = x.replaceAll(RegExp(r'[\u201C\u201D\u201E\u201F]'), '"');
  x = x.replaceAll(RegExp(r'[\u2012\u2013\u2014\u2212]'), '-');
  x = x.replaceAll('…', '...');
  x = x.replaceAll('€', 'EUR');
  x = x.replaceAll('’', "'");
  const map = <String, String>{
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'É': 'E',
    'È': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'À': 'A',
    'Â': 'A',
    'Ä': 'A',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'Ù': 'U',
    'Û': 'U',
    'Ü': 'U',
    'î': 'i',
    'ï': 'i',
    'Î': 'I',
    'Ï': 'I',
    'ô': 'o',
    'ö': 'o',
    'Ô': 'O',
    'Ö': 'O',
    'ç': 'c',
    'Ç': 'C',
    'œ': 'oe',
    'Œ': 'OE',
    'æ': 'ae',
    'Æ': 'AE',
  };
  map.forEach((k, v) => x = x.replaceAll(k, v));
  final out = StringBuffer();
  for (final r in x.runes) {
    // ASCII + Latin-1 « imprimable » (évite C1 0x80–0x9F souvent absents des polices PDF).
    final ok = r == 0x09 || r == 0x0A || r == 0x0D || (r >= 0x20 && r <= 0x7E) || (r >= 0xA0 && r <= 0xFF);
    if (ok) {
      out.writeCharCode(r);
    } else {
      out.write('?');
    }
  }
  final t = out.toString().trim();
  return t.isEmpty ? '-' : t;
}

String _periodLabel(PerformancePeriodFilter p, DateTime anchor, DateTime? customStart, Locale locale) {
  switch (p) {
    case PerformancePeriodFilter.all:
      return _p(locale, 'Tout l\'historique', 'All history', 'Todo el historial', 'Gesamte Historie', 'Todo o histórico', '전체 기록');
    case PerformancePeriodFilter.oneDay:
      return _p(locale, 'Aujourd\'hui', 'Today', 'Hoy', 'Heute', 'Hoje', '오늘');
    case PerformancePeriodFilter.yesterday:
      return _p(locale, 'Hier', 'Yesterday', 'Ayer', 'Gestern', 'Ontem', '어제');
    case PerformancePeriodFilter.threeDays:
      return _p(locale, '3 derniers jours', 'Last 3 days', 'Últimos 3 días', 'Letzte 3 Tage', 'Últimos 3 dias', '최근 3일');
    case PerformancePeriodFilter.oneWeek:
      return _p(locale, 'Cette semaine (7 jours)', 'Last 7 days', 'Últimos 7 días', 'Letzte 7 Tage', 'Últimos 7 dias', '최근 7일');
    case PerformancePeriodFilter.lastWeek:
      return _p(locale, 'Semaine civile précédente', 'Previous calendar week', 'Semana civil anterior', 'Vorherige Kalenderwoche', 'Semana civil anterior', '직전 주(월~일)');
    case PerformancePeriodFilter.lastMonth:
      return _p(locale, 'Mois glissant précédent', 'Prior rolling month', 'Mes móvil anterior', 'Rollierender Monat zuvor', 'Mês móvel anterior', '직전 같은 날짜 기준 한 달');
    case PerformancePeriodFilter.currentMonth:
      return _p(locale, 'Mois en cours', 'Current month', 'Mes actual', 'Aktueller Monat', 'Mês atual', '이번 달');
    case PerformancePeriodFilter.custom:
      if (customStart == null) {
        return _p(locale, 'Période personnalisée', 'Custom period', 'Periodo personalizado', 'Benutzerdefiniert', 'Personalizado', '사용자 기간');
      }
      final d = DateTime(customStart.year, customStart.month, customStart.day);
      final dd = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      return _p(locale, 'Du $dd', 'From $dd', 'Desde $dd', 'Ab $dd', 'De $dd', '$dd부터');
  }
}
