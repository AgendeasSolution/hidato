import '../models/index.dart';

/// Service for validating game moves and solutions
class GameValidator {
  /// Verifies if a solution is correct
  VerificationResult verifySolution(
    List<List<int>> playerBoard,
    List<List<int>> originalPuzzle,
    int startNum,
    int endNum,
  ) {
    final result = VerificationResult(
      isCorrect: true,
      errors: [],
      missingNumbers: [],
      invalidMoves: [],
    );

    // Check if clues were changed
    for (int r = 0; r < originalPuzzle.length; r++) {
      for (int c = 0; c < originalPuzzle[r].length; c++) {
        if (originalPuzzle[r][c] > 0 && playerBoard[r][c] != originalPuzzle[r][c]) {
          result.isCorrect = false;
          result.errors.add(
            'Clue at ($r, $c) was changed from ${originalPuzzle[r][c]} to ${playerBoard[r][c]}',
          );
        }
      }
    }

    // Check if all numbers are present
    for (int num = startNum; num <= endNum; num++) {
      final pos = findNumberPosition(playerBoard, num);
      if (pos == null) {
        result.isCorrect = false;
        result.missingNumbers.add(num);
      }
    }

    // Check for empty cells
    for (int r = 0; r < playerBoard.length; r++) {
      for (int c = 0; c < playerBoard[r].length; c++) {
        if (playerBoard[r][c] == 0) {
          result.isCorrect = false;
          result.errors.add('Empty cell at position ($r, $c)');
        }
      }
    }

    // Check adjacency of consecutive numbers
    for (int num = startNum; num < endNum; num++) {
      final currentPos = findNumberPosition(playerBoard, num);
      final nextPos = findNumberPosition(playerBoard, num + 1);

      if (currentPos == null || nextPos == null) {
        result.isCorrect = false;
        result.errors.add('Missing numbers $num or ${num + 1}');
        continue;
      }

      if (!isAdjacent(currentPos, nextPos)) {
        result.isCorrect = false;
        result.invalidMoves.add('Numbers $num and ${num + 1} are not adjacent');
      }
    }

    return result;
  }

  /// Checks if two positions are adjacent
  bool isAdjacent(Position pos1, Position pos2) {
    final rowDiff = (pos1.row - pos2.row).abs();
    final colDiff = (pos1.col - pos2.col).abs();
    return rowDiff + colDiff == 1;
  }

  /// Finds the position of a number on the board
  Position? findNumberPosition(List<List<int>> board, int number) {
    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board[r].length; c++) {
        if (board[r][c] == number) {
          return Position(r, c);
        }
      }
    }
    return null;
  }

  /// Checks if a move is valid
  bool isValidMove(Position newPos, Position? lastPlacedPos) {
    if (lastPlacedPos == null) return true;
    return isAdjacent(newPos, lastPlacedPos);
  }
}

