import 'dart:async';

import 'package:test/test.dart';
import 'package:sudoku_api/sudoku_api.dart';

void main() async {
  final PuzzleOptions puzzleOptions =
      PuzzleOptions(patternName: "winter", name: "options test");
  final Puzzle puzzle = Puzzle(puzzleOptions);
  await puzzle.generate();

  String serializationTestTitle01 = 'Test Puzzle conversion toMap';
  test(serializationTestTitle01, () {
    final Map<String, dynamic> puzzleMap = puzzle.toMap();
    final Puzzle newPuzzle = Puzzle.fromMap(puzzleMap);
    expect(newPuzzle, isA<Puzzle>());
  });

  String serializationTestTitle02 = 'Test solved board is still the same';
  test(serializationTestTitle02, () {
    final Map<String, dynamic> puzzleMap = puzzle.toMap();
    final Puzzle newPuzzle = Puzzle.fromMap(puzzleMap);
    expect(newPuzzle.solvedBoard()!.toMap(), puzzle.solvedBoard()!.toMap());
  });

  String serializationTestTitle03 =
      'Test the time management through serialization';
  test(serializationTestTitle03, () async {
    puzzle.startStopwatch();
    await Future.delayed(const Duration(seconds: 5), () {});
    puzzle.stopStopwatch();
    final Map<String, dynamic> puzzleMap = puzzle.toMap();
    final Puzzle newPuzzle = Puzzle.fromMap(puzzleMap);
    expect(newPuzzle.getTimeElapsed(), Duration(seconds: 5));
  });

  String serializationTestTitle04 = 'Test markup';
  test(serializationTestTitle04, () async {
    int posIndex = -1;
    for (int i = 0; i < 81; i++) {
      if (!puzzle.board()!.cellAt(new Position(index: i)).prefill()!) {
        posIndex = i;
        puzzle.board()!.cellAt(new Position(index: i)).addMarkup(5);
        puzzle.board()!.cellAt(new Position(index: i)).addMarkup(7);
        puzzle.board()!.cellAt(new Position(index: i)).addMarkup(9);
      }
    }

    final Map<String, dynamic> puzzleMap = puzzle.toMap();
    final Puzzle newPuzzle = Puzzle.fromMap(puzzleMap);
    expect(
        newPuzzle
            .board()!
            .cellAt(new Position(index: posIndex))
            .getMarkup()!
            .length,
        puzzle
            .board()!
            .cellAt(new Position(index: posIndex))
            .getMarkup()!
            .length);
  });
}
