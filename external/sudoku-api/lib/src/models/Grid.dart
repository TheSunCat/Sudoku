import 'dart:async';
import '../logic/GridUtils.dart';
import 'Position.dart';
import 'Cell.dart';

/// Container for holding 9x9 cell matrix
/// For an example of what a 9x9 grid looks like, see [Position]
class Grid {
  List<List<Cell>>? _matrix;
  late StreamController _onChange;
  late List<StreamSubscription> _cellStreamSubs;

  /// Constructs a grid with matrix of cells whose value is all empty
  Grid() {
    _matrix = List.generate(
        9,
        (_) => List<Cell>.filled(
            9, new Cell(new Position(row: 0, column: 0, index: 0)),
            growable: false),
        growable: false);
    _buildEmpty();
  }

  Grid._(List<List<Cell>>? matrix) : this._matrix = matrix;

  /// Serialization
  ///
  factory Grid.fromMap(Map<String, dynamic> map) {
    return Grid._(
      map["matrix"] == null
          ? null
          : List<List<Cell>>.from(map["matrix"]
              .map((x) => List<Cell>.from(x.map((x) => Cell.fromMap(x))))),
    );
  }
  Map<String, dynamic> toMap() => {
        "matrix": _matrix == null
            ? null
            : List<dynamic>.from(_matrix!
                .map((x) => List<dynamic>.from(x.map((x) => x.toMap())))),
      };

  /// Constructs a matrix of cells whose value is all empty
  void _buildEmpty() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        _matrix![r][c] = new Cell(new Position(row: r, column: c));
      }
    }
  }

  /// Attach listeners for each cell - the grid is now listening for changes to
  /// any cell, and will broadcast them through [_onChange]
  void startListening() {
    _cellStreamSubs = [];
    _onChange = new StreamController.broadcast();

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        _cellStreamSubs
            .add(_matrix![r][c].change.listen((cell) => _onChange.add(cell)));
      }
    }
  }

  /// Detach all subscriptions to cell streams - stop listening to changes
  void stopListening() {
    for (StreamSubscription sub in _cellStreamSubs) {
      sub.cancel();
    }
  }

  /// Pre-generates the first row of grid with randomized values
  void pregenFirstRow() {
    /// Generate digit collection
    List<int> vals = [];
    for (int i = 1; i < 10; i++) {
      vals.add(i);
    }
    vals.shuffle();

    for (int c = 0; c < 9; c++) {
      _matrix![0][c].setValue(vals[c]);
      _matrix![0][c].setPrefill(true);
      _matrix![0][c].setValidity(true);
    }
  }

  /// Returns a list of [Cell] at row # [rowNum]
  List<Cell> getRow(int rowNum) {
    throwIfInvalid(new Position(row: rowNum, column: 0));
    return _matrix![rowNum];
  }

  /// Returns a list of [Cell] at row # [colNum]
  List<Cell> getColumn(int colNum) {
    throwIfInvalid(new Position(row: 0, column: colNum));
    List<Cell> _tmpCol = [];

    for (int c = 0; c < 9; c++) {
      _tmpCol.add(_matrix![c][colNum]);
    }
    return _tmpCol;
  }

  /// Returns a list of [Cell] at segment defined by [position.segment]
  List<Cell> getSegment(Position position) {
    throwIfInvalid(position);
    List<Cell> _tmpSeg = [];

    for (int rInc = 0; rInc < 3; rInc++) {
      for (int cInc = 0; cInc < 3; cInc++) {
        _tmpSeg.add(_matrix![(position.segment!.x * 3) + rInc as int]
            [(position.segment!.y * 3) + cInc as int]);
      }
    }
    return _tmpSeg;
  }

  /// Determines if any of [cells] have the same value, returns true if so
  /// Excludes empty cells (cells whose value is 0)
  bool _doesCellCollectionHaveViolatedCells(List<Cell> cells) {
    Set<int?> _seenValues = new Set<int?>();

    for (Cell cell in cells) {
      if (cell.getValue() == 0) {
        continue;
      } else if (_seenValues.contains(cell.getValue())) {
        return true;
      }
      _seenValues.add(cell.getValue());
    }

    return false;
  }

  /// Determines if a row is violated by using a [Set] of [Cell] values
  /// If, while building this [Set], a duplicate value is going to be added,
  /// then this row is violated
  /// No violations are counted for empty cells (cells whose value is 0)
  bool isRowViolated(Position position) {
    return _doesCellCollectionHaveViolatedCells(getRow(position.grid!.x as int));
  }

  /// Determines if a column is violated by using a [Set] of [Cell] values
  /// If, while building this [Set], a duplicate value is going to be added,
  /// then this column is violated
  /// No violations are counted for empty cells (cells whose value is 0)
  bool isColumnViolated(Position position) {
    return _doesCellCollectionHaveViolatedCells(getColumn(position.grid!.y as int));
  }

  /// Determines if a segment is violated by using a [Set] of [Cell] values
  /// If, while building this [Set], a duplicate value is going to be added,
  /// then this segment is violated
  /// No violations are counted for empty cells (cells whose value is 0)
  bool isSegmentViolated(Position position) {
    return _doesCellCollectionHaveViolatedCells(getSegment(position));
  }

  /// Getters and setters
  /// I can only make these comments so interesting and no more :l
  Cell cellAt(Position pos) => _matrix![pos.grid!.x as int][pos.grid!.y as int];
  Stream get change => _onChange.stream.asBroadcastStream();
  List<List<Cell>>? matrix() => _matrix;
}

/// Performs a DEEP clone of a grid
/// When talking about cloning, it (mostly) boils down to two types;
/// Shallow: Constructs new object in new member space, but inserts references
///          for as many of that objects fields as possible.
/// Deep:    Constructs a new object in new memory space, along with new objects
///          for all fields within that object.
Grid deepClone(Grid? source) {
  Grid _target = new Grid();

  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      _target.matrix()![r][c].setValidity(source!.matrix()![r][c].valid());
      _target.matrix()![r][c].setPristine(source.matrix()![r][c].pristine());
      _target.matrix()![r][c].addMarkupSet(source.matrix()![r][c].getMarkup()!);
      _target.matrix()![r][c].setValue(source.matrix()![r][c].getValue());
      _target.matrix()![r][c].setPrefill(source.matrix()![r][c].prefill());
    }
  }
  return _target;
}
