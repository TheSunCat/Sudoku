import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';

import 'Pattern.dart' as MY;

/// Prevent pulling Pattern from dart:core
import '../logic/SudokuException.dart';

/// Character code for '1' digit, which is clue placeholder in patterns
const int HOLDER_CODE = 49;

/// Collection specifically for [Pattern]
/// Implements logic for adding new [Pattern] to set, along with validation
class PatternSet<Pattern> extends DelegatingList<MY.Pattern> {
  final List<MY.Pattern> _l;

  /// Default Spring season puzzle - flower blossom
  Map<int, String> _spring = {
    0: "0 0 0 0 1 0 0 0 0",
    1: "0 0 0 1 1 1 0 0 0",
    2: "0 0 0 1 0 1 0 0 0",
    3: "0 1 1 0 1 0 1 1 0",
    4: "1 1 0 1 1 1 0 1 1",
    5: "0 1 1 0 1 0 1 1 0",
    6: "0 0 0 1 0 1 0 0 0",
    7: "0 0 0 1 1 1 0 0 0",
    8: "0 0 0 0 1 0 0 0 0"
  };

  /// Default Summer season puzzle - watermelon
  Map<int, String> _summer = {
    0: "0 0 0 0 0 1 1 0 0",
    1: "0 0 0 0 1 1 0 1 0",
    2: "0 0 0 1 1 1 0 1 0",
    3: "0 0 1 1 1 0 0 1 0",
    4: "0 1 1 0 0 0 1 1 0",
    5: "1 1 0 0 0 0 1 0 0",
    6: "1 0 0 0 1 1 0 0 0",
    7: "0 1 1 1 1 0 0 0 0",
    8: "0 0 0 0 0 0 0 0 0"
  };

  /// Default Fall season puzzle - leaf
  Map<int, String> _fall = {
    0: "0 0 0 0 0 0 0 0 0",
    1: "0 0 0 0 1 0 1 1 0",
    2: "0 0 0 1 0 1 1 1 0",
    3: "0 0 1 0 0 1 1 0 0",
    4: "0 0 1 1 1 0 0 1 0",
    5: "0 0 1 1 1 0 1 0 0",
    6: "0 0 1 1 1 1 0 0 0",
    7: "0 1 0 0 0 0 0 0 0",
    8: "1 0 0 0 0 0 0 0 0"
  };

  /// Default Winter season puzzle - snowflake
  Map<int, String> _winter = {
    0: "0 1 0 0 0 0 0 1 0",
    1: "1 1 0 0 1 0 0 1 1",
    2: "0 0 1 0 1 0 1 0 0",
    3: "0 0 0 1 0 1 0 0 0",
    4: "1 1 1 0 1 0 1 1 1",
    5: "0 0 0 1 0 1 0 0 0",
    6: "0 0 1 0 1 0 1 0 0",
    7: "1 1 0 0 1 0 0 1 1",
    8: "0 1 0 0 0 0 0 1 0"
  };

  PatternSet() : this._(<MY.Pattern>[]);

  PatternSet._(l)
      : _l = l,
        super(l);

  /// Loads seasonal puzzles into set, along with a Random pattern placeholder
  /// For seasonals, refer to [_spring], [_summer], [_fall], and [_winter]
  void loadDefaults() {
    _l.add(new MY.Pattern("random", null));

    _l.add(new MY.Pattern("spring", _spring, clues: 29));
    _l.add(new MY.Pattern("summer", _summer, clues: 27));
    _l.add(new MY.Pattern("fall", _fall, clues: 24));
    _l.add(new MY.Pattern("winter", _winter, clues: 31));
  }

  /// Adds new [Pattern] to set, and ensures validity
  /// Validity checks include pattern name, and pattern integrity
  @override
  void add(MY.Pattern element) {
    if (element.getName().isEmpty) {
      throw InvalidPatternException("Pattern is missing name");
    } else if (!_checkValidPatternMap(element.getMap()).item1) {
      throw InvalidPatternException("Pattern format for ${element.getName()} "
          "is broken");
    } else {
      _l.add(element);
    }
  }

  /// Checks integrity of pattern
  /// Returns Tuple, where [item1] is validity, and [item2] is reasons why not
  /// Integrity determined by pattern where:
  /// - Map of size 9, keys [0-8] and values strings
  /// - Strings represent rows - 0's are empty,  1's are clues
  /// - Each value in String row is separated by a space
  ///
  /// Example of valid pattern [_spring]:
  ///   0: "0 0 0 0 1 0 0 0 0",
  ///   1: "0 0 0 1 1 1 0 0 0",
  ///   2: "0 0 0 1 0 1 0 0 0",
  ///   3: "0 1 1 0 1 0 1 1 0",
  ///   4: "1 1 0 1 1 1 0 1 1",
  ///   5: "0 1 1 0 1 0 1 1 0",
  ///   6: "0 0 0 1 0 1 0 0 0",
  ///   7: "0 0 0 1 1 1 0 0 0",
  ///   8: "0 0 0 0 1 0 0 0 0"
  ///
  Tuple2<bool, List<String>> _checkValidPatternMap(Map<int, String>? map) {
    String _patrow = "";
    String _bigrow = "";
    List<String> _reasons = new List<String>.empty();

    for (int row = 0; row < 9; row++) {
      _patrow = map![row]!.replaceAll(' ', '');

      if (_patrow.length != 9) {
        _reasons.add("Pattern Map row #$row does not " +
            "have 9 characters (expected: 9, actual: ${_patrow.length})");
      }
      _bigrow += _patrow;
    }

    if (!_bigrow.contains(String.fromCharCode(HOLDER_CODE))) {
      _reasons.add("Pattern does not contain any "
          "placeholders. Represent which cell to keep as '1'");
    }

    return new Tuple2<bool, List<String>>(_reasons.isEmpty, _reasons);
  }

  @override
  set length(int newLength) {
    _l.length = newLength;
  }

  @override
  int get length => _l.length;

  @override
  MY.Pattern operator [](int index) => _l[index];

  @override
  void operator []=(int index, MY.Pattern value) {
    _l[index] = value;
  }
}
