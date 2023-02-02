import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudoku/painters.dart';
import 'package:sudoku/stack.dart';
import 'package:sudoku/sudoku.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

import 'move.dart';

class GameBoard extends StatefulWidget {
  final Function(List<List<Cell>>)? onBoardChanged;
  final Function(Cell cell)? onCellTapped;
  final Function(BuildContext)? onGameWon;
  final Function()? onReady;
  final Function(Duration)? setStopwatchOffset;
  final int highlightNum;
  final bool marking;
  final int difficulty;
  final Sudoku? savedGame;

  const GameBoard({super.key,
    required this.onBoardChanged, required this.onCellTapped,
    required this.onGameWon, this.highlightNum = -1, required this.marking,
    required this.onReady, this.setStopwatchOffset,
    this.difficulty = 0, this.savedGame});

  @override
  State<StatefulWidget> createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  static const int _boardLength = 9;

  List<List<Cell>>? _puzzle;
  bool _generated = false;
  bool _hasReset = false;

  int _validations = 0;

  final LIFO<List<Move>> _undoStack = LIFO();

  final List<Position> _validationWrongCells = List.empty(growable: true);

  late List<AnimationController> _scaleAnimationControllers;
  late List<Animation<double>> _scaleAnimations;
  late AnimationController _noAnimationController;
  late Animation<double> _noAnimation;

  @override
  Widget build(BuildContext context) {
    ensurePuzzle();

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _boardLength,
          ),
          itemBuilder: _buildGridItems,
          itemCount: _boardLength * _boardLength,
          primary: true,
          // disable scrolling
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }

  Widget _buildGridItems(BuildContext context, int index) {
    int boardLength = 9;
    int sectorLength = 3;

    int x,
        y = 0;
    x = (index % boardLength);
    y = (index / boardLength).floor();

    // not my best code...
    Border border = Border(
      right: ((x % sectorLength == sectorLength - 1) && (x != boardLength - 1))
          ? BorderSide(width: 2.0, color: Theme
          .of(context)
          .primaryColor)
          : ((x == boardLength - 1)
          ? BorderSide.none
          : BorderSide(width: 1.0, color: Theme
          .of(context)
          .dividerColor)),
      bottom: ((y % sectorLength == sectorLength - 1) && (y != boardLength - 1))
          ? BorderSide(width: 2.0, color: Theme
          .of(context)
          .primaryColor)
          : ((y == boardLength - 1)
          ? BorderSide.none
          : BorderSide(width: 1.0, color: Theme
          .of(context)
          .dividerColor)),
    );

    return GestureDetector(
      onTap: () => onCellTapped(x, y),
      child: Container( // for tap target
        color: Colors.transparent,
        child: GridTile(
          child: CustomPaint(
            foregroundPainter: EdgePainter(
                border, x != boardLength - 1, y != boardLength - 1),
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

    Cell cell = _puzzle![y][x];
    int val = cell.value;

    if (val == 0 && cell.markup.isEmpty) {
      return const SizedBox.shrink();
    } // show nothing for empty cells

    Color textColor = Theme
        .of(context)
        .textTheme
        .bodyMedium!
        .color!;
    Color itemColor = Colors.transparent;

    if (cell.prefill) {
      textColor = textColor.withOpacity(0.65);
      itemColor = textColor.withOpacity(0.07);
    }

    bool highlighted = false;

    if (val == widget.highlightNum || cell.markup.contains(widget.highlightNum)) {
      itemColor = Theme
          .of(context)
          .primaryColor;
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
                builder: (context, child) =>
                    DefaultTextStyle(
                        style: DefaultTextStyle
                            .of(context)
                            .style
                            .apply(
                            decoration: TextDecoration.none,
                            color: highlighted
                                ? ColorTween(begin: textColor, end: Theme
                                .of(context)
                                .canvasColor)
                                .animate(animation)
                                .value!
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

  void onCellTapped(int x, int y) {
    if (_puzzle == null) {
      return;
    }

    Cell cell = _puzzle![y][x];

    //widget.onCellTapped!(cell);

    if (cell.prefill) {
      return;
    }

    // place cell
    setState(() {
      _undoStack
          .push([Move(x, y, cell.value, List.from(cell.markup))]);

      AnimationController animation = _scaleAnimationControllers[y * 9 + x];

      if (widget.highlightNum != 10) {
        if (!widget.marking && cell.value == widget.highlightNum) {
          // wait for animation
          Future.delayed(const Duration(milliseconds: 190), () {
            setState(() {
              _puzzle![y][x].value = 0;
              widget.onBoardChanged!(_puzzle!);
            });
          });

          _validationWrongCells.removeWhere(
                  (element) => (x == element.x && y == element.y));

          animation.reset();
          animation.reverse(from: 1.0);
        } else {
          if (widget.marking && widget.highlightNum > 0) {
            if (cell.markup.isEmpty ||
                (!cell.markup.contains(widget.highlightNum) &&
                    cell.markup.length <= 8)) {
              cell.markup.add(widget.highlightNum);

              animation.reset();
              animation.forward();
            } else {
              animation.reset();
              animation.reverse(from: 1.0);

              cell.markup.removeWhere((int val) => val == widget.highlightNum);

              Future.delayed(const Duration(milliseconds: 500), () {
                if (cell.markup.isNotEmpty) {
                  animation.reset();
                  animation.forward();
                }
              });
            }

            _puzzle![y][x].value = 0;
          } else if(widget.highlightNum != -1) {
            cell.markup.clear();
            _puzzle![y][x].value = widget.highlightNum;

            // remove markups that are no longer valid
            for (int row = 0; row < 9; row++) {
              _puzzle![row][x].markup.removeWhere((int val) {
                bool ret = val == widget.highlightNum;

                if (ret) {
                  _undoStack.peek.add(Move(x, row, _puzzle![row][x].value,
                      List.from(_puzzle![row][x].markup)));
                }

                return ret;
              });
            }

            for (int column = 0; column < 9; column++) {
              _puzzle![y][column].markup.removeWhere((int val) {
                bool ret = val == widget.highlightNum;

                if (ret) {
                  _undoStack.peek.add(Move(column, y,
                      _puzzle![y][column].value,
                      List.from(_puzzle![y][column].markup)));
                }

                return ret;
              });
            }

            int rowStart = y - (y % 3);
            int columnStart = x - (x % 3);
            for (int row = rowStart; row < rowStart + 3; row++) {
              for (int column = columnStart; column <
                  columnStart + 3; column++) {
                _puzzle![row][column].markup.removeWhere((int val) {
                  bool ret = val == widget.highlightNum;

                  if (ret) {
                    _undoStack.peek.add(Move(
                        column, row, _puzzle![row][column].value,
                        List.from(_puzzle![row][column].markup)));
                  }

                  return ret;
                });
              }
            }

            animation.reset();
            animation.forward();
          }

          widget.onBoardChanged!(_puzzle!);

          _validationWrongCells.removeWhere(
                  (element) => (x == element.x && y == element.y));

          List<List<int>> sudoku = List.empty(growable: true);
          for (int row = 0; row < 9; row++) {
            sudoku.add(
                List.generate(9, (column) => _puzzle![row][column].value));
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

        widget.onBoardChanged!(_puzzle!);

        _validationWrongCells.removeWhere(
                (element) => (x == element.x && y == element.y));

        animation.reset();
        animation.reverse(from: 1.0);
      }
    });
  }

  void win(BuildContext context) {
    widget.onGameWon!(context);
  }

  void ensurePuzzle() {
    if (_puzzle == null) {
      if(widget.savedGame == null || _hasReset) {
        // TODO async?
        int clues = (difficulties.length - widget.difficulty) * 6;

        _puzzle = List.empty(growable: true);

        List<List<int>> board = SudokuGenerator(emptySquares: 60 - clues).newSudoku;

        for(int row = 0; row < board.length; row++) {
          _puzzle!.add(List.generate(9, (column) {
            int val = board[row][column];
            return Cell(Position(column, row), val, val != 0);
          }));
        }

        onReady();
      } else {

        _puzzle = widget.savedGame!.game;
        widget.setStopwatchOffset!(Duration(seconds: widget.savedGame!.time));
        onReady();
      }
    }
  }

  void onReady() {
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

    // save the new game
    widget.onBoardChanged!(_puzzle!);

    widget.onReady!();
  }

  void validate() {
    _validations++;

    _validationWrongCells.clear();

    setState(() {
      for (int x = 0; x < 9; x++) {
        for (int y = 0; y < 9; y++) {
          Cell cell = _puzzle![y][x];
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
  }

  bool cellInvalid(int x, int y) {
    Cell cell = _puzzle![y][x];

    if(cell.prefill) {
      return false;
    }

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

  void restart() {
    setState(() {
      _puzzle = null; // cause the board to be re-generated
      _validationWrongCells.clear();
      _undoStack.clear();

      // set flag to ignore saved game
      _hasReset = true;
    });
  }

  void undo() {
    if (_undoStack.isEmpty) {
      return;
    }

    // undo the move
    setState(() {
      _undoStack.pop().forEach((move) {
        Cell cell = _puzzle![move.y][move.x];

        cell.value = move.value;

        cell.markup.clear();
        for (var element in move.markup) {
          cell.markup.add(element);
        }

        // reset animation
        AnimationController animation = _scaleAnimationControllers[move.y * 9 + move.x];
        animation.reset();
        animation.forward();

        // save the board
        widget.onBoardChanged!(_puzzle!);
      });
    });
  }

  void updateHighlightedNum(int highlightedNum) {
    // delay each by random amount for nice animation
    Random rand = Random();

    for (int x = 0; x < 9; x++) {
      for (int y = 0; y < 9; y++) {
        if (_puzzle![y][x].value == highlightedNum) { // TODO maybe check markup
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

  int getValidations() {
    return _validations;
  }

  int countCellsOf(int val) {
    int count = 0;

    for (int x = 0; x < 9; x++) {
      for (int y = 0; y < 9; y++) {
        if (_puzzle![y][x].value == val) {
          count++;
        }
      }
    }

    return count;
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
    super.dispose();

    for(int i = 0; i < _scaleAnimationControllers.length; i++) {
      _scaleAnimationControllers[i].dispose();
    }
  }
}