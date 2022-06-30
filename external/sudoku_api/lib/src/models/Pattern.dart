/// Pattern itself [Map] and metadata describing it
class Pattern {
  String _name;
  Map<int, String>? _map;
  int? _clues;
  String? _author;

  /// Constructs a new Pattern object
  /// [clues] is defined by # of clues given
  Pattern(this._name, this._map,
      {int clues = 0, String author = "Anonymous"}) {
    this._clues = clues;
    this._author = author;
  }

  /// Getters and setters
  /// I can only make these comments so interesting and no more :l
  String getName() => _name;
  Map<int, String>? getMap() => _map;
}
