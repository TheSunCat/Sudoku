import 'package:dynamic_color_theme/color_picker_dialog.dart';
import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const kFuchsia = const Color(0xFF880E4F);
const kWhite = Colors.white;
const kLightGrey = const Color(0xFFE8E8E8);
const kDarkGrey = const Color(0xFF303030);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorTheme(
      data: (Color color, bool isDark) {
        return _buildTheme(color, isDark);
      },
      defaultColor: kFuchsia,
      defaultIsDark: false,
      themedWidgetBuilder: (BuildContext context, ThemeData theme) {
        return MaterialApp(
          home: MyHomePage(title: 'Dynamic Color Theme'),
          theme: theme,
          title: 'Flutter Demo',
        );
      },
    );
  }

  ThemeData _buildTheme(Color accentColor, bool isDark) {
    final ThemeData base = isDark ? ThemeData.dark() : ThemeData.light();
    final Color primaryColor = isDark ? kDarkGrey : kWhite;

    return base.copyWith(
      accentColor: accentColor,
      accentTextTheme: _buildTextTheme(base.accentTextTheme, accentColor),
      cardColor: primaryColor,
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: accentColor,
      ),
      iconTheme: base.iconTheme.copyWith(
        color: accentColor,
      ),
      primaryColor: primaryColor,
      primaryIconTheme: base.primaryIconTheme.copyWith(
        color: accentColor,
      ),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme, accentColor),
      scaffoldBackgroundColor: primaryColor,
      textSelectionTheme: _buildTextSelectionTheme(base.textSelectionTheme, accentColor, isDark),
      textTheme: _buildTextTheme(base.textTheme, accentColor),
    );
  }

  TextTheme _buildTextTheme(TextTheme base, Color color) {
    return base.copyWith(
      bodyText2: base.bodyText2!.copyWith(
        fontSize: 16,
      ),
      bodyText1: base.bodyText1!.copyWith(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      button: base.button!.copyWith(
        color: color,
      ),
      caption: base.caption!.copyWith(
        color: color,
        fontSize: 14,
      ),
      headline5: base.headline5!.copyWith(
        color: color,
        fontSize: 24,
      ),
      subtitle1: base.subtitle1!.copyWith(
        color: color,
        fontSize: 18,
      ),
      headline6: base.headline6!.copyWith(
        color: color,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  TextSelectionThemeData _buildTextSelectionTheme(TextSelectionThemeData base, Color accentColor, bool isDark) {
    return base.copyWith(
      cursorColor: accentColor,
      selectionColor: isDark ? kDarkGrey : kLightGrey,
      selectionHandleColor: accentColor,
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    Color color = DynamicColorTheme.of(context).color;
    bool isDark = DynamicColorTheme.of(context).isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text('Color is $color and isDark is $isDark'),
          ),
          TextButton(
            child: Text(
              'Flip dark mode',
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () {
              DynamicColorTheme.of(context).setIsDark(
                isDark: !isDark,
                shouldSave: true,
              );
            },
          ),
          TextButton(
            child: Text(
              'Set color to Fuschia!',
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () {
              DynamicColorTheme.of(context).setColor(
                color: kFuchsia,
                shouldSave: true,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: color,
        icon: Icon(Icons.color_lens),
        label: Text('Color Picker'),
        onPressed: () {
          showDialog(
            builder: (BuildContext context) {
              return WillPopScope(
                child: ColorPickerDialog(
                  defaultColor: kFuchsia,
                  defaultIsDark: false,
                  title: 'Choose your Destiny',
                  cancelButtonText: 'NEVERMIND',
                  confirmButtonText: 'SOUNDS GOOD',
                  shouldAutoDetermineDarkMode: true,
                  shouldShowLabel: true,
                ),
                onWillPop: () async {
                  DynamicColorTheme.of(context).resetToSharedPrefsValues();
                  return true;
                },
              );
            },
            context: context,
          );
        },
      ),
    );
  }
}
