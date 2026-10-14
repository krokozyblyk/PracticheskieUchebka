import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._(this._preferences);

  static const _themeKey = 'theme_mode';
  static const _converterFromKey = 'converter_from';
  static const _converterToKey = 'converter_to';

  static AppSettings? _instance;

  static AppSettings get instance {
    final settings = _instance;
    if (settings == null) {
      throw StateError('AppSettings.load() must be called before runApp()');
    }
    return settings;
  }

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _instance = AppSettings._(preferences);
  }

  final SharedPreferences _preferences;

  ThemeMode get themeMode {
    final saved = _preferences.getString(_themeKey);
    return switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  bool get isDarkTheme => themeMode == ThemeMode.dark;

  void toggleTheme() {
    final next = isDarkTheme ? 'light' : 'dark';
    _preferences.setString(_themeKey, next);
    notifyListeners();
  }

  String get converterFrom => _preferences.getString(_converterFromKey) ?? 'USD';

  String get converterTo => _preferences.getString(_converterToKey) ?? 'RUB';

  Future<void> saveCurrencyPair(String from, String to) async {
    await _preferences.setString(_converterFromKey, from);
    await _preferences.setString(_converterToKey, to);
  }
}
