import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudoku/stack.dart';
import 'package:sudoku_api/sudoku_api.dart';

import 'fade_dialog.dart';
import 'move.dart';

class SudokuGame extends StatefulWidget {
  final int clues;

  const SudokuGame({Key? key, required this.clues}) : super(key: key);

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  Puzzle? _puzzle;
  Grid? _board;

  final LIFO<Move> _undoStack = LIFO();

  bool _gameWon = false;

  bool _marking = false;
  int _selectedNumber = -1;
  List<Position> _validationWrongCells = List.empty(growable: true);

  late Timer refreshTimer;
  _SudokuGameState() : super() {
    // refresh the timer every second
    refreshTimer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();

    refreshTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_puzzle == null) {
      _puzzle =
          Puzzle(PuzzleOptions(patternName: "random", clues: widget.clues));

      _puzzle!.generate().then((_) {
        _puzzle!.startStopwatch();

        setState(() {
          _board = _puzzle!.board()!;
        });
      });

      /**
       * TODO is it safe to just carry on and access puzzle data,
       * despite it not being generated yet?
       * Dunno about you, but sounds like a recipe for disaster to me.
       */
    }

    const int boardLength = 9;

    String timeString = "";
    Duration timer = _puzzle!.getTimeElapsed();
    if (timer.inDays != 0) {
      timeString += "${timer.inDays}D ";
    }
    if (timer.inHours != 0) {
      timeString += "${timer.inHours % 24}H ";
    }
    if (timer.inMinutes != 0) {
      timeString += "${timer.inMinutes % 60}M ";
    }
    if (timer.inSeconds != 0) {
      timeString += "${timer.inSeconds % 60}S";
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.grey.shade800,
          centerTitle: true,
          title:
              Text(timeString, style: Theme.of(context).textTheme.bodyMedium),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//        mainAxisAlignment: MainAxisAlignment.center,
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
                      //padding: const EdgeInsets.fromLTRB(80, 40, 80, 0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                        itemBuilder: _buildNumberButtons,
                        itemCount: 10,
                        primary: true, // disable scrolling
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
                          fadeDialog(context, "Are you sure you want to restart this game?", "Cancel", "Restart", () => {}, () {
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
                            _validationWrongCells.clear();

                            setState(() {
                              for (int x = 0; x < 9; x++) {
                                for (int y = 0; y < 9; y++) {
                                  Cell cell =
                                  _board!.cellAt(Position(row: x, column: y));
                                  if (cell.getValue() != 0 &&
                                      !cell.valid()! &&
                                      !cell.pristine()!) {
                                    _validationWrongCells
                                        .add(Position(row: y, column: x));
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
                      child: OutlinedButton(
                        onPressed: () {
                          // toggle marking mode
                          setState(() => {_marking = !_marking});
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              _marking ? Theme.of(context).primaryColor : null),
                          foregroundColor: MaterialStateProperty.all(_marking
                              ? Colors.white
                              : Theme.of(context).primaryColor),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0))),
                        ),
                        child: const Icon(Icons.edit),
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
            ]));
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
          ? BorderSide(width: 2.0, color: Theme.of(context).indicatorColor)
          : ((x == boardLength - 1)
              ? BorderSide.none
              : BorderSide(width: 1.0, color: Theme.of(context).dividerColor)),
      bottom: ((y % sectorLength == sectorLength - 1) && (y != boardLength - 1))
          ? BorderSide(width: 2.0, color: Theme.of(context).indicatorColor)
          : ((y == boardLength - 1)
              ? BorderSide.none
              : BorderSide(width: 1.0, color: Theme.of(context).dividerColor)),
    );

    return GestureDetector(
      onTap: () {
        Position pos = Position(row: y, column: x);
        Cell cell = _board!.cellAt(pos);

        if (_selectedNumber == -1 ||
            _puzzle!.board() == null ||
            cell.prefill()!) {
          return;
        }

        // place cell
        setState(() {
          _undoStack
              .push(Move(x, y, cell.getValue()!, List.from(cell.getMarkup()!)));

          if (_selectedNumber != 10) {
            if (!_marking && cell.getValue() == _selectedNumber) {
              _puzzle!.fillCell(pos, 0);

              _validationWrongCells.removeWhere(
                  (element) => (x == element.grid!.x && y == element.grid!.y));

            } else {
              if (_marking) {
                if (!cell.markup() ||
                    (!cell.getMarkup()!.contains(_selectedNumber) &&
                        cell.getMarkup()!.length <= 8)) {
                  cell.addMarkup(_selectedNumber);
                } else {
                  cell.removeMarkup(_selectedNumber);
                }

                _puzzle!.fillCell(pos, 0);
              } else {
                cell.clearMarkup();
                _puzzle!.fillCell(pos, _selectedNumber);
              }

              _validationWrongCells.removeWhere(
                  (element) => (x == element.grid!.x && y == element.grid!.y));

              Future<bool> solved = isBoardSolved();
              solved.then((value) {
                // TODO win screen

                if (value) {
                  _gameWon = true;
                  print("Won!");
                } else {
                  print("Not won!");
                }
              });
            }
          } else if (!cell.prefill()!) {
            cell.clearMarkup();
            _puzzle!.fillCell(pos, 0);
            _validationWrongCells.removeWhere(
                (element) => (x == element.grid!.x && y == element.grid!.y));
          }
        });
      },
      child: GridTile(
        child: Container(
          decoration: BoxDecoration(border: border),
          child: Center(
            child: _buildGridItem(x, y),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(int x, int y) {
    if (_board == null) {
      return const SizedBox.shrink();
    }

    Cell cell = _board!.cellAt(Position(column: x, row: y));

    int val = cell.getValue()!;

    if (val == 0 && !cell.markup()) {
      return const SizedBox.shrink();
    } // show nothing for empty cells

    Color itemColor = Colors.grey.shade300;

    bool highlighted = false;

    if (val == _selectedNumber ||
        (cell.markup() && cell.getMarkup()!.contains(_selectedNumber))) {
      itemColor = Theme.of(context).primaryColor;
      highlighted = true;
    }

    if (_validationWrongCells
        .any((element) => ((element.grid!.x == x) && (element.grid!.y == y)))) {
      itemColor = Colors.red;
      highlighted = true;
    }

    List<String> markup = List.generate(cell.getMarkup()!.length,
        (index) => cell.getMarkup()!.elementAt(index).toString());

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
          // expand to fill parent
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              color: itemColor, borderRadius: BorderRadius.circular(100)
              //more than 50% of width makes circle
              ),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Center(
                child: cell.markup()
                    ? DefaultTextStyle(
                        style: TextStyle(
                            color: highlighted
                                ? Colors.white
                                : Colors.grey.shade600),
                        child: Column(
                          children: [
                            // TODO this is ugly. Is there a better way?
                            Row(
                              // NQSP to preserve small text size
                              children: [
                                Text(markup.length >= 8 ? markup[7] : " "),
                                Text(markup.length >= 7 ? markup[6] : " "),
                              ],
                            ),
                            Row(
                              children: [
                                Text(markup.length >= 6 ? markup[5] : " "),
                                Text(markup.length >= 5 ? markup[4] : " "),
                                Text(markup.length >= 4 ? markup[3] : " "),
                                Text(markup.length >= 3 ? markup[2] : " "),
                              ],
                            ),
                            Row(
                              children: [
                                Text(markup.length >= 2 ? markup[1] : " "),
                                Text(markup.length >= 1 ? markup[0] : " "),
                              ],
                            )
                          ],
                        ),
                      )
                    : Text(
                        val.toString(),
                        style: TextStyle(
                          color:
                              highlighted ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
              ),
            ),
          )),
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
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            if (_selectedNumber == index + 1) {
              _selectedNumber = -1;
            } else {
              _selectedNumber = index + 1;
            }
          });
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(300.0))),
          backgroundColor: selectedIndex == index
              ? MaterialStateProperty.all(Theme.of(context).primaryColor)
              : null,
        ),
        child: SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 6.0),
                    Text(
                      (index == 9) ? "X" : (index + 1).toString(),
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      countString,
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.white
                            : Colors.grey.shade600,
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
}
