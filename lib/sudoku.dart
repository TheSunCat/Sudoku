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