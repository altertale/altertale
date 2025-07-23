import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reading_settings_model.dart';
import '../services/auth_service.dart';

class ReadingSettingsProvider with ChangeNotifier {
  static const String _settingsKey = 'reading_settings';

  ReadingSettingsModel _settings = ReadingSettingsModel.defaultLight();
  bool _isLoading = false;
  String? _error;

  // Getters
  ReadingSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Quick access getters
  double get fontSize => _settings.fontSize;
  double get lineHeight => _settings.lineHeight;
  String get fontFamily => _settings.fontFamily;
  Color get backgroundColor => _settings.backgroundColor;
  Color get textColor => _settings.textColor;
  bool get isDarkMode => _settings.isDarkMode;
  bool get isSepia => _settings.isSepia;
  double get brightness => _settings.brightness;
  TextAlign get textAlign => _settings.textAlign;
  bool get autoScroll => _settings.autoScroll;
  double get autoScrollSpeed => _settings.autoScrollSpeed;
  String get readingMode => _settings.readingMode;
  TextStyle get textStyle => _settings.textStyle;

  /// Initialize reading settings
  Future<void> init() async {
    await loadSettings();
  }

  /// Load settings from storage
  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_getSettingsKey());

      if (settingsJson != null) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        _settings = ReadingSettingsModel.fromJson(json);
        print(
          '📖 Loaded reading settings: ${_settings.fontFamily}, ${_settings.fontSize}pt',
        );
      } else {
        _settings = ReadingSettingsModel.defaultLight();
        print('📖 Using default reading settings');
      }
    } catch (e) {
      _error = 'Okuma ayarları yüklenemedi: $e';
      print('❌ Error loading reading settings: $e');
      _settings = ReadingSettingsModel.defaultLight();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save settings to storage
  Future<bool> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.toJson());

      final success = await prefs.setString(_getSettingsKey(), settingsJson);

      if (success) {
        print('💾 Reading settings saved successfully');
      }

      return success;
    } catch (e) {
      _error = 'Okuma ayarları kaydedilemedi: $e';
      print('❌ Error saving reading settings: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update font size
  Future<void> updateFontSize(double fontSize) async {
    _settings = _settings.copyWith(fontSize: fontSize);
    notifyListeners();
    await saveSettings();
  }

  /// Update line height
  Future<void> updateLineHeight(double lineHeight) async {
    _settings = _settings.copyWith(lineHeight: lineHeight);
    notifyListeners();
    await saveSettings();
  }

  /// Update font family
  Future<void> updateFontFamily(String fontFamily) async {
    _settings = _settings.copyWith(fontFamily: fontFamily);
    notifyListeners();
    await saveSettings();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    if (_settings.isDarkMode) {
      await applyTheme(ReadingSettingsModel.defaultLight());
    } else {
      await applyTheme(ReadingSettingsModel.defaultDark());
    }
  }

  /// Toggle sepia mode
  Future<void> toggleSepia() async {
    if (_settings.isSepia) {
      await applyTheme(ReadingSettingsModel.defaultLight());
    } else {
      await applyTheme(ReadingSettingsModel.sepia());
    }
  }

  /// Update background color
  Future<void> updateBackgroundColor(Color color) async {
    _settings = _settings.copyWith(backgroundColor: color);
    notifyListeners();
    await saveSettings();
  }

  /// Update text color
  Future<void> updateTextColor(Color color) async {
    _settings = _settings.copyWith(textColor: color);
    notifyListeners();
    await saveSettings();
  }

  /// Update brightness
  Future<void> updateBrightness(double brightness) async {
    _settings = _settings.copyWith(brightness: brightness);
    notifyListeners();
    await saveSettings();
  }

  /// Update text alignment
  Future<void> updateTextAlign(TextAlign textAlign) async {
    _settings = _settings.copyWith(textAlign: textAlign);
    notifyListeners();
    await saveSettings();
  }

  /// Update letter spacing
  Future<void> updateLetterSpacing(double letterSpacing) async {
    _settings = _settings.copyWith(letterSpacing: letterSpacing);
    notifyListeners();
    await saveSettings();
  }

  /// Update page width
  Future<void> updatePageWidth(double pageWidth) async {
    _settings = _settings.copyWith(pageWidth: pageWidth);
    notifyListeners();
    await saveSettings();
  }

  /// Toggle auto scroll
  Future<void> toggleAutoScroll() async {
    _settings = _settings.copyWith(autoScroll: !_settings.autoScroll);
    notifyListeners();
    await saveSettings();
  }

  /// Update auto scroll speed
  Future<void> updateAutoScrollSpeed(double speed) async {
    _settings = _settings.copyWith(autoScrollSpeed: speed);
    notifyListeners();
    await saveSettings();
  }

  /// Update reading mode
  Future<void> updateReadingMode(String mode) async {
    _settings = _settings.copyWith(readingMode: mode);
    notifyListeners();
    await saveSettings();
  }

  /// Apply preset theme
  Future<void> applyTheme(ReadingSettingsModel theme) async {
    _settings = theme.copyWith(
      // Preserve user customizations
      fontSize: _settings.fontSize,
      fontFamily: _settings.fontFamily,
      pageWidth: _settings.pageWidth,
      autoScroll: _settings.autoScroll,
      autoScrollSpeed: _settings.autoScrollSpeed,
      readingMode: _settings.readingMode,
    );
    notifyListeners();
    await saveSettings();
  }

  /// Apply full settings
  Future<void> applySettings(ReadingSettingsModel newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await saveSettings();
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    _settings = ReadingSettingsModel.defaultLight();
    notifyListeners();
    await saveSettings();
  }

  /// Increase font size
  Future<void> increaseFontSize() async {
    final newSize = (_settings.fontSize + 2).clamp(12.0, 32.0);
    await updateFontSize(newSize);
  }

  /// Decrease font size
  Future<void> decreaseFontSize() async {
    final newSize = (_settings.fontSize - 2).clamp(12.0, 32.0);
    await updateFontSize(newSize);
  }

  /// Increase line height
  Future<void> increaseLineHeight() async {
    final newHeight = (_settings.lineHeight + 0.1).clamp(1.0, 3.0);
    await updateLineHeight(newHeight);
  }

  /// Decrease line height
  Future<void> decreaseLineHeight() async {
    final newHeight = (_settings.lineHeight - 0.1).clamp(1.0, 3.0);
    await updateLineHeight(newHeight);
  }

  /// Get accessibility info
  Map<String, dynamic> getAccessibilityInfo() {
    return {
      'contrast_ratio': _settings.contrastRatio,
      'is_accessible': _settings.isAccessible,
      'font_size': _settings.fontSize,
      'line_height': _settings.lineHeight,
      'recommendations': _getAccessibilityRecommendations(),
    };
  }

  /// Get accessibility recommendations
  List<String> _getAccessibilityRecommendations() {
    final recommendations = <String>[];

    if (!_settings.isAccessible) {
      recommendations.add(
        'Metin ve arka plan renkleri arasındaki kontrast artırılmalı',
      );
    }

    if (_settings.fontSize < 14) {
      recommendations.add(
        'Daha büyük font boyutu kullanılması öneriliyor (min. 14pt)',
      );
    }

    if (_settings.lineHeight < 1.4) {
      recommendations.add('Satır aralığı artırılması öneriliyor (min. 1.4)');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Ayarlarınız erişilebilirlik standartlarına uygun!');
    }

    return recommendations;
  }

  /// Export settings as JSON string
  Future<String> exportSettings() async {
    try {
      return jsonEncode(_settings.toJson());
    } catch (e) {
      throw 'Ayarlar dışa aktarılamadı: $e';
    }
  }

  /// Import settings from JSON string
  Future<bool> importSettings(String jsonString) async {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final newSettings = ReadingSettingsModel.fromJson(json);

      await applySettings(newSettings);
      return true;
    } catch (e) {
      _error = 'Ayarlar içe aktarılamadı: $e';
      print('❌ Error importing settings: $e');
      notifyListeners();
      return false;
    }
  }

  /// Get user-specific settings key
  String _getSettingsKey() {
    final userId = AuthService().currentUser?.uid;
    return userId != null ? '${_settingsKey}_$userId' : _settingsKey;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
