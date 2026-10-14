double? parseNumber(String? raw) {
  if (raw == null) return null;
  final normalized = raw.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String formatNumber(double value, {int decimalPlaces = 10}) {
  if (value.isNaN || value.isInfinite) return 'не определено';
  final rounded = double.parse(value.toStringAsFixed(decimalPlaces));
  if (rounded == rounded.roundToDouble() && rounded.abs() < 1e15) {
    return rounded.toStringAsFixed(0);
  }
  return rounded.toString();
}

String formatMoney(double value, {int decimalPlaces = 2}) {
  if (value.isNaN || value.isInfinite) return 'не определено';
  return value.toStringAsFixed(decimalPlaces);
}
