String formatSol(double value, {int maxDecimals = 6}) {
  if (value == 0) return '0';
  String formatted = value.toStringAsFixed(maxDecimals);

  // Remove trailing zeros and the decimal point if not needed
  formatted = formatted.replaceAll(RegExp(r'0+$'), '');
  formatted = formatted.replaceAll(RegExp(r'\.$'), '');

  return formatted;
}
