/*
  Collection of Sudoku-specific exceptions
 */

/// Throw whenever a [Position] is valid (it does not confirm to 9x9 grid)
class InvalidPositionException implements Exception {
  String cause;

  InvalidPositionException(this.cause);
}

/// Throw whenever there's a [Pattern] related issue
class InvalidPatternException implements Exception {
  String cause;
  InvalidPatternException(this.cause);
}

/// Throw whenever [Puzzle] experiences a generation related issue
class GenerationException implements Exception {
  String cause;
  GenerationException(this.cause);
}
