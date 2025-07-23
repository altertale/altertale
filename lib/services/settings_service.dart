import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings Service
///
/// Manages all application settings and user preferences
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // ==================== CONSTANTS ====================
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _autoSaveKey = 'auto_save_enabled';
  static const String _offlineModeKey = 'offline_mode_enabled';
  static const String _analyticsEnabledKey = 'analytics_enabled';
  static const String _crashReportingKey = 'crash_reporting_enabled';
  static const String _lastBackupDateKey = 'last_backup_date';
  static const String _languageKey = 'selected_language';
  static const String _textSizeKey = 'text_size_scale';

  // ==================== PRIVATE STATE ====================
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Default values
  static const bool _defaultNotificationsEnabled = true;
  static const bool _defaultAutoSave = true;
  static const bool _defaultOfflineMode = false;
  static const bool _defaultAnalytics = true;
  static const bool _defaultCrashReporting = true;
  static const String _defaultLanguage = 'tr';
  static const double _defaultTextSize = 1.0;

  // ==================== INITIALIZATION ====================

  /// Initialize settings service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      if (kDebugMode) {
        print('⚙️ SettingsService: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SettingsService: Initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // ==================== NOTIFICATION SETTINGS ====================

  /// Get notifications enabled status
  Future<bool> getNotificationsEnabled() async {
    await _ensureInitialized();
    return _prefs?.getBool(_notificationsEnabledKey) ??
        _defaultNotificationsEnabled;
  }

  /// Set notifications enabled status
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs?.setBool(_notificationsEnabledKey, enabled);
    if (kDebugMode) {
      print('⚙️ SettingsService: Notifications enabled set to: $enabled');
    }
  }

  // ==================== AUTO SAVE SETTINGS ====================

  /// Get auto save enabled status
  Future<bool> getAutoSaveEnabled() async {
    await _ensureInitialized();
    return _prefs?.getBool(_autoSaveKey) ?? _defaultAutoSave;
  }

  /// Set auto save enabled status
  Future<void> setAutoSaveEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs?.setBool(_autoSaveKey, enabled);
    if (kDebugMode) {
      print('⚙️ SettingsService: Auto save enabled set to: $enabled');
    }
  }

  // ==================== OFFLINE MODE SETTINGS ====================

  /// Get offline mode enabled status
  Future<bool> getOfflineModeEnabled() async {
    await _ensureInitialized();
    return _prefs?.getBool(_offlineModeKey) ?? _defaultOfflineMode;
  }

  /// Set offline mode enabled status
  Future<void> setOfflineModeEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs?.setBool(_offlineModeKey, enabled);
    if (kDebugMode) {
      print('⚙️ SettingsService: Offline mode enabled set to: $enabled');
    }
  }

  // ==================== ANALYTICS SETTINGS ====================

  /// Get analytics enabled status
  Future<bool> getAnalyticsEnabled() async {
    await _ensureInitialized();
    return _prefs?.getBool(_analyticsEnabledKey) ?? _defaultAnalytics;
  }

  /// Set analytics enabled status
  Future<void> setAnalyticsEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs?.setBool(_analyticsEnabledKey, enabled);
    if (kDebugMode) {
      print('⚙️ SettingsService: Analytics enabled set to: $enabled');
    }
  }

  // ==================== CRASH REPORTING SETTINGS ====================

  /// Get crash reporting enabled status
  Future<bool> getCrashReportingEnabled() async {
    await _ensureInitialized();
    return _prefs?.getBool(_crashReportingKey) ?? _defaultCrashReporting;
  }

  /// Set crash reporting enabled status
  Future<void> setCrashReportingEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs?.setBool(_crashReportingKey, enabled);
    if (kDebugMode) {
      print('⚙️ SettingsService: Crash reporting enabled set to: $enabled');
    }
  }

  // ==================== LANGUAGE SETTINGS ====================

  /// Get selected language
  Future<String> getSelectedLanguage() async {
    await _ensureInitialized();
    return _prefs?.getString(_languageKey) ?? _defaultLanguage;
  }

  /// Set selected language
  Future<void> setSelectedLanguage(String language) async {
    await _ensureInitialized();
    await _prefs?.setString(_languageKey, language);
    if (kDebugMode) {
      print('⚙️ SettingsService: Language set to: $language');
    }
  }

  // ==================== TEXT SIZE SETTINGS ====================

  /// Get text size scale
  Future<double> getTextSizeScale() async {
    await _ensureInitialized();
    return _prefs?.getDouble(_textSizeKey) ?? _defaultTextSize;
  }

  /// Set text size scale
  Future<void> setTextSizeScale(double scale) async {
    await _ensureInitialized();
    await _prefs?.setDouble(_textSizeKey, scale);
    if (kDebugMode) {
      print('⚙️ SettingsService: Text size scale set to: $scale');
    }
  }

  // ==================== BACKUP SETTINGS ====================

  /// Get last backup date
  Future<DateTime?> getLastBackupDate() async {
    await _ensureInitialized();
    final timestamp = _prefs?.getInt(_lastBackupDateKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Set last backup date
  Future<void> setLastBackupDate(DateTime date) async {
    await _ensureInitialized();
    await _prefs?.setInt(_lastBackupDateKey, date.millisecondsSinceEpoch);
    if (kDebugMode) {
      print('⚙️ SettingsService: Last backup date set to: $date');
    }
  }

  // ==================== BULK OPERATIONS ====================

  /// Get all settings as a map
  Future<Map<String, dynamic>> getAllSettings() async {
    await _ensureInitialized();

    return {
      'notificationsEnabled': await getNotificationsEnabled(),
      'autoSaveEnabled': await getAutoSaveEnabled(),
      'offlineModeEnabled': await getOfflineModeEnabled(),
      'analyticsEnabled': await getAnalyticsEnabled(),
      'crashReportingEnabled': await getCrashReportingEnabled(),
      'selectedLanguage': await getSelectedLanguage(),
      'textSizeScale': await getTextSizeScale(),
      'lastBackupDate': await getLastBackupDate(),
    };
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await _ensureInitialized();

    try {
      await Future.wait([
        setNotificationsEnabled(_defaultNotificationsEnabled),
        setAutoSaveEnabled(_defaultAutoSave),
        setOfflineModeEnabled(_defaultOfflineMode),
        setAnalyticsEnabled(_defaultAnalytics),
        setCrashReportingEnabled(_defaultCrashReporting),
        setSelectedLanguage(_defaultLanguage),
        setTextSizeScale(_defaultTextSize),
      ]);

      // Remove backup date
      await _prefs?.remove(_lastBackupDateKey);

      if (kDebugMode) {
        print('⚙️ SettingsService: All settings reset to defaults');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SettingsService: Error resetting settings: $e');
      }
      rethrow;
    }
  }

  /// Export settings to JSON-like map
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final settings = await getAllSettings();
      settings['exportDate'] = DateTime.now().toIso8601String();
      settings['version'] = '1.0';

      if (kDebugMode) {
        print('⚙️ SettingsService: Settings exported successfully');
      }

      return settings;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SettingsService: Error exporting settings: $e');
      }
      rethrow;
    }
  }

  /// Import settings from JSON-like map
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      await _ensureInitialized();

      // Validate and import each setting
      if (settings.containsKey('notificationsEnabled')) {
        await setNotificationsEnabled(settings['notificationsEnabled'] as bool);
      }

      if (settings.containsKey('autoSaveEnabled')) {
        await setAutoSaveEnabled(settings['autoSaveEnabled'] as bool);
      }

      if (settings.containsKey('offlineModeEnabled')) {
        await setOfflineModeEnabled(settings['offlineModeEnabled'] as bool);
      }

      if (settings.containsKey('analyticsEnabled')) {
        await setAnalyticsEnabled(settings['analyticsEnabled'] as bool);
      }

      if (settings.containsKey('crashReportingEnabled')) {
        await setCrashReportingEnabled(
          settings['crashReportingEnabled'] as bool,
        );
      }

      if (settings.containsKey('selectedLanguage')) {
        await setSelectedLanguage(settings['selectedLanguage'] as String);
      }

      if (settings.containsKey('textSizeScale')) {
        await setTextSizeScale((settings['textSizeScale'] as num).toDouble());
      }

      if (kDebugMode) {
        print('⚙️ SettingsService: Settings imported successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SettingsService: Error importing settings: $e');
      }
      rethrow;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all settings (for debugging/testing)
  Future<void> clearAllSettings() async {
    await _ensureInitialized();
    try {
      await _prefs?.clear();
      if (kDebugMode) {
        print('⚙️ SettingsService: All settings cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SettingsService: Error clearing settings: $e');
      }
      rethrow;
    }
  }

  /// Get service status information
  Map<String, dynamic> getServiceStatus() {
    return {
      'isInitialized': _isInitialized,
      'hasPreferences': _prefs != null,
      'serviceVersion': '1.0.0',
    };
  }
}
