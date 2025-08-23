class Sudoku {
  List<List<Cell>> game;
  int time;

  static int numDifficulties = 5;

  Sudoku(this.game, this.time);

  factory Sudoku.fromJson(Map<String, dynamic> json) =>
      Sudoku(List<List<Cell>>.from(json['game'].map<List<Cell>>((e) => List<Cell>.from(e.map((f) => Cell.fromJson(f))))), json['time']);

  Map toJson() => {
    'game': game,
    'time': time
  };
}

class Cell {
  Position pos;
  int value;
  bool prefill;

  List<int> markup;

  Cell(this.pos, this.value, this.prefill, {List<int>? defaultMarkup})
      : markup = defaultMarkup ?? List.empty(growable: true);

  factory Cell.fromJson(Map<String, dynamic> json) =>
      Cell(Position.fromJson(json['pos']), json['value'], json['prefill'], defaultMarkup: List.from(json['markup'].map((e) => e)));

  Map toJson() => {
    'pos': pos,
    'value': value,
    'prefill': prefill,
    'markup': markup
  };
}

class Position {
  int x; // column
  int y; // row

  Position(this.x, this.y);

  factory Position.fromJson(Map<String, dynamic> json) =>
      Position(json['x'], json['y']);

  Map toJson() => {
    'x': x,
    'y': y
  };
}