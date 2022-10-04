/*
   Collection of Utility functions used for stuff puzzle-related
 */

/// Minimum clues necessary for a valid sudoku puzzle
int minClues = 17;

/// Average clues of a sudoku puzzle
int avgClues = 25;

/// Maximum clues necessary for a valid sudoku puzzle
int maxClues = 80;

/// Possible types of cell violations that can be committed
/// Violations:
/// - Row: Cell value already exists in that row
/// - Column: Cell value already exists in that column
/// - Segment: Cell value already exists in that segment
/// - Solution: Cell value does not match its solution board counterpart
enum CellViolation { Row, Column, Segment, Solution }
