import 'dart:async';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/painters.dart';
import 'package:sudoku/save_manager.dart';
import 'package:sudoku/stack.dart';
import 'package:sudoku/sudoku.dart';
import 'package:sudoku/util.dart';

import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

import 'color_settings.dart';
import 'custom_app_bar.dart';
import 'fade_dialog.dart';
import 'move.dart';

final List<String> difficulties = [
  "Beginner",
  "Easy",
  "Medium",
  "Hard",
  "Extreme"
];

class SudokuGame extends StatefulWidget {
  final int difficulty;
  final Future<Sudoku>? savedGame;

  const SudokuGame({Key? key, required this.difficulty, this.savedGame}) : super(key: key);

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> with TickerProviderStateMixin {
  List<List<Cell>>? _puzzle;

  final LIFO<List<Move>> _undoStack = LIFO();

  bool _marking = false;
  int _selectedNumber = -1;

  int _validations = 0;
  final List<Position> _validationWrongCells = List.empty(growable: true);

  bool _generated = false;
  late List<AnimationController> _scaleAnimationControllers;
  late List<Animation<double>> _scaleAnimations;
  late AnimationController _noAnimationController;
  late Animation<double> _noAnimation;

  Duration _stopwatchOffset = const Duration(); // saved time
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _refreshTimer;
  _SudokuGameState() : super() {
    // refresh the timer every second
    _refreshTimer = Timer.periodic(
        const Duration(milliseconds: 500), (Timer t) => setState(() {})); // TODO store time in variable
  }

  @override
  void initState() {
    super.initState();

    _scaleAnimationControllers = List.generate(9*9, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 200),
        vsync: this,
      );
    });

    //_scaleAnimationControllers.forEach((element) => element.reset());

    _scaleAnimations = List.generate(9*9, (index) {
      return CurvedAnimation(parent: _scaleAnimationControllers[index], curve: Curves.fastLinearToSlowEaseIn);
    });

    _noAnimationController = AnimationController(vsync: this, value: 1);
    _noAnimation = CurvedAnimation(parent: _noAnimationController, curve: Curves.linear);
  }

  @override
  void dispose() {

    _refreshTimer.cancel();
    _stopwatch.stop();

    for(int i = 0; i < _scaleAnimationControllers.length; i++) {
      _scaleAnimationControllers[i].dispose();
    }

    super.dispose();
  }

  void onBoardChange() {
    SaveManager().save(widget.difficulty, Sudoku(_puzzle!, (_stopwatch.elapsed + _stopwatchOffset).inSeconds));
  }

  void onReady() {
    _stopwatch.start();

    setState(() {
      Random rand = Random();

      for(int i = 0; i < _scaleAnimationControllers.length; i++) {
        Future.delayed(Duration(milliseconds: rand.nextInt(1000)), () {
          _scaleAnimationControllers[i].reset();
          _scaleAnimationControllers[i].forward();
        });
      }

      Future.delayed(const Duration(milliseconds: 1000), () {
        _generated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_puzzle == null) {
      if(widget.savedGame == null) {
        // TODO async?

        _puzzle = List.empty(growable: true);

        int clues = (difficulties.length - widget.difficulty) * 6;

        List<List<int>> board = SudokuGenerator(emptySquares: 60 - clues).newSudoku;

        for(int row = 0; row < board.length; row++) {
          _puzzle!.add(List.generate(9, (column) {
            int val = board[row][column];
            return Cell(Position(column, row), val, val != 0);
          }));
        }

        onReady();
      } else {
        widget.savedGame!.then((value) {
          _puzzle = value.game;
          _stopwatchOffset = Duration(seconds: value.time);
          onReady();
        });
      }

      return const SizedBox.shrink();
    }

    const int boardLength = 9;

    String timeString = timeToString(_stopwatch.elapsed + _stopwatchOffset);


    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: DynamicColorTheme.of(context).isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              makeAppBar(context, timeString,
                IconButton(
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                  onPressed: () {
                    // stop the timer while color settings are changed
                    _stopwatch.stop();

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ColorSettings()),
                    ).then((value) => setState(() => _stopwatch.start()));
                  },
                  icon: const Icon(Icons.color_lens),
                )
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: boardLength,
                          ),
                          itemBuilder: _buildGridItems,
                          itemCount: boardLength * boardLength,
                          primary: true, // disable scrolling
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ),
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
                              itemBuilder: _buildNumberButtons,
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
                                fadeDialog(context, "Are you sure you want to restart with a new board?", "Cancel", "Restart", () => {}, () {
                                  setState(() {
                                    _puzzle = null; // cause the board to be re-generated
                                    _selectedNumber = -1;
                                    _validationWrongCells.clear();
                                    _undoStack.clear();
                                  });
                                });
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0))),
                                side: MaterialStateProperty.all(const BorderSide(color: Colors.transparent)),
                              ),
                              child: const Icon(Icons.refresh),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                fadeDialog(context, "Are you sure you want to validate?", "Cancel", "Validate", () => {}, () {
                                  _validations++;

                                  _validationWrongCells.clear();

                                  setState(() {
                                    for (int x = 0; x < 9; x++) {
                                      for (int y = 0; y < 9; y++) {
                                        Position pos = Position(x, y);
                                        Cell cell = _puzzle![x][y];
                                        if (cell.value != 0 &&
                                            !cell.prefill) {

                                          if(cellInvalid(x, y)) {
                                            _validationWrongCells
                                                .add(
                                                Position(x, y));
                                          }
                                        }
                                      }
                                    }
                                  });
                                });
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0))),
                                side: MaterialStateProperty.all(const BorderSide(color: Colors.transparent)),
                              ),
                              child: const Icon(Icons.check),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AnimatedContainer(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: _marking ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
                              ),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease,
                              child: OutlinedButton(
                                onPressed: () {
                                  // toggle marking mode
                                  setState(() => {_marking = !_marking});
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                     Colors.transparent),
                                  foregroundColor: MaterialStateProperty.all(_marking
                                      ? Theme.of(context).canvasColor
                                      : Theme.of(context).primaryColor), // TODO should I use textColor for these?
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0))),
                                  side: MaterialStateProperty.all(const BorderSide(color: Colors.transparent)),
                                ),
                                child: const Icon(Icons.edit),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                if (_undoStack.isEmpty) {
                                  return;
                                }

                                // undo the move
                                setState(() {
                                  _undoStack.pop().forEach((move) {
                                    Cell cell = _puzzle![move.y][move.x];

                                    cell.value = move.value;

                                    cell.markup.clear();
                                    // ignore: avoid_function_literals_in_foreach_calls
                                    move.markup.forEach(
                                            (element) => cell.markup.add(element) );
                                  });
                                });
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0))),
                                side: MaterialStateProperty.all(const BorderSide(color: Colors.transparent)),
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
        )
      ),
    );
  }

  Widget _buildGridItems(BuildContext context, int index) {
    int boardLength = 9;
    int sectorLength = 3;

    int x, y = 0;
    x = (index % boardLength);
    y = (index / boardLength).floor();

    // not my best code...
    Border border = Border(
      right: ((x % sectorLength == sectorLength - 1) && (x != boardLength - 1))
          ? BorderSide(width: 2.0, color: Theme.of(context).primaryColor)
          : ((x == boardLength - 1)
              ? BorderSide.none
              : BorderSide(width: 1.0, color: Theme.of(context).dividerColor)),
      bottom: ((y % sectorLength == sectorLength - 1) && (y != boardLength - 1))
          ? BorderSide(width: 2.0, color: Theme.of(context).primaryColor)
          : ((y == boardLength - 1)
              ? BorderSide.none
              : BorderSide(width: 1.0, color: Theme.of(context).dividerColor)),
    );

    return GestureDetector(
      onTap: () {
        if (_puzzle == null) {
          return;
        }

        Cell cell = _puzzle![y][x];

        if(_selectedNumber == -1) {
          numberButtonPressed(cell.value - 1);
          return;
        }

        if(cell.prefill) {
          return;
        }

        // place cell
        setState(() {
          _undoStack
              .push([Move(x, y, cell.value, List.from(cell.markup))]);

          AnimationController animation = _scaleAnimationControllers[y * 9 + x];

          if (_selectedNumber != 10) {
            if (!_marking && cell.value == _selectedNumber) {
              // wait for animation
              Future.delayed(const Duration(milliseconds: 190), () {
                setState(() {
                  _puzzle![y][x].value = 0;
                  onBoardChange();
                });
              });

              _validationWrongCells.removeWhere(
                  (element) => (x == element.x && y == element.y));

              animation.reset();
              animation.reverse(from: 1.0);

            } else {
              if (_marking && _selectedNumber != 0) {
                if (cell.markup.isEmpty ||
                    (!cell.markup.contains(_selectedNumber) &&
                        cell.markup.length <= 8)) {
                  cell.markup.add(_selectedNumber);

                  animation.reset();
                  animation.forward();
                } else {
                  animation.reset();
                  animation.reverse(from: 1.0);

                  cell.markup.removeWhere((int val) => val == _selectedNumber);

                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (cell.markup.isNotEmpty) {
                      animation.reset();
                      animation.forward();
                    }
                  });
                }

                _puzzle![y][x].value = 0;

              } else {
                cell.markup.clear();
                _puzzle![y][x].value = _selectedNumber;

                // remove markups that are no longer valid
                for(int row = 0; row < 9; row++) {
                  _puzzle![row][x].markup.removeWhere((int val) {
                    bool ret = val == _selectedNumber;

                    if(ret) {
                      _undoStack.peek.add(Move(x, row, _puzzle![row][x].value, List.from(_puzzle![row][x].markup)));
                    }

                    return ret;
                  });
                }

                for(int column = 0; column < 9; column++) {
                  _puzzle![y][column].markup.removeWhere((int val) {
                    bool ret = val == _selectedNumber;

                    if(ret) {
                      _undoStack.peek.add(Move(column, y, _puzzle![y][column].value, List.from(_puzzle![y][column].markup)));
                    }

                    return ret;
                  });
                }

                int rowStart = y - (y % 3);
                int columnStart = x - (x % 3);
                for(int row = rowStart; row < rowStart + 3; row++) {
                  for(int column = columnStart; column < columnStart + 3; column++) {
                    _puzzle![row][column].markup.removeWhere((int val) {
                      bool ret = val == _selectedNumber;

                      if(ret) {
                        _undoStack.peek.add(Move(column, row, _puzzle![row][column].value, List.from(_puzzle![row][column].markup)));
                      }

                      return ret;
                    });
                  }
                }

                animation.reset();
                animation.forward();
              }

              onBoardChange();

              _validationWrongCells.removeWhere(
                  (element) => (x == element.x && y == element.y));

              List<List<int>> sudoku = List.empty(growable: true);
              for(int row = 0; row < 9; row++) {
                sudoku.add(List.generate(9, (column) => _puzzle![row][column].value));
              }

              try {
                bool solved = SudokuUtilities.isSolved(sudoku);
                if (solved) {
                  win(context);
                }
              } on InvalidSudokuConfigurationException {
                // Sudoku would not validate here
              }
            }
          } else if (!cell.prefill) {
            cell.markup.clear();
            _puzzle![y][x].value = 0;

            onBoardChange();

            _validationWrongCells.removeWhere(
                (element) => (x == element.x && y == element.y));

            animation.reset();
            animation.reverse(from: 1.0);
          }
        });
      },
      child: Container( // for tap target
        color: Colors.transparent,
        child: GridTile(
          child: CustomPaint(
            foregroundPainter: EdgePainter(border, x != boardLength - 1, y != boardLength - 1),
            //decoration: BoxDecoration(border: border),
            child: Center(
              child: _buildGridItem(x, y),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(int x, int y) {
    if (_puzzle == null) {
      return const SizedBox.shrink();
    }

    Animation<double> animation = _scaleAnimations[y * 9 + x];
    bool animating = !(animation.isDismissed || animation.isCompleted);

    Cell cell = _puzzle![y][x];
    int val = cell.value;

    if (val == 0 && cell.markup.isEmpty) {
      return const SizedBox.shrink();
    } // show nothing for empty cells

    Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    Color itemColor = Colors.transparent;

    if(cell.prefill) {
      textColor = textColor.withOpacity(0.65);
      itemColor = textColor.withOpacity(0.07);
    }

    bool highlighted = false;

    if (val == _selectedNumber || cell.markup.contains(_selectedNumber)) {
      itemColor = Theme.of(context).primaryColor;
      highlighted = true;
    }

    if (_validationWrongCells
        .any((element) => ((element.x == x) && (element.y == y)))) {
      itemColor = Colors.red.shade300;
      highlighted = true;
    }

    List<String> markup = List.generate(cell.markup.length,
        (index) => cell.markup[index].toString());

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Stack(
        children: [
          ScaleTransition(
            scale: animation,
            alignment: Alignment.center,
            child: AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 100),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: itemColor, borderRadius: BorderRadius.circular(500)
                //more than 50% of width makes circle
              ),
              child: null,
            ),
          ),
          ScaleTransition(
            scale: _generated ? _noAnimation : animation,
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) => DefaultTextStyle(
                  style: DefaultTextStyle.of(context).style.apply(
                      decoration: TextDecoration.none,
                      color: highlighted
                          ? ColorTween(begin: textColor, end: Theme.of(context).canvasColor)
                          .animate(animation).value!
                          : textColor),
                  child: child!
              ),
              child: Center(
                child: cell.markup.isNotEmpty
                    ? Container(
                        color: Colors.transparent,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Column(
                            children: [
                              // TODO this is ugly. Is there a better way?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // NQSP to preserve small text size
                                children: [
                                  Text(markup.length >= 8 ? markup[7] : " "),
                                  Text(markup.length >= 7 ? markup[6] : " "),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(markup.length >= 6 ? markup[5] : " "),
                                  Text(markup.length >= 5 ? markup[4] : " "),
                                  Text(markup.length >= 4 ? markup[3] : " "),
                                  Text(markup.length >= 3 ? markup[2] : " "),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(markup.length >= 2 ? markup[1] : " "),
                                  Text(markup.length >= 1 ? markup[0] : " "),
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                      height: double.infinity,
                      child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            val.toString(),
                        ),
                      ),
                    ),
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget _buildNumberButtons(BuildContext context, int index) {
    if (_puzzle == null) {
      return const SizedBox.shrink();
    }

    int count = 0;
    for (int x = 0; x < 9; x++) {
      for (int y = 0; y < 9; y++) {
        if (_puzzle![y][x].value == index + 1) {
          count++;
        }
      }
    }

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
              ? Theme.of(context).primaryColor
              : Theme.of(context).canvasColor,
        ),
        child: OutlinedButton(
          onPressed: () {
            numberButtonPressed(index);
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(300.0))),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
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
                          ? Theme.of(context).canvasColor
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
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox.shrink()
              ),
            ],
          ),
        ),
      ),
    );
  }

  void numberButtonPressed(int index) {
    setState(() {
      if (_selectedNumber == index + 1) {
        _selectedNumber = -1;
      } else {
        _selectedNumber = index + 1;

        // delay each by random amount for nice animation
        Random rand = Random();

        for (int x = 0; x < 9; x++) {
          for (int y = 0; y < 9; y++) {
            if (_puzzle![y][x].value == _selectedNumber) { // TODO maybe check markup
              AnimationController animation = _scaleAnimationControllers[y * 9 + x];

              animation.reset();

              Future.delayed(Duration(milliseconds: rand.nextInt(200)), ()
              {
                animation.reset();
                animation.forward();
              });
            }
          }
        }
      }
    });
  }

  void win(BuildContext context) {
    SaveManager().getScores(widget.difficulty).then(
      (List<Score> scores) => setState(
        () {
          SaveManager().clear(widget.difficulty);

          // record the new score
          SaveManager().recordScore(
              _stopwatch.elapsed + _stopwatchOffset, widget.difficulty);

          // also add it to our local list
          DateTime now = DateTime.now();
          scores.add(Score(_stopwatch.elapsed + _stopwatchOffset, "${now.day} ${DateFormat.yMMM().format(now)}"));
          scores.sort((a, b) => a.time.compareTo(b.time));

          if (scores.length > 10) {
            scores.removeRange(9, scores.length - 1);
          }

          _stopwatch.stop();
          String timeString = timeToString(_stopwatch.elapsed + _stopwatchOffset);

          print("Saved scores: $scores");

          // funny random win string generation
          Random rand = Random();

          List<String> winStrings = [
            "You win!", "Congration, you done it!", "Great job!", "Impressive.",
            "EYYYYYYYY!", "All our base are belong to you.", "You're winner!",
            "A winner is you!", "A ADJECTIVE game!"];

          // make the last entry very likely
          int winStringIndex = rand.nextInt(winStrings.length * 2).clamp(
              0, winStrings.length - 1);
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
            " excellent",
            " concise"
          ];

          winString = winString.replaceAll(
              " ADJECTIVE", adjectives[rand.nextInt(adjectives.length)]);

          bool alreadyHighlighted = false;

          fadePopup(context, AlertDialog(
            title: Center(child: Text(winString)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Difficulty: ${difficulties[widget.difficulty]}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                  [
                    Text("Validations used: $_validations"),
                  ],
                ),
                Text("Time: $timeString"),
                const SizedBox(height: 10),
                scores.isEmpty
                    ? const SizedBox.shrink() : SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: scores.map((score) {
                      bool highlight = false;

                      if(!alreadyHighlighted && timeString == timeToString(score.time)) {
                        alreadyHighlighted = true;
                        highlight = true;
                      }

                      return Container(
                        padding: const EdgeInsets.all(5),
                        color: highlight ? DynamicColorTheme.of(context).color : Colors.transparent,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: highlight
                            ? Theme.of(context).canvasColor
                                  : Theme.of(context).textTheme.bodyMedium!.color!,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:
                            [
                              Text("${scores.indexOf(score) + 1}. ${score.date}"),

                              Text(timeToString(score.time)),
                            ]
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
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
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius
                              .circular(30.0))),
                    ),
                    child: const Text("Got it!")
                  ),
                ),
              ],
            ),
          )
          );
        }
      )
    );
  }

  bool cellInvalid(int x, int y) {
    Cell cell = _puzzle![y][x];

    if(cell.prefill) {
      return false;
    }

    Position pos = cell.pos;
    int value = cell.value;

    // check segment
    List<Cell> segment = List.empty(growable: true);
    int rowStart = y - (y % 3);
    int columnStart = x - (x % 3);

    for(int row = 0; row < 3; row++) {
      for(int column = 0; column < 3; column++) {
        segment.add(_puzzle![row + rowStart][column + columnStart]);
      }
    }

    if(valueRepeats(segment, value)) {
      return true;
    }

    // check row
    List<Cell> row = List.empty(growable: true);
    for(int column = 0; column < 9; column++) {
      row.add(_puzzle![y][column]);
    }

    if(valueRepeats(row, value)) {
      return true;
    }

    // check column
    List<Cell> column = List.empty(growable: true);
    for(int row = 0; row < 9; row++) {
      column.add(_puzzle![row][x]);
    }

    if(valueRepeats(column, value)) {
      return true;
    }

    return false;
  }

  bool valueRepeats(List<Cell> cells, int value) {
    Set<int> seenValues = {};
    for(int i = 0; i < cells.length; i++) {
      int curVal = cells[i].value;

      if (seenValues.contains(curVal) && curVal == value) {
        return true;
      }

      seenValues.add(curVal);
    }

    return false;
  }
}
