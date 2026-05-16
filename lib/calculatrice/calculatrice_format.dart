String fmtMoney(double v) {
  final s = v.toStringAsFixed(2);
  return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}

String fmtMoneyCompact(double v) {
  final abs = v.abs();
  if (abs >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (abs >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

String fmtRatio(double v) {
  var s = v.toStringAsFixed(2);
  s = s.replaceAll(RegExp(r'\.?0+$'), '');
  return s;
}

String fmtPctTrim(double v) {
  var s = v.toStringAsFixed(2);
  s = s.replaceAll(RegExp(r'\.?0+$'), '');
  return '$s%';
}

