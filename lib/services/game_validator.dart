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

  /// Checks if a move is valid according to all Hidato rules
  bool isValidMove(
    List<List<int>> currentBoard,
    List<List<int>> originalBoard,
    Position newPos,
    int numberToPlace,
    int startNum,
    int endNum,
  ) {
    // Rule 1: Non-Adjacent Placement
    if (!_isValidAdjacentPlacement(currentBoard, newPos, numberToPlace, startNum)) {
      return false;
    }

    // Rule 2: Breaking the Number Sequence
    if (!_isValidSequencePlacement(currentBoard, numberToPlace, startNum, endNum)) {
      return false;
    }

    // Rule 3: Invalid Adjacency Chain
    if (!_isValidAdjacencyChain(currentBoard, newPos, numberToPlace, startNum, endNum)) {
      return false;
    }

    return true;
  }

  /// Rule 1: Each number must be placed adjacent to the previous number
  bool _isValidAdjacentPlacement(
    List<List<int>> currentBoard,
    Position newPos,
    int numberToPlace,
    int startNum,
  ) {
    // If this is the first number to place, it's valid
    if (numberToPlace == startNum) {
      return true;
    }

    // Find the position of the previous number
    final previousNumber = numberToPlace - 1;
    final previousPos = findNumberPosition(currentBoard, previousNumber);

    // If previous number doesn't exist, this placement is invalid
    if (previousPos == null) {
      return false;
    }

    // Check if new position is adjacent to previous number
    return isAdjacent(newPos, previousPos);
  }

  /// Rule 2: Numbers must form a continuous sequence
  bool _isValidSequencePlacement(
    List<List<int>> currentBoard,
    int numberToPlace,
    int startNum,
    int endNum,
  ) {
    // Check if we're trying to place a number that's too far ahead
    for (int num = startNum; num < numberToPlace; num++) {
      final pos = findNumberPosition(currentBoard, num);
      if (pos == null) {
        // There's a gap in the sequence before this number
        return false;
      }
    }

    // Check if this number is already placed
    final existingPos = findNumberPosition(currentBoard, numberToPlace);
    if (existingPos != null) {
      return false; // Number already exists
    }

    return true;
  }

  /// Rule 3: All previous numbers in the sequence must be properly connected
  bool _isValidAdjacencyChain(
    List<List<int>> currentBoard,
    Position newPos,
    int numberToPlace,
    int startNum,
    int endNum,
  ) {
    // Create a temporary board with the new placement
    final tempBoard = _createTempBoardWithPlacement(currentBoard, newPos, numberToPlace);

    // Check if all consecutive numbers are adjacent
    for (int num = startNum; num < endNum; num++) {
      final currentPos = findNumberPosition(tempBoard, num);
      final nextPos = findNumberPosition(tempBoard, num + 1);

      if (currentPos != null && nextPos != null) {
        if (!isAdjacent(currentPos, nextPos)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Creates a temporary board with the new placement for validation
  List<List<int>> _createTempBoardWithPlacement(
    List<List<int>> currentBoard,
    Position newPos,
    int numberToPlace,
  ) {
    final tempBoard = currentBoard.map((row) => List<int>.from(row)).toList();
    tempBoard[newPos.row][newPos.col] = numberToPlace;
    return tempBoard;
  }

  /// Validates a move and returns detailed validation result
  ValidationResult validateMove(
    List<List<int>> currentBoard,
    List<List<int>> originalBoard,
    Position newPos,
    int numberToPlace,
    int startNum,
    int endNum,
  ) {
    final result = ValidationResult();

    // Rule 1: Non-Adjacent Placement
    if (!_isValidAdjacentPlacement(currentBoard, newPos, numberToPlace, startNum)) {
      result.isValid = false;
      result.errorMessage = 'Number $numberToPlace must be placed adjacent to number ${numberToPlace - 1}';
      result.errorType = ValidationErrorType.nonAdjacentPlacement;
      return result;
    }

    // Rule 2: Breaking the Number Sequence
    if (!_isValidSequencePlacement(currentBoard, numberToPlace, startNum, endNum)) {
      result.isValid = false;
      result.errorMessage = 'Cannot place number $numberToPlace - there are gaps in the sequence';
      result.errorType = ValidationErrorType.breakingSequence;
      return result;
    }

    // Rule 3: Invalid Adjacency Chain
    if (!_isValidAdjacencyChain(currentBoard, newPos, numberToPlace, startNum, endNum)) {
      result.isValid = false;
      result.errorMessage = 'This placement would break the adjacency chain of previous numbers';
      result.errorType = ValidationErrorType.invalidAdjacencyChain;
      return result;
    }

    result.isValid = true;
    return result;
  }

  /// Legacy method for backward compatibility - simplified validation
  bool isValidMoveLegacy(Position newPos, Position? lastPlacedPos) {
    if (lastPlacedPos == null) return true;
    return isAdjacent(newPos, lastPlacedPos);
  }
}

/// Result of move validation with detailed error information
class ValidationResult {
  bool isValid;
  String errorMessage;
  ValidationErrorType errorType;

  ValidationResult({
    this.isValid = false,
    this.errorMessage = '',
    this.errorType = ValidationErrorType.none,
  });
}

/// Types of validation errors
enum ValidationErrorType {
  none,
  nonAdjacentPlacement,
  breakingSequence,
  invalidAdjacencyChain,
}

