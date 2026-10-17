import 'package:flutter/material.dart';

ThemeData buildAppTheme({required Brightness brightness}) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: brightness,
    ),
    useMaterial3: true,
  );
}
