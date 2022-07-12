import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/painters.dart';
import 'package:sudoku/save_manager.dart';
import 'package:sudoku/stack.dart';

import 'package:sudoku_api/sudoku_api.dart';

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
  final Future<Puzzle>? savedGame;

  const SudokuGame({Key? key, required this.difficulty, this.savedGame}) : super(key: key);

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> with TickerProviderStateMixin {
  Puzzle? _puzzle;
  Grid? _board;

  final LIFO<Move> _undoStack = LIFO();


  bool _marking = false;
  int _selectedNumber = -1;

  int _validations = 0;
  final List<Position> _validationWrongCells = List.empty(growable: true);

  late List<AnimationController> _scaleAnimationControllers;
  late List<Animation<double>> _scaleAnimations;

  late Timer refreshTimer;
  _SudokuGameState() : super() {
    // refresh the timer every second
    refreshTimer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => setState(() {}));
  }

  @override
  void initState() {
    super.initState();

    _scaleAnimationControllers = List.generate(9*9, (index) {
      return AnimationController(
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 200),
          vsync: this, value: 0.1);
    });

    _scaleAnimations = List.generate(9*9, (index) {
      return CurvedAnimation(parent: _scaleAnimationControllers[index], curve: Curves.fastLinearToSlowEaseIn);
    });
  }

  @override
  void dispose() {
    super.dispose();

    refreshTimer.cancel();
    _puzzle?.dispose();

    for(int i = 0; i < _scaleAnimationControllers.length; i++) {
      _scaleAnimationControllers[i].dispose();
    }
  }

  void onReady() {
    _puzzle!.onBoardChange((cell) => {
      SaveManager().save(widget.difficulty, _puzzle!)
    });

    _puzzle!.startStopwatch();

    setState(() {
      _board = _puzzle!.board()!;

      Random rand = Random();

      for(int i = 0; i < _scaleAnimationControllers.length; i++) {
        Future.delayed(Duration(milliseconds: rand.nextInt(500)), () {
          _scaleAnimationControllers[i].reset();
          _scaleAnimationControllers[i].forward();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_puzzle == null) {
      if(widget.savedGame == null) {
        print("Generating new game");

        int clues = (difficulties.length - widget.difficulty) * 10;

        _puzzle = Puzzle(PuzzleOptions(patternName: "random", clues: clues));

        _puzzle!.generate().then((_) {
          onReady();
        });
      } else {
        print("Using saved game");

        widget.savedGame!.then((value) {
          _puzzle = value;
          onReady();
        });
      }

      return const SizedBox.shrink();
    }

    const int boardLength = 9;

    String timeString = timeToString(_puzzle!.getTimeElapsed());


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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ColorSettings()),
                  ),
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
                                        Position pos = Position(row: y, column: x);
                                        Cell cell = _board!.cellAt(pos);
                                        if (cell.getValue() != 0 &&
                                            !cell.prefill()!) {

                                          if(cellInvalid(x, y)) {
                                            _validationWrongCells
                                                .add(
                                                Position(row: x, column: y));
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
                                  Move move = _undoStack.pop();
                                  Cell cell = _board!
                                      .cellAt(Position(row: move.y, column: move.x));

                                  cell.setValue(move.value);

                                  cell.clearMarkup();
                                  // ignore: avoid_function_literals_in_foreach_calls
                                  move.markup.forEach(
                                      (element) => {cell.addMarkup(element)});
                                });
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0))),
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
        if (_puzzle!.board() == null) {
          return;
        }

        Position pos = Position(row: y, column: x);
        Cell cell = _board!.cellAt(pos);

        if(_selectedNumber == -1 || cell.prefill()!) {
          numberButtonPressed(cell.getValue()! - 1);
          return;
        }

        // place cell
        setState(() {
          _undoStack
              .push(Move(x, y, cell.getValue()!, List.from(cell.getMarkup()!)));

          AnimationController animation = _scaleAnimationControllers[y * 9 + x];

          if (_selectedNumber != 10) {
            if (!_marking && cell.getValue() == _selectedNumber) {
              // wait for animation
              Future.delayed(const Duration(milliseconds: 190), () {
                setState(() => _puzzle!.fillCell(pos, 0));
              });

              _validationWrongCells.removeWhere(
                  (element) => (x == element.grid!.x && y == element.grid!.y));

              animation.reset();
              animation.reverse(from: 1.0);

            } else {
              if (_marking) {
                if (!cell.markup() ||
                    (!cell.getMarkup()!.contains(_selectedNumber) &&
                        cell.getMarkup()!.length <= 8)) {
                  cell.addMarkup(_selectedNumber);

                  animation.reset();
                  animation.forward();
                } else {
                  animation.reset();
                  animation.reverse(from: 1.0);

                  cell.removeMarkup(_selectedNumber);

                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (cell.getMarkup()!.isNotEmpty) {
                      animation.reset();
                      animation.forward();
                    }
                  });
                }

                _puzzle!.fillCell(pos, 0);

              } else {
                cell.clearMarkup();
                _puzzle!.fillCell(pos, _selectedNumber);

                animation.reset();
                animation.forward();
              }

              _validationWrongCells.removeWhere(
                  (element) => (x == element.grid!.x && y == element.grid!.y));

              Future<bool> solved = isBoardSolved();
              solved.then((value) {

                if (value) {
                  win(context);
                }
              });
            }
          } else if (!cell.prefill()!) {
            // wait for animation
            Future.delayed(const Duration(milliseconds: 500), () {
              cell.clearMarkup();
              _puzzle!.fillCell(pos, 0);
            });

            _validationWrongCells.removeWhere(
                (element) => (x == element.grid!.x && y == element.grid!.y));

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
    if (_board == null) {
      return const SizedBox.shrink();
    }

    Animation<double> animation = _scaleAnimations[y * 9 + x];
    bool animating = !(animation.isDismissed || animation.isCompleted);

    Cell cell = _board!.cellAt(Position(column: x, row: y));
    int val = cell.getValue()!;

    if ((cell.pristine()! && !cell.prefill()!) || (val == 0 && !cell.markup())) {
      return const SizedBox.shrink();
    } // show nothing for empty cells

    Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    Color itemColor = Colors.transparent;

    if(cell.prefill()!) {
      textColor = textColor.withOpacity(0.65);
      itemColor = textColor.withOpacity(0.07);
    }

    bool highlighted = false;

    if (val == _selectedNumber ||
        (cell.markup() && cell.getMarkup()!.contains(_selectedNumber))) {
      itemColor = Theme.of(context).primaryColor;
      highlighted = true;
    }

    if (_validationWrongCells
        .any((element) => ((element.grid!.x == x) && (element.grid!.y == y)))) {
      itemColor = Colors.red.shade300;
      highlighted = true;
    }

    List<String> markup = List.generate(cell.getMarkup()!.length,
        (index) => cell.getMarkup()!.elementAt(index).toString());

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
          AnimatedBuilder(
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
              child: cell.markup()
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
        ]
      ),
    );
  }

  Widget _buildNumberButtons(BuildContext context, int index) {
    if (_board == null) {
      return const SizedBox.shrink();
    }

    int count = 0;
    for (int x = 0; x < 9; x++) {
      for (int y = 0; y < 9; y++) {
        if (_board!.getColumn(x)[y].getValue() == index + 1) {
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
            if (_board!.cellAt(Position(row: y, column: x))
                .getValue()! == _selectedNumber) {
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

  Future<bool> isBoardSolved() async {
    for (int i = 0; i < 9 * 9; i++) {
      if (_board!.cellAt(Position(index: i)).getValue() == 0) {
        return false;
      }
    }

    for (int x = 0; x < 9; x++) {
      if (_board!.isColumnViolated(Position(column: x, row: 0))) {
        return false;
      }
      if (_board!.isRowViolated(Position(row: x, column: 0))) {
        return false;
      }

      if (_board!.isSegmentViolated(Position(index: x * 9))) {
        return false;
      }
    }

    return true;
  }

  String timeToString(Duration time) {
    String timeString = "";

    if (time.inDays != 0) {
      timeString += "${time.inDays}D ";
    }
    if (time.inHours != 0) {
      timeString += "${time.inHours % 24}H ";
    }
    if (time.inMinutes != 0) {
      timeString += "${time.inMinutes % 60}M ";
    }
    if (time.inSeconds != 0) {
      timeString += "${time.inSeconds % 60}S";
    }

    return timeString;
  }

  void win(BuildContext context) {
    SaveManager().clear(widget.difficulty);

    _puzzle!.stopStopwatch();
    String timeString = timeToString(_puzzle!.getTimeElapsed());

    // funny random win string generation
    Random rand = Random();

    List<String> winStrings = [
      "You win!", "Congration, you done it!", "Great job!", "Impressive.",
      "EYYYYYYYY!", "All our base are belong to you.", "You're winner!",
      "A winner is you!", "A ADJECTIVE game."];

    // make the last entry very likely
    int winStringIndex = rand.nextInt(winStrings.length * 2).clamp(0, winStrings.length - 1);
    String winString = winStrings[winStringIndex];

    List<String> adjectives = [
      " charming", " determined", " fabulous", " dynamic", "n imaginative",
      " breathtaking", " brilliant", "n elegant", " lovely", " spectacular"
    ];

    winString.replaceAll(" ADJECTIVE", adjectives[rand.nextInt(adjectives.length)]);

    fadePopup(context, AlertDialog(
      title: Center(child: Text(winString)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Difficulty: ${difficulties[widget.difficulty]}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Validations used: $_validations"),
            ],
          ),
          Text("Time: $timeString"),
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
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
              ),
              child: const Text("Got it!")
            ),
          ),
        ],
      ),
    ));
  }

  bool cellInvalid(int x, int y) {
    Cell cell = _board!.cellAt(Position(row: y, column: x));

    if(cell.prefill()!) {
      return false;
    }

    Position pos = cell.getPosition()!;
    int value = cell.getValue()!;

    if(valueRepeats(_board!.getSegment(pos), value)) {
      return true;
    }

    if(valueRepeats(_board!.getRow(y), value)) {
      return true;
    }

    if(valueRepeats(_board!.getColumn(x), value)) {
      return true;
    }

    return false;
  }

  bool valueRepeats(List<Cell> cells, int value) {
    Set<int> seenValues = {};
    for(int i = 0; i < cells.length; i++) {
      int curVal = cells[i].getValue()!;

      if (seenValues.contains(curVal) && curVal == value) {
        return true;
      }

      seenValues.add(curVal);
    }

    return false;
  }
}
