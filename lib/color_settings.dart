import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/custom_app_bar.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sudoku/theme.dart';

import 'l10n/app_localizations.dart';

class ColorSettings extends StatefulWidget {
  const ColorSettings({super.key});

  @override
  State<ColorSettings> createState() => _ColorSettingsState();
}

class _ColorSettingsState extends State<ColorSettings> {
  Color? curColor;

  @override
  Widget build(BuildContext context) {
    curColor ??= Provider.of<ThemeProvider>(context).primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: MediaQuery.of(context).platformBrightness,
          systemNavigationBarColor: Colors.transparent,
        ),
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(alignment: Alignment.topLeft, child: makeAppBar(context, AppLocalizations.of(context)!.themeTitle, null)),
                  ),
                  const Expanded(flex: 6, child: SizedBox.shrink()),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: SizedBox.shrink(),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(AppLocalizations.of(context)!.themePrimaryColor),
                        ),
                        Expanded(
                          flex: 3,
                          child: OutlinedButton(
                            onPressed: () => showDialog(
                                context: context,
                                builder: (context) {
                                  final theme = Provider.of<ThemeProvider>(context, listen: false);

                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.themePickPrimaryColor),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                          enableAlpha: false,
                                          pickerAreaBorderRadius: BorderRadius.circular(10),
                                          labelTypes: [], // hide label
                                          pickerColor: curColor!,
                                          onColorChanged: (Color value) {
                                            setState(() {
                                              curColor = value;
                                            });
                                            theme.setPrimaryColor(value, true);
                                          }),
                                    ),
                                  );
                                }),
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                              backgroundColor: WidgetStateProperty.all(curColor),
                              overlayColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary), // TODO does this look good?
                            ),
                            child: const SizedBox(
                              width: 64,
                              height: 64,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox.shrink(),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Expanded(
                        flex: 1,
                        child: SizedBox.shrink(),
                      ),
                      Expanded(flex: 3, child: Text(AppLocalizations.of(context)!.themeDarkTheme)),
                      Expanded(
                        flex: 3,
                        child: OutlinedButton(
                          onPressed: () {
                            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

                            ThemeMode oldMode = themeProvider.themeMode;
                            if (oldMode == ThemeMode.system) {
                              oldMode = MediaQuery.of(context).platformBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
                            }

                            final ThemeMode newMode = (oldMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
                            themeProvider.setThemeMode(newMode, true);
                          },
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                            enableFeedback: false,
                          ),
                          child: const SizedBox(width: 64, height: 64, child: Icon(Icons.dark_mode)),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox.shrink(),
                      ),
                    ]),
                  ),
                  const Expanded(flex: 1, child: SizedBox.shrink()),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

                        // TODO: how to reset?
                        themeProvider.setPrimaryColor(const Color.fromARGB(255, 255, 0, 0), true);
                        themeProvider.setThemeMode(ThemeMode.system, true);
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                        enableFeedback: false,
                      ),
                      child: Text(AppLocalizations.of(context)!.themeResetTheme),
                    ),
                  ),
                  const Expanded(flex: 15, child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ));
  }
}
