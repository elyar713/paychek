/// Normalisation légère du texte PDF (conserve Unicode : accents, hangoul, etc.).
String paychekPdfNormalize(String? value) {
  var x = (value ?? '').trim();
  if (x.isEmpty) return '-';
  x = x.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');
  x = x.replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ');
  x = x.replaceAll('×', 'x');
  x = x.replaceAll('✕', 'x');
  x = x.replaceAll('·', '·');
  x = x.replaceAll('•', '•');
  x = x.replaceAll(RegExp(r'[«»]'), '"');
  x = x.replaceAll(RegExp(r'[\u2018\u2019\u201A\u201B]'), "'");
  x = x.replaceAll(RegExp(r'[\u201C\u201D\u201E\u201F]'), '"');
  x = x.replaceAll(RegExp(r'[\u2012\u2013\u2014\u2212]'), '-');
  x = x.replaceAll('…', '...');
  x = x.replaceAll('’', "'");
  return x;
}

bool paychekPdfTextHasHangul(String text) {
  return text.runes.any((r) => r >= 0xAC00 && r <= 0xD7A3 || (r >= 0x1100 && r <= 0x11FF));
}
