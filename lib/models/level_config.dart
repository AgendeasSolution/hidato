/// Configuration for a game level
class LevelConfig {
  final int level;
  final int rows;
  final int columns;
  final int totalCells;
  final int clues;
  final List<List<int>> initialBoard;

  LevelConfig({
    required this.level,
    required this.rows,
    required this.columns,
    required this.totalCells,
    required this.clues,
    required this.initialBoard,
  });

  /// Creates a deep copy of the level config
  LevelConfig copyWith({
    int? level,
    int? rows,
    int? columns,
    int? totalCells,
    int? clues,
    List<List<int>>? initialBoard,
  }) {
    return LevelConfig(
      level: level ?? this.level,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      totalCells: totalCells ?? this.totalCells,
      clues: clues ?? this.clues,
      initialBoard: initialBoard ?? this.initialBoard.map((row) => List<int>.from(row)).toList(),
    );
  }
}

