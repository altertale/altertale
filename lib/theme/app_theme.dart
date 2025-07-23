import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'text_styles.dart';

/// Altertale App Theme
///
/// Comprehensive theme system for the application:
/// - Material 3 design system
/// - Light and dark theme configurations
/// - Custom component themes
/// - Reading-focused UI elements
/// - Accessibility compliance
/// - Platform-specific adjustments
class AppTheme {
  AppTheme._();

  // ==================== MAIN THEME DATA ====================

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      // Material 3 activation
      useMaterial3: true,

      // Color scheme
      colorScheme: AppColors.lightColorScheme,

      // Typography
      textTheme: AppTextStyles.lightTextTheme,

      // Font family
      fontFamily: AppTextStyles.fontFamily,

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // App bar theme
      appBarTheme: _lightAppBarTheme,

      // Bottom navigation theme
      bottomNavigationBarTheme: _lightBottomNavigationTheme,

      // Elevated button theme
      elevatedButtonTheme: _lightElevatedButtonTheme,

      // Outlined button theme
      outlinedButtonTheme: _lightOutlinedButtonTheme,

      // Text button theme
      textButtonTheme: _lightTextButtonTheme,

      // Input decoration theme
      inputDecorationTheme: _lightInputDecorationTheme,

      // Card theme
      cardTheme: _lightCardTheme,

      // Dialog theme
      dialogTheme: _lightDialogTheme,

      // Bottom sheet theme
      bottomSheetTheme: _lightBottomSheetTheme,

      // Snack bar theme
      snackBarTheme: _lightSnackBarTheme,

      // Floating action button theme
      floatingActionButtonTheme: _lightFabTheme,

      // Switch theme
      switchTheme: _lightSwitchTheme,

      // Checkbox theme
      checkboxTheme: _lightCheckboxTheme,

      // Radio theme
      radioTheme: _lightRadioTheme,

      // Slider theme
      sliderTheme: _lightSliderTheme,

      // Progress indicator theme
      progressIndicatorTheme: _lightProgressIndicatorTheme,

      // Tab bar theme
      tabBarTheme: const TabBarThemeData(),

      // Chip theme
      chipTheme: _lightChipTheme,

      // Divider theme
      dividerTheme: _lightDividerTheme,

      // Icon theme
      iconTheme: _lightIconTheme,
      primaryIconTheme: _lightPrimaryIconTheme,

      // List tile theme
      listTileTheme: _lightListTileTheme,

      // Drawer theme
      drawerTheme: _lightDrawerTheme,

      // Tooltip theme
      tooltipTheme: _lightTooltipTheme,

      // Page transitions
      pageTransitionsTheme: _pageTransitionsTheme,

      // Platform brightness
      brightness: Brightness.light,

      // Splash color
      splashColor: AppColors.lightColorScheme.primary.withOpacity(0.1),
      highlightColor: AppColors.lightColorScheme.primary.withOpacity(0.05),

      // Focus color
      focusColor: AppColors.lightColorScheme.primary.withOpacity(0.12),
      hoverColor: AppColors.lightColorScheme.primary.withOpacity(0.04),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      // Material 3 activation
      useMaterial3: true,

      // Color scheme
      colorScheme: AppColors.darkColorScheme,

      // Typography
      textTheme: AppTextStyles.darkTextTheme,

      // Font family
      fontFamily: AppTextStyles.fontFamily,

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // App bar theme
      appBarTheme: _darkAppBarTheme,

      // Bottom navigation theme
      bottomNavigationBarTheme: _darkBottomNavigationTheme,

      // Elevated button theme
      elevatedButtonTheme: _darkElevatedButtonTheme,

      // Outlined button theme
      outlinedButtonTheme: _darkOutlinedButtonTheme,

      // Text button theme
      textButtonTheme: _darkTextButtonTheme,

      // Input decoration theme
      inputDecorationTheme: _darkInputDecorationTheme,

      // Card theme
      cardTheme: _darkCardTheme,

      // Dialog theme
      dialogTheme: _darkDialogTheme,

      // Bottom sheet theme
      bottomSheetTheme: _darkBottomSheetTheme,

      // Snack bar theme
      snackBarTheme: _darkSnackBarTheme,

      // Floating action button theme
      floatingActionButtonTheme: _darkFabTheme,

      // Switch theme
      switchTheme: _darkSwitchTheme,

      // Checkbox theme
      checkboxTheme: _darkCheckboxTheme,

      // Radio theme
      radioTheme: _darkRadioTheme,

      // Slider theme
      sliderTheme: _darkSliderTheme,

      // Progress indicator theme
      progressIndicatorTheme: _darkProgressIndicatorTheme,

      // Tab bar theme
      tabBarTheme: const TabBarThemeData(),

      // Chip theme
      chipTheme: _darkChipTheme,

      // Divider theme
      dividerTheme: _darkDividerTheme,

      // Icon theme
      iconTheme: _darkIconTheme,
      primaryIconTheme: _darkPrimaryIconTheme,

      // List tile theme
      listTileTheme: _darkListTileTheme,

      // Drawer theme
      drawerTheme: _darkDrawerTheme,

      // Tooltip theme
      tooltipTheme: _darkTooltipTheme,

      // Page transitions
      pageTransitionsTheme: _pageTransitionsTheme,

      // Platform brightness
      brightness: Brightness.dark,

      // Splash color
      splashColor: AppColors.darkColorScheme.primary.withOpacity(0.1),
      highlightColor: AppColors.darkColorScheme.primary.withOpacity(0.05),

      // Focus color
      focusColor: AppColors.darkColorScheme.primary.withOpacity(0.12),
      hoverColor: AppColors.darkColorScheme.primary.withOpacity(0.04),
    );
  }

  // ==================== LIGHT THEME COMPONENTS ====================

  static AppBarTheme get _lightAppBarTheme => AppBarTheme(
    backgroundColor: AppColors.lightColorScheme.surface,
    foregroundColor: AppColors.lightColorScheme.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: AppColors.lightColorScheme.shadow.withOpacity(0.1),
    surfaceTintColor: AppColors.lightColorScheme.surfaceTint,
    titleTextStyle: AppTextStyles.lightTextTheme.titleLarge,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    iconTheme: IconThemeData(
      color: AppColors.lightColorScheme.onSurface,
      size: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColors.lightColorScheme.onSurface,
      size: 24,
    ),
  );

  static BottomNavigationBarThemeData get _lightBottomNavigationTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightColorScheme.surface,
        selectedItemColor: AppColors.lightColorScheme.primary,
        unselectedItemColor: AppColors.lightColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 3,
        selectedLabelStyle: AppTextStyles.lightTextTheme.labelSmall?.copyWith(
          fontWeight: AppTextStyles.semiBold,
        ),
        unselectedLabelStyle: AppTextStyles.lightTextTheme.labelSmall,
      );

  static ElevatedButtonThemeData get _lightElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightColorScheme.primary,
          foregroundColor: AppColors.lightColorScheme.onPrimary,
          disabledBackgroundColor: AppColors.lightColorScheme.onSurface
              .withOpacity(0.12),
          disabledForegroundColor: AppColors.lightColorScheme.onSurface
              .withOpacity(0.38),
          elevation: 2,
          shadowColor: AppColors.lightColorScheme.shadow.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: ButtonStyles.primary(Brightness.light),
          minimumSize: const Size(64, 48),
        ),
      );

  static OutlinedButtonThemeData get _lightOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightColorScheme.primary,
          disabledForegroundColor: AppColors.lightColorScheme.onSurface
              .withOpacity(0.38),
          side: BorderSide(color: AppColors.lightColorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: ButtonStyles.secondary(Brightness.light),
          minimumSize: const Size(64, 48),
        ),
      );

  static TextButtonThemeData get _lightTextButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.lightColorScheme.primary,
      disabledForegroundColor: AppColors.lightColorScheme.onSurface.withOpacity(
        0.38,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: ButtonStyles.text(Brightness.light),
      minimumSize: const Size(48, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static InputDecorationTheme get _lightInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightColorScheme.surface.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightColorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.error,
            width: 2,
          ),
        ),
        labelStyle: FormStyles.label(Brightness.light),
        hintStyle: FormStyles.helper(Brightness.light),
        helperStyle: FormStyles.helper(Brightness.light),
        errorStyle: FormStyles.error(Brightness.light),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      );

  static CardThemeData get _lightCardTheme => CardThemeData(
    color: AppColors.lightColorScheme.surface,
    shadowColor: AppColors.lightColorScheme.shadow.withOpacity(0.1),
    surfaceTintColor: AppColors.lightColorScheme.surfaceTint,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  );

  // ==================== DARK THEME COMPONENTS ====================

  static AppBarTheme get _darkAppBarTheme => AppBarTheme(
    backgroundColor: AppColors.darkColorScheme.surface,
    foregroundColor: AppColors.darkColorScheme.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: AppColors.darkColorScheme.shadow.withOpacity(0.2),
    surfaceTintColor: AppColors.darkColorScheme.surfaceTint,
    titleTextStyle: AppTextStyles.darkTextTheme.titleLarge,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    iconTheme: IconThemeData(
      color: AppColors.darkColorScheme.onSurface,
      size: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColors.darkColorScheme.onSurface,
      size: 24,
    ),
  );

  static BottomNavigationBarThemeData get _darkBottomNavigationTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkColorScheme.surface,
        selectedItemColor: AppColors.darkColorScheme.primary,
        unselectedItemColor: AppColors.darkColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 3,
        selectedLabelStyle: AppTextStyles.darkTextTheme.labelSmall?.copyWith(
          fontWeight: AppTextStyles.semiBold,
        ),
        unselectedLabelStyle: AppTextStyles.darkTextTheme.labelSmall,
      );

  static ElevatedButtonThemeData get _darkElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkColorScheme.primary,
          foregroundColor: AppColors.darkColorScheme.onPrimary,
          disabledBackgroundColor: AppColors.darkColorScheme.onSurface
              .withOpacity(0.12),
          disabledForegroundColor: AppColors.darkColorScheme.onSurface
              .withOpacity(0.38),
          elevation: 2,
          shadowColor: AppColors.darkColorScheme.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: ButtonStyles.primary(Brightness.dark),
          minimumSize: const Size(64, 48),
        ),
      );

  static OutlinedButtonThemeData get _darkOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkColorScheme.primary,
          disabledForegroundColor: AppColors.darkColorScheme.onSurface
              .withOpacity(0.38),
          side: BorderSide(color: AppColors.darkColorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: ButtonStyles.secondary(Brightness.dark),
          minimumSize: const Size(64, 48),
        ),
      );

  static TextButtonThemeData get _darkTextButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.darkColorScheme.primary,
      disabledForegroundColor: AppColors.darkColorScheme.onSurface.withOpacity(
        0.38,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: ButtonStyles.text(Brightness.dark),
      minimumSize: const Size(48, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static InputDecorationTheme get _darkInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkColorScheme.surface.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkColorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkColorScheme.error,
            width: 2,
          ),
        ),
        labelStyle: FormStyles.label(Brightness.dark),
        hintStyle: FormStyles.helper(Brightness.dark),
        helperStyle: FormStyles.helper(Brightness.dark),
        errorStyle: FormStyles.error(Brightness.dark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      );

  static CardThemeData get _darkCardTheme => CardThemeData(
    color: AppColors.darkColorScheme.surface,
    shadowColor: AppColors.darkColorScheme.shadow.withOpacity(0.2),
    surfaceTintColor: AppColors.darkColorScheme.surfaceTint,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  );

  // ==================== SHARED THEME COMPONENTS ====================

  // Dialog theme - same for both modes with color adjustments
  static DialogThemeData get _lightDialogTheme => DialogThemeData(
    backgroundColor: AppColors.lightColorScheme.surface,
    surfaceTintColor: AppColors.lightColorScheme.surfaceTint,
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: AppTextStyles.lightTextTheme.headlineSmall,
    contentTextStyle: AppTextStyles.lightTextTheme.bodyMedium,
  );

  static DialogThemeData get _darkDialogTheme => DialogThemeData(
    backgroundColor: AppColors.darkColorScheme.surface,
    surfaceTintColor: AppColors.darkColorScheme.surfaceTint,
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: AppTextStyles.darkTextTheme.headlineSmall,
    contentTextStyle: AppTextStyles.darkTextTheme.bodyMedium,
  );

  // ==================== ADDITIONAL COMPONENT THEMES ====================

  // Add remaining theme components (FloatingActionButton, Switch, etc.)
  static FloatingActionButtonThemeData get _lightFabTheme =>
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightColorScheme.primaryContainer,
        foregroundColor: AppColors.lightColorScheme.onPrimaryContainer,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  static FloatingActionButtonThemeData get _darkFabTheme =>
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkColorScheme.primaryContainer,
        foregroundColor: AppColors.darkColorScheme.onPrimaryContainer,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  // Page transitions theme
  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      );

  // ==================== PLACEHOLDER THEMES ====================
  // (Simplified for brevity - add full implementations as needed)

  static BottomSheetThemeData get _lightBottomSheetTheme =>
      const BottomSheetThemeData();
  static BottomSheetThemeData get _darkBottomSheetTheme =>
      const BottomSheetThemeData();

  static SnackBarThemeData get _lightSnackBarTheme => const SnackBarThemeData();
  static SnackBarThemeData get _darkSnackBarTheme => const SnackBarThemeData();

  static SwitchThemeData get _lightSwitchTheme => const SwitchThemeData();
  static SwitchThemeData get _darkSwitchTheme => const SwitchThemeData();

  static CheckboxThemeData get _lightCheckboxTheme => const CheckboxThemeData();
  static CheckboxThemeData get _darkCheckboxTheme => const CheckboxThemeData();

  static RadioThemeData get _lightRadioTheme => const RadioThemeData();
  static RadioThemeData get _darkRadioTheme => const RadioThemeData();

  static SliderThemeData get _lightSliderTheme => const SliderThemeData();
  static SliderThemeData get _darkSliderTheme => const SliderThemeData();

  static ProgressIndicatorThemeData get _lightProgressIndicatorTheme =>
      const ProgressIndicatorThemeData();
  static ProgressIndicatorThemeData get _darkProgressIndicatorTheme =>
      const ProgressIndicatorThemeData();

  static TabBarTheme get _lightTabBarTheme => const TabBarTheme();
  static TabBarTheme get _darkTabBarTheme => const TabBarTheme();

  static ChipThemeData get _lightChipTheme => const ChipThemeData();
  static ChipThemeData get _darkChipTheme => const ChipThemeData();

  static DividerThemeData get _lightDividerTheme => const DividerThemeData();
  static DividerThemeData get _darkDividerTheme => const DividerThemeData();

  static IconThemeData get _lightIconTheme => const IconThemeData();
  static IconThemeData get _lightPrimaryIconTheme => const IconThemeData();
  static IconThemeData get _darkIconTheme => const IconThemeData();
  static IconThemeData get _darkPrimaryIconTheme => const IconThemeData();

  static ListTileThemeData get _lightListTileTheme => const ListTileThemeData();
  static ListTileThemeData get _darkListTileTheme => const ListTileThemeData();

  static DrawerThemeData get _lightDrawerTheme => const DrawerThemeData();
  static DrawerThemeData get _darkDrawerTheme => const DrawerThemeData();

  static TooltipThemeData get _lightTooltipTheme => const TooltipThemeData();
  static TooltipThemeData get _darkTooltipTheme => const TooltipThemeData();
}
