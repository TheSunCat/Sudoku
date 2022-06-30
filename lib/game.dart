import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sudoku_api/sudoku_api.dart';

class SudokuGame extends StatefulWidget {
  final int clues;

  const SudokuGame({Key? key, required this.clues}) : super(key: key);

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  Puzzle? _puzzle;
  late Grid _board;
  late Grid _solution;

  bool _gameWon = false;

  int _selectedNumber = -1;

  late Timer refreshTimer;
  _SudokuGameState() : super() {
    // refresh the timer every second
    refreshTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) => setState((){}));
  }

  @override
  void dispose() {
    super.dispose();

    refreshTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_puzzle == null) {
      _puzzle = Puzzle(PuzzleOptions(patternName: "random", clues: widget.clues));

      _puzzle!.generate().then((_) {
        _puzzle!.startStopwatch();

        setState(() {
          _board = _puzzle!.board()!;
        });

        _solution =_puzzle!.solvedBoard()!;
      });

      return const Text("Loading...");
    }

    const int boardLength = 9;

    String timeString = "";
    Duration timer = _puzzle!.getTimeElapsed();
    if(timer.inDays != 0) {
      timeString += "${timer.inDays}D ";
    }
    if(timer.inHours != 0) {
      timeString += "${timer.inHours % 24}H ";
    }
    if(timer.inMinutes != 0) {
      timeString += "${timer.inMinutes % 60}M ";
    }
    if(timer.inSeconds != 0) {
      timeString += "${timer.inSeconds % 60}S";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.grey.shade800,
        centerTitle: true,
        title: Text(timeString, style: Theme.of(context).textTheme.bodyMedium),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardLength,
                ),
                itemBuilder: _buildGridItems,
                itemCount: boardLength * boardLength,
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                    ),
                    itemBuilder: _buildNumberButtons,
                    itemCount: 10,
                  ),
                ),
              ],
            ),
          ),
        ]
      )
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
      right:  ((x % sectorLength == sectorLength - 1) && (x != boardLength - 1))
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
        if(_selectedNumber == -1 || _puzzle!.board() == null) {
          return;
        }

        // place cell
        setState(() {
          if(_selectedNumber != 10) {
            if(_puzzle!.board()!.cellAt(Position(row: y, column: x)).getValue() == _selectedNumber)
            {
              _puzzle!.fillCell(Position(row: y, column: x), 0);
            } else {
              _puzzle!.fillCell(Position(row: y, column: x), _selectedNumber);

              Future<bool> solved = isBoardSolved();
              solved.then((value) {
                if(value) {
                  _gameWon = true;
                  print("Won!");
                } else {
                  print("Not won!");
                }
              });
            }
          } else if (!_puzzle!.board()!.cellAt(Position(row: y, column: x)).prefill()!) {
            _puzzle!.fillCell(Position(row: y, column: x), 0);
          }


        });
      },
      child: GridTile(
        child: Container(
          decoration: BoxDecoration(
              border: border
          ),
          child: Center(
            child: _buildGridItem(x, y),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(int x, int y) {
    int val = _board.cellAt(Position(column: x, row: y)).getValue()!;

    if(val == 0) {
      return const SizedBox.shrink();
    } // nothing

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // expand to fill parent
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
            color: (val == _selectedNumber) ? Theme.of(context).primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(100)
          //more than 50% of width makes circle
        ),

        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(val.toString(),
                style: TextStyle(
                  color: (val == _selectedNumber) ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        )
      ),
    );
  }

  Widget _buildNumberButtons(BuildContext context, int index) {
    int count = 0;
    for (int x = 0; x < 9; x++) {
        for (int y = 0; y < 9; y++) {
          if (_board.getColumn(x)[y].getValue() == index + 1) {
            count++;
          }
        }
    }

    String countString = (9 - count).toString();
    if(index == 9 || count == 9) {
      countString = "";
    } else
    {
      if(count > 9)
      {
        countString = "${count - 9}+";
      }
    }


    int selectedIndex = _selectedNumber - 1;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            if(_selectedNumber == index + 1) {
              _selectedNumber = -1;
            } else {
              _selectedNumber = index + 1;
            }
          });
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(300.0))),
          backgroundColor: selectedIndex == index ? MaterialStateProperty.all(Theme.of(context).primaryColor) : null,
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
                    Text((index == 9) ? "X" : (index + 1).toString(),
                      style: TextStyle(
                        color: selectedIndex == index ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    Text(countString,
                      style: TextStyle(
                        color: selectedIndex == index ? Colors.white : Colors.grey.shade600,
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

  Future<bool> isBoardSolved() async
  {
    for(int i = 0; i < 9*9; i++) {
      if(_board.cellAt(Position(index: i)).getValue() == 0) {
        print("Board not full.");
        return false;
      }
    }

    for(int x = 0; x < 9; x++) {
      if(_board.isColumnViolated(Position(column: x, row: 0))) {
        print("Column $x violated.");
        return false;
      }
      if(_board.isRowViolated(Position(row: x, column: 0))) {
        print("Row $x violated.");
        return false;
      }

      if(_board.isSegmentViolated(Position(index: x * 9))) {
        print("Segment $x violated.");
        return false;
      }
    }

    return true;
  }
}