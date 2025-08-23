import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudoku/save_manager.dart';
import 'package:sudoku/sudoku.dart';
import 'package:sudoku/util.dart';

import 'color_settings.dart';
import 'custom_app_bar.dart';
import 'fade_dialog.dart';
import 'game_board.dart';
import 'leaderboard.dart';

class SudokuGame extends StatefulWidget {
  final int difficulty;
  final Sudoku? savedGame;

  const SudokuGame({super.key, required this.difficulty, this.savedGame});

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  final GlobalKey<GameBoardState> _gameBoard = GlobalKey();

  int _selectedNumber = -1;

  bool _marking = false;

  Duration _stopwatchOffset = const Duration(); // saved time
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _refreshTimer;
  _SudokuGameState() : super() {
    // refresh the timer every second
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 900),
        (Timer t) => setState(() {})); // TODO store time in variable
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _stopwatch.stop();

    super.dispose();
  }

  void onBoardChanged(List<List<Cell>> puzzle) {
    SaveManager().save(widget.difficulty,
        Sudoku(puzzle, (_stopwatch.elapsed + _stopwatchOffset).inSeconds));

    // update number buttons
    // the true means nothing, but is required to call setState
    setState(() => true);
  }

  void onReady() {
    _stopwatch.start();
  }

  @override
  Widget build(BuildContext context) {
    String timeString = timeToString(_stopwatch.elapsed + _stopwatchOffset);

    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          makeAppBar(
              context,
              timeString,
              IconButton(
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  // stop the timer while color settings are changed
                  _stopwatch.stop();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ColorSettings()),
                  ).then((value) => setState(() {
                        _stopwatch.start();
                      }));
                },
                icon: const Icon(Icons.color_lens),
              )),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GameBoard(
                  key: _gameBoard,
                  marking: _marking,
                  onBoardChanged: onBoardChanged,
                  onCellTapped: cellPressed,
                  onGameWon: win,
                  onReady: onReady,
                  emptySquares: difficultyToEmptySquares(widget.difficulty),
                  highlightNum: _selectedNumber,
                  savedGame: widget.savedGame,
                  setStopwatchOffset: (Duration d) => _stopwatchOffset = d,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        flex: 1,
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                          ),
                          itemBuilder: _buildNumberButton,
                          itemCount: 10,
                          primary: true, // disable scrolling
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            fadeDialog(
                                context,
                                "Are you sure you want to restart with a new board?",
                                "Cancel",
                                "Restart",
                                () => {}, () {
                              _gameBoard.currentState!.restart();

                              // reset time
                              _stopwatch.reset();
                              _stopwatchOffset = const Duration();

                              _selectedNumber = -1;
                            });
                          },
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                            side: WidgetStateProperty.all(
                                const BorderSide(color: Colors.transparent)),
                          ),
                          child: const Icon(Icons.refresh),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            fadeDialog(
                                context,
                                "Are you sure you want to validate?",
                                "Cancel",
                                "Validate",
                                () => {}, () {
                              _gameBoard.currentState!.validate();
                            });
                          },
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                            side: WidgetStateProperty.all(
                                const BorderSide(color: Colors.transparent)),
                          ),
                          child: const Icon(Icons.check),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: _marking
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                          ),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                          child: OutlinedButton(
                            onPressed: () {
                              // toggle marking mode
                              setState(() {_marking = !_marking;});
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              foregroundColor: WidgetStateProperty.all(_marking
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).colorScheme.primary), // TODO should I use textColor for these?
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0))),
                              side: WidgetStateProperty.all(
                                  const BorderSide(color: Colors.transparent)),
                            ),
                            child: const Icon(Icons.edit),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _gameBoard.currentState!.undo();
                          },
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                            side: WidgetStateProperty.all(
                                const BorderSide(color: Colors.transparent)),
                          ),
                          child: const Icon(Icons.undo),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildNumberButton(BuildContext context, int index) {
    int count = _gameBoard.currentState!.countCellsOf(index + 1);

    String countString = (9 - count).toString();
    if (index == 9 || count == 9) {
      countString = "";
    } else {
      if (count > 9) {
        countString = "${count - 9}+";
      }
    }

    int selectedIndex = _selectedNumber - 1;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(300),
          color: selectedIndex == index
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
        ),
        child: OutlinedButton(
          onPressed: () {
            numberButtonTapped(index);
          },
          style: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(300.0))),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                flex: 4,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text(
                    " ", // for spacing
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text(
                    (index == 9) ? "X" : (index + 1).toString(),
                    style: TextStyle(
                      color: selectedIndex == index
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).textTheme.bodyMedium!.color!,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  countString,
                  style: TextStyle(
                    color: selectedIndex == index
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  void numberButtonTapped(int index) {
    setState(() {
      if (_selectedNumber == index + 1) {
        _selectedNumber = -1;
      } else {
        _selectedNumber = index + 1;
      }

      _gameBoard.currentState!.updateHighlightedNum(_selectedNumber);
    });
  }

  void cellPressed(Cell cell) {
    if (_selectedNumber == -1) {
      numberButtonTapped(cell.value - 1);
      return;
    }
  }

  void win(BuildContext context) {
    _stopwatch.stop();
    Duration gameTime =
        Duration(seconds: (_stopwatch.elapsed + _stopwatchOffset).inSeconds);

    SaveManager().getScores(widget.difficulty).then((List<Score> scores) async {
      SaveManager().clear(widget.difficulty);

      // record the new score
      SaveManager().recordScore(gameTime, widget.difficulty);

      List<Score> newScores = await SaveManager().getScores(widget.difficulty);

      String timeString = timeToString(gameTime);

      print("Saved scores: $newScores");

      // funny random win string generation
      Random rand = Random();

      List<String> winStrings = [
        "You win!",
        "Congration, you done it!",
        "Great job!",
        "Impressive.",
        "EYYYYYYYY!",
        "All our base are belong to you.",
        "You're winner!",
        "A winner is you!",
        "A ADJECTIVE game!"
      ];

      // make the last entry very likely
      int winStringIndex =
          rand.nextInt(winStrings.length * 2).clamp(0, winStrings.length - 1);
      String winString = winStrings[winStringIndex];

      List<String> adjectives = [
        " charming",
        " determined",
        " fabulous",
        " dynamic",
        "n imaginative",
        " breathtaking",
        " brilliant",
        "n elegant",
        " lovely",
        " spectacular",
        "n internet-worthy",
        " screenshot-worthy",
        " duck-like",
        "n explosive",
        " devious",
        "n excellent",
        " concise"
      ];

      winString = winString.replaceAll(
          " ADJECTIVE", adjectives[rand.nextInt(adjectives.length)]);

      if (!context.mounted) {
        print("BUG: this should never happen");
        return;
      }

      fadePopup(
          context,
          AlertDialog(
            title: Center(child: Text(winString)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Difficulty: ${difficulties[widget.difficulty]}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "Validations used: ${_gameBoard.currentState!.getValidations()}"),
                  ],
                ),
                Text("Time: $timeString"),
                const SizedBox(height: 10),
                makeLeaderboard(context, newScores, highlightTime: timeString),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                  child: OutlinedButton(
                      onPressed: () {
                        // clear save again for good measure
                        SaveManager().clear(widget.difficulty);

                        // TODO is this a good idea/allowed? How else do I pop twice?
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                      ),
                      child: const Text("Got it!")),
                ),
              ],
            ),
          ));
    });
  }
}
