import 'package:flutter/material.dart';

/// Base provider sınıfı
/// Ortak loading/error state yönetimi sağlar
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Loading durumunu ayarlar
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Hata mesajını ayarlar
  void setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Hata mesajını temizler
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Loading ve error state'ini temizler
  void clearState() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Async operasyon wrapper'ı
  /// Try-catch pattern'ini standartlaştırır
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showLoading = true,
    bool clearErrorFirst = true,
  }) async {
    if (clearErrorFirst) clearError();
    if (showLoading) setLoading(true);

    try {
      final result = await operation();
      if (showLoading) setLoading(false);
      return result;
    } catch (e) {
      setError(errorMessage ?? 'İşlem başarısız: $e');
      return null;
    }
  }

  /// Void async operasyon wrapper'ı
  Future<bool> executeAsyncVoid(
    Future<void> Function() operation, {
    String? errorMessage,
    String? successMessage,
    bool showLoading = true,
    bool clearErrorFirst = true,
  }) async {
    if (clearErrorFirst) clearError();
    if (showLoading) setLoading(true);

    try {
      await operation();
      if (showLoading) setLoading(false);
      return true;
    } catch (e) {
      setError(errorMessage ?? 'İşlem başarısız: $e');
      return false;
    }
  }
}
