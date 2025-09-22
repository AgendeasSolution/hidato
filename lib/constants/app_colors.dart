import 'package:flutter/material.dart';

/// Application color scheme
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF8B5CF6);
  
  // Secondary colors
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryDark = Color(0xFF1D4ED8);
  
  // Success colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF166534);
  
  // Warning colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);
  
  // Error colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorDark = Color(0xFF991B1B);
  
  // Neutral colors - matching the design
  static const Color background = Color(0xFFF5F5F5); // Light grey background
  static const Color surface = Colors.white; // White card background
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color border = Color(0xFFE0E0E0); // Light grey border
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color textPrimary = Color(0xFF333333); // Dark text
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF999999);
  
  // Game board colors - matching the design specifications
  static const Color cellEmpty = Colors.white; // Empty cells
  
  // User-placed numbers (blue theme)
  static const Color cellUserBg1 = Color(0xFFDBEAFE); // Light blue
  static const Color cellUserBg2 = Color(0xFFBFDBFE); // Medium blue
  static const Color cellUserText = Color(0xFF1E40AF); // Dark blue
  static const Color cellUserBorder = Color(0xFF93C5FD); // Medium blue border
  
  // Clue numbers (gray theme)
  static const Color cellClueBg1 = Color(0xFFF1F5F9); // Light gray
  static const Color cellClueBg2 = Color(0xFFE2E8F0); // Medium gray
  static const Color cellClueText = Color(0xFF475569); // Dark gray
  static const Color cellClueBorder = Color(0xFFCBD5E1); // Light gray border
  
  // Start number (green theme)
  static const Color cellStartBg1 = Color(0xFFDCFCE7); // Light green
  static const Color cellStartBg2 = Color(0xFFBBF7D0); // Medium green
  static const Color cellStartText = Color(0xFF166534); // Dark green
  static const Color cellStartBorder = Color(0xFF86EFAC); // Medium green border
  
  // End number (red theme)
  static const Color cellEndBg1 = Color(0xFFFEF2F2); // Light red
  static const Color cellEndBg2 = Color(0xFFFECACA); // Medium red
  static const Color cellEndText = Color(0xFF991B1B); // Dark red
  static const Color cellEndBorder = Color(0xFFFCA5A5); // Medium red border
  
  // Error state (red theme)
  static const Color cellErrorBg1 = Color(0xFFFEF2F2); // Light red
  static const Color cellErrorBg2 = Color(0xFFFECACA); // Medium red
  static const Color cellErrorText = Color(0xFFDC2626); // Red
  static const Color cellErrorBorder = Color(0xFFF87171); // Red border
  
  // Hint highlight (yellow theme)
  static const Color cellHintBg1 = Color(0xFFFEF3C7); // Light yellow
  static const Color cellHintBg2 = Color(0xFFFDE68A); // Medium yellow
  static const Color cellHintText = Color(0xFF92400E); // Dark yellow
  static const Color cellHintBorder = Color(0xFFF59E0B); // Orange border
  
  // Highlight state
  static const Color cellHighlightBorder = Color(0xFF3B82F6); // Blue border
  static const Color cellHighlightShadow = Color(0x333B82F6); // Blue shadow
  static const Color cellSelected = Color(0xFF3B82F6);
  
  // Button colors from design
  static const Color buttonPurple = Color(0xFF8B5CF6); // Hint button
  static const Color buttonTeal = Color(0xFF14B8A6); // Solution button (teal-green)
  static const Color buttonOrange = Color(0xFFF59E0B); // Reset button
  static const Color buttonGrey = Color(0xFF9CA3AF); // Undo button
  static const Color buttonWhite = Colors.white; // Level button
  
  // Text highlight colors
  static const Color textBlue = Color(0xFF3B82F6); // Blue highlight for numbers
  
  // Shadow colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x19000000);
  static const Color shadowDark = Color(0x40000000);
}

