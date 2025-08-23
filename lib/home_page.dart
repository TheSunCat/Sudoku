import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/painters.dart';
import 'package:sudoku/save_manager.dart';
import 'package:sudoku/sudoku.dart';

import 'about.dart';
import 'color_settings.dart';
import 'fade_dialog.dart';
import 'game.dart';
import 'l10n/app_localizations.dart';
import 'leaderboard.dart';

class HomePage extends StatefulWidget {
  static String id = 'HomePage';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _difficulty = 0;
  String _difficultyStr = "";
  bool _hasSave = false;

  void _updateDifficulty(int delta) {
    // clamp difficulty within bounds of array
    setState(() => _difficulty =
        max(0, min(Sudoku.numDifficulties - 1, _difficulty + delta)));

    Future<bool> saveFuture = SaveManager().saveExists(_difficulty);

    saveFuture.then((value) => setState(() {
      _difficultyStr = AppLocalizations.of(context)!.difficulties.split(':')[_difficulty];
      _hasSave = value;
    }));

    SaveManager().saveLastDifficulty(_difficulty);
  }

  @override void initState() {
    super.initState();

    // start at saved difficulty
    SaveManager().getLastDifficulty().then((value) => {
      _updateDifficulty(value)
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: MediaQuery.platformBrightnessOf(context),
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
                    icon: Icon(Icons.color_lens,
                        color: Theme.of(context).canvasColor),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(500)
                      //more than 50% of width makes circle
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: CustomPaint(
                        size: Size(screenWidth * .50, screenWidth * .50),
                        painter: LogoPainter(Theme.of(context).colorScheme.surface),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _difficulty == 0
                            ? null
                            : () {
                          _updateDifficulty(-1);
                        },
                        style: ButtonStyle(
                          foregroundColor:
                          WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) =>
                              states.contains(WidgetState.disabled)
                                  ? Colors.grey
                                  : Theme.of(context).colorScheme.primary),
                          shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0))),
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
                      TextButton(
                        onPressed: _difficulty == Sudoku.numDifficulties - 1
                            ? null
                            : () {
                          _updateDifficulty(1);
                        },
                        style: ButtonStyle(
                          foregroundColor:
                          WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) =>
                              states.contains(WidgetState.disabled)
                                  ? Colors.grey
                                  : Theme.of(context).colorScheme.primary),
                          shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0))),
                        ),
                        child: const Icon(Icons.arrow_right),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton(
                      onPressed: () async {
                        final temp = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SudokuGame(difficulty: _difficulty),
                          ),
                        );
                        setState(() => _updateDifficulty(0));
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                        foregroundColor: WidgetStateProperty.all(
                            Theme.of(context).textTheme.bodyMedium!.color!),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(AppLocalizations.of(context)!.homeNewGame, style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  FutureBuilder<Sudoku>(
                      future: SaveManager().load(_difficulty),
                      builder:
                          (BuildContext context, AsyncSnapshot<Sudoku> sudoku) {
                        // TODO how can I check whether the AsyncSnapshot has completed yet?

                        return OutlinedButton(
                            onPressed: _hasSave
                                ? () async {
                              final temp = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SudokuGame(
                                    difficulty: _difficulty,
                                    savedGame: sudoku.data!,
                                  ),
                                ),
                              );
                              setState(() => _updateDifficulty(0));
                            }
                                : null,
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(30.0))),
                              foregroundColor: WidgetStateProperty.all(
                                  Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withValues(alpha: _hasSave ? 1 : 0.5)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(AppLocalizations.of(context)!.homeContinue,
                                  style: TextStyle(fontSize: 20)),
                            ));
                      }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ColorSettings()),
                    ),
                    icon: const Icon(Icons.color_lens),
                  ),
                  IconButton(
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                      onPressed: () => SaveManager()
                          .getScores(_difficulty)
                          .then((List<Score> scores) => fadePopup(
                          context,
                          AlertDialog(
                            title: Center(child: Text(AppLocalizations.of(context)!.leaderboardScores)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                makeLeaderboard(context, scores),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 16.0, 0, 0),
                                  child: OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      style: ButtonStyle(
                                        shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    30.0))),
                                      ),
                                      child: Text(AppLocalizations.of(context)!.leaderboardClose)),
                                ),
                              ],
                            ),
                          ),
                          dismissable: true)),
                      icon: const Icon(Icons.leaderboard)),
                  IconButton(
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const About()));
                      },
                      icon: const Icon(Icons.question_mark))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
