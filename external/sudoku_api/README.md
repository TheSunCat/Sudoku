## Simple, dart API for Sudoku puzzles

## Introduction

**sudoku_api** simplifies the generation, interaction, and management
of **Sudoku Puzzles**.

Well, how does it do that?
* Contains a Built-in solver for generating new puzzles, or solving existing ones
* Utilizes and exposes event streams for grid interactions (e.g. cell value changed), and puzzle states
* Exposes a bunch of neat, easy to use models manipulating Cells, Positions, Grids, and even Patterns of a Sudoku puzzle

#### What is Sudoku?
> ... a logic-based, combinatorial number-placement puzzle. The objective is to fill a 9×9 grid with digits so that each column, each row, and each of the nine 3×3 subgrids (segments) that compose the grid contain all of the digits from 1 to 9. The puzzle setter provides a partially completed grid, which for a well-posed puzzle has a single solution.

## Example

```dart

import 'package:sudoku_api/Puzzle.dart';

void main() {
  
  PuzzleOptions puzzleOptions = new PuzzleOptions(patternName: "winter");
  
  Puzzle puzzle = new Puzzle(puzzleOptions);
  
    puzzle.generate().then((_) {
      print("=====================================");
      print("Your puzzle, fresh off the press:");
      print("-------------------------------------");
      printGrid(puzzle.board());
      print("=====================================");
      print("Give up? Here's your puzzle solution:");
      print("-------------------------------------");
      printGrid(puzzle.solvedBoard());
      print("=====================================");
    });
}
```

### Output

```
=====================================
Your puzzle, fresh off the press:
-------------------------------------
  9           8   
3 4     7     6 9 
    8   5   1     
      4   5       
4 5 6   9   3 1 2 
      3   2       
    2   8   9     
8 3     2     7 5 
  6           2   
=====================================
Give up? Here's your puzzle solution:
-------------------------------------
2 9 1 6 3 4 5 8 7 
3 4 5 1 7 8 2 6 9 
6 7 8 2 5 9 1 3 4 
1 2 3 4 6 5 7 9 8 
4 5 6 8 9 7 3 1 2 
7 8 9 3 1 2 4 5 6 
5 1 2 7 8 6 9 4 3 
8 3 4 9 2 1 6 7 5 
9 6 7 5 4 3 8 2 1 
=====================================
```


### Contributing
Let's make some sweet Sudoku, together.

1. Fork `sudoku_api`, clone, and checkout the `dev` branch
2. Write some pretty neat code, then push
3. [Create a pull request from a fork](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)


#### Implementations
[Sudoku Toolkit (AlvinRamoutar)](https://github.com/AlvinRamoutar/sudoku-toolkit) - WIP

#### Inspiration
One of my college projects; [Java Sudoku](https://github.com/AlvinRamoutar/Sudoku/).

#### Libraries
* [uuid](https://pub.dev/packages/uuid)
* [tuple](https://pub.dev/packages/tuple)
* [collection](https://pub.dev/packages/collection)
