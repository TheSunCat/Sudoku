import '../Puzzle.dart';

/// Encapsulates serializable properties required for setting up a [Puzzle]
class PuzzleOptions {
  String? name;
  int? clues;
  String? patternName;

  /// Constructs new PuzzleOptions - use me when constructing a new [Puzzle]
  PuzzleOptions(
      {String? name, int? clues = 25, String? patternName = "random"}) {
    this.name = name;
    this.clues = clues;
    this.patternName = patternName;
  }

  /// Serialization
  ///
  factory PuzzleOptions.fromMap(Map<String, dynamic> json) => PuzzleOptions(
        name: json["name"] == null ? null : json["name"],
        clues: json["clues"] == null ? null : json["clues"],
        patternName: json["pattern_name"] == null ? null : json["pattern_name"],
      );
  Map<String, dynamic> toMap() => {
        "name": name == null ? null : name,
        "clues": clues == null ? null : clues,
        "pattern_name": patternName == null ? null : patternName,
      };
}
