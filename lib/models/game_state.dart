import 'position.dart';

/// Represents the state of the game at a specific point in time
class GameState {
  final List<List<int>> board;
  final int nextNumber;
  final Position? lastPlacedPos;

  GameState({
    required this.board,
    required this.nextNumber,
    this.lastPlacedPos,
  });

  /// Creates a deep copy of the game state
  GameState copyWith({
    List<List<int>>? board,
    int? nextNumber,
    Position? lastPlacedPos,
  }) {
    return GameState(
      board: board ?? this.board.map((row) => List<int>.from(row)).toList(),
      nextNumber: nextNumber ?? this.nextNumber,
      lastPlacedPos: lastPlacedPos ?? this.lastPlacedPos,
    );
  }
}

