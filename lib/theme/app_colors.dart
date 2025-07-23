import 'package:flutter/material.dart';

/// Altertale App Color Palette
///
/// Comprehensive color system for the application:
/// - Material 3 compatible color scheme
/// - Light and dark mode support
/// - Semantic color definitions
/// - Brand color consistency
/// - Accessibility compliant contrast ratios
class AppColors {
  AppColors._();

  // ==================== BRAND COLORS ====================

  /// Primary brand color - Altertale's main color
  static const Color brandPrimary = Color(0xFF6366F1); // Indigo-500

  /// Secondary brand color - Accent color
  static const Color brandSecondary = Color(0xFF8B5CF6); // Violet-500

  /// Tertiary brand color - Supporting color
  static const Color brandTertiary = Color(0xFF06B6D4); // Cyan-500

  // ==================== LIGHT MODE COLORS ====================

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary colors
    primary: Color(0xFF6366F1), // Indigo-500
    onPrimary: Color(0xFFFFFFFF), // White
    primaryContainer: Color(0xFFE0E7FF), // Indigo-100
    onPrimaryContainer: Color(0xFF312E81), // Indigo-800
    // Secondary colors
    secondary: Color(0xFF8B5CF6), // Violet-500
    onSecondary: Color(0xFFFFFFFF), // White
    secondaryContainer: Color(0xFFEDE9FE), // Violet-100
    onSecondaryContainer: Color(0xFF581C87), // Violet-800
    // Tertiary colors
    tertiary: Color(0xFF06B6D4), // Cyan-500
    onTertiary: Color(0xFFFFFFFF), // White
    tertiaryContainer: Color(0xFFCFFAFE), // Cyan-100
    onTertiaryContainer: Color(0xFF164E63), // Cyan-800
    // Error colors
    error: Color(0xFFEF4444), // Red-500
    onError: Color(0xFFFFFFFF), // White
    errorContainer: Color(0xFFFEF2F2), // Red-50
    onErrorContainer: Color(0xFF991B1B), // Red-800
    // Background colors
    background: Color(0xFFFAFAFA), // Gray-50
    onBackground: Color(0xFF1F2937), // Gray-800
    // Surface colors
    surface: Color(0xFFFFFFFF), // White
    onSurface: Color(0xFF1F2937), // Gray-800
    surfaceVariant: Color(0xFFF3F4F6), // Gray-100
    onSurfaceVariant: Color(0xFF6B7280), // Gray-500
    // Outline colors
    outline: Color(0xFFD1D5DB), // Gray-300
    outlineVariant: Color(0xFFE5E7EB), // Gray-200
    // Surface tones
    surfaceTint: Color(0xFF6366F1), // Primary
    inverseSurface: Color(0xFF1F2937), // Gray-800
    onInverseSurface: Color(0xFFF9FAFB), // Gray-50
    inversePrimary: Color(0xFFA5B4FC), // Indigo-300
    // Shadows
    shadow: Color(0xFF000000), // Black
    scrim: Color(0xFF000000), // Black
  );

  // ==================== DARK MODE COLORS ====================

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary colors
    primary: Color(0xFFA5B4FC), // Indigo-300
    onPrimary: Color(0xFF312E81), // Indigo-800
    primaryContainer: Color(0xFF4338CA), // Indigo-600
    onPrimaryContainer: Color(0xFFE0E7FF), // Indigo-100
    // Secondary colors
    secondary: Color(0xFFC4B5FD), // Violet-300
    onSecondary: Color(0xFF581C87), // Violet-800
    secondaryContainer: Color(0xFF7C3AED), // Violet-600
    onSecondaryContainer: Color(0xFFEDE9FE), // Violet-100
    // Tertiary colors
    tertiary: Color(0xFF67E8F9), // Cyan-300
    onTertiary: Color(0xFF164E63), // Cyan-800
    tertiaryContainer: Color(0xFF0891B2), // Cyan-600
    onTertiaryContainer: Color(0xFFCFFAFE), // Cyan-100
    // Error colors
    error: Color(0xFFF87171), // Red-400
    onError: Color(0xFF991B1B), // Red-800
    errorContainer: Color(0xFFDC2626), // Red-600
    onErrorContainer: Color(0xFFFEF2F2), // Red-50
    // Background colors
    background: Color(0xFF0F172A), // Slate-900
    onBackground: Color(0xFFF1F5F9), // Slate-100
    // Surface colors
    surface: Color(0xFF1E293B), // Slate-800
    onSurface: Color(0xFFF1F5F9), // Slate-100
    surfaceVariant: Color(0xFF334155), // Slate-700
    onSurfaceVariant: Color(0xFF94A3B8), // Slate-400
    // Outline colors
    outline: Color(0xFF475569), // Slate-600
    outlineVariant: Color(0xFF64748B), // Slate-500
    // Surface tones
    surfaceTint: Color(0xFFA5B4FC), // Primary
    inverseSurface: Color(0xFFF1F5F9), // Slate-100
    onInverseSurface: Color(0xFF1E293B), // Slate-800
    inversePrimary: Color(0xFF6366F1), // Indigo-500
    // Shadows
    shadow: Color(0xFF000000), // Black
    scrim: Color(0xFF000000), // Black
  );

  // ==================== SEMANTIC COLORS ====================

  /// Success colors
  static const Color successLight = Color(0xFF10B981); // Emerald-500
  static const Color successDark = Color(0xFF34D399); // Emerald-400
  static const Color onSuccessLight = Color(0xFFFFFFFF); // White
  static const Color onSuccessDark = Color(0xFF064E3B); // Emerald-800

  /// Warning colors
  static const Color warningLight = Color(0xFFF59E0B); // Amber-500
  static const Color warningDark = Color(0xFFFBBF24); // Amber-400
  static const Color onWarningLight = Color(0xFFFFFFFF); // White
  static const Color onWarningDark = Color(0xFF78350F); // Amber-800

  /// Info colors
  static const Color infoLight = Color(0xFF3B82F6); // Blue-500
  static const Color infoDark = Color(0xFF60A5FA); // Blue-400
  static const Color onInfoLight = Color(0xFFFFFFFF); // White
  static const Color onInfoDark = Color(0xFF1E3A8A); // Blue-800

  // ==================== CONTENT COLORS ====================

  /// Reading content background
  static const Color readingBackgroundLight = Color(0xFFFFFBEB); // Amber-50
  static const Color readingBackgroundDark = Color(0xFF1F2937); // Gray-800

  /// Highlight colors for text selection
  static const Color highlightLight = Color(0xFFFEF3C7); // Amber-100
  static const Color highlightDark = Color(0xFF374151); // Gray-700

  // ==================== HELPER METHODS ====================

  /// Get success color based on brightness
  static Color getSuccessColor(Brightness brightness) {
    return brightness == Brightness.light ? successLight : successDark;
  }

  /// Get warning color based on brightness
  static Color getWarningColor(Brightness brightness) {
    return brightness == Brightness.light ? warningLight : warningDark;
  }

  /// Get info color based on brightness
  static Color getInfoColor(Brightness brightness) {
    return brightness == Brightness.light ? infoLight : infoDark;
  }

  /// Get reading background based on brightness
  static Color getReadingBackground(Brightness brightness) {
    return brightness == Brightness.light
        ? readingBackgroundLight
        : readingBackgroundDark;
  }

  /// Get highlight color based on brightness
  static Color getHighlightColor(Brightness brightness) {
    return brightness == Brightness.light ? highlightLight : highlightDark;
  }

  // ==================== COLOR VARIANTS ====================

  /// Primary color variants for different states
  static const Map<String, Color> primaryVariants = {
    'lightest': Color(0xFFF0F4FF), // Indigo-25
    'lighter': Color(0xFFE0E7FF), // Indigo-100
    'light': Color(0xFFC7D2FE), // Indigo-200
    'base': Color(0xFF6366F1), // Indigo-500
    'dark': Color(0xFF4338CA), // Indigo-600
    'darker': Color(0xFF3730A3), // Indigo-700
    'darkest': Color(0xFF312E81), // Indigo-800
  };

  /// Gray color variants for UI elements
  static const Map<String, Color> grayVariants = {
    'lightest': Color(0xFFFAFAFA), // Gray-50
    'lighter': Color(0xFFF3F4F6), // Gray-100
    'light': Color(0xFFE5E7EB), // Gray-200
    'base': Color(0xFF6B7280), // Gray-500
    'dark': Color(0xFF374151), // Gray-700
    'darker': Color(0xFF1F2937), // Gray-800
    'darkest': Color(0xFF111827), // Gray-900
  };
}
