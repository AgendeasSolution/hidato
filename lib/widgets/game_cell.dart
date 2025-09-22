import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';
import '../models/position.dart';

/// A single cell in the game board
class GameCell extends StatelessWidget {
  final int value;
  final bool isClue;
  final bool isLastPlaced;
  final bool isHintPosition;
  final bool isEmpty;
  final double size;
  final double fontSize;
  final VoidCallback? onTap;

  const GameCell({
    super.key,
    required this.value,
    required this.isClue,
    required this.isLastPlaced,
    required this.isHintPosition,
    required this.isEmpty,
    required this.size,
    required this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getCellColors();
    final actualFontSize = _getResponsiveFontSize(context);

    return GestureDetector(
      onTap: isEmpty ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: colors.gradient,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colors.borderColor,
            width: colors.borderWidth,
          ),
          boxShadow: _getBoxShadow(),
        ),
        child: Center(
          child: value == 0
              ? const SizedBox.shrink()
              : Text(
                  value.toString(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: actualFontSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context) {
    // Responsive font sizing: clamp(1.2rem, 4vw, 2.5rem) - increased for better visibility
    final screenWidth = MediaQuery.of(context).size.width;
    final viewportWidth = screenWidth / 100; // Convert to vw units
    final responsiveSize = viewportWidth * 4.0; // 4vw - increased from 2.5vw
    final minSize = 19.2; // 1.2rem = 19.2px - increased from 9.6px
    final maxSize = 40.0; // 2.5rem = 40px - increased from 24px
    
    return math.max(minSize, math.min(maxSize, responsiveSize));
  }

  _CellColors _getCellColors() {
    if (isHintPosition) {
      // Hint highlight (yellow theme)
      return _CellColors(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cellHintBg1, AppColors.cellHintBg2],
        ),
        textColor: AppColors.cellHintText,
        borderColor: AppColors.cellHintBorder,
        borderWidth: 3,
      );
    } else if (isClue) {
      // Clue numbers (gray theme)
      return _CellColors(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cellClueBg1, AppColors.cellClueBg2],
        ),
        textColor: AppColors.cellClueText,
        borderColor: AppColors.cellClueBorder,
        borderWidth: 1,
      );
    } else if (isEmpty) {
      // Empty cells - white background
      return _CellColors(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cellEmpty, AppColors.cellEmpty],
        ),
        textColor: AppColors.textPrimary,
        borderColor: AppColors.borderLight,
        borderWidth: 1,
      );
    } else {
      // User placed numbers - blue theme
      return _CellColors(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cellUserBg1, AppColors.cellUserBg2],
        ),
        textColor: AppColors.cellUserText,
        borderColor: AppColors.cellUserBorder,
        borderWidth: isLastPlaced ? 3 : 1,
      );
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    if (isLastPlaced) {
      // Highlight state
      return [
        BoxShadow(
          color: AppColors.cellHighlightShadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (isHintPosition) {
      // Hint highlight
      return [
        BoxShadow(
          color: AppColors.cellHintBorder.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return null;
  }
}

class _CellColors {
  final LinearGradient gradient;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;

  _CellColors({
    required this.gradient,
    required this.textColor,
    required this.borderColor,
    required this.borderWidth,
  });
}

