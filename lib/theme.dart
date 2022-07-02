import 'package:flutter/material.dart';

// Example buildTheme method
ThemeData buildTheme(Color accentColor, bool isDark) {

  final ThemeData base = isDark ? ThemeData.dark() : ThemeData.light();
  Color canvasColor = isDark ? Colors.black : Colors.white;

  return base.copyWith(
    canvasColor: canvasColor,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(accentColor),
        overlayColor: MaterialStateProperty.all(accentColor.withOpacity(0.2)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(accentColor),
        overlayColor: MaterialStateProperty.all(accentColor.withOpacity(0.2)),
      )
    ),
    primaryColor: accentColor,
    scaffoldBackgroundColor: canvasColor,
    textTheme: _buildTextTheme(base.textTheme, isDark),
  );
}

TextTheme _buildTextTheme(TextTheme base, bool isDark) {
  return base.copyWith(
    bodyMedium: base.bodyMedium?.copyWith(
      fontSize: 16,
      color: isDark ? Colors.grey.shade200 : Colors.grey.shade600
    ),
  );
}