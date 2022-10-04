import 'dart:math';

import '../logic/SudokuException.dart';

/// Represents the cartesian position of a cell on a typical Sudoku 9x9 grid
/// X and Y are row and column respectfully.
///
///           SEG0    SEG1    SEG2
///          0 1 2   3 4 5   6 7 8
///        -------------------------
///      0 | 0 0 0 | 0 0 0 | 0 0 0 |
/// SEG0 1 | 0 0 0 | 0 0 0 | 0 0 0 |
///      2 | 0 0 0 | 0 0 0 | 0 0 0 |
///        -------------------------
///      3 | 0 0 0 | 0 0 0 | 0 0 0 |
/// SEG1 4 | 0 0 0 | 0 0 0 | 0 0 0 |
///      5 | 0 0 0 | 0 0 0 | 0 0 0 |
///        -------------------------
///      6 | 0 0 0 | 0 0 0 | 0 0 0 |
/// SEG2 7 | 0 0 0 | 0 0 0 | 0 0 0 |
///      8 | 0 0 0 | 0 0 0 | 0 0 0 |
///        -------------------------
class Position {
  Point? grid;
  Point? segment;
  int? index;

  /// Construct a cell position, using either a [row]/[column] pair, or [index]
  Position({int row = -1, int column = -1, int index = -1}) {
    /// If index is supplied
    if (index != -1) {
      grid = new Point((index / 9).floor(), index % 9);
      segment = _segmentFromGridPos(grid!.x as int, grid!.y as int);
      this.index = index;

      /// If row/column is supplied
    } else if (row != -1 && column != -1) {
      grid = new Point(row, column);
      segment = _segmentFromGridPos(row, column);
      this.index = (row * 9) + column;

      /// If nothing is supplied (hey, that's illegal)
    } else {
      throw new InvalidPositionException("Cannot generate Position without "
          "row/column, or cell index");
    }
  }

  Position._({this.grid, this.segment, this.index});

  /// Serialization
  ///
  factory Position.fromMap(Map<String, dynamic> json) => Position._(
    grid: json["grid"] == null ? null : Point(json["grid"]["x"], json["grid"]["y"]),
    segment: json["segment"] == null ? null : Point(json["segment"]["x"], json["segment"]["y"]),
    index: json["index"] == null ? null : json["index"],
  );
  Map<String, dynamic> toMap() => {
    "grid": grid == null ? null : {"x": grid!.x, "y": grid!.y},
    "segment": segment == null ? null : {"x": segment!.x, "y": segment!.y},
    "index": index == null ? null : index,
  };


  /// Determine segment of the grid a cell is at using [row] and [col]
  /// Returned as a point, where X and Y are row and column respectfully.
  Point _segmentFromGridPos(int row, int col) =>
      new Point((row / 3).floor(), (col / 3).floor());

  /// Determine if position is valid via simple range check of [index]
  bool isValid() {
    if (index! < 0 || index! > 80) {
      return true;
    }
    return false;
  }
}
