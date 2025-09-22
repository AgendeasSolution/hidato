import 'package:flutter/material.dart';
import '../constants/index.dart';
import '../models/index.dart';
import '../services/index.dart';
import '../utils/index.dart';
import '../widgets/index.dart';

/// Main game screen for the Hidato puzzle
class GameScreen extends StatefulWidget {
  final int initialLevel;
  final Set<int> completedLevels;
  final Function(int) onLevelCompleted;
  
  const GameScreen({
    super.key,
    this.initialLevel = 0,
    this.completedLevels = const {},
    required this.onLevelCompleted,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game state
  List<List<int>> currentBoard = [];
  List<List<int>> originalPuzzleBoard = [];
  int nextNumber = 1;
  int startNum = 1;
  int endNum = 25;
  Position? lastPlacedPos;
  List<GameState> stateHistory = [];
  bool isSolved = false;
  List<List<List<int>>> currentSolutions = [];
  int currentSolutionIndex = 0;
  bool solutionButtonUsed = false;
  int hintCount = 0;
  int maxHints = 7; // Fixed limit of 7 hints per game
  int currentLevel = 1;
  int currentPuzzleIndex = 0;
  late Set<int> completedLevels;

  // Services
  late final GameValidator _validator;
  late final HintService _hintService;
  late final InterstitialAdService _interstitialAdService;
  late final RewardedAdService _rewardedAdService;

  // UI state
  bool showStartPopup = true;
  bool showGameOverPopup = false;
  bool showHintPopup = false;
  bool showLevelCompletionPopup = false;
  bool showAllLevelsCompletedPopup = false;
  bool showLoadingPopup = false;
  String loadingMessage = 'Loading...';
  bool isFillingSolution = false;
  String hintMessage = '';
  Position? hintPosition;
  bool isLoadingHintAd = false;
  bool isLoadingSolutionAd = false;
  late AnimationController _confettiController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    completedLevels = Set.from(widget.completedLevels);
    currentPuzzleIndex = widget.initialLevel;
    currentLevel = widget.initialLevel + 1;
    _initializeServices();
    _initializeAnimations();
    _startGame();
  }

  void _initializeServices() async {
    _validator = GameValidator();
    _hintService = HintService(GameSolver());
    _interstitialAdService = InterstitialAdService.instance;
    _rewardedAdService = RewardedAdService.instance;
    
    // Preload ads for better user experience
    _interstitialAdService.preloadAd();
    
    // Initialize rewarded ads and wait for them to be ready
    await _initializeRewardedAds();
  }

  Future<void> _initializeRewardedAds() async {
    try {
      // Load the first rewarded ad
      await _rewardedAdService.loadAd();
      print('Rewarded ad initialized successfully');
    } catch (e) {
      print('Failed to initialize rewarded ad: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _initializeAnimations() {
    _confettiController = AnimationController(
      duration: AppConstants.confettiDuration,
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: AppConstants.bounceDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bounceController.dispose();
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
              child: Stack(
                children: [
                  // Main game content - always show unless start popup is showing
                  if (!showStartPopup)
                    _buildGameContent(),

                  // Popups
                  if (showStartPopup) _buildStartPopup(),
                  if (showGameOverPopup) _buildGameOverPopup(),
                  if (showLevelCompletionPopup) _buildLevelCompletionPopup(),
                  if (showAllLevelsCompletedPopup) _buildAllLevelsCompletedPopup(),
                  if (showHintPopup) _buildHintPopup(),
                  if (showLoadingPopup) _buildLoadingPopup(),
                ],
              ),
            ),
            // Independent ad banner overlay at bottom
            AdBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    return Stack(
      children: [
        // Top controls positioned at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopControls(),
        ),
        // Game board completely centered vertically and independently positioned
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: _buildCombinedGameArea(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildBackButton(),
              Expanded(
                child: Center(
                  child: _buildLevelText(),
                ),
              ),
              const SizedBox(width: 44), // Spacer to balance the layout
            ],
          ),
          const SizedBox(height: 24),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.chevron_left,
          color: Colors.black,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildLevelText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9D5FF).withOpacity(0.6), // Reduced opacity light purple background
        borderRadius: BorderRadius.circular(20), // Oval shape
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.3), // Purple border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Level $currentLevel',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7C3AED), // Dark purple text
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    // If solution is being filled, hide all buttons
    if (isFillingSolution) {
      return const SizedBox.shrink();
    }

    // If game is solved (all cells filled), show only Play Again button
    if (isSolved) {
      return Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120, // Wider to fit "Play Again" text
              child: _buildControlButton(
                text: 'Play Again',
                icon: Icons.refresh,
                onTap: _handlePlayAgain,
                color: AppColors.buttonPurple,
              ),
            ),
          ],
        ),
      );
    }

    // Normal control buttons
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _buildControlButton(
              text: 'Hint',
              subtitle: isLoadingHintAd ? 'Loading...' : (hintCount >= maxHints ? 'No More' : 'Watch Ad • ${maxHints - hintCount}/$maxHints'),
              icon: Icons.lightbulb_outline,
              onTap: (hintCount >= maxHints || isLoadingHintAd) ? null : _handleHint,
              color: AppColors.buttonPurple,
              isDisabled: hintCount >= maxHints || isLoadingHintAd,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildControlButton(
              text: 'Solution',
              subtitle: isLoadingSolutionAd ? 'Loading...' : 'Watch Ad',
              icon: Icons.visibility,
              onTap: isLoadingSolutionAd ? null : _handleSolution,
              color: AppColors.success,
              isDisabled: isLoadingSolutionAd,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildControlButton(
              text: 'Reset',
              subtitle: 'Ad',
              icon: Icons.refresh,
              onTap: _handleReset,
              color: AppColors.buttonOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildControlButton(
              text: 'Undo',
              icon: Icons.undo,
              onTap: stateHistory.isEmpty ? null : _handleUndo,
              color: AppColors.error,
              isDisabled: stateHistory.isEmpty,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String text,
    String? subtitle,
    IconData? icon,
    required VoidCallback? onTap,
    required Color color,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[300] : color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDisabled ? null : [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDisabled ? Colors.grey[500] : Colors.white,
                size: 14,
              ),
              const SizedBox(height: 1),
            ],
            Text(
              text,
              style: TextStyle(
                color: isDisabled ? Colors.grey[500] : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: TextStyle(
                  color: isDisabled ? Colors.grey[400] : Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 6,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedGameArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Place number text
          nextNumber > endNum
              ? Text(
                  solutionButtonUsed 
                      ? '✅ Solution found!' 
                      : 'Congratulations! You solved it correctly!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                )
              : RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Place number: '),
                      TextSpan(
                        text: '$nextNumber',
                        style: const TextStyle(
                          color: AppColors.textBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 20),
          // Game board
          _buildGameBoardContent(),
        ],
      ),
    );
  }

  Widget _buildGameBoardContent() {
    if (currentBoard.isEmpty) return const SizedBox();

    final size = currentBoard.length;
    final screenSize = MediaQuery.of(context).size;
    // More responsive sizing that accounts for padding and works with centering
    final availableWidth = screenSize.width - 80; // Account for padding and margins
    final cellSize = (availableWidth - (size - 1) * 4) / size; // Account for gaps
    final gap = 4.0;
    final fontSize = cellSize * 0.35;

    return Container(
      width: cellSize * size + (size - 1) * gap,
      height: cellSize * size + (size - 1) * gap,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        ),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6), // Reduced from 8 to 6
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
        ),
        itemCount: size * size,
        itemBuilder: (context, index) {
          final row = index ~/ size;
          final col = index % size;
          return _buildCell(row, col, cellSize, fontSize);
        },
      ),
    );
  }

  Widget _buildCell(int row, int col, double size, double fontSize) {
    final value = currentBoard[row][col];
    final isClue = originalPuzzleBoard[row][col] != 0;
    final isLastPlaced = lastPlacedPos?.row == row && lastPlacedPos?.col == col;
    final isHintPosition = hintPosition?.row == row && hintPosition?.col == col;
    final isEmpty = value == 0;

    return GameCell(
      value: value,
      isClue: isClue,
      isLastPlaced: isLastPlaced,
      isHintPosition: isHintPosition,
      isEmpty: isEmpty,
      size: size,
      fontSize: fontSize,
      onTap: isEmpty && !isSolved ? () => _handleCellClick(row, col) : null,
    );
  }


  // Popup builders
  Widget _buildStartPopup() {
    return StartPopup(onStart: _startGame);
  }

  Widget _buildGameOverPopup() {
    return GamePopup(
      title: 'Congratulations!',
      emoji: '🎯',
      subtitle: 'You solved the puzzle perfectly!',
      buttonText: 'Next Challenge',
      onButtonTap: _startGame,
      buttonColor: AppColors.success,
    );
  }

  Widget _buildLevelCompletionPopup() {
    return LevelCompletionPopup(
      level: currentLevel,
      onNext: () {
        setState(() {
          showLevelCompletionPopup = false;
          currentPuzzleIndex++;
          currentLevel++;
          _startGame();
        });
      },
    );
  }

  Widget _buildAllLevelsCompletedPopup() {
    return AllLevelsCompletedPopup(
      onBackToHome: () {
        setState(() {
          showAllLevelsCompletedPopup = false;
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildHintPopup() {
    return HintPopup(
      message: hintMessage,
      onOk: () {
        setState(() {
          showHintPopup = false;
          hintPosition = null;
        });
      },
    );
  }

  Widget _buildLoadingPopup() {
    return LoadingPopup(
      message: loadingMessage,
      onComplete: () {
        setState(() {
          showLoadingPopup = false;
        });
      },
    );
  }


  // Game logic methods
  void _handleCellClick(int row, int col) {
    if (currentBoard[row][col] != 0) return;

    final isValidMove = _validator.isValidMove(Position(row, col), lastPlacedPos);

    if (isValidMove) {
      setState(() {
        stateHistory.add(GameState(
          board: GameUtils.deepCopyBoard(currentBoard),
          nextNumber: nextNumber,
          lastPlacedPos: lastPlacedPos,
        ));
        currentBoard[row][col] = nextNumber;
        lastPlacedPos = Position(row, col);
        nextNumber++;
        _advanceGameState();
      });

      _checkWinCondition();
    } else {
      // Show error animation
      _bounceController.forward().then((_) => _bounceController.reverse());
    }
  }

  void _advanceGameState() {
    Position? positionOfNext = _validator.findNumberPosition(currentBoard, nextNumber);
    while (positionOfNext != null && nextNumber <= endNum) {
      lastPlacedPos = positionOfNext;
      nextNumber++;
      positionOfNext = _validator.findNumberPosition(currentBoard, nextNumber);
    }
  }

  void _handleUndo() {
    if (stateHistory.isEmpty) return;

    setState(() {
      final prevState = stateHistory.removeLast();
      currentBoard = prevState.board;
      nextNumber = prevState.nextNumber;
      lastPlacedPos = prevState.lastPlacedPos;
    });

    _checkWinCondition();
  }

  void _handleReset() {
    // Show interstitial ad with 50% probability before resetting
    _interstitialAdService.showAdWithCustomProbability(0.5, onAdDismissed: () {
      // This callback runs after the ad is dismissed
      _performReset();
    }).then((adShown) {
      // If ad wasn't shown (50% chance or ad not ready), reset immediately
      if (!adShown) {
        _performReset();
      }
    });
  }

  void _performReset() {
    setState(() {
      isSolved = false;
      solutionButtonUsed = false;
      isFillingSolution = false;
      currentBoard = GameUtils.deepCopyBoard(originalPuzzleBoard);
      stateHistory = [];
      hintCount = 0;
      maxHints = (originalPuzzleBoard.length * originalPuzzleBoard[0].length / AppConstants.maxHintsMultiplier).ceil();
      nextNumber = 1;
      lastPlacedPos = _validator.findNumberPosition(currentBoard, 1);
      if (lastPlacedPos != null) {
        _advanceGameState();
      }
    });

    _checkWinCondition();
  }

  void _handlePlayAgain() {
    setState(() {
      isSolved = false;
      solutionButtonUsed = false;
      isFillingSolution = false;
      hintCount = 0;
      showGameOverPopup = false;
      showLevelCompletionPopup = false;
      showAllLevelsCompletedPopup = false;
    });
    _startGame();
  }


  void _handleSolution() async {
    if (currentPuzzleIndex == -1 || isLoadingSolutionAd) return;

    setState(() {
      isLoadingSolutionAd = true;
      loadingMessage = 'Loading Ad...';
      showLoadingPopup = true;
    });

    try {
      // Show rewarded ad - service will handle loading if needed
      final adShown = await _rewardedAdService.showAdAlways(
        onRewardEarned: () {
          // User earned reward - just mark that reward was earned
          // Don't apply solution yet, wait for ad to be dismissed
          print('User earned reward for solution');
        },
        onAdDismissed: () {
          // Ad was dismissed - check if reward was earned
          if (_rewardedAdService.wasRewardEarned) {
            // User watched the full ad and earned reward - now give them the solution
            _giveSolution();
          } else {
            // User didn't watch the full ad - show message
            _showSnackBar('Please watch the full ad to get the solution!');
          }
        },
      );

      // Hide loading popup
      setState(() {
        showLoadingPopup = false;
        isLoadingSolutionAd = false;
      });

      // If ad couldn't be shown, show error message instead of giving solution
      if (!adShown) {
        _showSnackBar('Unable to load ad. Please try again later.');
      }
    } catch (e) {
      setState(() {
        showLoadingPopup = false;
        isLoadingSolutionAd = false;
      });
      _showSnackBar('Error loading ad: $e');
    }
  }

  void _giveSolution() async {
    // Check if solutions are already cached
    List<List<List<int>>>? cachedSolutions = SolutionCache.getSolutions(originalPuzzleBoard);
    
    if (cachedSolutions != null && cachedSolutions.isNotEmpty) {
      // Solutions are already cached - use them immediately without popup
      _applySolution(cachedSolutions);
      return;
    }

    // Solutions not cached - show loading popup and compute
    setState(() {
      loadingMessage = 'Finding Solution...';
      showLoadingPopup = true;
    });

    // Add a small delay to ensure popup is visible
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // Compute solutions since they're not cached
      final uniqueness = await _hintService.checkUniqueness(originalPuzzleBoard);
      final solutions = uniqueness.solutions;
      
      // Cache the solutions for future use
      if (solutions.isNotEmpty) {
        SolutionCache.storeSolutions(originalPuzzleBoard, solutions);
      }

      // Ensure popup shows for at least 300ms
      await Future.delayed(const Duration(milliseconds: 300));

      // Hide loading popup
      setState(() {
        showLoadingPopup = false;
      });

      if (solutions.isEmpty) {
        setState(() {
          hintMessage = 'No solution found for this puzzle! The puzzle may be invalid.';
          showHintPopup = true;
        });
        return;
      }

      _applySolution(solutions);
    } catch (e) {
      // Ensure popup shows for at least 300ms even on error
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Hide loading popup
      setState(() {
        showLoadingPopup = false;
        hintMessage = 'Error finding solution: $e';
        showHintPopup = true;
      });
    }
  }

  void _applySolution(List<List<List<int>>> solutions) {
    currentSolutions = solutions;
    currentSolutionIndex = 0;

    // Set state but don't mark as solved yet - wait for animation to complete
    setState(() {
      solutionButtonUsed = true;
      currentBoard = GameUtils.deepCopyBoard(currentSolutions[currentSolutionIndex]);
      stateHistory = [];
      nextNumber = endNum + 1;
      lastPlacedPos = _validator.findNumberPosition(currentBoard, endNum);
    });

    // Run solution filling animation in background
    _animateSolutionFilling();
  }

  Future<void> _animateSolutionFilling() async {
    if (currentSolutions.isEmpty) return;

    final solution = currentSolutions[currentSolutionIndex];
    
    // Start solution filling animation - hide all buttons
    setState(() {
      isFillingSolution = true;
      currentBoard = GameUtils.deepCopyBoard(originalPuzzleBoard);
    });
    
    // Find all empty cells that need to be filled, sorted by their number value
    final List<Map<String, dynamic>> cellsToFill = [];
    for (int r = 0; r < solution.length; r++) {
      for (int c = 0; c < solution[r].length; c++) {
        if (originalPuzzleBoard[r][c] == 0 && solution[r][c] != 0) {
          cellsToFill.add({
            'position': Position(r, c),
            'number': solution[r][c],
          });
        }
      }
    }

    // Sort by number value (1, 2, 3, 4, etc.)
    cellsToFill.sort((a, b) => a['number'].compareTo(b['number']));

    // Animate filling each cell in numerical order
    for (int i = 0; i < cellsToFill.length; i++) {
      final pos = cellsToFill[i]['position'] as Position;
      final number = cellsToFill[i]['number'] as int;
      
      setState(() {
        currentBoard[pos.row][pos.col] = number;
      });
      
      // Wait a bit between each cell fill
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    // Mark as solved and show buttons again after animation is complete
    setState(() {
      isSolved = true;
      isFillingSolution = false;
    });
  }

  void _handleHint() async {
    if (isSolved || nextNumber > endNum || isLoadingHintAd) return;

    setState(() {
      isLoadingHintAd = true;
      loadingMessage = 'Loading Ad...';
      showLoadingPopup = true;
    });

    try {
      // Show rewarded ad - service will handle loading if needed
      final adShown = await _rewardedAdService.showAdAlways(
        onRewardEarned: () {
          // User earned reward - just mark that reward was earned
          // Don't apply hint yet, wait for ad to be dismissed
          print('User earned reward for hint');
        },
        onAdDismissed: () {
          // Ad was dismissed - check if reward was earned
          if (_rewardedAdService.wasRewardEarned) {
            // User watched the full ad and earned reward - now give them the hint
            _giveHint();
          } else {
            // User didn't watch the full ad - show message
            _showSnackBar('Please watch the full ad to get your hint!');
          }
        },
      );

      // Hide loading popup
      setState(() {
        showLoadingPopup = false;
        isLoadingHintAd = false;
      });

      // If ad couldn't be shown, show error message instead of giving hint
      if (!adShown) {
        _showSnackBar('Unable to load ad. Please try again later.');
      }
    } catch (e) {
      setState(() {
        showLoadingPopup = false;
        isLoadingHintAd = false;
      });
      _showSnackBar('Error loading ad: $e');
    }
  }

  void _giveHint() async {
    // Check if solutions are already cached
    bool solutionsCached = SolutionCache.hasSolutions(originalPuzzleBoard);
    
    if (!solutionsCached) {
      // Solutions not cached - show loading popup
      setState(() {
        loadingMessage = 'Finding Hint...';
        showLoadingPopup = true;
      });
    }

    setState(() {
      hintCount++;
    });


    // Add a small delay to ensure popup is visible (only if showing popup)
    if (!solutionsCached) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      int hintNumber = GameUtils.findNextNumberToPlace(
        currentBoard,
        originalPuzzleBoard,
        nextNumber,
        endNum,
      );

      // Use hint service which already handles cached solutions
      final hint = await _hintService.getHint(
        currentBoard,
        hintNumber,
        originalPuzzleBoard,
        lastPlacedPos,
      );

      // Only show popup for minimum time if solutions weren't cached
      if (!solutionsCached) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          showLoadingPopup = false;
        });
      }

      if (hint.position != null) {
        final pos = hint.position!;
        setState(() {
          currentBoard[pos.row][pos.col] = hintNumber;
          lastPlacedPos = pos;
          nextNumber = hintNumber + 1;
          hintPosition = pos;
        });

        // Advance game state to handle any consecutive numbers
        _advanceGameState();

        // Clear hint position after delay
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            hintPosition = null;
          });
        });

        _checkWinCondition();
      } else {
        setState(() {
          hintMessage = hint.message;
          showHintPopup = true;
        });
      }
    } catch (e) {
      // Hide loading popup if it was shown
      if (!solutionsCached) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          showLoadingPopup = false;
        });
      }
      
      setState(() {
        hintMessage = 'Error getting hint: $e';
        showHintPopup = true;
      });
    }
  }

  void _checkWinCondition() async {
    if (nextNumber > endNum) {
      final verification = _validator.verifySolution(
        currentBoard,
        originalPuzzleBoard,
        startNum,
        endNum,
      );

      setState(() {
        isSolved = verification.isCorrect;
        if (verification.isCorrect) {
          completedLevels.add(currentLevel);
          widget.onLevelCompleted(currentLevel);
        }
      });

      if (verification.isCorrect && !solutionButtonUsed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (currentPuzzleIndex < LevelData.levels.length - 1) {
            setState(() => showLevelCompletionPopup = true);
          } else {
            setState(() => showAllLevelsCompletedPopup = true);
          }
        });
      }
    }
  }


  void _startGame() async {
    setState(() {
      showStartPopup = false;
      showGameOverPopup = false;
      showLevelCompletionPopup = false;
      showAllLevelsCompletedPopup = false;
      isSolved = false;
      solutionButtonUsed = false;
      isFillingSolution = false;
    });

    final puzzleData = LevelData.levels[currentPuzzleIndex];
    originalPuzzleBoard = GameUtils.deepCopyBoard(puzzleData.initialBoard);
    currentBoard = GameUtils.deepCopyBoard(originalPuzzleBoard);

    final gridSize = puzzleData.totalCells;
    startNum = 1;
    endNum = gridSize;
    hintCount = 0;
    maxHints = (gridSize / AppConstants.maxHintsMultiplier).ceil();
    nextNumber = 1;
    lastPlacedPos = _validator.findNumberPosition(currentBoard, 1);

    if (lastPlacedPos != null) {
      _advanceGameState();
    }

    setState(() {});
  }
}

