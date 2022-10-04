import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  ColorPickerDialog({
    required this.defaultColor,
    required this.defaultIsDark,
    this.title = 'Choose a Color',
    this.cancelButtonText = 'CANCEL',
    this.confirmButtonText = 'CONFIRM',
    this.shouldAutoDetermineDarkMode = true,
    this.shouldShowLabel = false,
  });

  /// The default color when reset is tapped in the dialog.
  final Color defaultColor;

  /// The default dark mode when reset is tapped in the dialog.
  final bool defaultIsDark;

  /// The title of the dialog.
  ///
  /// By default, it is set to 'Choose a Color'.
  final String title;

  /// The text to display for the cancel button.
  ///
  /// By default, it is set to 'CANCEL'.
  final String cancelButtonText;

  /// The text to display for the confirm button.
  ///
  /// By default, it is set to 'CONFIRM'.
  final String confirmButtonText;

  /// Determines if the dark mode should be set based on the chosen color.
  ///
  /// By default, it is set to true.
  final bool shouldAutoDetermineDarkMode;

  /// Determines if the picker should show the HEX/RGB/HSV/HSL values.
  ///
  /// By default, it is set to false.
  final bool shouldShowLabel;

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late bool isDark;
  late Color pickedColor;

  @override
  void initState() {
    super.initState();

    isDark = DynamicColorTheme.of(context).isDark;
    pickedColor = DynamicColorTheme.of(context).color;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        InkWell(
          onTap: () {
            DynamicColorTheme.of(context).resetToSharedPrefsValues();
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(widget.cancelButtonText),
          ),
        ),
        InkWell(
          onTap: () {
            DynamicColorTheme.of(context).setColor(
              color: pickedColor,
              shouldSave: true,
            );
            DynamicColorTheme.of(context).setIsDark(
              isDark: isDark,
              shouldSave: true,
            );

            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(widget.confirmButtonText),
          ),
        ),
      ],
      content: SingleChildScrollView(
        child: ColorPicker(
          displayThumbColor: true,
          enableAlpha: false,
          showLabel: widget.shouldShowLabel,
          onColorChanged: (Color color) {
            setState(() {
              pickedColor = color;

              if (widget.shouldAutoDetermineDarkMode) {
                isDark = !useWhiteForeground(color);
              }
            });

            DynamicColorTheme.of(context).setColor(
              color: color,
              shouldSave: false,
            );

            DynamicColorTheme.of(context).setIsDark(
              isDark: isDark,
              shouldSave: false,
            );
          },
          pickerAreaHeightPercent: 0.7,
          pickerColor: pickedColor,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(widget.title),
          IconButton(
            icon: Icon(Icons.settings_backup_restore),
            onPressed: _reset,
            tooltip: "Reset to Default",
          ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      pickedColor = widget.defaultColor;
      isDark = widget.defaultIsDark;
    });

    DynamicColorTheme.of(context).setColor(
      color: widget.defaultColor,
      shouldSave: false,
    );

    DynamicColorTheme.of(context).setIsDark(
      isDark: isDark,
      shouldSave: false,
    );
  }
}
