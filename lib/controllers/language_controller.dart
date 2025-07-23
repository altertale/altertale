import 'package:flutter/material.dart';
import '../models/preferences/user_preferences_model.dart';
import '../services/preferences/preferences_service.dart';

/// Dil kontrolcüsü
class LanguageController extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  
  UserPreferences _preferences = UserPreferences.defaultPreferences();
  bool _isLoading = true;

  /// Mevcut tercihler
  UserPreferences get preferences => _preferences;

  /// Yükleme durumu
  bool get isLoading => _isLoading;

  /// Mevcut dil
  Language get currentLanguage => _preferences.language;

  /// Mevcut locale
  Locale get currentLocale => _preferences.locale;

  /// Dil kontrolcüsünü başlat
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

  /// Dil tercihini güncelle
  Future<void> updateLanguage(Language language) async {
    try {
      await _preferencesService.updateLanguage(language);
      
      _preferences = _preferences.copyWith(language: language);
      notifyListeners();
    } catch (e) {
      throw Exception('Dil tercihi güncellenirken hata oluştu: $e');
    }
  }

  /// Desteklenen diller
  List<Language> get supportedLanguages => Language.values;

  /// Dil adını al
  String getLanguageName(Language language) {
    return language.displayName;
  }

  /// Dil kodunu al
  String getLanguageCode(Language language) {
    return language.languageCode;
  }

  /// Dil bayrağını al (emoji)
  String getLanguageFlag(Language language) {
    switch (language) {
      case Language.turkish:
        return '🇹🇷';
      case Language.english:
        return '🇺🇸';
    }
  }

  /// Sistem dilini algıla
  Language getSystemLanguage() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final languageCode = locale.languageCode.toLowerCase();
    
    switch (languageCode) {
      case 'tr':
        return Language.turkish;
      case 'en':
        return Language.english;
      default:
        return Language.turkish; // Varsayılan
    }
  }

  /// Dil tercihlerini yenile
  Future<void> refreshLanguage() async {
    await initialize();
  }
}
