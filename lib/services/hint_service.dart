import '../models/index.dart';
import 'game_solver.dart';
import 'solution_cache.dart';

/// Service for providing hints to players
class HintService {
  final GameSolver _solver;

  HintService(this._solver);

  /// Gets a hint for the next number to place
  Future<HintResult> getHint(
    List<List<int>> currentBoard,
    int nextNum,
    List<List<int>> originalPuzzle,
    Position? lastPlacedPos,
  ) async {
    List<List<List<int>>> solutions;
    
    // Try to use cached solutions first
    solutions = SolutionCache.getSolutions(originalPuzzle) ?? [];
    
    if (solutions.isEmpty) {
      // Fallback to computing solutions if not cached
      solutions = await _solver.solve(originalPuzzle);
    }
    
    if (solutions.isEmpty) {
      return HintResult(type: 'error', message: 'No solutions found for this puzzle');
    }

    // Filter solutions that are compatible with current board state
    final compatibleSolutions = <List<List<int>>>[];
    for (final solution in solutions) {
      if (_isSolutionCompatible(currentBoard, solution)) {
        compatibleSolutions.add(solution);
      }
    }
    
    if (compatibleSolutions.isEmpty) {
      return HintResult(
        type: 'error',
        message: 'No valid solutions found with current board state. Try using Reset to start over!',
      );
    }

    // Find valid positions for the next number from compatible solutions
    final validPositions = <Position>[];

    // First, try to find positions that are adjacent to the last placed number
    if (lastPlacedPos != null) {
      for (final solution in compatibleSolutions) {
        final pos = findNumberPosition(solution, nextNum);
        if (pos != null && currentBoard[pos.row][pos.col] == 0) {
          if (isAdjacent(pos, lastPlacedPos)) {
            if (!validPositions.any((p) => p.row == pos.row && p.col == pos.col)) {
              validPositions.add(pos);
            }
          }
        }
      }
    }

    // If no adjacent positions found, try any valid position from compatible solutions
    if (validPositions.isEmpty) {
      for (final solution in compatibleSolutions) {
        final pos = findNumberPosition(solution, nextNum);
        if (pos != null && currentBoard[pos.row][pos.col] == 0) {
          if (!validPositions.any((p) => p.row == pos.row && p.col == pos.col)) {
            validPositions.add(pos);
          }
        }
      }
    }

    if (validPositions.isEmpty) {
      return HintResult(
        type: 'error',
        message: 'No valid positions found for number $nextNum. Try using Reset to start over!',
      );
    }

    // Pick the first valid position
    final pos = validPositions.first;
    return HintResult(
      type: 'multiple',
      message: 'Placing number $nextNum automatically!',
      number: nextNum,
      position: pos,
    );
  }

  /// Checks puzzle uniqueness
  Future<UniquenessResult> checkUniqueness(List<List<int>> puzzle) async {
    List<List<List<int>>> solutions;
    
    // Try to use cached solutions first
    solutions = SolutionCache.getSolutions(puzzle) ?? [];
    
    if (solutions.isEmpty) {
      // Fallback to computing solutions if not cached
      solutions = await _solver.solve(puzzle);
    }
    
    return UniquenessResult(
      hasSolution: solutions.isNotEmpty,
      isUnique: solutions.length == 1,
      solutionCount: solutions.length,
      solutions: solutions,
    );
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

  /// Checks if two positions are adjacent
  bool isAdjacent(Position pos1, Position pos2) {
    final rowDiff = (pos1.row - pos2.row).abs();
    final colDiff = (pos1.col - pos2.col).abs();
    return rowDiff + colDiff == 1;
  }

  /// Checks if a solution is compatible with the current board state
  bool _isSolutionCompatible(List<List<int>> currentBoard, List<List<int>> solution) {
    for (int r = 0; r < currentBoard.length; r++) {
      for (int c = 0; c < currentBoard[r].length; c++) {
        // If current board has a number, it must match the solution
        if (currentBoard[r][c] != 0 && currentBoard[r][c] != solution[r][c]) {
          return false;
        }
      }
    }
    return true;
  }
}

