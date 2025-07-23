import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Altertale Text Styles
///
/// Comprehensive typography system for the application:
/// - Google Fonts Inter integration
/// - Material 3 typography scale
/// - Semantic text style definitions
/// - Light and dark mode support
/// - Responsive text scaling
/// - Reading-focused typography
class AppTextStyles {
  AppTextStyles._();

  // ==================== FONT CONFIGURATION ====================

  /// Base font family - Inter from Google Fonts
  static const String fontFamily = 'Inter';

  /// Font weights used throughout the app
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // ==================== LIGHT MODE TEXT THEME ====================

  static TextTheme lightTextTheme = TextTheme(
    // Display styles - Large headings
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      fontWeight: extraBold,
      height: 1.12,
      letterSpacing: -0.25,
      color: AppColors.lightColorScheme.onSurface,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      fontWeight: extraBold,
      height: 1.16,
      letterSpacing: 0,
      color: AppColors.lightColorScheme.onSurface,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: bold,
      height: 1.22,
      letterSpacing: 0,
      color: AppColors.lightColorScheme.onSurface,
    ),

    // Headline styles - Section headings
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: bold,
      height: 1.25,
      letterSpacing: 0,
      color: AppColors.lightColorScheme.onSurface,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: bold,
      height: 1.29,
      letterSpacing: 0,
      color: AppColors.lightColorScheme.onSurface,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: semiBold,
      height: 1.33,
      letterSpacing: 0,
      color: AppColors.lightColorScheme.onSurface,
    ),

    // Title styles - Card titles, dialogs
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: semiBold,
      height: 1.27,
      letterSpacing: 0,
      color: AppColors.lightColorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: medium,
      height: 1.50,
      letterSpacing: 0.15,
      color: AppColors.lightColorScheme.onSurface,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: medium,
      height: 1.43,
      letterSpacing: 0.1,
      color: AppColors.lightColorScheme.onSurface,
    ),

    // Label styles - Buttons, tabs
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: medium,
      height: 1.43,
      letterSpacing: 0.1,
      color: AppColors.lightColorScheme.onSurface,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: medium,
      height: 1.33,
      letterSpacing: 0.5,
      color: AppColors.lightColorScheme.onSurface,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: medium,
      height: 1.45,
      letterSpacing: 0.5,
      color: AppColors.lightColorScheme.onSurface,
    ),

    // Body styles - Main content
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: regular,
      height: 1.50,
      letterSpacing: 0.5,
      color: AppColors.lightColorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: regular,
      height: 1.43,
      letterSpacing: 0.25,
      color: AppColors.lightColorScheme.onSurface,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: regular,
      height: 1.33,
      letterSpacing: 0.4,
      color: AppColors.lightColorScheme.onSurfaceVariant,
    ),
  );

  // ==================== DARK MODE TEXT THEME ====================

  static TextTheme darkTextTheme = TextTheme(
    // Display styles
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      fontWeight: extraBold,
      height: 1.12,
      letterSpacing: -0.25,
      color: AppColors.darkColorScheme.onSurface,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      fontWeight: extraBold,
      height: 1.16,
      letterSpacing: 0,
      color: AppColors.darkColorScheme.onSurface,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: bold,
      height: 1.22,
      letterSpacing: 0,
      color: AppColors.darkColorScheme.onSurface,
    ),

    // Headline styles
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: bold,
      height: 1.25,
      letterSpacing: 0,
      color: AppColors.darkColorScheme.onSurface,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: bold,
      height: 1.29,
      letterSpacing: 0,
      color: AppColors.darkColorScheme.onSurface,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: semiBold,
      height: 1.33,
      letterSpacing: 0,
      color: AppColors.darkColorScheme.onSurface,
    ),

    // Title styles
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: semiBold,
      height: 1.27,
      letterSpacing: 0,
      color: AppColors.darkColorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: medium,
      height: 1.50,
      letterSpacing: 0.15,
      color: AppColors.darkColorScheme.onSurface,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: medium,
      height: 1.43,
      letterSpacing: 0.1,
      color: AppColors.darkColorScheme.onSurface,
    ),

    // Label styles
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: medium,
      height: 1.43,
      letterSpacing: 0.1,
      color: AppColors.darkColorScheme.onSurface,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: medium,
      height: 1.33,
      letterSpacing: 0.5,
      color: AppColors.darkColorScheme.onSurface,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: medium,
      height: 1.45,
      letterSpacing: 0.5,
      color: AppColors.darkColorScheme.onSurface,
    ),

    // Body styles
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: regular,
      height: 1.50,
      letterSpacing: 0.5,
      color: AppColors.darkColorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: regular,
      height: 1.43,
      letterSpacing: 0.25,
      color: AppColors.darkColorScheme.onSurface,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: regular,
      height: 1.33,
      letterSpacing: 0.4,
      color: AppColors.darkColorScheme.onSurfaceVariant,
    ),
  );

  // ==================== HELPER METHODS ====================

  /// Get text theme based on brightness
  static TextTheme getTextTheme(Brightness brightness) {
    return brightness == Brightness.light ? lightTextTheme : darkTextTheme;
  }

  /// Apply custom color to existing text style
  static TextStyle applyColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Scale text style for accessibility
  static TextStyle scaleTextStyle(TextStyle style, double scaleFactor) {
    return style.copyWith(fontSize: (style.fontSize ?? 14) * scaleFactor);
  }

  /// Create text style with custom properties
  static TextStyle createCustomStyle({
    required double fontSize,
    FontWeight fontWeight = regular,
    double? height,
    double? letterSpacing,
    Color? color,
    Brightness brightness = Brightness.light,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color:
          color ??
          (brightness == Brightness.light
              ? AppColors.lightColorScheme.onSurface
              : AppColors.darkColorScheme.onSurface),
    );
  }
}

/// Reading content styles - Optimized for long-form reading
class ReadingStyles {
  ReadingStyles._();

  /// Story title style
  static TextStyle storyTitle(Brightness brightness) => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: AppTextStyles.bold,
    height: 1.25,
    letterSpacing: -0.5,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.onSurface
        : AppColors.darkColorScheme.onSurface,
  );

  /// Story content paragraph style
  static TextStyle storyContent(
    Brightness brightness, {
    double fontSize = 16,
  }) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: AppTextStyles.regular,
    height: 1.6,
    letterSpacing: 0.2,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.onSurface
        : AppColors.darkColorScheme.onSurface,
  );

  /// Chapter title style
  static TextStyle chapterTitle(Brightness brightness) => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: AppTextStyles.semiBold,
    height: 1.3,
    letterSpacing: 0,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.onSurface
        : AppColors.darkColorScheme.onSurface,
  );

  /// Author name style
  static TextStyle authorName(Brightness brightness) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: AppTextStyles.medium,
    height: 1.4,
    letterSpacing: 0.25,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.primary
        : AppColors.darkColorScheme.primary,
  );

  /// Reading time indicator
  static TextStyle readingTime(Brightness brightness) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: AppTextStyles.regular,
    height: 1.33,
    letterSpacing: 0.4,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.onSurfaceVariant
        : AppColors.darkColorScheme.onSurfaceVariant,
  );
}

/// Button text styles
class ButtonStyles {
  ButtonStyles._();

  /// Primary button text
  static TextStyle primary(Brightness brightness) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: AppTextStyles.semiBold,
    height: 1.43,
    letterSpacing: 0.1,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.onPrimary
        : AppColors.darkColorScheme.onPrimary,
  );

  /// Secondary button text
  static TextStyle secondary(Brightness brightness) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: AppTextStyles.medium,
    height: 1.43,
    letterSpacing: 0.1,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.primary
        : AppColors.darkColorScheme.primary,
  );

  /// Text button style
  static TextStyle text(Brightness brightness) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: AppTextStyles.medium,
    height: 1.43,
    letterSpacing: 0.1,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.primary
        : AppColors.darkColorScheme.primary,
  );
}

/// Form field styles
class FormStyles {
  FormStyles._();

  /// Input field text
  static TextStyle input(Brightness brightness) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: AppTextStyles.regular,
    height: 1.50,
    letterSpacing: 0.5,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.onSurface
        : AppColors.darkColorScheme.onSurface,
  );

  /// Input label text
  static TextStyle label(Brightness brightness) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: AppTextStyles.medium,
    height: 1.43,
    letterSpacing: 0.25,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.onSurfaceVariant
        : AppColors.darkColorScheme.onSurfaceVariant,
  );

  /// Helper text
  static TextStyle helper(Brightness brightness) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: AppTextStyles.regular,
    height: 1.33,
    letterSpacing: 0.4,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.onSurfaceVariant
        : AppColors.darkColorScheme.onSurfaceVariant,
  );

  /// Error text
  static TextStyle error(Brightness brightness) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: AppTextStyles.regular,
    height: 1.33,
    letterSpacing: 0.4,
    color: brightness == Brightness.light
        ? AppColors.lightColorScheme.error
        : AppColors.darkColorScheme.error,
  );
}
