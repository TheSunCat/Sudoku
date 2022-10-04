import 'package:sudoku_api/src/logic/SudokuException.dart';
import 'package:test/test.dart';
import 'package:sudoku_api/sudoku_api.dart';

void main() async {
  String patterSetTest = 'Error Pattern Set';
  test(patterSetTest, () {
    final Map<int, String> errorMap = {
      0: "0 0 0 0 1 0 0 0 0 1 0",
    };
    final patterSet = PatternSet();
    final patterName = "errorPattern";
    Pattern pattern = Pattern(patterName, errorMap);
    expect(
        () => patterSet.add(pattern), throwsA(isA<InvalidPatternException>()));
  });
}
