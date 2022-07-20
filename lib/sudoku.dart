class Cell {
  Position pos;
  int value;

  bool prefill;

  List<int> markup = List.empty(growable: true);

  Cell(this.pos, this.value, this.prefill);
}

class Position {
  int x; // column
  int y; // row

  Position(this.x, this.y);
}