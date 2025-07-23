import 'package:shared_preferences/shared_preferences.dart';

/// Okuma ilerlemesini cihazda saklar ve Firebase ile senkronize eder
class ProgressTracker {
  /// Okuma ilerlemesini kaydet (cihazda)
  static Future<void> saveProgress(String bookId, int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('progress_$bookId', page);
  }

  /// Okuma ilerlemesini yükle (cihazdan)
  static Future<int?> getProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('progress_$bookId');
  }

  /// (Opsiyonel) Firebase ile senkronize etme fonksiyonu eklenebilir
} 