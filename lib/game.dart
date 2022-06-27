import 'package:flutter/material.dart';
import 'package:sudoku_api/sudoku_api.dart';

class SudokuGame extends StatefulWidget {
  const SudokuGame({Key? key}) : super(key: key);

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  final Puzzle _puzzle = Puzzle(PuzzleOptions(patternName: "random"));
  Grid _board = Grid();

  _SudokuGameState() {
    _puzzle.generate().then((_) {
      setState(() {
        _board = _puzzle.board()!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int boardLength = 9;

    return Scaffold(
      body: Column(
        children: <Widget>[
          AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0)
            ),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boardLength,
              ),
              itemBuilder: _buildGridItems,
              itemCount: boardLength * boardLength,
            ),
          ),
        ),
      ])
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
      onTap: () => { print("Tapped $x, $y") },
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
            color: Colors.grey.shade300,
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
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}