import 'models/Position.dart';
import 'models/Grid.dart';
import 'models/Cell.dart';

/// Puzzle Solver class which implements solving and validation functionality
/// Implementation based on my previous project; Java Sudoku
/// https://github.com/AlvinRamoutar/Sudoku
class Solver {
  Grid? _solvedBoard;
  bool _solutionAttained = false;
  int _ambiguousSolutions = 0;

  Solver({Grid? solvedBoard}) : _solvedBoard = solvedBoard;

  ///
  ///
  Future<Grid?> solveFromGrid(Grid grid) async {
    _solvedBoard = new Grid();
    _solve(grid, 0);
    return _solvedBoard;
  }

  Future<Grid?> solve() async {
    _solvedBoard = new Grid();
    Grid _tmpGrid = new Grid();
    _tmpGrid.pregenFirstRow();
    _solve(_tmpGrid, 0);
    return _solvedBoard;
  }

  /// Recursive method that utilizes Dancing Links to solve Sudoku Puzzles
  /// A simple brute-force approach, in which iterates through one [index] at a
  /// time of [board], tests a valid value, and continues. Should an error appear
  /// somewhere during the solve, then rollback until the last successful
  /// cell/validation, and try again.
  void _solve(Grid board, int indice) {
    //When the final index is reached, grid is solved. Store as solved grid.
    if (indice == 81) {
      for (int o = 0; o < 9; o++) {
        for (int i = 0; i < 9; i++) {
          _solvedBoard!.matrix()![o][i].setValue(board.matrix()![o][i].getValue());
          _solvedBoard!.matrix()![o][i].setValidity(true);
          _solvedBoard!.matrix()![o][i].setPrefill(true);
        }
      }
      _solutionAttained = true;
    } else {
      //Use recursion to continuously iterate through indexes until 81
      int row = (indice / 9).floor();
      int col = indice % 9;

      if (_solutionAttained) {
        //Proceed to pre-filled cells
      } else if (board.matrix()![row][col].getValue() != 0) {
        _solve(board, indice + 1);
      } else {
        //Currently at a location that requires a value, try all possibilities
        for (int i = 1; i <= 9; i++) {
          if (consistent(board, new Position(row: row, column: col), i)) {
            board.matrix()![row][col].setValue(i);
            _solve(board, indice + 1);
            board.matrix()![row][col].setValue(0);
          }
        }
      }
      //If this point is reached, there is no valid solution for the grid
    }
  }

  /// Initializes an ambiguity check with a supplied [grid], and returns true
  /// if ambiguous
  Future<bool> checkAmbiguity(Grid grid) async {
    Grid _tmpGrid = deepClone(grid);
    _checkAmbiguity(_tmpGrid, 0);
    if (_ambiguousSolutions == 1) {
      return false; //Puzzle has only 1 valid solution (good).
    } else {
      return true; //Various solutions exist for the same puzzle (bad).
    }
  }

  /// Performs an ambiguity check on [board] by using similar logic as Solver
  /// Iterates through each [indice]
  void _checkAmbiguity(Grid board, int indice) {
    //Increment solution count if a valid one is attained
    if (indice == 81) {
      _ambiguousSolutions++;
    } else {
      //Recursive solve
      int row = (indice / 9).floor();
      int col = indice % 9;

      if (_ambiguousSolutions > 2) {
      } else if (board.matrix()![row][col].getValue() != 0) {
        _checkAmbiguity(board, indice + 1);
      } else {
        for (int i = 1; i <= 9; i++) {
          if (consistent(board, new Position(row: row, column: col), i)) {
            board.matrix()![row][col].setValue(i);
            _checkAmbiguity(board, indice + 1);
            board.matrix()![row][col].setValue(0);
          }
        }
      }
    }
  }

  /// Validates [board] consistency from the position of a cell into an index
  /// Used by [solve] and [checkAmbiguity] to validate [c].
  /// Will return true if [c] does not violate board.
  bool consistent(Grid board, Position pos, int c) {
    // Checks columns and rows
    for (int i = 0; i < 9; i++) {
      if (board.matrix()![pos.grid!.x as int][i].getValue() == c ||
          board.matrix()![i][pos.grid!.y as int].getValue() == c) return false;
    }

    // Checks segment of grid
    for (Cell cell in board.getSegment(pos)) {
      if (cell.getValue() == c) {
        return false;
      }
    }

    return true;
  }

  Grid? solvedBoard() => _solvedBoard;
}
