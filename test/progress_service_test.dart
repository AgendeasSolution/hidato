import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hidato/services/progress_service.dart';

void main() {
  group('ProgressService Tests', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should initialize with only level 1 unlocked', () async {
      await ProgressService.initializeProgress();
      
      final unlockedLevels = await ProgressService.getUnlockedLevels();
      final completedLevels = await ProgressService.getCompletedLevels();
      
      expect(unlockedLevels, contains(1));
      expect(unlockedLevels.length, 1);
      expect(completedLevels.length, 0);
    });

    test('should unlock next level when completing a level', () async {
      await ProgressService.initializeProgress();
      
      // Complete level 1
      await ProgressService.completeLevel(1);
      
      final unlockedLevels = await ProgressService.getUnlockedLevels();
      final completedLevels = await ProgressService.getCompletedLevels();
      
      expect(unlockedLevels, contains(1));
      expect(unlockedLevels, contains(2));
      expect(unlockedLevels.length, 2);
      expect(completedLevels, contains(1));
      expect(completedLevels.length, 1);
    });

    test('should check if level is unlocked correctly', () async {
      await ProgressService.initializeProgress();
      
      expect(await ProgressService.isLevelUnlocked(1), true);
      expect(await ProgressService.isLevelUnlocked(2), false);
      
      await ProgressService.completeLevel(1);
      
      expect(await ProgressService.isLevelUnlocked(1), true);
      expect(await ProgressService.isLevelUnlocked(2), true);
      expect(await ProgressService.isLevelUnlocked(3), false);
    });

    test('should check if level is completed correctly', () async {
      await ProgressService.initializeProgress();
      
      expect(await ProgressService.isLevelCompleted(1), false);
      
      await ProgressService.completeLevel(1);
      
      expect(await ProgressService.isLevelCompleted(1), true);
      expect(await ProgressService.isLevelCompleted(2), false);
    });

    test('should get progress stats correctly', () async {
      await ProgressService.initializeProgress();
      
      var stats = await ProgressService.getProgressStats();
      expect(stats['completedCount'], 0);
      expect(stats['unlockedCount'], 1);
      expect(stats['completedLevels'], []);
      expect(stats['unlockedLevels'], [1]);
      
      await ProgressService.completeLevel(1);
      
      stats = await ProgressService.getProgressStats();
      expect(stats['completedCount'], 1);
      expect(stats['unlockedCount'], 2);
      expect(stats['completedLevels'], [1]);
      expect(stats['unlockedLevels'], [1, 2]);
    });

    test('should reset progress correctly', () async {
      await ProgressService.initializeProgress();
      await ProgressService.completeLevel(1);
      await ProgressService.completeLevel(2);
      
      // Verify some progress exists
      expect((await ProgressService.getCompletedLevels()).length, 2);
      expect((await ProgressService.getUnlockedLevels()).length, 3);
      
      // Reset progress
      await ProgressService.resetProgress();
      
      // Should be back to initial state
      final unlockedLevels = await ProgressService.getUnlockedLevels();
      final completedLevels = await ProgressService.getCompletedLevels();
      
      expect(unlockedLevels.length, 1);
      expect(unlockedLevels, contains(1));
      expect(completedLevels.length, 0);
    });
  });
}
