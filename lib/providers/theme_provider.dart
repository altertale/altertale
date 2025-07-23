import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Production-Ready Theme Provider
///
/// Material Design 3 theme management:
/// - Light/Dark mode switching
/// - System theme following
/// - Theme persistence across app restarts
/// - Custom color schemes
/// - Accessibility support
/// - Performance optimized
class ThemeProvider extends ChangeNotifier {
  // ==================== CONSTANTS ====================
  static const String _themePreferenceKey = 'theme_mode_preference';
  static const String _colorSchemeKey = 'color_scheme_preference';
  static const String _fontScaleKey = 'font_scale_preference';

  // ==================== PRIVATE STATE ====================
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedColorScheme = 'purple'; // Default color scheme
  double _fontScale = 1.0;
  bool _isInitialized = false;
  bool _disposed = false;

  // ==================== PUBLIC GETTERS ====================

  /// Current theme mode (light, dark, system)
  ThemeMode get themeMode => _themeMode;

  /// Current color scheme name
  String get selectedColorScheme => _selectedColorScheme;

  /// Current font scale factor
  double get fontScale => _fontScale;

  /// Whether provider is fully initialized
  bool get isInitialized => _isInitialized;

  /// Whether current mode is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Whether following system theme
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Whether current mode is light
  bool get isLightMode => _themeMode == ThemeMode.light;

  // ==================== CONSTRUCTOR ====================

  /// Initialize ThemeProvider with automatic theme loading
  ThemeProvider() {
    _initializeTheme();
  }

  // ==================== INITIALIZATION ====================

  /// Initialize theme from saved preferences
  Future<void> _initializeTheme() async {
    if (_disposed) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final savedThemeMode = prefs.getString(_themePreferenceKey);
      if (savedThemeMode != null) {
        _themeMode = _parseThemeMode(savedThemeMode);
      }

      // Load color scheme
      final savedColorScheme = prefs.getString(_colorSchemeKey);
      if (savedColorScheme != null) {
        _selectedColorScheme = savedColorScheme;
      }

      // Load font scale
      final savedFontScale = prefs.getDouble(_fontScaleKey);
      if (savedFontScale != null) {
        _fontScale = savedFontScale.clamp(0.8, 1.5); // Reasonable bounds
      }

      _isInitialized = true;

      if (kDebugMode) {
        print(
          '✅ ThemeProvider initialized: mode=$_themeMode, color=$_selectedColorScheme, scale=$_fontScale',
        );
      }

      _safeNotifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ThemeProvider initialization failed: $e');
      }

      // Fall back to defaults
      _isInitialized = true;
      _safeNotifyListeners();
    }
  }

  // ==================== THEME MODE MANAGEMENT ====================

  /// Switch to light theme
  Future<void> setLightTheme() async {
    await _setThemeMode(ThemeMode.light);
  }

  /// Switch to dark theme
  Future<void> setDarkTheme() async {
    await _setThemeMode(ThemeMode.dark);
  }

  /// Follow system theme
  Future<void> setSystemTheme() async {
    await _setThemeMode(ThemeMode.system);
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setDarkTheme();
        break;
      case ThemeMode.dark:
        await setLightTheme();
        break;
      case ThemeMode.system:
        // Get current brightness and switch to opposite
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        if (brightness == Brightness.light) {
          await setDarkTheme();
        } else {
          await setLightTheme();
        }
        break;
    }
  }

  /// Set specific theme mode
  Future<void> _setThemeMode(ThemeMode mode) async {
    if (_disposed || _themeMode == mode) return;

    _themeMode = mode;
    await _saveThemeMode();
    _safeNotifyListeners();

    if (kDebugMode) {
      print('🎨 Theme mode changed to: $mode');
    }
  }

  // ==================== COLOR SCHEME MANAGEMENT ====================

  /// Available color schemes
  List<String> get availableColorSchemes => [
    'purple', // Default Altertale purple
    'blue', // Material blue
    'green', // Nature green
    'orange', // Energetic orange
    'pink', // Playful pink
    'teal', // Calm teal
    'indigo', // Professional indigo
    'red', // Attention red
  ];

  /// Set color scheme
  Future<void> setColorScheme(String colorScheme) async {
    if (_disposed ||
        _selectedColorScheme == colorScheme ||
        !availableColorSchemes.contains(colorScheme)) {
      return;
    }

    _selectedColorScheme = colorScheme;
    await _saveColorScheme();
    _safeNotifyListeners();

    if (kDebugMode) {
      print('🎨 Color scheme changed to: $colorScheme');
    }
  }

  /// Get color scheme seed color
  Color getColorSchemeSeed(String scheme) {
    switch (scheme) {
      case 'purple':
        return const Color(0xFF6750A4);
      case 'blue':
        return const Color(0xFF1976D2);
      case 'green':
        return const Color(0xFF388E3C);
      case 'orange':
        return const Color(0xFFFF9800);
      case 'pink':
        return const Color(0xFFE91E63);
      case 'teal':
        return const Color(0xFF00695C);
      case 'indigo':
        return const Color(0xFF3F51B5);
      case 'red':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF6750A4); // Default purple
    }
  }

  /// Get current theme seed color
  Color get currentSeedColor => getColorSchemeSeed(_selectedColorScheme);

  // ==================== FONT SCALE MANAGEMENT ====================

  /// Set font scale factor
  Future<void> setFontScale(double scale) async {
    if (_disposed) return;

    // Clamp to reasonable bounds
    final clampedScale = scale.clamp(0.8, 1.5);

    if (_fontScale == clampedScale) return;

    _fontScale = clampedScale;
    await _saveFontScale();
    _safeNotifyListeners();

    if (kDebugMode) {
      print('📝 Font scale changed to: $clampedScale');
    }
  }

  /// Reset font scale to default
  Future<void> resetFontScale() async {
    await setFontScale(1.0);
  }

  /// Increase font scale
  Future<void> increaseFontScale() async {
    await setFontScale(_fontScale + 0.1);
  }

  /// Decrease font scale
  Future<void> decreaseFontScale() async {
    await setFontScale(_fontScale - 0.1);
  }

  // ==================== THEME GENERATION ====================

  /// Generate light theme
  ThemeData get lightTheme {
    return _generateTheme(Brightness.light);
  }

  /// Generate dark theme
  ThemeData get darkTheme {
    return _generateTheme(Brightness.dark);
  }

  /// Generate theme for specific brightness
  ThemeData _generateTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: currentSeedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',

      // Apply font scale to text theme
      textTheme: _getScaledTextTheme(brightness),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20 * _fontScale,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: 'Inter',
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, 48 * _fontScale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16 * _fontScale,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16 * _fontScale,
        ),
        labelStyle: TextStyle(fontSize: 16 * _fontScale, fontFamily: 'Inter'),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.all(8),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withAlpha(77), // 0.3 opacity
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Get scaled text theme
  TextTheme _getScaledTextTheme(Brightness brightness) {
    final baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: (baseTextTheme.displayLarge?.fontSize ?? 57) * _fontScale,
        fontFamily: 'Inter',
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: (baseTextTheme.displayMedium?.fontSize ?? 45) * _fontScale,
        fontFamily: 'Inter',
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: (baseTextTheme.displaySmall?.fontSize ?? 36) * _fontScale,
        fontFamily: 'Inter',
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 32) * _fontScale,
        fontFamily: 'Inter',
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 28) * _fontScale,
        fontFamily: 'Inter',
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 24) * _fontScale,
        fontFamily: 'Inter',
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22) * _fontScale,
        fontFamily: 'Inter',
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16) * _fontScale,
        fontFamily: 'Inter',
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14) * _fontScale,
        fontFamily: 'Inter',
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * _fontScale,
        fontFamily: 'Inter',
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * _fontScale,
        fontFamily: 'Inter',
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * _fontScale,
        fontFamily: 'Inter',
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * _fontScale,
        fontFamily: 'Inter',
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12) * _fontScale,
        fontFamily: 'Inter',
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: (baseTextTheme.labelSmall?.fontSize ?? 11) * _fontScale,
        fontFamily: 'Inter',
      ),
    );
  }

  // ==================== PERSISTENCE METHODS ====================

  /// Save theme mode to preferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, _themeMode.toString());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save theme mode: $e');
      }
    }
  }

  /// Save color scheme to preferences
  Future<void> _saveColorScheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_colorSchemeKey, _selectedColorScheme);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save color scheme: $e');
      }
    }
  }

  /// Save font scale to preferences
  Future<void> _saveFontScale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontScaleKey, _fontScale);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save font scale: $e');
      }
    }
  }

  // ==================== HELPER METHODS ====================

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  /// Get theme mode display name
  String getThemeModeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Açık Tema';
      case ThemeMode.dark:
        return 'Koyu Tema';
      case ThemeMode.system:
        return 'Sistem Teması';
    }
  }

  /// Get current theme mode display name
  String get currentThemeModeDisplayName => getThemeModeDisplayName(_themeMode);

  /// Get color scheme display name
  String getColorSchemeDisplayName(String scheme) {
    switch (scheme) {
      case 'purple':
        return 'Mor';
      case 'blue':
        return 'Mavi';
      case 'green':
        return 'Yeşil';
      case 'orange':
        return 'Turuncu';
      case 'pink':
        return 'Pembe';
      case 'teal':
        return 'Deniz Mavisi';
      case 'indigo':
        return 'Çivit Mavisi';
      case 'red':
        return 'Kırmızı';
      default:
        return scheme;
    }
  }

  /// Get current color scheme display name
  String get currentColorSchemeDisplayName =>
      getColorSchemeDisplayName(_selectedColorScheme);

  /// Safely notify listeners (check if disposed)
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // ==================== DISPOSE ====================

  @override
  void dispose() {
    _disposed = true;

    if (kDebugMode) {
      print('🗑️ ThemeProvider disposed');
    }

    super.dispose();
  }
}
