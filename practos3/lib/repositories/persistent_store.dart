import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PersistentStore<T> {
  final SharedPreferences prefs;
  final String key;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final List<T> Function() seed;

  late List<T> items;

  PersistentStore({
    required this.prefs,
    required this.key,
    required this.fromJson,
    required this.toJson,
    required this.seed,
  }) {
    _restore();
  }

  void _restore() {
    final raw = prefs.getString(key);
    if (raw == null) {
      items = [...seed()];
      _persist();
      return;
    }
    try {
      final decoded = jsonDecode(raw) as List;
      items = decoded
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      items = [...seed()];
      _persist();
    }
  }

  Future<void> _persist() async {
    await prefs.setString(key, jsonEncode(items.map(toJson).toList()));
  }

  Future<void> persist() => _persist();
}
