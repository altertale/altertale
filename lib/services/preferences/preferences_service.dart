import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/preferences/user_preferences_model.dart';

/// Kullanıcı tercihleri servisi
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SharedPreferences anahtarları
  static const String _preferencesKey = 'user_preferences';
  static const String _isFirstLaunchKey = 'is_first_launch';

  /// Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  /// Kullanıcı tercihlerini yükle
  Future<UserPreferences> loadPreferences() async {
    try {
      // Önce SharedPreferences'dan yükle
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString(_preferencesKey);

      UserPreferences preferences;

      if (preferencesJson != null) {
        final data = jsonDecode(preferencesJson) as Map<String, dynamic>;
        preferences = UserPreferences.fromSharedPreferences(data);
      } else {
        // Varsayılan tercihler
        preferences = UserPreferences.defaultPreferences();
      }

      // Kullanıcı giriş yapmışsa Firebase'den senkronize et
      if (currentUser != null) {
        final cloudPreferences = await _loadFromFirebase();
        if (cloudPreferences != null) {
          // Cloud'daki tercihler daha yeniyse kullan
          if (cloudPreferences.lastUpdated.isAfter(preferences.lastUpdated)) {
            preferences = cloudPreferences;
            // Lokal'e kaydet
            await _saveToSharedPreferences(preferences);
          }
        } else {
          // Cloud'da yoksa mevcut tercihleri yükle
          await _saveToFirebase(preferences);
        }
      }

      return preferences;
    } catch (e) {
      // Hata durumunda varsayılan tercihleri döndür
      return UserPreferences.defaultPreferences();
    }
  }

  /// Tercihleri kaydet
  Future<void> savePreferences(UserPreferences preferences) async {
    try {
      // Önce SharedPreferences'a kaydet
      await _saveToSharedPreferences(preferences);

      // Kullanıcı giriş yapmışsa Firebase'e de kaydet
      if (currentUser != null) {
        await _saveToFirebase(preferences);
      }
    } catch (e) {
      throw Exception('Tercihler kaydedilirken hata oluştu: $e');
    }
  }

  /// Tema modunu güncelle
  Future<void> updateAppThemeMode(AppThemeMode themeMode) async {
    try {
      final currentPreferences = await loadPreferences();
      final newPreferences = currentPreferences.copyWith(themeMode: themeMode);
      await savePreferences(newPreferences);
    } catch (e) {
      throw Exception('Tema modu güncellenirken hata oluştu: $e');
    }
  }

  /// Dil tercihini güncelle
  Future<void> updateLanguage(Language language) async {
    try {
      final currentPreferences = await loadPreferences();
      final newPreferences = currentPreferences.copyWith(language: language);
      await savePreferences(newPreferences);
    } catch (e) {
      throw Exception('Dil tercihi güncellenirken hata oluştu: $e');
    }
  }

  /// Yazı tipi boyutunu güncelle
  Future<void> updateFontSize(FontSize fontSize) async {
    try {
      final currentPreferences = await loadPreferences();
      final newPreferences = currentPreferences.copyWith(fontSize: fontSize);
      await savePreferences(newPreferences);
    } catch (e) {
      throw Exception('Yazı tipi boyutu güncellenirken hata oluştu: $e');
    }
  }

  /// Satır aralığını güncelle
  Future<void> updateLineSpacing(LineSpacing lineSpacing) async {
    try {
      final currentPreferences = await loadPreferences();
      final newPreferences = currentPreferences.copyWith(lineSpacing: lineSpacing);
      await savePreferences(newPreferences);
    } catch (e) {
      throw Exception('Satır aralığı güncellenirken hata oluştu: $e');
    }
  }

  /// Okuma arka plan rengini güncelle
  Future<void> updateReadingBackground(ReadingBackground background) async {
    try {
      final currentPreferences = await loadPreferences();
      final newPreferences = currentPreferences.copyWith(readingBackground: background);
      await savePreferences(newPreferences);
    } catch (e) {
      throw Exception('Okuma arka plan rengi güncellenirken hata oluştu: $e');
    }
  }

  /// Bildirim ayarını güncelle
  Future<void> updateNotificationsEnabled(bool enabled) async {
    try {
      final currentPreferences = await loadPreferences();
      final newPreferences = currentPreferences.copyWith(notificationsEnabled: enabled);
      await savePreferences(newPreferences);
    } catch (e) {
      throw Exception('Bildirim ayarı güncellenirken hata oluştu: $e');
    }
  }

  /// Otomatik senkronizasyon ayarını güncelle
  Future<void> updateAutoSyncEnabled(bool enabled) async {
    try {
      final currentPreferences = await loadPreferences();
      final newPreferences = currentPreferences.copyWith(autoSyncEnabled: enabled);
      await savePreferences(newPreferences);
    } catch (e) {
      throw Exception('Otomatik senkronizasyon ayarı güncellenirken hata oluştu: $e');
    }
  }

  /// Tercihleri sıfırla
  Future<void> resetPreferences() async {
    try {
      final defaultPreferences = UserPreferences.defaultPreferences();
      await savePreferences(defaultPreferences);
    } catch (e) {
      throw Exception('Tercihler sıfırlanırken hata oluştu: $e');
    }
  }

  /// İlk kez açılıp açılmadığını kontrol et
  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isFirstLaunchKey) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// İlk açılış bayrağını ayarla
  Future<void> setFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstLaunchKey, false);
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Kullanıcı tercihlerini temizle (çıkış yaparken)
  Future<void> clearUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_preferencesKey);
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// SharedPreferences'a kaydet
  Future<void> _saveToSharedPreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = jsonEncode(preferences.toSharedPreferences());
    await prefs.setString(_preferencesKey, preferencesJson);
  }

  /// Firebase'e kaydet
  Future<void> _saveToFirebase(UserPreferences preferences) async {
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('preferences')
        .doc('settings')
        .set(preferences.toFirestore());
  }

  /// Firebase'den yükle
  Future<UserPreferences?> _loadFromFirebase() async {
    if (currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('preferences')
          .doc('settings')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserPreferences.fromFirestore(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Tercihleri Firebase ile senkronize et
  Future<void> syncWithFirebase() async {
    if (currentUser == null) return;

    try {
      final localPreferences = await loadPreferences();
      final cloudPreferences = await _loadFromFirebase();

      if (cloudPreferences != null) {
        // Cloud'daki tercihler daha yeniyse kullan
        if (cloudPreferences.lastUpdated.isAfter(localPreferences.lastUpdated)) {
          await _saveToSharedPreferences(cloudPreferences);
        } else {
          // Lokal tercihler daha yeniyse cloud'a yükle
          await _saveToFirebase(localPreferences);
        }
      } else {
        // Cloud'da yoksa lokal tercihleri yükle
        await _saveToFirebase(localPreferences);
      }
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }
}
