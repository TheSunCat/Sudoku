import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sudoku/custom_app_bar.dart';

class ColorSettings extends StatefulWidget {
  const ColorSettings({Key? key}) : super(key: key);

  @override
  State<ColorSettings> createState() => _ColorSettingsState();
}

class _ColorSettingsState extends State<ColorSettings> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // dark text for status bar
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              makeAppBar(context, "Color Settings", null),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Primary color:\t\t\t"),

                          OutlinedButton(
                            onPressed: () => showDialog(context: context, builder: (context) => AlertDialog(
                              title: const Text("Pick a primary color:"),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  enableAlpha: false,
                                  pickerAreaBorderRadius: BorderRadius.circular(500),
                                  showLabel: false,
                                  pickerColor: Theme.of(context).primaryColor,
                                  onColorChanged: (Color value) => DynamicColorTheme.of(context).setColor(color: value, shouldSave: true),
                                ),
                              ),
                            )),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                              surfaceTintColor: MaterialStateProperty.all(Colors.red),
                              shadowColor: MaterialStateProperty.all(Colors.red),
                              enableFeedback: false,
                            ),
                            child: const SizedBox(
                              width: 64,
                              height: 64,
                            ),
                          ),
                        ]
                      ),
                      const SizedBox(height:25),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Dark theme:\t\t\t"),

                            OutlinedButton(
                              onPressed: () => DynamicColorTheme.of(context).setIsDark(isDark: !DynamicColorTheme.of(context).isDark, shouldSave: true),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                                backgroundColor: MaterialStateProperty.all(Theme.of(context).canvasColor),
                                enableFeedback: false,
                              ),
                              child: const SizedBox(
                                width: 64,
                                height: 64,
                                child: Icon(Icons.dark_mode)
                              ),
                            ),
                          ]
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

}