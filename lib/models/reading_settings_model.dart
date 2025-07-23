import 'package:flutter/material.dart';
import 'dart:convert';

/// Reading settings model for customizable reading experience
class ReadingSettingsModel {
  final double fontSize;
  final double lineHeight;
  final String fontFamily;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;
  final double pageWidth;
  final bool isDarkMode;
  final bool isSepia;
  final double brightness;
  final TextAlign textAlign;
  final double letterSpacing;
  final double wordSpacing;
  final bool autoScroll;
  final double autoScrollSpeed;
  final bool showPageNumbers;
  final bool showProgressBar;
  final String readingMode; // 'continuous', 'paginated'

  const ReadingSettingsModel({
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.fontFamily = 'Inter',
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.padding = const EdgeInsets.all(20.0),
    this.pageWidth = 600.0,
    this.isDarkMode = false,
    this.isSepia = false,
    this.brightness = 1.0,
    this.textAlign = TextAlign.left,
    this.letterSpacing = 0.0,
    this.wordSpacing = 0.0,
    this.autoScroll = false,
    this.autoScrollSpeed = 1.0,
    this.showPageNumbers = true,
    this.showProgressBar = true,
    this.readingMode = 'continuous',
  });

  /// Create default light mode settings
  factory ReadingSettingsModel.defaultLight() {
    return const ReadingSettingsModel(
      fontSize: 16.0,
      lineHeight: 1.5,
      fontFamily: 'Inter',
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      isDarkMode: false,
      isSepia: false,
      brightness: 1.0,
    );
  }

  /// Create default dark mode settings
  factory ReadingSettingsModel.defaultDark() {
    return const ReadingSettingsModel(
      fontSize: 16.0,
      lineHeight: 1.5,
      fontFamily: 'Inter',
      backgroundColor: Color(0xFF1A1A1A),
      textColor: Color(0xFFE0E0E0),
      isDarkMode: true,
      isSepia: false,
      brightness: 0.8,
    );
  }

  /// Create sepia mode settings
  factory ReadingSettingsModel.sepia() {
    return const ReadingSettingsModel(
      fontSize: 16.0,
      lineHeight: 1.5,
      fontFamily: 'Inter',
      backgroundColor: Color(0xFFF4F1E8),
      textColor: Color(0xFF5C4B3A),
      isDarkMode: false,
      isSepia: true,
      brightness: 0.9,
    );
  }

  /// Create from JSON
  factory ReadingSettingsModel.fromJson(Map<String, dynamic> json) {
    return ReadingSettingsModel(
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      lineHeight: (json['lineHeight'] ?? 1.5).toDouble(),
      fontFamily: json['fontFamily'] ?? 'Inter',
      backgroundColor: Color(json['backgroundColor'] ?? 0xFFFFFFFF),
      textColor: Color(json['textColor'] ?? 0xFF000000),
      padding: EdgeInsets.all((json['padding'] ?? 20.0).toDouble()),
      pageWidth: (json['pageWidth'] ?? 600.0).toDouble(),
      isDarkMode: json['isDarkMode'] ?? false,
      isSepia: json['isSepia'] ?? false,
      brightness: (json['brightness'] ?? 1.0).toDouble(),
      textAlign: _parseTextAlign(json['textAlign']),
      letterSpacing: (json['letterSpacing'] ?? 0.0).toDouble(),
      wordSpacing: (json['wordSpacing'] ?? 0.0).toDouble(),
      autoScroll: json['autoScroll'] ?? false,
      autoScrollSpeed: (json['autoScrollSpeed'] ?? 1.0).toDouble(),
      showPageNumbers: json['showPageNumbers'] ?? true,
      showProgressBar: json['showProgressBar'] ?? true,
      readingMode: json['readingMode'] ?? 'continuous',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'fontFamily': fontFamily,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
      'padding': padding.left, // Simplified to single value
      'pageWidth': pageWidth,
      'isDarkMode': isDarkMode,
      'isSepia': isSepia,
      'brightness': brightness,
      'textAlign': textAlign.toString().split('.').last,
      'letterSpacing': letterSpacing,
      'wordSpacing': wordSpacing,
      'autoScroll': autoScroll,
      'autoScrollSpeed': autoScrollSpeed,
      'showPageNumbers': showPageNumbers,
      'showProgressBar': showProgressBar,
      'readingMode': readingMode,
    };
  }

  /// Copy with new values
  ReadingSettingsModel copyWith({
    double? fontSize,
    double? lineHeight,
    String? fontFamily,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsets? padding,
    double? pageWidth,
    bool? isDarkMode,
    bool? isSepia,
    double? brightness,
    TextAlign? textAlign,
    double? letterSpacing,
    double? wordSpacing,
    bool? autoScroll,
    double? autoScrollSpeed,
    bool? showPageNumbers,
    bool? showProgressBar,
    String? readingMode,
  }) {
    return ReadingSettingsModel(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      fontFamily: fontFamily ?? this.fontFamily,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      padding: padding ?? this.padding,
      pageWidth: pageWidth ?? this.pageWidth,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isSepia: isSepia ?? this.isSepia,
      brightness: brightness ?? this.brightness,
      textAlign: textAlign ?? this.textAlign,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      autoScroll: autoScroll ?? this.autoScroll,
      autoScrollSpeed: autoScrollSpeed ?? this.autoScrollSpeed,
      showPageNumbers: showPageNumbers ?? this.showPageNumbers,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      readingMode: readingMode ?? this.readingMode,
    );
  }

  /// Get TextStyle from settings
  TextStyle get textStyle {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      color: textColor,
      height: lineHeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
    );
  }

  /// Get available font families
  static List<String> get availableFonts {
    return [
      'Inter',
      'Roboto',
      'Open Sans',
      'Lato',
      'Merriweather',
      'Source Serif Pro',
      'Crimson Text',
      'Libre Baskerville',
      'PT Serif',
      'Georgia',
    ];
  }

  /// Get reading mode options
  static List<Map<String, dynamic>> get readingModeOptions {
    return [
      {
        'value': 'continuous',
        'label': 'Sürekli Okuma',
        'description': 'Sayfa geçişi olmadan sürekli kaydır',
        'icon': Icons.view_stream,
      },
      {
        'value': 'paginated',
        'label': 'Sayfalı Okuma',
        'description': 'Geleneksel sayfa sayfa okuma',
        'icon': Icons.menu_book,
      },
    ];
  }

  /// Get text alignment options
  static List<Map<String, dynamic>> get textAlignOptions {
    return [
      {
        'value': TextAlign.left,
        'label': 'Sola Hizalı',
        'icon': Icons.format_align_left,
      },
      {
        'value': TextAlign.center,
        'label': 'Ortalanmış',
        'icon': Icons.format_align_center,
      },
      {
        'value': TextAlign.justify,
        'label': 'İki Yana Yaslı',
        'icon': Icons.format_align_justify,
      },
    ];
  }

  /// Parse TextAlign from string
  static TextAlign _parseTextAlign(String? value) {
    switch (value) {
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  /// Get contrast ratio for accessibility
  double get contrastRatio {
    // Simplified contrast calculation
    final bgLuminance = _getLuminance(backgroundColor);
    final textLuminance = _getLuminance(textColor);

    final lighter = bgLuminance > textLuminance ? bgLuminance : textLuminance;
    final darker = bgLuminance > textLuminance ? textLuminance : bgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if settings meet accessibility standards
  bool get isAccessible {
    return contrastRatio >= 4.5; // WCAG AA standard
  }

  /// Get luminance of a color
  double _getLuminance(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    return 0.299 * r + 0.587 * g + 0.114 * b;
  }

  /// Get preset themes
  static List<ReadingSettingsModel> get presetThemes {
    return [
      ReadingSettingsModel.defaultLight(),
      ReadingSettingsModel.defaultDark(),
      ReadingSettingsModel.sepia(),
      // High contrast theme
      const ReadingSettingsModel(
        fontSize: 18.0,
        lineHeight: 1.6,
        fontFamily: 'Inter',
        backgroundColor: Colors.black,
        textColor: Colors.white,
        isDarkMode: true,
        brightness: 1.0,
      ),
      // Blue light filter theme
      const ReadingSettingsModel(
        fontSize: 16.0,
        lineHeight: 1.5,
        fontFamily: 'Inter',
        backgroundColor: Color(0xFFF8F6F0),
        textColor: Color(0xFF2A2A2A),
        brightness: 0.7,
      ),
    ];
  }

  @override
  String toString() {
    return 'ReadingSettings(font: $fontFamily, size: $fontSize, mode: ${isDarkMode ? 'dark' : 'light'})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingSettingsModel &&
        other.fontSize == fontSize &&
        other.fontFamily == fontFamily &&
        other.isDarkMode == isDarkMode &&
        other.isSepia == isSepia;
  }

  @override
  int get hashCode {
    return fontSize.hashCode ^
        fontFamily.hashCode ^
        isDarkMode.hashCode ^
        isSepia.hashCode;
  }
}
