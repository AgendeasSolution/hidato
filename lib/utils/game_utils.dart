import '../models/index.dart';

/// Utility functions for game logic
class GameUtils {
  /// Advances the game state by finding and placing consecutive numbers
  static void advanceGameState(
    List<List<int>> board,
    int startNumber,
    int endNumber,
    Position? Function(int) findNumberPosition,
  ) {
    int nextNumber = startNumber;
    Position? lastPlacedPos = findNumberPosition(nextNumber);
    
    while (lastPlacedPos != null && nextNumber <= endNumber) {
      nextNumber++;
      lastPlacedPos = findNumberPosition(nextNumber);
    }
  }

  /// Finds the next number that needs to be placed
  static int findNextNumberToPlace(
    List<List<int>> currentBoard,
    List<List<int>> originalBoard,
    int startNumber,
    int endNumber,
  ) {
    for (int num = startNumber; num <= endNumber; num++) {
      bool isClue = originalBoard.any((row) => row.any((cell) => cell == num));
      bool isPlaced = currentBoard.any((row) => row.any((cell) => cell == num));

      if (!isClue && !isPlaced) {
        return num;
      }
    }
    return endNumber + 1; // All numbers placed
  }

  /// Creates a deep copy of a 2D list
  static List<List<int>> deepCopyBoard(List<List<int>> board) {
    return board.map((row) => List<int>.from(row)).toList();
  }

  /// Checks if a position is within board bounds
  static bool isWithinBounds(int row, int col, int rows, int cols) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }

  /// Gets all adjacent positions for a given position
  static List<Position> getAdjacentPositions(int row, int col, int rows, int cols) {
    final positions = <Position>[];
    const deltas = [
      [-1, 0], // up
      [1, 0],  // down
      [0, -1], // left
      [0, 1],  // right
    ];

    for (final delta in deltas) {
      final newRow = row + delta[0];
      final newCol = col + delta[1];
      if (isWithinBounds(newRow, newCol, rows, cols)) {
        positions.add(Position(newRow, newCol));
      }
    }

    return positions;
  }

  /// Counts the number of empty cells on the board
  static int countEmptyCells(List<List<int>> board) {
    int count = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell == 0) count++;
      }
    }
    return count;
  }

  /// Counts the number of filled cells on the board
  static int countFilledCells(List<List<int>> board) {
    int count = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell != 0) count++;
      }
    }
    return count;
  }
}

