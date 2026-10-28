import 'package:flutter/material.dart';

const _bg = Color(0xFF121212);
const _surface = Color(0xFF1E1E1E);
const _surfaceHigh = Color(0xFF242424);
const _surfaceHighest = Color(0xFF2C2C2C);
const _outline = Color(0xFF333333);
const _outlineStrong = Color(0xFF40493D);
const _green = Color(0xFF2E7D32);
const _greenLight = Color(0xFF81C784);
const _text = Color(0xFFE8EAED);
const _textMuted = Color(0xFF9AA0A6);
const _error = Color(0xFFEF9A9A);

ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _green,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF1B5E20),
    onPrimaryContainer: Color(0xFFCBFFC2),
    secondary: _greenLight,
    onSecondary: Color(0xFF003911),
    secondaryContainer: Color(0xFF0B551F),
    onSecondaryContainer: Color(0xFF82C985),
    tertiary: Color(0xFFFFB3B2),
    onTertiary: Color(0xFF561E20),
    tertiaryContainer: Color(0xFFA1595A),
    onTertiaryContainer: Color(0xFFFFEDEC),
    error: _error,
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: _bg,
    onSurface: _text,
    surfaceContainerLowest: Color(0xFF0E0E0E),
    surfaceContainerLow: Color(0xFF1C1B1B),
    surfaceContainer: Color(0xFF201F1F),
    surfaceContainerHigh: Color(0xFF2A2A2A),
    surfaceContainerHighest: Color(0xFF353534),
    onSurfaceVariant: _textMuted,
    outline: _outline,
    outlineVariant: _outlineStrong,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE5E2E1),
    onInverseSurface: Color(0xFF313030),
    inversePrimary: Color(0xFF1B6D24),
    surfaceTint: _greenLight,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: _bg,
    fontFamily: 'Roboto',
  );

  final textTheme = base.textTheme.copyWith(
    headlineLarge: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 32 / 28,
      letterSpacing: -0.28,
      color: _text,
    ),
    headlineMedium: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 28 / 22,
      letterSpacing: -0.22,
      color: _text,
    ),
    titleLarge: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 24 / 18,
      color: _text,
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 24 / 16,
      color: _text,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      color: _text,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: _text,
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 16 / 12,
      color: _textMuted,
    ),
    labelLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: _text,
    ),
    labelMedium: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      letterSpacing: 0.24,
      color: _textMuted,
    ),
    labelSmall: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      height: 14 / 10,
      letterSpacing: 0.4,
      color: _textMuted,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: _bg,
      foregroundColor: _text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _text,
      ),
      iconTheme: IconThemeData(color: _text),
    ),
    cardTheme: const CardThemeData(
      color: _surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: _outline),
      ),
    ),
    dividerTheme: const DividerThemeData(color: _outline, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: const TextStyle(color: _textMuted),
      hintStyle: const TextStyle(color: _textMuted),
      floatingLabelStyle: const TextStyle(color: _greenLight),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _outline),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _outline),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _greenLight, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _error, width: 2),
      ),
      errorStyle: const TextStyle(color: _error, fontSize: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _text,
        side: const BorderSide(color: _outline),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _greenLight),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: _textMuted),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _surface,
      selectedColor: _green.withValues(alpha: 0.22),
      disabledColor: _surfaceHigh,
      labelStyle: const TextStyle(color: _textMuted, fontSize: 13),
      secondaryLabelStyle: const TextStyle(color: _greenLight, fontSize: 13),
      side: const BorderSide(color: _outline),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: _surface,
      indicatorColor: Color(0xFF2A3D2B),
      selectedIconTheme: IconThemeData(color: _greenLight),
      unselectedIconTheme: IconThemeData(color: _textMuted),
      selectedLabelTextStyle: TextStyle(
        color: _greenLight,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: _textMuted, fontSize: 11),
      useIndicator: true,
      minWidth: 72,
      minExtendedWidth: 240,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _surface,
      indicatorColor: const Color(0xFF2A3D2B),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? _greenLight
              : _textMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? _greenLight
              : _textMuted,
        ),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: _surfaceHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: _outline),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _text,
      ),
      contentTextStyle: TextStyle(fontSize: 14, color: _text),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: _surfaceHighest,
      contentTextStyle: TextStyle(color: _text, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(_surfaceHigh),
      headingTextStyle: TextStyle(
        color: _textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(color: _text, fontSize: 14),
      dividerThickness: 1,
      horizontalMargin: 16,
      columnSpacing: 20,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: _textMuted,
      textColor: _text,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? _green : null,
      ),
      side: const BorderSide(color: _textMuted, width: 1.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _greenLight,
      linearTrackColor: _surfaceHigh,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: _surfaceHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _outline),
      ),
      textStyle: const TextStyle(color: _text, fontSize: 12),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(_textMuted.withValues(alpha: 0.5)),
      radius: const Radius.circular(6),
    ),
  );
}
