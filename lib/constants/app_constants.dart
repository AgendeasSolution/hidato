/// Application-wide constants
class AppConstants {
  // App information
  static const String appName = 'Hidato Puzzle';
  static const String appVersion = '1.0.0';
  
  // Game configuration
  static const int maxHintsMultiplier = 4; // 25% of total cells
  static const int solverTimeoutMs = 10000; // 10 seconds
  static const int hintDisplayDurationMs = 2000; // 2 seconds
  
  // Animation durations
  static const Duration confettiDuration = Duration(seconds: 3);
  static const Duration bounceDuration = Duration(milliseconds: 500);
  static const Duration cellAnimationDuration = Duration(milliseconds: 200);
  
}

