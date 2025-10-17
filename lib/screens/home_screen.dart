import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/index.dart';
import '../models/index.dart';
import '../services/index.dart';
import '../widgets/index.dart';
import 'game_screen.dart';

/// Home screen with game logo, levels grid, and how to play button
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _gridController;
  late Animation<double> _logoAnimation;
  late Animation<double> _gridAnimation;
  
  Set<int> completedLevels = {};
  Set<int> unlockedLevels = {1}; // Level 1 unlocked by default
  late final AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService.instance;
    _initializeAnimations();
    _startAnimations();
    _loadProgress();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _gridAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _gridController.forward();
    });
  }

  Future<void> _loadProgress() async {
    await ProgressService.initializeProgress();
    final completed = await ProgressService.getCompletedLevels();
    final unlocked = await ProgressService.getUnlockedLevels();
    
    setState(() {
      completedLevels = completed;
      unlockedLevels = unlocked;
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content area - takes full available space
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 60, // Reserve space for ad banner
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40), // Space for the sound button
                    _buildGameLogo(),
                    const SizedBox(height: 16),
                    _buildLevelsGrid(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Sound button positioned at top-right corner
            Positioned(
              top: 8,
              right: 16,
              child: const SoundToggle(),
            ),
            // Independent ad banner overlay at bottom
            AdBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameLogo() {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoAnimation.value,
          child: Column(
            children: [
              Text(
                'Hidato Puzzle',
                style: GoogleFonts.jua(
                  fontSize: MediaQuery.of(context).size.width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F46E5),
                  letterSpacing: MediaQuery.of(context).size.width * 0.005,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelsGrid() {
    return AnimatedBuilder(
      animation: _gridAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _gridAnimation.value)),
            child: Opacity(
              opacity: _gridAnimation.value.clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Choose a Level',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Flexible(
                      child: _buildHowToPlayButton(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    crossAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                    mainAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                    childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.0 : 1.1,
                  ),
                  itemCount: LevelData.levels.length,
                  itemBuilder: (context, index) {
                    final level = LevelData.levels[index];
                    final isCompleted = completedLevels.contains(level.level);
                    final isUnlocked = unlockedLevels.contains(level.level);
                    return _buildLevelCard(level, isCompleted, isUnlocked);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(LevelConfig level, bool isCompleted, bool isUnlocked) {
    final isLocked = !isUnlocked;
    
    return GestureDetector(
      onTap: isLocked ? null : () {
        _audioService.playClickSound();
        _startLevel(level);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLocked
                ? [Colors.white, Colors.white] // White for locked cards
                : isCompleted
                    ? [const Color(0xFF4F46E5), const Color(0xFF4F46E5)] // Logo color for completed
                    : [AppColors.surface, AppColors.surfaceLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked 
                ? const Color(0xFFE2E8F0) // Light, subtle border
                : isCompleted 
                    ? const Color(0xFF4F46E5) // Logo color border
                    : const Color(0xFF4F46E5), // Logo color border for unlocked
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isLocked
                  ? const Color(0x08000000) // Very subtle shadow
                  : isCompleted 
                      ? const Color(0xFF4F46E5).withOpacity(0.3) // Logo color shadow
                      : AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock icon for locked levels
            if (isLocked)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
            // Check icon for completed levels
            if (isCompleted)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
            // Level number and grid size - only for unlocked and completed levels
            if (!isLocked) ...[
              Text(
                '${level.level}',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? Colors.white // White for completed levels
                      : AppColors.textPrimary, // Dark for unlocked levels
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${level.rows}×${level.columns}',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.025,
                  color: isCompleted 
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHowToPlayButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenWidth * 0.12,
      child: ElevatedButton(
        onPressed: () {
          _audioService.playClickSound();
          _showHowToPlay();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenWidth * 0.01,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
          ),
          elevation: 4,
          shadowColor: AppColors.secondary.withOpacity(0.3),
          minimumSize: Size.zero,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_outline, size: screenWidth * 0.04),
              SizedBox(width: screenWidth * 0.01),
              Text(
                'How to Play',
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLevel(LevelConfig level) {
    // Check if level is unlocked before starting
    if (!unlockedLevels.contains(level.level)) {
      _showLevelLockedDialog();
      return;
    }
    
    // Navigate to game screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          initialLevel: level.level - 1,
          completedLevels: completedLevels,
          onLevelCompleted: (levelNumber) async {
            // Update progress in storage
            await ProgressService.completeLevel(levelNumber);
            
            // Update local state
            setState(() {
              completedLevels.add(levelNumber);
              unlockedLevels.add(levelNumber + 1);
            });
          },
        ),
      ),
    ).then((_) {
      // Reload progress when returning from game screen
      _loadProgress();
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 6;
    if (width > 800) return 5;
    if (width > 600) return 4;
    return 3; // Minimum 3 columns for all devices
  }

  void _showLevelLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Level Locked',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: const Text(
          'Complete the previous level to unlock this one!',
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _audioService.playClickSound();
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }


  void _showHowToPlay() {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isMobile ? Colors.white : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(16),
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.1,
        ),
        title: Center(
          child: Text(
            'How to Play Hidato',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSection(
                context,
                '🎯 Objective',
                'Fill the grid with consecutive numbers from 1 to the highest number, where each number is adjacent to the next horizontally or vertically.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                '📋 Rules',
                '• You can only move horizontally or vertically (4 directions)\n'
                '• Diagonal moves are NOT allowed\n'
                '• Some numbers are already placed as clues\n'
                '• Complete the sequence to win!',
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                '💡 Tips',
                '• Look for the highest and lowest numbers first\n'
                '• Use the hint button if you get stuck\n'
                '• The solution button shows the complete answer\n'
                '• You can undo your moves anytime',
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4),
            child: ElevatedButton(
              onPressed: () {
                _audioService.playClickSound();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.025,
                  horizontal: screenWidth * 0.08,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: screenWidth * 0.04),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Got it! Let\'s Play',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}


