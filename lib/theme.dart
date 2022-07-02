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
        surfaceTintColor: MaterialStateProperty.all(Colors.red),
        //overlayColor: MaterialStateProperty.all(Colors.red),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(accentColor)
      )
    ),
    primaryColor: accentColor,
    //highlightColor: Colors.red,
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