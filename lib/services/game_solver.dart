import '../models/index.dart';
import '../constants/app_constants.dart';

/// Service for solving Hidato puzzles
class GameSolver {
  final Map<String, List<List<List<int>>>> solutionCache = {};

  /// Solves a puzzle and returns all possible solutions
  Future<List<List<List<int>>>> solve(List<List<int>> puzzle) async {
    final puzzleKey = puzzle.toString();
    if (solutionCache.containsKey(puzzleKey)) {
      return solutionCache[puzzleKey]!;
    }

    final result = await solveNumberPath(puzzle, findAll: true);
    solutionCache[puzzleKey] = List.from(result.solutions);
    return result.solutions;
  }

  /// Solves a number path puzzle with various options
  Future<SolveResult> solveNumberPath(
    List<List<int>> initialBoard, {
    bool findAll = false,
    int timeoutMs = AppConstants.solverTimeoutMs,
  }) async {
    final startTime = DateTime.now();
    bool aborted = false;

    final rows = initialBoard.length;
    if (rows == 0) throw Exception("initialBoard must have at least one row");
    final cols = initialBoard[0].length;
    final total = rows * cols;

    for (int r = 0; r < rows; r++) {
      if (initialBoard[r].length != cols) {
        throw Exception("initialBoard must be rectangular");
      }
    }

    final Map<int, Position> cluePos = {};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final v = initialBoard[r][c];
        if (v != 0) {
          if (v < 1 || v > total || v != v.toInt()) {
            throw Exception("Invalid clue value $v at $r,$c");
          }
          if (cluePos.containsKey(v)) {
            throw Exception("Duplicate clue number $v");
          }
          cluePos[v] = Position(r, c);
        }
      }
    }

    const deltas = [
      [-1, 0], // up
      [1, 0], // down
      [0, -1], // left
      [0, 1], // right
    ];

    bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

    int reachableCount(List<List<bool>> gridOccupied, int? headR, int? headC) {
      final seen = List.generate(rows, (_) => List.filled(cols, false));
      final queue = <List<int>>[];

      if (headR != null) {
        queue.add([headR, headC!]);
        seen[headR][headC] = true;
      } else {
        outer: for (int r = 0; r < rows; r++) {
          for (int c = 0; c < cols; c++) {
            if (!gridOccupied[r][c]) {
              queue.add([r, c]);
              seen[r][c] = true;
              break outer;
            }
          }
        }
        if (queue.isEmpty) return 0;
      }

      int count = 0;
      while (queue.isNotEmpty) {
        final pos = queue.removeAt(0);
        final r = pos[0], c = pos[1];
        if (!gridOccupied[r][c]) count++;

        for (final delta in deltas) {
          final nr = r + delta[0], nc = c + delta[1];
          if (!inBounds(nr, nc) || seen[nr][nc]) continue;
          seen[nr][nc] = true;
          if (!gridOccupied[nr][nc]) queue.add([nr, nc]);
        }
      }
      return count;
    }

    List<List<int>> neighborOrder(int r, int c, List<List<bool>> gridOccupied) {
      final neighbors = <Map<String, dynamic>>[];

      for (final delta in deltas) {
        final nr = r + delta[0], nc = c + delta[1];
        if (!inBounds(nr, nc)) continue;
        if (gridOccupied[nr][nc]) continue;

        int moves = 0;
        for (final delta2 in deltas) {
          final xr = nr + delta2[0], xc = nc + delta2[1];
          if (!inBounds(xr, xc)) continue;
          if (!gridOccupied[xr][xc] && !(xr == r && xc == c)) moves++;
        }
        neighbors.add({'nr': nr, 'nc': nc, 'moves': moves});
      }

      neighbors.sort((a, b) => a['moves'].compareTo(b['moves']));
      return neighbors.map((n) => [n['nr'] as int, n['nc'] as int]).toList();
    }

    final solutions = <List<List<int>>>[];
    final grid = List.generate(rows, (_) => List.filled(cols, 0));
    final occupied = List.generate(rows, (_) => List.filled(cols, false));

    final reverseClueMap = List.generate(rows, (_) => List.filled(cols, 0));
    for (final entry in cluePos.entries) {
      reverseClueMap[entry.value.row][entry.value.col] = entry.key;
    }

    int nodesExplored = 0;
    bool abortedByTimeout = false;

    bool timeoutCheck() {
      if (timeoutMs == 0) return false;
      if (DateTime.now().difference(startTime).inMilliseconds > timeoutMs) {
        aborted = true;
        abortedByTimeout = true;
        return true;
      }
      return false;
    }

    void dfs(int k, int? headR, int? headC) {
      if (aborted) return;
      if (timeoutCheck()) return;

      nodesExplored++;

      if (cluePos.containsKey(k)) {
        final pos = cluePos[k]!;
        if (occupied[pos.row][pos.col]) return;

        if (k > 1) {
          final dr = (pos.row - headR!).abs();
          final dc = (pos.col - headC!).abs();
          final orthAdj = (dr == 1 && dc == 0) || (dr == 0 && dc == 1);
          if (!orthAdj) return;
        }

        grid[pos.row][pos.col] = k;
        occupied[pos.row][pos.col] = true;

        final remaining = total - k;
        if (remaining > 0) {
          final reach = reachableCount(occupied, pos.row, pos.col);
          if (reach < remaining) {
            occupied[pos.row][pos.col] = false;
            grid[pos.row][pos.col] = 0;
            return;
          }
        } else {
          solutions.add(grid.map((row) => List<int>.from(row)).toList());
          if (!findAll) aborted = true;
          occupied[pos.row][pos.col] = false;
          grid[pos.row][pos.col] = 0;
          return;
        }

        dfs(k + 1, pos.row, pos.col);
        occupied[pos.row][pos.col] = false;
        grid[pos.row][pos.col] = 0;
        return;
      }

      if (k == 1) return;

      final neighbors = neighborOrder(headR!, headC!, occupied);
      for (final neighbor in neighbors) {
        final nr = neighbor[0], nc = neighbor[1];

        if (reverseClueMap[nr][nc] != 0) {
          final clueNumberAtCell = reverseClueMap[nr][nc];
          if (clueNumberAtCell != k) continue;
        }

        grid[nr][nc] = k;
        occupied[nr][nc] = true;

        final remaining = total - k;
        if (remaining > 0) {
          final reach = reachableCount(occupied, nr, nc);
          if (reach < remaining) {
            occupied[nr][nc] = false;
            grid[nr][nc] = 0;
            continue;
          }
        } else {
          solutions.add(grid.map((row) => List<int>.from(row)).toList());
          occupied[nr][nc] = false;
          grid[nr][nc] = 0;
          if (!findAll) {
            aborted = true;
            return;
          }
          continue;
        }

        dfs(k + 1, nr, nc);
        if (aborted) return;

        occupied[nr][nc] = false;
        grid[nr][nc] = 0;
      }
    }

    final startPositions = <List<int>>[];
    if (cluePos.containsKey(1)) {
      final pos = cluePos[1]!;
      startPositions.add([pos.row, pos.col]);
    } else {
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (reverseClueMap[r][c] != 0) continue;
          startPositions.add([r, c]);
        }
      }
    }

    for (final start in startPositions) {
      if (aborted) break;

      final sr = start[0], sc = start[1];
      grid[sr][sc] = 1;
      occupied[sr][sc] = true;

      final rem = total - 1;
      if (rem > 0) {
        final reach = reachableCount(occupied, sr, sc);
        if (reach >= rem) {
          dfs(2, sr, sc);
        }
      } else {
        solutions.add(grid.map((row) => List<int>.from(row)).toList());
        if (!findAll) {
          occupied[sr][sc] = false;
          grid[sr][sc] = 0;
          break;
        }
      }

      occupied[sr][sc] = false;
      grid[sr][sc] = 0;
    }

    final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
    return SolveResult(
      solutions: solutions,
      stats: SolveStats(
        found: solutions.length,
        elapsedMs: elapsedMs,
        nodesExplored: nodesExplored,
        aborted: aborted || abortedByTimeout,
        timeoutMs: timeoutMs,
      ),
    );
  }

  /// Clears the solution cache
  void clearCache() {
    solutionCache.clear();
  }
}

