import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bildirim servisi - FCM ve uygulama içi bildirimleri yönetir
class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _notificationsCollection = 'notifications';
  static const String _fcmTokensCollection = 'fcm_tokens';
  static const String _notificationsKey = 'local_notifications';

  // State değişkenleri
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  /// FCM'yi başlat ve izinleri al
  Future<void> initialize() async {
    try {
      // Bildirim izinlerini iste
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Bildirim izni verildi');

        // FCM token'ı al
        String? token = await _messaging.getToken();
        if (token != null) {
          print('FCM Token: $token');
          await _saveFCMToken(token);
        }

        // Token yenilendiğinde
        _messaging.onTokenRefresh.listen((newToken) {
          _saveFCMToken(newToken);
        });

        // Foreground mesajları dinle
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Background mesajları dinle
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Uygulama kapalıyken açıldığında
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      } else {
        print('Bildirim izni reddedildi');
      }
    } catch (e) {
      print('FCM başlatılırken hata: $e');
    }
  }

  /// FCM token'ı kaydet
  Future<void> _saveFCMToken(String token) async {
    try {
      // TODO: Kullanıcı ID'sini AuthProvider'dan al
      String? userId = 'current_user_id'; // Geçici

      await _firestore.collection(_fcmTokensCollection).doc(userId).set({
        'token': token,
        'platform': 'flutter',
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('FCM token kaydedilirken hata: $e');
    }
  }

  /// Foreground mesajını işle
  void _handleForegroundMessage(RemoteMessage message) {
    // Bildirimi Firestore'a kaydet
    _saveNotificationToFirestore(message);

    // TODO: In-app notification göster (SnackBar, Dialog, vs.)
    print('Foreground bildirim: ${message.notification?.title}');
  }

  /// Bildirime tıklandığında işle
  void _handleNotificationTap(RemoteMessage message) {
    // Bildirimi okundu olarak işaretle
    _markNotificationAsRead(message.messageId);

    // TODO: İlgili sayfaya yönlendir
    print('Bildirime tıklandı: ${message.notification?.title}');
  }

  /// Bildirimi okundu olarak işaretle
  Future<void> _markNotificationAsRead(String? messageId) async {
    if (messageId == null) return;

    try {
      await _firestore
          .collection(_notificationsCollection)
          .where('messageId', isEqualTo: messageId)
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.update({'isRead': true});
            }
          });
    } catch (e) {
      print('Bildirim işaretlenirken hata: $e');
    }
  }

  /// Bildirimi Firestore'a kaydet
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      // TODO: Kullanıcı ID'sini AuthProvider'dan al
      String? userId = 'current_user_id'; // Geçici

      await _firestore.collection(_notificationsCollection).add({
        'userId': userId,
        'title': message.notification?.title ?? '',
        'message': message.notification?.body ?? '',
        'data': message.data,
        'messageId': message.messageId,
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Bildirim Firestore\'a kaydedilirken hata: $e');
    }
  }

  /// Bildirim ayarlarını kaydet
  Future<void> saveNotificationSettings({
    required String userId,
    required Map<String, bool> settings,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'notificationSettings': settings,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Bildirim ayarları kaydedilirken hata: $e');
    }
  }

  /// Bildirim ayarlarını getir
  Future<Map<String, bool>> getNotificationSettings(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        final settings = data['notificationSettings'] as Map<String, dynamic>?;

        if (settings != null) {
          return settings.map((key, value) => MapEntry(key, value as bool));
        }
      }

      // Varsayılan ayarlar
      return {
        'newBooks': true,
        'campaigns': true,
        'friends': true,
        'weekly': true,
        'general': true,
      };
    } catch (e) {
      print('Bildirim ayarları getirilirken hata: $e');
      return {};
    }
  }

  /// Bildirim kaydet (UI için basit versiyon)
  void saveNotification(String title, String message) {
    try {
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'message': message,
        'type': 'general',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      _notifications.insert(0, notification); // En üste ekle
      _unreadCount++;
      _clearError();
      notifyListeners();

      // Local storage'a kaydet
      _saveNotificationsToStorage();
    } catch (e) {
      _setError('Bildirim kaydedilirken hata: $e');
    }
  }

  /// Bildirim kaydet (gelişmiş versiyon)
  void saveNotificationAdvanced({
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
    String? userId,
  }) {
    try {
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'message': message,
        'type': type ?? 'general',
        'data': data ?? {},
        'userId': userId,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      _notifications.insert(0, notification);
      _unreadCount++;
      _clearError();
      notifyListeners();

      // Local storage'a kaydet
      _saveNotificationsToStorage();

      // Firestore'a da kaydet (eğer userId varsa)
      if (userId != null) {
        _saveNotificationToFirestoreAdvanced(notification);
      }
    } catch (e) {
      _setError('Bildirim kaydedilirken hata: $e');
    }
  }

  /// Bildirimleri local storage'dan yükle
  Future<void> loadNotifications() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

      _notifications = notificationsJson
          .map((json) {
            try {
              // Basit string parsing (gerçek uygulamada JSON decode kullanın)
              return <String, dynamic>{
                'id': json,
                'title': 'Bildirim',
                'message': 'Yüklenen bildirim',
                'type': 'general',
                'isRead': false,
                'createdAt': DateTime.now().toIso8601String(),
              };
            } catch (e) {
              return <String, dynamic>{};
            }
          })
          .where((notification) => notification.isNotEmpty)
          .toList();

      // Okunmamış bildirim sayısını hesapla
      _unreadCount = _notifications.where((n) => n['isRead'] == false).length;

      _clearError();
    } catch (e) {
      _setError('Bildirimler yüklenirken hata: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Bildirimleri local storage'a kaydet
  Future<void> _saveNotificationsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications.map((notification) {
        return notification['id'] as String;
      }).toList();

      await prefs.setStringList(_notificationsKey, notificationsJson);
    } catch (e) {
      print('Bildirimler kaydedilirken hata: $e');
    }
  }

  /// Bildirimi Firestore'a kaydet (gelişmiş versiyon)
  Future<void> _saveNotificationToFirestoreAdvanced(
    Map<String, dynamic> notification,
  ) async {
    try {
      final notificationRef = _firestore
          .collection(_notificationsCollection)
          .doc();
      await notificationRef.set({
        ...notification,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firestore\'a bildirim kaydedilirken hata: $e');
    }
  }

  /// Bildirimi okundu olarak işaretle
  void markAsRead(String notificationId) {
    try {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        notifyListeners();
        _saveNotificationsToStorage();
      }
    } catch (e) {
      _setError('Bildirim işaretlenirken hata: $e');
    }
  }

  /// Tüm bildirimleri okundu olarak işaretle
  void markAllAsRead() {
    try {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
      _saveNotificationsToStorage();
    } catch (e) {
      _setError('Bildirimler işaretlenirken hata: $e');
    }
  }

  /// Bildirimi sil
  void deleteNotification(String notificationId) {
    try {
      _notifications.removeWhere((n) => n['id'] == notificationId);
      // Okunmamış sayısını yeniden hesapla
      _unreadCount = _notifications.where((n) => n['isRead'] == false).length;
      notifyListeners();
      _saveNotificationsToStorage();
    } catch (e) {
      _setError('Bildirim silinirken hata: $e');
    }
  }

  /// Tüm bildirimleri sil
  void clearAllNotifications() {
    try {
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
      _saveNotificationsToStorage();
    } catch (e) {
      _setError('Bildirimler silinirken hata: $e');
    }
  }

  /// Bildirimleri tipe göre filtrele
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['type'] == type).toList();
  }

  /// Okunmamış bildirimleri getir
  List<Map<String, dynamic>> getUnreadNotifications() {
    return _notifications.where((n) => n['isRead'] == false).toList();
  }

  /// Bildirim istatistiklerini getir
  Map<String, dynamic> getNotificationStats() {
    final total = _notifications.length;
    final unread = _unreadCount;
    final read = total - unread;

    // Tipe göre grupla
    final typeStats = <String, int>{};
    for (var notification in _notifications) {
      final type = notification['type'] ?? 'general';
      typeStats[type] = (typeStats[type] ?? 0) + 1;
    }

    return {'total': total, 'unread': unread, 'read': read, 'types': typeStats};
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
