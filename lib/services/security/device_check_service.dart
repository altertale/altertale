import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Cihaz kontrol servisi
class DeviceCheckService {
  static final DeviceCheckService _instance = DeviceCheckService._internal();
  factory DeviceCheckService() => _instance;
  DeviceCheckService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // reCAPTCHA ayarları
  static const String _recaptchaSiteKey = 'YOUR_RECAPTCHA_SITE_KEY';
  static const String _recaptchaSecretKey = 'YOUR_RECAPTCHA_SECRET_KEY';
  static const String _recaptchaVerifyUrl = 'https://www.google.com/recaptcha/api/siteverify';

  // Cihaz kontrol ayarları
  static const int _maxDevicesPerUser = 5;
  static const int _suspiciousDeviceThreshold = 3;

  /// Cihaz doğrulama
  Future<bool> verifyDevice() async {
    try {
      // Cihaz bilgilerini al
      final deviceInfo = await _getDeviceInfo();
      
      // Cihaz türünü kontrol et
      if (!_isValidDevice(deviceInfo)) {
        return false;
      }

      // Cihaz güvenlik kontrolü
      if (!await _checkDeviceSecurity(deviceInfo)) {
        return false;
      }

      // reCAPTCHA kontrolü (web için)
      if (kIsWeb) {
        if (!await _verifyRecaptcha()) {
          return false;
        }
      }

      // DeviceCheck kontrolü (iOS için)
      if (Platform.isIOS) {
        if (!await _verifyDeviceCheck()) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cihaz bilgilerini al
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'deviceId': androidInfo.id,
          'deviceName': androidInfo.brand,
          'deviceModel': androidInfo.model,
          'systemVersion': androidInfo.version.release,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'fingerprint': androidInfo.fingerprint,
          'bootloader': androidInfo.bootloader,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'product': androidInfo.product,
          'hardware': androidInfo.hardware,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'deviceId': iosInfo.identifierForVendor ?? '',
          'deviceName': iosInfo.name,
          'deviceModel': iosInfo.model,
          'systemVersion': iosInfo.systemVersion,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'localizedModel': iosInfo.localizedModel,
          'utsname': iosInfo.utsname.sysname,
        };
      } else if (kIsWeb) {
        return {
          'platform': 'web',
          'deviceId': 'web_${DateTime.now().millisecondsSinceEpoch}',
          'deviceName': 'Web Browser',
          'userAgent': defaultTargetPlatform.toString(),
        };
      } else {
        return {
          'platform': 'unknown',
          'deviceId': 'unknown_${DateTime.now().millisecondsSinceEpoch}',
          'deviceName': 'Unknown Device',
        };
      }
    } catch (e) {
      return {
        'platform': 'error',
        'deviceId': 'error_${DateTime.now().millisecondsSinceEpoch}',
        'deviceName': 'Error Device',
      };
    }
  }

  /// Geçerli cihaz mı?
  bool _isValidDevice(Map<String, dynamic> deviceInfo) {
    // Emülatör kontrolü
    if (deviceInfo['platform'] == 'android') {
      if (!deviceInfo['isPhysicalDevice']) {
        // Emülatör tespit edildi
        return false;
      }
    } else if (deviceInfo['platform'] == 'ios') {
      if (!deviceInfo['isPhysicalDevice']) {
        // Simulator tespit edildi
        return false;
      }
    }

    // Bilinmeyen platform kontrolü
    if (deviceInfo['platform'] == 'unknown' || deviceInfo['platform'] == 'error') {
      return false;
    }

    return true;
  }

  /// Cihaz güvenlik kontrolü
  Future<bool> _checkDeviceSecurity(Map<String, dynamic> deviceInfo) async {
    try {
      // Root/Jailbreak kontrolü
      if (await _isDeviceRooted(deviceInfo)) {
        return false;
      }

      // Şüpheli cihaz kontrolü
      if (await _isSuspiciousDevice(deviceInfo)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cihaz root'lu mu?
  Future<bool> _isDeviceRooted(Map<String, dynamic> deviceInfo) async {
    try {
      if (deviceInfo['platform'] == 'android') {
        // Android root kontrolü
        final buildTags = deviceInfo['fingerprint'] ?? '';
        final buildTagsLower = buildTags.toLowerCase();
        
        // Root göstergeleri
        final rootIndicators = [
          'test-keys',
          'debug',
          'userdebug',
          'eng',
          'su',
          'magisk',
          'supersu',
        ];

        for (final indicator in rootIndicators) {
          if (buildTagsLower.contains(indicator)) {
            return true;
          }
        }

        // Sistem dosyaları kontrolü
        final systemFiles = [
          '/system/app/Superuser.apk',
          '/system/xbin/su',
          '/system/bin/su',
          '/sbin/su',
          '/system/su',
          '/system/bin/.ext/.su',
          '/system/etc/init.d/99SuperSUDaemon',
          '/dev/com.koushikdutta.superuser.daemon/',
        ];

        for (final file in systemFiles) {
          if (await File(file).exists()) {
            return true;
          }
        }
      } else if (deviceInfo['platform'] == 'ios') {
        // iOS jailbreak kontrolü
        final jailbreakFiles = [
          '/Applications/Cydia.app',
          '/Library/MobileSubstrate/MobileSubstrate.dylib',
          '/bin/bash',
          '/usr/sbin/sshd',
          '/etc/apt',
          '/private/var/lib/apt/',
          '/private/var/lib/cydia',
          '/private/var/mobile/Library/SBSettings/Themes',
          '/Library/MobileSubstrate/DynamicLibraries/Veency.plist',
          '/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist',
          '/System/Library/LaunchDaemons/com.ikey.bbot.plist',
          '/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist',
        ];

        for (final file in jailbreakFiles) {
          if (await File(file).exists()) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Şüpheli cihaz mı?
  Future<bool> _isSuspiciousDevice(Map<String, dynamic> deviceInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = deviceInfo['deviceId'];
      
      // Cihaz kullanım sayısını kontrol et
      final usageCount = prefs.getInt('device_usage_$deviceId') ?? 0;
      
      if (usageCount > _suspiciousDeviceThreshold) {
        return true;
      }

      // Kullanım sayısını artır
      await prefs.setInt('device_usage_$deviceId', usageCount + 1);

      return false;
    } catch (e) {
      return true; // Hata durumunda şüpheli kabul et
    }
  }

  /// reCAPTCHA doğrulama (web için)
  Future<bool> _verifyRecaptcha() async {
    try {
      // Bu kısım web'de reCAPTCHA widget'ı ile entegre edilir
      // Şimdilik true döndür
      return true;
    } catch (e) {
      return false;
    }
  }

  /// DeviceCheck doğrulama (iOS için)
  Future<bool> _verifyDeviceCheck() async {
    try {
      // Bu kısım iOS DeviceCheck API'si ile entegre edilir
      // Şimdilik true döndür
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cihaz parmak izi oluştur
  Future<String> generateDeviceFingerprint(Map<String, dynamic> deviceInfo) async {
    try {
      final fingerprint = {
        'platform': deviceInfo['platform'],
        'deviceId': deviceInfo['deviceId'],
        'deviceModel': deviceInfo['deviceModel'],
        'systemVersion': deviceInfo['systemVersion'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      return base64Encode(utf8.encode(jsonEncode(fingerprint)));
    } catch (e) {
      return 'error_fingerprint';
    }
  }

  /// Cihaz bilgilerini temizle
  Future<void> clearDeviceInfo(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('device_usage_$deviceId');
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Cihaz kullanım istatistikleri
  Future<Map<String, dynamic>> getDeviceUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final deviceKeys = keys.where((key) => key.startsWith('device_usage_')).toList();
      
      final stats = <String, int>{};
      for (final key in deviceKeys) {
        final deviceId = key.replaceFirst('device_usage_', '');
        final usageCount = prefs.getInt(key) ?? 0;
        stats[deviceId] = usageCount;
      }

      return {
        'totalDevices': stats.length,
        'suspiciousDevices': stats.values.where((count) => count > _suspiciousDeviceThreshold).length,
        'deviceStats': stats,
      };
    } catch (e) {
      return {
        'totalDevices': 0,
        'suspiciousDevices': 0,
        'deviceStats': {},
      };
    }
  }
}
