import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudoku/game.dart';
import 'package:sudoku/painters.dart';

void main() {
  runApp(const Sudoku());
}

class Sudoku extends StatelessWidget {
  const Sudoku({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(
        primarySwatch: Colors.purple,
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
  int _difficulty = 0;
  String _difficultyStr = "Beginner";

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

    return Scaffold(
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
    );
  }
}
