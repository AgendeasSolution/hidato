import 'position.dart';

/// Result of solving a puzzle
class SolveResult {
  final List<List<List<int>>> solutions;
  final SolveStats stats;

  SolveResult({required this.solutions, required this.stats});
}

/// Statistics about the solving process
class SolveStats {
  final int found;
  final int elapsedMs;
  final int nodesExplored;
  final bool aborted;
  final int timeoutMs;

  SolveStats({
    required this.found,
    required this.elapsedMs,
    required this.nodesExplored,
    required this.aborted,
    required this.timeoutMs,
  });
}

/// Result of verifying a solution
class VerificationResult {
  bool isCorrect;
  final List<String> errors;
  final List<int> missingNumbers;
  final List<String> invalidMoves;

  VerificationResult({
    required this.isCorrect,
    required this.errors,
    required this.missingNumbers,
    required this.invalidMoves,
  });
}

/// Result of getting a hint
class HintResult {
  final String type;
  final String message;
  final int? number;
  final Position? position;

  HintResult({
    required this.type,
    required this.message,
    this.number,
    this.position,
  });
}

/// Result of checking puzzle uniqueness
class UniquenessResult {
  final bool hasSolution;
  final bool isUnique;
  final int solutionCount;
  final List<List<List<int>>> solutions;

  UniquenessResult({
    required this.hasSolution,
    required this.isUnique,
    required this.solutionCount,
    required this.solutions,
  });
}

