library dynamic_color_theme;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ThemedWidgetBuilder = Widget Function(
  BuildContext context,
  ThemeData data,
);

typedef ThemeDataBuilder = ThemeData Function(Color color, bool isDark);

class DynamicColorTheme extends StatefulWidget {
  const DynamicColorTheme({
    Key? key,
    required this.data,
    required this.themedWidgetBuilder,
    required this.defaultColor,
    required this.defaultIsDark,
  }) : super(key: key);

  /// Function that provides the theme and expects a widget to be returned.
  ///
  /// Typically, this would return your MaterialApp widget.
  final ThemedWidgetBuilder themedWidgetBuilder;

  /// Function that provides the chosen color and dark mode selection and
  /// expects an instance of ThemeData to be returned.
  ///
  /// This data will be provided to the themedWidgetBuilder.
  final ThemeDataBuilder data;

  /// The default color to use if nothing has been saved in shared preferences
  /// yet.
  final Color defaultColor;

  /// The default dark mode selection if nothing has been saved in shared
  /// preferences yet.
  final bool defaultIsDark;

  @override
  DynamicColorThemeState createState() => DynamicColorThemeState();

  static DynamicColorThemeState/*!*/ of(BuildContext context) {
    return context.findAncestorStateOfType<DynamicColorThemeState>()!;
  }
}

class DynamicColorThemeState extends State<DynamicColorTheme> {
  late ThemeData _data;

  late Color _color;
  late bool _isDark;

  static const String _colorSharedPreferencesKey = 'color';
  static const String _isDarkSharedPreferencesKey = 'isDarkMode';

  ThemeData get data => _data;

  Color get color => _color;

  bool get isDark => _isDark;

  @override
  void initState() {
    super.initState();
    _color = widget.defaultColor;
    _isDark = widget.defaultIsDark;

    _data = widget.data(_color, _isDark);

    Future<Color> colorFuture = loadColor();
    Future<bool> isDarkFuture = loadIsDark();

    Future.wait([colorFuture, isDarkFuture]).then((List results) {
      _color = results[0];
      _isDark = results[1];

      _data = widget.data(_color, _isDark);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = widget.data(_color, _isDark);
  }

  @override
  void didUpdateWidget(DynamicColorTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    _data = widget.data(_color, _isDark);
  }

  /// Sets the provided color. If `shouldSave` is true, it will save it in
  /// shared preferences.
  ///
  /// This triggers a rebuild of the widgets utilizing the `DynamicColorTheme`.
  Future<void> setColor({
    required Color color,
    required bool shouldSave,
  }) async {
    setState(() {
      _data = widget.data(color, _isDark);
      _color = color;
    });

    if (shouldSave) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_colorSharedPreferencesKey, color.value);
    }
  }

  /// Sets the dark mode. If `shouldSave` is true, it will save it in shared
  /// preferences.
  ///
  /// This triggers a rebuild of the widgets utilizing the `DynamicColorTheme`.
  Future<void> setIsDark({
    required bool isDark,
    required bool shouldSave,
  }) async {
    setState(() {
      _data = widget.data(_color, isDark);
      _isDark = isDark;
    });

    if (shouldSave) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isDarkSharedPreferencesKey, isDark);
    }
  }

  /// Resets the dark mode flag and color to the ones that are saved in shared
  /// preferences.
  ///
  /// This triggers a rebuild of the widgets utilizing the `DynamicColorTheme`.
  void resetToSharedPrefsValues() {
    Future<Color> colorFuture = loadColor();
    Future<bool> isDarkFuture = loadIsDark();

    Future.wait([colorFuture, isDarkFuture]).then((List results) {
      _color = results[0];
      _isDark = results[1];

      setState(() {
        _data = widget.data(_color, _isDark);
      });
    });
  }

  /// Loads the saved color from shared preferences.
  Future<Color> loadColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int colorValue =
        prefs.getInt(_colorSharedPreferencesKey) ?? widget.defaultColor.value;
    return Color(colorValue);
  }

  /// Loads the saved dark mode flag from shared preferences.
  Future<bool> loadIsDark() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkSharedPreferencesKey) ?? widget.defaultIsDark;
  }

  @override
  Widget build(BuildContext context) {
    return widget.themedWidgetBuilder(context, _data);
  }
}
