import 'package:flutter/material.dart';
import '../models/preferences/user_preferences_model.dart';
import '../services/preferences/preferences_service.dart';

/// Tema kontrolcüsü
class ThemeController extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  
  UserPreferences _preferences = UserPreferences.defaultPreferences();
  bool _isLoading = true;

  /// Mevcut tercihler
  UserPreferences get preferences => _preferences;

  /// Yükleme durumu
  bool get isLoading => _isLoading;

  /// Etkili tema modu
  AppThemeMode get effectiveAppThemeMode => _preferences.effectiveAppThemeMode;

  /// Tema kontrolcüsünü başlat
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      _preferences = await _preferencesService.loadPreferences();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tema modunu güncelle
  Future<void> updateAppThemeMode(AppThemeMode themeMode) async {
    try {
      await _preferencesService.updateAppThemeMode(themeMode);
      
      _preferences = _preferences.copyWith(themeMode: themeMode);
      notifyListeners();
    } catch (e) {
      throw Exception('Tema modu güncellenirken hata oluştu: $e');
    }
  }

  /// Yazı tipi boyutunu güncelle
  Future<void> updateFontSize(FontSize fontSize) async {
    try {
      await _preferencesService.updateFontSize(fontSize);
      
      _preferences = _preferences.copyWith(fontSize: fontSize);
      notifyListeners();
    } catch (e) {
      throw Exception('Yazı tipi boyutu güncellenirken hata oluştu: $e');
    }
  }

  /// Satır aralığını güncelle
  Future<void> updateLineSpacing(LineSpacing lineSpacing) async {
    try {
      await _preferencesService.updateLineSpacing(lineSpacing);
      
      _preferences = _preferences.copyWith(lineSpacing: lineSpacing);
      notifyListeners();
    } catch (e) {
      throw Exception('Satır aralığı güncellenirken hata oluştu: $e');
    }
  }

  /// Okuma arka plan rengini güncelle
  Future<void> updateReadingBackground(ReadingBackground background) async {
    try {
      await _preferencesService.updateReadingBackground(background);
      
      _preferences = _preferences.copyWith(readingBackground: background);
      notifyListeners();
    } catch (e) {
      throw Exception('Okuma arka plan rengi güncellenirken hata oluştu: $e');
    }
  }

  /// Bildirim ayarını güncelle
  Future<void> updateNotificationsEnabled(bool enabled) async {
    try {
      await _preferencesService.updateNotificationsEnabled(enabled);
      
      _preferences = _preferences.copyWith(notificationsEnabled: enabled);
      notifyListeners();
    } catch (e) {
      throw Exception('Bildirim ayarı güncellenirken hata oluştu: $e');
    }
  }

  /// Otomatik senkronizasyon ayarını güncelle
  Future<void> updateAutoSyncEnabled(bool enabled) async {
    try {
      await _preferencesService.updateAutoSyncEnabled(enabled);
      
      _preferences = _preferences.copyWith(autoSyncEnabled: enabled);
      notifyListeners();
    } catch (e) {
      throw Exception('Otomatik senkronizasyon ayarı güncellenirken hata oluştu: $e');
    }
  }

  /// Tercihleri sıfırla
  Future<void> resetPreferences() async {
    try {
      await _preferencesService.resetPreferences();
      
      _preferences = UserPreferences.defaultPreferences();
      notifyListeners();
    } catch (e) {
      throw Exception('Tercihler sıfırlanırken hata oluştu: $e');
    }
  }

  /// Tercihleri yenile
  Future<void> refreshPreferences() async {
    await initialize();
  }

  /// Tema verilerini oluştur
  ThemeData createThemeData() {
    final isDark = effectiveAppThemeMode == AppThemeMode.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: isDark ? _createDarkColorScheme() : _createLightColorScheme(),
      fontFamily: 'Roboto',
      textTheme: _createTextTheme(),
    );
  }

  /// Açık tema renk paleti
  ColorScheme _createLightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );
  }

  /// Koyu tema renk paleti
  ColorScheme _createDarkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    );
  }

  /// Yazı tipi teması
  TextTheme _createTextTheme() {
    final baseSize = _preferences.fontSizeValue;
    
    return TextTheme(
      displayLarge: TextStyle(fontSize: baseSize * 3.5),
      displayMedium: TextStyle(fontSize: baseSize * 3.0),
      displaySmall: TextStyle(fontSize: baseSize * 2.5),
      headlineLarge: TextStyle(fontSize: baseSize * 2.0),
      headlineMedium: TextStyle(fontSize: baseSize * 1.75),
      headlineSmall: TextStyle(fontSize: baseSize * 1.5),
      titleLarge: TextStyle(fontSize: baseSize * 1.25),
      titleMedium: TextStyle(fontSize: baseSize * 1.125),
      titleSmall: TextStyle(fontSize: baseSize),
      bodyLarge: TextStyle(fontSize: baseSize),
      bodyMedium: TextStyle(fontSize: baseSize * 0.875),
      bodySmall: TextStyle(fontSize: baseSize * 0.75),
      labelLarge: TextStyle(fontSize: baseSize * 0.875),
      labelMedium: TextStyle(fontSize: baseSize * 0.75),
      labelSmall: TextStyle(fontSize: baseSize * 0.625),
    );
  }

  /// Okuma teması oluştur
  ThemeData createReadingTheme() {
    final baseTheme = createThemeData();
    
    return baseTheme.copyWith(
      scaffoldBackgroundColor: _preferences.readingBackgroundColor,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: _preferences.readingBackgroundColor == Colors.black 
            ? Colors.white 
            : Colors.black,
      ),
    );
  }

  /// Satır aralığı stilini oluştur
  TextStyle createReadingTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      height: _preferences.lineSpacingValue,
      fontSize: _preferences.fontSizeValue,
    );
  }
}
