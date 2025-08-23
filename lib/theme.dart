import 'package:flutter/material.dart';
import 'package:sudoku/save_manager.dart';

class ThemeSettings {
  bool isCustom;
  bool isDark;
  Color primary;

  ThemeSettings(this.isCustom, this.isDark, this.primary);
}

class ThemeProvider with ChangeNotifier {
  late Color _defaultPrimary;
  late Color _primary;
  Color get primary => _primary;

  late ColorScheme _lightScheme;
  late ColorScheme _darkScheme;

  ThemeMode _themeMode = ThemeMode.system;
  bool _isCustom = false;
  bool get isCustom => _isCustom;

  ThemeProvider(ThemeSettings initial) {
    if (initial.isCustom) {
      _themeMode = initial.isDark ? ThemeMode.dark : ThemeMode.light;
    }

    _defaultPrimary = initial.primary;
    _primary = _defaultPrimary;
    _isCustom = isCustom;

    _generateThemes(_defaultPrimary);
  }

  ThemeMode get themeMode => _themeMode;
  void setThemeMode(ThemeMode value, bool custom) {
    _themeMode = value;

    if (!_isCustom && custom) {
      _isCustom = true;
      SaveManager().markCustomTheme(custom);
      SaveManager().setDark(value == ThemeMode.dark);
    } else if (value == ThemeMode.system) {
      _isCustom = false;
      setPrimaryColor(_defaultPrimary, false);
      SaveManager().markCustomTheme(false);
    }

    notifyListeners();
  }

  ColorScheme get lightScheme => _lightScheme;
  ColorScheme get darkScheme => _darkScheme;

  // generates themes from color
  void setPrimaryColor(Color color, bool custom) {
    _primary = color;
    _generateThemes(color);

    if (custom) {
      SaveManager().setPrimaryColor(color);
      _isCustom = true;
    }

    notifyListeners();
  }

  void _generateThemes(Color color)
  {
    _lightScheme =
        ColorScheme.fromSeed(primary: color, seedColor: color, brightness: Brightness.light, dynamicSchemeVariant: DynamicSchemeVariant.fidelity);
    _darkScheme =
        ColorScheme.fromSeed(primary: color, surface: Colors.black, seedColor: color, brightness: Brightness.dark, dynamicSchemeVariant: DynamicSchemeVariant.fidelity);
  }
}
