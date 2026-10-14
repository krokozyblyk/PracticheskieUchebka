import 'package:flutter/material.dart';

import '../app_settings.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final isDark = settings.isDarkTheme;
    return IconButton(
      tooltip: isDark ? 'Светлая тема' : 'Тёмная тема',
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: settings.toggleTheme,
    );
  }
}
