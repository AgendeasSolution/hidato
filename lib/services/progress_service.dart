import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing game progress and level unlocking
class ProgressService {
  static const String _completedLevelsKey = 'completed_levels';
  static const String _unlockedLevelsKey = 'unlocked_levels';
  
  /// Get completed levels from storage
  static Future<Set<int>> getCompletedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final String? completedLevelsJson = prefs.getString(_completedLevelsKey);
    
    if (completedLevelsJson == null) {
      return <int>{};
    }
    
    try {
      final List<dynamic> completedLevelsList = jsonDecode(completedLevelsJson);
      return completedLevelsList.map((e) => e as int).toSet();
    } catch (e) {
      return <int>{};
    }
  }
  
  /// Get unlocked levels from storage
  static Future<Set<int>> getUnlockedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final String? unlockedLevelsJson = prefs.getString(_unlockedLevelsKey);
    
    if (unlockedLevelsJson == null) {
      // First time playing - only level 1 is unlocked
      return <int>{1};
    }
    
    try {
      final List<dynamic> unlockedLevelsList = jsonDecode(unlockedLevelsJson);
      final Set<int> unlockedLevels = unlockedLevelsList.map((e) => e as int).toSet();
      
      // Always ensure level 1 is unlocked
      if (!unlockedLevels.contains(1)) {
        unlockedLevels.add(1);
        await saveUnlockedLevels(unlockedLevels);
      }
      
      return unlockedLevels;
    } catch (e) {
      return <int>{1};
    }
  }
  
  /// Save completed levels to storage
  static Future<void> saveCompletedLevels(Set<int> completedLevels) async {
    final prefs = await SharedPreferences.getInstance();
    final String completedLevelsJson = jsonEncode(completedLevels.toList());
    await prefs.setString(_completedLevelsKey, completedLevelsJson);
  }
  
  /// Save unlocked levels to storage
  static Future<void> saveUnlockedLevels(Set<int> unlockedLevels) async {
    final prefs = await SharedPreferences.getInstance();
    final String unlockedLevelsJson = jsonEncode(unlockedLevels.toList());
    await prefs.setString(_unlockedLevelsKey, unlockedLevelsJson);
  }
  
  /// Mark a level as completed and unlock the next level
  static Future<void> completeLevel(int levelNumber) async {
    final completedLevels = await getCompletedLevels();
    final unlockedLevels = await getUnlockedLevels();
    
    // Add current level to completed levels
    completedLevels.add(levelNumber);
    
    // Unlock the next level
    final nextLevel = levelNumber + 1;
    unlockedLevels.add(nextLevel);
    
    // Save both sets
    await saveCompletedLevels(completedLevels);
    await saveUnlockedLevels(unlockedLevels);
  }
  
  /// Check if a level is unlocked
  static Future<bool> isLevelUnlocked(int levelNumber) async {
    final unlockedLevels = await getUnlockedLevels();
    return unlockedLevels.contains(levelNumber);
  }
  
  /// Check if a level is completed
  static Future<bool> isLevelCompleted(int levelNumber) async {
    final completedLevels = await getCompletedLevels();
    return completedLevels.contains(levelNumber);
  }
  
  /// Get progress statistics
  static Future<Map<String, dynamic>> getProgressStats() async {
    final completedLevels = await getCompletedLevels();
    final unlockedLevels = await getUnlockedLevels();
    
    return {
      'completedCount': completedLevels.length,
      'unlockedCount': unlockedLevels.length,
      'completedLevels': completedLevels.toList()..sort(),
      'unlockedLevels': unlockedLevels.toList()..sort(),
    };
  }
  
  /// Reset all progress (for testing or reset functionality)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedLevelsKey);
    await prefs.remove(_unlockedLevelsKey);
  }
  
  /// Initialize progress (call this when app starts)
  static Future<void> initializeProgress() async {
    final unlockedLevels = await getUnlockedLevels();
    
    // Ensure level 1 is always unlocked
    if (!unlockedLevels.contains(1)) {
      unlockedLevels.add(1);
      await saveUnlockedLevels(unlockedLevels);
    }
  }
}
