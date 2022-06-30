import 'package:sudoku_api/sudoku_api.dart';

void main() {

  PuzzleOptions puzzleOptions = new PuzzleOptions(patternName: "winter");

  Puzzle puzzle = new Puzzle(puzzleOptions);

  puzzle.generate().then((_) {
    print("=====================================");
    print("Your puzzle, fresh off the press:");
    print("-------------------------------------");
    printGrid(puzzle.board());
    print("=====================================");
    print("Give up? Here's your puzzle solution:");
    print("-------------------------------------");
    printGrid(puzzle.solvedBoard());
    print("=====================================");
  });
}