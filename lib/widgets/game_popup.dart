import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'game_button.dart';

/// A reusable popup dialog widget
class GamePopup extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? emoji;
  final Widget? content;
  final String? buttonText;
  final VoidCallback? onButtonTap;
  final Color? buttonColor;
  final List<Widget>? additionalButtons;

  const GamePopup({
    super.key,
    required this.title,
    this.subtitle,
    this.emoji,
    this.content,
    this.buttonText,
    this.onButtonTap,
    this.buttonColor,
    this.additionalButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                style: GoogleFonts.jua(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F46E5), // Logo color
                  letterSpacing: 2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              if (content != null) ...[
                const SizedBox(height: 16),
                content!,
              ],
              const SizedBox(height: 24),
              if (buttonText != null && onButtonTap != null)
                ActionButton(
                  text: buttonText!,
                  onTap: onButtonTap!,
                  color: buttonColor ?? AppColors.primary,
                ),
              if (additionalButtons != null) ...[
                const SizedBox(height: 12),
                ...additionalButtons!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A popup specifically for game start
class StartPopup extends StatelessWidget {
  final VoidCallback onStart;

  const StartPopup({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return GamePopup(
      title: 'Hidato Puzzle',
      emoji: '🎯',
      content: Column(
        children: [
          const Text(
            'How to Play',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '1. Fill the grid with consecutive numbers from start to end\n'
                '2. Numbers must be adjacent (horizontally or vertically)\n'
                '3. Start from the lowest number and work your way up\n'
                '4. Use the hint button if you get stuck!',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      buttonText: 'Start Playing',
      onButtonTap: onStart,
      buttonColor: AppColors.primary,
    );
  }
}

/// A popup for level completion
class LevelCompletionPopup extends StatelessWidget {
  final int level;
  final VoidCallback onNext;

  const LevelCompletionPopup({
    super.key,
    required this.level,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              // Title
              Text(
                'Level $level Complete!',
                textAlign: TextAlign.center,
                style: GoogleFonts.jua(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F46E5), // Logo color
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle with center alignment and different color
              Text(
                'Great job! Ready for the next challenge?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF059669), // Success green color
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              // Button
              ActionButton(
                text: 'Next Level',
                onTap: onNext,
                color: AppColors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A popup for all levels completed
class AllLevelsCompletedPopup extends StatelessWidget {
  final VoidCallback onBackToHome;

  const AllLevelsCompletedPopup({
    super.key,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return GamePopup(
      title: 'Congratulations!',
      emoji: '🎊',
      subtitle: 'You\'ve completed all levels!',
      buttonText: 'Back to Home',
      onButtonTap: onBackToHome,
      buttonColor: AppColors.warning,
    );
  }
}

/// A popup for hints
class HintPopup extends StatelessWidget {
  final String message;
  final VoidCallback onOk;

  const HintPopup({
    super.key,
    required this.message,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              const Text('💡', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              // Title
              Text(
                'Hint',
                textAlign: TextAlign.center,
                style: GoogleFonts.jua(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F46E5), // Logo color
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              // Content with center alignment
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // Button
              ActionButton(
                text: 'OK',
                onTap: onOk,
                color: AppColors.primaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A popup for loading states with logo styling
class LoadingPopup extends StatefulWidget {
  final String message;
  final VoidCallback? onComplete;

  const LoadingPopup({
    super.key,
    required this.message,
    this.onComplete,
  });

  @override
  State<LoadingPopup> createState() => _LoadingPopupState();
}

class _LoadingPopupState extends State<LoadingPopup> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading message with logo font and color
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.jua(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4F46E5), // Logo color
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
