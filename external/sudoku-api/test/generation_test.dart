import 'package:test/test.dart';
import 'package:sudoku_api/sudoku_api.dart';

void main() {

  void testPuzzleGen({int clues = 0, String pattern = "random"}) {
    final PuzzleOptions puzzleOptions =
      new PuzzleOptions(clues: clues, patternName: pattern);
    final Puzzle puzzle = new Puzzle(puzzleOptions);
    puzzle.generate().then((_) {
      print("=================");
      printGrid(puzzle.solvedBoard());
      print("-----------------");
      printGrid(puzzle.board());
      print("=================");
    });
  }


    test("Prefill validity in active board", () {
    final PuzzleOptions puzzleOptions = new PuzzleOptions(clues: 25);
    final Puzzle puzzle = new Puzzle(puzzleOptions);
    puzzle.generate().then((_) {

      bool isCellFilled;
      bool? isPrefillValue;
      for(int r = 0; r < 9; r++) {
        for(Cell c in puzzle.board()!.getRow(r)) {
          isCellFilled = c.getValue() != 0;
          isPrefillValue = puzzle.board()!.cellAt(c.getPosition()!).prefill();

          // If the value of the cell is 0, then we are expecting prefill to be
          // false. Likewise, if value of cell is NOT 0, then prefill should be
          // true.
          expect(isCellFilled, isPrefillValue);
        }
      }
    });
  });


  String testRandom32Clues = 'Test Puzzle Generation. Clues: 32 (easy). Pattern: Random.';
  test(testRandom32Clues, () {
    testPuzzleGen(clues: 32, pattern: "random");
  });

  String testRandom25Clues = 'Test Puzzle Generation. Clues: 25 (normal). Pattern: Random.';
  test(testRandom25Clues, () {
    testPuzzleGen(clues: 25, pattern: "random");
  });

  String testRandom17Clues = 'Test Puzzle Generation. Clues: 17 (hard). Pattern: Random.';
  test(testRandom17Clues, () {
    testPuzzleGen(clues: 17, pattern: "random");
  });

  String testSpring = 'Test Puzzle Generation. Pattern: Spring.';
  test(testSpring, () {
    testPuzzleGen(pattern: "spring");
  });

  String testSummer = 'Test Puzzle Generation. Pattern: Summer.';
  test(testSummer, () {
    testPuzzleGen(pattern: "summer");
  });

  String testFall = 'Test Puzzle Generation. Pattern: Fall.';
  test(testFall, () {
    testPuzzleGen(pattern: "fall");
  });

    String testWinter = 'Test Puzzle Generation. Pattern: Winter.';
  test(testWinter, () {
    testPuzzleGen(pattern: "winter");
  });

  String testGridListener = 'Test Grid-level listener for cell change';
  test(testGridListener, () {

    final PuzzleOptions puzzleOptions = new PuzzleOptions(clues: 25);
    final Puzzle puzzle = new Puzzle(puzzleOptions);
    Position randPos;

    puzzle.generate().then((_) {
      print("=================");
      printGrid(puzzle.solvedBoard());
      print("-----------------");
      printGrid(puzzle.board());
      print("=================");

      while(true) {
        randPos = getRandomPosition();
        if(!puzzle.board()!.matrix()![randPos.grid!.x as int][randPos.grid!.y as int].prefill()!) {
          puzzle.board()!.matrix()![randPos.grid!.x as int][randPos.grid!.y as int].setValue(1);
          break;
        }
      }
      print("=================");
    });
  });
}
