import 'package:flutter/material.dart';

ThemeData buildAppTheme({required Brightness brightness}) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: brightness,
    ),
    useMaterial3: true,
  );
}
