import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/platform_utils.dart';
import 'package:flutter/foundation.dart';

/// Desteklenen diller
enum SupportedLocale {
  tr('tr', 'Türkçe', 'Turkish'),
  en('en', 'English', 'İngilizce');

  const SupportedLocale(this.code, this.nativeName, this.englishName);
  
  final String code;
  final String nativeName;
  final String englishName;
}

/// Dil provider - Uygulama dilini yönetir
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  static const String _usersCollection = 'users';
  static const String _settingsCollection = 'settings';

  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Locale _locale = const Locale('tr', 'TR');
  bool _isLoading = false;

  LocaleProvider(this._prefs) {
    _loadLocale();
  }

  /// Mevcut locale
  Locale get locale => _locale;

  /// Yükleniyor durumu
  bool get isLoading => _isLoading;

  /// Türkçe mi?
  bool get isTurkish => _locale.languageCode == 'tr';

  /// İngilizce mi?
  bool get isEnglish => _locale.languageCode == 'en';

  /// Dil kodunu döndür
  String get languageCode => _locale.languageCode;

  /// Ülke kodunu döndür
  String get countryCode => _locale.countryCode ?? '';

  /// Locale'i değiştir
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;

    _locale = newLocale;
    _isLoading = true;
    notifyListeners();

    try {
      // SharedPreferences'a kaydet
      await _prefs.setString(_localeKey, '${newLocale.languageCode}_${newLocale.countryCode}');

      // Firestore'a kaydet (kullanıcı giriş yapmışsa)
      await _saveLocaleToFirestore(newLocale);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Locale kaydedilirken hata: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Locale'i SharedPreferences'dan yükle
  Future<void> _loadLocale() async {
    try {
      final localeString = _prefs.getString(_localeKey);
      if (localeString != null) {
        final parts = localeString.split('_');
        if (parts.length == 2) {
          _locale = Locale(parts[0], parts[1]);
        }
      }

      // Firestore'dan da yükle (kullanıcı giriş yapmışsa)
      await _loadLocaleFromFirestore();

      notifyListeners();
    } catch (e) {
      print('Locale yüklenirken hata: $e');
    }
  }

  /// Locale'i Firestore'a kaydet
  Future<void> _saveLocaleToFirestore(Locale locale) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .collection(_settingsCollection)
            .doc('locale')
            .set({
          'languageCode': locale.languageCode,
          'countryCode': locale.countryCode,
          'updatedAt': FieldValue.serverTimestamp(),
          'platform': PlatformUtils.platformName,
        });
      }
    } catch (e) {
      print('Locale Firestore\'a kaydedilirken hata: $e');
    }
  }

  /// Locale'i Firestore'dan yükle
  Future<void> _loadLocaleFromFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .collection(_settingsCollection)
            .doc('locale')
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final languageCode = data['languageCode'] as String?;
          final countryCode = data['countryCode'] as String?;
          
          if (languageCode != null) {
            final firestoreLocale = Locale(languageCode, countryCode);
            
            // Firestore'daki locale daha güncelse güncelle
            if (firestoreLocale != _locale) {
              _locale = firestoreLocale;
              await _prefs.setString(_localeKey, '${languageCode}_${countryCode ?? ''}');
            }
          }
        }
      }
    } catch (e) {
      print('Locale Firestore\'dan yüklenirken hata: $e');
    }
  }

  /// Locale'i sıfırla (varsayılan: Türkçe)
  Future<void> resetLocale() async {
    await setLocale(const Locale('tr', 'TR'));
  }

  /// Desteklenen locale'leri döndür
  List<SupportedLocale> get supportedLocales => SupportedLocale.values;

  /// Mevcut locale'in SupportedLocale karşılığını döndür
  SupportedLocale get currentSupportedLocale {
    return SupportedLocale.values.firstWhere(
      (sl) => sl.code == _locale.languageCode,
      orElse: () => SupportedLocale.tr,
    );
  }

  /// Locale adını döndür
  String getLocaleName(Locale locale) {
    final supported = SupportedLocale.values.firstWhere(
      (sl) => sl.code == locale.languageCode,
      orElse: () => SupportedLocale.tr,
    );
    
    // Mevcut dilde kendi adını göster
    if (locale.languageCode == 'tr') {
      return supported.nativeName;
    } else {
      return supported.englishName;
    }
  }

  /// Locale açıklamasını döndür
  String getLocaleDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return 'Türkçe dil desteği';
      case 'en':
        return 'English language support';
      default:
        return 'Language support';
    }
  }

  /// Locale ikonunu döndür
  IconData getLocaleIcon(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return Icons.flag; // Türk bayrağı
      case 'en':
        return Icons.flag_outlined; // İngiliz bayrağı
      default:
        return Icons.language;
    }
  }

  /// Locale rengini döndür
  Color getLocaleColor(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return Colors.red; // Türk bayrağı rengi
      case 'en':
        return Colors.blue; // İngiliz bayrağı rengi
      default:
        return Colors.grey;
    }
  }

  /// Sistem locale'ini al
  Locale getSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;
    
    // Sistem locale'i destekleniyor mu kontrol et
    final isSupported = SupportedLocale.values.any(
      (sl) => sl.code == systemLocale.languageCode,
    );
    
    if (isSupported) {
      return systemLocale;
    }
    
    // Desteklenmiyorsa varsayılan döndür
    return const Locale('tr', 'TR');
  }

  /// Sistem dilini kullan
  Future<void> useSystemLocale() async {
    final systemLocale = getSystemLocale();
    await setLocale(systemLocale);
  }

  /// Dil ayarlarını dışa aktar
  Map<String, dynamic> exportLocaleSettings() {
    return {
      'languageCode': _locale.languageCode,
      'countryCode': _locale.countryCode,
      'lastUpdated': DateTime.now().toIso8601String(),
      'platform': PlatformUtils.platformName,
    };
  }

  /// Dil ayarlarını içe aktar
  Future<void> importLocaleSettings(Map<String, dynamic> settings) async {
    try {
      final languageCode = settings['languageCode'] as String?;
      final countryCode = settings['countryCode'] as String?;
      
      if (languageCode != null) {
        final locale = Locale(languageCode, countryCode);
        await setLocale(locale);
      }
    } catch (e) {
      print('Dil ayarları içe aktarılırken hata: $e');
    }
  }

  /// Dil istatistiklerini getir
  Future<Map<String, dynamic>> getLocaleStats() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .collection(_settingsCollection)
            .doc('locale')
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          return {
            'currentLanguage': _locale.languageCode,
            'currentCountry': _locale.countryCode,
            'lastChanged': data['updatedAt']?.toDate()?.toIso8601String(),
            'platform': data['platform'],
            'isSynced': true,
          };
        }
      }

      return {
        'currentLanguage': _locale.languageCode,
        'currentCountry': _locale.countryCode,
        'lastChanged': null,
        'platform': PlatformUtils.platformName,
        'isSynced': false,
      };
    } catch (e) {
      print('Dil istatistikleri getirilirken hata: $e');
      return {
        'currentLanguage': _locale.languageCode,
        'currentCountry': _locale.countryCode,
        'lastChanged': null,
        'platform': PlatformUtils.platformName,
        'isSynced': false,
      };
    }
  }

  /// Desteklenen locale'lerin listesini döndür
  List<Locale> get supportedLocalesList {
    return SupportedLocale.values.map((sl) {
      switch (sl.code) {
        case 'tr':
          return const Locale('tr', 'TR');
        case 'en':
          return const Locale('en', 'US');
        default:
          return const Locale('tr', 'TR');
      }
    }).toList();
  }

  /// Locale değişiklik geçmişini getir
  Future<List<Map<String, dynamic>>> getLocaleHistory() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .collection(_settingsCollection)
            .doc('locale')
            .collection('history')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'languageCode': data['languageCode'],
            'countryCode': data['countryCode'],
            'timestamp': data['timestamp']?.toDate()?.toIso8601String(),
            'platform': data['platform'],
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Dil geçmişi getirilirken hata: $e');
      return [];
    }
  }
} 