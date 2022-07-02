import 'dart:math';

import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/game.dart';
import 'package:sudoku/painters.dart';
import 'package:sudoku/theme.dart';
import 'package:system_theme/system_theme.dart';

import 'color_settings.dart';

void main() {
  runApp(const Sudoku());
}

class Sudoku extends StatelessWidget {
  const Sudoku({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorTheme(
      data: (Color color, bool isDark) {
        return buildTheme(
            color, isDark); // TODO define your own buildTheme method here
      },
      defaultColor: SystemTheme.accentColor.accent,//const Color.fromARGB(0xFF, 0xAA, 0x8E, 0xD6),
      defaultIsDark: SystemTheme.isDarkMode,
      themedWidgetBuilder: (BuildContext context, ThemeData theme) {
        return MaterialApp(
          title: 'Sudoku',
          theme: theme,

          home: const HomePage(),
        );
      }
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _difficulties = [ "Beginner", "Easy", "Medium", "Hard", "Extreme" ];
  int _difficulty = 2;
  String _difficultyStr = "Medium";

  void _updateDifficulty(int delta) {
    setState(() {
      // clamp difficulty within bounds of array
      _difficulty = max(0, min(_difficulties.length - 1, _difficulty + delta));

      _difficultyStr = _difficulties[_difficulty];
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: DynamicColorTheme.of(context).isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  IconButton(
                    enableFeedback: false,
                    onPressed: null,
                    icon: Icon(Icons.color_lens, color: Theme.of(context).canvasColor),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(500)
                      //more than 50% of width makes circle
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: CustomPaint(
                        size: Size(screenWidth * .50, screenWidth * .50),
                        painter: LogoPainter(Theme.of(context).canvasColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: () {
                          _updateDifficulty(-1);
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                        ),
                        child: const Icon(Icons.arrow_left),
                      ),
                      SizedBox(
                        width: 100,
                        child: Center(
                          child: Text(
                            _difficultyStr,
                          ),
                        ),
                      ),
                      TextButton(onPressed: () {
                          _updateDifficulty(1);
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                        ),
                        child: const Icon(Icons.arrow_right),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SudokuGame(clues: (_difficulties.length - _difficulty) * 10)),
                        );
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                        foregroundColor: MaterialStateProperty.all(Theme.of(context).textTheme.bodyMedium!.color!),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("New Game", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ColorSettings()),
                    ),
                    icon: const Icon(Icons.color_lens),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
