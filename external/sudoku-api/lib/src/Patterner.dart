import 'logic/SudokuException.dart';
import 'models/PatternSet.dart';
import 'models/Pattern.dart';
import 'models/Grid.dart';
import 'models/Position.dart';

/// Controller for managing patterns, and building puzzles out of them
class Patterner {
  late PatternSet patternSet;

  /// Create new patterner and inits [patternSet] with default seasonal pattern
  Patterner() {
    patternSet = new PatternSet();
    patternSet.loadDefaults();
  }

  /// Modifies [grid] according to pattern identified by [patternName]
  /// For built-in patterns, check out [PatternSet]
  Grid? buildGridFromPattern(Grid? grid, String? patternName) {
    /// Retrieve from PatternSet
    Pattern? pattern = patternSet.firstWhere((p) => p.getName() == patternName);

    /// Modifies grid according to pattern, replacing clues with empty cells
    String _patrow = "";
    for (int row = 0; row < 9; row++) {
      _patrow = pattern.getMap()![row]!.replaceAll(' ', '');

      for (int col = 0; col < 9; col++) {
        if (_patrow.codeUnitAt(col) != HOLDER_CODE) {
          grid!.matrix()![row][col].clear();
        }
      }
    }

    return grid;
  }

  /// Modifies [grid] according to random pattern and [cellsRemaining] (clues)
  Grid? buildGridFromRandom(Grid? grid, int cellsRemaining) {
    /// Catch for those trying to generate illegal grids
    if (cellsRemaining > 80 || cellsRemaining < 1) {
      throw new InvalidPatternException("Cannot generate random grid with "
          "$cellsRemaining cells remaining (min: 1, max: 80)");
    }

    Position pos;
    List<int> cellIndices = [];

    for (int i = 0; i < 81; i++) {
      cellIndices.add(i);
    }
    cellIndices.shuffle();

    /// Randomly pull index val. between [0, 80] and clear that cell
    while (cellIndices.length != cellsRemaining) {
      pos = new Position(index: cellIndices.removeLast());
      grid!.matrix()![pos.grid!.x as int][pos.grid!.y as int].clear();
    }

    return grid;
  }
}
