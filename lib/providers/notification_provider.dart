import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

/// Bildirim işlemleri için provider
/// Uygulama içi bildirimleri yönetir
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  // Durum değişkenleri
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;
  
  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  
  /// Provider'a erişim için static metod
  static NotificationProvider of(BuildContext context) {
    return Provider.of<NotificationProvider>(context, listen: false);
  }
  
  /// Bildirimleri yükle
  Future<void> loadNotifications(String userId) async {
    _setLoading(true);
    try {
      // TODO: NotificationService'e getNotifications metodu eklenmeli
      _notifications = []; // Geçici boş liste
      _unreadCount = 0;
      _clearError();
    } catch (e) {
      _setError('Bildirimler yüklenirken hata: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Bildirim kaydet
  Future<void> saveNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // TODO: NotificationService'e saveNotification metodu eklenmeli
      _clearError();
    } catch (e) {
      _setError('Bildirim kaydedilirken hata: $e');
    }
  }
  
  /// Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    try {
      // TODO: NotificationService'e markAsRead metodu eklenmeli
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      notifyListeners();
    } catch (e) {
      _setError('Bildirim işaretlenirken hata: $e');
    }
  }
  
  /// Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllAsRead(String userId) async {
    try {
      // TODO: NotificationService'e markAllAsRead metodu eklenmeli
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _setError('Bildirimler işaretlenirken hata: $e');
    }
  }
  
  /// Bildirim gönder
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.sendNotification(
        body: message,
        targetAudience: 'all',
      );
      _clearError();
    } catch (e) {
      _setError('Bildirim gönderilirken hata: $e');
    }
  }
  
  // Private metodlar
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}
