import 'dart:async';

import 'package:sudoku_api/src/logic/SudokuException.dart';

import 'Patterner.dart';
import 'Solver.dart';

import 'logic/PuzzleUtils.dart';

import 'models/Cell.dart';
import 'models/Grid.dart';
import 'models/Position.dart';
import 'models/PuzzleOptions.dart';

/// Sudoku Puzzle Class
/// Handles:
/// - Puzzle options
/// - Generation
/// - Observable grid change
/// - Stopwatch
class Puzzle {
  late Solver _solver;
  Grid? _board;
  late Patterner _patterner;
  PuzzleOptions? _options;
  late Stopwatch _stopwatch;
  int? _timeElapsedInSeconds =
      0; // holds the elapsed time for when getting converted to a map

  late StreamSubscription _boardChangeStreamSub;
  Function(Cell)? _onChangeHandler;

  /// Constructs a new Sudoku puzzle - don't forget to run [generate]
  Puzzle(PuzzleOptions options) {
    _options = options;
    _stopwatch = new Stopwatch();
    _solver = new Solver();
    _patterner = new Patterner();
  }

  /// Private constructor - For when using [Puzzle.fromJson] to get a previously generated puzzle
  Puzzle._({
    Grid? board,
    Grid? solvedBoard,
    PuzzleOptions? options,
    int? timeElapsedInSeconds = 0,
  }) {
    _options = options;
    _board = board;
    _timeElapsedInSeconds = timeElapsedInSeconds;
    _patterner = Patterner();
    _stopwatch = Stopwatch();
    _solver = Solver(solvedBoard: solvedBoard);

    _board!.startListening();
    _boardChangeStreamSub =
        _board!.change.listen((cell) => _onBoardChange(cell));
  }

  /// Serialization
  ///
  factory Puzzle.fromJson(Map<String, dynamic> map) {
    if (!map.containsKey('board') ||
        !map.containsKey('options') ||
        !map.containsKey('solved_board')) {
      throw ('Missing board or options in the map');
    }
    return Puzzle._(
        board: Grid.fromJson(map['board']),
        solvedBoard: Grid.fromJson(map['solved_board']),
        options: PuzzleOptions.fromJson(map['options']),
        timeElapsedInSeconds: map['time_elapsed_in_seconds']);
  }
  Map<String, dynamic> toJson() => {
        "board": board() == null ? null : board()!.toJson(),
        "solved_board": _solver.solvedBoard() == null
            ? null
            : _solver.solvedBoard()!.toJson(),
        "options": options() == null ? null : options()!.toJson(),
        "time_elapsed_in_seconds": getTimeElapsed().inSeconds
      };

  /// Generates a new puzzle using parameters set in [_options]
  Future<bool> generate() async {
    if (_board != null) GenerationException('Board already generated');

    await _solver.solve();
    _board = deepClone(_solver.solvedBoard());

    if (_options!.patternName!.toLowerCase() == "random") {
      _patterner.buildGridFromRandom(_board, _options!.clues!);
    } else {
      _patterner.buildGridFromPattern(_board, _options!.patternName);
    }

    _board!.startListening();
    _boardChangeStreamSub =
        _board!.change.listen((cell) => _onBoardChange(cell));

    return true;
  }

  /// Calls supplied [_onChangeHandler], if you have any assigned through
  /// [onBoardChange]
  void _onBoardChange(Cell cell) {
    if (_onChangeHandler != null) {
      _onChangeHandler!(cell);
    }
  }

  /// Set a [handler] function, which will be called whenever the grid changes.
  /// A change is whenever a cell experiences a change in value.
  void onBoardChange(Function(Cell) handler) {
    _onChangeHandler = handler;
  }

  /// Fill a particular [Cell] at [position] with [value], and returns a list of
  /// [CellViolation]
  /// For what violations are, please refer to [CellViolation] enum
  List<CellViolation> fillCell(Position position, int value) {
    Cell _target = _board!.cellAt(position);
    _target.setValue(value);

    List<CellViolation> _violations = new List<CellViolation>.empty(growable: true);

    if (board()!.isRowViolated(position)) {
      _violations.add(CellViolation.Row);
    }
    if (board()!.isColumnViolated(position)) {
      _violations.add(CellViolation.Column);
    }
    if (board()!.isSegmentViolated(position)) {
      _violations.add(CellViolation.Segment);
    }
    if (_target.getValue() !=
        _solver.solvedBoard()!.cellAt(position).getValue()) {
      _violations.add(CellViolation.Solution);
    }

    return _violations;
  }

  /// Terminate listeners, and prepare [Puzzle] for closure
  void dispose() {
    _boardChangeStreamSub.cancel();
    _board!.stopListening();
  }

  /// Getters and setters
  /// I can only make these comments so interesting and no more :l
  void startStopwatch() => _stopwatch.start();
  void stopStopwatch() => _stopwatch.stop();

  ///to check stopwatch is paused or not
  bool get isStopwatchRunning => _stopwatch.isRunning;

  /// Add the time elapsed in case the game is being reloaded from map/storage
  Duration getTimeElapsed() =>
      Duration(seconds: _timeElapsedInSeconds!) + _stopwatch.elapsed;

  Grid? board() => this._board;
  Grid? solvedBoard() => this._solver.solvedBoard();

  PuzzleOptions? options() => this._options;
}
