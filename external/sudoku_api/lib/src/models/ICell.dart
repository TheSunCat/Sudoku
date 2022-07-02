import 'Position.dart';

/// Interface for creating cell-like objects which belong to a 9x9 grid
/// Notably used by [Cell]
abstract class ICell {
  /// Position of this cell in a 9x9 grid
  final Position? position;

  /// Whether or not this cell's value has been changed since grid generation
  bool? isPristine;

  ICell(this.position, this.isPristine);

  Position? getPosition();

  /// Getters and setters
  /// I can only make these comments so interesting and no more :l
  bool? pristine() => this.isPristine;
  void setPristine(bool pristine) => this.isPristine = pristine;
}
