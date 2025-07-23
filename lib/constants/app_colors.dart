import 'package:flutter/material.dart';

/// Uygulama renk paleti
/// Sade ve minimal tasarım için optimize edilmiş renkler
class AppColors {
  // Ana Renkler
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  
  // Nötr Renkler
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  
  // Metin Renkleri
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);
  
  // Durum Renkleri
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Karanlık Tema Renkleri
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkCard = Color(0xFF374151);
  
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextTertiary = Color(0xFF9CA3AF);
  
  // Kart Arka Plan Renkleri
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color darkCardBackground = Color(0xFF1F2937);
  
  // Özel Renkler
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color shadow = Color(0x1A000000);
  
  static const Color overlay = Color(0x80000000);
  static const Color backdrop = Color(0x40000000);
  
  // Gradient Renkleri
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFFF3F4F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Kitap Kategorileri Renkleri
  static const Color fantasy = Color(0xFF8B5CF6); // Purple
  static const Color romance = Color(0xFFEC4899); // Pink
  static const Color adventure = Color(0xFFF59E0B); // Amber
  static const Color mystery = Color(0xFF6B7280); // Gray
  static const Color scifi = Color(0xFF06B6D4); // Cyan
  static const Color horror = Color(0xFFDC2626); // Red
  
  // Puan Sistemi Renkleri
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color platinum = Color(0xFFE5E4E2);
  
  /// Tema moduna göre arka plan rengini döndürür
  static Color getBackgroundColor(bool isDark) {
    return isDark ? darkBackground : background;
  }
  
  /// Tema moduna göre yüzey rengini döndürür
  static Color getSurfaceColor(bool isDark) {
    return isDark ? darkSurface : surface;
  }
  
  /// Tema moduna göre kart rengini döndürür
  static Color getCardColor(bool isDark) {
    return isDark ? darkCard : card;
  }
  
  /// Tema moduna göre birincil metin rengini döndürür
  static Color getTextPrimaryColor(bool isDark) {
    return isDark ? darkTextPrimary : textPrimary;
  }
  
  /// Tema moduna göre ikincil metin rengini döndürür
  static Color getTextSecondaryColor(bool isDark) {
    return isDark ? darkTextSecondary : textSecondary;
  }
  
  /// Tema moduna göre üçüncül metin rengini döndürür
  static Color getTextTertiaryColor(bool isDark) {
    return isDark ? darkTextTertiary : textTertiary;
  }
  
  /// Kategori rengini döndürür
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fantasy':
        return fantasy;
      case 'romance':
        return romance;
      case 'adventure':
        return adventure;
      case 'mystery':
        return mystery;
      case 'scifi':
        return scifi;
      case 'horror':
        return horror;
      default:
        return primary;
    }
  }
  
  /// Puan seviyesine göre renk döndürür
  static Color getPointsColor(int points) {
    if (points >= 1000) return platinum;
    if (points >= 500) return gold;
    if (points >= 100) return silver;
    return bronze;
  }
  
  /// Yıldız rengini döndürür
  static Color getStarColor(double rating) {
    if (rating >= 4.5) return gold;
    if (rating >= 3.5) return silver;
    if (rating >= 2.5) return bronze;
    return textTertiary;
  }
} 