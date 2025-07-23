import 'package:flutter/material.dart';

/// Tema modu
enum AppThemeMode {
  light('Açık Tema'),
  dark('Koyu Tema'),
  system('Sistem');

  const AppThemeMode(this.displayName);
  final String displayName;
}

/// Dil seçenekleri
enum Language {
  turkish('Türkçe', 'tr'),
  english('English', 'en');

  const Language(this.displayName, this.languageCode);
  final String displayName;
  final String languageCode;
}

/// Yazı tipi boyutu
enum FontSize {
  small('Küçük', 14.0),
  medium('Orta', 16.0),
  large('Büyük', 18.0),
  extraLarge('Çok Büyük', 20.0);

  const FontSize(this.displayName, this.size);
  final String displayName;
  final double size;
}

/// Satır aralığı
enum LineSpacing {
  tight('Dar', 1.2),
  normal('Normal', 1.5),
  wide('Geniş', 1.8);

  const LineSpacing(this.displayName, this.spacing);
  final String displayName;
  final double spacing;
}

/// Okuma arka plan rengi
enum ReadingBackground {
  white('Beyaz', Colors.white),
  gray('Gri', Color(0xFFF5F5F5)),
  sepia('Sepya', Color(0xFFF4ECD8)),
  black('Siyah', Colors.black);

  const ReadingBackground(this.displayName, this.color);
  final String displayName;
  final Color color;
}

/// Kullanıcı tercihleri modeli
class UserPreferences {
  final AppThemeMode themeMode;
  final Language language;
  final FontSize fontSize;
  final LineSpacing lineSpacing;
  final ReadingBackground readingBackground;
  final bool notificationsEnabled;
  final bool autoSyncEnabled;
  final DateTime lastUpdated;

  const UserPreferences({
    this.themeMode = AppThemeMode.system,
    this.language = Language.turkish,
    this.fontSize = FontSize.medium,
    this.lineSpacing = LineSpacing.normal,
    this.readingBackground = ReadingBackground.white,
    this.notificationsEnabled = true,
    this.autoSyncEnabled = true,
    required this.lastUpdated,
  });

  /// Varsayılan tercihler
  factory UserPreferences.defaultPreferences() {
    return UserPreferences(
      themeMode: AppThemeMode.system,
      language: Language.turkish,
      fontSize: FontSize.medium,
      lineSpacing: LineSpacing.normal,
      readingBackground: ReadingBackground.white,
      notificationsEnabled: true,
      autoSyncEnabled: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// Firestore'dan model oluştur
  factory UserPreferences.fromFirestore(Map<String, dynamic> data) {
    return UserPreferences(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == (data['themeMode'] ?? 'system'),
        orElse: () => AppThemeMode.system,
      ),
      language: Language.values.firstWhere(
        (e) => e.languageCode == (data['language'] ?? 'tr'),
        orElse: () => Language.turkish,
      ),
      fontSize: FontSize.values.firstWhere(
        (e) => e.size == (data['fontSize'] ?? 16.0),
        orElse: () => FontSize.medium,
      ),
      lineSpacing: LineSpacing.values.firstWhere(
        (e) => e.spacing == (data['lineSpacing'] ?? 1.5),
        orElse: () => LineSpacing.normal,
      ),
      readingBackground: ReadingBackground.values.firstWhere(
        (e) => e.displayName == (data['readingBackground'] ?? 'Beyaz'),
        orElse: () => ReadingBackground.white,
      ),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      autoSyncEnabled: data['autoSyncEnabled'] ?? true,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as DateTime)
          : DateTime.now(),
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'themeMode': themeMode.name,
      'language': language.languageCode,
      'fontSize': fontSize.size,
      'lineSpacing': lineSpacing.spacing,
      'readingBackground': readingBackground.displayName,
      'notificationsEnabled': notificationsEnabled,
      'autoSyncEnabled': autoSyncEnabled,
      'lastUpdated': lastUpdated,
    };
  }

  /// SharedPreferences'dan model oluştur
  factory UserPreferences.fromSharedPreferences(Map<String, dynamic> data) {
    return UserPreferences(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == (data['themeMode'] ?? 'system'),
        orElse: () => AppThemeMode.system,
      ),
      language: Language.values.firstWhere(
        (e) => e.languageCode == (data['language'] ?? 'tr'),
        orElse: () => Language.turkish,
      ),
      fontSize: FontSize.values.firstWhere(
        (e) => e.size == (data['fontSize'] ?? 16.0),
        orElse: () => FontSize.medium,
      ),
      lineSpacing: LineSpacing.values.firstWhere(
        (e) => e.spacing == (data['lineSpacing'] ?? 1.5),
        orElse: () => LineSpacing.normal,
      ),
      readingBackground: ReadingBackground.values.firstWhere(
        (e) => e.displayName == (data['readingBackground'] ?? 'Beyaz'),
        orElse: () => ReadingBackground.white,
      ),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      autoSyncEnabled: data['autoSyncEnabled'] ?? true,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.parse(data['lastUpdated'])
          : DateTime.now(),
    );
  }

  /// SharedPreferences'a gönderilecek map
  Map<String, dynamic> toSharedPreferences() {
    return {
      'themeMode': themeMode.name,
      'language': language.languageCode,
      'fontSize': fontSize.size,
      'lineSpacing': lineSpacing.spacing,
      'readingBackground': readingBackground.displayName,
      'notificationsEnabled': notificationsEnabled,
      'autoSyncEnabled': autoSyncEnabled,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Tercihleri güncelle
  UserPreferences copyWith({
    AppThemeMode? themeMode,
    Language? language,
    FontSize? fontSize,
    LineSpacing? lineSpacing,
    ReadingBackground? readingBackground,
    bool? notificationsEnabled,
    bool? autoSyncEnabled,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      readingBackground: readingBackground ?? this.readingBackground,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      lastUpdated: DateTime.now(),
    );
  }

  /// Tema modunu ThemeMode'a dönüştür
  AppThemeMode get effectiveAppThemeMode {
    if (themeMode == AppThemeMode.system) {
      // Sistem temasını algıla
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? AppThemeMode.dark : AppThemeMode.light;
    }
    return themeMode;
  }

  /// Dil kodunu al
  String get languageCode => language.languageCode;

  /// Locale oluştur
  Locale get locale => Locale(language.languageCode);

  /// Yazı tipi boyutunu al
  double get fontSizeValue => fontSize.size;

  /// Satır aralığını al
  double get lineSpacingValue => lineSpacing.spacing;

  /// Okuma arka plan rengini al
  Color get readingBackgroundColor => readingBackground.color;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.themeMode == themeMode &&
        other.language == language &&
        other.fontSize == fontSize &&
        other.lineSpacing == lineSpacing &&
        other.readingBackground == readingBackground &&
        other.notificationsEnabled == notificationsEnabled &&
        other.autoSyncEnabled == autoSyncEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      language,
      fontSize,
      lineSpacing,
      readingBackground,
      notificationsEnabled,
      autoSyncEnabled,
    );
  }

  @override
  String toString() {
    return 'UserPreferences('
        'themeMode: $themeMode, '
        'language: $language, '
        'fontSize: $fontSize, '
        'lineSpacing: $lineSpacing, '
        'readingBackground: $readingBackground, '
        'notificationsEnabled: $notificationsEnabled, '
        'autoSyncEnabled: $autoSyncEnabled)';
  }
}
