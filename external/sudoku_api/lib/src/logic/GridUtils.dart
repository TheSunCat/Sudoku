import 'dart:math';

import '../models/Cell.dart';
import '../models/Grid.dart';
import '../models/Position.dart';
import 'SudokuException.dart';

/*
 Collection of Utility functions used for stuff grid-related
 */

/// Throw an [InvalidPositionException] exception if [position] is not valid
void throwIfInvalid(Position position) {
  if (position.isValid()) {
    throw new InvalidPositionException("Position is invalid for a cell at row"
        " $position.grid.x and column $position.grid.y");
  }
}

/// Gets a random, valid [position]
Position getRandomPosition() {
  Random rand = new Random();
  return new Position(index: rand.nextInt(81));
}

/// Used for debugging [grid], prints to console a somewhat-grid-shaped
/// matrix of cell value
void printGrid(Grid? grid) {
  for (int r = 0; r < 9; r++) {
    String row = "";
    for (Cell c in grid!.getRow(r)) {
      row += ((c.getValue() == 0) ? " " : c.getValue()).toString() + " ";
    }
    print(row);
  }
}
