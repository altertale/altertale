import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../models/security/security_model.dart';

/// Güvenlik servisi
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Koleksiyon isimleri
  static const String _userSessionsCollection = 'userSessions';
  static const String _securityEventsCollection = 'securityEvents';
  static const String _userSecurityProfilesCollection = 'userSecurityProfiles';
  static const String _deviceInfoCollection = 'deviceInfo';

  // Güvenlik ayarları
  static const int _maxFailedLoginAttempts = 5;
  static const int _lockoutDurationMinutes = 30;
  static const int _maxConcurrentSessions = 3;
  static const int _suspiciousActivityThreshold = 10;

  /// Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  // ==================== KULLANICI GÜVENLİK PROFİLİ ====================

  /// Kullanıcı güvenlik profilini getir
  Future<UserSecurityProfile> getUserSecurityProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_userSecurityProfilesCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserSecurityProfile.fromFirestore(doc);
      } else {
        // Varsayılan profil oluştur
        final profile = UserSecurityProfile.defaultProfile(userId);
        await _saveUserSecurityProfile(profile);
        return profile;
      }
    } catch (e) {
      throw Exception('Güvenlik profili alınırken hata oluştu: $e');
    }
  }

  /// Kullanıcı güvenlik profilini güncelle
  Future<void> updateUserSecurityProfile(UserSecurityProfile profile) async {
    try {
      await _saveUserSecurityProfile(profile);
    } catch (e) {
      throw Exception('Güvenlik profili güncellenirken hata oluştu: $e');
    }
  }

  /// Başarısız giriş denemesini kaydet
  Future<void> recordFailedLoginAttempt(String userId, String ipAddress) async {
    try {
      final profile = await getUserSecurityProfile(userId);
      final now = DateTime.now();
      
      int failedAttempts = profile.failedLoginAttempts + 1;
      DateTime? lockoutUntil;
      
      // Maksimum deneme sayısını aştıysa hesabı kilitle
      if (failedAttempts >= _maxFailedLoginAttempts) {
        lockoutUntil = now.add(Duration(minutes: _lockoutDurationMinutes));
      }

      final updatedProfile = profile.copyWith(
        failedLoginAttempts: failedAttempts,
        lastFailedLogin: now,
        lockoutUntil: lockoutUntil,
      );

      await updateUserSecurityProfile(updatedProfile);

      // Güvenlik olayı kaydet
      await _recordSecurityEvent(
        userId: userId,
        eventType: 'failed_login_attempt',
        description: 'Başarısız giriş denemesi',
        severity: failedAttempts >= _maxFailedLoginAttempts ? 'high' : 'medium',
        ipAddress: ipAddress,
        metadata: {
          'failedAttempts': failedAttempts,
          'lockoutUntil': lockoutUntil?.toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Başarısız giriş denemesi kaydedilirken hata oluştu: $e');
    }
  }

  /// Başarılı girişi kaydet
  Future<void> recordSuccessfulLogin(String userId, String ipAddress) async {
    try {
      final profile = await getUserSecurityProfile(userId);
      
      // Başarısız giriş denemelerini sıfırla
      final updatedProfile = profile.copyWith(
        failedLoginAttempts: 0,
        lastFailedLogin: null,
        lockoutUntil: null,
      );

      await updateUserSecurityProfile(updatedProfile);

      // Güvenlik olayı kaydet
      await _recordSecurityEvent(
        userId: userId,
        eventType: 'successful_login',
        description: 'Başarılı giriş',
        severity: 'low',
        ipAddress: ipAddress,
      );
    } catch (e) {
      throw Exception('Başarılı giriş kaydedilirken hata oluştu: $e');
    }
  }

  // ==================== OTURUM YÖNETİMİ ====================

  /// Yeni oturum oluştur
  Future<UserSession> createUserSession(String userId, String ipAddress) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      final location = await _getLocationFromIP(ipAddress);
      
      final session = UserSession(
        id: '', // Firestore tarafından oluşturulacak
        userId: userId,
        deviceId: deviceInfo.deviceId,
        deviceName: deviceInfo.deviceName,
        deviceType: deviceInfo.deviceType,
        ipAddress: ipAddress,
        userAgent: deviceInfo.systemVersion,
        location: location,
        loginTime: DateTime.now(),
        isCurrentSession: true,
      );

      final docRef = await _firestore
          .collection(_userSessionsCollection)
          .add(session.toFirestore());

      // Diğer oturumları güncelle
      await _updateOtherSessions(userId, docRef.id);

      return session.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Oturum oluşturulurken hata oluştu: $e');
    }
  }

  /// Kullanıcının aktif oturumlarını getir
  Stream<List<UserSession>> getUserSessions(String userId) {
    return _firestore
        .collection(_userSessionsCollection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('loginTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserSession.fromFirestore(doc);
      }).toList();
    });
  }

  /// Oturumu sonlandır
  Future<void> endUserSession(String sessionId) async {
    try {
      await _firestore
          .collection(_userSessionsCollection)
          .doc(sessionId)
          .update({
        'isActive': false,
        'logoutTime': FieldValue.serverTimestamp(),
        'isCurrentSession': false,
      });
    } catch (e) {
      throw Exception('Oturum sonlandırılırken hata oluştu: $e');
    }
  }

  /// Tüm oturumları sonlandır
  Future<void> endAllUserSessions(String userId) async {
    try {
      final sessions = await _firestore
          .collection(_userSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in sessions.docs) {
        batch.update(doc.reference, {
          'isActive': false,
          'logoutTime': FieldValue.serverTimestamp(),
          'isCurrentSession': false,
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Oturumlar sonlandırılırken hata oluştu: $e');
    }
  }

  /// Çoklu oturum kontrolü
  Future<bool> checkMultipleSessions(String userId) async {
    try {
      final sessions = await _firestore
          .collection(_userSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return sessions.docs.length > _maxConcurrentSessions;
    } catch (e) {
      return false;
    }
  }

  // ==================== GÜVENLİK OLAYLARI ====================

  /// Güvenlik olayı kaydet
  Future<void> _recordSecurityEvent({
    required String userId,
    required String eventType,
    required String description,
    required String severity,
    required String ipAddress,
    String? deviceId,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      
      final event = SecurityEvent(
        id: '', // Firestore tarafından oluşturulacak
        userId: userId,
        eventType: eventType,
        description: description,
        severity: severity,
        ipAddress: ipAddress,
        deviceId: deviceId ?? deviceInfo.deviceId,
        userAgent: userAgent ?? deviceInfo.systemVersion,
        metadata: metadata ?? {},
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection(_securityEventsCollection)
          .add(event.toFirestore());
    } catch (e) {
      // Güvenlik olayı kaydedilemezse sessizce geç
    }
  }

  /// Kullanıcının güvenlik olaylarını getir
  Stream<List<SecurityEvent>> getUserSecurityEvents(String userId) {
    return _firestore
        .collection(_securityEventsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SecurityEvent.fromFirestore(doc);
      }).toList();
    });
  }

  /// Şüpheli aktivite tespit et
  Future<bool> detectSuspiciousActivity(String userId) async {
    try {
      final events = await _firestore
          .collection(_securityEventsCollection)
          .where('userId', isEqualTo: userId)
          .where('severity', whereIn: ['medium', 'high', 'critical'])
          .where('timestamp', isGreaterThan: Timestamp.fromDate(
            DateTime.now().subtract(Duration(hours: 24)),
          ))
          .get();

      return events.docs.length >= _suspiciousActivityThreshold;
    } catch (e) {
      return false;
    }
  }

  // ==================== CİHAZ YÖNETİMİ ====================

  /// Cihaz bilgilerini al
  Future<DeviceInfo> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return DeviceInfo(
          deviceId: androidInfo.id,
          deviceName: androidInfo.brand,
          deviceType: 'mobile',
          platform: 'android',
          version: androidInfo.version.release,
          buildNumber: androidInfo.version.sdkInt.toString(),
          deviceModel: androidInfo.model,
          systemVersion: androidInfo.version.release,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return DeviceInfo(
          deviceId: iosInfo.identifierForVendor ?? '',
          deviceName: iosInfo.name,
          deviceType: 'mobile',
          platform: 'ios',
          version: iosInfo.systemVersion,
          buildNumber: iosInfo.systemVersion,
          deviceModel: iosInfo.model,
          systemVersion: iosInfo.systemVersion,
          isPhysicalDevice: iosInfo.isPhysicalDevice,
        );
      } else {
        // Web veya desktop
        final packageInfo = await PackageInfo.fromPlatform();
        return DeviceInfo(
          deviceId: 'web_${DateTime.now().millisecondsSinceEpoch}',
          deviceName: 'Web Browser',
          deviceType: 'web',
          platform: 'web',
          version: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          deviceModel: 'Web',
          systemVersion: 'Web',
          isPhysicalDevice: false,
        );
      }
    } catch (e) {
      // Varsayılan cihaz bilgileri
      return DeviceInfo(
        deviceId: 'unknown_${DateTime.now().millisecondsSinceEpoch}',
        deviceName: 'Unknown Device',
        deviceType: 'unknown',
        platform: 'unknown',
        version: '1.0.0',
        buildNumber: '1',
        deviceModel: 'Unknown',
        systemVersion: 'Unknown',
        isPhysicalDevice: false,
      );
    }
  }

  /// Cihaz bilgilerini kaydet
  Future<void> saveDeviceInfo(String userId, DeviceInfo deviceInfo) async {
    try {
      await _firestore
          .collection(_deviceInfoCollection)
          .doc(userId)
          .collection('devices')
          .doc(deviceInfo.deviceId)
          .set(deviceInfo.toFirestore());
    } catch (e) {
      // Cihaz bilgileri kaydedilemezse sessizce geç
    }
  }

  // ==================== IP VE KONUM ====================

  /// IP adresinden konum al
  Future<String> _getLocationFromIP(String ipAddress) async {
    try {
      // Basit implementasyon - gerçek uygulamada IP geolocation servisi kullanılır
      if (ipAddress.startsWith('192.168.') || ipAddress.startsWith('10.') || ipAddress.startsWith('172.')) {
        return 'Local Network';
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  /// IP adresini al
  Future<String> getCurrentIPAddress() async {
    try {
      // Basit implementasyon - gerçek uygulamada IP servisi kullanılır
      return '127.0.0.1';
    } catch (e) {
      return 'Unknown IP';
    }
  }

  // ==================== YETKİ KONTROLÜ ====================

  /// Kullanıcının yetkisini kontrol et
  Future<bool> hasPermission(String userId, String permission) async {
    try {
      final profile = await getUserSecurityProfile(userId);
      return profile.hasPermission(permission);
    } catch (e) {
      return false;
    }
  }

  /// Admin kontrolü
  Future<bool> isAdmin(String userId) async {
    try {
      final profile = await getUserSecurityProfile(userId);
      return profile.isAdmin;
    } catch (e) {
      return false;
    }
  }

  /// Editör kontrolü
  Future<bool> isEditor(String userId) async {
    try {
      final profile = await getUserSecurityProfile(userId);
      return profile.isEditor;
    } catch (e) {
      return false;
    }
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Kullanıcı güvenlik profilini kaydet
  Future<void> _saveUserSecurityProfile(UserSecurityProfile profile) async {
    await _firestore
        .collection(_userSecurityProfilesCollection)
        .doc(profile.userId)
        .set(profile.toFirestore());
  }

  /// Diğer oturumları güncelle
  Future<void> _updateOtherSessions(String userId, String currentSessionId) async {
    try {
      final sessions = await _firestore
          .collection(_userSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isCurrentSession', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in sessions.docs) {
        if (doc.id != currentSessionId) {
          batch.update(doc.reference, {
            'isCurrentSession': false,
          });
        }
      }
      await batch.commit();
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }
}
