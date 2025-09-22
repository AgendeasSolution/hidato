import '../models/index.dart';

/// Service for caching solutions for complex levels
class SolutionCache {
  static final Map<String, List<List<List<int>>>> _cache = {};
  static final Map<String, bool> _isComputing = {};

  /// Get cached solutions for a level
  static List<List<List<int>>>? getSolutions(List<List<int>> puzzle) {
    final key = _generateKey(puzzle);
    return _cache[key];
  }

  /// Store solutions for a level
  static void storeSolutions(List<List<int>> puzzle, List<List<List<int>>> solutions) {
    final key = _generateKey(puzzle);
    _cache[key] = List.from(solutions);
  }

  /// Check if solutions are currently being computed for a level
  static bool isComputing(List<List<int>> puzzle) {
    final key = _generateKey(puzzle);
    return _isComputing[key] ?? false;
  }

  /// Mark that solutions are being computed for a level
  static void setComputing(List<List<int>> puzzle, bool computing) {
    final key = _generateKey(puzzle);
    _isComputing[key] = computing;
  }

  /// Check if solutions exist for a level
  static bool hasSolutions(List<List<int>> puzzle) {
    final key = _generateKey(puzzle);
    return _cache.containsKey(key) && _cache[key]!.isNotEmpty;
  }

  /// Clear all cached solutions
  static void clearCache() {
    _cache.clear();
    _isComputing.clear();
  }

  /// Clear solutions for a specific level
  static void clearLevel(List<List<int>> puzzle) {
    final key = _generateKey(puzzle);
    _cache.remove(key);
    _isComputing.remove(key);
  }

  /// Generate a unique key for a puzzle
  static String _generateKey(List<List<int>> puzzle) {
    return puzzle.map((row) => row.join(',')).join('|');
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cachedLevels': _cache.length,
      'computingLevels': _isComputing.values.where((v) => v).length,
      'totalSolutions': _cache.values.fold(0, (sum, solutions) => sum + solutions.length),
    };
  }
}
