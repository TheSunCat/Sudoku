import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/game.dart';
import 'package:sudoku/painters.dart';

void main() {
  runApp(const Sudoku());
}

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

class Sudoku extends StatelessWidget {
  const Sudoku({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(
        primarySwatch: buildMaterialColor(const Color.fromARGB(0xFF, 0xAA, 0x8E, 0xD6)),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.grey.shade600)),
      ),
      home: const HomePage(),
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
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // dark text for status bar
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Center(
          child: Column(
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
                    ),
                    child: const Text("New Game")
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
