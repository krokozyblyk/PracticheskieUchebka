int asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

List<int> asIntList(Object? value) {
  if (value is! List) return const [];
  return value.map(asInt).toList();
}

int? asIdOf(Object? value) {
  if (value is Map) return asInt(value['id']);
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<int> asIdList(Object? value) {
  if (value is! List) return const [];
  return value.map(asIdOf).whereType<int>().toList();
}
